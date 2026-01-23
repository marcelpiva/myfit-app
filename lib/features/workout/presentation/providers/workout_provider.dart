import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/workout_service.dart';
import '../../../home/presentation/providers/student_home_provider.dart';

// Service provider
final workoutServiceProvider = Provider<WorkoutService>((ref) {
  return WorkoutService();
});

// ==================== Workouts ====================

class WorkoutsState {
  final List<Map<String, dynamic>> workouts;
  final bool isLoading;
  final String? error;

  const WorkoutsState({
    this.workouts = const [],
    this.isLoading = false,
    this.error,
  });

  WorkoutsState copyWith({
    List<Map<String, dynamic>>? workouts,
    bool? isLoading,
    String? error,
  }) {
    return WorkoutsState(
      workouts: workouts ?? this.workouts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WorkoutsNotifier extends StateNotifier<WorkoutsState> {
  final WorkoutService _service;
  final Ref _ref;

  WorkoutsNotifier(this._service, this._ref) : super(const WorkoutsState()) {
    loadWorkouts();
  }

  /// Check if user has a trainer (student with personal)
  bool get _hasTrainer => _ref.read(studentDashboardProvider).hasTrainer;

  Future<void> loadWorkouts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (_hasTrainer) {
        // Student has trainer - don't show individual workouts
        // They should only train workouts within their assigned plans
        debugPrint('loadWorkouts: Student has trainer, no individual workouts');
        state = state.copyWith(workouts: [], isLoading: false);
      } else {
        // Student has no trainer - load their own workouts
        final workouts = await _service.getWorkouts();
        state = state.copyWith(workouts: workouts, isLoading: false);
      }
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar treinos');
    }
  }

  Future<void> createWorkout({
    required String name,
    String? description,
    String? difficulty,
    int? estimatedDuration,
    List<String>? muscleGroups,
  }) async {
    try {
      final workout = await _service.createWorkout(
        name: name,
        description: description,
        difficulty: difficulty,
        estimatedDuration: estimatedDuration,
        muscleGroups: muscleGroups,
      );
      state = state.copyWith(workouts: [workout, ...state.workouts]);
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> updateWorkout(String workoutId, {
    String? name,
    String? description,
    String? difficulty,
    int? estimatedDuration,
    List<String>? muscleGroups,
  }) async {
    try {
      final workout = await _service.updateWorkout(
        workoutId,
        name: name,
        description: description,
        difficulty: difficulty,
        estimatedDuration: estimatedDuration,
        muscleGroups: muscleGroups,
      );
      state = state.copyWith(
        workouts: state.workouts.map((w) => w['id'] == workoutId ? workout : w).toList(),
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _service.deleteWorkout(workoutId);
      state = state.copyWith(
        workouts: state.workouts.where((w) => w['id'] != workoutId).toList(),
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> duplicateWorkout(String workoutId) async {
    try {
      final workout = await _service.duplicateWorkout(workoutId);
      state = state.copyWith(workouts: [workout, ...state.workouts]);
    } on ApiException catch (e) {
      throw e;
    }
  }

  void refresh() => loadWorkouts();
}

final workoutsNotifierProvider = StateNotifierProvider<WorkoutsNotifier, WorkoutsState>((ref) {
  final service = ref.watch(workoutServiceProvider);
  return WorkoutsNotifier(service, ref);
});

// ==================== Workout Sessions ====================

class WorkoutSessionsState {
  final List<Map<String, dynamic>> sessions;
  final Map<String, dynamic>? activeSession;
  final bool isLoading;
  final String? error;

  const WorkoutSessionsState({
    this.sessions = const [],
    this.activeSession,
    this.isLoading = false,
    this.error,
  });

  WorkoutSessionsState copyWith({
    List<Map<String, dynamic>>? sessions,
    Map<String, dynamic>? activeSession,
    bool? isLoading,
    String? error,
    bool clearActiveSession = false,
  }) {
    return WorkoutSessionsState(
      sessions: sessions ?? this.sessions,
      activeSession: clearActiveSession ? null : (activeSession ?? this.activeSession),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WorkoutSessionsNotifier extends StateNotifier<WorkoutSessionsState> {
  final WorkoutService _service;

  WorkoutSessionsNotifier(this._service) : super(const WorkoutSessionsState()) {
    loadSessions();
  }

  Future<void> loadSessions({DateTime? fromDate, DateTime? toDate}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessions = await _service.getWorkoutSessions(
        fromDate: fromDate,
        toDate: toDate,
      );
      state = state.copyWith(sessions: sessions, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar sessões');
    }
  }

  Future<void> startSession({
    required String workoutId,
    String? assignmentId,
  }) async {
    try {
      final session = await _service.startWorkoutSession(
        workoutId: workoutId,
        assignmentId: assignmentId,
      );
      state = state.copyWith(
        activeSession: session,
        sessions: [session, ...state.sessions],
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> recordSet({
    required String sessionId,
    required String exerciseId,
    required int setNumber,
    required int reps,
    double? weight,
    int? durationSeconds,
    String? notes,
  }) async {
    try {
      await _service.recordSessionSet(
        sessionId,
        exerciseId: exerciseId,
        setNumber: setNumber,
        reps: reps,
        weight: weight,
        durationSeconds: durationSeconds,
        notes: notes,
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> completeSession({
    required String sessionId,
    String? notes,
    int? rating,
    int? perceivedExertion,
  }) async {
    try {
      final session = await _service.completeWorkoutSession(
        sessionId,
        notes: notes,
        rating: rating,
        perceivedExertion: perceivedExertion,
      );
      state = state.copyWith(
        activeSession: null,
        sessions: state.sessions.map((s) => s['id'] == sessionId ? session : s).toList(),
        clearActiveSession: true,
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  void refresh() => loadSessions();
}

final workoutSessionsNotifierProvider = StateNotifierProvider<WorkoutSessionsNotifier, WorkoutSessionsState>((ref) {
  final service = ref.watch(workoutServiceProvider);
  return WorkoutSessionsNotifier(service);
});

// ==================== Exercises Library ====================

class ExercisesState {
  final List<Map<String, dynamic>> exercises;
  final bool isLoading;
  final String? error;

  const ExercisesState({
    this.exercises = const [],
    this.isLoading = false,
    this.error,
  });

  ExercisesState copyWith({
    List<Map<String, dynamic>>? exercises,
    bool? isLoading,
    String? error,
  }) {
    return ExercisesState(
      exercises: exercises ?? this.exercises,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ExercisesNotifier extends StateNotifier<ExercisesState> {
  final WorkoutService _service;

  ExercisesNotifier(this._service) : super(const ExercisesState());

  Future<void> loadExercises({
    String? muscleGroup,
    String? equipment,
    String? difficulty,
    String? query,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final exercises = await _service.getExercises(
        muscleGroup: muscleGroup,
        equipment: equipment,
        difficulty: difficulty,
        query: query,
      );
      state = state.copyWith(exercises: exercises, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar exercícios');
    }
  }

  void clearExercises() {
    state = const ExercisesState();
  }
}

final exercisesNotifierProvider = StateNotifierProvider<ExercisesNotifier, ExercisesState>((ref) {
  final service = ref.watch(workoutServiceProvider);
  return ExercisesNotifier(service);
});

// ==================== Convenience Providers ====================

final workoutsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(workoutsNotifierProvider).workouts;
});

final workoutSessionsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(workoutSessionsNotifierProvider).sessions;
});

final activeWorkoutSessionProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(workoutSessionsNotifierProvider).activeSession;
});

final exercisesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(exercisesNotifierProvider).exercises;
});

// Loading state providers
final isWorkoutsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(workoutsNotifierProvider).isLoading;
});

final isWorkoutSessionsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(workoutSessionsNotifierProvider).isLoading;
});

final isExercisesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(exercisesNotifierProvider).isLoading;
});

// ==================== Workout Detail ====================

class WorkoutDetailState {
  final Map<String, dynamic>? workout;
  final List<Map<String, dynamic>> exercises;
  final bool isLoading;
  final String? error;

  const WorkoutDetailState({
    this.workout,
    this.exercises = const [],
    this.isLoading = false,
    this.error,
  });

  WorkoutDetailState copyWith({
    Map<String, dynamic>? workout,
    List<Map<String, dynamic>>? exercises,
    bool? isLoading,
    String? error,
  }) {
    return WorkoutDetailState(
      workout: workout ?? this.workout,
      exercises: exercises ?? this.exercises,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  String get name => workout?['name'] ?? '';
  String get description => workout?['description'] ?? '';
  int get exerciseCount => exercises.length;
  int get estimatedDuration => (workout?['estimated_duration'] ?? 0) as int;
  String get difficulty => workout?['difficulty'] ?? 'intermediate';
}

class WorkoutDetailNotifier extends StateNotifier<WorkoutDetailState> {
  final WorkoutService _service;
  final String workoutId;

  WorkoutDetailNotifier(this._service, this.workoutId)
      : super(const WorkoutDetailState()) {
    loadDetail();
  }

  Future<void> loadDetail() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _service.getWorkout(workoutId),
        _service.getWorkoutExercises(workoutId),
      ]);
      state = state.copyWith(
        workout: results[0] as Map<String, dynamic>,
        exercises: results[1] as List<Map<String, dynamic>>,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar detalhes do treino',
      );
    }
  }

  Future<void> refresh() async => loadDetail();
}

final workoutDetailNotifierProvider = StateNotifierProvider.family<
    WorkoutDetailNotifier, WorkoutDetailState, String>((ref, workoutId) {
  final service = ref.watch(workoutServiceProvider);
  return WorkoutDetailNotifier(service, workoutId);
});

final workoutDetailExercisesProvider =
    Provider.family<List<Map<String, dynamic>>, String>((ref, workoutId) {
  return ref.watch(workoutDetailNotifierProvider(workoutId)).exercises;
});

final isWorkoutDetailLoadingProvider =
    Provider.family<bool, String>((ref, workoutId) {
  return ref.watch(workoutDetailNotifierProvider(workoutId)).isLoading;
});

// ==================== Training Plans ====================

class PlansState {
  final List<Map<String, dynamic>> plans;
  final bool isLoading;
  final String? error;

  const PlansState({
    this.plans = const [],
    this.isLoading = false,
    this.error,
  });

  PlansState copyWith({
    List<Map<String, dynamic>>? plans,
    bool? isLoading,
    String? error,
  }) {
    return PlansState(
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PlansNotifier extends StateNotifier<PlansState> {
  final WorkoutService _service;
  final Ref _ref;

  PlansNotifier(this._service, this._ref) : super(const PlansState()) {
    loadPlans();
  }

  /// Check if user has a trainer (student with personal)
  bool get _hasTrainer => _ref.read(studentDashboardProvider).hasTrainer;

  Future<void> loadPlans() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      List<Map<String, dynamic>> plans;

      if (_hasTrainer) {
        // Student has a trainer - load only assigned plans
        debugPrint('loadPlans: Student has trainer, loading plan assignments');
        final assignments = await _service.getPlanAssignments(activeOnly: true);

        // Transform assignments to plan format for UI consistency
        plans = assignments.map((assignment) {
          final plan = assignment['plan'] as Map<String, dynamic>? ?? {};
          // Map plan_workouts to workouts for UI compatibility
          final planWorkouts = plan['plan_workouts'] as List? ?? [];
          return <String, dynamic>{
            ...plan,
            'workouts': planWorkouts,  // UI expects 'workouts' field
            'assignment_id': assignment['id'],
            'start_date': assignment['start_date'],
            'end_date': assignment['end_date'],
            'trainer_notes': assignment['notes'],
            'is_assigned': true,
          };
        }).toList();

        debugPrint('loadPlans: Loaded ${plans.length} assigned plans');
      } else {
        // Student has no trainer - load their own plans
        debugPrint('loadPlans: Student has no trainer, loading own plans');
        plans = await _service.getPlans();
      }

      state = state.copyWith(plans: plans, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar planos: $e');
      debugPrint('StackTrace: $stackTrace');
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar planos: ${e.runtimeType}');
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      await _service.deletePlan(planId);
      state = state.copyWith(
        plans: state.plans.where((p) => p['id'] != planId).toList(),
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> duplicatePlan(String planId) async {
    try {
      final plan = await _service.duplicatePlan(planId);
      state = state.copyWith(plans: [plan, ...state.plans]);
    } on ApiException catch (e) {
      throw e;
    }
  }

  void refresh() => loadPlans();
}

final plansNotifierProvider = StateNotifierProvider<PlansNotifier, PlansState>((ref) {
  final service = ref.watch(workoutServiceProvider);
  return PlansNotifier(service, ref);
});

final plansProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(plansNotifierProvider).plans;
});

final isPlansLoadingProvider = Provider<bool>((ref) {
  return ref.watch(plansNotifierProvider).isLoading;
});

// ==================== Plan Detail ====================

class PlanDetailState {
  final Map<String, dynamic>? plan;
  final bool isLoading;
  final String? error;

  const PlanDetailState({
    this.plan,
    this.isLoading = false,
    this.error,
  });

  PlanDetailState copyWith({
    Map<String, dynamic>? plan,
    bool? isLoading,
    String? error,
  }) {
    return PlanDetailState(
      plan: plan ?? this.plan,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PlanDetailNotifier extends StateNotifier<PlanDetailState> {
  final WorkoutService _service;
  final String planId;

  PlanDetailNotifier(this._service, this.planId) : super(const PlanDetailState()) {
    loadDetail();
  }

  Future<void> loadDetail() async {
    // Don't make API calls with invalid planId
    if (planId.isEmpty || planId == 'null') {
      state = state.copyWith(isLoading: false, error: 'ID do plano inválido');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final plan = await _service.getPlan(planId);
      state = state.copyWith(plan: plan, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar plano');
    }
  }

  void refresh() => loadDetail();
}

final planDetailNotifierProvider = StateNotifierProvider.family<PlanDetailNotifier, PlanDetailState, String>((ref, planId) {
  final service = ref.watch(workoutServiceProvider);
  return PlanDetailNotifier(service, planId);
});
