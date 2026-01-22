// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'milestone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Milestone {

 String get id; String get userId; MilestoneType get type; String get title; String? get description; double get targetValue; double get currentValue; String get unit; MilestoneStatus get status; DateTime? get targetDate; DateTime? get completedAt; DateTime get createdAt; DateTime? get updatedAt;// For PR milestones
 String? get exerciseId; String? get exerciseName;// For measurement milestones
 String? get measurementType;// AI-generated insights
 String? get aiInsight;// Progress history
 List<MilestoneProgress> get progressHistory;
/// Create a copy of Milestone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MilestoneCopyWith<Milestone> get copyWith => _$MilestoneCopyWithImpl<Milestone>(this as Milestone, _$identity);

  /// Serializes this Milestone to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Milestone&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.status, status) || other.status == status)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.measurementType, measurementType) || other.measurementType == measurementType)&&(identical(other.aiInsight, aiInsight) || other.aiInsight == aiInsight)&&const DeepCollectionEquality().equals(other.progressHistory, progressHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,title,description,targetValue,currentValue,unit,status,targetDate,completedAt,createdAt,updatedAt,exerciseId,exerciseName,measurementType,aiInsight,const DeepCollectionEquality().hash(progressHistory));

@override
String toString() {
  return 'Milestone(id: $id, userId: $userId, type: $type, title: $title, description: $description, targetValue: $targetValue, currentValue: $currentValue, unit: $unit, status: $status, targetDate: $targetDate, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt, exerciseId: $exerciseId, exerciseName: $exerciseName, measurementType: $measurementType, aiInsight: $aiInsight, progressHistory: $progressHistory)';
}


}

/// @nodoc
abstract mixin class $MilestoneCopyWith<$Res>  {
  factory $MilestoneCopyWith(Milestone value, $Res Function(Milestone) _then) = _$MilestoneCopyWithImpl;
@useResult
$Res call({
 String id, String userId, MilestoneType type, String title, String? description, double targetValue, double currentValue, String unit, MilestoneStatus status, DateTime? targetDate, DateTime? completedAt, DateTime createdAt, DateTime? updatedAt, String? exerciseId, String? exerciseName, String? measurementType, String? aiInsight, List<MilestoneProgress> progressHistory
});




}
/// @nodoc
class _$MilestoneCopyWithImpl<$Res>
    implements $MilestoneCopyWith<$Res> {
  _$MilestoneCopyWithImpl(this._self, this._then);

  final Milestone _self;
  final $Res Function(Milestone) _then;

/// Create a copy of Milestone
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? title = null,Object? description = freezed,Object? targetValue = null,Object? currentValue = null,Object? unit = null,Object? status = null,Object? targetDate = freezed,Object? completedAt = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? exerciseId = freezed,Object? exerciseName = freezed,Object? measurementType = freezed,Object? aiInsight = freezed,Object? progressHistory = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MilestoneType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,targetValue: null == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double,currentValue: null == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MilestoneStatus,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,exerciseId: freezed == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String?,exerciseName: freezed == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String?,measurementType: freezed == measurementType ? _self.measurementType : measurementType // ignore: cast_nullable_to_non_nullable
as String?,aiInsight: freezed == aiInsight ? _self.aiInsight : aiInsight // ignore: cast_nullable_to_non_nullable
as String?,progressHistory: null == progressHistory ? _self.progressHistory : progressHistory // ignore: cast_nullable_to_non_nullable
as List<MilestoneProgress>,
  ));
}

}


/// Adds pattern-matching-related methods to [Milestone].
extension MilestonePatterns on Milestone {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Milestone value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Milestone() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Milestone value)  $default,){
final _that = this;
switch (_that) {
case _Milestone():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Milestone value)?  $default,){
final _that = this;
switch (_that) {
case _Milestone() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  MilestoneType type,  String title,  String? description,  double targetValue,  double currentValue,  String unit,  MilestoneStatus status,  DateTime? targetDate,  DateTime? completedAt,  DateTime createdAt,  DateTime? updatedAt,  String? exerciseId,  String? exerciseName,  String? measurementType,  String? aiInsight,  List<MilestoneProgress> progressHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Milestone() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.title,_that.description,_that.targetValue,_that.currentValue,_that.unit,_that.status,_that.targetDate,_that.completedAt,_that.createdAt,_that.updatedAt,_that.exerciseId,_that.exerciseName,_that.measurementType,_that.aiInsight,_that.progressHistory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  MilestoneType type,  String title,  String? description,  double targetValue,  double currentValue,  String unit,  MilestoneStatus status,  DateTime? targetDate,  DateTime? completedAt,  DateTime createdAt,  DateTime? updatedAt,  String? exerciseId,  String? exerciseName,  String? measurementType,  String? aiInsight,  List<MilestoneProgress> progressHistory)  $default,) {final _that = this;
switch (_that) {
case _Milestone():
return $default(_that.id,_that.userId,_that.type,_that.title,_that.description,_that.targetValue,_that.currentValue,_that.unit,_that.status,_that.targetDate,_that.completedAt,_that.createdAt,_that.updatedAt,_that.exerciseId,_that.exerciseName,_that.measurementType,_that.aiInsight,_that.progressHistory);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  MilestoneType type,  String title,  String? description,  double targetValue,  double currentValue,  String unit,  MilestoneStatus status,  DateTime? targetDate,  DateTime? completedAt,  DateTime createdAt,  DateTime? updatedAt,  String? exerciseId,  String? exerciseName,  String? measurementType,  String? aiInsight,  List<MilestoneProgress> progressHistory)?  $default,) {final _that = this;
switch (_that) {
case _Milestone() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.title,_that.description,_that.targetValue,_that.currentValue,_that.unit,_that.status,_that.targetDate,_that.completedAt,_that.createdAt,_that.updatedAt,_that.exerciseId,_that.exerciseName,_that.measurementType,_that.aiInsight,_that.progressHistory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Milestone extends Milestone {
  const _Milestone({required this.id, required this.userId, required this.type, required this.title, this.description, required this.targetValue, required this.currentValue, required this.unit, this.status = MilestoneStatus.active, this.targetDate, this.completedAt, required this.createdAt, this.updatedAt, this.exerciseId, this.exerciseName, this.measurementType, this.aiInsight, final  List<MilestoneProgress> progressHistory = const []}): _progressHistory = progressHistory,super._();
  factory _Milestone.fromJson(Map<String, dynamic> json) => _$MilestoneFromJson(json);

@override final  String id;
@override final  String userId;
@override final  MilestoneType type;
@override final  String title;
@override final  String? description;
@override final  double targetValue;
@override final  double currentValue;
@override final  String unit;
@override@JsonKey() final  MilestoneStatus status;
@override final  DateTime? targetDate;
@override final  DateTime? completedAt;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
// For PR milestones
@override final  String? exerciseId;
@override final  String? exerciseName;
// For measurement milestones
@override final  String? measurementType;
// AI-generated insights
@override final  String? aiInsight;
// Progress history
 final  List<MilestoneProgress> _progressHistory;
// Progress history
@override@JsonKey() List<MilestoneProgress> get progressHistory {
  if (_progressHistory is EqualUnmodifiableListView) return _progressHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_progressHistory);
}


/// Create a copy of Milestone
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MilestoneCopyWith<_Milestone> get copyWith => __$MilestoneCopyWithImpl<_Milestone>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MilestoneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Milestone&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.status, status) || other.status == status)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.measurementType, measurementType) || other.measurementType == measurementType)&&(identical(other.aiInsight, aiInsight) || other.aiInsight == aiInsight)&&const DeepCollectionEquality().equals(other._progressHistory, _progressHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,title,description,targetValue,currentValue,unit,status,targetDate,completedAt,createdAt,updatedAt,exerciseId,exerciseName,measurementType,aiInsight,const DeepCollectionEquality().hash(_progressHistory));

@override
String toString() {
  return 'Milestone(id: $id, userId: $userId, type: $type, title: $title, description: $description, targetValue: $targetValue, currentValue: $currentValue, unit: $unit, status: $status, targetDate: $targetDate, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt, exerciseId: $exerciseId, exerciseName: $exerciseName, measurementType: $measurementType, aiInsight: $aiInsight, progressHistory: $progressHistory)';
}


}

/// @nodoc
abstract mixin class _$MilestoneCopyWith<$Res> implements $MilestoneCopyWith<$Res> {
  factory _$MilestoneCopyWith(_Milestone value, $Res Function(_Milestone) _then) = __$MilestoneCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, MilestoneType type, String title, String? description, double targetValue, double currentValue, String unit, MilestoneStatus status, DateTime? targetDate, DateTime? completedAt, DateTime createdAt, DateTime? updatedAt, String? exerciseId, String? exerciseName, String? measurementType, String? aiInsight, List<MilestoneProgress> progressHistory
});




}
/// @nodoc
class __$MilestoneCopyWithImpl<$Res>
    implements _$MilestoneCopyWith<$Res> {
  __$MilestoneCopyWithImpl(this._self, this._then);

  final _Milestone _self;
  final $Res Function(_Milestone) _then;

/// Create a copy of Milestone
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? title = null,Object? description = freezed,Object? targetValue = null,Object? currentValue = null,Object? unit = null,Object? status = null,Object? targetDate = freezed,Object? completedAt = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? exerciseId = freezed,Object? exerciseName = freezed,Object? measurementType = freezed,Object? aiInsight = freezed,Object? progressHistory = null,}) {
  return _then(_Milestone(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MilestoneType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,targetValue: null == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double,currentValue: null == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MilestoneStatus,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,exerciseId: freezed == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String?,exerciseName: freezed == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String?,measurementType: freezed == measurementType ? _self.measurementType : measurementType // ignore: cast_nullable_to_non_nullable
as String?,aiInsight: freezed == aiInsight ? _self.aiInsight : aiInsight // ignore: cast_nullable_to_non_nullable
as String?,progressHistory: null == progressHistory ? _self._progressHistory : progressHistory // ignore: cast_nullable_to_non_nullable
as List<MilestoneProgress>,
  ));
}


}


/// @nodoc
mixin _$MilestoneProgress {

 DateTime get date; double get value; String? get note;
/// Create a copy of MilestoneProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MilestoneProgressCopyWith<MilestoneProgress> get copyWith => _$MilestoneProgressCopyWithImpl<MilestoneProgress>(this as MilestoneProgress, _$identity);

  /// Serializes this MilestoneProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MilestoneProgress&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,value,note);

@override
String toString() {
  return 'MilestoneProgress(date: $date, value: $value, note: $note)';
}


}

/// @nodoc
abstract mixin class $MilestoneProgressCopyWith<$Res>  {
  factory $MilestoneProgressCopyWith(MilestoneProgress value, $Res Function(MilestoneProgress) _then) = _$MilestoneProgressCopyWithImpl;
@useResult
$Res call({
 DateTime date, double value, String? note
});




}
/// @nodoc
class _$MilestoneProgressCopyWithImpl<$Res>
    implements $MilestoneProgressCopyWith<$Res> {
  _$MilestoneProgressCopyWithImpl(this._self, this._then);

  final MilestoneProgress _self;
  final $Res Function(MilestoneProgress) _then;

/// Create a copy of MilestoneProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? value = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MilestoneProgress].
extension MilestoneProgressPatterns on MilestoneProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MilestoneProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MilestoneProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MilestoneProgress value)  $default,){
final _that = this;
switch (_that) {
case _MilestoneProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MilestoneProgress value)?  $default,){
final _that = this;
switch (_that) {
case _MilestoneProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double value,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MilestoneProgress() when $default != null:
return $default(_that.date,_that.value,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double value,  String? note)  $default,) {final _that = this;
switch (_that) {
case _MilestoneProgress():
return $default(_that.date,_that.value,_that.note);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double value,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _MilestoneProgress() when $default != null:
return $default(_that.date,_that.value,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MilestoneProgress implements MilestoneProgress {
  const _MilestoneProgress({required this.date, required this.value, this.note});
  factory _MilestoneProgress.fromJson(Map<String, dynamic> json) => _$MilestoneProgressFromJson(json);

@override final  DateTime date;
@override final  double value;
@override final  String? note;

/// Create a copy of MilestoneProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MilestoneProgressCopyWith<_MilestoneProgress> get copyWith => __$MilestoneProgressCopyWithImpl<_MilestoneProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MilestoneProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MilestoneProgress&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,value,note);

@override
String toString() {
  return 'MilestoneProgress(date: $date, value: $value, note: $note)';
}


}

/// @nodoc
abstract mixin class _$MilestoneProgressCopyWith<$Res> implements $MilestoneProgressCopyWith<$Res> {
  factory _$MilestoneProgressCopyWith(_MilestoneProgress value, $Res Function(_MilestoneProgress) _then) = __$MilestoneProgressCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double value, String? note
});




}
/// @nodoc
class __$MilestoneProgressCopyWithImpl<$Res>
    implements _$MilestoneProgressCopyWith<$Res> {
  __$MilestoneProgressCopyWithImpl(this._self, this._then);

  final _MilestoneProgress _self;
  final $Res Function(_MilestoneProgress) _then;

/// Create a copy of MilestoneProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? value = null,Object? note = freezed,}) {
  return _then(_MilestoneProgress(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AIInsight {

 String get id; String get userId; String get category; String get title; String get content; List<String> get recommendations; String? get relatedMilestoneId; bool get isDismissed; DateTime get generatedAt; DateTime? get expiresAt;// Sentiment: positive, neutral, warning
 String get sentiment;
/// Create a copy of AIInsight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AIInsightCopyWith<AIInsight> get copyWith => _$AIInsightCopyWithImpl<AIInsight>(this as AIInsight, _$identity);

  /// Serializes this AIInsight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIInsight&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.category, category) || other.category == category)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.recommendations, recommendations)&&(identical(other.relatedMilestoneId, relatedMilestoneId) || other.relatedMilestoneId == relatedMilestoneId)&&(identical(other.isDismissed, isDismissed) || other.isDismissed == isDismissed)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.sentiment, sentiment) || other.sentiment == sentiment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,category,title,content,const DeepCollectionEquality().hash(recommendations),relatedMilestoneId,isDismissed,generatedAt,expiresAt,sentiment);

@override
String toString() {
  return 'AIInsight(id: $id, userId: $userId, category: $category, title: $title, content: $content, recommendations: $recommendations, relatedMilestoneId: $relatedMilestoneId, isDismissed: $isDismissed, generatedAt: $generatedAt, expiresAt: $expiresAt, sentiment: $sentiment)';
}


}

/// @nodoc
abstract mixin class $AIInsightCopyWith<$Res>  {
  factory $AIInsightCopyWith(AIInsight value, $Res Function(AIInsight) _then) = _$AIInsightCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String category, String title, String content, List<String> recommendations, String? relatedMilestoneId, bool isDismissed, DateTime generatedAt, DateTime? expiresAt, String sentiment
});




}
/// @nodoc
class _$AIInsightCopyWithImpl<$Res>
    implements $AIInsightCopyWith<$Res> {
  _$AIInsightCopyWithImpl(this._self, this._then);

  final AIInsight _self;
  final $Res Function(AIInsight) _then;

/// Create a copy of AIInsight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? category = null,Object? title = null,Object? content = null,Object? recommendations = null,Object? relatedMilestoneId = freezed,Object? isDismissed = null,Object? generatedAt = null,Object? expiresAt = freezed,Object? sentiment = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,recommendations: null == recommendations ? _self.recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as List<String>,relatedMilestoneId: freezed == relatedMilestoneId ? _self.relatedMilestoneId : relatedMilestoneId // ignore: cast_nullable_to_non_nullable
as String?,isDismissed: null == isDismissed ? _self.isDismissed : isDismissed // ignore: cast_nullable_to_non_nullable
as bool,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sentiment: null == sentiment ? _self.sentiment : sentiment // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AIInsight].
extension AIInsightPatterns on AIInsight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AIInsight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AIInsight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AIInsight value)  $default,){
final _that = this;
switch (_that) {
case _AIInsight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AIInsight value)?  $default,){
final _that = this;
switch (_that) {
case _AIInsight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String category,  String title,  String content,  List<String> recommendations,  String? relatedMilestoneId,  bool isDismissed,  DateTime generatedAt,  DateTime? expiresAt,  String sentiment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AIInsight() when $default != null:
return $default(_that.id,_that.userId,_that.category,_that.title,_that.content,_that.recommendations,_that.relatedMilestoneId,_that.isDismissed,_that.generatedAt,_that.expiresAt,_that.sentiment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String category,  String title,  String content,  List<String> recommendations,  String? relatedMilestoneId,  bool isDismissed,  DateTime generatedAt,  DateTime? expiresAt,  String sentiment)  $default,) {final _that = this;
switch (_that) {
case _AIInsight():
return $default(_that.id,_that.userId,_that.category,_that.title,_that.content,_that.recommendations,_that.relatedMilestoneId,_that.isDismissed,_that.generatedAt,_that.expiresAt,_that.sentiment);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String category,  String title,  String content,  List<String> recommendations,  String? relatedMilestoneId,  bool isDismissed,  DateTime generatedAt,  DateTime? expiresAt,  String sentiment)?  $default,) {final _that = this;
switch (_that) {
case _AIInsight() when $default != null:
return $default(_that.id,_that.userId,_that.category,_that.title,_that.content,_that.recommendations,_that.relatedMilestoneId,_that.isDismissed,_that.generatedAt,_that.expiresAt,_that.sentiment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AIInsight extends AIInsight {
  const _AIInsight({required this.id, required this.userId, required this.category, required this.title, required this.content, final  List<String> recommendations = const [], this.relatedMilestoneId, this.isDismissed = false, required this.generatedAt, this.expiresAt, this.sentiment = 'neutral'}): _recommendations = recommendations,super._();
  factory _AIInsight.fromJson(Map<String, dynamic> json) => _$AIInsightFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String category;
@override final  String title;
@override final  String content;
 final  List<String> _recommendations;
@override@JsonKey() List<String> get recommendations {
  if (_recommendations is EqualUnmodifiableListView) return _recommendations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recommendations);
}

@override final  String? relatedMilestoneId;
@override@JsonKey() final  bool isDismissed;
@override final  DateTime generatedAt;
@override final  DateTime? expiresAt;
// Sentiment: positive, neutral, warning
@override@JsonKey() final  String sentiment;

/// Create a copy of AIInsight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AIInsightCopyWith<_AIInsight> get copyWith => __$AIInsightCopyWithImpl<_AIInsight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AIInsightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AIInsight&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.category, category) || other.category == category)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._recommendations, _recommendations)&&(identical(other.relatedMilestoneId, relatedMilestoneId) || other.relatedMilestoneId == relatedMilestoneId)&&(identical(other.isDismissed, isDismissed) || other.isDismissed == isDismissed)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.sentiment, sentiment) || other.sentiment == sentiment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,category,title,content,const DeepCollectionEquality().hash(_recommendations),relatedMilestoneId,isDismissed,generatedAt,expiresAt,sentiment);

@override
String toString() {
  return 'AIInsight(id: $id, userId: $userId, category: $category, title: $title, content: $content, recommendations: $recommendations, relatedMilestoneId: $relatedMilestoneId, isDismissed: $isDismissed, generatedAt: $generatedAt, expiresAt: $expiresAt, sentiment: $sentiment)';
}


}

/// @nodoc
abstract mixin class _$AIInsightCopyWith<$Res> implements $AIInsightCopyWith<$Res> {
  factory _$AIInsightCopyWith(_AIInsight value, $Res Function(_AIInsight) _then) = __$AIInsightCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String category, String title, String content, List<String> recommendations, String? relatedMilestoneId, bool isDismissed, DateTime generatedAt, DateTime? expiresAt, String sentiment
});




}
/// @nodoc
class __$AIInsightCopyWithImpl<$Res>
    implements _$AIInsightCopyWith<$Res> {
  __$AIInsightCopyWithImpl(this._self, this._then);

  final _AIInsight _self;
  final $Res Function(_AIInsight) _then;

/// Create a copy of AIInsight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? category = null,Object? title = null,Object? content = null,Object? recommendations = null,Object? relatedMilestoneId = freezed,Object? isDismissed = null,Object? generatedAt = null,Object? expiresAt = freezed,Object? sentiment = null,}) {
  return _then(_AIInsight(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,recommendations: null == recommendations ? _self._recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as List<String>,relatedMilestoneId: freezed == relatedMilestoneId ? _self.relatedMilestoneId : relatedMilestoneId // ignore: cast_nullable_to_non_nullable
as String?,isDismissed: null == isDismissed ? _self.isDismissed : isDismissed // ignore: cast_nullable_to_non_nullable
as bool,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sentiment: null == sentiment ? _self.sentiment : sentiment // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MilestoneStats {

 int get totalMilestones; int get completedMilestones; int get activeMilestones; int get currentStreak; int get longestStreak; DateTime? get lastAchievement; List<Milestone> get recentAchievements;
/// Create a copy of MilestoneStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MilestoneStatsCopyWith<MilestoneStats> get copyWith => _$MilestoneStatsCopyWithImpl<MilestoneStats>(this as MilestoneStats, _$identity);

  /// Serializes this MilestoneStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MilestoneStats&&(identical(other.totalMilestones, totalMilestones) || other.totalMilestones == totalMilestones)&&(identical(other.completedMilestones, completedMilestones) || other.completedMilestones == completedMilestones)&&(identical(other.activeMilestones, activeMilestones) || other.activeMilestones == activeMilestones)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.lastAchievement, lastAchievement) || other.lastAchievement == lastAchievement)&&const DeepCollectionEquality().equals(other.recentAchievements, recentAchievements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalMilestones,completedMilestones,activeMilestones,currentStreak,longestStreak,lastAchievement,const DeepCollectionEquality().hash(recentAchievements));

@override
String toString() {
  return 'MilestoneStats(totalMilestones: $totalMilestones, completedMilestones: $completedMilestones, activeMilestones: $activeMilestones, currentStreak: $currentStreak, longestStreak: $longestStreak, lastAchievement: $lastAchievement, recentAchievements: $recentAchievements)';
}


}

/// @nodoc
abstract mixin class $MilestoneStatsCopyWith<$Res>  {
  factory $MilestoneStatsCopyWith(MilestoneStats value, $Res Function(MilestoneStats) _then) = _$MilestoneStatsCopyWithImpl;
@useResult
$Res call({
 int totalMilestones, int completedMilestones, int activeMilestones, int currentStreak, int longestStreak, DateTime? lastAchievement, List<Milestone> recentAchievements
});




}
/// @nodoc
class _$MilestoneStatsCopyWithImpl<$Res>
    implements $MilestoneStatsCopyWith<$Res> {
  _$MilestoneStatsCopyWithImpl(this._self, this._then);

  final MilestoneStats _self;
  final $Res Function(MilestoneStats) _then;

/// Create a copy of MilestoneStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalMilestones = null,Object? completedMilestones = null,Object? activeMilestones = null,Object? currentStreak = null,Object? longestStreak = null,Object? lastAchievement = freezed,Object? recentAchievements = null,}) {
  return _then(_self.copyWith(
totalMilestones: null == totalMilestones ? _self.totalMilestones : totalMilestones // ignore: cast_nullable_to_non_nullable
as int,completedMilestones: null == completedMilestones ? _self.completedMilestones : completedMilestones // ignore: cast_nullable_to_non_nullable
as int,activeMilestones: null == activeMilestones ? _self.activeMilestones : activeMilestones // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,lastAchievement: freezed == lastAchievement ? _self.lastAchievement : lastAchievement // ignore: cast_nullable_to_non_nullable
as DateTime?,recentAchievements: null == recentAchievements ? _self.recentAchievements : recentAchievements // ignore: cast_nullable_to_non_nullable
as List<Milestone>,
  ));
}

}


/// Adds pattern-matching-related methods to [MilestoneStats].
extension MilestoneStatsPatterns on MilestoneStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MilestoneStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MilestoneStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MilestoneStats value)  $default,){
final _that = this;
switch (_that) {
case _MilestoneStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MilestoneStats value)?  $default,){
final _that = this;
switch (_that) {
case _MilestoneStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalMilestones,  int completedMilestones,  int activeMilestones,  int currentStreak,  int longestStreak,  DateTime? lastAchievement,  List<Milestone> recentAchievements)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MilestoneStats() when $default != null:
return $default(_that.totalMilestones,_that.completedMilestones,_that.activeMilestones,_that.currentStreak,_that.longestStreak,_that.lastAchievement,_that.recentAchievements);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalMilestones,  int completedMilestones,  int activeMilestones,  int currentStreak,  int longestStreak,  DateTime? lastAchievement,  List<Milestone> recentAchievements)  $default,) {final _that = this;
switch (_that) {
case _MilestoneStats():
return $default(_that.totalMilestones,_that.completedMilestones,_that.activeMilestones,_that.currentStreak,_that.longestStreak,_that.lastAchievement,_that.recentAchievements);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalMilestones,  int completedMilestones,  int activeMilestones,  int currentStreak,  int longestStreak,  DateTime? lastAchievement,  List<Milestone> recentAchievements)?  $default,) {final _that = this;
switch (_that) {
case _MilestoneStats() when $default != null:
return $default(_that.totalMilestones,_that.completedMilestones,_that.activeMilestones,_that.currentStreak,_that.longestStreak,_that.lastAchievement,_that.recentAchievements);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MilestoneStats implements MilestoneStats {
  const _MilestoneStats({this.totalMilestones = 0, this.completedMilestones = 0, this.activeMilestones = 0, this.currentStreak = 0, this.longestStreak = 0, this.lastAchievement, final  List<Milestone> recentAchievements = const []}): _recentAchievements = recentAchievements;
  factory _MilestoneStats.fromJson(Map<String, dynamic> json) => _$MilestoneStatsFromJson(json);

@override@JsonKey() final  int totalMilestones;
@override@JsonKey() final  int completedMilestones;
@override@JsonKey() final  int activeMilestones;
@override@JsonKey() final  int currentStreak;
@override@JsonKey() final  int longestStreak;
@override final  DateTime? lastAchievement;
 final  List<Milestone> _recentAchievements;
@override@JsonKey() List<Milestone> get recentAchievements {
  if (_recentAchievements is EqualUnmodifiableListView) return _recentAchievements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentAchievements);
}


/// Create a copy of MilestoneStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MilestoneStatsCopyWith<_MilestoneStats> get copyWith => __$MilestoneStatsCopyWithImpl<_MilestoneStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MilestoneStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MilestoneStats&&(identical(other.totalMilestones, totalMilestones) || other.totalMilestones == totalMilestones)&&(identical(other.completedMilestones, completedMilestones) || other.completedMilestones == completedMilestones)&&(identical(other.activeMilestones, activeMilestones) || other.activeMilestones == activeMilestones)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.lastAchievement, lastAchievement) || other.lastAchievement == lastAchievement)&&const DeepCollectionEquality().equals(other._recentAchievements, _recentAchievements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalMilestones,completedMilestones,activeMilestones,currentStreak,longestStreak,lastAchievement,const DeepCollectionEquality().hash(_recentAchievements));

@override
String toString() {
  return 'MilestoneStats(totalMilestones: $totalMilestones, completedMilestones: $completedMilestones, activeMilestones: $activeMilestones, currentStreak: $currentStreak, longestStreak: $longestStreak, lastAchievement: $lastAchievement, recentAchievements: $recentAchievements)';
}


}

/// @nodoc
abstract mixin class _$MilestoneStatsCopyWith<$Res> implements $MilestoneStatsCopyWith<$Res> {
  factory _$MilestoneStatsCopyWith(_MilestoneStats value, $Res Function(_MilestoneStats) _then) = __$MilestoneStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalMilestones, int completedMilestones, int activeMilestones, int currentStreak, int longestStreak, DateTime? lastAchievement, List<Milestone> recentAchievements
});




}
/// @nodoc
class __$MilestoneStatsCopyWithImpl<$Res>
    implements _$MilestoneStatsCopyWith<$Res> {
  __$MilestoneStatsCopyWithImpl(this._self, this._then);

  final _MilestoneStats _self;
  final $Res Function(_MilestoneStats) _then;

/// Create a copy of MilestoneStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalMilestones = null,Object? completedMilestones = null,Object? activeMilestones = null,Object? currentStreak = null,Object? longestStreak = null,Object? lastAchievement = freezed,Object? recentAchievements = null,}) {
  return _then(_MilestoneStats(
totalMilestones: null == totalMilestones ? _self.totalMilestones : totalMilestones // ignore: cast_nullable_to_non_nullable
as int,completedMilestones: null == completedMilestones ? _self.completedMilestones : completedMilestones // ignore: cast_nullable_to_non_nullable
as int,activeMilestones: null == activeMilestones ? _self.activeMilestones : activeMilestones // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,lastAchievement: freezed == lastAchievement ? _self.lastAchievement : lastAchievement // ignore: cast_nullable_to_non_nullable
as DateTime?,recentAchievements: null == recentAchievements ? _self._recentAchievements : recentAchievements // ignore: cast_nullable_to_non_nullable
as List<Milestone>,
  ));
}


}

// dart format on
