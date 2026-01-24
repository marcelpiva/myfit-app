import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/cache/cache.dart';
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

// ==================== Trainer Dashboard Data ====================

class TrainerDashboardData {
  final int totalStudents;
  final int activeStudents;
  final int todaySessions;
  final int pendingWorkouts;
  final List<Map<String, dynamic>> recentActivities;
  final List<Map<String, dynamic>> alerts;
  final List<Map<String, dynamic>> todaySchedule;

  const TrainerDashboardData({
    this.totalStudents = 0,
    this.activeStudents = 0,
    this.todaySessions = 0,
    this.pendingWorkouts = 0,
    this.recentActivities = const [],
    this.alerts = const [],
    this.todaySchedule = const [],
  });
}

// ==================== Trainer Dashboard State ====================

class TrainerDashboardState implements CachedState<TrainerDashboardData> {
  @override
  final TrainerDashboardData? data;
  @override
  final bool isLoading;
  @override
  final String? error;
  @override
  final CacheMetadata cache;

  const TrainerDashboardState({
    this.data,
    this.isLoading = false,
    this.error,
    this.cache = const CacheMetadata(),
  });

  // CachedState implementation
  @override
  bool get hasData => data != null;

  @override
  bool isStale(CacheConfig config) => cache.isStale(config);

  @override
  bool get isBackgroundRefresh => cache.isRefreshing && hasData;

  // Convenience getters
  int get totalStudents => data?.totalStudents ?? 0;
  int get activeStudents => data?.activeStudents ?? 0;
  int get todaySessions => data?.todaySessions ?? 0;
  int get pendingWorkouts => data?.pendingWorkouts ?? 0;
  List<Map<String, dynamic>> get recentActivities =>
      data?.recentActivities ?? const [];
  List<Map<String, dynamic>> get alerts => data?.alerts ?? const [];
  List<Map<String, dynamic>> get todaySchedule =>
      data?.todaySchedule ?? const [];

  TrainerDashboardState copyWith({
    TrainerDashboardData? data,
    bool? isLoading,
    String? error,
    CacheMetadata? cache,
  }) {
    return TrainerDashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      cache: cache ?? this.cache,
    );
  }
}

class TrainerDashboardNotifier
    extends CachedStateNotifier<TrainerDashboardState> {
  final OrganizationService _orgService;
  final WorkoutService _workoutService;
  final ScheduleService _scheduleService;
  final String? orgId;

  TrainerDashboardNotifier({
    required Ref ref,
    required OrganizationService orgService,
    required WorkoutService workoutService,
    required ScheduleService scheduleService,
    this.orgId,
  })  : _orgService = orgService,
        _workoutService = workoutService,
        _scheduleService = scheduleService,
        super(
          const TrainerDashboardState(),
          config: CacheConfigs.dashboard, // 1 min TTL, auto-refresh
          ref: ref,
        );

  /// Events that should trigger a refresh of this provider
  @override
  Set<CacheEventType> get invalidationEvents => {
        CacheEventType.workoutCompleted,
        CacheEventType.sessionCompleted,
        CacheEventType.checkInCompleted,
        CacheEventType.studentAdded,
        CacheEventType.studentRemoved,
        CacheEventType.inviteAccepted,
        CacheEventType.contextChanged,
        CacheEventType.appResumed,
      };

  @override
  Future<void> fetchData() async {
    if (orgId == null) {
      onFetchSuccess(const TrainerDashboardData());
      return;
    }

    try {
      // Load members to get student count
      final members = await _orgService.getMembers(orgId!, role: 'student');
      final activeMembers =
          members.where((m) => m['status'] == 'active').length;

      // Load workouts to get pending count
      final workouts = await _workoutService.getWorkoutAssignments();
      final pendingWorkouts =
          workouts.where((w) => w['status'] == 'draft').length;

      // Build activities from recent check-ins
      final activities = _buildRecentActivities();

      // Build alerts
      final alerts = _buildAlerts(members, workouts);

      // Load today's schedule
      List<Map<String, dynamic>> todaySchedule = [];
      try {
        todaySchedule =
            await _scheduleService.getAppointmentsForDay(DateTime.now());
      } catch (_) {
        // Schedule loading is non-critical, continue with empty list
      }

      final data = TrainerDashboardData(
        totalStudents: members.length,
        activeStudents: activeMembers,
        todaySessions: todaySchedule.length,
        pendingWorkouts: pendingWorkouts,
        recentActivities: activities,
        alerts: alerts,
        todaySchedule: todaySchedule,
      );

      onFetchSuccess(data);
    } catch (e) {
      throw Exception('Erro ao carregar dashboard');
    }
  }

  @override
  TrainerDashboardState updateStateWithData(
    dynamic data,
    CacheMetadata newCache,
  ) {
    return state.copyWith(
      data: data as TrainerDashboardData,
      isLoading: false,
      error: null,
      cache: newCache,
    );
  }

  @override
  TrainerDashboardState updateStateForLoading(
    bool isLoading,
    CacheMetadata cache,
  ) {
    return state.copyWith(isLoading: isLoading, cache: cache);
  }

  @override
  TrainerDashboardState updateStateForError(
    String error,
    CacheMetadata cache,
  ) {
    return state.copyWith(isLoading: false, error: error, cache: cache);
  }

  List<Map<String, dynamic>> _buildRecentActivities() {
    // Get recent check-ins from the check-in provider
    final checkIns = ref.read(checkInHistoryProvider);

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

  // Keep old method name for backwards compatibility
  Future<void> loadDashboard() => loadData(forceRefresh: true);
}

final trainerDashboardNotifierProvider = StateNotifierProvider.family<
    TrainerDashboardNotifier, TrainerDashboardState, String?>((ref, orgId) {
  final orgService = ref.watch(trainerHomeOrgServiceProvider);
  final workoutService = ref.watch(trainerHomeWorkoutServiceProvider);
  final scheduleService = ref.watch(trainerHomeScheduleServiceProvider);
  return TrainerDashboardNotifier(
    ref: ref,
    orgService: orgService,
    workoutService: workoutService,
    scheduleService: scheduleService,
    orgId: orgId,
  );
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
