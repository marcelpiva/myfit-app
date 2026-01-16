// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainerWorkout _$TrainerWorkoutFromJson(
  Map<String, dynamic> json,
) => _TrainerWorkout(
  id: json['id'] as String,
  trainerId: json['trainerId'] as String,
  trainerName: json['trainerName'] as String,
  studentId: json['studentId'] as String,
  studentName: json['studentName'] as String,
  studentAvatarUrl: json['studentAvatarUrl'] as String?,
  name: json['name'] as String,
  description: json['description'] as String?,
  difficulty:
      $enumDecodeNullable(_$WorkoutDifficultyEnumMap, json['difficulty']) ??
      WorkoutDifficulty.intermediate,
  status:
      $enumDecodeNullable(_$WorkoutAssignmentStatusEnumMap, json['status']) ??
      WorkoutAssignmentStatus.draft,
  exercises:
      (json['exercises'] as List<dynamic>?)
          ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  periodization:
      $enumDecodeNullable(_$PeriodizationTypeEnumMap, json['periodization']) ??
      PeriodizationType.linear,
  weekNumber: (json['weekNumber'] as num?)?.toInt(),
  totalWeeks: (json['totalWeeks'] as num?)?.toInt(),
  phase: json['phase'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
  completedSessions: (json['completedSessions'] as num?)?.toInt() ?? 0,
  estimatedDurationMinutes:
      (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 0,
  trainerNotes: json['trainerNotes'] as String?,
  studentFeedback: json['studentFeedback'] as String?,
  aiGenerated: json['aiGenerated'] as bool? ?? false,
  aiSuggestionId: json['aiSuggestionId'] as String?,
  version: (json['version'] as num?)?.toInt() ?? 1,
  previousVersionId: json['previousVersionId'] as String?,
);

Map<String, dynamic> _$TrainerWorkoutToJson(_TrainerWorkout instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trainerId': instance.trainerId,
      'trainerName': instance.trainerName,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'studentAvatarUrl': instance.studentAvatarUrl,
      'name': instance.name,
      'description': instance.description,
      'difficulty': _$WorkoutDifficultyEnumMap[instance.difficulty]!,
      'status': _$WorkoutAssignmentStatusEnumMap[instance.status]!,
      'exercises': instance.exercises,
      'periodization': _$PeriodizationTypeEnumMap[instance.periodization]!,
      'weekNumber': instance.weekNumber,
      'totalWeeks': instance.totalWeeks,
      'phase': instance.phase,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'totalSessions': instance.totalSessions,
      'completedSessions': instance.completedSessions,
      'estimatedDurationMinutes': instance.estimatedDurationMinutes,
      'trainerNotes': instance.trainerNotes,
      'studentFeedback': instance.studentFeedback,
      'aiGenerated': instance.aiGenerated,
      'aiSuggestionId': instance.aiSuggestionId,
      'version': instance.version,
      'previousVersionId': instance.previousVersionId,
    };

const _$WorkoutDifficultyEnumMap = {
  WorkoutDifficulty.beginner: 'beginner',
  WorkoutDifficulty.intermediate: 'intermediate',
  WorkoutDifficulty.advanced: 'advanced',
  WorkoutDifficulty.elite: 'elite',
};

const _$WorkoutAssignmentStatusEnumMap = {
  WorkoutAssignmentStatus.draft: 'draft',
  WorkoutAssignmentStatus.active: 'active',
  WorkoutAssignmentStatus.paused: 'paused',
  WorkoutAssignmentStatus.completed: 'completed',
  WorkoutAssignmentStatus.archived: 'archived',
};

const _$PeriodizationTypeEnumMap = {
  PeriodizationType.linear: 'linear',
  PeriodizationType.undulating: 'undulating',
  PeriodizationType.block: 'block',
  PeriodizationType.conjugate: 'conjugate',
  PeriodizationType.custom: 'custom',
};

_WorkoutExercise _$WorkoutExerciseFromJson(Map<String, dynamic> json) =>
    _WorkoutExercise(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      exerciseImageUrl: json['exerciseImageUrl'] as String?,
      exerciseVideoUrl: json['exerciseVideoUrl'] as String?,
      sets: (json['sets'] as num?)?.toInt() ?? 3,
      repsMin: (json['repsMin'] as num?)?.toInt(),
      repsMax: (json['repsMax'] as num?)?.toInt(),
      repsNote: json['repsNote'] as String?,
      restSeconds: (json['restSeconds'] as num?)?.toInt(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      weightNote: json['weightNote'] as String?,
      dropSet: json['dropSet'] as bool? ?? false,
      superSet: json['superSet'] as bool? ?? false,
      superSetWith: json['superSetWith'] as String?,
      tempo: json['tempo'] as String?,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      order: (json['order'] as num?)?.toInt() ?? 0,
      groupId: json['groupId'] as String?,
      notes: json['notes'] as String?,
      progressionNote: json['progressionNote'] as String?,
      nextWeightKg: (json['nextWeightKg'] as num?)?.toDouble(),
      nextRepsTarget: (json['nextRepsTarget'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WorkoutExerciseToJson(_WorkoutExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'exerciseImageUrl': instance.exerciseImageUrl,
      'exerciseVideoUrl': instance.exerciseVideoUrl,
      'sets': instance.sets,
      'repsMin': instance.repsMin,
      'repsMax': instance.repsMax,
      'repsNote': instance.repsNote,
      'restSeconds': instance.restSeconds,
      'weightKg': instance.weightKg,
      'weightNote': instance.weightNote,
      'dropSet': instance.dropSet,
      'superSet': instance.superSet,
      'superSetWith': instance.superSetWith,
      'tempo': instance.tempo,
      'durationSeconds': instance.durationSeconds,
      'order': instance.order,
      'groupId': instance.groupId,
      'notes': instance.notes,
      'progressionNote': instance.progressionNote,
      'nextWeightKg': instance.nextWeightKg,
      'nextRepsTarget': instance.nextRepsTarget,
    };

_ExerciseProgress _$ExerciseProgressFromJson(Map<String, dynamic> json) =>
    _ExerciseProgress(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      studentId: json['studentId'] as String,
      logs:
          (json['logs'] as List<dynamic>?)
              ?.map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pr1RM: (json['pr1RM'] as num?)?.toDouble(),
      pr5RM: (json['pr5RM'] as num?)?.toDouble(),
      pr10RM: (json['pr10RM'] as num?)?.toDouble(),
      lastPrDate: json['lastPrDate'] == null
          ? null
          : DateTime.parse(json['lastPrDate'] as String),
      trend:
          $enumDecodeNullable(_$ProgressTrendEnumMap, json['trend']) ??
          ProgressTrend.stable,
      averageWeightLast4Weeks: (json['averageWeightLast4Weeks'] as num?)
          ?.toDouble(),
      averageRepsLast4Weeks: (json['averageRepsLast4Weeks'] as num?)
          ?.toDouble(),
    );

Map<String, dynamic> _$ExerciseProgressToJson(_ExerciseProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'studentId': instance.studentId,
      'logs': instance.logs,
      'pr1RM': instance.pr1RM,
      'pr5RM': instance.pr5RM,
      'pr10RM': instance.pr10RM,
      'lastPrDate': instance.lastPrDate?.toIso8601String(),
      'trend': _$ProgressTrendEnumMap[instance.trend]!,
      'averageWeightLast4Weeks': instance.averageWeightLast4Weeks,
      'averageRepsLast4Weeks': instance.averageRepsLast4Weeks,
    };

const _$ProgressTrendEnumMap = {
  ProgressTrend.improving: 'improving',
  ProgressTrend.stable: 'stable',
  ProgressTrend.declining: 'declining',
};

_ExerciseLog _$ExerciseLogFromJson(Map<String, dynamic> json) => _ExerciseLog(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  sets: (json['sets'] as num).toInt(),
  reps: (json['reps'] as num).toInt(),
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  rpe: (json['rpe'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  isPR: json['isPR'] as bool? ?? false,
);

Map<String, dynamic> _$ExerciseLogToJson(_ExerciseLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'sets': instance.sets,
      'reps': instance.reps,
      'weightKg': instance.weightKg,
      'rpe': instance.rpe,
      'notes': instance.notes,
      'isPR': instance.isPR,
    };

_StudentProgress _$StudentProgressFromJson(
  Map<String, dynamic> json,
) => _StudentProgress(
  studentId: json['studentId'] as String,
  studentName: json['studentName'] as String,
  studentAvatarUrl: json['studentAvatarUrl'] as String?,
  totalWorkouts: (json['totalWorkouts'] as num?)?.toInt() ?? 0,
  totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
  totalMinutes: (json['totalMinutes'] as num?)?.toInt() ?? 0,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
  sessionsThisWeek: (json['sessionsThisWeek'] as num?)?.toInt() ?? 0,
  sessionsThisMonth: (json['sessionsThisMonth'] as num?)?.toInt() ?? 0,
  averageSessionsPerWeek: (json['averageSessionsPerWeek'] as num?)?.toDouble(),
  exerciseProgress:
      (json['exerciseProgress'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, ExerciseProgress.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  milestones:
      (json['milestones'] as List<dynamic>?)
          ?.map((e) => ProgressMilestone.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  trainerNotes: json['trainerNotes'] as String?,
  lastEvaluation: json['lastEvaluation'] == null
      ? null
      : DateTime.parse(json['lastEvaluation'] as String),
  aiSuggestions:
      (json['aiSuggestions'] as List<dynamic>?)
          ?.map((e) => AISuggestion.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$StudentProgressToJson(_StudentProgress instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'studentAvatarUrl': instance.studentAvatarUrl,
      'totalWorkouts': instance.totalWorkouts,
      'totalSessions': instance.totalSessions,
      'totalMinutes': instance.totalMinutes,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'sessionsThisWeek': instance.sessionsThisWeek,
      'sessionsThisMonth': instance.sessionsThisMonth,
      'averageSessionsPerWeek': instance.averageSessionsPerWeek,
      'exerciseProgress': instance.exerciseProgress,
      'milestones': instance.milestones,
      'trainerNotes': instance.trainerNotes,
      'lastEvaluation': instance.lastEvaluation?.toIso8601String(),
      'aiSuggestions': instance.aiSuggestions,
    };

_ProgressMilestone _$ProgressMilestoneFromJson(Map<String, dynamic> json) =>
    _ProgressMilestone(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      achievedAt: DateTime.parse(json['achievedAt'] as String),
      icon: json['icon'] as String?,
      exerciseId: json['exerciseId'] as String?,
      value: (json['value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$ProgressMilestoneToJson(_ProgressMilestone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'achievedAt': instance.achievedAt.toIso8601String(),
      'icon': instance.icon,
      'exerciseId': instance.exerciseId,
      'value': instance.value,
      'unit': instance.unit,
    };

_AISuggestion _$AISuggestionFromJson(Map<String, dynamic> json) =>
    _AISuggestion(
      id: json['id'] as String,
      type: $enumDecode(_$AISuggestionTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      rationale: json['rationale'] as String,
      exerciseId: json['exerciseId'] as String?,
      exerciseName: json['exerciseName'] as String?,
      suggestedWeight: (json['suggestedWeight'] as num?)?.toDouble(),
      suggestedReps: (json['suggestedReps'] as num?)?.toInt(),
      suggestedSets: (json['suggestedSets'] as num?)?.toInt(),
      newExerciseId: json['newExerciseId'] as String?,
      newExerciseName: json['newExerciseName'] as String?,
      replacesExerciseId: json['replacesExerciseId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      applied: json['applied'] as bool? ?? false,
      dismissed: json['dismissed'] as bool? ?? false,
      dismissReason: json['dismissReason'] as String?,
    );

Map<String, dynamic> _$AISuggestionToJson(_AISuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AISuggestionTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'rationale': instance.rationale,
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'suggestedWeight': instance.suggestedWeight,
      'suggestedReps': instance.suggestedReps,
      'suggestedSets': instance.suggestedSets,
      'newExerciseId': instance.newExerciseId,
      'newExerciseName': instance.newExerciseName,
      'replacesExerciseId': instance.replacesExerciseId,
      'createdAt': instance.createdAt.toIso8601String(),
      'applied': instance.applied,
      'dismissed': instance.dismissed,
      'dismissReason': instance.dismissReason,
    };

const _$AISuggestionTypeEnumMap = {
  AISuggestionType.increaseWeight: 'increaseWeight',
  AISuggestionType.increaseVolume: 'increaseVolume',
  AISuggestionType.deload: 'deload',
  AISuggestionType.replaceExercise: 'replaceExercise',
  AISuggestionType.addExercise: 'addExercise',
  AISuggestionType.removeExercise: 'removeExercise',
  AISuggestionType.changePeriodization: 'changePeriodization',
  AISuggestionType.adjustFrequency: 'adjustFrequency',
  AISuggestionType.focusWeakPoint: 'focusWeakPoint',
  AISuggestionType.general: 'general',
};
