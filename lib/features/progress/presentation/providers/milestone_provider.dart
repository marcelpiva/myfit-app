import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/milestone.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

part 'milestone_provider.freezed.dart';

/// State for milestones
@freezed
sealed class MilestoneState with _$MilestoneState {
  const MilestoneState._();

  const factory MilestoneState({
    @Default([]) List<Milestone> milestones,
    @Default([]) List<AIInsight> insights,
    MilestoneStats? stats,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingInsights,
    String? error,
  }) = _MilestoneState;

  /// Active milestones
  List<Milestone> get activeMilestones =>
      milestones.where((m) => m.status == MilestoneStatus.active).toList();

  /// Completed milestones
  List<Milestone> get completedMilestones =>
      milestones.where((m) => m.status == MilestoneStatus.completed).toList();

  /// Milestones close to completion (>80%)
  List<Milestone> get almostCompleteMilestones =>
      activeMilestones.where((m) => m.progressPercentage >= 80).toList();

  /// Valid (non-expired, non-dismissed) insights
  List<AIInsight> get validInsights =>
      insights.where((i) => i.isValid && !i.isDismissed).toList();
}

/// Provider for milestone state
final milestoneProvider =
    StateNotifierProvider<MilestoneNotifier, MilestoneState>((ref) {
  return MilestoneNotifier(ref);
});

/// Notifier for milestone operations
class MilestoneNotifier extends StateNotifier<MilestoneState> {
  final Ref _ref;

  MilestoneNotifier(this._ref) : super(const MilestoneState()) {
    loadMilestones();
  }

  ApiClient get _api => _ref.read(apiClientProvider);

  /// Load all milestones for the current user
  Future<void> loadMilestones() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.get(ApiEndpoints.milestones);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        final milestones = (data['milestones'] as List? ?? [])
            .map((m) => Milestone.fromJson(m as Map<String, dynamic>))
            .toList();

        final stats = data['stats'] != null
            ? MilestoneStats.fromJson(data['stats'] as Map<String, dynamic>)
            : null;

        state = state.copyWith(
          milestones: milestones,
          stats: stats,
          isLoading: false,
        );

        // Also load AI insights
        await loadInsights();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Falha ao carregar metas',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar metas: $e',
      );
    }
  }

  /// Load AI insights for the current user
  Future<void> loadInsights() async {
    state = state.copyWith(isLoadingInsights: true);

    try {
      final response = await _api.get(ApiEndpoints.aiInsights);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        final insights = (data['insights'] as List? ?? [])
            .map((i) => AIInsight.fromJson(i as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          insights: insights,
          isLoadingInsights: false,
        );
      } else {
        state = state.copyWith(isLoadingInsights: false);
      }
    } catch (e) {
      // Insights are optional, don't show error
      state = state.copyWith(isLoadingInsights: false);
    }
  }

  /// Create a new milestone
  Future<bool> createMilestone({
    required MilestoneType type,
    required String title,
    String? description,
    required double targetValue,
    required String unit,
    DateTime? targetDate,
    String? exerciseId,
    String? measurementType,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.milestones,
        data: {
          'type': type.name,
          'title': title,
          'description': description,
          'target_value': targetValue,
          'unit': unit,
          'target_date': targetDate?.toIso8601String(),
          'exercise_id': exerciseId,
          'measurement_type': measurementType,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          final milestone = Milestone.fromJson(response.data as Map<String, dynamic>);
          state = state.copyWith(
            milestones: [...state.milestones, milestone],
          );
        }
        return true;
      }
    } catch (e) {
      // Ignore
    }
    return false;
  }

  /// Update milestone progress
  Future<bool> updateProgress(String milestoneId, double newValue, {String? note}) async {
    try {
      final response = await _api.post(
        ApiEndpoints.milestoneProgress(milestoneId),
        data: {
          'value': newValue,
          'note': note,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final updated = Milestone.fromJson(response.data as Map<String, dynamic>);
        state = state.copyWith(
          milestones: state.milestones
              .map((m) => m.id == milestoneId ? updated : m)
              .toList(),
        );
        return true;
      }
    } catch (e) {
      // Ignore
    }
    return false;
  }

  /// Complete a milestone
  Future<bool> completeMilestone(String milestoneId) async {
    try {
      final response = await _api.post(
        ApiEndpoints.milestoneComplete(milestoneId),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(
          milestones: state.milestones.map((m) {
            if (m.id == milestoneId) {
              return Milestone(
                id: m.id,
                userId: m.userId,
                type: m.type,
                title: m.title,
                description: m.description,
                targetValue: m.targetValue,
                currentValue: m.targetValue,
                unit: m.unit,
                status: MilestoneStatus.completed,
                targetDate: m.targetDate,
                completedAt: DateTime.now(),
                createdAt: m.createdAt,
                updatedAt: DateTime.now(),
                exerciseId: m.exerciseId,
                exerciseName: m.exerciseName,
                measurementType: m.measurementType,
                aiInsight: m.aiInsight,
                progressHistory: m.progressHistory,
              );
            }
            return m;
          }).toList(),
        );
        return true;
      }
    } catch (e) {
      // Ignore
    }
    return false;
  }

  /// Delete a milestone
  Future<bool> deleteMilestone(String milestoneId) async {
    try {
      final response = await _api.delete(
        ApiEndpoints.milestoneDetail(milestoneId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        state = state.copyWith(
          milestones: state.milestones.where((m) => m.id != milestoneId).toList(),
        );
        return true;
      }
    } catch (e) {
      // Ignore
    }
    return false;
  }

  /// Dismiss an AI insight
  Future<void> dismissInsight(String insightId) async {
    state = state.copyWith(
      insights: state.insights.map((i) {
        if (i.id == insightId) {
          return AIInsight(
            id: i.id,
            userId: i.userId,
            category: i.category,
            title: i.title,
            content: i.content,
            recommendations: i.recommendations,
            relatedMilestoneId: i.relatedMilestoneId,
            isDismissed: true,
            generatedAt: i.generatedAt,
            expiresAt: i.expiresAt,
            sentiment: i.sentiment,
          );
        }
        return i;
      }).toList(),
    );

    // Also notify backend
    try {
      await _api.post(ApiEndpoints.dismissInsight(insightId));
    } catch (e) {
      // Ignore
    }
  }

  /// Generate new AI insights based on recent progress
  Future<void> generateInsights() async {
    state = state.copyWith(isLoadingInsights: true);

    try {
      final response = await _api.post(ApiEndpoints.generateInsights);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final insights = (data['insights'] as List? ?? [])
            .map((i) => AIInsight.fromJson(i as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          insights: [...state.insights, ...insights],
          isLoadingInsights: false,
        );
      } else {
        state = state.copyWith(isLoadingInsights: false);
      }
    } catch (e) {
      state = state.copyWith(isLoadingInsights: false);
    }
  }
}

/// Provider for a single milestone by ID
final milestoneByIdProvider = Provider.family<Milestone?, String>((ref, id) {
  final state = ref.watch(milestoneProvider);
  return state.milestones.where((m) => m.id == id).firstOrNull;
});

/// Provider for milestones filtered by type
final milestonesByTypeProvider =
    Provider.family<List<Milestone>, MilestoneType>((ref, type) {
  final state = ref.watch(milestoneProvider);
  return state.milestones.where((m) => m.type == type).toList();
});
