import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/services/workout_service.dart';
import '../../../workout_builder/domain/models/exercise.dart';
import '../../domain/models/workout_program.dart';

part 'program_wizard_provider.freezed.dart';

/// Creation method for the program
enum CreationMethod {
  scratch,
  ai,
  template,
}

/// Wizard exercise configuration
@freezed
sealed class WizardExercise with _$WizardExercise {
  const factory WizardExercise({
    required String id,
    required String exerciseId,
    required String name,
    required String muscleGroup,
    @Default(3) int sets,
    @Default('10-12') String reps,
    @Default(60) int restSeconds,
    @Default('') String notes,
  }) = _WizardExercise;
}

/// Wizard workout configuration
@freezed
sealed class WizardWorkout with _$WizardWorkout {
  const factory WizardWorkout({
    required String id,
    required String label,
    required String name,
    @Default([]) List<String> muscleGroups,
    @Default([]) List<WizardExercise> exercises,
    @Default(0) int order,
    int? dayOfWeek,
  }) = _WizardWorkout;
}

/// Program wizard state
@freezed
sealed class ProgramWizardState with _$ProgramWizardState {
  const ProgramWizardState._();

  const factory ProgramWizardState({
    @Default(0) int currentStep,
    CreationMethod? method,
    @Default('') String programName,
    @Default(WorkoutGoal.hypertrophy) WorkoutGoal goal,
    @Default(ProgramDifficulty.intermediate) ProgramDifficulty difficulty,
    @Default(SplitType.abc) SplitType splitType,
    int? durationWeeks,
    @Default([]) List<WizardWorkout> workouts,
    @Default(false) bool isLoading,
    String? error,
    @Default(false) bool isTemplate,
    String? templateId,
    String? studentId,
    String? editingProgramId,
  }) = _ProgramWizardState;

  /// Check if we're in edit mode
  bool get isEditing => editingProgramId != null;

  /// Check if current step is valid
  bool get isCurrentStepValid {
    switch (currentStep) {
      case 0:
        return method != null;
      case 1:
        return programName.isNotEmpty;
      case 2:
        return true; // Split is always selected with default
      case 3:
        return workouts.isNotEmpty &&
            workouts.every((w) => w.exercises.isNotEmpty);
      case 4:
        return true; // Review step
      default:
        return false;
    }
  }

  /// Total step count
  int get totalSteps => 5;

  /// Check if we're on the last step
  bool get isLastStep => currentStep == totalSteps - 1;

  /// Get total exercise count across all workouts
  int get totalExerciseCount {
    return workouts.fold<int>(0, (sum, w) => sum + w.exercises.length);
  }

  /// Get estimated total duration
  int get estimatedTotalMinutes {
    return workouts.fold<int>(0, (sum, w) {
      final exerciseDuration = w.exercises.fold<int>(0, (es, e) {
        return es + (e.sets * 45) + (e.sets * e.restSeconds);
      });
      return sum + (exerciseDuration ~/ 60);
    });
  }
}

/// Program wizard notifier
class ProgramWizardNotifier extends StateNotifier<ProgramWizardState> {
  ProgramWizardNotifier() : super(const ProgramWizardState());

  // Step navigation
  void nextStep() {
    if (state.currentStep < state.totalSteps - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < state.totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  // Step 1: Method selection
  void selectMethod(CreationMethod method) {
    state = state.copyWith(method: method);
  }

  // Step 2: Program info
  void setProgramName(String name) {
    state = state.copyWith(programName: name);
  }

  void setGoal(WorkoutGoal goal) {
    state = state.copyWith(goal: goal);
  }

  void setDifficulty(ProgramDifficulty difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  void setDurationWeeks(int? weeks) {
    state = state.copyWith(durationWeeks: weeks);
  }

  void setIsTemplate(bool isTemplate) {
    state = state.copyWith(isTemplate: isTemplate);
  }

  void setStudentId(String? studentId) {
    state = state.copyWith(studentId: studentId);
  }

  /// Load data from a template to clone
  void loadFromTemplate(Map<String, dynamic> template) {
    try {
      // Parse template data
      final name = '${template['name'] ?? 'Programa'} (Copia)';
      final goalStr = template['goal'] as String? ?? 'hypertrophy';
      final difficultyStr = template['difficulty'] as String? ?? 'intermediate';
      final splitTypeStr = template['split_type'] as String? ?? 'abc';
      final durationWeeks = template['duration_weeks'] as int?;
      final programWorkouts = (template['program_workouts'] as List<dynamic>?) ?? [];

      if (programWorkouts.isEmpty) {
        state = state.copyWith(error: 'Template sem treinos definidos');
        return;
      }

      // Convert to wizard workouts
      final workouts = <WizardWorkout>[];
      for (final pw in programWorkouts) {
        final pwMap = pw as Map<String, dynamic>;
        final label = pwMap['label'] as String? ?? 'A';
        final workout = pwMap['workout'] as Map<String, dynamic>?;
        final workoutName = workout?['name'] as String? ?? 'Treino $label';
        final exercises = (workout?['exercises'] as List<dynamic>?) ?? [];

        final wizardExercises = <WizardExercise>[];
        for (final ex in exercises) {
          final exMap = ex as Map<String, dynamic>;
          final exerciseData = exMap['exercise'] as Map<String, dynamic>?;

          // Get exercise_id - could be UUID string or direct id
          String exerciseId = '';
          if (exMap['exercise_id'] != null) {
            exerciseId = exMap['exercise_id'].toString();
          }

          wizardExercises.add(WizardExercise(
            id: '${DateTime.now().millisecondsSinceEpoch}_${exerciseId.hashCode}',
            exerciseId: exerciseId,
            name: exerciseData?['name'] as String? ?? 'Exercicio',
            muscleGroup: exerciseData?['muscle_group'] as String? ?? '',
            sets: exMap['sets'] as int? ?? 3,
            reps: (exMap['reps'] ?? '10-12').toString(),
            restSeconds: exMap['rest_seconds'] as int? ?? 60,
            notes: exMap['notes'] as String? ?? '',
          ));
        }

        workouts.add(WizardWorkout(
          id: label,
          label: label,
          name: workoutName,
          order: pwMap['order'] as int? ?? workouts.length,
          exercises: wizardExercises,
          muscleGroups: (workout?['target_muscles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
        ));
      }

      state = state.copyWith(
        templateId: template['id']?.toString(),
        programName: name,
        goal: goalStr.toWorkoutGoal(),
        difficulty: difficultyStr.toProgramDifficulty(),
        splitType: splitTypeStr.toSplitType(),
        durationWeeks: durationWeeks,
        workouts: workouts,
        currentStep: 1, // Go to step 1 (program info) after loading template
        method: CreationMethod.template,
        isTemplate: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao processar template: $e');
    }
  }

  /// Load data from AI-generated program
  void loadFromAIGenerated(Map<String, dynamic> aiData) {
    try {
      final name = aiData['name'] as String? ?? 'Programa IA';
      final description = aiData['description'] as String?;
      final goalStr = aiData['goal'] as String? ?? 'hypertrophy';
      final difficultyStr = aiData['difficulty'] as String? ?? 'intermediate';
      final splitTypeStr = aiData['split_type'] as String? ?? 'abc';
      final durationWeeks = aiData['duration_weeks'] as int?;
      final aiWorkouts = (aiData['workouts'] as List<dynamic>?) ?? [];

      // Convert AI workouts to wizard workouts
      final workouts = <WizardWorkout>[];
      for (final w in aiWorkouts) {
        final wMap = w as Map<String, dynamic>;
        final label = wMap['label'] as String? ?? String.fromCharCode(65 + workouts.length);
        final workoutName = wMap['name'] as String? ?? 'Treino $label';
        final exercises = (wMap['exercises'] as List<dynamic>?) ?? [];

        final wizardExercises = <WizardExercise>[];
        for (final ex in exercises) {
          final exMap = ex as Map<String, dynamic>;
          final exerciseId = exMap['exercise_id']?.toString() ?? '';

          wizardExercises.add(WizardExercise(
            id: '${DateTime.now().millisecondsSinceEpoch}_${exerciseId.hashCode}',
            exerciseId: exerciseId,
            name: exMap['name'] as String? ?? 'Exercicio',
            muscleGroup: (exMap['muscle_group'] as String? ?? '').toString(),
            sets: exMap['sets'] as int? ?? 3,
            reps: (exMap['reps'] ?? '10-12').toString(),
            restSeconds: exMap['rest_seconds'] as int? ?? 60,
            notes: exMap['reason'] as String? ?? '',
          ));
        }

        workouts.add(WizardWorkout(
          id: label,
          label: label,
          name: workoutName,
          order: wMap['order'] as int? ?? workouts.length,
          exercises: wizardExercises,
          muscleGroups: [],
        ));
      }

      state = state.copyWith(
        programName: name,
        goal: goalStr.toWorkoutGoal(),
        difficulty: difficultyStr.toProgramDifficulty(),
        splitType: splitTypeStr.toSplitType(),
        durationWeeks: durationWeeks,
        workouts: workouts,
        method: CreationMethod.ai,
        isTemplate: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao processar programa IA: $e');
    }
  }

  /// Load program data for editing
  Future<void> loadProgramForEdit(String programId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final workoutService = WorkoutService();
      final program = await workoutService.getProgram(programId);

      // Parse program data
      final name = program['name'] as String? ?? '';
      final goalStr = program['goal'] as String? ?? 'hypertrophy';
      final difficultyStr = program['difficulty'] as String? ?? 'intermediate';
      final splitTypeStr = program['split_type'] as String? ?? 'abc';
      final durationWeeks = program['duration_weeks'] as int?;
      final isTemplate = program['is_template'] as bool? ?? false;
      final programWorkouts = (program['program_workouts'] as List<dynamic>?) ?? [];

      // Convert to wizard workouts
      final workouts = programWorkouts.map((pw) {
        final pwMap = pw as Map<String, dynamic>;
        final label = pwMap['label'] as String? ?? '';
        final workout = pwMap['workout'] as Map<String, dynamic>?;
        final workoutName = workout?['name'] as String? ?? 'Treino $label';
        final exercises = (workout?['exercises'] as List<dynamic>?) ?? [];

        final wizardExercises = exercises.map((ex) {
          final exMap = ex as Map<String, dynamic>;
          final exerciseData = exMap['exercise'] as Map<String, dynamic>?;
          return WizardExercise(
            id: exMap['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
            exerciseId: exMap['exercise_id'] as String? ?? '',
            name: exerciseData?['name'] as String? ?? '',
            muscleGroup: exerciseData?['muscle_group'] as String? ?? '',
            sets: exMap['sets'] as int? ?? 3,
            reps: exMap['reps'] as String? ?? '10-12',
            restSeconds: exMap['rest_seconds'] as int? ?? 60,
            notes: exMap['notes'] as String? ?? '',
          );
        }).toList();

        return WizardWorkout(
          id: label,
          label: label,
          name: workoutName,
          order: pwMap['order'] as int? ?? 0,
          exercises: wizardExercises,
          muscleGroups: (workout?['target_muscles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
        );
      }).toList();

      state = state.copyWith(
        editingProgramId: programId,
        programName: name,
        goal: goalStr.toWorkoutGoal(),
        difficulty: difficultyStr.toProgramDifficulty(),
        splitType: splitTypeStr.toSplitType(),
        durationWeeks: durationWeeks,
        isTemplate: isTemplate,
        workouts: workouts,
        method: CreationMethod.scratch,
        currentStep: 1, // Skip method selection in edit mode
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Step 3: Split selection
  void selectSplit(SplitType splitType) {
    state = state.copyWith(splitType: splitType);
    _generateWorkoutStructure();
  }

  void _generateWorkoutStructure() {
    final workouts = <WizardWorkout>[];

    switch (state.splitType) {
      case SplitType.abc:
        workouts.addAll([
          WizardWorkout(
              id: 'A', label: 'A', name: 'Treino A', order: 0, muscleGroups: []),
          WizardWorkout(
              id: 'B', label: 'B', name: 'Treino B', order: 1, muscleGroups: []),
          WizardWorkout(
              id: 'C', label: 'C', name: 'Treino C', order: 2, muscleGroups: []),
        ]);
        break;
      case SplitType.abcd:
        workouts.addAll([
          WizardWorkout(
              id: 'A', label: 'A', name: 'Treino A', order: 0, muscleGroups: []),
          WizardWorkout(
              id: 'B', label: 'B', name: 'Treino B', order: 1, muscleGroups: []),
          WizardWorkout(
              id: 'C', label: 'C', name: 'Treino C', order: 2, muscleGroups: []),
          WizardWorkout(
              id: 'D', label: 'D', name: 'Treino D', order: 3, muscleGroups: []),
        ]);
        break;
      case SplitType.abcde:
        workouts.addAll([
          WizardWorkout(
              id: 'A', label: 'A', name: 'Treino A', order: 0, muscleGroups: []),
          WizardWorkout(
              id: 'B', label: 'B', name: 'Treino B', order: 1, muscleGroups: []),
          WizardWorkout(
              id: 'C', label: 'C', name: 'Treino C', order: 2, muscleGroups: []),
          WizardWorkout(
              id: 'D', label: 'D', name: 'Treino D', order: 3, muscleGroups: []),
          WizardWorkout(
              id: 'E', label: 'E', name: 'Treino E', order: 4, muscleGroups: []),
        ]);
        break;
      case SplitType.pushPullLegs:
        workouts.addAll([
          WizardWorkout(
              id: 'Push',
              label: 'Push',
              name: 'Push (Empurrar)',
              order: 0,
              muscleGroups: ['chest', 'shoulders', 'triceps']),
          WizardWorkout(
              id: 'Pull',
              label: 'Pull',
              name: 'Pull (Puxar)',
              order: 1,
              muscleGroups: ['back', 'biceps']),
          WizardWorkout(
              id: 'Legs',
              label: 'Legs',
              name: 'Legs (Pernas)',
              order: 2,
              muscleGroups: ['legs', 'glutes']),
        ]);
        break;
      case SplitType.upperLower:
        workouts.addAll([
          WizardWorkout(
              id: 'Upper',
              label: 'Upper',
              name: 'Upper (Superior)',
              order: 0,
              muscleGroups: ['chest', 'back', 'shoulders', 'biceps', 'triceps']),
          WizardWorkout(
              id: 'Lower',
              label: 'Lower',
              name: 'Lower (Inferior)',
              order: 1,
              muscleGroups: ['legs', 'glutes']),
        ]);
        break;
      case SplitType.fullBody:
        workouts.addAll([
          WizardWorkout(
              id: 'Full',
              label: 'Full',
              name: 'Full Body (Corpo Inteiro)',
              order: 0,
              muscleGroups: [
                'chest',
                'back',
                'shoulders',
                'legs',
                'biceps',
                'triceps'
              ]),
        ]);
        break;
      case SplitType.custom:
        // Start with empty for custom
        break;
    }

    state = state.copyWith(workouts: workouts);
  }

  // Step 4: Workout configuration
  void addWorkout() {
    final label = String.fromCharCode(65 + state.workouts.length); // A, B, C...
    final workout = WizardWorkout(
      id: label,
      label: label,
      name: 'Treino $label',
      order: state.workouts.length,
      muscleGroups: [],
    );
    state = state.copyWith(workouts: [...state.workouts, workout]);
  }

  void removeWorkout(String workoutId) {
    final workouts =
        state.workouts.where((w) => w.id != workoutId).toList();
    // Reorder remaining workouts
    for (var i = 0; i < workouts.length; i++) {
      workouts[i] = workouts[i].copyWith(order: i);
    }
    state = state.copyWith(workouts: workouts);
  }

  void updateWorkoutName(String workoutId, String name) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        return w.copyWith(name: name);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Alias for updateWorkoutName - used by UI for clarity
  void renameWorkout(String workoutId, String newName) {
    updateWorkoutName(workoutId, newName);
  }

  /// Update workout label (A, B, C, etc.)
  void updateWorkoutLabel(String workoutId, String newLabel) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        return w.copyWith(label: newLabel);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Update workout completely (label, name, muscle groups)
  void updateWorkout({
    required String workoutId,
    String? label,
    String? name,
    List<String>? muscleGroups,
  }) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        return w.copyWith(
          label: label ?? w.label,
          name: name ?? w.name,
          muscleGroups: muscleGroups ?? w.muscleGroups,
        );
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Update workout and remove exercises that don't match the new muscle groups
  void updateWorkoutWithExerciseCleanup({
    required String workoutId,
    String? label,
    String? name,
    required List<String> muscleGroups,
  }) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        // Filter exercises to keep only those matching allowed muscle groups
        final filteredExercises = muscleGroups.isEmpty
            ? w.exercises // If no groups defined, keep all exercises
            : w.exercises.where((e) {
                final exerciseMuscle = e.muscleGroup.toLowerCase();
                return muscleGroups.any((g) {
                  final groupLower = g.toLowerCase();
                  final groupDisplayName = g.toMuscleGroup().displayName.toLowerCase();
                  return groupLower == exerciseMuscle ||
                      groupDisplayName == exerciseMuscle;
                });
              }).toList();

        return w.copyWith(
          label: label ?? w.label,
          name: name ?? w.name,
          muscleGroups: muscleGroups,
          exercises: filteredExercises,
        );
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Get exercises that would be removed if muscle groups change
  List<WizardExercise> getExercisesToRemove(String workoutId, List<String> newMuscleGroups) {
    final workout = state.workouts.firstWhere(
      (w) => w.id == workoutId,
      orElse: () => const WizardWorkout(id: '', label: '', name: ''),
    );

    if (newMuscleGroups.isEmpty) return []; // No restriction, keep all

    return workout.exercises.where((e) {
      final exerciseMuscle = e.muscleGroup.toLowerCase();
      return !newMuscleGroups.any((g) {
        final groupLower = g.toLowerCase();
        final groupDisplayName = g.toMuscleGroup().displayName.toLowerCase();
        return groupLower == exerciseMuscle || groupDisplayName == exerciseMuscle;
      });
    }).toList();
  }

  void setWorkoutMuscleGroups(String workoutId, List<String> groups) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        return w.copyWith(muscleGroups: groups);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  void addExerciseToWorkout(String workoutId, Exercise exercise) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        final wizardExercise = WizardExercise(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          exerciseId: exercise.id,
          name: exercise.name,
          muscleGroup: exercise.muscleGroupName,
        );
        return w.copyWith(exercises: [...w.exercises, wizardExercise]);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  void removeExerciseFromWorkout(String workoutId, String exerciseId) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        final exercises = w.exercises.where((e) => e.id != exerciseId).toList();
        return w.copyWith(exercises: exercises);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  void updateExercise(
      String workoutId, String exerciseId, WizardExercise updated) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        final exercises = w.exercises.map((e) {
          if (e.id == exerciseId) {
            return updated;
          }
          return e;
        }).toList();
        return w.copyWith(exercises: exercises);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  void reorderExercises(String workoutId, int oldIndex, int newIndex) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        final exercises = List<WizardExercise>.from(w.exercises);
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final item = exercises.removeAt(oldIndex);
        exercises.insert(newIndex, item);
        return w.copyWith(exercises: exercises);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Copy an exercise from one workout to another
  void copyExerciseToWorkout(String fromWorkoutId, String exerciseId, String toWorkoutId) {
    // Find the exercise to copy
    WizardExercise? exerciseToCopy;
    for (final w in state.workouts) {
      if (w.id == fromWorkoutId) {
        for (final e in w.exercises) {
          if (e.id == exerciseId) {
            exerciseToCopy = e;
            break;
          }
        }
        break;
      }
    }

    if (exerciseToCopy == null) return;

    // Create a copy with a new ID
    final copiedExercise = exerciseToCopy.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    // Add to target workout
    final workouts = state.workouts.map((w) {
      if (w.id == toWorkoutId) {
        return w.copyWith(exercises: [...w.exercises, copiedExercise]);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  // AI Integration
  /// Returns a map with 'success' (bool), 'message' (String), and 'count' (int)
  Future<Map<String, dynamic>> suggestExercisesForWorkout(String workoutId) async {
    final workout = state.workouts.firstWhere((w) => w.id == workoutId);

    if (workout.muscleGroups.isEmpty) {
      return {
        'success': false,
        'message': 'Selecione pelo menos um grupo muscular antes de sugerir exercicios',
        'count': 0,
      };
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final workoutService = WorkoutService();

      // Get existing exercise IDs to exclude
      final existingIds = workout.exercises.map((e) => e.exerciseId).toList();

      // Call the API to get suggestions
      final response = await workoutService.suggestExercises(
        muscleGroups: workout.muscleGroups,
        goal: state.goal.toApiValue(),
        difficulty: state.difficulty.toApiValue(),
        count: 6,
        excludeExerciseIds: existingIds.isNotEmpty ? existingIds : null,
      );

      final suggestions = (response['suggestions'] as List<dynamic>?) ?? [];
      final apiMessage = response['message'] as String?;

      if (suggestions.isEmpty) {
        state = state.copyWith(isLoading: false);
        return {
          'success': false,
          'message': apiMessage ?? 'Nenhum exercicio encontrado. Execute o seed de exercicios no backend.',
          'count': 0,
        };
      }

      final workouts = state.workouts.map((w) {
        if (w.id == workoutId) {
          final wizardExercises = suggestions.map((s) {
            final sMap = s as Map<String, dynamic>;
            return WizardExercise(
              id: DateTime.now().millisecondsSinceEpoch.toString() + (sMap['exercise_id'] as String? ?? ''),
              exerciseId: sMap['exercise_id'] as String? ?? '',
              name: sMap['name'] as String? ?? '',
              muscleGroup: sMap['muscle_group'] as String? ?? '',
              sets: sMap['sets'] as int? ?? 3,
              reps: sMap['reps'] as String? ?? '10-12',
              restSeconds: sMap['rest_seconds'] as int? ?? 60,
            );
          }).toList();
          return w.copyWith(exercises: [...w.exercises, ...wizardExercises]);
        }
        return w;
      }).toList();

      state = state.copyWith(workouts: workouts, isLoading: false);
      return {
        'success': true,
        'message': apiMessage ?? '${suggestions.length} exercicios sugeridos!',
        'count': suggestions.length,
      };
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {
        'success': false,
        'message': 'Erro ao sugerir exercicios: ${e.toString()}',
        'count': 0,
      };
    }
  }

  // Step 5: Create or update program
  Future<String?> createProgram() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final workoutService = WorkoutService();

      final workoutsData = state.workouts.map((w) {
        return {
          'label': w.label,
          'workout_name': w.name,
          'order': w.order,
          'workout_exercises': w.exercises.map((e) {
            return {
              'exercise_id': e.exerciseId,
              'sets': e.sets,
              'reps': e.reps,
              'rest_seconds': e.restSeconds,
              'notes': e.notes,
            };
          }).toList(),
        };
      }).toList();

      String? programId;

      if (state.isEditing) {
        // Update existing program metadata
        // Note: Workout structure updates require separate API calls
        await workoutService.updateProgram(
          state.editingProgramId!,
          name: state.programName,
          goal: state.goal.toApiValue(),
          difficulty: state.difficulty.toApiValue(),
          splitType: state.splitType.toApiValue(),
          durationWeeks: state.durationWeeks,
          isTemplate: state.isTemplate,
        );
        programId = state.editingProgramId;
      } else {
        // Create new program
        programId = await workoutService.createProgram(
          name: state.programName,
          goal: state.goal.toApiValue(),
          difficulty: state.difficulty.toApiValue(),
          splitType: state.splitType.toApiValue(),
          durationWeeks: state.durationWeeks,
          isTemplate: state.isTemplate,
          workouts: workoutsData,
        );
      }

      // Auto-assign to student if studentId is present
      if (programId != null && state.studentId != null) {
        await workoutService.createProgramAssignment(
          programId: programId,
          studentId: state.studentId!,
        );
      }

      state = state.copyWith(isLoading: false);
      return programId;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Reset
  void reset() {
    state = const ProgramWizardState();
  }
}

/// Provider for program wizard
final programWizardProvider =
    StateNotifierProvider.autoDispose<ProgramWizardNotifier, ProgramWizardState>(
  (ref) => ProgramWizardNotifier(),
);
