import 'package:myfit_app/features/workout_program/domain/models/workout_program.dart';
import 'package:myfit_app/features/workout_program/presentation/providers/program_wizard_provider.dart';
import 'package:myfit_app/features/workout_builder/domain/models/exercise.dart';

/// Fixtures for exercise group and technique-related test data.
///
/// This class provides test data for:
/// - Single exercises with techniques (dropset, rest-pause, cluster)
/// - Exercise groups (superset, triset, giantset)
/// - Full workouts with mixed techniques
class ExerciseGroupFixtures {
  // ============================================
  // BASIC EXERCISES (from catalog)
  // ============================================

  /// Creates a basic exercise from the catalog.
  static Exercise catalogExercise({
    String id = 'exercise-1',
    String name = 'Supino Reto',
    MuscleGroup muscleGroup = MuscleGroup.chest,
  }) {
    return Exercise(
      id: id,
      name: name,
      muscleGroup: muscleGroup,
      description: 'Descricao do exercicio $name',
      instructions: 'Instrucoes para executar $name',
    );
  }

  /// Creates a list of common exercises for testing.
  static List<Exercise> commonExercises() {
    return [
      catalogExercise(id: 'ex-1', name: 'Supino Reto', muscleGroup: MuscleGroup.chest),
      catalogExercise(id: 'ex-2', name: 'Supino Inclinado', muscleGroup: MuscleGroup.chest),
      catalogExercise(id: 'ex-3', name: 'Crucifixo', muscleGroup: MuscleGroup.chest),
      catalogExercise(id: 'ex-4', name: 'Puxada Frontal', muscleGroup: MuscleGroup.back),
      catalogExercise(id: 'ex-5', name: 'Remada Curvada', muscleGroup: MuscleGroup.back),
      catalogExercise(id: 'ex-6', name: 'Rosca Direta', muscleGroup: MuscleGroup.biceps),
      catalogExercise(id: 'ex-7', name: 'Triceps Pulley', muscleGroup: MuscleGroup.triceps),
      catalogExercise(id: 'ex-8', name: 'Agachamento', muscleGroup: MuscleGroup.legs),
    ];
  }

  // ============================================
  // NORMAL EXERCISES (WizardExercise)
  // ============================================

  /// Creates a normal exercise without any technique.
  static WizardExercise normalExercise({
    String id = 'wizard-ex-1',
    String exerciseId = 'exercise-1',
    String name = 'Supino Reto',
    String muscleGroup = 'chest',
    int sets = 3,
    String reps = '10-12',
    int restSeconds = 60,
    int? isometricSeconds,
    String executionInstructions = '',
  }) {
    return WizardExercise(
      id: id,
      exerciseId: exerciseId,
      name: name,
      muscleGroup: muscleGroup,
      sets: sets,
      reps: reps,
      restSeconds: restSeconds,
      isometricSeconds: isometricSeconds,
      executionInstructions: executionInstructions,
      techniqueType: TechniqueType.normal,
    );
  }

  // ============================================
  // SINGLE-EXERCISE TECHNIQUES
  // ============================================

  /// Creates a dropset exercise.
  static WizardExercise dropsetExercise({
    String id = 'wizard-dropset-1',
    String exerciseId = 'exercise-dropset',
    String name = 'Extensora',
    String muscleGroup = 'legs',
    int sets = 3,
    String reps = '10',
    int restSeconds = 90,
  }) {
    return WizardExercise(
      id: id,
      exerciseId: exerciseId,
      name: name,
      muscleGroup: muscleGroup,
      sets: sets,
      reps: reps,
      restSeconds: restSeconds,
      techniqueType: TechniqueType.dropset,
      executionInstructions: 'Execute 3 reducoes de carga sem descanso',
    );
  }

  /// Creates a rest-pause exercise.
  static WizardExercise restPauseExercise({
    String id = 'wizard-restpause-1',
    String exerciseId = 'exercise-restpause',
    String name = 'Leg Press',
    String muscleGroup = 'legs',
    int sets = 3,
    String reps = '8',
    int restSeconds = 120,
  }) {
    return WizardExercise(
      id: id,
      exerciseId: exerciseId,
      name: name,
      muscleGroup: muscleGroup,
      sets: sets,
      reps: reps,
      restSeconds: restSeconds,
      techniqueType: TechniqueType.restPause,
      executionInstructions: 'Execute ate a falha, pause 15s, continue',
    );
  }

  /// Creates a cluster exercise.
  static WizardExercise clusterExercise({
    String id = 'wizard-cluster-1',
    String exerciseId = 'exercise-cluster',
    String name = 'Remada Curvada',
    String muscleGroup = 'back',
    int sets = 4,
    String reps = '5',
    int restSeconds = 120,
  }) {
    return WizardExercise(
      id: id,
      exerciseId: exerciseId,
      name: name,
      muscleGroup: muscleGroup,
      sets: sets,
      reps: reps,
      restSeconds: restSeconds,
      techniqueType: TechniqueType.cluster,
      executionInstructions: 'Execute 4 mini-sets com 10s entre cada',
    );
  }

  // ============================================
  // EXERCISE GROUPS (SUPERSET, TRISET, GIANTSET)
  // ============================================

  /// Creates a superset (2 exercises).
  static List<WizardExercise> superset({
    String groupId = 'superset-1',
    List<String>? ids,
    List<String>? exerciseIds,
    List<String>? names,
    int sets = 3,
    String reps = '10-12',
    int finalRestSeconds = 60,
  }) {
    final wizardIds = ids ?? ['wizard-superset-1', 'wizard-superset-2'];
    final exIds = exerciseIds ?? ['ex-superset-1', 'ex-superset-2'];
    final exNames = names ?? ['Supino Reto', 'Puxada Frontal'];

    return [
      WizardExercise(
        id: wizardIds[0],
        exerciseId: exIds[0],
        name: exNames[0],
        muscleGroup: 'chest',
        sets: sets,
        reps: reps,
        restSeconds: 0, // No rest between group exercises
        techniqueType: TechniqueType.superset,
        exerciseGroupId: groupId,
        exerciseGroupOrder: 0,
        executionInstructions: 'Sem descanso entre os exercicios',
      ),
      WizardExercise(
        id: wizardIds[1],
        exerciseId: exIds[1],
        name: exNames[1],
        muscleGroup: 'back',
        sets: sets,
        reps: reps,
        restSeconds: finalRestSeconds, // Rest after last exercise
        techniqueType: TechniqueType.superset,
        exerciseGroupId: groupId,
        exerciseGroupOrder: 1,
        executionInstructions: 'Sem descanso entre os exercicios',
      ),
    ];
  }

  /// Creates a triset (3 exercises).
  static List<WizardExercise> triset({
    String groupId = 'triset-1',
    List<String>? ids,
    List<String>? exerciseIds,
    List<String>? names,
    int sets = 3,
    String reps = '12',
    int finalRestSeconds = 90,
  }) {
    final wizardIds = ids ?? ['wizard-triset-1', 'wizard-triset-2', 'wizard-triset-3'];
    final exIds = exerciseIds ?? ['ex-triset-1', 'ex-triset-2', 'ex-triset-3'];
    final exNames = names ?? ['Supino Inclinado', 'Crucifixo', 'Peck Deck'];

    return List.generate(3, (index) {
      return WizardExercise(
        id: wizardIds[index],
        exerciseId: exIds[index],
        name: exNames[index],
        muscleGroup: 'chest',
        sets: sets,
        reps: reps,
        restSeconds: index == 2 ? finalRestSeconds : 0,
        techniqueType: TechniqueType.triset,
        exerciseGroupId: groupId,
        exerciseGroupOrder: index,
        executionInstructions: 'Sem descanso entre os exercicios',
      );
    });
  }

  /// Creates a giantset (4+ exercises).
  static List<WizardExercise> giantset({
    String groupId = 'giantset-1',
    int count = 4,
    List<String>? ids,
    List<String>? exerciseIds,
    List<String>? names,
    int sets = 3,
    String reps = '15',
    int finalRestSeconds = 120,
  }) {
    final wizardIds = ids ?? List.generate(count, (i) => 'wizard-giantset-$i');
    final exIds = exerciseIds ?? List.generate(count, (i) => 'ex-giantset-$i');
    final defaultNames = ['Agachamento', 'Leg Press', 'Extensora', 'Flexora',
                          'Panturrilha', 'Avanco', 'Stiff', 'Cadeira Abdutora'];
    final exNames = names ?? defaultNames;

    return List.generate(count, (index) {
      return WizardExercise(
        id: wizardIds[index],
        exerciseId: exIds[index],
        name: exNames[index % exNames.length],
        muscleGroup: 'legs',
        sets: sets,
        reps: reps,
        restSeconds: index == count - 1 ? finalRestSeconds : 0,
        techniqueType: TechniqueType.giantset,
        exerciseGroupId: groupId,
        exerciseGroupOrder: index,
        executionInstructions: 'Execucao continua - sem descanso',
      );
    });
  }

  // ============================================
  // COMPLETE WORKOUTS
  // ============================================

  /// Creates a workout with mixed techniques.
  static WizardWorkout workoutWithMixedTechniques({
    String id = 'workout-mixed',
    String name = 'Treino Avancado',
    String label = 'A',
  }) {
    return WizardWorkout(
      id: id,
      name: name,
      label: label,
      exercises: [
        // Normal exercise
        normalExercise(
          id: 'wizard-1',
          exerciseId: 'ex-1',
          name: 'Aquecimento',
          sets: 2,
          reps: '15',
        ),
        // Superset
        ...superset(
          groupId: 'superset-workout-1',
          ids: ['wizard-2', 'wizard-3'],
          exerciseIds: ['ex-2', 'ex-3'],
          names: ['Supino Reto', 'Puxada Frontal'],
        ),
        // Dropset
        dropsetExercise(
          id: 'wizard-4',
          exerciseId: 'ex-4',
          name: 'Extensora',
        ),
        // Another normal exercise
        normalExercise(
          id: 'wizard-5',
          exerciseId: 'ex-5',
          name: 'Rosca Direta',
        ),
        // Triset
        ...triset(
          groupId: 'triset-workout-1',
          ids: ['wizard-6', 'wizard-7', 'wizard-8'],
          exerciseIds: ['ex-6', 'ex-7', 'ex-8'],
          names: ['Elevacao Frontal', 'Elevacao Lateral', 'Crucifixo Invertido'],
        ),
      ],
    );
  }

  /// Creates a workout with multiple supersets.
  static WizardWorkout workoutWithMultipleSupersets({
    String id = 'workout-supersets',
    String name = 'Treino Supersets',
    String label = 'B',
  }) {
    return WizardWorkout(
      id: id,
      name: name,
      label: label,
      exercises: [
        ...superset(
          groupId: 'superset-1',
          ids: ['wizard-1', 'wizard-2'],
          exerciseIds: ['ex-1', 'ex-2'],
          names: ['Supino Reto', 'Remada Curvada'],
        ),
        ...superset(
          groupId: 'superset-2',
          ids: ['wizard-3', 'wizard-4'],
          exerciseIds: ['ex-3', 'ex-4'],
          names: ['Desenvolvimento', 'Elevacao Lateral'],
        ),
        ...superset(
          groupId: 'superset-3',
          ids: ['wizard-5', 'wizard-6'],
          exerciseIds: ['ex-5', 'ex-6'],
          names: ['Rosca Direta', 'Triceps Pulley'],
        ),
      ],
    );
  }

  /// Creates a workout with all technique types.
  static WizardWorkout workoutWithAllTechniques({
    String id = 'workout-all',
    String name = 'Treino Completo',
    String label = 'C',
  }) {
    return WizardWorkout(
      id: id,
      name: name,
      label: label,
      exercises: [
        // Normal
        normalExercise(id: 'wizard-normal', exerciseId: 'ex-normal', name: 'Agachamento'),
        // Superset
        ...superset(groupId: 'superset-all', ids: ['wizard-ss-1', 'wizard-ss-2']),
        // Triset
        ...triset(groupId: 'triset-all', ids: ['wizard-ts-1', 'wizard-ts-2', 'wizard-ts-3']),
        // Giantset
        ...giantset(groupId: 'giantset-all', count: 4,
                   ids: ['wizard-gs-1', 'wizard-gs-2', 'wizard-gs-3', 'wizard-gs-4']),
        // Dropset
        dropsetExercise(id: 'wizard-dropset', exerciseId: 'ex-dropset'),
        // Rest-Pause
        restPauseExercise(id: 'wizard-restpause', exerciseId: 'ex-restpause'),
        // Cluster
        clusterExercise(id: 'wizard-cluster', exerciseId: 'ex-cluster'),
      ],
    );
  }

  // ============================================
  // API RESPONSE FIXTURES
  // ============================================

  /// Creates an exercise API response.
  static Map<String, dynamic> exerciseApiResponse({
    String id = 'exercise-1',
    String name = 'Supino Reto',
    String muscleGroup = 'chest',
    TechniqueType techniqueType = TechniqueType.normal,
    int sets = 3,
    String reps = '10-12',
    int restSeconds = 60,
    String? groupId,
    int? groupOrder,
  }) {
    return {
      'id': id,
      'exercise_id': id,
      'name': name,
      'exercise_name': name,
      'muscle_group': muscleGroup,
      'technique_type': techniqueType.name,
      'sets': sets,
      'reps': reps,
      'rest_seconds': restSeconds,
      if (groupId != null) 'exercise_group_id': groupId,
      if (groupOrder != null) 'exercise_group_order': groupOrder,
    };
  }

  /// Creates a superset API response.
  static List<Map<String, dynamic>> supersetApiResponse({
    String groupId = 'superset-1',
    List<String>? exerciseIds,
    List<String>? names,
  }) {
    final ids = exerciseIds ?? ['ex-1', 'ex-2'];
    final exNames = names ?? ['Supino Reto', 'Puxada Frontal'];

    return [
      exerciseApiResponse(
        id: ids[0],
        name: exNames[0],
        techniqueType: TechniqueType.superset,
        groupId: groupId,
        groupOrder: 0,
        restSeconds: 0,
      ),
      exerciseApiResponse(
        id: ids[1],
        name: exNames[1],
        techniqueType: TechniqueType.superset,
        groupId: groupId,
        groupOrder: 1,
        restSeconds: 60,
      ),
    ];
  }

  /// Creates a workout API response with exercise groups.
  static Map<String, dynamic> workoutWithGroupsApiResponse({
    String id = 'workout-1',
    String name = 'Treino A',
    String label = 'A',
  }) {
    return {
      'id': id,
      'name': name,
      'label': label,
      'day_of_week': 1,
      'exercises': [
        exerciseApiResponse(id: 'ex-1', name: 'Aquecimento'),
        ...supersetApiResponse(groupId: 'superset-1'),
        exerciseApiResponse(
          id: 'ex-dropset',
          name: 'Extensora',
          techniqueType: TechniqueType.dropset,
        ),
      ],
    };
  }

  // ============================================
  // EDGE CASE FIXTURES
  // ============================================

  /// Creates a group with only 1 exercise (should auto-disband).
  static List<WizardExercise> singleExerciseGroup({
    String groupId = 'single-group',
    String id = 'wizard-single',
    String exerciseId = 'ex-single',
    String name = 'Exercicio Solo',
  }) {
    return [
      WizardExercise(
        id: id,
        exerciseId: exerciseId,
        name: name,
        muscleGroup: 'chest',
        sets: 3,
        reps: '10',
        restSeconds: 60,
        techniqueType: TechniqueType.superset, // Will be changed to normal
        exerciseGroupId: groupId,
        exerciseGroupOrder: 0,
      ),
    ];
  }

  /// Creates a maximum size giantset (8 exercises).
  static List<WizardExercise> maxSizeGiantset({
    String groupId = 'giantset-max',
  }) {
    return giantset(
      groupId: groupId,
      count: 8,
      names: [
        'Agachamento',
        'Leg Press',
        'Hack',
        'Extensora',
        'Flexora',
        'Panturrilha Sentado',
        'Panturrilha em Pe',
        'Stiff',
      ],
    );
  }

  /// Creates an exercise with instructions.
  static WizardExercise exerciseWithInstructions({
    String id = 'wizard-instructions',
    String exerciseId = 'ex-instructions',
    String name = 'Exercicio com Instrucoes',
    String instructions = 'Execute devagar, 3 segundos na excentrica',
  }) {
    return WizardExercise(
      id: id,
      exerciseId: exerciseId,
      name: name,
      muscleGroup: 'chest',
      sets: 4,
      reps: '8-10',
      restSeconds: 90,
      executionInstructions: instructions,
      techniqueType: TechniqueType.normal,
    );
  }

  /// Creates an exercise with isometric hold.
  static WizardExercise exerciseWithIsometricHold({
    String id = 'wizard-isometric',
    String exerciseId = 'ex-isometric',
    String name = 'Prancha',
    int isometricSeconds = 30,
  }) {
    return WizardExercise(
      id: id,
      exerciseId: exerciseId,
      name: name,
      muscleGroup: 'abs',
      sets: 3,
      reps: '1',
      restSeconds: 60,
      isometricSeconds: isometricSeconds,
      techniqueType: TechniqueType.normal,
      executionInstructions: 'Mantenha a posicao por ${isometricSeconds}s',
    );
  }
}
