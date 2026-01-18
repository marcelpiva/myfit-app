// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SharedSession _$SharedSessionFromJson(Map<String, dynamic> json) =>
    _SharedSession(
      id: json['id'] as String,
      workoutId: json['workout_id'] as String,
      userId: json['user_id'] as String,
      trainerId: json['trainer_id'] as String?,
      isShared: json['is_shared'] as bool,
      status: $enumDecode(_$SessionStatusEnumMap, json['status']),
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      studentFeedback: json['student_feedback'] as String?,
      trainerNotes: json['trainer_notes'] as String?,
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((e) => SessionSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => SessionMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      adjustments:
          (json['adjustments'] as List<dynamic>?)
              ?.map(
                (e) => TrainerAdjustment.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SharedSessionToJson(_SharedSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workout_id': instance.workoutId,
      'user_id': instance.userId,
      'trainer_id': instance.trainerId,
      'is_shared': instance.isShared,
      'status': _$SessionStatusEnumMap[instance.status]!,
      'started_at': instance.startedAt.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'duration_minutes': instance.durationMinutes,
      'notes': instance.notes,
      'rating': instance.rating,
      'student_feedback': instance.studentFeedback,
      'trainer_notes': instance.trainerNotes,
      'sets': instance.sets,
      'messages': instance.messages,
      'adjustments': instance.adjustments,
    };

const _$SessionStatusEnumMap = {
  SessionStatus.waiting: 'waiting',
  SessionStatus.active: 'active',
  SessionStatus.paused: 'paused',
  SessionStatus.completed: 'completed',
};

_SessionSet _$SessionSetFromJson(Map<String, dynamic> json) => _SessionSet(
  id: json['id'] as String,
  exerciseId: json['exercise_id'] as String,
  setNumber: (json['set_number'] as num).toInt(),
  repsCompleted: (json['reps_completed'] as num).toInt(),
  weightKg: (json['weight_kg'] as num?)?.toDouble(),
  durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  performedAt: DateTime.parse(json['performed_at'] as String),
);

Map<String, dynamic> _$SessionSetToJson(_SessionSet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exercise_id': instance.exerciseId,
      'set_number': instance.setNumber,
      'reps_completed': instance.repsCompleted,
      'weight_kg': instance.weightKg,
      'duration_seconds': instance.durationSeconds,
      'notes': instance.notes,
      'performed_at': instance.performedAt.toIso8601String(),
    };

_SessionMessage _$SessionMessageFromJson(Map<String, dynamic> json) =>
    _SessionMessage(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String?,
      message: json['message'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );

Map<String, dynamic> _$SessionMessageToJson(_SessionMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'sender_id': instance.senderId,
      'sender_name': instance.senderName,
      'message': instance.message,
      'sent_at': instance.sentAt.toIso8601String(),
      'is_read': instance.isRead,
    };

_TrainerAdjustment _$TrainerAdjustmentFromJson(Map<String, dynamic> json) =>
    _TrainerAdjustment(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      trainerId: json['trainer_id'] as String,
      exerciseId: json['exercise_id'] as String,
      setNumber: (json['set_number'] as num?)?.toInt(),
      suggestedWeightKg: (json['suggested_weight_kg'] as num?)?.toDouble(),
      suggestedReps: (json['suggested_reps'] as num?)?.toInt(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TrainerAdjustmentToJson(_TrainerAdjustment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'trainer_id': instance.trainerId,
      'exercise_id': instance.exerciseId,
      'set_number': instance.setNumber,
      'suggested_weight_kg': instance.suggestedWeightKg,
      'suggested_reps': instance.suggestedReps,
      'note': instance.note,
      'created_at': instance.createdAt.toIso8601String(),
    };

_ActiveSession _$ActiveSessionFromJson(Map<String, dynamic> json) =>
    _ActiveSession(
      id: json['id'] as String,
      workoutId: json['workout_id'] as String,
      workoutName: json['workout_name'] as String,
      userId: json['user_id'] as String,
      studentName: json['student_name'] as String,
      studentAvatar: json['student_avatar'] as String?,
      trainerId: json['trainer_id'] as String?,
      isShared: json['is_shared'] as bool,
      status: $enumDecode(_$SessionStatusEnumMap, json['status']),
      startedAt: DateTime.parse(json['started_at'] as String),
      currentExerciseIndex:
          (json['current_exercise_index'] as num?)?.toInt() ?? 0,
      totalExercises: (json['total_exercises'] as num?)?.toInt() ?? 0,
      completedSets: (json['completed_sets'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ActiveSessionToJson(_ActiveSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workout_id': instance.workoutId,
      'workout_name': instance.workoutName,
      'user_id': instance.userId,
      'student_name': instance.studentName,
      'student_avatar': instance.studentAvatar,
      'trainer_id': instance.trainerId,
      'is_shared': instance.isShared,
      'status': _$SessionStatusEnumMap[instance.status]!,
      'started_at': instance.startedAt.toIso8601String(),
      'current_exercise_index': instance.currentExerciseIndex,
      'total_exercises': instance.totalExercises,
      'completed_sets': instance.completedSets,
    };
