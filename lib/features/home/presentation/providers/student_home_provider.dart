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

// ==================== Student Pending Plans Provider ====================

/// State for student's own pending plan assignments
class StudentPendingPlansState {
  final List<Map<String, dynamic>> pendingPlans;
  final bool isLoading;
  final bool isResponding;
  final String? error;

  const StudentPendingPlansState({
    this.pendingPlans = const [],
    this.isLoading = false,
    this.isResponding = false,
    this.error,
  });

  StudentPendingPlansState copyWith({
    List<Map<String, dynamic>>? pendingPlans,
    bool? isLoading,
    bool? isResponding,
    String? error,
  }) {
    return StudentPendingPlansState(
      pendingPlans: pendingPlans ?? this.pendingPlans,
      isLoading: isLoading ?? this.isLoading,
      isResponding: isResponding ?? this.isResponding,
      error: error,
    );
  }

  bool get hasPendingPlans => pendingPlans.isNotEmpty;
  int get pendingCount => pendingPlans.length;
}

class StudentPendingPlansNotifier extends StateNotifier<StudentPendingPlansState> {
  final ApiClient _client;

  StudentPendingPlansNotifier({ApiClient? client})
      : _client = client ?? ApiClient.instance,
        super(const StudentPendingPlansState()) {
    loadPendingPlans();
  }

  Future<void> loadPendingPlans() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client.get(
        ApiEndpoints.planAssignments,
        queryParameters: {
          'as_trainer': false,
          'active_only': false,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final allPlans = (response.data as List).cast<Map<String, dynamic>>();
        // Filter only pending plans
        final pending = allPlans
            .where((p) => p['status'] == 'pending')
            .toList();

        // Sort by created_at descending
        pending.sort((a, b) {
          final aDate = DateTime.tryParse(a['created_at'] as String? ?? '');
          final bDate = DateTime.tryParse(b['created_at'] as String? ?? '');
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate);
        });

        state = state.copyWith(
          pendingPlans: pending,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erro ao carregar planos pendentes',
        );
      }
    } on DioException catch (e) {
      final message = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Erro ao carregar planos pendentes';
      state = state.copyWith(isLoading: false, error: message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro inesperado: $e',
      );
    }
  }

  Future<bool> acceptPlan(String assignmentId) async {
    state = state.copyWith(isResponding: true, error: null);
    try {
      final response = await _client.post(
        '${ApiEndpoints.planAssignments}/$assignmentId/respond',
        data: {'accept': true},
      );
      if (response.statusCode == 200) {
        await loadPendingPlans();
        state = state.copyWith(isResponding: false);
        return true;
      }
      state = state.copyWith(isResponding: false, error: 'Erro ao aceitar plano');
      return false;
    } catch (e) {
      state = state.copyWith(isResponding: false, error: e.toString());
      return false;
    }
  }

  Future<bool> declinePlan(String assignmentId, {String? reason}) async {
    state = state.copyWith(isResponding: true, error: null);
    try {
      final data = <String, dynamic>{'accept': false};
      if (reason != null && reason.isNotEmpty) {
        data['declined_reason'] = reason;
      }

      final response = await _client.post(
        '${ApiEndpoints.planAssignments}/$assignmentId/respond',
        data: data,
      );
      if (response.statusCode == 200) {
        await loadPendingPlans();
        state = state.copyWith(isResponding: false);
        return true;
      }
      state = state.copyWith(isResponding: false, error: 'Erro ao recusar plano');
      return false;
    } catch (e) {
      state = state.copyWith(isResponding: false, error: e.toString());
      return false;
    }
  }

  void refresh() => loadPendingPlans();
}

final studentPendingPlansProvider =
    StateNotifierProvider<StudentPendingPlansNotifier, StudentPendingPlansState>(
  (ref) => StudentPendingPlansNotifier(),
);
