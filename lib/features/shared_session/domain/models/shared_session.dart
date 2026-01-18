/// Models for shared workout sessions (co-training).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared_session.freezed.dart';
part 'shared_session.g.dart';

/// Session status for co-training.
enum SessionStatus {
  @JsonValue('waiting')
  waiting,
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('completed')
  completed,
}

/// A shared workout session between trainer and student.
@freezed
sealed class SharedSession with _$SharedSession {
  const SharedSession._();

  const factory SharedSession({
    required String id,
    @JsonKey(name: 'workout_id') required String workoutId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'trainer_id') String? trainerId,
    @JsonKey(name: 'is_shared') required bool isShared,
    required SessionStatus status,
    @JsonKey(name: 'started_at') required DateTime startedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    String? notes,
    int? rating,
    @JsonKey(name: 'student_feedback') String? studentFeedback,
    @JsonKey(name: 'trainer_notes') String? trainerNotes,
    @Default([]) List<SessionSet> sets,
    @Default([]) List<SessionMessage> messages,
    @Default([]) List<TrainerAdjustment> adjustments,
  }) = _SharedSession;

  factory SharedSession.fromJson(Map<String, dynamic> json) =>
      _$SharedSessionFromJson(json);
}

/// A set completed during a session.
@freezed
sealed class SessionSet with _$SessionSet {
  const SessionSet._();

  const factory SessionSet({
    required String id,
    @JsonKey(name: 'exercise_id') required String exerciseId,
    @JsonKey(name: 'set_number') required int setNumber,
    @JsonKey(name: 'reps_completed') required int repsCompleted,
    @JsonKey(name: 'weight_kg') double? weightKg,
    @JsonKey(name: 'duration_seconds') int? durationSeconds,
    String? notes,
    @JsonKey(name: 'performed_at') required DateTime performedAt,
  }) = _SessionSet;

  factory SessionSet.fromJson(Map<String, dynamic> json) =>
      _$SessionSetFromJson(json);
}

/// A message sent during co-training.
@freezed
sealed class SessionMessage with _$SessionMessage {
  const SessionMessage._();

  const factory SessionMessage({
    required String id,
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'sender_id') required String senderId,
    @JsonKey(name: 'sender_name') String? senderName,
    required String message,
    @JsonKey(name: 'sent_at') required DateTime sentAt,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
  }) = _SessionMessage;

  factory SessionMessage.fromJson(Map<String, dynamic> json) =>
      _$SessionMessageFromJson(json);
}

/// A trainer adjustment during co-training.
@freezed
sealed class TrainerAdjustment with _$TrainerAdjustment {
  const TrainerAdjustment._();

  const factory TrainerAdjustment({
    required String id,
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'trainer_id') required String trainerId,
    @JsonKey(name: 'exercise_id') required String exerciseId,
    @JsonKey(name: 'set_number') int? setNumber,
    @JsonKey(name: 'suggested_weight_kg') double? suggestedWeightKg,
    @JsonKey(name: 'suggested_reps') int? suggestedReps,
    String? note,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TrainerAdjustment;

  factory TrainerAdjustment.fromJson(Map<String, dynamic> json) =>
      _$TrainerAdjustmentFromJson(json);
}

/// Event types for real-time session updates.
enum SessionEventType {
  sessionStarted,
  sessionPaused,
  sessionResumed,
  sessionCompleted,
  trainerJoined,
  trainerLeft,
  trainerAdjustment,
  setCompleted,
  exerciseChanged,
  messageSent,
  messageRead,
  syncRequest,
  syncResponse,
}

/// A real-time session event.
@freezed
sealed class SessionEvent with _$SessionEvent {
  const SessionEvent._();

  const factory SessionEvent({
    @JsonKey(name: 'event_type') required SessionEventType eventType,
    @JsonKey(name: 'session_id') required String sessionId,
    required Map<String, dynamic> data,
    @JsonKey(name: 'sender_id') String? senderId,
    required DateTime timestamp,
  }) = _SessionEvent;

  factory SessionEvent.fromJson(Map<String, dynamic> json) {
    final eventTypeStr = json['event_type'] as String;
    final eventType = SessionEventType.values.firstWhere(
      (e) => e.name == _snakeToCamel(eventTypeStr),
      orElse: () => SessionEventType.syncResponse,
    );

    return SessionEvent(
      eventType: eventType,
      sessionId: json['session_id'] as String,
      data: json['data'] as Map<String, dynamic>? ?? {},
      senderId: json['sender_id'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Active session info for "Students Now" view.
@freezed
sealed class ActiveSession with _$ActiveSession {
  const ActiveSession._();

  const factory ActiveSession({
    required String id,
    @JsonKey(name: 'workout_id') required String workoutId,
    @JsonKey(name: 'workout_name') required String workoutName,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'student_name') required String studentName,
    @JsonKey(name: 'student_avatar') String? studentAvatar,
    @JsonKey(name: 'trainer_id') String? trainerId,
    @JsonKey(name: 'is_shared') required bool isShared,
    required SessionStatus status,
    @JsonKey(name: 'started_at') required DateTime startedAt,
    @JsonKey(name: 'current_exercise_index') @Default(0) int currentExerciseIndex,
    @JsonKey(name: 'total_exercises') @Default(0) int totalExercises,
    @JsonKey(name: 'completed_sets') @Default(0) int completedSets,
  }) = _ActiveSession;

  factory ActiveSession.fromJson(Map<String, dynamic> json) =>
      _$ActiveSessionFromJson(json);
}

String _snakeToCamel(String snake) {
  final parts = snake.split('_');
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}
