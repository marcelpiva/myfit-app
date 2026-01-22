// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PersonalRecord _$PersonalRecordFromJson(Map<String, dynamic> json) =>
    _PersonalRecord(
      id: json['id'] as String,
      exerciseId: json['exercise_id'] as String,
      exerciseName: json['exercise_name'] as String,
      studentId: json['student_id'] as String,
      type: $enumDecode(_$PRTypeEnumMap, json['type']),
      value: (json['value'] as num).toDouble(),
      achievedAt: DateTime.parse(json['achieved_at'] as String),
      previousValue: (json['previous_value'] as num?)?.toDouble(),
      previousDate: json['previous_date'] == null
          ? null
          : DateTime.parse(json['previous_date'] as String),
      setNumber: (json['set_number'] as num?)?.toInt(),
      reps: (json['reps'] as num?)?.toInt(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      sessionId: json['session_id'] as String?,
    );

Map<String, dynamic> _$PersonalRecordToJson(_PersonalRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exercise_id': instance.exerciseId,
      'exercise_name': instance.exerciseName,
      'student_id': instance.studentId,
      'type': _$PRTypeEnumMap[instance.type]!,
      'value': instance.value,
      'achieved_at': instance.achievedAt.toIso8601String(),
      'previous_value': instance.previousValue,
      'previous_date': instance.previousDate?.toIso8601String(),
      'set_number': instance.setNumber,
      'reps': instance.reps,
      'weight_kg': instance.weightKg,
      'notes': instance.notes,
      'session_id': instance.sessionId,
    };

const _$PRTypeEnumMap = {
  PRType.maxWeight: 'max_weight',
  PRType.maxReps: 'max_reps',
  PRType.maxVolume: 'max_volume',
  PRType.estimated1RM: 'estimated_1rm',
};

_ExercisePRSummary _$ExercisePRSummaryFromJson(Map<String, dynamic> json) =>
    _ExercisePRSummary(
      exerciseId: json['exercise_id'] as String,
      exerciseName: json['exercise_name'] as String,
      exerciseImageUrl: json['exercise_image_url'] as String?,
      muscleGroup: json['muscle_group'] as String?,
      prMaxWeight: (json['pr_max_weight'] as num?)?.toDouble(),
      prMaxWeightDate: json['pr_max_weight_date'] == null
          ? null
          : DateTime.parse(json['pr_max_weight_date'] as String),
      prMaxWeightReps: (json['pr_max_weight_reps'] as num?)?.toInt(),
      prMaxReps: (json['pr_max_reps'] as num?)?.toInt(),
      prMaxRepsDate: json['pr_max_reps_date'] == null
          ? null
          : DateTime.parse(json['pr_max_reps_date'] as String),
      prMaxRepsWeight: (json['pr_max_reps_weight'] as num?)?.toDouble(),
      prMaxVolume: (json['pr_max_volume'] as num?)?.toDouble(),
      prMaxVolumeDate: json['pr_max_volume_date'] == null
          ? null
          : DateTime.parse(json['pr_max_volume_date'] as String),
      prEstimated1RM: (json['pr_estimated_1rm'] as num?)?.toDouble(),
      prEstimated1RMDate: json['pr_estimated_1rm_date'] == null
          ? null
          : DateTime.parse(json['pr_estimated_1rm_date'] as String),
      totalSessions: (json['total_sessions'] as num?)?.toInt() ?? 0,
      lastPerformed: json['last_performed'] == null
          ? null
          : DateTime.parse(json['last_performed'] as String),
      recentPRs:
          (json['recent_prs'] as List<dynamic>?)
              ?.map((e) => PersonalRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ExercisePRSummaryToJson(_ExercisePRSummary instance) =>
    <String, dynamic>{
      'exercise_id': instance.exerciseId,
      'exercise_name': instance.exerciseName,
      'exercise_image_url': instance.exerciseImageUrl,
      'muscle_group': instance.muscleGroup,
      'pr_max_weight': instance.prMaxWeight,
      'pr_max_weight_date': instance.prMaxWeightDate?.toIso8601String(),
      'pr_max_weight_reps': instance.prMaxWeightReps,
      'pr_max_reps': instance.prMaxReps,
      'pr_max_reps_date': instance.prMaxRepsDate?.toIso8601String(),
      'pr_max_reps_weight': instance.prMaxRepsWeight,
      'pr_max_volume': instance.prMaxVolume,
      'pr_max_volume_date': instance.prMaxVolumeDate?.toIso8601String(),
      'pr_estimated_1rm': instance.prEstimated1RM,
      'pr_estimated_1rm_date': instance.prEstimated1RMDate?.toIso8601String(),
      'total_sessions': instance.totalSessions,
      'last_performed': instance.lastPerformed?.toIso8601String(),
      'recent_prs': instance.recentPRs,
    };

_PersonalRecordList _$PersonalRecordListFromJson(Map<String, dynamic> json) =>
    _PersonalRecordList(
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExercisePRSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPRs: (json['total_prs'] as num?)?.toInt() ?? 0,
      prsThisMonth: (json['prs_this_month'] as num?)?.toInt() ?? 0,
      mostImprovedExercise: json['most_improved_exercise'] as String?,
    );

Map<String, dynamic> _$PersonalRecordListToJson(_PersonalRecordList instance) =>
    <String, dynamic>{
      'exercises': instance.exercises,
      'total_prs': instance.totalPRs,
      'prs_this_month': instance.prsThisMonth,
      'most_improved_exercise': instance.mostImprovedExercise,
    };

_PRAchievement _$PRAchievementFromJson(Map<String, dynamic> json) =>
    _PRAchievement(
      exerciseName: json['exercise_name'] as String,
      type: $enumDecode(_$PRTypeEnumMap, json['type']),
      newValue: (json['new_value'] as num).toDouble(),
      previousValue: (json['previous_value'] as num?)?.toDouble(),
      improvementPercent: (json['improvement_percent'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PRAchievementToJson(_PRAchievement instance) =>
    <String, dynamic>{
      'exercise_name': instance.exerciseName,
      'type': _$PRTypeEnumMap[instance.type]!,
      'new_value': instance.newValue,
      'previous_value': instance.previousValue,
      'improvement_percent': instance.improvementPercent,
    };
