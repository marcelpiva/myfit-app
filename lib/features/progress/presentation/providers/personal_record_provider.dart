import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/models/personal_record.dart';

// ==================== Personal Records State ====================

class PersonalRecordsState {
  final List<ExercisePRSummary> exercises;
  final int totalPRs;
  final int prsThisMonth;
  final String? mostImprovedExercise;
  final bool isLoading;
  final String? error;

  const PersonalRecordsState({
    this.exercises = const [],
    this.totalPRs = 0,
    this.prsThisMonth = 0,
    this.mostImprovedExercise,
    this.isLoading = false,
    this.error,
  });

  PersonalRecordsState copyWith({
    List<ExercisePRSummary>? exercises,
    int? totalPRs,
    int? prsThisMonth,
    String? mostImprovedExercise,
    bool? isLoading,
    String? error,
  }) {
    return PersonalRecordsState(
      exercises: exercises ?? this.exercises,
      totalPRs: totalPRs ?? this.totalPRs,
      prsThisMonth: prsThisMonth ?? this.prsThisMonth,
      mostImprovedExercise: mostImprovedExercise ?? this.mostImprovedExercise,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get exercises with PRs
  List<ExercisePRSummary> get exercisesWithPRs =>
      exercises.where((e) => e.hasPRs).toList();

  /// Get exercises grouped by muscle group
  Map<String, List<ExercisePRSummary>> get exercisesByMuscleGroup {
    final grouped = <String, List<ExercisePRSummary>>{};
    for (final exercise in exercisesWithPRs) {
      final group = exercise.muscleGroup ?? 'Outros';
      grouped.putIfAbsent(group, () => []).add(exercise);
    }
    return grouped;
  }
}

class PersonalRecordsNotifier extends StateNotifier<PersonalRecordsState> {
  final ApiClient _client;

  PersonalRecordsNotifier({ApiClient? client})
      : _client = client ?? ApiClient.instance,
        super(const PersonalRecordsState()) {
    loadPersonalRecords();
  }

  Future<void> loadPersonalRecords() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client.get(ApiEndpoints.personalRecords);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final list = PersonalRecordList.fromJson(data);
        state = state.copyWith(
          exercises: list.exercises,
          totalPRs: list.totalPRs,
          prsThisMonth: list.prsThisMonth,
          mostImprovedExercise: list.mostImprovedExercise,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erro ao carregar PRs',
        );
      }
    } on DioException catch (e) {
      final message = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Erro ao carregar PRs';
      state = state.copyWith(isLoading: false, error: message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro inesperado: $e',
      );
    }
  }

  void refresh() => loadPersonalRecords();
}

// ==================== Exercise PR Detail State ====================

class ExercisePRDetailState {
  final ExercisePRSummary? summary;
  final List<PersonalRecord> history;
  final bool isLoading;
  final String? error;

  const ExercisePRDetailState({
    this.summary,
    this.history = const [],
    this.isLoading = false,
    this.error,
  });

  ExercisePRDetailState copyWith({
    ExercisePRSummary? summary,
    List<PersonalRecord>? history,
    bool? isLoading,
    String? error,
  }) {
    return ExercisePRDetailState(
      summary: summary ?? this.summary,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ExercisePRDetailNotifier extends StateNotifier<ExercisePRDetailState> {
  final ApiClient _client;
  final String exerciseId;

  ExercisePRDetailNotifier({
    required this.exerciseId,
    ApiClient? client,
  })  : _client = client ?? ApiClient.instance,
        super(const ExercisePRDetailState()) {
    loadExercisePRs();
  }

  Future<void> loadExercisePRs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client.get(
        ApiEndpoints.exercisePersonalRecords(exerciseId),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final summary = ExercisePRSummary.fromJson(data['summary'] ?? data);
        final historyData = data['history'] as List<dynamic>? ?? [];
        final history = historyData
            .map((e) => PersonalRecord.fromJson(e as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          summary: summary,
          history: history,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erro ao carregar detalhes',
        );
      }
    } on DioException catch (e) {
      final message = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Erro ao carregar detalhes';
      state = state.copyWith(isLoading: false, error: message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro inesperado: $e',
      );
    }
  }

  void refresh() => loadExercisePRs();
}

// ==================== Providers ====================

final personalRecordsProvider =
    StateNotifierProvider<PersonalRecordsNotifier, PersonalRecordsState>(
  (ref) => PersonalRecordsNotifier(),
);

final exercisePRDetailProvider = StateNotifierProvider.family<
    ExercisePRDetailNotifier, ExercisePRDetailState, String>(
  (ref, exerciseId) => ExercisePRDetailNotifier(exerciseId: exerciseId),
);

// Convenience providers
final totalPRsProvider = Provider<int>((ref) {
  return ref.watch(personalRecordsProvider).totalPRs;
});

final prsThisMonthProvider = Provider<int>((ref) {
  return ref.watch(personalRecordsProvider).prsThisMonth;
});

final exercisesWithPRsProvider = Provider<List<ExercisePRSummary>>((ref) {
  return ref.watch(personalRecordsProvider).exercisesWithPRs;
});

final prsByMuscleGroupProvider =
    Provider<Map<String, List<ExercisePRSummary>>>((ref) {
  return ref.watch(personalRecordsProvider).exercisesByMuscleGroup;
});
