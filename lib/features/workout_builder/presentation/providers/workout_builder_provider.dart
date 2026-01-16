import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/workout_service.dart';
import '../../domain/models/exercise.dart';
import 'exercise_catalog_provider.dart';

/// Exercise in the workout being built
class WorkoutBuilderExercise {
  final String id;
  final String exerciseId;
  final String name;
  final String muscleGroup;
  final int sets;
  final String reps;
  final int restSeconds;
  final String notes;
  final int order;

  WorkoutBuilderExercise({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    this.sets = 3,
    this.reps = '10-12',
    this.restSeconds = 60,
    this.notes = '',
    this.order = 0,
  });

  WorkoutBuilderExercise copyWith({
    String? id,
    String? exerciseId,
    String? name,
    String? muscleGroup,
    int? sets,
    String? reps,
    int? restSeconds,
    String? notes,
    int? order,
  }) {
    return WorkoutBuilderExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      notes: notes ?? this.notes,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() => {
        'exercise_id': exerciseId,
        'sets': sets,
        'reps': _parseReps(),
        'rest_seconds': restSeconds,
        'order_index': order,
        if (notes.isNotEmpty) 'notes': notes,
      };

  int _parseReps() {
    // Try to parse reps like "10-12" -> 12, "10" -> 10
    final match = RegExp(r'(\d+)').firstMatch(reps);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 10;
  }

  factory WorkoutBuilderExercise.fromExercise(Exercise exercise, int order) {
    return WorkoutBuilderExercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exerciseId: exercise.id,
      name: exercise.name,
      muscleGroup: exercise.muscleGroupName,
      order: order,
    );
  }
}

/// State for the workout builder
class WorkoutBuilderState {
  final String? workoutId;
  final String name;
  final String description;
  final String difficulty;
  final int estimatedDuration;
  final List<WorkoutBuilderExercise> exercises;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const WorkoutBuilderState({
    this.workoutId,
    this.name = '',
    this.description = '',
    this.difficulty = 'intermediate',
    this.estimatedDuration = 60,
    this.exercises = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  WorkoutBuilderState copyWith({
    String? workoutId,
    String? name,
    String? description,
    String? difficulty,
    int? estimatedDuration,
    List<WorkoutBuilderExercise>? exercises,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return WorkoutBuilderState(
      workoutId: workoutId ?? this.workoutId,
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      exercises: exercises ?? this.exercises,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }

  bool get isValid => name.trim().isNotEmpty && exercises.isNotEmpty;

  List<String> get muscleGroups =>
      exercises.map((e) => e.muscleGroup).toSet().toList();
}

/// Notifier for workout builder state
class WorkoutBuilderNotifier extends StateNotifier<WorkoutBuilderState> {
  final WorkoutService _workoutService;

  WorkoutBuilderNotifier(this._workoutService) : super(const WorkoutBuilderState());

  /// Initialize with existing workout ID (for editing)
  Future<void> loadWorkout(String workoutId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final data = await _workoutService.getWorkout(workoutId);
      final exercisesData = await _workoutService.getWorkoutExercises(workoutId);

      final exercises = exercisesData.asMap().entries.map((entry) {
        final e = entry.value;
        return WorkoutBuilderExercise(
          id: e['id'] as String? ?? entry.key.toString(),
          exerciseId: e['exercise_id'] as String? ?? '',
          name: e['exercise_name'] as String? ?? e['name'] as String? ?? 'Exercício',
          muscleGroup: e['muscle_group'] as String? ?? '',
          sets: e['sets'] as int? ?? 3,
          reps: '${e['reps'] ?? 10}',
          restSeconds: e['rest_seconds'] as int? ?? 60,
          notes: e['notes'] as String? ?? '',
          order: e['order_index'] as int? ?? entry.key,
        );
      }).toList();

      state = state.copyWith(
        workoutId: workoutId,
        name: data['name'] as String? ?? '',
        description: data['description'] as String? ?? '',
        difficulty: data['difficulty'] as String? ?? 'intermediate',
        estimatedDuration: data['estimated_duration'] as int? ?? 60,
        exercises: exercises,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar treino: $e',
      );
    }
  }

  /// Set workout name
  void setName(String name) {
    state = state.copyWith(name: name);
  }

  /// Set workout description
  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// Set difficulty
  void setDifficulty(String difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  /// Add exercise from catalog
  void addExercise(Exercise exercise) {
    final newExercise = WorkoutBuilderExercise.fromExercise(
      exercise,
      state.exercises.length,
    );

    state = state.copyWith(
      exercises: [...state.exercises, newExercise],
      estimatedDuration: _calculateDuration(state.exercises.length + 1),
    );
  }

  /// Update exercise
  void updateExercise(WorkoutBuilderExercise exercise) {
    final exercises = state.exercises.map((e) {
      if (e.id == exercise.id) return exercise;
      return e;
    }).toList();

    state = state.copyWith(exercises: exercises);
  }

  /// Remove exercise
  void removeExercise(String exerciseId) {
    final exercises = state.exercises.where((e) => e.id != exerciseId).toList();
    // Update order
    for (var i = 0; i < exercises.length; i++) {
      exercises[i] = exercises[i].copyWith(order: i);
    }
    state = state.copyWith(
      exercises: exercises,
      estimatedDuration: _calculateDuration(exercises.length),
    );
  }

  /// Reorder exercises
  void reorderExercises(int oldIndex, int newIndex) {
    final exercises = List<WorkoutBuilderExercise>.from(state.exercises);
    if (newIndex > oldIndex) newIndex--;
    final item = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, item);

    // Update order indices
    for (var i = 0; i < exercises.length; i++) {
      exercises[i] = exercises[i].copyWith(order: i);
    }

    state = state.copyWith(exercises: exercises);
  }

  /// Calculate estimated duration based on exercises
  int _calculateDuration(int exerciseCount) {
    // ~10 min per exercise average
    return (exerciseCount * 10).clamp(15, 120);
  }

  /// Save workout to API
  Future<String?> saveWorkout() async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'Nome e exercícios são obrigatórios');
      return null;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final exercisesData = state.exercises.map((e) => e.toJson()).toList();

      if (state.workoutId != null) {
        // Update existing workout
        await _workoutService.updateWorkout(
          state.workoutId!,
          name: state.name,
          description: state.description.isNotEmpty ? state.description : null,
          difficulty: state.difficulty,
          estimatedDuration: state.estimatedDuration,
          muscleGroups: state.muscleGroups,
        );

        state = state.copyWith(isSaving: false);
        return state.workoutId;
      } else {
        // Create new workout
        final result = await _workoutService.createWorkout(
          name: state.name,
          description: state.description.isNotEmpty ? state.description : null,
          difficulty: state.difficulty,
          estimatedDuration: state.estimatedDuration,
          muscleGroups: state.muscleGroups,
          exercises: exercisesData,
        );

        final workoutId = result['id'] as String;
        state = state.copyWith(workoutId: workoutId, isSaving: false);
        return workoutId;
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao salvar treino: $e',
      );
      return null;
    }
  }

  /// Reset state
  void reset() {
    state = const WorkoutBuilderState();
  }
}

/// Provider for workout builder
final workoutBuilderProvider =
    StateNotifierProvider<WorkoutBuilderNotifier, WorkoutBuilderState>((ref) {
  final workoutService = ref.read(workoutServiceProvider);
  return WorkoutBuilderNotifier(workoutService);
});
