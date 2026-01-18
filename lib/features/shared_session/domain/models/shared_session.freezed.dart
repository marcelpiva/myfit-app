// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shared_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SharedSession {

 String get id;@JsonKey(name: 'workout_id') String get workoutId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'trainer_id') String? get trainerId;@JsonKey(name: 'is_shared') bool get isShared; SessionStatus get status;@JsonKey(name: 'started_at') DateTime get startedAt;@JsonKey(name: 'completed_at') DateTime? get completedAt;@JsonKey(name: 'duration_minutes') int? get durationMinutes; String? get notes; int? get rating;@JsonKey(name: 'student_feedback') String? get studentFeedback;@JsonKey(name: 'trainer_notes') String? get trainerNotes; List<SessionSet> get sets; List<SessionMessage> get messages; List<TrainerAdjustment> get adjustments;
/// Create a copy of SharedSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharedSessionCopyWith<SharedSession> get copyWith => _$SharedSessionCopyWithImpl<SharedSession>(this as SharedSession, _$identity);

  /// Serializes this SharedSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharedSession&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.isShared, isShared) || other.isShared == isShared)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.studentFeedback, studentFeedback) || other.studentFeedback == studentFeedback)&&(identical(other.trainerNotes, trainerNotes) || other.trainerNotes == trainerNotes)&&const DeepCollectionEquality().equals(other.sets, sets)&&const DeepCollectionEquality().equals(other.messages, messages)&&const DeepCollectionEquality().equals(other.adjustments, adjustments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workoutId,userId,trainerId,isShared,status,startedAt,completedAt,durationMinutes,notes,rating,studentFeedback,trainerNotes,const DeepCollectionEquality().hash(sets),const DeepCollectionEquality().hash(messages),const DeepCollectionEquality().hash(adjustments));

@override
String toString() {
  return 'SharedSession(id: $id, workoutId: $workoutId, userId: $userId, trainerId: $trainerId, isShared: $isShared, status: $status, startedAt: $startedAt, completedAt: $completedAt, durationMinutes: $durationMinutes, notes: $notes, rating: $rating, studentFeedback: $studentFeedback, trainerNotes: $trainerNotes, sets: $sets, messages: $messages, adjustments: $adjustments)';
}


}

/// @nodoc
abstract mixin class $SharedSessionCopyWith<$Res>  {
  factory $SharedSessionCopyWith(SharedSession value, $Res Function(SharedSession) _then) = _$SharedSessionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'workout_id') String workoutId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'trainer_id') String? trainerId,@JsonKey(name: 'is_shared') bool isShared, SessionStatus status,@JsonKey(name: 'started_at') DateTime startedAt,@JsonKey(name: 'completed_at') DateTime? completedAt,@JsonKey(name: 'duration_minutes') int? durationMinutes, String? notes, int? rating,@JsonKey(name: 'student_feedback') String? studentFeedback,@JsonKey(name: 'trainer_notes') String? trainerNotes, List<SessionSet> sets, List<SessionMessage> messages, List<TrainerAdjustment> adjustments
});




}
/// @nodoc
class _$SharedSessionCopyWithImpl<$Res>
    implements $SharedSessionCopyWith<$Res> {
  _$SharedSessionCopyWithImpl(this._self, this._then);

  final SharedSession _self;
  final $Res Function(SharedSession) _then;

/// Create a copy of SharedSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workoutId = null,Object? userId = null,Object? trainerId = freezed,Object? isShared = null,Object? status = null,Object? startedAt = null,Object? completedAt = freezed,Object? durationMinutes = freezed,Object? notes = freezed,Object? rating = freezed,Object? studentFeedback = freezed,Object? trainerNotes = freezed,Object? sets = null,Object? messages = null,Object? adjustments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,trainerId: freezed == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String?,isShared: null == isShared ? _self.isShared : isShared // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SessionStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,studentFeedback: freezed == studentFeedback ? _self.studentFeedback : studentFeedback // ignore: cast_nullable_to_non_nullable
as String?,trainerNotes: freezed == trainerNotes ? _self.trainerNotes : trainerNotes // ignore: cast_nullable_to_non_nullable
as String?,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<SessionSet>,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<SessionMessage>,adjustments: null == adjustments ? _self.adjustments : adjustments // ignore: cast_nullable_to_non_nullable
as List<TrainerAdjustment>,
  ));
}

}


/// Adds pattern-matching-related methods to [SharedSession].
extension SharedSessionPatterns on SharedSession {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharedSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharedSession() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharedSession value)  $default,){
final _that = this;
switch (_that) {
case _SharedSession():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharedSession value)?  $default,){
final _that = this;
switch (_that) {
case _SharedSession() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'workout_id')  String workoutId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'trainer_id')  String? trainerId, @JsonKey(name: 'is_shared')  bool isShared,  SessionStatus status, @JsonKey(name: 'started_at')  DateTime startedAt, @JsonKey(name: 'completed_at')  DateTime? completedAt, @JsonKey(name: 'duration_minutes')  int? durationMinutes,  String? notes,  int? rating, @JsonKey(name: 'student_feedback')  String? studentFeedback, @JsonKey(name: 'trainer_notes')  String? trainerNotes,  List<SessionSet> sets,  List<SessionMessage> messages,  List<TrainerAdjustment> adjustments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharedSession() when $default != null:
return $default(_that.id,_that.workoutId,_that.userId,_that.trainerId,_that.isShared,_that.status,_that.startedAt,_that.completedAt,_that.durationMinutes,_that.notes,_that.rating,_that.studentFeedback,_that.trainerNotes,_that.sets,_that.messages,_that.adjustments);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'workout_id')  String workoutId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'trainer_id')  String? trainerId, @JsonKey(name: 'is_shared')  bool isShared,  SessionStatus status, @JsonKey(name: 'started_at')  DateTime startedAt, @JsonKey(name: 'completed_at')  DateTime? completedAt, @JsonKey(name: 'duration_minutes')  int? durationMinutes,  String? notes,  int? rating, @JsonKey(name: 'student_feedback')  String? studentFeedback, @JsonKey(name: 'trainer_notes')  String? trainerNotes,  List<SessionSet> sets,  List<SessionMessage> messages,  List<TrainerAdjustment> adjustments)  $default,) {final _that = this;
switch (_that) {
case _SharedSession():
return $default(_that.id,_that.workoutId,_that.userId,_that.trainerId,_that.isShared,_that.status,_that.startedAt,_that.completedAt,_that.durationMinutes,_that.notes,_that.rating,_that.studentFeedback,_that.trainerNotes,_that.sets,_that.messages,_that.adjustments);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'workout_id')  String workoutId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'trainer_id')  String? trainerId, @JsonKey(name: 'is_shared')  bool isShared,  SessionStatus status, @JsonKey(name: 'started_at')  DateTime startedAt, @JsonKey(name: 'completed_at')  DateTime? completedAt, @JsonKey(name: 'duration_minutes')  int? durationMinutes,  String? notes,  int? rating, @JsonKey(name: 'student_feedback')  String? studentFeedback, @JsonKey(name: 'trainer_notes')  String? trainerNotes,  List<SessionSet> sets,  List<SessionMessage> messages,  List<TrainerAdjustment> adjustments)?  $default,) {final _that = this;
switch (_that) {
case _SharedSession() when $default != null:
return $default(_that.id,_that.workoutId,_that.userId,_that.trainerId,_that.isShared,_that.status,_that.startedAt,_that.completedAt,_that.durationMinutes,_that.notes,_that.rating,_that.studentFeedback,_that.trainerNotes,_that.sets,_that.messages,_that.adjustments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SharedSession extends SharedSession {
  const _SharedSession({required this.id, @JsonKey(name: 'workout_id') required this.workoutId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'trainer_id') this.trainerId, @JsonKey(name: 'is_shared') required this.isShared, required this.status, @JsonKey(name: 'started_at') required this.startedAt, @JsonKey(name: 'completed_at') this.completedAt, @JsonKey(name: 'duration_minutes') this.durationMinutes, this.notes, this.rating, @JsonKey(name: 'student_feedback') this.studentFeedback, @JsonKey(name: 'trainer_notes') this.trainerNotes, final  List<SessionSet> sets = const [], final  List<SessionMessage> messages = const [], final  List<TrainerAdjustment> adjustments = const []}): _sets = sets,_messages = messages,_adjustments = adjustments,super._();
  factory _SharedSession.fromJson(Map<String, dynamic> json) => _$SharedSessionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'workout_id') final  String workoutId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'trainer_id') final  String? trainerId;
@override@JsonKey(name: 'is_shared') final  bool isShared;
@override final  SessionStatus status;
@override@JsonKey(name: 'started_at') final  DateTime startedAt;
@override@JsonKey(name: 'completed_at') final  DateTime? completedAt;
@override@JsonKey(name: 'duration_minutes') final  int? durationMinutes;
@override final  String? notes;
@override final  int? rating;
@override@JsonKey(name: 'student_feedback') final  String? studentFeedback;
@override@JsonKey(name: 'trainer_notes') final  String? trainerNotes;
 final  List<SessionSet> _sets;
@override@JsonKey() List<SessionSet> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}

 final  List<SessionMessage> _messages;
@override@JsonKey() List<SessionMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

 final  List<TrainerAdjustment> _adjustments;
@override@JsonKey() List<TrainerAdjustment> get adjustments {
  if (_adjustments is EqualUnmodifiableListView) return _adjustments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_adjustments);
}


/// Create a copy of SharedSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharedSessionCopyWith<_SharedSession> get copyWith => __$SharedSessionCopyWithImpl<_SharedSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SharedSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharedSession&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.isShared, isShared) || other.isShared == isShared)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.studentFeedback, studentFeedback) || other.studentFeedback == studentFeedback)&&(identical(other.trainerNotes, trainerNotes) || other.trainerNotes == trainerNotes)&&const DeepCollectionEquality().equals(other._sets, _sets)&&const DeepCollectionEquality().equals(other._messages, _messages)&&const DeepCollectionEquality().equals(other._adjustments, _adjustments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workoutId,userId,trainerId,isShared,status,startedAt,completedAt,durationMinutes,notes,rating,studentFeedback,trainerNotes,const DeepCollectionEquality().hash(_sets),const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_adjustments));

@override
String toString() {
  return 'SharedSession(id: $id, workoutId: $workoutId, userId: $userId, trainerId: $trainerId, isShared: $isShared, status: $status, startedAt: $startedAt, completedAt: $completedAt, durationMinutes: $durationMinutes, notes: $notes, rating: $rating, studentFeedback: $studentFeedback, trainerNotes: $trainerNotes, sets: $sets, messages: $messages, adjustments: $adjustments)';
}


}

/// @nodoc
abstract mixin class _$SharedSessionCopyWith<$Res> implements $SharedSessionCopyWith<$Res> {
  factory _$SharedSessionCopyWith(_SharedSession value, $Res Function(_SharedSession) _then) = __$SharedSessionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'workout_id') String workoutId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'trainer_id') String? trainerId,@JsonKey(name: 'is_shared') bool isShared, SessionStatus status,@JsonKey(name: 'started_at') DateTime startedAt,@JsonKey(name: 'completed_at') DateTime? completedAt,@JsonKey(name: 'duration_minutes') int? durationMinutes, String? notes, int? rating,@JsonKey(name: 'student_feedback') String? studentFeedback,@JsonKey(name: 'trainer_notes') String? trainerNotes, List<SessionSet> sets, List<SessionMessage> messages, List<TrainerAdjustment> adjustments
});




}
/// @nodoc
class __$SharedSessionCopyWithImpl<$Res>
    implements _$SharedSessionCopyWith<$Res> {
  __$SharedSessionCopyWithImpl(this._self, this._then);

  final _SharedSession _self;
  final $Res Function(_SharedSession) _then;

/// Create a copy of SharedSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workoutId = null,Object? userId = null,Object? trainerId = freezed,Object? isShared = null,Object? status = null,Object? startedAt = null,Object? completedAt = freezed,Object? durationMinutes = freezed,Object? notes = freezed,Object? rating = freezed,Object? studentFeedback = freezed,Object? trainerNotes = freezed,Object? sets = null,Object? messages = null,Object? adjustments = null,}) {
  return _then(_SharedSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,trainerId: freezed == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String?,isShared: null == isShared ? _self.isShared : isShared // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SessionStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,studentFeedback: freezed == studentFeedback ? _self.studentFeedback : studentFeedback // ignore: cast_nullable_to_non_nullable
as String?,trainerNotes: freezed == trainerNotes ? _self.trainerNotes : trainerNotes // ignore: cast_nullable_to_non_nullable
as String?,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<SessionSet>,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<SessionMessage>,adjustments: null == adjustments ? _self._adjustments : adjustments // ignore: cast_nullable_to_non_nullable
as List<TrainerAdjustment>,
  ));
}


}


/// @nodoc
mixin _$SessionSet {

 String get id;@JsonKey(name: 'exercise_id') String get exerciseId;@JsonKey(name: 'set_number') int get setNumber;@JsonKey(name: 'reps_completed') int get repsCompleted;@JsonKey(name: 'weight_kg') double? get weightKg;@JsonKey(name: 'duration_seconds') int? get durationSeconds; String? get notes;@JsonKey(name: 'performed_at') DateTime get performedAt;
/// Create a copy of SessionSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionSetCopyWith<SessionSet> get copyWith => _$SessionSetCopyWithImpl<SessionSet>(this as SessionSet, _$identity);

  /// Serializes this SessionSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionSet&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.repsCompleted, repsCompleted) || other.repsCompleted == repsCompleted)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.performedAt, performedAt) || other.performedAt == performedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,setNumber,repsCompleted,weightKg,durationSeconds,notes,performedAt);

@override
String toString() {
  return 'SessionSet(id: $id, exerciseId: $exerciseId, setNumber: $setNumber, repsCompleted: $repsCompleted, weightKg: $weightKg, durationSeconds: $durationSeconds, notes: $notes, performedAt: $performedAt)';
}


}

/// @nodoc
abstract mixin class $SessionSetCopyWith<$Res>  {
  factory $SessionSetCopyWith(SessionSet value, $Res Function(SessionSet) _then) = _$SessionSetCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'exercise_id') String exerciseId,@JsonKey(name: 'set_number') int setNumber,@JsonKey(name: 'reps_completed') int repsCompleted,@JsonKey(name: 'weight_kg') double? weightKg,@JsonKey(name: 'duration_seconds') int? durationSeconds, String? notes,@JsonKey(name: 'performed_at') DateTime performedAt
});




}
/// @nodoc
class _$SessionSetCopyWithImpl<$Res>
    implements $SessionSetCopyWith<$Res> {
  _$SessionSetCopyWithImpl(this._self, this._then);

  final SessionSet _self;
  final $Res Function(SessionSet) _then;

/// Create a copy of SessionSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? setNumber = null,Object? repsCompleted = null,Object? weightKg = freezed,Object? durationSeconds = freezed,Object? notes = freezed,Object? performedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,repsCompleted: null == repsCompleted ? _self.repsCompleted : repsCompleted // ignore: cast_nullable_to_non_nullable
as int,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,performedAt: null == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionSet].
extension SessionSetPatterns on SessionSet {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionSet() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionSet value)  $default,){
final _that = this;
switch (_that) {
case _SessionSet():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionSet value)?  $default,){
final _that = this;
switch (_that) {
case _SessionSet() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'set_number')  int setNumber, @JsonKey(name: 'reps_completed')  int repsCompleted, @JsonKey(name: 'weight_kg')  double? weightKg, @JsonKey(name: 'duration_seconds')  int? durationSeconds,  String? notes, @JsonKey(name: 'performed_at')  DateTime performedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionSet() when $default != null:
return $default(_that.id,_that.exerciseId,_that.setNumber,_that.repsCompleted,_that.weightKg,_that.durationSeconds,_that.notes,_that.performedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'set_number')  int setNumber, @JsonKey(name: 'reps_completed')  int repsCompleted, @JsonKey(name: 'weight_kg')  double? weightKg, @JsonKey(name: 'duration_seconds')  int? durationSeconds,  String? notes, @JsonKey(name: 'performed_at')  DateTime performedAt)  $default,) {final _that = this;
switch (_that) {
case _SessionSet():
return $default(_that.id,_that.exerciseId,_that.setNumber,_that.repsCompleted,_that.weightKg,_that.durationSeconds,_that.notes,_that.performedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'set_number')  int setNumber, @JsonKey(name: 'reps_completed')  int repsCompleted, @JsonKey(name: 'weight_kg')  double? weightKg, @JsonKey(name: 'duration_seconds')  int? durationSeconds,  String? notes, @JsonKey(name: 'performed_at')  DateTime performedAt)?  $default,) {final _that = this;
switch (_that) {
case _SessionSet() when $default != null:
return $default(_that.id,_that.exerciseId,_that.setNumber,_that.repsCompleted,_that.weightKg,_that.durationSeconds,_that.notes,_that.performedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionSet extends SessionSet {
  const _SessionSet({required this.id, @JsonKey(name: 'exercise_id') required this.exerciseId, @JsonKey(name: 'set_number') required this.setNumber, @JsonKey(name: 'reps_completed') required this.repsCompleted, @JsonKey(name: 'weight_kg') this.weightKg, @JsonKey(name: 'duration_seconds') this.durationSeconds, this.notes, @JsonKey(name: 'performed_at') required this.performedAt}): super._();
  factory _SessionSet.fromJson(Map<String, dynamic> json) => _$SessionSetFromJson(json);

@override final  String id;
@override@JsonKey(name: 'exercise_id') final  String exerciseId;
@override@JsonKey(name: 'set_number') final  int setNumber;
@override@JsonKey(name: 'reps_completed') final  int repsCompleted;
@override@JsonKey(name: 'weight_kg') final  double? weightKg;
@override@JsonKey(name: 'duration_seconds') final  int? durationSeconds;
@override final  String? notes;
@override@JsonKey(name: 'performed_at') final  DateTime performedAt;

/// Create a copy of SessionSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionSetCopyWith<_SessionSet> get copyWith => __$SessionSetCopyWithImpl<_SessionSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionSetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionSet&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.repsCompleted, repsCompleted) || other.repsCompleted == repsCompleted)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.performedAt, performedAt) || other.performedAt == performedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,setNumber,repsCompleted,weightKg,durationSeconds,notes,performedAt);

@override
String toString() {
  return 'SessionSet(id: $id, exerciseId: $exerciseId, setNumber: $setNumber, repsCompleted: $repsCompleted, weightKg: $weightKg, durationSeconds: $durationSeconds, notes: $notes, performedAt: $performedAt)';
}


}

/// @nodoc
abstract mixin class _$SessionSetCopyWith<$Res> implements $SessionSetCopyWith<$Res> {
  factory _$SessionSetCopyWith(_SessionSet value, $Res Function(_SessionSet) _then) = __$SessionSetCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'exercise_id') String exerciseId,@JsonKey(name: 'set_number') int setNumber,@JsonKey(name: 'reps_completed') int repsCompleted,@JsonKey(name: 'weight_kg') double? weightKg,@JsonKey(name: 'duration_seconds') int? durationSeconds, String? notes,@JsonKey(name: 'performed_at') DateTime performedAt
});




}
/// @nodoc
class __$SessionSetCopyWithImpl<$Res>
    implements _$SessionSetCopyWith<$Res> {
  __$SessionSetCopyWithImpl(this._self, this._then);

  final _SessionSet _self;
  final $Res Function(_SessionSet) _then;

/// Create a copy of SessionSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? setNumber = null,Object? repsCompleted = null,Object? weightKg = freezed,Object? durationSeconds = freezed,Object? notes = freezed,Object? performedAt = null,}) {
  return _then(_SessionSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,repsCompleted: null == repsCompleted ? _self.repsCompleted : repsCompleted // ignore: cast_nullable_to_non_nullable
as int,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,performedAt: null == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$SessionMessage {

 String get id;@JsonKey(name: 'session_id') String get sessionId;@JsonKey(name: 'sender_id') String get senderId;@JsonKey(name: 'sender_name') String? get senderName; String get message;@JsonKey(name: 'sent_at') DateTime get sentAt;@JsonKey(name: 'is_read') bool get isRead;
/// Create a copy of SessionMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionMessageCopyWith<SessionMessage> get copyWith => _$SessionMessageCopyWithImpl<SessionMessage>(this as SessionMessage, _$identity);

  /// Serializes this SessionMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.message, message) || other.message == message)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,senderId,senderName,message,sentAt,isRead);

@override
String toString() {
  return 'SessionMessage(id: $id, sessionId: $sessionId, senderId: $senderId, senderName: $senderName, message: $message, sentAt: $sentAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class $SessionMessageCopyWith<$Res>  {
  factory $SessionMessageCopyWith(SessionMessage value, $Res Function(SessionMessage) _then) = _$SessionMessageCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'sender_id') String senderId,@JsonKey(name: 'sender_name') String? senderName, String message,@JsonKey(name: 'sent_at') DateTime sentAt,@JsonKey(name: 'is_read') bool isRead
});




}
/// @nodoc
class _$SessionMessageCopyWithImpl<$Res>
    implements $SessionMessageCopyWith<$Res> {
  _$SessionMessageCopyWithImpl(this._self, this._then);

  final SessionMessage _self;
  final $Res Function(SessionMessage) _then;

/// Create a copy of SessionMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? senderId = null,Object? senderName = freezed,Object? message = null,Object? sentAt = null,Object? isRead = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionMessage].
extension SessionMessagePatterns on SessionMessage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionMessage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionMessage value)  $default,){
final _that = this;
switch (_that) {
case _SessionMessage():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionMessage value)?  $default,){
final _that = this;
switch (_that) {
case _SessionMessage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'sender_id')  String senderId, @JsonKey(name: 'sender_name')  String? senderName,  String message, @JsonKey(name: 'sent_at')  DateTime sentAt, @JsonKey(name: 'is_read')  bool isRead)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionMessage() when $default != null:
return $default(_that.id,_that.sessionId,_that.senderId,_that.senderName,_that.message,_that.sentAt,_that.isRead);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'sender_id')  String senderId, @JsonKey(name: 'sender_name')  String? senderName,  String message, @JsonKey(name: 'sent_at')  DateTime sentAt, @JsonKey(name: 'is_read')  bool isRead)  $default,) {final _that = this;
switch (_that) {
case _SessionMessage():
return $default(_that.id,_that.sessionId,_that.senderId,_that.senderName,_that.message,_that.sentAt,_that.isRead);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'sender_id')  String senderId, @JsonKey(name: 'sender_name')  String? senderName,  String message, @JsonKey(name: 'sent_at')  DateTime sentAt, @JsonKey(name: 'is_read')  bool isRead)?  $default,) {final _that = this;
switch (_that) {
case _SessionMessage() when $default != null:
return $default(_that.id,_that.sessionId,_that.senderId,_that.senderName,_that.message,_that.sentAt,_that.isRead);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionMessage extends SessionMessage {
  const _SessionMessage({required this.id, @JsonKey(name: 'session_id') required this.sessionId, @JsonKey(name: 'sender_id') required this.senderId, @JsonKey(name: 'sender_name') this.senderName, required this.message, @JsonKey(name: 'sent_at') required this.sentAt, @JsonKey(name: 'is_read') this.isRead = false}): super._();
  factory _SessionMessage.fromJson(Map<String, dynamic> json) => _$SessionMessageFromJson(json);

@override final  String id;
@override@JsonKey(name: 'session_id') final  String sessionId;
@override@JsonKey(name: 'sender_id') final  String senderId;
@override@JsonKey(name: 'sender_name') final  String? senderName;
@override final  String message;
@override@JsonKey(name: 'sent_at') final  DateTime sentAt;
@override@JsonKey(name: 'is_read') final  bool isRead;

/// Create a copy of SessionMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionMessageCopyWith<_SessionMessage> get copyWith => __$SessionMessageCopyWithImpl<_SessionMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.message, message) || other.message == message)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,senderId,senderName,message,sentAt,isRead);

@override
String toString() {
  return 'SessionMessage(id: $id, sessionId: $sessionId, senderId: $senderId, senderName: $senderName, message: $message, sentAt: $sentAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class _$SessionMessageCopyWith<$Res> implements $SessionMessageCopyWith<$Res> {
  factory _$SessionMessageCopyWith(_SessionMessage value, $Res Function(_SessionMessage) _then) = __$SessionMessageCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'sender_id') String senderId,@JsonKey(name: 'sender_name') String? senderName, String message,@JsonKey(name: 'sent_at') DateTime sentAt,@JsonKey(name: 'is_read') bool isRead
});




}
/// @nodoc
class __$SessionMessageCopyWithImpl<$Res>
    implements _$SessionMessageCopyWith<$Res> {
  __$SessionMessageCopyWithImpl(this._self, this._then);

  final _SessionMessage _self;
  final $Res Function(_SessionMessage) _then;

/// Create a copy of SessionMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? senderId = null,Object? senderName = freezed,Object? message = null,Object? sentAt = null,Object? isRead = null,}) {
  return _then(_SessionMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TrainerAdjustment {

 String get id;@JsonKey(name: 'session_id') String get sessionId;@JsonKey(name: 'trainer_id') String get trainerId;@JsonKey(name: 'exercise_id') String get exerciseId;@JsonKey(name: 'set_number') int? get setNumber;@JsonKey(name: 'suggested_weight_kg') double? get suggestedWeightKg;@JsonKey(name: 'suggested_reps') int? get suggestedReps; String? get note;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of TrainerAdjustment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerAdjustmentCopyWith<TrainerAdjustment> get copyWith => _$TrainerAdjustmentCopyWithImpl<TrainerAdjustment>(this as TrainerAdjustment, _$identity);

  /// Serializes this TrainerAdjustment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerAdjustment&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.suggestedWeightKg, suggestedWeightKg) || other.suggestedWeightKg == suggestedWeightKg)&&(identical(other.suggestedReps, suggestedReps) || other.suggestedReps == suggestedReps)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,trainerId,exerciseId,setNumber,suggestedWeightKg,suggestedReps,note,createdAt);

@override
String toString() {
  return 'TrainerAdjustment(id: $id, sessionId: $sessionId, trainerId: $trainerId, exerciseId: $exerciseId, setNumber: $setNumber, suggestedWeightKg: $suggestedWeightKg, suggestedReps: $suggestedReps, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TrainerAdjustmentCopyWith<$Res>  {
  factory $TrainerAdjustmentCopyWith(TrainerAdjustment value, $Res Function(TrainerAdjustment) _then) = _$TrainerAdjustmentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'trainer_id') String trainerId,@JsonKey(name: 'exercise_id') String exerciseId,@JsonKey(name: 'set_number') int? setNumber,@JsonKey(name: 'suggested_weight_kg') double? suggestedWeightKg,@JsonKey(name: 'suggested_reps') int? suggestedReps, String? note,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$TrainerAdjustmentCopyWithImpl<$Res>
    implements $TrainerAdjustmentCopyWith<$Res> {
  _$TrainerAdjustmentCopyWithImpl(this._self, this._then);

  final TrainerAdjustment _self;
  final $Res Function(TrainerAdjustment) _then;

/// Create a copy of TrainerAdjustment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? trainerId = null,Object? exerciseId = null,Object? setNumber = freezed,Object? suggestedWeightKg = freezed,Object? suggestedReps = freezed,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,setNumber: freezed == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int?,suggestedWeightKg: freezed == suggestedWeightKg ? _self.suggestedWeightKg : suggestedWeightKg // ignore: cast_nullable_to_non_nullable
as double?,suggestedReps: freezed == suggestedReps ? _self.suggestedReps : suggestedReps // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerAdjustment].
extension TrainerAdjustmentPatterns on TrainerAdjustment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerAdjustment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerAdjustment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerAdjustment value)  $default,){
final _that = this;
switch (_that) {
case _TrainerAdjustment():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerAdjustment value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerAdjustment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'trainer_id')  String trainerId, @JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'set_number')  int? setNumber, @JsonKey(name: 'suggested_weight_kg')  double? suggestedWeightKg, @JsonKey(name: 'suggested_reps')  int? suggestedReps,  String? note, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerAdjustment() when $default != null:
return $default(_that.id,_that.sessionId,_that.trainerId,_that.exerciseId,_that.setNumber,_that.suggestedWeightKg,_that.suggestedReps,_that.note,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'trainer_id')  String trainerId, @JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'set_number')  int? setNumber, @JsonKey(name: 'suggested_weight_kg')  double? suggestedWeightKg, @JsonKey(name: 'suggested_reps')  int? suggestedReps,  String? note, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TrainerAdjustment():
return $default(_that.id,_that.sessionId,_that.trainerId,_that.exerciseId,_that.setNumber,_that.suggestedWeightKg,_that.suggestedReps,_that.note,_that.createdAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'trainer_id')  String trainerId, @JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'set_number')  int? setNumber, @JsonKey(name: 'suggested_weight_kg')  double? suggestedWeightKg, @JsonKey(name: 'suggested_reps')  int? suggestedReps,  String? note, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TrainerAdjustment() when $default != null:
return $default(_that.id,_that.sessionId,_that.trainerId,_that.exerciseId,_that.setNumber,_that.suggestedWeightKg,_that.suggestedReps,_that.note,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerAdjustment extends TrainerAdjustment {
  const _TrainerAdjustment({required this.id, @JsonKey(name: 'session_id') required this.sessionId, @JsonKey(name: 'trainer_id') required this.trainerId, @JsonKey(name: 'exercise_id') required this.exerciseId, @JsonKey(name: 'set_number') this.setNumber, @JsonKey(name: 'suggested_weight_kg') this.suggestedWeightKg, @JsonKey(name: 'suggested_reps') this.suggestedReps, this.note, @JsonKey(name: 'created_at') required this.createdAt}): super._();
  factory _TrainerAdjustment.fromJson(Map<String, dynamic> json) => _$TrainerAdjustmentFromJson(json);

@override final  String id;
@override@JsonKey(name: 'session_id') final  String sessionId;
@override@JsonKey(name: 'trainer_id') final  String trainerId;
@override@JsonKey(name: 'exercise_id') final  String exerciseId;
@override@JsonKey(name: 'set_number') final  int? setNumber;
@override@JsonKey(name: 'suggested_weight_kg') final  double? suggestedWeightKg;
@override@JsonKey(name: 'suggested_reps') final  int? suggestedReps;
@override final  String? note;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of TrainerAdjustment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerAdjustmentCopyWith<_TrainerAdjustment> get copyWith => __$TrainerAdjustmentCopyWithImpl<_TrainerAdjustment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerAdjustmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerAdjustment&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.suggestedWeightKg, suggestedWeightKg) || other.suggestedWeightKg == suggestedWeightKg)&&(identical(other.suggestedReps, suggestedReps) || other.suggestedReps == suggestedReps)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,trainerId,exerciseId,setNumber,suggestedWeightKg,suggestedReps,note,createdAt);

@override
String toString() {
  return 'TrainerAdjustment(id: $id, sessionId: $sessionId, trainerId: $trainerId, exerciseId: $exerciseId, setNumber: $setNumber, suggestedWeightKg: $suggestedWeightKg, suggestedReps: $suggestedReps, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TrainerAdjustmentCopyWith<$Res> implements $TrainerAdjustmentCopyWith<$Res> {
  factory _$TrainerAdjustmentCopyWith(_TrainerAdjustment value, $Res Function(_TrainerAdjustment) _then) = __$TrainerAdjustmentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'trainer_id') String trainerId,@JsonKey(name: 'exercise_id') String exerciseId,@JsonKey(name: 'set_number') int? setNumber,@JsonKey(name: 'suggested_weight_kg') double? suggestedWeightKg,@JsonKey(name: 'suggested_reps') int? suggestedReps, String? note,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$TrainerAdjustmentCopyWithImpl<$Res>
    implements _$TrainerAdjustmentCopyWith<$Res> {
  __$TrainerAdjustmentCopyWithImpl(this._self, this._then);

  final _TrainerAdjustment _self;
  final $Res Function(_TrainerAdjustment) _then;

/// Create a copy of TrainerAdjustment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? trainerId = null,Object? exerciseId = null,Object? setNumber = freezed,Object? suggestedWeightKg = freezed,Object? suggestedReps = freezed,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_TrainerAdjustment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,setNumber: freezed == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int?,suggestedWeightKg: freezed == suggestedWeightKg ? _self.suggestedWeightKg : suggestedWeightKg // ignore: cast_nullable_to_non_nullable
as double?,suggestedReps: freezed == suggestedReps ? _self.suggestedReps : suggestedReps // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$SessionEvent {

@JsonKey(name: 'event_type') SessionEventType get eventType;@JsonKey(name: 'session_id') String get sessionId; Map<String, dynamic> get data;@JsonKey(name: 'sender_id') String? get senderId; DateTime get timestamp;
/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionEventCopyWith<SessionEvent> get copyWith => _$SessionEventCopyWithImpl<SessionEvent>(this as SessionEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionEvent&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,eventType,sessionId,const DeepCollectionEquality().hash(data),senderId,timestamp);

@override
String toString() {
  return 'SessionEvent(eventType: $eventType, sessionId: $sessionId, data: $data, senderId: $senderId, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $SessionEventCopyWith<$Res>  {
  factory $SessionEventCopyWith(SessionEvent value, $Res Function(SessionEvent) _then) = _$SessionEventCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'event_type') SessionEventType eventType,@JsonKey(name: 'session_id') String sessionId, Map<String, dynamic> data,@JsonKey(name: 'sender_id') String? senderId, DateTime timestamp
});




}
/// @nodoc
class _$SessionEventCopyWithImpl<$Res>
    implements $SessionEventCopyWith<$Res> {
  _$SessionEventCopyWithImpl(this._self, this._then);

  final SessionEvent _self;
  final $Res Function(SessionEvent) _then;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventType = null,Object? sessionId = null,Object? data = null,Object? senderId = freezed,Object? timestamp = null,}) {
  return _then(_self.copyWith(
eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as SessionEventType,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionEvent].
extension SessionEventPatterns on SessionEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionEvent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionEvent value)  $default,){
final _that = this;
switch (_that) {
case _SessionEvent():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionEvent value)?  $default,){
final _that = this;
switch (_that) {
case _SessionEvent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'event_type')  SessionEventType eventType, @JsonKey(name: 'session_id')  String sessionId,  Map<String, dynamic> data, @JsonKey(name: 'sender_id')  String? senderId,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionEvent() when $default != null:
return $default(_that.eventType,_that.sessionId,_that.data,_that.senderId,_that.timestamp);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'event_type')  SessionEventType eventType, @JsonKey(name: 'session_id')  String sessionId,  Map<String, dynamic> data, @JsonKey(name: 'sender_id')  String? senderId,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _SessionEvent():
return $default(_that.eventType,_that.sessionId,_that.data,_that.senderId,_that.timestamp);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'event_type')  SessionEventType eventType, @JsonKey(name: 'session_id')  String sessionId,  Map<String, dynamic> data, @JsonKey(name: 'sender_id')  String? senderId,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _SessionEvent() when $default != null:
return $default(_that.eventType,_that.sessionId,_that.data,_that.senderId,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc


class _SessionEvent extends SessionEvent {
  const _SessionEvent({@JsonKey(name: 'event_type') required this.eventType, @JsonKey(name: 'session_id') required this.sessionId, required final  Map<String, dynamic> data, @JsonKey(name: 'sender_id') this.senderId, required this.timestamp}): _data = data,super._();
  

@override@JsonKey(name: 'event_type') final  SessionEventType eventType;
@override@JsonKey(name: 'session_id') final  String sessionId;
 final  Map<String, dynamic> _data;
@override Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}

@override@JsonKey(name: 'sender_id') final  String? senderId;
@override final  DateTime timestamp;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionEventCopyWith<_SessionEvent> get copyWith => __$SessionEventCopyWithImpl<_SessionEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionEvent&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,eventType,sessionId,const DeepCollectionEquality().hash(_data),senderId,timestamp);

@override
String toString() {
  return 'SessionEvent(eventType: $eventType, sessionId: $sessionId, data: $data, senderId: $senderId, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$SessionEventCopyWith<$Res> implements $SessionEventCopyWith<$Res> {
  factory _$SessionEventCopyWith(_SessionEvent value, $Res Function(_SessionEvent) _then) = __$SessionEventCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'event_type') SessionEventType eventType,@JsonKey(name: 'session_id') String sessionId, Map<String, dynamic> data,@JsonKey(name: 'sender_id') String? senderId, DateTime timestamp
});




}
/// @nodoc
class __$SessionEventCopyWithImpl<$Res>
    implements _$SessionEventCopyWith<$Res> {
  __$SessionEventCopyWithImpl(this._self, this._then);

  final _SessionEvent _self;
  final $Res Function(_SessionEvent) _then;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventType = null,Object? sessionId = null,Object? data = null,Object? senderId = freezed,Object? timestamp = null,}) {
  return _then(_SessionEvent(
eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as SessionEventType,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ActiveSession {

 String get id;@JsonKey(name: 'workout_id') String get workoutId;@JsonKey(name: 'workout_name') String get workoutName;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'student_name') String get studentName;@JsonKey(name: 'student_avatar') String? get studentAvatar;@JsonKey(name: 'trainer_id') String? get trainerId;@JsonKey(name: 'is_shared') bool get isShared; SessionStatus get status;@JsonKey(name: 'started_at') DateTime get startedAt;@JsonKey(name: 'current_exercise_index') int get currentExerciseIndex;@JsonKey(name: 'total_exercises') int get totalExercises;@JsonKey(name: 'completed_sets') int get completedSets;
/// Create a copy of ActiveSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActiveSessionCopyWith<ActiveSession> get copyWith => _$ActiveSessionCopyWithImpl<ActiveSession>(this as ActiveSession, _$identity);

  /// Serializes this ActiveSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActiveSession&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.workoutName, workoutName) || other.workoutName == workoutName)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentAvatar, studentAvatar) || other.studentAvatar == studentAvatar)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.isShared, isShared) || other.isShared == isShared)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.currentExerciseIndex, currentExerciseIndex) || other.currentExerciseIndex == currentExerciseIndex)&&(identical(other.totalExercises, totalExercises) || other.totalExercises == totalExercises)&&(identical(other.completedSets, completedSets) || other.completedSets == completedSets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workoutId,workoutName,userId,studentName,studentAvatar,trainerId,isShared,status,startedAt,currentExerciseIndex,totalExercises,completedSets);

@override
String toString() {
  return 'ActiveSession(id: $id, workoutId: $workoutId, workoutName: $workoutName, userId: $userId, studentName: $studentName, studentAvatar: $studentAvatar, trainerId: $trainerId, isShared: $isShared, status: $status, startedAt: $startedAt, currentExerciseIndex: $currentExerciseIndex, totalExercises: $totalExercises, completedSets: $completedSets)';
}


}

/// @nodoc
abstract mixin class $ActiveSessionCopyWith<$Res>  {
  factory $ActiveSessionCopyWith(ActiveSession value, $Res Function(ActiveSession) _then) = _$ActiveSessionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'workout_id') String workoutId,@JsonKey(name: 'workout_name') String workoutName,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'student_name') String studentName,@JsonKey(name: 'student_avatar') String? studentAvatar,@JsonKey(name: 'trainer_id') String? trainerId,@JsonKey(name: 'is_shared') bool isShared, SessionStatus status,@JsonKey(name: 'started_at') DateTime startedAt,@JsonKey(name: 'current_exercise_index') int currentExerciseIndex,@JsonKey(name: 'total_exercises') int totalExercises,@JsonKey(name: 'completed_sets') int completedSets
});




}
/// @nodoc
class _$ActiveSessionCopyWithImpl<$Res>
    implements $ActiveSessionCopyWith<$Res> {
  _$ActiveSessionCopyWithImpl(this._self, this._then);

  final ActiveSession _self;
  final $Res Function(ActiveSession) _then;

/// Create a copy of ActiveSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workoutId = null,Object? workoutName = null,Object? userId = null,Object? studentName = null,Object? studentAvatar = freezed,Object? trainerId = freezed,Object? isShared = null,Object? status = null,Object? startedAt = null,Object? currentExerciseIndex = null,Object? totalExercises = null,Object? completedSets = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,workoutName: null == workoutName ? _self.workoutName : workoutName // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,studentName: null == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String,studentAvatar: freezed == studentAvatar ? _self.studentAvatar : studentAvatar // ignore: cast_nullable_to_non_nullable
as String?,trainerId: freezed == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String?,isShared: null == isShared ? _self.isShared : isShared // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SessionStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,currentExerciseIndex: null == currentExerciseIndex ? _self.currentExerciseIndex : currentExerciseIndex // ignore: cast_nullable_to_non_nullable
as int,totalExercises: null == totalExercises ? _self.totalExercises : totalExercises // ignore: cast_nullable_to_non_nullable
as int,completedSets: null == completedSets ? _self.completedSets : completedSets // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ActiveSession].
extension ActiveSessionPatterns on ActiveSession {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActiveSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActiveSession() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActiveSession value)  $default,){
final _that = this;
switch (_that) {
case _ActiveSession():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActiveSession value)?  $default,){
final _that = this;
switch (_that) {
case _ActiveSession() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'workout_id')  String workoutId, @JsonKey(name: 'workout_name')  String workoutName, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'student_name')  String studentName, @JsonKey(name: 'student_avatar')  String? studentAvatar, @JsonKey(name: 'trainer_id')  String? trainerId, @JsonKey(name: 'is_shared')  bool isShared,  SessionStatus status, @JsonKey(name: 'started_at')  DateTime startedAt, @JsonKey(name: 'current_exercise_index')  int currentExerciseIndex, @JsonKey(name: 'total_exercises')  int totalExercises, @JsonKey(name: 'completed_sets')  int completedSets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActiveSession() when $default != null:
return $default(_that.id,_that.workoutId,_that.workoutName,_that.userId,_that.studentName,_that.studentAvatar,_that.trainerId,_that.isShared,_that.status,_that.startedAt,_that.currentExerciseIndex,_that.totalExercises,_that.completedSets);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'workout_id')  String workoutId, @JsonKey(name: 'workout_name')  String workoutName, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'student_name')  String studentName, @JsonKey(name: 'student_avatar')  String? studentAvatar, @JsonKey(name: 'trainer_id')  String? trainerId, @JsonKey(name: 'is_shared')  bool isShared,  SessionStatus status, @JsonKey(name: 'started_at')  DateTime startedAt, @JsonKey(name: 'current_exercise_index')  int currentExerciseIndex, @JsonKey(name: 'total_exercises')  int totalExercises, @JsonKey(name: 'completed_sets')  int completedSets)  $default,) {final _that = this;
switch (_that) {
case _ActiveSession():
return $default(_that.id,_that.workoutId,_that.workoutName,_that.userId,_that.studentName,_that.studentAvatar,_that.trainerId,_that.isShared,_that.status,_that.startedAt,_that.currentExerciseIndex,_that.totalExercises,_that.completedSets);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'workout_id')  String workoutId, @JsonKey(name: 'workout_name')  String workoutName, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'student_name')  String studentName, @JsonKey(name: 'student_avatar')  String? studentAvatar, @JsonKey(name: 'trainer_id')  String? trainerId, @JsonKey(name: 'is_shared')  bool isShared,  SessionStatus status, @JsonKey(name: 'started_at')  DateTime startedAt, @JsonKey(name: 'current_exercise_index')  int currentExerciseIndex, @JsonKey(name: 'total_exercises')  int totalExercises, @JsonKey(name: 'completed_sets')  int completedSets)?  $default,) {final _that = this;
switch (_that) {
case _ActiveSession() when $default != null:
return $default(_that.id,_that.workoutId,_that.workoutName,_that.userId,_that.studentName,_that.studentAvatar,_that.trainerId,_that.isShared,_that.status,_that.startedAt,_that.currentExerciseIndex,_that.totalExercises,_that.completedSets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActiveSession extends ActiveSession {
  const _ActiveSession({required this.id, @JsonKey(name: 'workout_id') required this.workoutId, @JsonKey(name: 'workout_name') required this.workoutName, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'student_name') required this.studentName, @JsonKey(name: 'student_avatar') this.studentAvatar, @JsonKey(name: 'trainer_id') this.trainerId, @JsonKey(name: 'is_shared') required this.isShared, required this.status, @JsonKey(name: 'started_at') required this.startedAt, @JsonKey(name: 'current_exercise_index') this.currentExerciseIndex = 0, @JsonKey(name: 'total_exercises') this.totalExercises = 0, @JsonKey(name: 'completed_sets') this.completedSets = 0}): super._();
  factory _ActiveSession.fromJson(Map<String, dynamic> json) => _$ActiveSessionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'workout_id') final  String workoutId;
@override@JsonKey(name: 'workout_name') final  String workoutName;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'student_name') final  String studentName;
@override@JsonKey(name: 'student_avatar') final  String? studentAvatar;
@override@JsonKey(name: 'trainer_id') final  String? trainerId;
@override@JsonKey(name: 'is_shared') final  bool isShared;
@override final  SessionStatus status;
@override@JsonKey(name: 'started_at') final  DateTime startedAt;
@override@JsonKey(name: 'current_exercise_index') final  int currentExerciseIndex;
@override@JsonKey(name: 'total_exercises') final  int totalExercises;
@override@JsonKey(name: 'completed_sets') final  int completedSets;

/// Create a copy of ActiveSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActiveSessionCopyWith<_ActiveSession> get copyWith => __$ActiveSessionCopyWithImpl<_ActiveSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActiveSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActiveSession&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.workoutName, workoutName) || other.workoutName == workoutName)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentAvatar, studentAvatar) || other.studentAvatar == studentAvatar)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.isShared, isShared) || other.isShared == isShared)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.currentExerciseIndex, currentExerciseIndex) || other.currentExerciseIndex == currentExerciseIndex)&&(identical(other.totalExercises, totalExercises) || other.totalExercises == totalExercises)&&(identical(other.completedSets, completedSets) || other.completedSets == completedSets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workoutId,workoutName,userId,studentName,studentAvatar,trainerId,isShared,status,startedAt,currentExerciseIndex,totalExercises,completedSets);

@override
String toString() {
  return 'ActiveSession(id: $id, workoutId: $workoutId, workoutName: $workoutName, userId: $userId, studentName: $studentName, studentAvatar: $studentAvatar, trainerId: $trainerId, isShared: $isShared, status: $status, startedAt: $startedAt, currentExerciseIndex: $currentExerciseIndex, totalExercises: $totalExercises, completedSets: $completedSets)';
}


}

/// @nodoc
abstract mixin class _$ActiveSessionCopyWith<$Res> implements $ActiveSessionCopyWith<$Res> {
  factory _$ActiveSessionCopyWith(_ActiveSession value, $Res Function(_ActiveSession) _then) = __$ActiveSessionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'workout_id') String workoutId,@JsonKey(name: 'workout_name') String workoutName,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'student_name') String studentName,@JsonKey(name: 'student_avatar') String? studentAvatar,@JsonKey(name: 'trainer_id') String? trainerId,@JsonKey(name: 'is_shared') bool isShared, SessionStatus status,@JsonKey(name: 'started_at') DateTime startedAt,@JsonKey(name: 'current_exercise_index') int currentExerciseIndex,@JsonKey(name: 'total_exercises') int totalExercises,@JsonKey(name: 'completed_sets') int completedSets
});




}
/// @nodoc
class __$ActiveSessionCopyWithImpl<$Res>
    implements _$ActiveSessionCopyWith<$Res> {
  __$ActiveSessionCopyWithImpl(this._self, this._then);

  final _ActiveSession _self;
  final $Res Function(_ActiveSession) _then;

/// Create a copy of ActiveSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workoutId = null,Object? workoutName = null,Object? userId = null,Object? studentName = null,Object? studentAvatar = freezed,Object? trainerId = freezed,Object? isShared = null,Object? status = null,Object? startedAt = null,Object? currentExerciseIndex = null,Object? totalExercises = null,Object? completedSets = null,}) {
  return _then(_ActiveSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,workoutName: null == workoutName ? _self.workoutName : workoutName // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,studentName: null == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String,studentAvatar: freezed == studentAvatar ? _self.studentAvatar : studentAvatar // ignore: cast_nullable_to_non_nullable
as String?,trainerId: freezed == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String?,isShared: null == isShared ? _self.isShared : isShared // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SessionStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,currentExerciseIndex: null == currentExerciseIndex ? _self.currentExerciseIndex : currentExerciseIndex // ignore: cast_nullable_to_non_nullable
as int,totalExercises: null == totalExercises ? _self.totalExercises : totalExercises // ignore: cast_nullable_to_non_nullable
as int,completedSets: null == completedSets ? _self.completedSets : completedSets // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
