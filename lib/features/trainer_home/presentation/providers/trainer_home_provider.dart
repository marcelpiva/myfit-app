import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/organization_service.dart';
import '../../../../core/services/schedule_service.dart';
import '../../../../core/services/workout_service.dart';
import '../../../checkin/presentation/providers/checkin_provider.dart';

// Service providers
final trainerHomeOrgServiceProvider = Provider<OrganizationService>((ref) {
  return OrganizationService();
});

final trainerHomeWorkoutServiceProvider = Provider<WorkoutService>((ref) {
  return WorkoutService();
});

final trainerHomeScheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService();
});

// ==================== Trainer Dashboard State ====================

class TrainerDashboardState {
  final int totalStudents;
  final int activeStudents;
  final int todaySessions;
  final int pendingWorkouts;
  final List<Map<String, dynamic>> recentActivities;
  final List<Map<String, dynamic>> alerts;
  final List<Map<String, dynamic>> todaySchedule;
  final bool isLoading;
  final String? error;

  const TrainerDashboardState({
    this.totalStudents = 0,
    this.activeStudents = 0,
    this.todaySessions = 0,
    this.pendingWorkouts = 0,
    this.recentActivities = const [],
    this.alerts = const [],
    this.todaySchedule = const [],
    this.isLoading = false,
    this.error,
  });

  TrainerDashboardState copyWith({
    int? totalStudents,
    int? activeStudents,
    int? todaySessions,
    int? pendingWorkouts,
    List<Map<String, dynamic>>? recentActivities,
    List<Map<String, dynamic>>? alerts,
    List<Map<String, dynamic>>? todaySchedule,
    bool? isLoading,
    String? error,
  }) {
    return TrainerDashboardState(
      totalStudents: totalStudents ?? this.totalStudents,
      activeStudents: activeStudents ?? this.activeStudents,
      todaySessions: todaySessions ?? this.todaySessions,
      pendingWorkouts: pendingWorkouts ?? this.pendingWorkouts,
      recentActivities: recentActivities ?? this.recentActivities,
      alerts: alerts ?? this.alerts,
      todaySchedule: todaySchedule ?? this.todaySchedule,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TrainerDashboardNotifier extends StateNotifier<TrainerDashboardState> {
  final OrganizationService _orgService;
  final WorkoutService _workoutService;
  final ScheduleService _scheduleService;
  final Ref _ref;
  final String? orgId;

  TrainerDashboardNotifier(
    this._orgService,
    this._workoutService,
    this._scheduleService,
    this._ref,
    this.orgId,
  ) : super(const TrainerDashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    if (orgId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Load members to get student count
      final members = await _orgService.getMembers(orgId!, role: 'student');
      final activeMembers = members.where((m) => m['status'] == 'active').length;

      // Load workouts to get pending count
      final workouts = await _workoutService.getWorkoutAssignments();
      final pendingWorkouts = workouts.where((w) => w['status'] == 'draft').length;

      // Build activities from recent check-ins
      final activities = _buildRecentActivities();

      // Build alerts
      final alerts = _buildAlerts(members, workouts);

      // Load today's schedule
      List<Map<String, dynamic>> todaySchedule = [];
      try {
        todaySchedule = await _scheduleService.getAppointmentsForDay(DateTime.now());
      } catch (_) {
        // Schedule loading is non-critical, continue with empty list
      }

      state = state.copyWith(
        totalStudents: members.length,
        activeStudents: activeMembers,
        todaySessions: todaySchedule.length,
        pendingWorkouts: pendingWorkouts,
        recentActivities: activities,
        alerts: alerts,
        todaySchedule: todaySchedule,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar dashboard');
    }
  }

  List<Map<String, dynamic>> _buildRecentActivities() {
    // Get recent check-ins from the check-in provider
    final checkIns = _ref.read(checkInHistoryProvider);

    return checkIns.take(5).map((checkIn) {
      return {
        'type': 'checkin',
        'title': '${checkIn.memberName ?? 'Aluno'} fez check-in',
        'subtitle': checkIn.organizationName,
        'time': _formatTime(checkIn.timestamp),
        'icon': 'log_in',
      };
    }).toList();
  }

  List<Map<String, dynamic>> _buildAlerts(
    List<Map<String, dynamic>> members,
    List<Map<String, dynamic>> workouts,
  ) {
    final alerts = <Map<String, dynamic>>[];

    // Alert for inactive students (no workout in 7+ days)
    final inactiveCount = members.where((m) {
      final lastWorkout = m['last_workout_at'] as String?;
      if (lastWorkout == null) return true;
      final date = DateTime.tryParse(lastWorkout);
      if (date == null) return true;
      return DateTime.now().difference(date).inDays > 7;
    }).length;

    if (inactiveCount > 0) {
      alerts.add({
        'type': 'warning',
        'title': '$inactiveCount alunos inativos',
        'subtitle': 'Sem treino há mais de 7 dias',
        'action': 'view_students',
      });
    }

    // Alert for pending workouts
    final pendingCount = workouts.where((w) => w['status'] == 'draft').length;
    if (pendingCount > 0) {
      alerts.add({
        'type': 'info',
        'title': '$pendingCount treinos pendentes',
        'subtitle': 'Aguardando ativação',
        'action': 'view_workouts',
      });
    }

    return alerts;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    return 'Há ${diff.inDays}d';
  }

  void refresh() => loadDashboard();
}

final trainerDashboardNotifierProvider =
    StateNotifierProvider.family<TrainerDashboardNotifier, TrainerDashboardState, String?>((ref, orgId) {
  final orgService = ref.watch(trainerHomeOrgServiceProvider);
  final workoutService = ref.watch(trainerHomeWorkoutServiceProvider);
  final scheduleService = ref.watch(trainerHomeScheduleServiceProvider);
  return TrainerDashboardNotifier(orgService, workoutService, scheduleService, ref, orgId);
});

// ==================== Convenience Providers ====================

final trainerStatsProvider = Provider.family<Map<String, int>, String?>((ref, orgId) {
  final state = ref.watch(trainerDashboardNotifierProvider(orgId));
  return {
    'totalStudents': state.totalStudents,
    'activeStudents': state.activeStudents,
    'todaySessions': state.todaySessions,
    'pendingWorkouts': state.pendingWorkouts,
  };
});

final trainerActivitiesProvider = Provider.family<List<Map<String, dynamic>>, String?>((ref, orgId) {
  return ref.watch(trainerDashboardNotifierProvider(orgId)).recentActivities;
});

final trainerAlertsProvider = Provider.family<List<Map<String, dynamic>>, String?>((ref, orgId) {
  return ref.watch(trainerDashboardNotifierProvider(orgId)).alerts;
});

final trainerScheduleProvider = Provider.family<List<Map<String, dynamic>>, String?>((ref, orgId) {
  return ref.watch(trainerDashboardNotifierProvider(orgId)).todaySchedule;
});

// Loading state
final isTrainerDashboardLoadingProvider = Provider.family<bool, String?>((ref, orgId) {
  return ref.watch(trainerDashboardNotifierProvider(orgId)).isLoading;
});
