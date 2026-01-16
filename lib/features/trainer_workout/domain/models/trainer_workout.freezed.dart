// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_workout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainerWorkout {

 String get id;// === Quem criou ===
 String get trainerId; String get trainerName;// === Para quem ===
 String get studentId; String get studentName; String? get studentAvatarUrl;// === Info básica ===
 String get name; String? get description; WorkoutDifficulty get difficulty; WorkoutAssignmentStatus get status;// === Exercícios ===
 List<WorkoutExercise> get exercises;// === Periodização ===
 PeriodizationType get periodization; int? get weekNumber; int? get totalWeeks; String? get phase;// Ex: "Hipertrofia", "Força", "Cutting"
// === Datas ===
 DateTime get createdAt; DateTime? get updatedAt; DateTime? get startDate; DateTime? get endDate;// === Métricas ===
 int get totalSessions; int get completedSessions; int get estimatedDurationMinutes;// === Notas ===
 String? get trainerNotes; String? get studentFeedback;// === IA ===
 bool get aiGenerated; String? get aiSuggestionId;// === Versioning ===
 int get version; String? get previousVersionId;
/// Create a copy of TrainerWorkout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerWorkoutCopyWith<TrainerWorkout> get copyWith => _$TrainerWorkoutCopyWithImpl<TrainerWorkout>(this as TrainerWorkout, _$identity);

  /// Serializes this TrainerWorkout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.trainerName, trainerName) || other.trainerName == trainerName)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentAvatarUrl, studentAvatarUrl) || other.studentAvatarUrl == studentAvatarUrl)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.periodization, periodization) || other.periodization == periodization)&&(identical(other.weekNumber, weekNumber) || other.weekNumber == weekNumber)&&(identical(other.totalWeeks, totalWeeks) || other.totalWeeks == totalWeeks)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.completedSessions, completedSessions) || other.completedSessions == completedSessions)&&(identical(other.estimatedDurationMinutes, estimatedDurationMinutes) || other.estimatedDurationMinutes == estimatedDurationMinutes)&&(identical(other.trainerNotes, trainerNotes) || other.trainerNotes == trainerNotes)&&(identical(other.studentFeedback, studentFeedback) || other.studentFeedback == studentFeedback)&&(identical(other.aiGenerated, aiGenerated) || other.aiGenerated == aiGenerated)&&(identical(other.aiSuggestionId, aiSuggestionId) || other.aiSuggestionId == aiSuggestionId)&&(identical(other.version, version) || other.version == version)&&(identical(other.previousVersionId, previousVersionId) || other.previousVersionId == previousVersionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,trainerId,trainerName,studentId,studentName,studentAvatarUrl,name,description,difficulty,status,const DeepCollectionEquality().hash(exercises),periodization,weekNumber,totalWeeks,phase,createdAt,updatedAt,startDate,endDate,totalSessions,completedSessions,estimatedDurationMinutes,trainerNotes,studentFeedback,aiGenerated,aiSuggestionId,version,previousVersionId]);

@override
String toString() {
  return 'TrainerWorkout(id: $id, trainerId: $trainerId, trainerName: $trainerName, studentId: $studentId, studentName: $studentName, studentAvatarUrl: $studentAvatarUrl, name: $name, description: $description, difficulty: $difficulty, status: $status, exercises: $exercises, periodization: $periodization, weekNumber: $weekNumber, totalWeeks: $totalWeeks, phase: $phase, createdAt: $createdAt, updatedAt: $updatedAt, startDate: $startDate, endDate: $endDate, totalSessions: $totalSessions, completedSessions: $completedSessions, estimatedDurationMinutes: $estimatedDurationMinutes, trainerNotes: $trainerNotes, studentFeedback: $studentFeedback, aiGenerated: $aiGenerated, aiSuggestionId: $aiSuggestionId, version: $version, previousVersionId: $previousVersionId)';
}


}

/// @nodoc
abstract mixin class $TrainerWorkoutCopyWith<$Res>  {
  factory $TrainerWorkoutCopyWith(TrainerWorkout value, $Res Function(TrainerWorkout) _then) = _$TrainerWorkoutCopyWithImpl;
@useResult
$Res call({
 String id, String trainerId, String trainerName, String studentId, String studentName, String? studentAvatarUrl, String name, String? description, WorkoutDifficulty difficulty, WorkoutAssignmentStatus status, List<WorkoutExercise> exercises, PeriodizationType periodization, int? weekNumber, int? totalWeeks, String? phase, DateTime createdAt, DateTime? updatedAt, DateTime? startDate, DateTime? endDate, int totalSessions, int completedSessions, int estimatedDurationMinutes, String? trainerNotes, String? studentFeedback, bool aiGenerated, String? aiSuggestionId, int version, String? previousVersionId
});




}
/// @nodoc
class _$TrainerWorkoutCopyWithImpl<$Res>
    implements $TrainerWorkoutCopyWith<$Res> {
  _$TrainerWorkoutCopyWithImpl(this._self, this._then);

  final TrainerWorkout _self;
  final $Res Function(TrainerWorkout) _then;

/// Create a copy of TrainerWorkout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trainerId = null,Object? trainerName = null,Object? studentId = null,Object? studentName = null,Object? studentAvatarUrl = freezed,Object? name = null,Object? description = freezed,Object? difficulty = null,Object? status = null,Object? exercises = null,Object? periodization = null,Object? weekNumber = freezed,Object? totalWeeks = freezed,Object? phase = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? totalSessions = null,Object? completedSessions = null,Object? estimatedDurationMinutes = null,Object? trainerNotes = freezed,Object? studentFeedback = freezed,Object? aiGenerated = null,Object? aiSuggestionId = freezed,Object? version = null,Object? previousVersionId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,trainerName: null == trainerName ? _self.trainerName : trainerName // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,studentName: null == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String,studentAvatarUrl: freezed == studentAvatarUrl ? _self.studentAvatarUrl : studentAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as WorkoutDifficulty,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WorkoutAssignmentStatus,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<WorkoutExercise>,periodization: null == periodization ? _self.periodization : periodization // ignore: cast_nullable_to_non_nullable
as PeriodizationType,weekNumber: freezed == weekNumber ? _self.weekNumber : weekNumber // ignore: cast_nullable_to_non_nullable
as int?,totalWeeks: freezed == totalWeeks ? _self.totalWeeks : totalWeeks // ignore: cast_nullable_to_non_nullable
as int?,phase: freezed == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,completedSessions: null == completedSessions ? _self.completedSessions : completedSessions // ignore: cast_nullable_to_non_nullable
as int,estimatedDurationMinutes: null == estimatedDurationMinutes ? _self.estimatedDurationMinutes : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,trainerNotes: freezed == trainerNotes ? _self.trainerNotes : trainerNotes // ignore: cast_nullable_to_non_nullable
as String?,studentFeedback: freezed == studentFeedback ? _self.studentFeedback : studentFeedback // ignore: cast_nullable_to_non_nullable
as String?,aiGenerated: null == aiGenerated ? _self.aiGenerated : aiGenerated // ignore: cast_nullable_to_non_nullable
as bool,aiSuggestionId: freezed == aiSuggestionId ? _self.aiSuggestionId : aiSuggestionId // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,previousVersionId: freezed == previousVersionId ? _self.previousVersionId : previousVersionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerWorkout].
extension TrainerWorkoutPatterns on TrainerWorkout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerWorkout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerWorkout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerWorkout value)  $default,){
final _that = this;
switch (_that) {
case _TrainerWorkout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerWorkout value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerWorkout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String trainerId,  String trainerName,  String studentId,  String studentName,  String? studentAvatarUrl,  String name,  String? description,  WorkoutDifficulty difficulty,  WorkoutAssignmentStatus status,  List<WorkoutExercise> exercises,  PeriodizationType periodization,  int? weekNumber,  int? totalWeeks,  String? phase,  DateTime createdAt,  DateTime? updatedAt,  DateTime? startDate,  DateTime? endDate,  int totalSessions,  int completedSessions,  int estimatedDurationMinutes,  String? trainerNotes,  String? studentFeedback,  bool aiGenerated,  String? aiSuggestionId,  int version,  String? previousVersionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerWorkout() when $default != null:
return $default(_that.id,_that.trainerId,_that.trainerName,_that.studentId,_that.studentName,_that.studentAvatarUrl,_that.name,_that.description,_that.difficulty,_that.status,_that.exercises,_that.periodization,_that.weekNumber,_that.totalWeeks,_that.phase,_that.createdAt,_that.updatedAt,_that.startDate,_that.endDate,_that.totalSessions,_that.completedSessions,_that.estimatedDurationMinutes,_that.trainerNotes,_that.studentFeedback,_that.aiGenerated,_that.aiSuggestionId,_that.version,_that.previousVersionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String trainerId,  String trainerName,  String studentId,  String studentName,  String? studentAvatarUrl,  String name,  String? description,  WorkoutDifficulty difficulty,  WorkoutAssignmentStatus status,  List<WorkoutExercise> exercises,  PeriodizationType periodization,  int? weekNumber,  int? totalWeeks,  String? phase,  DateTime createdAt,  DateTime? updatedAt,  DateTime? startDate,  DateTime? endDate,  int totalSessions,  int completedSessions,  int estimatedDurationMinutes,  String? trainerNotes,  String? studentFeedback,  bool aiGenerated,  String? aiSuggestionId,  int version,  String? previousVersionId)  $default,) {final _that = this;
switch (_that) {
case _TrainerWorkout():
return $default(_that.id,_that.trainerId,_that.trainerName,_that.studentId,_that.studentName,_that.studentAvatarUrl,_that.name,_that.description,_that.difficulty,_that.status,_that.exercises,_that.periodization,_that.weekNumber,_that.totalWeeks,_that.phase,_that.createdAt,_that.updatedAt,_that.startDate,_that.endDate,_that.totalSessions,_that.completedSessions,_that.estimatedDurationMinutes,_that.trainerNotes,_that.studentFeedback,_that.aiGenerated,_that.aiSuggestionId,_that.version,_that.previousVersionId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String trainerId,  String trainerName,  String studentId,  String studentName,  String? studentAvatarUrl,  String name,  String? description,  WorkoutDifficulty difficulty,  WorkoutAssignmentStatus status,  List<WorkoutExercise> exercises,  PeriodizationType periodization,  int? weekNumber,  int? totalWeeks,  String? phase,  DateTime createdAt,  DateTime? updatedAt,  DateTime? startDate,  DateTime? endDate,  int totalSessions,  int completedSessions,  int estimatedDurationMinutes,  String? trainerNotes,  String? studentFeedback,  bool aiGenerated,  String? aiSuggestionId,  int version,  String? previousVersionId)?  $default,) {final _that = this;
switch (_that) {
case _TrainerWorkout() when $default != null:
return $default(_that.id,_that.trainerId,_that.trainerName,_that.studentId,_that.studentName,_that.studentAvatarUrl,_that.name,_that.description,_that.difficulty,_that.status,_that.exercises,_that.periodization,_that.weekNumber,_that.totalWeeks,_that.phase,_that.createdAt,_that.updatedAt,_that.startDate,_that.endDate,_that.totalSessions,_that.completedSessions,_that.estimatedDurationMinutes,_that.trainerNotes,_that.studentFeedback,_that.aiGenerated,_that.aiSuggestionId,_that.version,_that.previousVersionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerWorkout extends TrainerWorkout {
  const _TrainerWorkout({required this.id, required this.trainerId, required this.trainerName, required this.studentId, required this.studentName, this.studentAvatarUrl, required this.name, this.description, this.difficulty = WorkoutDifficulty.intermediate, this.status = WorkoutAssignmentStatus.draft, final  List<WorkoutExercise> exercises = const [], this.periodization = PeriodizationType.linear, this.weekNumber, this.totalWeeks, this.phase, required this.createdAt, this.updatedAt, this.startDate, this.endDate, this.totalSessions = 0, this.completedSessions = 0, this.estimatedDurationMinutes = 0, this.trainerNotes, this.studentFeedback, this.aiGenerated = false, this.aiSuggestionId, this.version = 1, this.previousVersionId}): _exercises = exercises,super._();
  factory _TrainerWorkout.fromJson(Map<String, dynamic> json) => _$TrainerWorkoutFromJson(json);

@override final  String id;
// === Quem criou ===
@override final  String trainerId;
@override final  String trainerName;
// === Para quem ===
@override final  String studentId;
@override final  String studentName;
@override final  String? studentAvatarUrl;
// === Info básica ===
@override final  String name;
@override final  String? description;
@override@JsonKey() final  WorkoutDifficulty difficulty;
@override@JsonKey() final  WorkoutAssignmentStatus status;
// === Exercícios ===
 final  List<WorkoutExercise> _exercises;
// === Exercícios ===
@override@JsonKey() List<WorkoutExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

// === Periodização ===
@override@JsonKey() final  PeriodizationType periodization;
@override final  int? weekNumber;
@override final  int? totalWeeks;
@override final  String? phase;
// Ex: "Hipertrofia", "Força", "Cutting"
// === Datas ===
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
// === Métricas ===
@override@JsonKey() final  int totalSessions;
@override@JsonKey() final  int completedSessions;
@override@JsonKey() final  int estimatedDurationMinutes;
// === Notas ===
@override final  String? trainerNotes;
@override final  String? studentFeedback;
// === IA ===
@override@JsonKey() final  bool aiGenerated;
@override final  String? aiSuggestionId;
// === Versioning ===
@override@JsonKey() final  int version;
@override final  String? previousVersionId;

/// Create a copy of TrainerWorkout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerWorkoutCopyWith<_TrainerWorkout> get copyWith => __$TrainerWorkoutCopyWithImpl<_TrainerWorkout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerWorkoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.trainerName, trainerName) || other.trainerName == trainerName)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentAvatarUrl, studentAvatarUrl) || other.studentAvatarUrl == studentAvatarUrl)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.periodization, periodization) || other.periodization == periodization)&&(identical(other.weekNumber, weekNumber) || other.weekNumber == weekNumber)&&(identical(other.totalWeeks, totalWeeks) || other.totalWeeks == totalWeeks)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.completedSessions, completedSessions) || other.completedSessions == completedSessions)&&(identical(other.estimatedDurationMinutes, estimatedDurationMinutes) || other.estimatedDurationMinutes == estimatedDurationMinutes)&&(identical(other.trainerNotes, trainerNotes) || other.trainerNotes == trainerNotes)&&(identical(other.studentFeedback, studentFeedback) || other.studentFeedback == studentFeedback)&&(identical(other.aiGenerated, aiGenerated) || other.aiGenerated == aiGenerated)&&(identical(other.aiSuggestionId, aiSuggestionId) || other.aiSuggestionId == aiSuggestionId)&&(identical(other.version, version) || other.version == version)&&(identical(other.previousVersionId, previousVersionId) || other.previousVersionId == previousVersionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,trainerId,trainerName,studentId,studentName,studentAvatarUrl,name,description,difficulty,status,const DeepCollectionEquality().hash(_exercises),periodization,weekNumber,totalWeeks,phase,createdAt,updatedAt,startDate,endDate,totalSessions,completedSessions,estimatedDurationMinutes,trainerNotes,studentFeedback,aiGenerated,aiSuggestionId,version,previousVersionId]);

@override
String toString() {
  return 'TrainerWorkout(id: $id, trainerId: $trainerId, trainerName: $trainerName, studentId: $studentId, studentName: $studentName, studentAvatarUrl: $studentAvatarUrl, name: $name, description: $description, difficulty: $difficulty, status: $status, exercises: $exercises, periodization: $periodization, weekNumber: $weekNumber, totalWeeks: $totalWeeks, phase: $phase, createdAt: $createdAt, updatedAt: $updatedAt, startDate: $startDate, endDate: $endDate, totalSessions: $totalSessions, completedSessions: $completedSessions, estimatedDurationMinutes: $estimatedDurationMinutes, trainerNotes: $trainerNotes, studentFeedback: $studentFeedback, aiGenerated: $aiGenerated, aiSuggestionId: $aiSuggestionId, version: $version, previousVersionId: $previousVersionId)';
}


}

/// @nodoc
abstract mixin class _$TrainerWorkoutCopyWith<$Res> implements $TrainerWorkoutCopyWith<$Res> {
  factory _$TrainerWorkoutCopyWith(_TrainerWorkout value, $Res Function(_TrainerWorkout) _then) = __$TrainerWorkoutCopyWithImpl;
@override @useResult
$Res call({
 String id, String trainerId, String trainerName, String studentId, String studentName, String? studentAvatarUrl, String name, String? description, WorkoutDifficulty difficulty, WorkoutAssignmentStatus status, List<WorkoutExercise> exercises, PeriodizationType periodization, int? weekNumber, int? totalWeeks, String? phase, DateTime createdAt, DateTime? updatedAt, DateTime? startDate, DateTime? endDate, int totalSessions, int completedSessions, int estimatedDurationMinutes, String? trainerNotes, String? studentFeedback, bool aiGenerated, String? aiSuggestionId, int version, String? previousVersionId
});




}
/// @nodoc
class __$TrainerWorkoutCopyWithImpl<$Res>
    implements _$TrainerWorkoutCopyWith<$Res> {
  __$TrainerWorkoutCopyWithImpl(this._self, this._then);

  final _TrainerWorkout _self;
  final $Res Function(_TrainerWorkout) _then;

/// Create a copy of TrainerWorkout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trainerId = null,Object? trainerName = null,Object? studentId = null,Object? studentName = null,Object? studentAvatarUrl = freezed,Object? name = null,Object? description = freezed,Object? difficulty = null,Object? status = null,Object? exercises = null,Object? periodization = null,Object? weekNumber = freezed,Object? totalWeeks = freezed,Object? phase = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? totalSessions = null,Object? completedSessions = null,Object? estimatedDurationMinutes = null,Object? trainerNotes = freezed,Object? studentFeedback = freezed,Object? aiGenerated = null,Object? aiSuggestionId = freezed,Object? version = null,Object? previousVersionId = freezed,}) {
  return _then(_TrainerWorkout(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,trainerName: null == trainerName ? _self.trainerName : trainerName // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,studentName: null == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String,studentAvatarUrl: freezed == studentAvatarUrl ? _self.studentAvatarUrl : studentAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as WorkoutDifficulty,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WorkoutAssignmentStatus,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<WorkoutExercise>,periodization: null == periodization ? _self.periodization : periodization // ignore: cast_nullable_to_non_nullable
as PeriodizationType,weekNumber: freezed == weekNumber ? _self.weekNumber : weekNumber // ignore: cast_nullable_to_non_nullable
as int?,totalWeeks: freezed == totalWeeks ? _self.totalWeeks : totalWeeks // ignore: cast_nullable_to_non_nullable
as int?,phase: freezed == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,completedSessions: null == completedSessions ? _self.completedSessions : completedSessions // ignore: cast_nullable_to_non_nullable
as int,estimatedDurationMinutes: null == estimatedDurationMinutes ? _self.estimatedDurationMinutes : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,trainerNotes: freezed == trainerNotes ? _self.trainerNotes : trainerNotes // ignore: cast_nullable_to_non_nullable
as String?,studentFeedback: freezed == studentFeedback ? _self.studentFeedback : studentFeedback // ignore: cast_nullable_to_non_nullable
as String?,aiGenerated: null == aiGenerated ? _self.aiGenerated : aiGenerated // ignore: cast_nullable_to_non_nullable
as bool,aiSuggestionId: freezed == aiSuggestionId ? _self.aiSuggestionId : aiSuggestionId // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,previousVersionId: freezed == previousVersionId ? _self.previousVersionId : previousVersionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WorkoutExercise {

 String get id; String get exerciseId; String get exerciseName; String? get exerciseImageUrl; String? get exerciseVideoUrl;// === Prescrição ===
 int get sets; int? get repsMin; int? get repsMax; String? get repsNote;// Ex: "até a falha", "AMRAP"
 int? get restSeconds;// === Carga ===
 double? get weightKg; String? get weightNote;// Ex: "RPE 8", "70% 1RM"
 bool get dropSet; bool get superSet; String? get superSetWith;// === Tempo ===
 String? get tempo;// Ex: "3-1-2-0"
 int? get durationSeconds;// Para exercícios isométricos
// === Organização ===
 int get order; String? get groupId;// Para agrupar exercícios (superset, circuit)
 String? get notes;// === Progressão sugerida ===
 String? get progressionNote; double? get nextWeightKg; int? get nextRepsTarget;
/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutExerciseCopyWith<WorkoutExercise> get copyWith => _$WorkoutExerciseCopyWithImpl<WorkoutExercise>(this as WorkoutExercise, _$identity);

  /// Serializes this WorkoutExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.exerciseImageUrl, exerciseImageUrl) || other.exerciseImageUrl == exerciseImageUrl)&&(identical(other.exerciseVideoUrl, exerciseVideoUrl) || other.exerciseVideoUrl == exerciseVideoUrl)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.repsMin, repsMin) || other.repsMin == repsMin)&&(identical(other.repsMax, repsMax) || other.repsMax == repsMax)&&(identical(other.repsNote, repsNote) || other.repsNote == repsNote)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.weightNote, weightNote) || other.weightNote == weightNote)&&(identical(other.dropSet, dropSet) || other.dropSet == dropSet)&&(identical(other.superSet, superSet) || other.superSet == superSet)&&(identical(other.superSetWith, superSetWith) || other.superSetWith == superSetWith)&&(identical(other.tempo, tempo) || other.tempo == tempo)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.order, order) || other.order == order)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.progressionNote, progressionNote) || other.progressionNote == progressionNote)&&(identical(other.nextWeightKg, nextWeightKg) || other.nextWeightKg == nextWeightKg)&&(identical(other.nextRepsTarget, nextRepsTarget) || other.nextRepsTarget == nextRepsTarget));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,exerciseId,exerciseName,exerciseImageUrl,exerciseVideoUrl,sets,repsMin,repsMax,repsNote,restSeconds,weightKg,weightNote,dropSet,superSet,superSetWith,tempo,durationSeconds,order,groupId,notes,progressionNote,nextWeightKg,nextRepsTarget]);

@override
String toString() {
  return 'WorkoutExercise(id: $id, exerciseId: $exerciseId, exerciseName: $exerciseName, exerciseImageUrl: $exerciseImageUrl, exerciseVideoUrl: $exerciseVideoUrl, sets: $sets, repsMin: $repsMin, repsMax: $repsMax, repsNote: $repsNote, restSeconds: $restSeconds, weightKg: $weightKg, weightNote: $weightNote, dropSet: $dropSet, superSet: $superSet, superSetWith: $superSetWith, tempo: $tempo, durationSeconds: $durationSeconds, order: $order, groupId: $groupId, notes: $notes, progressionNote: $progressionNote, nextWeightKg: $nextWeightKg, nextRepsTarget: $nextRepsTarget)';
}


}

/// @nodoc
abstract mixin class $WorkoutExerciseCopyWith<$Res>  {
  factory $WorkoutExerciseCopyWith(WorkoutExercise value, $Res Function(WorkoutExercise) _then) = _$WorkoutExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, String exerciseName, String? exerciseImageUrl, String? exerciseVideoUrl, int sets, int? repsMin, int? repsMax, String? repsNote, int? restSeconds, double? weightKg, String? weightNote, bool dropSet, bool superSet, String? superSetWith, String? tempo, int? durationSeconds, int order, String? groupId, String? notes, String? progressionNote, double? nextWeightKg, int? nextRepsTarget
});




}
/// @nodoc
class _$WorkoutExerciseCopyWithImpl<$Res>
    implements $WorkoutExerciseCopyWith<$Res> {
  _$WorkoutExerciseCopyWithImpl(this._self, this._then);

  final WorkoutExercise _self;
  final $Res Function(WorkoutExercise) _then;

/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? exerciseName = null,Object? exerciseImageUrl = freezed,Object? exerciseVideoUrl = freezed,Object? sets = null,Object? repsMin = freezed,Object? repsMax = freezed,Object? repsNote = freezed,Object? restSeconds = freezed,Object? weightKg = freezed,Object? weightNote = freezed,Object? dropSet = null,Object? superSet = null,Object? superSetWith = freezed,Object? tempo = freezed,Object? durationSeconds = freezed,Object? order = null,Object? groupId = freezed,Object? notes = freezed,Object? progressionNote = freezed,Object? nextWeightKg = freezed,Object? nextRepsTarget = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,exerciseImageUrl: freezed == exerciseImageUrl ? _self.exerciseImageUrl : exerciseImageUrl // ignore: cast_nullable_to_non_nullable
as String?,exerciseVideoUrl: freezed == exerciseVideoUrl ? _self.exerciseVideoUrl : exerciseVideoUrl // ignore: cast_nullable_to_non_nullable
as String?,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,repsMin: freezed == repsMin ? _self.repsMin : repsMin // ignore: cast_nullable_to_non_nullable
as int?,repsMax: freezed == repsMax ? _self.repsMax : repsMax // ignore: cast_nullable_to_non_nullable
as int?,repsNote: freezed == repsNote ? _self.repsNote : repsNote // ignore: cast_nullable_to_non_nullable
as String?,restSeconds: freezed == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,weightNote: freezed == weightNote ? _self.weightNote : weightNote // ignore: cast_nullable_to_non_nullable
as String?,dropSet: null == dropSet ? _self.dropSet : dropSet // ignore: cast_nullable_to_non_nullable
as bool,superSet: null == superSet ? _self.superSet : superSet // ignore: cast_nullable_to_non_nullable
as bool,superSetWith: freezed == superSetWith ? _self.superSetWith : superSetWith // ignore: cast_nullable_to_non_nullable
as String?,tempo: freezed == tempo ? _self.tempo : tempo // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,progressionNote: freezed == progressionNote ? _self.progressionNote : progressionNote // ignore: cast_nullable_to_non_nullable
as String?,nextWeightKg: freezed == nextWeightKg ? _self.nextWeightKg : nextWeightKg // ignore: cast_nullable_to_non_nullable
as double?,nextRepsTarget: freezed == nextRepsTarget ? _self.nextRepsTarget : nextRepsTarget // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutExercise].
extension WorkoutExercisePatterns on WorkoutExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutExercise value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutExercise value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String exerciseName,  String? exerciseImageUrl,  String? exerciseVideoUrl,  int sets,  int? repsMin,  int? repsMax,  String? repsNote,  int? restSeconds,  double? weightKg,  String? weightNote,  bool dropSet,  bool superSet,  String? superSetWith,  String? tempo,  int? durationSeconds,  int order,  String? groupId,  String? notes,  String? progressionNote,  double? nextWeightKg,  int? nextRepsTarget)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.exerciseImageUrl,_that.exerciseVideoUrl,_that.sets,_that.repsMin,_that.repsMax,_that.repsNote,_that.restSeconds,_that.weightKg,_that.weightNote,_that.dropSet,_that.superSet,_that.superSetWith,_that.tempo,_that.durationSeconds,_that.order,_that.groupId,_that.notes,_that.progressionNote,_that.nextWeightKg,_that.nextRepsTarget);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String exerciseName,  String? exerciseImageUrl,  String? exerciseVideoUrl,  int sets,  int? repsMin,  int? repsMax,  String? repsNote,  int? restSeconds,  double? weightKg,  String? weightNote,  bool dropSet,  bool superSet,  String? superSetWith,  String? tempo,  int? durationSeconds,  int order,  String? groupId,  String? notes,  String? progressionNote,  double? nextWeightKg,  int? nextRepsTarget)  $default,) {final _that = this;
switch (_that) {
case _WorkoutExercise():
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.exerciseImageUrl,_that.exerciseVideoUrl,_that.sets,_that.repsMin,_that.repsMax,_that.repsNote,_that.restSeconds,_that.weightKg,_that.weightNote,_that.dropSet,_that.superSet,_that.superSetWith,_that.tempo,_that.durationSeconds,_that.order,_that.groupId,_that.notes,_that.progressionNote,_that.nextWeightKg,_that.nextRepsTarget);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  String exerciseName,  String? exerciseImageUrl,  String? exerciseVideoUrl,  int sets,  int? repsMin,  int? repsMax,  String? repsNote,  int? restSeconds,  double? weightKg,  String? weightNote,  bool dropSet,  bool superSet,  String? superSetWith,  String? tempo,  int? durationSeconds,  int order,  String? groupId,  String? notes,  String? progressionNote,  double? nextWeightKg,  int? nextRepsTarget)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.exerciseImageUrl,_that.exerciseVideoUrl,_that.sets,_that.repsMin,_that.repsMax,_that.repsNote,_that.restSeconds,_that.weightKg,_that.weightNote,_that.dropSet,_that.superSet,_that.superSetWith,_that.tempo,_that.durationSeconds,_that.order,_that.groupId,_that.notes,_that.progressionNote,_that.nextWeightKg,_that.nextRepsTarget);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutExercise extends WorkoutExercise {
  const _WorkoutExercise({required this.id, required this.exerciseId, required this.exerciseName, this.exerciseImageUrl, this.exerciseVideoUrl, this.sets = 3, this.repsMin, this.repsMax, this.repsNote, this.restSeconds, this.weightKg, this.weightNote, this.dropSet = false, this.superSet = false, this.superSetWith, this.tempo, this.durationSeconds, this.order = 0, this.groupId, this.notes, this.progressionNote, this.nextWeightKg, this.nextRepsTarget}): super._();
  factory _WorkoutExercise.fromJson(Map<String, dynamic> json) => _$WorkoutExerciseFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  String exerciseName;
@override final  String? exerciseImageUrl;
@override final  String? exerciseVideoUrl;
// === Prescrição ===
@override@JsonKey() final  int sets;
@override final  int? repsMin;
@override final  int? repsMax;
@override final  String? repsNote;
// Ex: "até a falha", "AMRAP"
@override final  int? restSeconds;
// === Carga ===
@override final  double? weightKg;
@override final  String? weightNote;
// Ex: "RPE 8", "70% 1RM"
@override@JsonKey() final  bool dropSet;
@override@JsonKey() final  bool superSet;
@override final  String? superSetWith;
// === Tempo ===
@override final  String? tempo;
// Ex: "3-1-2-0"
@override final  int? durationSeconds;
// Para exercícios isométricos
// === Organização ===
@override@JsonKey() final  int order;
@override final  String? groupId;
// Para agrupar exercícios (superset, circuit)
@override final  String? notes;
// === Progressão sugerida ===
@override final  String? progressionNote;
@override final  double? nextWeightKg;
@override final  int? nextRepsTarget;

/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutExerciseCopyWith<_WorkoutExercise> get copyWith => __$WorkoutExerciseCopyWithImpl<_WorkoutExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.exerciseImageUrl, exerciseImageUrl) || other.exerciseImageUrl == exerciseImageUrl)&&(identical(other.exerciseVideoUrl, exerciseVideoUrl) || other.exerciseVideoUrl == exerciseVideoUrl)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.repsMin, repsMin) || other.repsMin == repsMin)&&(identical(other.repsMax, repsMax) || other.repsMax == repsMax)&&(identical(other.repsNote, repsNote) || other.repsNote == repsNote)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.weightNote, weightNote) || other.weightNote == weightNote)&&(identical(other.dropSet, dropSet) || other.dropSet == dropSet)&&(identical(other.superSet, superSet) || other.superSet == superSet)&&(identical(other.superSetWith, superSetWith) || other.superSetWith == superSetWith)&&(identical(other.tempo, tempo) || other.tempo == tempo)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.order, order) || other.order == order)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.progressionNote, progressionNote) || other.progressionNote == progressionNote)&&(identical(other.nextWeightKg, nextWeightKg) || other.nextWeightKg == nextWeightKg)&&(identical(other.nextRepsTarget, nextRepsTarget) || other.nextRepsTarget == nextRepsTarget));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,exerciseId,exerciseName,exerciseImageUrl,exerciseVideoUrl,sets,repsMin,repsMax,repsNote,restSeconds,weightKg,weightNote,dropSet,superSet,superSetWith,tempo,durationSeconds,order,groupId,notes,progressionNote,nextWeightKg,nextRepsTarget]);

@override
String toString() {
  return 'WorkoutExercise(id: $id, exerciseId: $exerciseId, exerciseName: $exerciseName, exerciseImageUrl: $exerciseImageUrl, exerciseVideoUrl: $exerciseVideoUrl, sets: $sets, repsMin: $repsMin, repsMax: $repsMax, repsNote: $repsNote, restSeconds: $restSeconds, weightKg: $weightKg, weightNote: $weightNote, dropSet: $dropSet, superSet: $superSet, superSetWith: $superSetWith, tempo: $tempo, durationSeconds: $durationSeconds, order: $order, groupId: $groupId, notes: $notes, progressionNote: $progressionNote, nextWeightKg: $nextWeightKg, nextRepsTarget: $nextRepsTarget)';
}


}

/// @nodoc
abstract mixin class _$WorkoutExerciseCopyWith<$Res> implements $WorkoutExerciseCopyWith<$Res> {
  factory _$WorkoutExerciseCopyWith(_WorkoutExercise value, $Res Function(_WorkoutExercise) _then) = __$WorkoutExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, String exerciseName, String? exerciseImageUrl, String? exerciseVideoUrl, int sets, int? repsMin, int? repsMax, String? repsNote, int? restSeconds, double? weightKg, String? weightNote, bool dropSet, bool superSet, String? superSetWith, String? tempo, int? durationSeconds, int order, String? groupId, String? notes, String? progressionNote, double? nextWeightKg, int? nextRepsTarget
});




}
/// @nodoc
class __$WorkoutExerciseCopyWithImpl<$Res>
    implements _$WorkoutExerciseCopyWith<$Res> {
  __$WorkoutExerciseCopyWithImpl(this._self, this._then);

  final _WorkoutExercise _self;
  final $Res Function(_WorkoutExercise) _then;

/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? exerciseName = null,Object? exerciseImageUrl = freezed,Object? exerciseVideoUrl = freezed,Object? sets = null,Object? repsMin = freezed,Object? repsMax = freezed,Object? repsNote = freezed,Object? restSeconds = freezed,Object? weightKg = freezed,Object? weightNote = freezed,Object? dropSet = null,Object? superSet = null,Object? superSetWith = freezed,Object? tempo = freezed,Object? durationSeconds = freezed,Object? order = null,Object? groupId = freezed,Object? notes = freezed,Object? progressionNote = freezed,Object? nextWeightKg = freezed,Object? nextRepsTarget = freezed,}) {
  return _then(_WorkoutExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,exerciseImageUrl: freezed == exerciseImageUrl ? _self.exerciseImageUrl : exerciseImageUrl // ignore: cast_nullable_to_non_nullable
as String?,exerciseVideoUrl: freezed == exerciseVideoUrl ? _self.exerciseVideoUrl : exerciseVideoUrl // ignore: cast_nullable_to_non_nullable
as String?,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,repsMin: freezed == repsMin ? _self.repsMin : repsMin // ignore: cast_nullable_to_non_nullable
as int?,repsMax: freezed == repsMax ? _self.repsMax : repsMax // ignore: cast_nullable_to_non_nullable
as int?,repsNote: freezed == repsNote ? _self.repsNote : repsNote // ignore: cast_nullable_to_non_nullable
as String?,restSeconds: freezed == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,weightNote: freezed == weightNote ? _self.weightNote : weightNote // ignore: cast_nullable_to_non_nullable
as String?,dropSet: null == dropSet ? _self.dropSet : dropSet // ignore: cast_nullable_to_non_nullable
as bool,superSet: null == superSet ? _self.superSet : superSet // ignore: cast_nullable_to_non_nullable
as bool,superSetWith: freezed == superSetWith ? _self.superSetWith : superSetWith // ignore: cast_nullable_to_non_nullable
as String?,tempo: freezed == tempo ? _self.tempo : tempo // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,progressionNote: freezed == progressionNote ? _self.progressionNote : progressionNote // ignore: cast_nullable_to_non_nullable
as String?,nextWeightKg: freezed == nextWeightKg ? _self.nextWeightKg : nextWeightKg // ignore: cast_nullable_to_non_nullable
as double?,nextRepsTarget: freezed == nextRepsTarget ? _self.nextRepsTarget : nextRepsTarget // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ExerciseProgress {

 String get id; String get exerciseId; String get exerciseName; String get studentId;// === Histórico de cargas ===
 List<ExerciseLog> get logs;// === PRs (Personal Records) ===
 double? get pr1RM; double? get pr5RM; double? get pr10RM; DateTime? get lastPrDate;// === Tendência ===
 ProgressTrend get trend; double? get averageWeightLast4Weeks; double? get averageRepsLast4Weeks;
/// Create a copy of ExerciseProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseProgressCopyWith<ExerciseProgress> get copyWith => _$ExerciseProgressCopyWithImpl<ExerciseProgress>(this as ExerciseProgress, _$identity);

  /// Serializes this ExerciseProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseProgress&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&const DeepCollectionEquality().equals(other.logs, logs)&&(identical(other.pr1RM, pr1RM) || other.pr1RM == pr1RM)&&(identical(other.pr5RM, pr5RM) || other.pr5RM == pr5RM)&&(identical(other.pr10RM, pr10RM) || other.pr10RM == pr10RM)&&(identical(other.lastPrDate, lastPrDate) || other.lastPrDate == lastPrDate)&&(identical(other.trend, trend) || other.trend == trend)&&(identical(other.averageWeightLast4Weeks, averageWeightLast4Weeks) || other.averageWeightLast4Weeks == averageWeightLast4Weeks)&&(identical(other.averageRepsLast4Weeks, averageRepsLast4Weeks) || other.averageRepsLast4Weeks == averageRepsLast4Weeks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,exerciseName,studentId,const DeepCollectionEquality().hash(logs),pr1RM,pr5RM,pr10RM,lastPrDate,trend,averageWeightLast4Weeks,averageRepsLast4Weeks);

@override
String toString() {
  return 'ExerciseProgress(id: $id, exerciseId: $exerciseId, exerciseName: $exerciseName, studentId: $studentId, logs: $logs, pr1RM: $pr1RM, pr5RM: $pr5RM, pr10RM: $pr10RM, lastPrDate: $lastPrDate, trend: $trend, averageWeightLast4Weeks: $averageWeightLast4Weeks, averageRepsLast4Weeks: $averageRepsLast4Weeks)';
}


}

/// @nodoc
abstract mixin class $ExerciseProgressCopyWith<$Res>  {
  factory $ExerciseProgressCopyWith(ExerciseProgress value, $Res Function(ExerciseProgress) _then) = _$ExerciseProgressCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, String exerciseName, String studentId, List<ExerciseLog> logs, double? pr1RM, double? pr5RM, double? pr10RM, DateTime? lastPrDate, ProgressTrend trend, double? averageWeightLast4Weeks, double? averageRepsLast4Weeks
});




}
/// @nodoc
class _$ExerciseProgressCopyWithImpl<$Res>
    implements $ExerciseProgressCopyWith<$Res> {
  _$ExerciseProgressCopyWithImpl(this._self, this._then);

  final ExerciseProgress _self;
  final $Res Function(ExerciseProgress) _then;

/// Create a copy of ExerciseProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? exerciseName = null,Object? studentId = null,Object? logs = null,Object? pr1RM = freezed,Object? pr5RM = freezed,Object? pr10RM = freezed,Object? lastPrDate = freezed,Object? trend = null,Object? averageWeightLast4Weeks = freezed,Object? averageRepsLast4Weeks = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as List<ExerciseLog>,pr1RM: freezed == pr1RM ? _self.pr1RM : pr1RM // ignore: cast_nullable_to_non_nullable
as double?,pr5RM: freezed == pr5RM ? _self.pr5RM : pr5RM // ignore: cast_nullable_to_non_nullable
as double?,pr10RM: freezed == pr10RM ? _self.pr10RM : pr10RM // ignore: cast_nullable_to_non_nullable
as double?,lastPrDate: freezed == lastPrDate ? _self.lastPrDate : lastPrDate // ignore: cast_nullable_to_non_nullable
as DateTime?,trend: null == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as ProgressTrend,averageWeightLast4Weeks: freezed == averageWeightLast4Weeks ? _self.averageWeightLast4Weeks : averageWeightLast4Weeks // ignore: cast_nullable_to_non_nullable
as double?,averageRepsLast4Weeks: freezed == averageRepsLast4Weeks ? _self.averageRepsLast4Weeks : averageRepsLast4Weeks // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseProgress].
extension ExerciseProgressPatterns on ExerciseProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseProgress value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseProgress value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String exerciseName,  String studentId,  List<ExerciseLog> logs,  double? pr1RM,  double? pr5RM,  double? pr10RM,  DateTime? lastPrDate,  ProgressTrend trend,  double? averageWeightLast4Weeks,  double? averageRepsLast4Weeks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseProgress() when $default != null:
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.studentId,_that.logs,_that.pr1RM,_that.pr5RM,_that.pr10RM,_that.lastPrDate,_that.trend,_that.averageWeightLast4Weeks,_that.averageRepsLast4Weeks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String exerciseName,  String studentId,  List<ExerciseLog> logs,  double? pr1RM,  double? pr5RM,  double? pr10RM,  DateTime? lastPrDate,  ProgressTrend trend,  double? averageWeightLast4Weeks,  double? averageRepsLast4Weeks)  $default,) {final _that = this;
switch (_that) {
case _ExerciseProgress():
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.studentId,_that.logs,_that.pr1RM,_that.pr5RM,_that.pr10RM,_that.lastPrDate,_that.trend,_that.averageWeightLast4Weeks,_that.averageRepsLast4Weeks);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  String exerciseName,  String studentId,  List<ExerciseLog> logs,  double? pr1RM,  double? pr5RM,  double? pr10RM,  DateTime? lastPrDate,  ProgressTrend trend,  double? averageWeightLast4Weeks,  double? averageRepsLast4Weeks)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseProgress() when $default != null:
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.studentId,_that.logs,_that.pr1RM,_that.pr5RM,_that.pr10RM,_that.lastPrDate,_that.trend,_that.averageWeightLast4Weeks,_that.averageRepsLast4Weeks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseProgress extends ExerciseProgress {
  const _ExerciseProgress({required this.id, required this.exerciseId, required this.exerciseName, required this.studentId, final  List<ExerciseLog> logs = const [], this.pr1RM, this.pr5RM, this.pr10RM, this.lastPrDate, this.trend = ProgressTrend.stable, this.averageWeightLast4Weeks, this.averageRepsLast4Weeks}): _logs = logs,super._();
  factory _ExerciseProgress.fromJson(Map<String, dynamic> json) => _$ExerciseProgressFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  String exerciseName;
@override final  String studentId;
// === Histórico de cargas ===
 final  List<ExerciseLog> _logs;
// === Histórico de cargas ===
@override@JsonKey() List<ExerciseLog> get logs {
  if (_logs is EqualUnmodifiableListView) return _logs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logs);
}

// === PRs (Personal Records) ===
@override final  double? pr1RM;
@override final  double? pr5RM;
@override final  double? pr10RM;
@override final  DateTime? lastPrDate;
// === Tendência ===
@override@JsonKey() final  ProgressTrend trend;
@override final  double? averageWeightLast4Weeks;
@override final  double? averageRepsLast4Weeks;

/// Create a copy of ExerciseProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseProgressCopyWith<_ExerciseProgress> get copyWith => __$ExerciseProgressCopyWithImpl<_ExerciseProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseProgress&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&const DeepCollectionEquality().equals(other._logs, _logs)&&(identical(other.pr1RM, pr1RM) || other.pr1RM == pr1RM)&&(identical(other.pr5RM, pr5RM) || other.pr5RM == pr5RM)&&(identical(other.pr10RM, pr10RM) || other.pr10RM == pr10RM)&&(identical(other.lastPrDate, lastPrDate) || other.lastPrDate == lastPrDate)&&(identical(other.trend, trend) || other.trend == trend)&&(identical(other.averageWeightLast4Weeks, averageWeightLast4Weeks) || other.averageWeightLast4Weeks == averageWeightLast4Weeks)&&(identical(other.averageRepsLast4Weeks, averageRepsLast4Weeks) || other.averageRepsLast4Weeks == averageRepsLast4Weeks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,exerciseName,studentId,const DeepCollectionEquality().hash(_logs),pr1RM,pr5RM,pr10RM,lastPrDate,trend,averageWeightLast4Weeks,averageRepsLast4Weeks);

@override
String toString() {
  return 'ExerciseProgress(id: $id, exerciseId: $exerciseId, exerciseName: $exerciseName, studentId: $studentId, logs: $logs, pr1RM: $pr1RM, pr5RM: $pr5RM, pr10RM: $pr10RM, lastPrDate: $lastPrDate, trend: $trend, averageWeightLast4Weeks: $averageWeightLast4Weeks, averageRepsLast4Weeks: $averageRepsLast4Weeks)';
}


}

/// @nodoc
abstract mixin class _$ExerciseProgressCopyWith<$Res> implements $ExerciseProgressCopyWith<$Res> {
  factory _$ExerciseProgressCopyWith(_ExerciseProgress value, $Res Function(_ExerciseProgress) _then) = __$ExerciseProgressCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, String exerciseName, String studentId, List<ExerciseLog> logs, double? pr1RM, double? pr5RM, double? pr10RM, DateTime? lastPrDate, ProgressTrend trend, double? averageWeightLast4Weeks, double? averageRepsLast4Weeks
});




}
/// @nodoc
class __$ExerciseProgressCopyWithImpl<$Res>
    implements _$ExerciseProgressCopyWith<$Res> {
  __$ExerciseProgressCopyWithImpl(this._self, this._then);

  final _ExerciseProgress _self;
  final $Res Function(_ExerciseProgress) _then;

/// Create a copy of ExerciseProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? exerciseName = null,Object? studentId = null,Object? logs = null,Object? pr1RM = freezed,Object? pr5RM = freezed,Object? pr10RM = freezed,Object? lastPrDate = freezed,Object? trend = null,Object? averageWeightLast4Weeks = freezed,Object? averageRepsLast4Weeks = freezed,}) {
  return _then(_ExerciseProgress(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<ExerciseLog>,pr1RM: freezed == pr1RM ? _self.pr1RM : pr1RM // ignore: cast_nullable_to_non_nullable
as double?,pr5RM: freezed == pr5RM ? _self.pr5RM : pr5RM // ignore: cast_nullable_to_non_nullable
as double?,pr10RM: freezed == pr10RM ? _self.pr10RM : pr10RM // ignore: cast_nullable_to_non_nullable
as double?,lastPrDate: freezed == lastPrDate ? _self.lastPrDate : lastPrDate // ignore: cast_nullable_to_non_nullable
as DateTime?,trend: null == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as ProgressTrend,averageWeightLast4Weeks: freezed == averageWeightLast4Weeks ? _self.averageWeightLast4Weeks : averageWeightLast4Weeks // ignore: cast_nullable_to_non_nullable
as double?,averageRepsLast4Weeks: freezed == averageRepsLast4Weeks ? _self.averageRepsLast4Weeks : averageRepsLast4Weeks // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$ExerciseLog {

 String get id; DateTime get date; int get sets; int get reps; double? get weightKg; int? get rpe;// Rate of Perceived Exertion (1-10)
 String? get notes; bool get isPR;
/// Create a copy of ExerciseLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseLogCopyWith<ExerciseLog> get copyWith => _$ExerciseLogCopyWithImpl<ExerciseLog>(this as ExerciseLog, _$identity);

  /// Serializes this ExerciseLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseLog&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isPR, isPR) || other.isPR == isPR));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,sets,reps,weightKg,rpe,notes,isPR);

@override
String toString() {
  return 'ExerciseLog(id: $id, date: $date, sets: $sets, reps: $reps, weightKg: $weightKg, rpe: $rpe, notes: $notes, isPR: $isPR)';
}


}

/// @nodoc
abstract mixin class $ExerciseLogCopyWith<$Res>  {
  factory $ExerciseLogCopyWith(ExerciseLog value, $Res Function(ExerciseLog) _then) = _$ExerciseLogCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, int sets, int reps, double? weightKg, int? rpe, String? notes, bool isPR
});




}
/// @nodoc
class _$ExerciseLogCopyWithImpl<$Res>
    implements $ExerciseLogCopyWith<$Res> {
  _$ExerciseLogCopyWithImpl(this._self, this._then);

  final ExerciseLog _self;
  final $Res Function(ExerciseLog) _then;

/// Create a copy of ExerciseLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? sets = null,Object? reps = null,Object? weightKg = freezed,Object? rpe = freezed,Object? notes = freezed,Object? isPR = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isPR: null == isPR ? _self.isPR : isPR // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseLog].
extension ExerciseLogPatterns on ExerciseLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseLog value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseLog value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  int sets,  int reps,  double? weightKg,  int? rpe,  String? notes,  bool isPR)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseLog() when $default != null:
return $default(_that.id,_that.date,_that.sets,_that.reps,_that.weightKg,_that.rpe,_that.notes,_that.isPR);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  int sets,  int reps,  double? weightKg,  int? rpe,  String? notes,  bool isPR)  $default,) {final _that = this;
switch (_that) {
case _ExerciseLog():
return $default(_that.id,_that.date,_that.sets,_that.reps,_that.weightKg,_that.rpe,_that.notes,_that.isPR);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  int sets,  int reps,  double? weightKg,  int? rpe,  String? notes,  bool isPR)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseLog() when $default != null:
return $default(_that.id,_that.date,_that.sets,_that.reps,_that.weightKg,_that.rpe,_that.notes,_that.isPR);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseLog extends ExerciseLog {
  const _ExerciseLog({required this.id, required this.date, required this.sets, required this.reps, this.weightKg, this.rpe, this.notes, this.isPR = false}): super._();
  factory _ExerciseLog.fromJson(Map<String, dynamic> json) => _$ExerciseLogFromJson(json);

@override final  String id;
@override final  DateTime date;
@override final  int sets;
@override final  int reps;
@override final  double? weightKg;
@override final  int? rpe;
// Rate of Perceived Exertion (1-10)
@override final  String? notes;
@override@JsonKey() final  bool isPR;

/// Create a copy of ExerciseLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseLogCopyWith<_ExerciseLog> get copyWith => __$ExerciseLogCopyWithImpl<_ExerciseLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseLog&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isPR, isPR) || other.isPR == isPR));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,sets,reps,weightKg,rpe,notes,isPR);

@override
String toString() {
  return 'ExerciseLog(id: $id, date: $date, sets: $sets, reps: $reps, weightKg: $weightKg, rpe: $rpe, notes: $notes, isPR: $isPR)';
}


}

/// @nodoc
abstract mixin class _$ExerciseLogCopyWith<$Res> implements $ExerciseLogCopyWith<$Res> {
  factory _$ExerciseLogCopyWith(_ExerciseLog value, $Res Function(_ExerciseLog) _then) = __$ExerciseLogCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, int sets, int reps, double? weightKg, int? rpe, String? notes, bool isPR
});




}
/// @nodoc
class __$ExerciseLogCopyWithImpl<$Res>
    implements _$ExerciseLogCopyWith<$Res> {
  __$ExerciseLogCopyWithImpl(this._self, this._then);

  final _ExerciseLog _self;
  final $Res Function(_ExerciseLog) _then;

/// Create a copy of ExerciseLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? sets = null,Object? reps = null,Object? weightKg = freezed,Object? rpe = freezed,Object? notes = freezed,Object? isPR = null,}) {
  return _then(_ExerciseLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isPR: null == isPR ? _self.isPR : isPR // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$StudentProgress {

 String get studentId; String get studentName; String? get studentAvatarUrl;// === Métricas gerais ===
 int get totalWorkouts; int get totalSessions; int get totalMinutes; int get currentStreak; int get longestStreak;// === Frequência ===
 int get sessionsThisWeek; int get sessionsThisMonth; double? get averageSessionsPerWeek;// === Evolução ===
 Map<String, ExerciseProgress> get exerciseProgress; List<ProgressMilestone> get milestones;// === Notas do trainer ===
 String? get trainerNotes; DateTime? get lastEvaluation;// === Próximas ações sugeridas pela IA ===
 List<AISuggestion> get aiSuggestions;
/// Create a copy of StudentProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentProgressCopyWith<StudentProgress> get copyWith => _$StudentProgressCopyWithImpl<StudentProgress>(this as StudentProgress, _$identity);

  /// Serializes this StudentProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentProgress&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentAvatarUrl, studentAvatarUrl) || other.studentAvatarUrl == studentAvatarUrl)&&(identical(other.totalWorkouts, totalWorkouts) || other.totalWorkouts == totalWorkouts)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.totalMinutes, totalMinutes) || other.totalMinutes == totalMinutes)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.sessionsThisWeek, sessionsThisWeek) || other.sessionsThisWeek == sessionsThisWeek)&&(identical(other.sessionsThisMonth, sessionsThisMonth) || other.sessionsThisMonth == sessionsThisMonth)&&(identical(other.averageSessionsPerWeek, averageSessionsPerWeek) || other.averageSessionsPerWeek == averageSessionsPerWeek)&&const DeepCollectionEquality().equals(other.exerciseProgress, exerciseProgress)&&const DeepCollectionEquality().equals(other.milestones, milestones)&&(identical(other.trainerNotes, trainerNotes) || other.trainerNotes == trainerNotes)&&(identical(other.lastEvaluation, lastEvaluation) || other.lastEvaluation == lastEvaluation)&&const DeepCollectionEquality().equals(other.aiSuggestions, aiSuggestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,studentId,studentName,studentAvatarUrl,totalWorkouts,totalSessions,totalMinutes,currentStreak,longestStreak,sessionsThisWeek,sessionsThisMonth,averageSessionsPerWeek,const DeepCollectionEquality().hash(exerciseProgress),const DeepCollectionEquality().hash(milestones),trainerNotes,lastEvaluation,const DeepCollectionEquality().hash(aiSuggestions));

@override
String toString() {
  return 'StudentProgress(studentId: $studentId, studentName: $studentName, studentAvatarUrl: $studentAvatarUrl, totalWorkouts: $totalWorkouts, totalSessions: $totalSessions, totalMinutes: $totalMinutes, currentStreak: $currentStreak, longestStreak: $longestStreak, sessionsThisWeek: $sessionsThisWeek, sessionsThisMonth: $sessionsThisMonth, averageSessionsPerWeek: $averageSessionsPerWeek, exerciseProgress: $exerciseProgress, milestones: $milestones, trainerNotes: $trainerNotes, lastEvaluation: $lastEvaluation, aiSuggestions: $aiSuggestions)';
}


}

/// @nodoc
abstract mixin class $StudentProgressCopyWith<$Res>  {
  factory $StudentProgressCopyWith(StudentProgress value, $Res Function(StudentProgress) _then) = _$StudentProgressCopyWithImpl;
@useResult
$Res call({
 String studentId, String studentName, String? studentAvatarUrl, int totalWorkouts, int totalSessions, int totalMinutes, int currentStreak, int longestStreak, int sessionsThisWeek, int sessionsThisMonth, double? averageSessionsPerWeek, Map<String, ExerciseProgress> exerciseProgress, List<ProgressMilestone> milestones, String? trainerNotes, DateTime? lastEvaluation, List<AISuggestion> aiSuggestions
});




}
/// @nodoc
class _$StudentProgressCopyWithImpl<$Res>
    implements $StudentProgressCopyWith<$Res> {
  _$StudentProgressCopyWithImpl(this._self, this._then);

  final StudentProgress _self;
  final $Res Function(StudentProgress) _then;

/// Create a copy of StudentProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? studentId = null,Object? studentName = null,Object? studentAvatarUrl = freezed,Object? totalWorkouts = null,Object? totalSessions = null,Object? totalMinutes = null,Object? currentStreak = null,Object? longestStreak = null,Object? sessionsThisWeek = null,Object? sessionsThisMonth = null,Object? averageSessionsPerWeek = freezed,Object? exerciseProgress = null,Object? milestones = null,Object? trainerNotes = freezed,Object? lastEvaluation = freezed,Object? aiSuggestions = null,}) {
  return _then(_self.copyWith(
studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,studentName: null == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String,studentAvatarUrl: freezed == studentAvatarUrl ? _self.studentAvatarUrl : studentAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,totalWorkouts: null == totalWorkouts ? _self.totalWorkouts : totalWorkouts // ignore: cast_nullable_to_non_nullable
as int,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,totalMinutes: null == totalMinutes ? _self.totalMinutes : totalMinutes // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,sessionsThisWeek: null == sessionsThisWeek ? _self.sessionsThisWeek : sessionsThisWeek // ignore: cast_nullable_to_non_nullable
as int,sessionsThisMonth: null == sessionsThisMonth ? _self.sessionsThisMonth : sessionsThisMonth // ignore: cast_nullable_to_non_nullable
as int,averageSessionsPerWeek: freezed == averageSessionsPerWeek ? _self.averageSessionsPerWeek : averageSessionsPerWeek // ignore: cast_nullable_to_non_nullable
as double?,exerciseProgress: null == exerciseProgress ? _self.exerciseProgress : exerciseProgress // ignore: cast_nullable_to_non_nullable
as Map<String, ExerciseProgress>,milestones: null == milestones ? _self.milestones : milestones // ignore: cast_nullable_to_non_nullable
as List<ProgressMilestone>,trainerNotes: freezed == trainerNotes ? _self.trainerNotes : trainerNotes // ignore: cast_nullable_to_non_nullable
as String?,lastEvaluation: freezed == lastEvaluation ? _self.lastEvaluation : lastEvaluation // ignore: cast_nullable_to_non_nullable
as DateTime?,aiSuggestions: null == aiSuggestions ? _self.aiSuggestions : aiSuggestions // ignore: cast_nullable_to_non_nullable
as List<AISuggestion>,
  ));
}

}


/// Adds pattern-matching-related methods to [StudentProgress].
extension StudentProgressPatterns on StudentProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentProgress value)  $default,){
final _that = this;
switch (_that) {
case _StudentProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentProgress value)?  $default,){
final _that = this;
switch (_that) {
case _StudentProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String studentId,  String studentName,  String? studentAvatarUrl,  int totalWorkouts,  int totalSessions,  int totalMinutes,  int currentStreak,  int longestStreak,  int sessionsThisWeek,  int sessionsThisMonth,  double? averageSessionsPerWeek,  Map<String, ExerciseProgress> exerciseProgress,  List<ProgressMilestone> milestones,  String? trainerNotes,  DateTime? lastEvaluation,  List<AISuggestion> aiSuggestions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentProgress() when $default != null:
return $default(_that.studentId,_that.studentName,_that.studentAvatarUrl,_that.totalWorkouts,_that.totalSessions,_that.totalMinutes,_that.currentStreak,_that.longestStreak,_that.sessionsThisWeek,_that.sessionsThisMonth,_that.averageSessionsPerWeek,_that.exerciseProgress,_that.milestones,_that.trainerNotes,_that.lastEvaluation,_that.aiSuggestions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String studentId,  String studentName,  String? studentAvatarUrl,  int totalWorkouts,  int totalSessions,  int totalMinutes,  int currentStreak,  int longestStreak,  int sessionsThisWeek,  int sessionsThisMonth,  double? averageSessionsPerWeek,  Map<String, ExerciseProgress> exerciseProgress,  List<ProgressMilestone> milestones,  String? trainerNotes,  DateTime? lastEvaluation,  List<AISuggestion> aiSuggestions)  $default,) {final _that = this;
switch (_that) {
case _StudentProgress():
return $default(_that.studentId,_that.studentName,_that.studentAvatarUrl,_that.totalWorkouts,_that.totalSessions,_that.totalMinutes,_that.currentStreak,_that.longestStreak,_that.sessionsThisWeek,_that.sessionsThisMonth,_that.averageSessionsPerWeek,_that.exerciseProgress,_that.milestones,_that.trainerNotes,_that.lastEvaluation,_that.aiSuggestions);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String studentId,  String studentName,  String? studentAvatarUrl,  int totalWorkouts,  int totalSessions,  int totalMinutes,  int currentStreak,  int longestStreak,  int sessionsThisWeek,  int sessionsThisMonth,  double? averageSessionsPerWeek,  Map<String, ExerciseProgress> exerciseProgress,  List<ProgressMilestone> milestones,  String? trainerNotes,  DateTime? lastEvaluation,  List<AISuggestion> aiSuggestions)?  $default,) {final _that = this;
switch (_that) {
case _StudentProgress() when $default != null:
return $default(_that.studentId,_that.studentName,_that.studentAvatarUrl,_that.totalWorkouts,_that.totalSessions,_that.totalMinutes,_that.currentStreak,_that.longestStreak,_that.sessionsThisWeek,_that.sessionsThisMonth,_that.averageSessionsPerWeek,_that.exerciseProgress,_that.milestones,_that.trainerNotes,_that.lastEvaluation,_that.aiSuggestions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentProgress extends StudentProgress {
  const _StudentProgress({required this.studentId, required this.studentName, this.studentAvatarUrl, this.totalWorkouts = 0, this.totalSessions = 0, this.totalMinutes = 0, this.currentStreak = 0, this.longestStreak = 0, this.sessionsThisWeek = 0, this.sessionsThisMonth = 0, this.averageSessionsPerWeek, final  Map<String, ExerciseProgress> exerciseProgress = const {}, final  List<ProgressMilestone> milestones = const [], this.trainerNotes, this.lastEvaluation, final  List<AISuggestion> aiSuggestions = const []}): _exerciseProgress = exerciseProgress,_milestones = milestones,_aiSuggestions = aiSuggestions,super._();
  factory _StudentProgress.fromJson(Map<String, dynamic> json) => _$StudentProgressFromJson(json);

@override final  String studentId;
@override final  String studentName;
@override final  String? studentAvatarUrl;
// === Métricas gerais ===
@override@JsonKey() final  int totalWorkouts;
@override@JsonKey() final  int totalSessions;
@override@JsonKey() final  int totalMinutes;
@override@JsonKey() final  int currentStreak;
@override@JsonKey() final  int longestStreak;
// === Frequência ===
@override@JsonKey() final  int sessionsThisWeek;
@override@JsonKey() final  int sessionsThisMonth;
@override final  double? averageSessionsPerWeek;
// === Evolução ===
 final  Map<String, ExerciseProgress> _exerciseProgress;
// === Evolução ===
@override@JsonKey() Map<String, ExerciseProgress> get exerciseProgress {
  if (_exerciseProgress is EqualUnmodifiableMapView) return _exerciseProgress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_exerciseProgress);
}

 final  List<ProgressMilestone> _milestones;
@override@JsonKey() List<ProgressMilestone> get milestones {
  if (_milestones is EqualUnmodifiableListView) return _milestones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_milestones);
}

// === Notas do trainer ===
@override final  String? trainerNotes;
@override final  DateTime? lastEvaluation;
// === Próximas ações sugeridas pela IA ===
 final  List<AISuggestion> _aiSuggestions;
// === Próximas ações sugeridas pela IA ===
@override@JsonKey() List<AISuggestion> get aiSuggestions {
  if (_aiSuggestions is EqualUnmodifiableListView) return _aiSuggestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aiSuggestions);
}


/// Create a copy of StudentProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentProgressCopyWith<_StudentProgress> get copyWith => __$StudentProgressCopyWithImpl<_StudentProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentProgress&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentAvatarUrl, studentAvatarUrl) || other.studentAvatarUrl == studentAvatarUrl)&&(identical(other.totalWorkouts, totalWorkouts) || other.totalWorkouts == totalWorkouts)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.totalMinutes, totalMinutes) || other.totalMinutes == totalMinutes)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.sessionsThisWeek, sessionsThisWeek) || other.sessionsThisWeek == sessionsThisWeek)&&(identical(other.sessionsThisMonth, sessionsThisMonth) || other.sessionsThisMonth == sessionsThisMonth)&&(identical(other.averageSessionsPerWeek, averageSessionsPerWeek) || other.averageSessionsPerWeek == averageSessionsPerWeek)&&const DeepCollectionEquality().equals(other._exerciseProgress, _exerciseProgress)&&const DeepCollectionEquality().equals(other._milestones, _milestones)&&(identical(other.trainerNotes, trainerNotes) || other.trainerNotes == trainerNotes)&&(identical(other.lastEvaluation, lastEvaluation) || other.lastEvaluation == lastEvaluation)&&const DeepCollectionEquality().equals(other._aiSuggestions, _aiSuggestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,studentId,studentName,studentAvatarUrl,totalWorkouts,totalSessions,totalMinutes,currentStreak,longestStreak,sessionsThisWeek,sessionsThisMonth,averageSessionsPerWeek,const DeepCollectionEquality().hash(_exerciseProgress),const DeepCollectionEquality().hash(_milestones),trainerNotes,lastEvaluation,const DeepCollectionEquality().hash(_aiSuggestions));

@override
String toString() {
  return 'StudentProgress(studentId: $studentId, studentName: $studentName, studentAvatarUrl: $studentAvatarUrl, totalWorkouts: $totalWorkouts, totalSessions: $totalSessions, totalMinutes: $totalMinutes, currentStreak: $currentStreak, longestStreak: $longestStreak, sessionsThisWeek: $sessionsThisWeek, sessionsThisMonth: $sessionsThisMonth, averageSessionsPerWeek: $averageSessionsPerWeek, exerciseProgress: $exerciseProgress, milestones: $milestones, trainerNotes: $trainerNotes, lastEvaluation: $lastEvaluation, aiSuggestions: $aiSuggestions)';
}


}

/// @nodoc
abstract mixin class _$StudentProgressCopyWith<$Res> implements $StudentProgressCopyWith<$Res> {
  factory _$StudentProgressCopyWith(_StudentProgress value, $Res Function(_StudentProgress) _then) = __$StudentProgressCopyWithImpl;
@override @useResult
$Res call({
 String studentId, String studentName, String? studentAvatarUrl, int totalWorkouts, int totalSessions, int totalMinutes, int currentStreak, int longestStreak, int sessionsThisWeek, int sessionsThisMonth, double? averageSessionsPerWeek, Map<String, ExerciseProgress> exerciseProgress, List<ProgressMilestone> milestones, String? trainerNotes, DateTime? lastEvaluation, List<AISuggestion> aiSuggestions
});




}
/// @nodoc
class __$StudentProgressCopyWithImpl<$Res>
    implements _$StudentProgressCopyWith<$Res> {
  __$StudentProgressCopyWithImpl(this._self, this._then);

  final _StudentProgress _self;
  final $Res Function(_StudentProgress) _then;

/// Create a copy of StudentProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? studentId = null,Object? studentName = null,Object? studentAvatarUrl = freezed,Object? totalWorkouts = null,Object? totalSessions = null,Object? totalMinutes = null,Object? currentStreak = null,Object? longestStreak = null,Object? sessionsThisWeek = null,Object? sessionsThisMonth = null,Object? averageSessionsPerWeek = freezed,Object? exerciseProgress = null,Object? milestones = null,Object? trainerNotes = freezed,Object? lastEvaluation = freezed,Object? aiSuggestions = null,}) {
  return _then(_StudentProgress(
studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,studentName: null == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String,studentAvatarUrl: freezed == studentAvatarUrl ? _self.studentAvatarUrl : studentAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,totalWorkouts: null == totalWorkouts ? _self.totalWorkouts : totalWorkouts // ignore: cast_nullable_to_non_nullable
as int,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,totalMinutes: null == totalMinutes ? _self.totalMinutes : totalMinutes // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,sessionsThisWeek: null == sessionsThisWeek ? _self.sessionsThisWeek : sessionsThisWeek // ignore: cast_nullable_to_non_nullable
as int,sessionsThisMonth: null == sessionsThisMonth ? _self.sessionsThisMonth : sessionsThisMonth // ignore: cast_nullable_to_non_nullable
as int,averageSessionsPerWeek: freezed == averageSessionsPerWeek ? _self.averageSessionsPerWeek : averageSessionsPerWeek // ignore: cast_nullable_to_non_nullable
as double?,exerciseProgress: null == exerciseProgress ? _self._exerciseProgress : exerciseProgress // ignore: cast_nullable_to_non_nullable
as Map<String, ExerciseProgress>,milestones: null == milestones ? _self._milestones : milestones // ignore: cast_nullable_to_non_nullable
as List<ProgressMilestone>,trainerNotes: freezed == trainerNotes ? _self.trainerNotes : trainerNotes // ignore: cast_nullable_to_non_nullable
as String?,lastEvaluation: freezed == lastEvaluation ? _self.lastEvaluation : lastEvaluation // ignore: cast_nullable_to_non_nullable
as DateTime?,aiSuggestions: null == aiSuggestions ? _self._aiSuggestions : aiSuggestions // ignore: cast_nullable_to_non_nullable
as List<AISuggestion>,
  ));
}


}


/// @nodoc
mixin _$ProgressMilestone {

 String get id; String get title; String get description; DateTime get achievedAt; String? get icon; String? get exerciseId; double? get value; String? get unit;
/// Create a copy of ProgressMilestone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressMilestoneCopyWith<ProgressMilestone> get copyWith => _$ProgressMilestoneCopyWithImpl<ProgressMilestone>(this as ProgressMilestone, _$identity);

  /// Serializes this ProgressMilestone to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgressMilestone&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,achievedAt,icon,exerciseId,value,unit);

@override
String toString() {
  return 'ProgressMilestone(id: $id, title: $title, description: $description, achievedAt: $achievedAt, icon: $icon, exerciseId: $exerciseId, value: $value, unit: $unit)';
}


}

/// @nodoc
abstract mixin class $ProgressMilestoneCopyWith<$Res>  {
  factory $ProgressMilestoneCopyWith(ProgressMilestone value, $Res Function(ProgressMilestone) _then) = _$ProgressMilestoneCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, DateTime achievedAt, String? icon, String? exerciseId, double? value, String? unit
});




}
/// @nodoc
class _$ProgressMilestoneCopyWithImpl<$Res>
    implements $ProgressMilestoneCopyWith<$Res> {
  _$ProgressMilestoneCopyWithImpl(this._self, this._then);

  final ProgressMilestone _self;
  final $Res Function(ProgressMilestone) _then;

/// Create a copy of ProgressMilestone
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? achievedAt = null,Object? icon = freezed,Object? exerciseId = freezed,Object? value = freezed,Object? unit = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,achievedAt: null == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,exerciseId: freezed == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgressMilestone].
extension ProgressMilestonePatterns on ProgressMilestone {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgressMilestone value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgressMilestone() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgressMilestone value)  $default,){
final _that = this;
switch (_that) {
case _ProgressMilestone():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgressMilestone value)?  $default,){
final _that = this;
switch (_that) {
case _ProgressMilestone() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  DateTime achievedAt,  String? icon,  String? exerciseId,  double? value,  String? unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgressMilestone() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.achievedAt,_that.icon,_that.exerciseId,_that.value,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  DateTime achievedAt,  String? icon,  String? exerciseId,  double? value,  String? unit)  $default,) {final _that = this;
switch (_that) {
case _ProgressMilestone():
return $default(_that.id,_that.title,_that.description,_that.achievedAt,_that.icon,_that.exerciseId,_that.value,_that.unit);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  DateTime achievedAt,  String? icon,  String? exerciseId,  double? value,  String? unit)?  $default,) {final _that = this;
switch (_that) {
case _ProgressMilestone() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.achievedAt,_that.icon,_that.exerciseId,_that.value,_that.unit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProgressMilestone extends ProgressMilestone {
  const _ProgressMilestone({required this.id, required this.title, required this.description, required this.achievedAt, this.icon, this.exerciseId, this.value, this.unit}): super._();
  factory _ProgressMilestone.fromJson(Map<String, dynamic> json) => _$ProgressMilestoneFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  DateTime achievedAt;
@override final  String? icon;
@override final  String? exerciseId;
@override final  double? value;
@override final  String? unit;

/// Create a copy of ProgressMilestone
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressMilestoneCopyWith<_ProgressMilestone> get copyWith => __$ProgressMilestoneCopyWithImpl<_ProgressMilestone>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProgressMilestoneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgressMilestone&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,achievedAt,icon,exerciseId,value,unit);

@override
String toString() {
  return 'ProgressMilestone(id: $id, title: $title, description: $description, achievedAt: $achievedAt, icon: $icon, exerciseId: $exerciseId, value: $value, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$ProgressMilestoneCopyWith<$Res> implements $ProgressMilestoneCopyWith<$Res> {
  factory _$ProgressMilestoneCopyWith(_ProgressMilestone value, $Res Function(_ProgressMilestone) _then) = __$ProgressMilestoneCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, DateTime achievedAt, String? icon, String? exerciseId, double? value, String? unit
});




}
/// @nodoc
class __$ProgressMilestoneCopyWithImpl<$Res>
    implements _$ProgressMilestoneCopyWith<$Res> {
  __$ProgressMilestoneCopyWithImpl(this._self, this._then);

  final _ProgressMilestone _self;
  final $Res Function(_ProgressMilestone) _then;

/// Create a copy of ProgressMilestone
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? achievedAt = null,Object? icon = freezed,Object? exerciseId = freezed,Object? value = freezed,Object? unit = freezed,}) {
  return _then(_ProgressMilestone(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,achievedAt: null == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,exerciseId: freezed == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AISuggestion {

 String get id; AISuggestionType get type; String get title; String get description; String get rationale;// === Dados específicos ===
 String? get exerciseId; String? get exerciseName; double? get suggestedWeight; int? get suggestedReps; int? get suggestedSets;// === Novo exercício sugerido ===
 String? get newExerciseId; String? get newExerciseName; String? get replacesExerciseId;// === Meta ===
 DateTime get createdAt; bool get applied; bool get dismissed; String? get dismissReason;
/// Create a copy of AISuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AISuggestionCopyWith<AISuggestion> get copyWith => _$AISuggestionCopyWithImpl<AISuggestion>(this as AISuggestion, _$identity);

  /// Serializes this AISuggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AISuggestion&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.rationale, rationale) || other.rationale == rationale)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.suggestedWeight, suggestedWeight) || other.suggestedWeight == suggestedWeight)&&(identical(other.suggestedReps, suggestedReps) || other.suggestedReps == suggestedReps)&&(identical(other.suggestedSets, suggestedSets) || other.suggestedSets == suggestedSets)&&(identical(other.newExerciseId, newExerciseId) || other.newExerciseId == newExerciseId)&&(identical(other.newExerciseName, newExerciseName) || other.newExerciseName == newExerciseName)&&(identical(other.replacesExerciseId, replacesExerciseId) || other.replacesExerciseId == replacesExerciseId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.applied, applied) || other.applied == applied)&&(identical(other.dismissed, dismissed) || other.dismissed == dismissed)&&(identical(other.dismissReason, dismissReason) || other.dismissReason == dismissReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,description,rationale,exerciseId,exerciseName,suggestedWeight,suggestedReps,suggestedSets,newExerciseId,newExerciseName,replacesExerciseId,createdAt,applied,dismissed,dismissReason);

@override
String toString() {
  return 'AISuggestion(id: $id, type: $type, title: $title, description: $description, rationale: $rationale, exerciseId: $exerciseId, exerciseName: $exerciseName, suggestedWeight: $suggestedWeight, suggestedReps: $suggestedReps, suggestedSets: $suggestedSets, newExerciseId: $newExerciseId, newExerciseName: $newExerciseName, replacesExerciseId: $replacesExerciseId, createdAt: $createdAt, applied: $applied, dismissed: $dismissed, dismissReason: $dismissReason)';
}


}

/// @nodoc
abstract mixin class $AISuggestionCopyWith<$Res>  {
  factory $AISuggestionCopyWith(AISuggestion value, $Res Function(AISuggestion) _then) = _$AISuggestionCopyWithImpl;
@useResult
$Res call({
 String id, AISuggestionType type, String title, String description, String rationale, String? exerciseId, String? exerciseName, double? suggestedWeight, int? suggestedReps, int? suggestedSets, String? newExerciseId, String? newExerciseName, String? replacesExerciseId, DateTime createdAt, bool applied, bool dismissed, String? dismissReason
});




}
/// @nodoc
class _$AISuggestionCopyWithImpl<$Res>
    implements $AISuggestionCopyWith<$Res> {
  _$AISuggestionCopyWithImpl(this._self, this._then);

  final AISuggestion _self;
  final $Res Function(AISuggestion) _then;

/// Create a copy of AISuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = null,Object? description = null,Object? rationale = null,Object? exerciseId = freezed,Object? exerciseName = freezed,Object? suggestedWeight = freezed,Object? suggestedReps = freezed,Object? suggestedSets = freezed,Object? newExerciseId = freezed,Object? newExerciseName = freezed,Object? replacesExerciseId = freezed,Object? createdAt = null,Object? applied = null,Object? dismissed = null,Object? dismissReason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AISuggestionType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,exerciseId: freezed == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String?,exerciseName: freezed == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String?,suggestedWeight: freezed == suggestedWeight ? _self.suggestedWeight : suggestedWeight // ignore: cast_nullable_to_non_nullable
as double?,suggestedReps: freezed == suggestedReps ? _self.suggestedReps : suggestedReps // ignore: cast_nullable_to_non_nullable
as int?,suggestedSets: freezed == suggestedSets ? _self.suggestedSets : suggestedSets // ignore: cast_nullable_to_non_nullable
as int?,newExerciseId: freezed == newExerciseId ? _self.newExerciseId : newExerciseId // ignore: cast_nullable_to_non_nullable
as String?,newExerciseName: freezed == newExerciseName ? _self.newExerciseName : newExerciseName // ignore: cast_nullable_to_non_nullable
as String?,replacesExerciseId: freezed == replacesExerciseId ? _self.replacesExerciseId : replacesExerciseId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,applied: null == applied ? _self.applied : applied // ignore: cast_nullable_to_non_nullable
as bool,dismissed: null == dismissed ? _self.dismissed : dismissed // ignore: cast_nullable_to_non_nullable
as bool,dismissReason: freezed == dismissReason ? _self.dismissReason : dismissReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AISuggestion].
extension AISuggestionPatterns on AISuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AISuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AISuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AISuggestion value)  $default,){
final _that = this;
switch (_that) {
case _AISuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AISuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _AISuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AISuggestionType type,  String title,  String description,  String rationale,  String? exerciseId,  String? exerciseName,  double? suggestedWeight,  int? suggestedReps,  int? suggestedSets,  String? newExerciseId,  String? newExerciseName,  String? replacesExerciseId,  DateTime createdAt,  bool applied,  bool dismissed,  String? dismissReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AISuggestion() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.description,_that.rationale,_that.exerciseId,_that.exerciseName,_that.suggestedWeight,_that.suggestedReps,_that.suggestedSets,_that.newExerciseId,_that.newExerciseName,_that.replacesExerciseId,_that.createdAt,_that.applied,_that.dismissed,_that.dismissReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AISuggestionType type,  String title,  String description,  String rationale,  String? exerciseId,  String? exerciseName,  double? suggestedWeight,  int? suggestedReps,  int? suggestedSets,  String? newExerciseId,  String? newExerciseName,  String? replacesExerciseId,  DateTime createdAt,  bool applied,  bool dismissed,  String? dismissReason)  $default,) {final _that = this;
switch (_that) {
case _AISuggestion():
return $default(_that.id,_that.type,_that.title,_that.description,_that.rationale,_that.exerciseId,_that.exerciseName,_that.suggestedWeight,_that.suggestedReps,_that.suggestedSets,_that.newExerciseId,_that.newExerciseName,_that.replacesExerciseId,_that.createdAt,_that.applied,_that.dismissed,_that.dismissReason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AISuggestionType type,  String title,  String description,  String rationale,  String? exerciseId,  String? exerciseName,  double? suggestedWeight,  int? suggestedReps,  int? suggestedSets,  String? newExerciseId,  String? newExerciseName,  String? replacesExerciseId,  DateTime createdAt,  bool applied,  bool dismissed,  String? dismissReason)?  $default,) {final _that = this;
switch (_that) {
case _AISuggestion() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.description,_that.rationale,_that.exerciseId,_that.exerciseName,_that.suggestedWeight,_that.suggestedReps,_that.suggestedSets,_that.newExerciseId,_that.newExerciseName,_that.replacesExerciseId,_that.createdAt,_that.applied,_that.dismissed,_that.dismissReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AISuggestion extends AISuggestion {
  const _AISuggestion({required this.id, required this.type, required this.title, required this.description, required this.rationale, this.exerciseId, this.exerciseName, this.suggestedWeight, this.suggestedReps, this.suggestedSets, this.newExerciseId, this.newExerciseName, this.replacesExerciseId, required this.createdAt, this.applied = false, this.dismissed = false, this.dismissReason}): super._();
  factory _AISuggestion.fromJson(Map<String, dynamic> json) => _$AISuggestionFromJson(json);

@override final  String id;
@override final  AISuggestionType type;
@override final  String title;
@override final  String description;
@override final  String rationale;
// === Dados específicos ===
@override final  String? exerciseId;
@override final  String? exerciseName;
@override final  double? suggestedWeight;
@override final  int? suggestedReps;
@override final  int? suggestedSets;
// === Novo exercício sugerido ===
@override final  String? newExerciseId;
@override final  String? newExerciseName;
@override final  String? replacesExerciseId;
// === Meta ===
@override final  DateTime createdAt;
@override@JsonKey() final  bool applied;
@override@JsonKey() final  bool dismissed;
@override final  String? dismissReason;

/// Create a copy of AISuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AISuggestionCopyWith<_AISuggestion> get copyWith => __$AISuggestionCopyWithImpl<_AISuggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AISuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AISuggestion&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.rationale, rationale) || other.rationale == rationale)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.suggestedWeight, suggestedWeight) || other.suggestedWeight == suggestedWeight)&&(identical(other.suggestedReps, suggestedReps) || other.suggestedReps == suggestedReps)&&(identical(other.suggestedSets, suggestedSets) || other.suggestedSets == suggestedSets)&&(identical(other.newExerciseId, newExerciseId) || other.newExerciseId == newExerciseId)&&(identical(other.newExerciseName, newExerciseName) || other.newExerciseName == newExerciseName)&&(identical(other.replacesExerciseId, replacesExerciseId) || other.replacesExerciseId == replacesExerciseId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.applied, applied) || other.applied == applied)&&(identical(other.dismissed, dismissed) || other.dismissed == dismissed)&&(identical(other.dismissReason, dismissReason) || other.dismissReason == dismissReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,description,rationale,exerciseId,exerciseName,suggestedWeight,suggestedReps,suggestedSets,newExerciseId,newExerciseName,replacesExerciseId,createdAt,applied,dismissed,dismissReason);

@override
String toString() {
  return 'AISuggestion(id: $id, type: $type, title: $title, description: $description, rationale: $rationale, exerciseId: $exerciseId, exerciseName: $exerciseName, suggestedWeight: $suggestedWeight, suggestedReps: $suggestedReps, suggestedSets: $suggestedSets, newExerciseId: $newExerciseId, newExerciseName: $newExerciseName, replacesExerciseId: $replacesExerciseId, createdAt: $createdAt, applied: $applied, dismissed: $dismissed, dismissReason: $dismissReason)';
}


}

/// @nodoc
abstract mixin class _$AISuggestionCopyWith<$Res> implements $AISuggestionCopyWith<$Res> {
  factory _$AISuggestionCopyWith(_AISuggestion value, $Res Function(_AISuggestion) _then) = __$AISuggestionCopyWithImpl;
@override @useResult
$Res call({
 String id, AISuggestionType type, String title, String description, String rationale, String? exerciseId, String? exerciseName, double? suggestedWeight, int? suggestedReps, int? suggestedSets, String? newExerciseId, String? newExerciseName, String? replacesExerciseId, DateTime createdAt, bool applied, bool dismissed, String? dismissReason
});




}
/// @nodoc
class __$AISuggestionCopyWithImpl<$Res>
    implements _$AISuggestionCopyWith<$Res> {
  __$AISuggestionCopyWithImpl(this._self, this._then);

  final _AISuggestion _self;
  final $Res Function(_AISuggestion) _then;

/// Create a copy of AISuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = null,Object? description = null,Object? rationale = null,Object? exerciseId = freezed,Object? exerciseName = freezed,Object? suggestedWeight = freezed,Object? suggestedReps = freezed,Object? suggestedSets = freezed,Object? newExerciseId = freezed,Object? newExerciseName = freezed,Object? replacesExerciseId = freezed,Object? createdAt = null,Object? applied = null,Object? dismissed = null,Object? dismissReason = freezed,}) {
  return _then(_AISuggestion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AISuggestionType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,exerciseId: freezed == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String?,exerciseName: freezed == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String?,suggestedWeight: freezed == suggestedWeight ? _self.suggestedWeight : suggestedWeight // ignore: cast_nullable_to_non_nullable
as double?,suggestedReps: freezed == suggestedReps ? _self.suggestedReps : suggestedReps // ignore: cast_nullable_to_non_nullable
as int?,suggestedSets: freezed == suggestedSets ? _self.suggestedSets : suggestedSets // ignore: cast_nullable_to_non_nullable
as int?,newExerciseId: freezed == newExerciseId ? _self.newExerciseId : newExerciseId // ignore: cast_nullable_to_non_nullable
as String?,newExerciseName: freezed == newExerciseName ? _self.newExerciseName : newExerciseName // ignore: cast_nullable_to_non_nullable
as String?,replacesExerciseId: freezed == replacesExerciseId ? _self.replacesExerciseId : replacesExerciseId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,applied: null == applied ? _self.applied : applied // ignore: cast_nullable_to_non_nullable
as bool,dismissed: null == dismissed ? _self.dismissed : dismissed // ignore: cast_nullable_to_non_nullable
as bool,dismissReason: freezed == dismissReason ? _self.dismissReason : dismissReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
