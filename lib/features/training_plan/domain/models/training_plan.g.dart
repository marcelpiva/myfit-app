// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainingPlan _$TrainingPlanFromJson(Map<String, dynamic> json) =>
    _TrainingPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      goal: $enumDecode(_$WorkoutGoalEnumMap, json['goal']),
      difficulty: $enumDecode(_$PlanDifficultyEnumMap, json['difficulty']),
      splitType: $enumDecode(_$SplitTypeEnumMap, json['splitType']),
      description: json['description'] as String?,
      durationWeeks: (json['durationWeeks'] as num?)?.toInt(),
      isTemplate: json['isTemplate'] as bool? ?? false,
      isPublic: json['isPublic'] as bool? ?? false,
      createdById: json['createdById'] as String,
      organizationId: json['organizationId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      planWorkouts:
          (json['planWorkouts'] as List<dynamic>?)
              ?.map((e) => PlanWorkout.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TrainingPlanToJson(_TrainingPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'goal': _$WorkoutGoalEnumMap[instance.goal]!,
      'difficulty': _$PlanDifficultyEnumMap[instance.difficulty]!,
      'splitType': _$SplitTypeEnumMap[instance.splitType]!,
      'description': instance.description,
      'durationWeeks': instance.durationWeeks,
      'isTemplate': instance.isTemplate,
      'isPublic': instance.isPublic,
      'createdById': instance.createdById,
      'organizationId': instance.organizationId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'planWorkouts': instance.planWorkouts,
    };

const _$WorkoutGoalEnumMap = {
  WorkoutGoal.hypertrophy: 'hypertrophy',
  WorkoutGoal.strength: 'strength',
  WorkoutGoal.fatLoss: 'fat_loss',
  WorkoutGoal.endurance: 'endurance',
  WorkoutGoal.functional: 'functional',
  WorkoutGoal.generalFitness: 'general_fitness',
};

const _$PlanDifficultyEnumMap = {
  PlanDifficulty.beginner: 'beginner',
  PlanDifficulty.intermediate: 'intermediate',
  PlanDifficulty.advanced: 'advanced',
};

const _$SplitTypeEnumMap = {
  SplitType.abc: 'abc',
  SplitType.abcd: 'abcd',
  SplitType.abcde: 'abcde',
  SplitType.pushPullLegs: 'push_pull_legs',
  SplitType.upperLower: 'upper_lower',
  SplitType.fullBody: 'full_body',
  SplitType.custom: 'custom',
};

_PlanWorkout _$PlanWorkoutFromJson(Map<String, dynamic> json) => _PlanWorkout(
  id: json['id'] as String,
  workoutId: json['workoutId'] as String,
  order: (json['order'] as num).toInt(),
  label: json['label'] as String,
  dayOfWeek: (json['dayOfWeek'] as num?)?.toInt(),
  workout: json['workout'] == null
      ? null
      : PlanWorkoutDetail.fromJson(json['workout'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PlanWorkoutToJson(_PlanWorkout instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workoutId': instance.workoutId,
      'order': instance.order,
      'label': instance.label,
      'dayOfWeek': instance.dayOfWeek,
      'workout': instance.workout,
    };

_PlanWorkoutDetail _$PlanWorkoutDetailFromJson(Map<String, dynamic> json) =>
    _PlanWorkoutDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      difficulty: json['difficulty'] as String,
      estimatedDurationMin: (json['estimatedDurationMin'] as num).toInt(),
      targetMuscles: (json['targetMuscles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map((e) => PlanExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PlanWorkoutDetailToJson(_PlanWorkoutDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'difficulty': instance.difficulty,
      'estimatedDurationMin': instance.estimatedDurationMin,
      'targetMuscles': instance.targetMuscles,
      'exercises': instance.exercises,
    };

_PlanExercise _$PlanExerciseFromJson(Map<String, dynamic> json) =>
    _PlanExercise(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      order: (json['order'] as num).toInt(),
      sets: (json['sets'] as num).toInt(),
      reps: json['reps'] as String,
      restSeconds: (json['restSeconds'] as num).toInt(),
      notes: json['notes'] as String?,
      supersetWith: json['supersetWith'] as String?,
      executionInstructions: json['executionInstructions'] as String?,
      isometricSeconds: (json['isometricSeconds'] as num?)?.toInt(),
      techniqueType:
          $enumDecodeNullable(_$TechniqueTypeEnumMap, json['techniqueType']) ??
          TechniqueType.normal,
      exerciseGroupId: json['exerciseGroupId'] as String?,
      exerciseGroupOrder: (json['exerciseGroupOrder'] as num?)?.toInt() ?? 0,
      estimatedSeconds: (json['estimatedSeconds'] as num?)?.toInt() ?? 0,
      exercise: json['exercise'] == null
          ? null
          : PlanExerciseDetail.fromJson(
              json['exercise'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PlanExerciseToJson(_PlanExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'order': instance.order,
      'sets': instance.sets,
      'reps': instance.reps,
      'restSeconds': instance.restSeconds,
      'notes': instance.notes,
      'supersetWith': instance.supersetWith,
      'executionInstructions': instance.executionInstructions,
      'isometricSeconds': instance.isometricSeconds,
      'techniqueType': _$TechniqueTypeEnumMap[instance.techniqueType]!,
      'exerciseGroupId': instance.exerciseGroupId,
      'exerciseGroupOrder': instance.exerciseGroupOrder,
      'estimatedSeconds': instance.estimatedSeconds,
      'exercise': instance.exercise,
    };

const _$TechniqueTypeEnumMap = {
  TechniqueType.normal: 'normal',
  TechniqueType.superset: 'superset',
  TechniqueType.biset: 'biset',
  TechniqueType.triset: 'triset',
  TechniqueType.giantset: 'giantset',
  TechniqueType.dropset: 'dropset',
  TechniqueType.restPause: 'rest_pause',
  TechniqueType.cluster: 'cluster',
};

_PlanExerciseDetail _$PlanExerciseDetailFromJson(Map<String, dynamic> json) =>
    _PlanExerciseDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String,
      description: json['description'] as String?,
      instructions: json['instructions'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );

Map<String, dynamic> _$PlanExerciseDetailToJson(_PlanExerciseDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'muscleGroup': instance.muscleGroup,
      'description': instance.description,
      'instructions': instance.instructions,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
    };
