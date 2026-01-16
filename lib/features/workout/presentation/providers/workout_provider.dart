import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/workout_service.dart';

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

  WorkoutsNotifier(this._service) : super(const WorkoutsState()) {
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final workouts = await _service.getWorkouts();
      state = state.copyWith(workouts: workouts, isLoading: false);
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
  return WorkoutsNotifier(service);
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

// ==================== Workout Programs ====================

class ProgramsState {
  final List<Map<String, dynamic>> programs;
  final bool isLoading;
  final String? error;

  const ProgramsState({
    this.programs = const [],
    this.isLoading = false,
    this.error,
  });

  ProgramsState copyWith({
    List<Map<String, dynamic>>? programs,
    bool? isLoading,
    String? error,
  }) {
    return ProgramsState(
      programs: programs ?? this.programs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProgramsNotifier extends StateNotifier<ProgramsState> {
  final WorkoutService _service;

  ProgramsNotifier(this._service) : super(const ProgramsState()) {
    loadPrograms();
  }

  Future<void> loadPrograms() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final programs = await _service.getPrograms();
      state = state.copyWith(programs: programs, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar programas');
    }
  }

  Future<void> deleteProgram(String programId) async {
    try {
      await _service.deleteProgram(programId);
      state = state.copyWith(
        programs: state.programs.where((p) => p['id'] != programId).toList(),
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> duplicateProgram(String programId) async {
    try {
      final program = await _service.duplicateProgram(programId);
      state = state.copyWith(programs: [program, ...state.programs]);
    } on ApiException catch (e) {
      throw e;
    }
  }

  void refresh() => loadPrograms();
}

final programsNotifierProvider = StateNotifierProvider<ProgramsNotifier, ProgramsState>((ref) {
  final service = ref.watch(workoutServiceProvider);
  return ProgramsNotifier(service);
});

final programsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(programsNotifierProvider).programs;
});

final isProgramsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(programsNotifierProvider).isLoading;
});

// ==================== Program Detail ====================

class ProgramDetailState {
  final Map<String, dynamic>? program;
  final bool isLoading;
  final String? error;

  const ProgramDetailState({
    this.program,
    this.isLoading = false,
    this.error,
  });

  ProgramDetailState copyWith({
    Map<String, dynamic>? program,
    bool? isLoading,
    String? error,
  }) {
    return ProgramDetailState(
      program: program ?? this.program,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProgramDetailNotifier extends StateNotifier<ProgramDetailState> {
  final WorkoutService _service;
  final String programId;

  ProgramDetailNotifier(this._service, this.programId) : super(const ProgramDetailState()) {
    loadDetail();
  }

  Future<void> loadDetail() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final program = await _service.getProgram(programId);
      state = state.copyWith(program: program, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar programa');
    }
  }

  void refresh() => loadDetail();
}

final programDetailNotifierProvider = StateNotifierProvider.family<ProgramDetailNotifier, ProgramDetailState, String>((ref, programId) {
  final service = ref.watch(workoutServiceProvider);
  return ProgramDetailNotifier(service, programId);
});
