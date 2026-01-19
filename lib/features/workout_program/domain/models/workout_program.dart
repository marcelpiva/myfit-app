import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_program.freezed.dart';
part 'workout_program.g.dart';

/// Training program goals
enum WorkoutGoal {
  @JsonValue('hypertrophy')
  hypertrophy,
  @JsonValue('strength')
  strength,
  @JsonValue('fat_loss')
  fatLoss,
  @JsonValue('endurance')
  endurance,
  @JsonValue('functional')
  functional,
  @JsonValue('general_fitness')
  generalFitness,
}

/// Training split types
enum SplitType {
  @JsonValue('abc')
  abc,
  @JsonValue('abcd')
  abcd,
  @JsonValue('abcde')
  abcde,
  @JsonValue('push_pull_legs')
  pushPullLegs,
  @JsonValue('upper_lower')
  upperLower,
  @JsonValue('full_body')
  fullBody,
  @JsonValue('custom')
  custom,
}

/// Difficulty levels
enum ProgramDifficulty {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
}

/// Advanced training technique types
enum TechniqueType {
  @JsonValue('normal')
  normal,
  @JsonValue('superset')
  superset,
  @JsonValue('biset')
  biset,
  @JsonValue('triset')
  triset,
  @JsonValue('giantset')
  giantset,
  @JsonValue('dropset')
  dropset,
  @JsonValue('rest_pause')
  restPause,
  @JsonValue('cluster')
  cluster,
}

/// Extension to get display name for TechniqueType
extension TechniqueTypeDisplay on TechniqueType {
  String get displayName {
    switch (this) {
      case TechniqueType.normal:
        return 'Normal';
      case TechniqueType.superset:
        return 'Superset';
      case TechniqueType.biset:
        return 'Bi-Set';
      case TechniqueType.triset:
        return 'Tri-Set';
      case TechniqueType.giantset:
        return 'Giant Set';
      case TechniqueType.dropset:
        return 'Drop Set';
      case TechniqueType.restPause:
        return 'Rest Pause';
      case TechniqueType.cluster:
        return 'Cluster';
    }
  }

  String get description {
    switch (this) {
      case TechniqueType.normal:
        return 'Execução padrão com descanso entre séries';
      case TechniqueType.superset:
        return 'Peito/Costas ou Bíceps/Tríceps (grupos opostos)';
      case TechniqueType.biset:
        return 'Peito/Ombros ou Costas/Bíceps (mesma área)';
      case TechniqueType.triset:
        return '3 exercícios do mesmo grupo muscular';
      case TechniqueType.giantset:
        return '4+ exercícios do mesmo grupo muscular';
      case TechniqueType.dropset:
        return 'Reduz o peso e continua sem descanso';
      case TechniqueType.restPause:
        return 'Pausas curtas (10-15s) durante a série';
      case TechniqueType.cluster:
        return 'Mini-séries com pausas curtas';
    }
  }

  String toApiValue() {
    switch (this) {
      case TechniqueType.normal:
        return 'normal';
      case TechniqueType.superset:
        return 'superset';
      case TechniqueType.biset:
        return 'biset';
      case TechniqueType.triset:
        return 'triset';
      case TechniqueType.giantset:
        return 'giantset';
      case TechniqueType.dropset:
        return 'dropset';
      case TechniqueType.restPause:
        return 'rest_pause';
      case TechniqueType.cluster:
        return 'cluster';
    }
  }
}

/// Extension to parse TechniqueType from string
extension TechniqueTypeParsing on String {
  TechniqueType toTechniqueType() {
    switch (toLowerCase()) {
      case 'superset':
        return TechniqueType.superset;
      case 'biset':
      case 'bi_set':
        return TechniqueType.biset;
      case 'triset':
      case 'tri_set':
        return TechniqueType.triset;
      case 'giantset':
      case 'giant_set':
        return TechniqueType.giantset;
      case 'dropset':
        return TechniqueType.dropset;
      case 'rest_pause':
        return TechniqueType.restPause;
      case 'cluster':
        return TechniqueType.cluster;
      case 'isometric':
        // Isometric is not a technique type but a modifier
        // Return normal and let isometric_seconds handle it
        return TechniqueType.normal;
      default:
        return TechniqueType.normal;
    }
  }
}

/// Extension to get API-compatible string values for WorkoutGoal
extension WorkoutGoalToApi on WorkoutGoal {
  String toApiValue() {
    switch (this) {
      case WorkoutGoal.hypertrophy:
        return 'hypertrophy';
      case WorkoutGoal.strength:
        return 'strength';
      case WorkoutGoal.fatLoss:
        return 'fat_loss';
      case WorkoutGoal.endurance:
        return 'endurance';
      case WorkoutGoal.functional:
        return 'functional';
      case WorkoutGoal.generalFitness:
        return 'general_fitness';
    }
  }
}

/// Extension to get API-compatible string values for SplitType
extension SplitTypeToApi on SplitType {
  String toApiValue() {
    switch (this) {
      case SplitType.abc:
        return 'abc';
      case SplitType.abcd:
        return 'abcd';
      case SplitType.abcde:
        return 'abcde';
      case SplitType.pushPullLegs:
        return 'push_pull_legs';
      case SplitType.upperLower:
        return 'upper_lower';
      case SplitType.fullBody:
        return 'full_body';
      case SplitType.custom:
        return 'custom';
    }
  }
}

/// Extension to get API-compatible string values for ProgramDifficulty
extension ProgramDifficultyToApi on ProgramDifficulty {
  String toApiValue() {
    switch (this) {
      case ProgramDifficulty.beginner:
        return 'beginner';
      case ProgramDifficulty.intermediate:
        return 'intermediate';
      case ProgramDifficulty.advanced:
        return 'advanced';
    }
  }
}

/// Workout Program - a structured collection of workouts
@freezed
sealed class WorkoutProgram with _$WorkoutProgram {
  const WorkoutProgram._();

  const factory WorkoutProgram({
    required String id,
    required String name,
    required WorkoutGoal goal,
    required ProgramDifficulty difficulty,
    required SplitType splitType,
    String? description,
    int? durationWeeks,
    @Default(false) bool isTemplate,
    @Default(false) bool isPublic,
    required String createdById,
    String? organizationId,
    DateTime? createdAt,
    @Default([]) List<ProgramWorkout> programWorkouts,
  }) = _WorkoutProgram;

  factory WorkoutProgram.fromJson(Map<String, dynamic> json) =>
      _$WorkoutProgramFromJson(json);

  /// Display name for goal
  String get goalName {
    switch (goal) {
      case WorkoutGoal.hypertrophy:
        return 'Hipertrofia';
      case WorkoutGoal.strength:
        return 'Força';
      case WorkoutGoal.fatLoss:
        return 'Emagrecimento';
      case WorkoutGoal.endurance:
        return 'Resistência';
      case WorkoutGoal.functional:
        return 'Funcional';
      case WorkoutGoal.generalFitness:
        return 'Condicionamento Geral';
    }
  }

  /// Display name for difficulty
  String get difficultyName {
    switch (difficulty) {
      case ProgramDifficulty.beginner:
        return 'Iniciante';
      case ProgramDifficulty.intermediate:
        return 'Intermediário';
      case ProgramDifficulty.advanced:
        return 'Avançado';
    }
  }

  /// Display name for split type
  String get splitTypeName {
    switch (splitType) {
      case SplitType.abc:
        return 'ABC';
      case SplitType.abcd:
        return 'ABCD';
      case SplitType.abcde:
        return 'ABCDE';
      case SplitType.pushPullLegs:
        return 'Push/Pull/Legs';
      case SplitType.upperLower:
        return 'Upper/Lower';
      case SplitType.fullBody:
        return 'Full Body';
      case SplitType.custom:
        return 'Personalizado';
    }
  }

  /// Get the number of workouts
  int get workoutCount => programWorkouts.length;

  /// Get total estimated duration of all workouts
  int get totalEstimatedMinutes {
    return programWorkouts.fold<int>(
      0,
      (sum, pw) => sum + (pw.workout?.estimatedDurationMin ?? 0),
    );
  }
}

/// Workout within a program
@freezed
sealed class ProgramWorkout with _$ProgramWorkout {
  const ProgramWorkout._();

  const factory ProgramWorkout({
    required String id,
    required String workoutId,
    required int order,
    required String label,
    int? dayOfWeek,
    ProgramWorkoutDetail? workout,
  }) = _ProgramWorkout;

  factory ProgramWorkout.fromJson(Map<String, dynamic> json) =>
      _$ProgramWorkoutFromJson(json);

  /// Get day of week name
  String? get dayOfWeekName {
    if (dayOfWeek == null) return null;
    switch (dayOfWeek!) {
      case 0:
        return 'Segunda';
      case 1:
        return 'Terça';
      case 2:
        return 'Quarta';
      case 3:
        return 'Quinta';
      case 4:
        return 'Sexta';
      case 5:
        return 'Sábado';
      case 6:
        return 'Domingo';
      default:
        return null;
    }
  }
}

/// Workout detail for program
@freezed
sealed class ProgramWorkoutDetail with _$ProgramWorkoutDetail {
  const ProgramWorkoutDetail._();

  const factory ProgramWorkoutDetail({
    required String id,
    required String name,
    String? description,
    required String difficulty,
    required int estimatedDurationMin,
    List<String>? targetMuscles,
    @Default([]) List<ProgramExercise> exercises,
  }) = _ProgramWorkoutDetail;

  factory ProgramWorkoutDetail.fromJson(Map<String, dynamic> json) =>
      _$ProgramWorkoutDetailFromJson(json);

  /// Get display name for difficulty
  String get difficultyName {
    switch (difficulty) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Intermediário';
      case 'advanced':
        return 'Avançado';
      default:
        return difficulty;
    }
  }
}

/// Exercise within a program workout
@freezed
sealed class ProgramExercise with _$ProgramExercise {
  const ProgramExercise._();

  const factory ProgramExercise({
    required String id,
    required String exerciseId,
    required int order,
    required int sets,
    required String reps,
    required int restSeconds,
    String? notes,
    String? supersetWith,
    // Advanced technique fields
    String? executionInstructions,
    int? isometricSeconds,
    @Default(TechniqueType.normal) TechniqueType techniqueType,
    String? exerciseGroupId,
    @Default(0) int exerciseGroupOrder,
    ProgramExerciseDetail? exercise,
  }) = _ProgramExercise;

  factory ProgramExercise.fromJson(Map<String, dynamic> json) =>
      _$ProgramExerciseFromJson(json);

  /// Check if exercise is part of a group (superset, triset, etc.)
  bool get isGrouped => exerciseGroupId != null && exerciseGroupId!.isNotEmpty;

  /// Check if this is the first exercise in a group
  bool get isGroupLeader => isGrouped && exerciseGroupOrder == 0;
}

/// Exercise detail
@freezed
sealed class ProgramExerciseDetail with _$ProgramExerciseDetail {
  const factory ProgramExerciseDetail({
    required String id,
    required String name,
    required String muscleGroup,
    String? description,
    String? instructions,
    String? imageUrl,
    String? videoUrl,
  }) = _ProgramExerciseDetail;

  factory ProgramExerciseDetail.fromJson(Map<String, dynamic> json) =>
      _$ProgramExerciseDetailFromJson(json);
}

/// Extension to parse goal from string
extension WorkoutGoalParsing on String {
  WorkoutGoal toWorkoutGoal() {
    switch (toLowerCase()) {
      case 'hypertrophy':
      case 'hipertrofia':
        return WorkoutGoal.hypertrophy;
      case 'strength':
      case 'forca':
        return WorkoutGoal.strength;
      case 'fat_loss':
      case 'emagrecimento':
        return WorkoutGoal.fatLoss;
      case 'endurance':
      case 'resistencia':
        return WorkoutGoal.endurance;
      case 'functional':
      case 'funcional':
        return WorkoutGoal.functional;
      default:
        return WorkoutGoal.generalFitness;
    }
  }
}

/// Extension to parse split type from string
extension SplitTypeParsing on String {
  SplitType toSplitType() {
    switch (toLowerCase()) {
      case 'abc':
        return SplitType.abc;
      case 'abcd':
        return SplitType.abcd;
      case 'abcde':
        return SplitType.abcde;
      case 'push_pull_legs':
      case 'ppl':
        return SplitType.pushPullLegs;
      case 'upper_lower':
        return SplitType.upperLower;
      case 'full_body':
        return SplitType.fullBody;
      default:
        return SplitType.custom;
    }
  }
}

/// Extension to parse difficulty from string
extension ProgramDifficultyParsing on String {
  ProgramDifficulty toProgramDifficulty() {
    switch (toLowerCase()) {
      case 'beginner':
      case 'iniciante':
        return ProgramDifficulty.beginner;
      case 'intermediate':
      case 'intermediario':
        return ProgramDifficulty.intermediate;
      case 'advanced':
      case 'avancado':
        return ProgramDifficulty.advanced;
      default:
        return ProgramDifficulty.intermediate;
    }
  }
}
