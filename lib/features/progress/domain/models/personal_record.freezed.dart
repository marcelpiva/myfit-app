// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'personal_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PersonalRecord {

 String get id;@JsonKey(name: 'exercise_id') String get exerciseId;@JsonKey(name: 'exercise_name') String get exerciseName;@JsonKey(name: 'student_id') String get studentId; PRType get type; double get value;@JsonKey(name: 'achieved_at') DateTime get achievedAt;@JsonKey(name: 'previous_value') double? get previousValue;@JsonKey(name: 'previous_date') DateTime? get previousDate;@JsonKey(name: 'set_number') int? get setNumber; int? get reps;@JsonKey(name: 'weight_kg') double? get weightKg; String? get notes;@JsonKey(name: 'session_id') String? get sessionId;
/// Create a copy of PersonalRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonalRecordCopyWith<PersonalRecord> get copyWith => _$PersonalRecordCopyWithImpl<PersonalRecord>(this as PersonalRecord, _$identity);

  /// Serializes this PersonalRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonalRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt)&&(identical(other.previousValue, previousValue) || other.previousValue == previousValue)&&(identical(other.previousDate, previousDate) || other.previousDate == previousDate)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,exerciseName,studentId,type,value,achievedAt,previousValue,previousDate,setNumber,reps,weightKg,notes,sessionId);

@override
String toString() {
  return 'PersonalRecord(id: $id, exerciseId: $exerciseId, exerciseName: $exerciseName, studentId: $studentId, type: $type, value: $value, achievedAt: $achievedAt, previousValue: $previousValue, previousDate: $previousDate, setNumber: $setNumber, reps: $reps, weightKg: $weightKg, notes: $notes, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $PersonalRecordCopyWith<$Res>  {
  factory $PersonalRecordCopyWith(PersonalRecord value, $Res Function(PersonalRecord) _then) = _$PersonalRecordCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'exercise_id') String exerciseId,@JsonKey(name: 'exercise_name') String exerciseName,@JsonKey(name: 'student_id') String studentId, PRType type, double value,@JsonKey(name: 'achieved_at') DateTime achievedAt,@JsonKey(name: 'previous_value') double? previousValue,@JsonKey(name: 'previous_date') DateTime? previousDate,@JsonKey(name: 'set_number') int? setNumber, int? reps,@JsonKey(name: 'weight_kg') double? weightKg, String? notes,@JsonKey(name: 'session_id') String? sessionId
});




}
/// @nodoc
class _$PersonalRecordCopyWithImpl<$Res>
    implements $PersonalRecordCopyWith<$Res> {
  _$PersonalRecordCopyWithImpl(this._self, this._then);

  final PersonalRecord _self;
  final $Res Function(PersonalRecord) _then;

/// Create a copy of PersonalRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? exerciseName = null,Object? studentId = null,Object? type = null,Object? value = null,Object? achievedAt = null,Object? previousValue = freezed,Object? previousDate = freezed,Object? setNumber = freezed,Object? reps = freezed,Object? weightKg = freezed,Object? notes = freezed,Object? sessionId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PRType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,achievedAt: null == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime,previousValue: freezed == previousValue ? _self.previousValue : previousValue // ignore: cast_nullable_to_non_nullable
as double?,previousDate: freezed == previousDate ? _self.previousDate : previousDate // ignore: cast_nullable_to_non_nullable
as DateTime?,setNumber: freezed == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonalRecord].
extension PersonalRecordPatterns on PersonalRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonalRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonalRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonalRecord value)  $default,){
final _that = this;
switch (_that) {
case _PersonalRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonalRecord value)?  $default,){
final _that = this;
switch (_that) {
case _PersonalRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'exercise_name')  String exerciseName, @JsonKey(name: 'student_id')  String studentId,  PRType type,  double value, @JsonKey(name: 'achieved_at')  DateTime achievedAt, @JsonKey(name: 'previous_value')  double? previousValue, @JsonKey(name: 'previous_date')  DateTime? previousDate, @JsonKey(name: 'set_number')  int? setNumber,  int? reps, @JsonKey(name: 'weight_kg')  double? weightKg,  String? notes, @JsonKey(name: 'session_id')  String? sessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonalRecord() when $default != null:
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.studentId,_that.type,_that.value,_that.achievedAt,_that.previousValue,_that.previousDate,_that.setNumber,_that.reps,_that.weightKg,_that.notes,_that.sessionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'exercise_name')  String exerciseName, @JsonKey(name: 'student_id')  String studentId,  PRType type,  double value, @JsonKey(name: 'achieved_at')  DateTime achievedAt, @JsonKey(name: 'previous_value')  double? previousValue, @JsonKey(name: 'previous_date')  DateTime? previousDate, @JsonKey(name: 'set_number')  int? setNumber,  int? reps, @JsonKey(name: 'weight_kg')  double? weightKg,  String? notes, @JsonKey(name: 'session_id')  String? sessionId)  $default,) {final _that = this;
switch (_that) {
case _PersonalRecord():
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.studentId,_that.type,_that.value,_that.achievedAt,_that.previousValue,_that.previousDate,_that.setNumber,_that.reps,_that.weightKg,_that.notes,_that.sessionId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'exercise_name')  String exerciseName, @JsonKey(name: 'student_id')  String studentId,  PRType type,  double value, @JsonKey(name: 'achieved_at')  DateTime achievedAt, @JsonKey(name: 'previous_value')  double? previousValue, @JsonKey(name: 'previous_date')  DateTime? previousDate, @JsonKey(name: 'set_number')  int? setNumber,  int? reps, @JsonKey(name: 'weight_kg')  double? weightKg,  String? notes, @JsonKey(name: 'session_id')  String? sessionId)?  $default,) {final _that = this;
switch (_that) {
case _PersonalRecord() when $default != null:
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.studentId,_that.type,_that.value,_that.achievedAt,_that.previousValue,_that.previousDate,_that.setNumber,_that.reps,_that.weightKg,_that.notes,_that.sessionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PersonalRecord extends PersonalRecord {
  const _PersonalRecord({required this.id, @JsonKey(name: 'exercise_id') required this.exerciseId, @JsonKey(name: 'exercise_name') required this.exerciseName, @JsonKey(name: 'student_id') required this.studentId, required this.type, required this.value, @JsonKey(name: 'achieved_at') required this.achievedAt, @JsonKey(name: 'previous_value') this.previousValue, @JsonKey(name: 'previous_date') this.previousDate, @JsonKey(name: 'set_number') this.setNumber, this.reps, @JsonKey(name: 'weight_kg') this.weightKg, this.notes, @JsonKey(name: 'session_id') this.sessionId}): super._();
  factory _PersonalRecord.fromJson(Map<String, dynamic> json) => _$PersonalRecordFromJson(json);

@override final  String id;
@override@JsonKey(name: 'exercise_id') final  String exerciseId;
@override@JsonKey(name: 'exercise_name') final  String exerciseName;
@override@JsonKey(name: 'student_id') final  String studentId;
@override final  PRType type;
@override final  double value;
@override@JsonKey(name: 'achieved_at') final  DateTime achievedAt;
@override@JsonKey(name: 'previous_value') final  double? previousValue;
@override@JsonKey(name: 'previous_date') final  DateTime? previousDate;
@override@JsonKey(name: 'set_number') final  int? setNumber;
@override final  int? reps;
@override@JsonKey(name: 'weight_kg') final  double? weightKg;
@override final  String? notes;
@override@JsonKey(name: 'session_id') final  String? sessionId;

/// Create a copy of PersonalRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonalRecordCopyWith<_PersonalRecord> get copyWith => __$PersonalRecordCopyWithImpl<_PersonalRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonalRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonalRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt)&&(identical(other.previousValue, previousValue) || other.previousValue == previousValue)&&(identical(other.previousDate, previousDate) || other.previousDate == previousDate)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,exerciseName,studentId,type,value,achievedAt,previousValue,previousDate,setNumber,reps,weightKg,notes,sessionId);

@override
String toString() {
  return 'PersonalRecord(id: $id, exerciseId: $exerciseId, exerciseName: $exerciseName, studentId: $studentId, type: $type, value: $value, achievedAt: $achievedAt, previousValue: $previousValue, previousDate: $previousDate, setNumber: $setNumber, reps: $reps, weightKg: $weightKg, notes: $notes, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class _$PersonalRecordCopyWith<$Res> implements $PersonalRecordCopyWith<$Res> {
  factory _$PersonalRecordCopyWith(_PersonalRecord value, $Res Function(_PersonalRecord) _then) = __$PersonalRecordCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'exercise_id') String exerciseId,@JsonKey(name: 'exercise_name') String exerciseName,@JsonKey(name: 'student_id') String studentId, PRType type, double value,@JsonKey(name: 'achieved_at') DateTime achievedAt,@JsonKey(name: 'previous_value') double? previousValue,@JsonKey(name: 'previous_date') DateTime? previousDate,@JsonKey(name: 'set_number') int? setNumber, int? reps,@JsonKey(name: 'weight_kg') double? weightKg, String? notes,@JsonKey(name: 'session_id') String? sessionId
});




}
/// @nodoc
class __$PersonalRecordCopyWithImpl<$Res>
    implements _$PersonalRecordCopyWith<$Res> {
  __$PersonalRecordCopyWithImpl(this._self, this._then);

  final _PersonalRecord _self;
  final $Res Function(_PersonalRecord) _then;

/// Create a copy of PersonalRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? exerciseName = null,Object? studentId = null,Object? type = null,Object? value = null,Object? achievedAt = null,Object? previousValue = freezed,Object? previousDate = freezed,Object? setNumber = freezed,Object? reps = freezed,Object? weightKg = freezed,Object? notes = freezed,Object? sessionId = freezed,}) {
  return _then(_PersonalRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PRType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,achievedAt: null == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime,previousValue: freezed == previousValue ? _self.previousValue : previousValue // ignore: cast_nullable_to_non_nullable
as double?,previousDate: freezed == previousDate ? _self.previousDate : previousDate // ignore: cast_nullable_to_non_nullable
as DateTime?,setNumber: freezed == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ExercisePRSummary {

@JsonKey(name: 'exercise_id') String get exerciseId;@JsonKey(name: 'exercise_name') String get exerciseName;@JsonKey(name: 'exercise_image_url') String? get exerciseImageUrl;@JsonKey(name: 'muscle_group') String? get muscleGroup;// Current PRs
@JsonKey(name: 'pr_max_weight') double? get prMaxWeight;@JsonKey(name: 'pr_max_weight_date') DateTime? get prMaxWeightDate;@JsonKey(name: 'pr_max_weight_reps') int? get prMaxWeightReps;@JsonKey(name: 'pr_max_reps') int? get prMaxReps;@JsonKey(name: 'pr_max_reps_date') DateTime? get prMaxRepsDate;@JsonKey(name: 'pr_max_reps_weight') double? get prMaxRepsWeight;@JsonKey(name: 'pr_max_volume') double? get prMaxVolume;@JsonKey(name: 'pr_max_volume_date') DateTime? get prMaxVolumeDate;@JsonKey(name: 'pr_estimated_1rm') double? get prEstimated1RM;@JsonKey(name: 'pr_estimated_1rm_date') DateTime? get prEstimated1RMDate;// Statistics
@JsonKey(name: 'total_sessions') int get totalSessions;@JsonKey(name: 'last_performed') DateTime? get lastPerformed;// History
@JsonKey(name: 'recent_prs') List<PersonalRecord> get recentPRs;
/// Create a copy of ExercisePRSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExercisePRSummaryCopyWith<ExercisePRSummary> get copyWith => _$ExercisePRSummaryCopyWithImpl<ExercisePRSummary>(this as ExercisePRSummary, _$identity);

  /// Serializes this ExercisePRSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExercisePRSummary&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.exerciseImageUrl, exerciseImageUrl) || other.exerciseImageUrl == exerciseImageUrl)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&(identical(other.prMaxWeight, prMaxWeight) || other.prMaxWeight == prMaxWeight)&&(identical(other.prMaxWeightDate, prMaxWeightDate) || other.prMaxWeightDate == prMaxWeightDate)&&(identical(other.prMaxWeightReps, prMaxWeightReps) || other.prMaxWeightReps == prMaxWeightReps)&&(identical(other.prMaxReps, prMaxReps) || other.prMaxReps == prMaxReps)&&(identical(other.prMaxRepsDate, prMaxRepsDate) || other.prMaxRepsDate == prMaxRepsDate)&&(identical(other.prMaxRepsWeight, prMaxRepsWeight) || other.prMaxRepsWeight == prMaxRepsWeight)&&(identical(other.prMaxVolume, prMaxVolume) || other.prMaxVolume == prMaxVolume)&&(identical(other.prMaxVolumeDate, prMaxVolumeDate) || other.prMaxVolumeDate == prMaxVolumeDate)&&(identical(other.prEstimated1RM, prEstimated1RM) || other.prEstimated1RM == prEstimated1RM)&&(identical(other.prEstimated1RMDate, prEstimated1RMDate) || other.prEstimated1RMDate == prEstimated1RMDate)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.lastPerformed, lastPerformed) || other.lastPerformed == lastPerformed)&&const DeepCollectionEquality().equals(other.recentPRs, recentPRs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseId,exerciseName,exerciseImageUrl,muscleGroup,prMaxWeight,prMaxWeightDate,prMaxWeightReps,prMaxReps,prMaxRepsDate,prMaxRepsWeight,prMaxVolume,prMaxVolumeDate,prEstimated1RM,prEstimated1RMDate,totalSessions,lastPerformed,const DeepCollectionEquality().hash(recentPRs));

@override
String toString() {
  return 'ExercisePRSummary(exerciseId: $exerciseId, exerciseName: $exerciseName, exerciseImageUrl: $exerciseImageUrl, muscleGroup: $muscleGroup, prMaxWeight: $prMaxWeight, prMaxWeightDate: $prMaxWeightDate, prMaxWeightReps: $prMaxWeightReps, prMaxReps: $prMaxReps, prMaxRepsDate: $prMaxRepsDate, prMaxRepsWeight: $prMaxRepsWeight, prMaxVolume: $prMaxVolume, prMaxVolumeDate: $prMaxVolumeDate, prEstimated1RM: $prEstimated1RM, prEstimated1RMDate: $prEstimated1RMDate, totalSessions: $totalSessions, lastPerformed: $lastPerformed, recentPRs: $recentPRs)';
}


}

/// @nodoc
abstract mixin class $ExercisePRSummaryCopyWith<$Res>  {
  factory $ExercisePRSummaryCopyWith(ExercisePRSummary value, $Res Function(ExercisePRSummary) _then) = _$ExercisePRSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'exercise_id') String exerciseId,@JsonKey(name: 'exercise_name') String exerciseName,@JsonKey(name: 'exercise_image_url') String? exerciseImageUrl,@JsonKey(name: 'muscle_group') String? muscleGroup,@JsonKey(name: 'pr_max_weight') double? prMaxWeight,@JsonKey(name: 'pr_max_weight_date') DateTime? prMaxWeightDate,@JsonKey(name: 'pr_max_weight_reps') int? prMaxWeightReps,@JsonKey(name: 'pr_max_reps') int? prMaxReps,@JsonKey(name: 'pr_max_reps_date') DateTime? prMaxRepsDate,@JsonKey(name: 'pr_max_reps_weight') double? prMaxRepsWeight,@JsonKey(name: 'pr_max_volume') double? prMaxVolume,@JsonKey(name: 'pr_max_volume_date') DateTime? prMaxVolumeDate,@JsonKey(name: 'pr_estimated_1rm') double? prEstimated1RM,@JsonKey(name: 'pr_estimated_1rm_date') DateTime? prEstimated1RMDate,@JsonKey(name: 'total_sessions') int totalSessions,@JsonKey(name: 'last_performed') DateTime? lastPerformed,@JsonKey(name: 'recent_prs') List<PersonalRecord> recentPRs
});




}
/// @nodoc
class _$ExercisePRSummaryCopyWithImpl<$Res>
    implements $ExercisePRSummaryCopyWith<$Res> {
  _$ExercisePRSummaryCopyWithImpl(this._self, this._then);

  final ExercisePRSummary _self;
  final $Res Function(ExercisePRSummary) _then;

/// Create a copy of ExercisePRSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseId = null,Object? exerciseName = null,Object? exerciseImageUrl = freezed,Object? muscleGroup = freezed,Object? prMaxWeight = freezed,Object? prMaxWeightDate = freezed,Object? prMaxWeightReps = freezed,Object? prMaxReps = freezed,Object? prMaxRepsDate = freezed,Object? prMaxRepsWeight = freezed,Object? prMaxVolume = freezed,Object? prMaxVolumeDate = freezed,Object? prEstimated1RM = freezed,Object? prEstimated1RMDate = freezed,Object? totalSessions = null,Object? lastPerformed = freezed,Object? recentPRs = null,}) {
  return _then(_self.copyWith(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,exerciseImageUrl: freezed == exerciseImageUrl ? _self.exerciseImageUrl : exerciseImageUrl // ignore: cast_nullable_to_non_nullable
as String?,muscleGroup: freezed == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String?,prMaxWeight: freezed == prMaxWeight ? _self.prMaxWeight : prMaxWeight // ignore: cast_nullable_to_non_nullable
as double?,prMaxWeightDate: freezed == prMaxWeightDate ? _self.prMaxWeightDate : prMaxWeightDate // ignore: cast_nullable_to_non_nullable
as DateTime?,prMaxWeightReps: freezed == prMaxWeightReps ? _self.prMaxWeightReps : prMaxWeightReps // ignore: cast_nullable_to_non_nullable
as int?,prMaxReps: freezed == prMaxReps ? _self.prMaxReps : prMaxReps // ignore: cast_nullable_to_non_nullable
as int?,prMaxRepsDate: freezed == prMaxRepsDate ? _self.prMaxRepsDate : prMaxRepsDate // ignore: cast_nullable_to_non_nullable
as DateTime?,prMaxRepsWeight: freezed == prMaxRepsWeight ? _self.prMaxRepsWeight : prMaxRepsWeight // ignore: cast_nullable_to_non_nullable
as double?,prMaxVolume: freezed == prMaxVolume ? _self.prMaxVolume : prMaxVolume // ignore: cast_nullable_to_non_nullable
as double?,prMaxVolumeDate: freezed == prMaxVolumeDate ? _self.prMaxVolumeDate : prMaxVolumeDate // ignore: cast_nullable_to_non_nullable
as DateTime?,prEstimated1RM: freezed == prEstimated1RM ? _self.prEstimated1RM : prEstimated1RM // ignore: cast_nullable_to_non_nullable
as double?,prEstimated1RMDate: freezed == prEstimated1RMDate ? _self.prEstimated1RMDate : prEstimated1RMDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,lastPerformed: freezed == lastPerformed ? _self.lastPerformed : lastPerformed // ignore: cast_nullable_to_non_nullable
as DateTime?,recentPRs: null == recentPRs ? _self.recentPRs : recentPRs // ignore: cast_nullable_to_non_nullable
as List<PersonalRecord>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExercisePRSummary].
extension ExercisePRSummaryPatterns on ExercisePRSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExercisePRSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExercisePRSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExercisePRSummary value)  $default,){
final _that = this;
switch (_that) {
case _ExercisePRSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExercisePRSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ExercisePRSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'exercise_name')  String exerciseName, @JsonKey(name: 'exercise_image_url')  String? exerciseImageUrl, @JsonKey(name: 'muscle_group')  String? muscleGroup, @JsonKey(name: 'pr_max_weight')  double? prMaxWeight, @JsonKey(name: 'pr_max_weight_date')  DateTime? prMaxWeightDate, @JsonKey(name: 'pr_max_weight_reps')  int? prMaxWeightReps, @JsonKey(name: 'pr_max_reps')  int? prMaxReps, @JsonKey(name: 'pr_max_reps_date')  DateTime? prMaxRepsDate, @JsonKey(name: 'pr_max_reps_weight')  double? prMaxRepsWeight, @JsonKey(name: 'pr_max_volume')  double? prMaxVolume, @JsonKey(name: 'pr_max_volume_date')  DateTime? prMaxVolumeDate, @JsonKey(name: 'pr_estimated_1rm')  double? prEstimated1RM, @JsonKey(name: 'pr_estimated_1rm_date')  DateTime? prEstimated1RMDate, @JsonKey(name: 'total_sessions')  int totalSessions, @JsonKey(name: 'last_performed')  DateTime? lastPerformed, @JsonKey(name: 'recent_prs')  List<PersonalRecord> recentPRs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExercisePRSummary() when $default != null:
return $default(_that.exerciseId,_that.exerciseName,_that.exerciseImageUrl,_that.muscleGroup,_that.prMaxWeight,_that.prMaxWeightDate,_that.prMaxWeightReps,_that.prMaxReps,_that.prMaxRepsDate,_that.prMaxRepsWeight,_that.prMaxVolume,_that.prMaxVolumeDate,_that.prEstimated1RM,_that.prEstimated1RMDate,_that.totalSessions,_that.lastPerformed,_that.recentPRs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'exercise_name')  String exerciseName, @JsonKey(name: 'exercise_image_url')  String? exerciseImageUrl, @JsonKey(name: 'muscle_group')  String? muscleGroup, @JsonKey(name: 'pr_max_weight')  double? prMaxWeight, @JsonKey(name: 'pr_max_weight_date')  DateTime? prMaxWeightDate, @JsonKey(name: 'pr_max_weight_reps')  int? prMaxWeightReps, @JsonKey(name: 'pr_max_reps')  int? prMaxReps, @JsonKey(name: 'pr_max_reps_date')  DateTime? prMaxRepsDate, @JsonKey(name: 'pr_max_reps_weight')  double? prMaxRepsWeight, @JsonKey(name: 'pr_max_volume')  double? prMaxVolume, @JsonKey(name: 'pr_max_volume_date')  DateTime? prMaxVolumeDate, @JsonKey(name: 'pr_estimated_1rm')  double? prEstimated1RM, @JsonKey(name: 'pr_estimated_1rm_date')  DateTime? prEstimated1RMDate, @JsonKey(name: 'total_sessions')  int totalSessions, @JsonKey(name: 'last_performed')  DateTime? lastPerformed, @JsonKey(name: 'recent_prs')  List<PersonalRecord> recentPRs)  $default,) {final _that = this;
switch (_that) {
case _ExercisePRSummary():
return $default(_that.exerciseId,_that.exerciseName,_that.exerciseImageUrl,_that.muscleGroup,_that.prMaxWeight,_that.prMaxWeightDate,_that.prMaxWeightReps,_that.prMaxReps,_that.prMaxRepsDate,_that.prMaxRepsWeight,_that.prMaxVolume,_that.prMaxVolumeDate,_that.prEstimated1RM,_that.prEstimated1RMDate,_that.totalSessions,_that.lastPerformed,_that.recentPRs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'exercise_name')  String exerciseName, @JsonKey(name: 'exercise_image_url')  String? exerciseImageUrl, @JsonKey(name: 'muscle_group')  String? muscleGroup, @JsonKey(name: 'pr_max_weight')  double? prMaxWeight, @JsonKey(name: 'pr_max_weight_date')  DateTime? prMaxWeightDate, @JsonKey(name: 'pr_max_weight_reps')  int? prMaxWeightReps, @JsonKey(name: 'pr_max_reps')  int? prMaxReps, @JsonKey(name: 'pr_max_reps_date')  DateTime? prMaxRepsDate, @JsonKey(name: 'pr_max_reps_weight')  double? prMaxRepsWeight, @JsonKey(name: 'pr_max_volume')  double? prMaxVolume, @JsonKey(name: 'pr_max_volume_date')  DateTime? prMaxVolumeDate, @JsonKey(name: 'pr_estimated_1rm')  double? prEstimated1RM, @JsonKey(name: 'pr_estimated_1rm_date')  DateTime? prEstimated1RMDate, @JsonKey(name: 'total_sessions')  int totalSessions, @JsonKey(name: 'last_performed')  DateTime? lastPerformed, @JsonKey(name: 'recent_prs')  List<PersonalRecord> recentPRs)?  $default,) {final _that = this;
switch (_that) {
case _ExercisePRSummary() when $default != null:
return $default(_that.exerciseId,_that.exerciseName,_that.exerciseImageUrl,_that.muscleGroup,_that.prMaxWeight,_that.prMaxWeightDate,_that.prMaxWeightReps,_that.prMaxReps,_that.prMaxRepsDate,_that.prMaxRepsWeight,_that.prMaxVolume,_that.prMaxVolumeDate,_that.prEstimated1RM,_that.prEstimated1RMDate,_that.totalSessions,_that.lastPerformed,_that.recentPRs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExercisePRSummary extends ExercisePRSummary {
  const _ExercisePRSummary({@JsonKey(name: 'exercise_id') required this.exerciseId, @JsonKey(name: 'exercise_name') required this.exerciseName, @JsonKey(name: 'exercise_image_url') this.exerciseImageUrl, @JsonKey(name: 'muscle_group') this.muscleGroup, @JsonKey(name: 'pr_max_weight') this.prMaxWeight, @JsonKey(name: 'pr_max_weight_date') this.prMaxWeightDate, @JsonKey(name: 'pr_max_weight_reps') this.prMaxWeightReps, @JsonKey(name: 'pr_max_reps') this.prMaxReps, @JsonKey(name: 'pr_max_reps_date') this.prMaxRepsDate, @JsonKey(name: 'pr_max_reps_weight') this.prMaxRepsWeight, @JsonKey(name: 'pr_max_volume') this.prMaxVolume, @JsonKey(name: 'pr_max_volume_date') this.prMaxVolumeDate, @JsonKey(name: 'pr_estimated_1rm') this.prEstimated1RM, @JsonKey(name: 'pr_estimated_1rm_date') this.prEstimated1RMDate, @JsonKey(name: 'total_sessions') this.totalSessions = 0, @JsonKey(name: 'last_performed') this.lastPerformed, @JsonKey(name: 'recent_prs') final  List<PersonalRecord> recentPRs = const []}): _recentPRs = recentPRs,super._();
  factory _ExercisePRSummary.fromJson(Map<String, dynamic> json) => _$ExercisePRSummaryFromJson(json);

@override@JsonKey(name: 'exercise_id') final  String exerciseId;
@override@JsonKey(name: 'exercise_name') final  String exerciseName;
@override@JsonKey(name: 'exercise_image_url') final  String? exerciseImageUrl;
@override@JsonKey(name: 'muscle_group') final  String? muscleGroup;
// Current PRs
@override@JsonKey(name: 'pr_max_weight') final  double? prMaxWeight;
@override@JsonKey(name: 'pr_max_weight_date') final  DateTime? prMaxWeightDate;
@override@JsonKey(name: 'pr_max_weight_reps') final  int? prMaxWeightReps;
@override@JsonKey(name: 'pr_max_reps') final  int? prMaxReps;
@override@JsonKey(name: 'pr_max_reps_date') final  DateTime? prMaxRepsDate;
@override@JsonKey(name: 'pr_max_reps_weight') final  double? prMaxRepsWeight;
@override@JsonKey(name: 'pr_max_volume') final  double? prMaxVolume;
@override@JsonKey(name: 'pr_max_volume_date') final  DateTime? prMaxVolumeDate;
@override@JsonKey(name: 'pr_estimated_1rm') final  double? prEstimated1RM;
@override@JsonKey(name: 'pr_estimated_1rm_date') final  DateTime? prEstimated1RMDate;
// Statistics
@override@JsonKey(name: 'total_sessions') final  int totalSessions;
@override@JsonKey(name: 'last_performed') final  DateTime? lastPerformed;
// History
 final  List<PersonalRecord> _recentPRs;
// History
@override@JsonKey(name: 'recent_prs') List<PersonalRecord> get recentPRs {
  if (_recentPRs is EqualUnmodifiableListView) return _recentPRs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentPRs);
}


/// Create a copy of ExercisePRSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExercisePRSummaryCopyWith<_ExercisePRSummary> get copyWith => __$ExercisePRSummaryCopyWithImpl<_ExercisePRSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExercisePRSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExercisePRSummary&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.exerciseImageUrl, exerciseImageUrl) || other.exerciseImageUrl == exerciseImageUrl)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&(identical(other.prMaxWeight, prMaxWeight) || other.prMaxWeight == prMaxWeight)&&(identical(other.prMaxWeightDate, prMaxWeightDate) || other.prMaxWeightDate == prMaxWeightDate)&&(identical(other.prMaxWeightReps, prMaxWeightReps) || other.prMaxWeightReps == prMaxWeightReps)&&(identical(other.prMaxReps, prMaxReps) || other.prMaxReps == prMaxReps)&&(identical(other.prMaxRepsDate, prMaxRepsDate) || other.prMaxRepsDate == prMaxRepsDate)&&(identical(other.prMaxRepsWeight, prMaxRepsWeight) || other.prMaxRepsWeight == prMaxRepsWeight)&&(identical(other.prMaxVolume, prMaxVolume) || other.prMaxVolume == prMaxVolume)&&(identical(other.prMaxVolumeDate, prMaxVolumeDate) || other.prMaxVolumeDate == prMaxVolumeDate)&&(identical(other.prEstimated1RM, prEstimated1RM) || other.prEstimated1RM == prEstimated1RM)&&(identical(other.prEstimated1RMDate, prEstimated1RMDate) || other.prEstimated1RMDate == prEstimated1RMDate)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.lastPerformed, lastPerformed) || other.lastPerformed == lastPerformed)&&const DeepCollectionEquality().equals(other._recentPRs, _recentPRs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseId,exerciseName,exerciseImageUrl,muscleGroup,prMaxWeight,prMaxWeightDate,prMaxWeightReps,prMaxReps,prMaxRepsDate,prMaxRepsWeight,prMaxVolume,prMaxVolumeDate,prEstimated1RM,prEstimated1RMDate,totalSessions,lastPerformed,const DeepCollectionEquality().hash(_recentPRs));

@override
String toString() {
  return 'ExercisePRSummary(exerciseId: $exerciseId, exerciseName: $exerciseName, exerciseImageUrl: $exerciseImageUrl, muscleGroup: $muscleGroup, prMaxWeight: $prMaxWeight, prMaxWeightDate: $prMaxWeightDate, prMaxWeightReps: $prMaxWeightReps, prMaxReps: $prMaxReps, prMaxRepsDate: $prMaxRepsDate, prMaxRepsWeight: $prMaxRepsWeight, prMaxVolume: $prMaxVolume, prMaxVolumeDate: $prMaxVolumeDate, prEstimated1RM: $prEstimated1RM, prEstimated1RMDate: $prEstimated1RMDate, totalSessions: $totalSessions, lastPerformed: $lastPerformed, recentPRs: $recentPRs)';
}


}

/// @nodoc
abstract mixin class _$ExercisePRSummaryCopyWith<$Res> implements $ExercisePRSummaryCopyWith<$Res> {
  factory _$ExercisePRSummaryCopyWith(_ExercisePRSummary value, $Res Function(_ExercisePRSummary) _then) = __$ExercisePRSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'exercise_id') String exerciseId,@JsonKey(name: 'exercise_name') String exerciseName,@JsonKey(name: 'exercise_image_url') String? exerciseImageUrl,@JsonKey(name: 'muscle_group') String? muscleGroup,@JsonKey(name: 'pr_max_weight') double? prMaxWeight,@JsonKey(name: 'pr_max_weight_date') DateTime? prMaxWeightDate,@JsonKey(name: 'pr_max_weight_reps') int? prMaxWeightReps,@JsonKey(name: 'pr_max_reps') int? prMaxReps,@JsonKey(name: 'pr_max_reps_date') DateTime? prMaxRepsDate,@JsonKey(name: 'pr_max_reps_weight') double? prMaxRepsWeight,@JsonKey(name: 'pr_max_volume') double? prMaxVolume,@JsonKey(name: 'pr_max_volume_date') DateTime? prMaxVolumeDate,@JsonKey(name: 'pr_estimated_1rm') double? prEstimated1RM,@JsonKey(name: 'pr_estimated_1rm_date') DateTime? prEstimated1RMDate,@JsonKey(name: 'total_sessions') int totalSessions,@JsonKey(name: 'last_performed') DateTime? lastPerformed,@JsonKey(name: 'recent_prs') List<PersonalRecord> recentPRs
});




}
/// @nodoc
class __$ExercisePRSummaryCopyWithImpl<$Res>
    implements _$ExercisePRSummaryCopyWith<$Res> {
  __$ExercisePRSummaryCopyWithImpl(this._self, this._then);

  final _ExercisePRSummary _self;
  final $Res Function(_ExercisePRSummary) _then;

/// Create a copy of ExercisePRSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseId = null,Object? exerciseName = null,Object? exerciseImageUrl = freezed,Object? muscleGroup = freezed,Object? prMaxWeight = freezed,Object? prMaxWeightDate = freezed,Object? prMaxWeightReps = freezed,Object? prMaxReps = freezed,Object? prMaxRepsDate = freezed,Object? prMaxRepsWeight = freezed,Object? prMaxVolume = freezed,Object? prMaxVolumeDate = freezed,Object? prEstimated1RM = freezed,Object? prEstimated1RMDate = freezed,Object? totalSessions = null,Object? lastPerformed = freezed,Object? recentPRs = null,}) {
  return _then(_ExercisePRSummary(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,exerciseImageUrl: freezed == exerciseImageUrl ? _self.exerciseImageUrl : exerciseImageUrl // ignore: cast_nullable_to_non_nullable
as String?,muscleGroup: freezed == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String?,prMaxWeight: freezed == prMaxWeight ? _self.prMaxWeight : prMaxWeight // ignore: cast_nullable_to_non_nullable
as double?,prMaxWeightDate: freezed == prMaxWeightDate ? _self.prMaxWeightDate : prMaxWeightDate // ignore: cast_nullable_to_non_nullable
as DateTime?,prMaxWeightReps: freezed == prMaxWeightReps ? _self.prMaxWeightReps : prMaxWeightReps // ignore: cast_nullable_to_non_nullable
as int?,prMaxReps: freezed == prMaxReps ? _self.prMaxReps : prMaxReps // ignore: cast_nullable_to_non_nullable
as int?,prMaxRepsDate: freezed == prMaxRepsDate ? _self.prMaxRepsDate : prMaxRepsDate // ignore: cast_nullable_to_non_nullable
as DateTime?,prMaxRepsWeight: freezed == prMaxRepsWeight ? _self.prMaxRepsWeight : prMaxRepsWeight // ignore: cast_nullable_to_non_nullable
as double?,prMaxVolume: freezed == prMaxVolume ? _self.prMaxVolume : prMaxVolume // ignore: cast_nullable_to_non_nullable
as double?,prMaxVolumeDate: freezed == prMaxVolumeDate ? _self.prMaxVolumeDate : prMaxVolumeDate // ignore: cast_nullable_to_non_nullable
as DateTime?,prEstimated1RM: freezed == prEstimated1RM ? _self.prEstimated1RM : prEstimated1RM // ignore: cast_nullable_to_non_nullable
as double?,prEstimated1RMDate: freezed == prEstimated1RMDate ? _self.prEstimated1RMDate : prEstimated1RMDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,lastPerformed: freezed == lastPerformed ? _self.lastPerformed : lastPerformed // ignore: cast_nullable_to_non_nullable
as DateTime?,recentPRs: null == recentPRs ? _self._recentPRs : recentPRs // ignore: cast_nullable_to_non_nullable
as List<PersonalRecord>,
  ));
}


}


/// @nodoc
mixin _$PersonalRecordList {

 List<ExercisePRSummary> get exercises;@JsonKey(name: 'total_prs') int get totalPRs;@JsonKey(name: 'prs_this_month') int get prsThisMonth;@JsonKey(name: 'most_improved_exercise') String? get mostImprovedExercise;
/// Create a copy of PersonalRecordList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonalRecordListCopyWith<PersonalRecordList> get copyWith => _$PersonalRecordListCopyWithImpl<PersonalRecordList>(this as PersonalRecordList, _$identity);

  /// Serializes this PersonalRecordList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonalRecordList&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.totalPRs, totalPRs) || other.totalPRs == totalPRs)&&(identical(other.prsThisMonth, prsThisMonth) || other.prsThisMonth == prsThisMonth)&&(identical(other.mostImprovedExercise, mostImprovedExercise) || other.mostImprovedExercise == mostImprovedExercise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(exercises),totalPRs,prsThisMonth,mostImprovedExercise);

@override
String toString() {
  return 'PersonalRecordList(exercises: $exercises, totalPRs: $totalPRs, prsThisMonth: $prsThisMonth, mostImprovedExercise: $mostImprovedExercise)';
}


}

/// @nodoc
abstract mixin class $PersonalRecordListCopyWith<$Res>  {
  factory $PersonalRecordListCopyWith(PersonalRecordList value, $Res Function(PersonalRecordList) _then) = _$PersonalRecordListCopyWithImpl;
@useResult
$Res call({
 List<ExercisePRSummary> exercises,@JsonKey(name: 'total_prs') int totalPRs,@JsonKey(name: 'prs_this_month') int prsThisMonth,@JsonKey(name: 'most_improved_exercise') String? mostImprovedExercise
});




}
/// @nodoc
class _$PersonalRecordListCopyWithImpl<$Res>
    implements $PersonalRecordListCopyWith<$Res> {
  _$PersonalRecordListCopyWithImpl(this._self, this._then);

  final PersonalRecordList _self;
  final $Res Function(PersonalRecordList) _then;

/// Create a copy of PersonalRecordList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exercises = null,Object? totalPRs = null,Object? prsThisMonth = null,Object? mostImprovedExercise = freezed,}) {
  return _then(_self.copyWith(
exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ExercisePRSummary>,totalPRs: null == totalPRs ? _self.totalPRs : totalPRs // ignore: cast_nullable_to_non_nullable
as int,prsThisMonth: null == prsThisMonth ? _self.prsThisMonth : prsThisMonth // ignore: cast_nullable_to_non_nullable
as int,mostImprovedExercise: freezed == mostImprovedExercise ? _self.mostImprovedExercise : mostImprovedExercise // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonalRecordList].
extension PersonalRecordListPatterns on PersonalRecordList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonalRecordList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonalRecordList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonalRecordList value)  $default,){
final _that = this;
switch (_that) {
case _PersonalRecordList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonalRecordList value)?  $default,){
final _that = this;
switch (_that) {
case _PersonalRecordList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ExercisePRSummary> exercises, @JsonKey(name: 'total_prs')  int totalPRs, @JsonKey(name: 'prs_this_month')  int prsThisMonth, @JsonKey(name: 'most_improved_exercise')  String? mostImprovedExercise)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonalRecordList() when $default != null:
return $default(_that.exercises,_that.totalPRs,_that.prsThisMonth,_that.mostImprovedExercise);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ExercisePRSummary> exercises, @JsonKey(name: 'total_prs')  int totalPRs, @JsonKey(name: 'prs_this_month')  int prsThisMonth, @JsonKey(name: 'most_improved_exercise')  String? mostImprovedExercise)  $default,) {final _that = this;
switch (_that) {
case _PersonalRecordList():
return $default(_that.exercises,_that.totalPRs,_that.prsThisMonth,_that.mostImprovedExercise);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ExercisePRSummary> exercises, @JsonKey(name: 'total_prs')  int totalPRs, @JsonKey(name: 'prs_this_month')  int prsThisMonth, @JsonKey(name: 'most_improved_exercise')  String? mostImprovedExercise)?  $default,) {final _that = this;
switch (_that) {
case _PersonalRecordList() when $default != null:
return $default(_that.exercises,_that.totalPRs,_that.prsThisMonth,_that.mostImprovedExercise);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PersonalRecordList implements PersonalRecordList {
  const _PersonalRecordList({required final  List<ExercisePRSummary> exercises, @JsonKey(name: 'total_prs') this.totalPRs = 0, @JsonKey(name: 'prs_this_month') this.prsThisMonth = 0, @JsonKey(name: 'most_improved_exercise') this.mostImprovedExercise}): _exercises = exercises;
  factory _PersonalRecordList.fromJson(Map<String, dynamic> json) => _$PersonalRecordListFromJson(json);

 final  List<ExercisePRSummary> _exercises;
@override List<ExercisePRSummary> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

@override@JsonKey(name: 'total_prs') final  int totalPRs;
@override@JsonKey(name: 'prs_this_month') final  int prsThisMonth;
@override@JsonKey(name: 'most_improved_exercise') final  String? mostImprovedExercise;

/// Create a copy of PersonalRecordList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonalRecordListCopyWith<_PersonalRecordList> get copyWith => __$PersonalRecordListCopyWithImpl<_PersonalRecordList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonalRecordListToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonalRecordList&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.totalPRs, totalPRs) || other.totalPRs == totalPRs)&&(identical(other.prsThisMonth, prsThisMonth) || other.prsThisMonth == prsThisMonth)&&(identical(other.mostImprovedExercise, mostImprovedExercise) || other.mostImprovedExercise == mostImprovedExercise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_exercises),totalPRs,prsThisMonth,mostImprovedExercise);

@override
String toString() {
  return 'PersonalRecordList(exercises: $exercises, totalPRs: $totalPRs, prsThisMonth: $prsThisMonth, mostImprovedExercise: $mostImprovedExercise)';
}


}

/// @nodoc
abstract mixin class _$PersonalRecordListCopyWith<$Res> implements $PersonalRecordListCopyWith<$Res> {
  factory _$PersonalRecordListCopyWith(_PersonalRecordList value, $Res Function(_PersonalRecordList) _then) = __$PersonalRecordListCopyWithImpl;
@override @useResult
$Res call({
 List<ExercisePRSummary> exercises,@JsonKey(name: 'total_prs') int totalPRs,@JsonKey(name: 'prs_this_month') int prsThisMonth,@JsonKey(name: 'most_improved_exercise') String? mostImprovedExercise
});




}
/// @nodoc
class __$PersonalRecordListCopyWithImpl<$Res>
    implements _$PersonalRecordListCopyWith<$Res> {
  __$PersonalRecordListCopyWithImpl(this._self, this._then);

  final _PersonalRecordList _self;
  final $Res Function(_PersonalRecordList) _then;

/// Create a copy of PersonalRecordList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exercises = null,Object? totalPRs = null,Object? prsThisMonth = null,Object? mostImprovedExercise = freezed,}) {
  return _then(_PersonalRecordList(
exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ExercisePRSummary>,totalPRs: null == totalPRs ? _self.totalPRs : totalPRs // ignore: cast_nullable_to_non_nullable
as int,prsThisMonth: null == prsThisMonth ? _self.prsThisMonth : prsThisMonth // ignore: cast_nullable_to_non_nullable
as int,mostImprovedExercise: freezed == mostImprovedExercise ? _self.mostImprovedExercise : mostImprovedExercise // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PRAchievement {

@JsonKey(name: 'exercise_name') String get exerciseName; PRType get type;@JsonKey(name: 'new_value') double get newValue;@JsonKey(name: 'previous_value') double? get previousValue;@JsonKey(name: 'improvement_percent') double? get improvementPercent;
/// Create a copy of PRAchievement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PRAchievementCopyWith<PRAchievement> get copyWith => _$PRAchievementCopyWithImpl<PRAchievement>(this as PRAchievement, _$identity);

  /// Serializes this PRAchievement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PRAchievement&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.type, type) || other.type == type)&&(identical(other.newValue, newValue) || other.newValue == newValue)&&(identical(other.previousValue, previousValue) || other.previousValue == previousValue)&&(identical(other.improvementPercent, improvementPercent) || other.improvementPercent == improvementPercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,type,newValue,previousValue,improvementPercent);

@override
String toString() {
  return 'PRAchievement(exerciseName: $exerciseName, type: $type, newValue: $newValue, previousValue: $previousValue, improvementPercent: $improvementPercent)';
}


}

/// @nodoc
abstract mixin class $PRAchievementCopyWith<$Res>  {
  factory $PRAchievementCopyWith(PRAchievement value, $Res Function(PRAchievement) _then) = _$PRAchievementCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'exercise_name') String exerciseName, PRType type,@JsonKey(name: 'new_value') double newValue,@JsonKey(name: 'previous_value') double? previousValue,@JsonKey(name: 'improvement_percent') double? improvementPercent
});




}
/// @nodoc
class _$PRAchievementCopyWithImpl<$Res>
    implements $PRAchievementCopyWith<$Res> {
  _$PRAchievementCopyWithImpl(this._self, this._then);

  final PRAchievement _self;
  final $Res Function(PRAchievement) _then;

/// Create a copy of PRAchievement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? type = null,Object? newValue = null,Object? previousValue = freezed,Object? improvementPercent = freezed,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PRType,newValue: null == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as double,previousValue: freezed == previousValue ? _self.previousValue : previousValue // ignore: cast_nullable_to_non_nullable
as double?,improvementPercent: freezed == improvementPercent ? _self.improvementPercent : improvementPercent // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [PRAchievement].
extension PRAchievementPatterns on PRAchievement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PRAchievement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PRAchievement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PRAchievement value)  $default,){
final _that = this;
switch (_that) {
case _PRAchievement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PRAchievement value)?  $default,){
final _that = this;
switch (_that) {
case _PRAchievement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'exercise_name')  String exerciseName,  PRType type, @JsonKey(name: 'new_value')  double newValue, @JsonKey(name: 'previous_value')  double? previousValue, @JsonKey(name: 'improvement_percent')  double? improvementPercent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PRAchievement() when $default != null:
return $default(_that.exerciseName,_that.type,_that.newValue,_that.previousValue,_that.improvementPercent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'exercise_name')  String exerciseName,  PRType type, @JsonKey(name: 'new_value')  double newValue, @JsonKey(name: 'previous_value')  double? previousValue, @JsonKey(name: 'improvement_percent')  double? improvementPercent)  $default,) {final _that = this;
switch (_that) {
case _PRAchievement():
return $default(_that.exerciseName,_that.type,_that.newValue,_that.previousValue,_that.improvementPercent);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'exercise_name')  String exerciseName,  PRType type, @JsonKey(name: 'new_value')  double newValue, @JsonKey(name: 'previous_value')  double? previousValue, @JsonKey(name: 'improvement_percent')  double? improvementPercent)?  $default,) {final _that = this;
switch (_that) {
case _PRAchievement() when $default != null:
return $default(_that.exerciseName,_that.type,_that.newValue,_that.previousValue,_that.improvementPercent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PRAchievement extends PRAchievement {
  const _PRAchievement({@JsonKey(name: 'exercise_name') required this.exerciseName, required this.type, @JsonKey(name: 'new_value') required this.newValue, @JsonKey(name: 'previous_value') this.previousValue, @JsonKey(name: 'improvement_percent') this.improvementPercent}): super._();
  factory _PRAchievement.fromJson(Map<String, dynamic> json) => _$PRAchievementFromJson(json);

@override@JsonKey(name: 'exercise_name') final  String exerciseName;
@override final  PRType type;
@override@JsonKey(name: 'new_value') final  double newValue;
@override@JsonKey(name: 'previous_value') final  double? previousValue;
@override@JsonKey(name: 'improvement_percent') final  double? improvementPercent;

/// Create a copy of PRAchievement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PRAchievementCopyWith<_PRAchievement> get copyWith => __$PRAchievementCopyWithImpl<_PRAchievement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PRAchievementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PRAchievement&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.type, type) || other.type == type)&&(identical(other.newValue, newValue) || other.newValue == newValue)&&(identical(other.previousValue, previousValue) || other.previousValue == previousValue)&&(identical(other.improvementPercent, improvementPercent) || other.improvementPercent == improvementPercent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,type,newValue,previousValue,improvementPercent);

@override
String toString() {
  return 'PRAchievement(exerciseName: $exerciseName, type: $type, newValue: $newValue, previousValue: $previousValue, improvementPercent: $improvementPercent)';
}


}

/// @nodoc
abstract mixin class _$PRAchievementCopyWith<$Res> implements $PRAchievementCopyWith<$Res> {
  factory _$PRAchievementCopyWith(_PRAchievement value, $Res Function(_PRAchievement) _then) = __$PRAchievementCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'exercise_name') String exerciseName, PRType type,@JsonKey(name: 'new_value') double newValue,@JsonKey(name: 'previous_value') double? previousValue,@JsonKey(name: 'improvement_percent') double? improvementPercent
});




}
/// @nodoc
class __$PRAchievementCopyWithImpl<$Res>
    implements _$PRAchievementCopyWith<$Res> {
  __$PRAchievementCopyWithImpl(this._self, this._then);

  final _PRAchievement _self;
  final $Res Function(_PRAchievement) _then;

/// Create a copy of PRAchievement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? type = null,Object? newValue = null,Object? previousValue = freezed,Object? improvementPercent = freezed,}) {
  return _then(_PRAchievement(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PRType,newValue: null == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as double,previousValue: freezed == previousValue ? _self.previousValue : previousValue // ignore: cast_nullable_to_non_nullable
as double?,improvementPercent: freezed == improvementPercent ? _self.improvementPercent : improvementPercent // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
