import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/cache/cache.dart';
import '../../../../core/error/api_exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../data/models/student_dashboard.dart';

// ==================== Student Dashboard State ====================

class StudentDashboardState implements CachedState<StudentDashboard> {
  @override
  final StudentDashboard? data;
  @override
  final bool isLoading;
  @override
  final String? error;
  @override
  final CacheMetadata cache;

  const StudentDashboardState({
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

  // Backwards compatible getter
  StudentDashboard? get dashboard => data;

  StudentDashboardState copyWith({
    StudentDashboard? dashboard,
    bool? isLoading,
    String? error,
    CacheMetadata? cache,
  }) {
    return StudentDashboardState(
      data: dashboard ?? data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      cache: cache ?? this.cache,
    );
  }

  // Convenience getters
  StudentStats get stats => data?.stats ?? const StudentStats();
  TodayWorkout? get todayWorkout => data?.todayWorkout;
  WeeklyProgress get weeklyProgress =>
      data?.weeklyProgress ?? const WeeklyProgress();
  List<RecentActivity> get recentActivity => data?.recentActivity ?? [];
  TrainerInfo? get trainer => data?.trainer;
  PlanProgress? get planProgress => data?.planProgress;
  int get unreadNotesCount => data?.unreadNotesCount ?? 0;

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

class StudentDashboardNotifier
    extends CachedStateNotifier<StudentDashboardState> {
  final ApiClient _client;

  StudentDashboardNotifier({
    required Ref ref,
    ApiClient? client,
  })  : _client = client ?? ApiClient.instance,
        super(
          const StudentDashboardState(),
          config: CacheConfigs.dashboard, // 1 min TTL, auto-refresh
          ref: ref,
        );

  /// Events that should trigger a refresh of this provider
  @override
  Set<CacheEventType> get invalidationEvents => {
        CacheEventType.workoutCompleted,
        CacheEventType.sessionCompleted,
        CacheEventType.planAssigned,
        CacheEventType.planAcknowledged,
        CacheEventType.checkInCompleted,
        CacheEventType.contextChanged,
        CacheEventType.appResumed,
      };

  @override
  Future<void> fetchData() async {
    try {
      final response = await _client.get(ApiEndpoints.studentDashboard);
      if (response.statusCode == 200 && response.data != null) {
        final dashboard = StudentDashboard.fromJson(
          response.data as Map<String, dynamic>,
        );
        onFetchSuccess(dashboard);
      } else {
        throw Exception('Erro ao carregar dashboard');
      }
    } on DioException catch (e) {
      final message = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Erro ao carregar dashboard';
      throw Exception(message);
    }
  }

  @override
  StudentDashboardState updateStateWithData(
    dynamic data,
    CacheMetadata newCache,
  ) {
    return state.copyWith(
      dashboard: data as StudentDashboard,
      isLoading: false,
      error: null,
      cache: newCache,
    );
  }

  @override
  StudentDashboardState updateStateForLoading(
    bool isLoading,
    CacheMetadata cache,
  ) {
    return state.copyWith(isLoading: isLoading, cache: cache);
  }

  @override
  StudentDashboardState updateStateForError(
    String error,
    CacheMetadata cache,
  ) {
    return state.copyWith(isLoading: false, error: error, cache: cache);
  }

  // Keep old method name for backwards compatibility
  Future<void> loadDashboard() => loadData(forceRefresh: true);
}

// ==================== Providers ====================

final studentDashboardProvider =
    StateNotifierProvider<StudentDashboardNotifier, StudentDashboardState>(
  (ref) => StudentDashboardNotifier(ref: ref),
);

// NEW: Provider to check if data is being refreshed in background
final isStudentDashboardRefreshingProvider = Provider<bool>((ref) {
  return ref.watch(studentDashboardProvider).cache.isRefreshing;
});

// NEW: Provider to check if data is stale
final isStudentDashboardStaleProvider = Provider<bool>((ref) {
  final state = ref.watch(studentDashboardProvider);
  return state.isStale(CacheConfigs.dashboard);
});

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
  final Ref _ref;

  StudentNewPlansNotifier({required Ref ref, ApiClient? client})
      : _ref = ref,
        _client = client ?? ApiClient.instance,
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
        // Emit cache event to invalidate trainer's view
        final planId = response.data?['plan_id'] as String?;
        if (planId != null) {
          _ref.read(cacheEventEmitterProvider).planAcknowledged(planId);
        }
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
  (ref) => StudentNewPlansNotifier(ref: ref),
);

// Backwards compatibility alias
final studentPendingPlansProvider = studentNewPlansProvider;
typedef StudentPendingPlansState = StudentNewPlansState;
typedef StudentPendingPlansNotifier = StudentNewPlansNotifier;
