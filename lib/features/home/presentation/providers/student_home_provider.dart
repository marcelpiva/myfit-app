import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../data/models/student_dashboard.dart';

// ==================== Student Dashboard State ====================

class StudentDashboardState {
  final StudentDashboard? dashboard;
  final bool isLoading;
  final String? error;

  const StudentDashboardState({
    this.dashboard,
    this.isLoading = false,
    this.error,
  });

  StudentDashboardState copyWith({
    StudentDashboard? dashboard,
    bool? isLoading,
    String? error,
  }) {
    return StudentDashboardState(
      dashboard: dashboard ?? this.dashboard,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Convenience getters
  StudentStats get stats => dashboard?.stats ?? const StudentStats();
  TodayWorkout? get todayWorkout => dashboard?.todayWorkout;
  WeeklyProgress get weeklyProgress =>
      dashboard?.weeklyProgress ?? const WeeklyProgress();
  List<RecentActivity> get recentActivity =>
      dashboard?.recentActivity ?? [];
  TrainerInfo? get trainer => dashboard?.trainer;
  PlanProgress? get planProgress => dashboard?.planProgress;
  int get unreadNotesCount => dashboard?.unreadNotesCount ?? 0;

  // Training mode helpers
  TrainingMode get trainingMode =>
      planProgress?.trainingMode ?? TrainingMode.presencial;
  bool get canTrainWithPersonal =>
      trainingMode == TrainingMode.presencial ||
      trainingMode == TrainingMode.hibrido;
  bool get hasTrainer => trainer != null;
  bool get hasPlan => planProgress != null;
  bool get hasTodayWorkout => todayWorkout != null;
}

class StudentDashboardNotifier extends StateNotifier<StudentDashboardState> {
  final ApiClient _client;

  StudentDashboardNotifier({ApiClient? client})
      : _client = client ?? ApiClient.instance,
        super(const StudentDashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client.get(ApiEndpoints.studentDashboard);
      if (response.statusCode == 200 && response.data != null) {
        final dashboard = StudentDashboard.fromJson(
          response.data as Map<String, dynamic>,
        );
        state = state.copyWith(
          dashboard: dashboard,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erro ao carregar dashboard',
        );
      }
    } on DioException catch (e) {
      final message = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Erro ao carregar dashboard';
      state = state.copyWith(isLoading: false, error: message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro inesperado: $e',
      );
    }
  }

  void refresh() => loadDashboard();
}

// ==================== Providers ====================

final studentDashboardProvider =
    StateNotifierProvider<StudentDashboardNotifier, StudentDashboardState>(
  (ref) => StudentDashboardNotifier(),
);

// Convenience providers for specific data
final studentStatsProvider = Provider<StudentStats>((ref) {
  return ref.watch(studentDashboardProvider).stats;
});

final todayWorkoutProvider = Provider<TodayWorkout?>((ref) {
  return ref.watch(studentDashboardProvider).todayWorkout;
});

final weeklyProgressProvider = Provider<WeeklyProgress>((ref) {
  return ref.watch(studentDashboardProvider).weeklyProgress;
});

final recentActivityProvider = Provider<List<RecentActivity>>((ref) {
  return ref.watch(studentDashboardProvider).recentActivity;
});

final trainerInfoProvider = Provider<TrainerInfo?>((ref) {
  return ref.watch(studentDashboardProvider).trainer;
});

final planProgressProvider = Provider<PlanProgress?>((ref) {
  return ref.watch(studentDashboardProvider).planProgress;
});

final unreadNotesCountProvider = Provider<int>((ref) {
  return ref.watch(studentDashboardProvider).unreadNotesCount;
});

final canTrainWithPersonalProvider = Provider<bool>((ref) {
  return ref.watch(studentDashboardProvider).canTrainWithPersonal;
});

final isStudentDashboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(studentDashboardProvider).isLoading;
});

// ==================== Student New Plans Provider ====================

/// State for student's new (unacknowledged) plan assignments
/// Plans are now auto-accepted, so we show "new" plans instead of "pending"
class StudentNewPlansState {
  final List<Map<String, dynamic>> newPlans;
  final bool isLoading;
  final bool isAcknowledging;
  final String? error;

  const StudentNewPlansState({
    this.newPlans = const [],
    this.isLoading = false,
    this.isAcknowledging = false,
    this.error,
  });

  StudentNewPlansState copyWith({
    List<Map<String, dynamic>>? newPlans,
    bool? isLoading,
    bool? isAcknowledging,
    String? error,
  }) {
    return StudentNewPlansState(
      newPlans: newPlans ?? this.newPlans,
      isLoading: isLoading ?? this.isLoading,
      isAcknowledging: isAcknowledging ?? this.isAcknowledging,
      error: error,
    );
  }

  bool get hasNewPlans => newPlans.isNotEmpty;
  int get newCount => newPlans.length;

  // Backwards compatibility aliases
  bool get hasPendingPlans => hasNewPlans;
  int get pendingCount => newCount;
  List<Map<String, dynamic>> get pendingPlans => newPlans;
}

class StudentNewPlansNotifier extends StateNotifier<StudentNewPlansState> {
  final ApiClient _client;

  StudentNewPlansNotifier({ApiClient? client})
      : _client = client ?? ApiClient.instance,
        super(const StudentNewPlansState()) {
    loadNewPlans();
  }

  Future<void> loadNewPlans() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client.get(
        ApiEndpoints.planAssignments,
        queryParameters: {
          'as_trainer': false,
          'active_only': true,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final allPlans = (response.data as List).cast<Map<String, dynamic>>();
        // Filter plans where acknowledged_at is null (new/unseen plans)
        final newPlans = allPlans
            .where((p) =>
                p['acknowledged_at'] == null &&
                p['status'] == 'accepted' &&
                p['is_active'] == true)
            .toList();

        // Sort by created_at descending (newest first)
        newPlans.sort((a, b) {
          final aDate = DateTime.tryParse(a['created_at'] as String? ?? '');
          final bDate = DateTime.tryParse(b['created_at'] as String? ?? '');
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate);
        });

        state = state.copyWith(
          newPlans: newPlans,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erro ao carregar novos planos',
        );
      }
    } on DioException catch (e) {
      final message = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Erro ao carregar novos planos';
      state = state.copyWith(isLoading: false, error: message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro inesperado: $e',
      );
    }
  }

  /// Mark a plan as acknowledged/seen
  Future<bool> acknowledgePlan(String assignmentId) async {
    state = state.copyWith(isAcknowledging: true, error: null);
    try {
      final response = await _client.post(
        '${ApiEndpoints.planAssignments}/$assignmentId/acknowledge',
      );
      if (response.statusCode == 200) {
        await loadNewPlans();
        state = state.copyWith(isAcknowledging: false);
        return true;
      }
      state = state.copyWith(isAcknowledging: false, error: 'Erro ao marcar plano como visto');
      return false;
    } catch (e) {
      state = state.copyWith(isAcknowledging: false, error: e.toString());
      return false;
    }
  }

  void refresh() => loadNewPlans();
}

final studentNewPlansProvider =
    StateNotifierProvider<StudentNewPlansNotifier, StudentNewPlansState>(
  (ref) => StudentNewPlansNotifier(),
);

// Backwards compatibility alias
final studentPendingPlansProvider = studentNewPlansProvider;
typedef StudentPendingPlansState = StudentNewPlansState;
typedef StudentPendingPlansNotifier = StudentNewPlansNotifier;
