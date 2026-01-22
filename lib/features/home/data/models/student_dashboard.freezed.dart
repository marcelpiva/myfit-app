// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudentStats {

@JsonKey(name: 'total_workouts') int get totalWorkouts;@JsonKey(name: 'adherence_percent') int get adherencePercent;@JsonKey(name: 'weight_change_kg') double? get weightChangeKg;@JsonKey(name: 'current_streak') int get currentStreak;
/// Create a copy of StudentStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentStatsCopyWith<StudentStats> get copyWith => _$StudentStatsCopyWithImpl<StudentStats>(this as StudentStats, _$identity);

  /// Serializes this StudentStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentStats&&(identical(other.totalWorkouts, totalWorkouts) || other.totalWorkouts == totalWorkouts)&&(identical(other.adherencePercent, adherencePercent) || other.adherencePercent == adherencePercent)&&(identical(other.weightChangeKg, weightChangeKg) || other.weightChangeKg == weightChangeKg)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalWorkouts,adherencePercent,weightChangeKg,currentStreak);

@override
String toString() {
  return 'StudentStats(totalWorkouts: $totalWorkouts, adherencePercent: $adherencePercent, weightChangeKg: $weightChangeKg, currentStreak: $currentStreak)';
}


}

/// @nodoc
abstract mixin class $StudentStatsCopyWith<$Res>  {
  factory $StudentStatsCopyWith(StudentStats value, $Res Function(StudentStats) _then) = _$StudentStatsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_workouts') int totalWorkouts,@JsonKey(name: 'adherence_percent') int adherencePercent,@JsonKey(name: 'weight_change_kg') double? weightChangeKg,@JsonKey(name: 'current_streak') int currentStreak
});




}
/// @nodoc
class _$StudentStatsCopyWithImpl<$Res>
    implements $StudentStatsCopyWith<$Res> {
  _$StudentStatsCopyWithImpl(this._self, this._then);

  final StudentStats _self;
  final $Res Function(StudentStats) _then;

/// Create a copy of StudentStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalWorkouts = null,Object? adherencePercent = null,Object? weightChangeKg = freezed,Object? currentStreak = null,}) {
  return _then(_self.copyWith(
totalWorkouts: null == totalWorkouts ? _self.totalWorkouts : totalWorkouts // ignore: cast_nullable_to_non_nullable
as int,adherencePercent: null == adherencePercent ? _self.adherencePercent : adherencePercent // ignore: cast_nullable_to_non_nullable
as int,weightChangeKg: freezed == weightChangeKg ? _self.weightChangeKg : weightChangeKg // ignore: cast_nullable_to_non_nullable
as double?,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StudentStats].
extension StudentStatsPatterns on StudentStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentStats value)  $default,){
final _that = this;
switch (_that) {
case _StudentStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentStats value)?  $default,){
final _that = this;
switch (_that) {
case _StudentStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_workouts')  int totalWorkouts, @JsonKey(name: 'adherence_percent')  int adherencePercent, @JsonKey(name: 'weight_change_kg')  double? weightChangeKg, @JsonKey(name: 'current_streak')  int currentStreak)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentStats() when $default != null:
return $default(_that.totalWorkouts,_that.adherencePercent,_that.weightChangeKg,_that.currentStreak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_workouts')  int totalWorkouts, @JsonKey(name: 'adherence_percent')  int adherencePercent, @JsonKey(name: 'weight_change_kg')  double? weightChangeKg, @JsonKey(name: 'current_streak')  int currentStreak)  $default,) {final _that = this;
switch (_that) {
case _StudentStats():
return $default(_that.totalWorkouts,_that.adherencePercent,_that.weightChangeKg,_that.currentStreak);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_workouts')  int totalWorkouts, @JsonKey(name: 'adherence_percent')  int adherencePercent, @JsonKey(name: 'weight_change_kg')  double? weightChangeKg, @JsonKey(name: 'current_streak')  int currentStreak)?  $default,) {final _that = this;
switch (_that) {
case _StudentStats() when $default != null:
return $default(_that.totalWorkouts,_that.adherencePercent,_that.weightChangeKg,_that.currentStreak);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentStats extends StudentStats {
  const _StudentStats({@JsonKey(name: 'total_workouts') this.totalWorkouts = 0, @JsonKey(name: 'adherence_percent') this.adherencePercent = 0, @JsonKey(name: 'weight_change_kg') this.weightChangeKg, @JsonKey(name: 'current_streak') this.currentStreak = 0}): super._();
  factory _StudentStats.fromJson(Map<String, dynamic> json) => _$StudentStatsFromJson(json);

@override@JsonKey(name: 'total_workouts') final  int totalWorkouts;
@override@JsonKey(name: 'adherence_percent') final  int adherencePercent;
@override@JsonKey(name: 'weight_change_kg') final  double? weightChangeKg;
@override@JsonKey(name: 'current_streak') final  int currentStreak;

/// Create a copy of StudentStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentStatsCopyWith<_StudentStats> get copyWith => __$StudentStatsCopyWithImpl<_StudentStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentStats&&(identical(other.totalWorkouts, totalWorkouts) || other.totalWorkouts == totalWorkouts)&&(identical(other.adherencePercent, adherencePercent) || other.adherencePercent == adherencePercent)&&(identical(other.weightChangeKg, weightChangeKg) || other.weightChangeKg == weightChangeKg)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalWorkouts,adherencePercent,weightChangeKg,currentStreak);

@override
String toString() {
  return 'StudentStats(totalWorkouts: $totalWorkouts, adherencePercent: $adherencePercent, weightChangeKg: $weightChangeKg, currentStreak: $currentStreak)';
}


}

/// @nodoc
abstract mixin class _$StudentStatsCopyWith<$Res> implements $StudentStatsCopyWith<$Res> {
  factory _$StudentStatsCopyWith(_StudentStats value, $Res Function(_StudentStats) _then) = __$StudentStatsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_workouts') int totalWorkouts,@JsonKey(name: 'adherence_percent') int adherencePercent,@JsonKey(name: 'weight_change_kg') double? weightChangeKg,@JsonKey(name: 'current_streak') int currentStreak
});




}
/// @nodoc
class __$StudentStatsCopyWithImpl<$Res>
    implements _$StudentStatsCopyWith<$Res> {
  __$StudentStatsCopyWithImpl(this._self, this._then);

  final _StudentStats _self;
  final $Res Function(_StudentStats) _then;

/// Create a copy of StudentStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalWorkouts = null,Object? adherencePercent = null,Object? weightChangeKg = freezed,Object? currentStreak = null,}) {
  return _then(_StudentStats(
totalWorkouts: null == totalWorkouts ? _self.totalWorkouts : totalWorkouts // ignore: cast_nullable_to_non_nullable
as int,adherencePercent: null == adherencePercent ? _self.adherencePercent : adherencePercent // ignore: cast_nullable_to_non_nullable
as int,weightChangeKg: freezed == weightChangeKg ? _self.weightChangeKg : weightChangeKg // ignore: cast_nullable_to_non_nullable
as double?,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TodayWorkout {

 String get id; String get name; String get label;@JsonKey(name: 'duration_minutes') int get durationMinutes;@JsonKey(name: 'exercises_count') int get exercisesCount;@JsonKey(name: 'plan_id') String? get planId;@JsonKey(name: 'workout_id') String get workoutId;
/// Create a copy of TodayWorkout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayWorkoutCopyWith<TodayWorkout> get copyWith => _$TodayWorkoutCopyWithImpl<TodayWorkout>(this as TodayWorkout, _$identity);

  /// Serializes this TodayWorkout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.label, label) || other.label == label)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.exercisesCount, exercisesCount) || other.exercisesCount == exercisesCount)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,label,durationMinutes,exercisesCount,planId,workoutId);

@override
String toString() {
  return 'TodayWorkout(id: $id, name: $name, label: $label, durationMinutes: $durationMinutes, exercisesCount: $exercisesCount, planId: $planId, workoutId: $workoutId)';
}


}

/// @nodoc
abstract mixin class $TodayWorkoutCopyWith<$Res>  {
  factory $TodayWorkoutCopyWith(TodayWorkout value, $Res Function(TodayWorkout) _then) = _$TodayWorkoutCopyWithImpl;
@useResult
$Res call({
 String id, String name, String label,@JsonKey(name: 'duration_minutes') int durationMinutes,@JsonKey(name: 'exercises_count') int exercisesCount,@JsonKey(name: 'plan_id') String? planId,@JsonKey(name: 'workout_id') String workoutId
});




}
/// @nodoc
class _$TodayWorkoutCopyWithImpl<$Res>
    implements $TodayWorkoutCopyWith<$Res> {
  _$TodayWorkoutCopyWithImpl(this._self, this._then);

  final TodayWorkout _self;
  final $Res Function(TodayWorkout) _then;

/// Create a copy of TodayWorkout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? label = null,Object? durationMinutes = null,Object? exercisesCount = null,Object? planId = freezed,Object? workoutId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,exercisesCount: null == exercisesCount ? _self.exercisesCount : exercisesCount // ignore: cast_nullable_to_non_nullable
as int,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayWorkout].
extension TodayWorkoutPatterns on TodayWorkout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayWorkout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayWorkout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayWorkout value)  $default,){
final _that = this;
switch (_that) {
case _TodayWorkout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayWorkout value)?  $default,){
final _that = this;
switch (_that) {
case _TodayWorkout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String label, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'exercises_count')  int exercisesCount, @JsonKey(name: 'plan_id')  String? planId, @JsonKey(name: 'workout_id')  String workoutId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayWorkout() when $default != null:
return $default(_that.id,_that.name,_that.label,_that.durationMinutes,_that.exercisesCount,_that.planId,_that.workoutId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String label, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'exercises_count')  int exercisesCount, @JsonKey(name: 'plan_id')  String? planId, @JsonKey(name: 'workout_id')  String workoutId)  $default,) {final _that = this;
switch (_that) {
case _TodayWorkout():
return $default(_that.id,_that.name,_that.label,_that.durationMinutes,_that.exercisesCount,_that.planId,_that.workoutId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String label, @JsonKey(name: 'duration_minutes')  int durationMinutes, @JsonKey(name: 'exercises_count')  int exercisesCount, @JsonKey(name: 'plan_id')  String? planId, @JsonKey(name: 'workout_id')  String workoutId)?  $default,) {final _that = this;
switch (_that) {
case _TodayWorkout() when $default != null:
return $default(_that.id,_that.name,_that.label,_that.durationMinutes,_that.exercisesCount,_that.planId,_that.workoutId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodayWorkout extends TodayWorkout {
  const _TodayWorkout({required this.id, required this.name, required this.label, @JsonKey(name: 'duration_minutes') this.durationMinutes = 60, @JsonKey(name: 'exercises_count') this.exercisesCount = 0, @JsonKey(name: 'plan_id') this.planId, @JsonKey(name: 'workout_id') required this.workoutId}): super._();
  factory _TodayWorkout.fromJson(Map<String, dynamic> json) => _$TodayWorkoutFromJson(json);

@override final  String id;
@override final  String name;
@override final  String label;
@override@JsonKey(name: 'duration_minutes') final  int durationMinutes;
@override@JsonKey(name: 'exercises_count') final  int exercisesCount;
@override@JsonKey(name: 'plan_id') final  String? planId;
@override@JsonKey(name: 'workout_id') final  String workoutId;

/// Create a copy of TodayWorkout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayWorkoutCopyWith<_TodayWorkout> get copyWith => __$TodayWorkoutCopyWithImpl<_TodayWorkout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodayWorkoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.label, label) || other.label == label)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.exercisesCount, exercisesCount) || other.exercisesCount == exercisesCount)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,label,durationMinutes,exercisesCount,planId,workoutId);

@override
String toString() {
  return 'TodayWorkout(id: $id, name: $name, label: $label, durationMinutes: $durationMinutes, exercisesCount: $exercisesCount, planId: $planId, workoutId: $workoutId)';
}


}

/// @nodoc
abstract mixin class _$TodayWorkoutCopyWith<$Res> implements $TodayWorkoutCopyWith<$Res> {
  factory _$TodayWorkoutCopyWith(_TodayWorkout value, $Res Function(_TodayWorkout) _then) = __$TodayWorkoutCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String label,@JsonKey(name: 'duration_minutes') int durationMinutes,@JsonKey(name: 'exercises_count') int exercisesCount,@JsonKey(name: 'plan_id') String? planId,@JsonKey(name: 'workout_id') String workoutId
});




}
/// @nodoc
class __$TodayWorkoutCopyWithImpl<$Res>
    implements _$TodayWorkoutCopyWith<$Res> {
  __$TodayWorkoutCopyWithImpl(this._self, this._then);

  final _TodayWorkout _self;
  final $Res Function(_TodayWorkout) _then;

/// Create a copy of TodayWorkout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? label = null,Object? durationMinutes = null,Object? exercisesCount = null,Object? planId = freezed,Object? workoutId = null,}) {
  return _then(_TodayWorkout(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,exercisesCount: null == exercisesCount ? _self.exercisesCount : exercisesCount // ignore: cast_nullable_to_non_nullable
as int,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String?,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$WeeklyProgress {

 int get completed; int get target; List<String?> get days;
/// Create a copy of WeeklyProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyProgressCopyWith<WeeklyProgress> get copyWith => _$WeeklyProgressCopyWithImpl<WeeklyProgress>(this as WeeklyProgress, _$identity);

  /// Serializes this WeeklyProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklyProgress&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other.days, days));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,completed,target,const DeepCollectionEquality().hash(days));

@override
String toString() {
  return 'WeeklyProgress(completed: $completed, target: $target, days: $days)';
}


}

/// @nodoc
abstract mixin class $WeeklyProgressCopyWith<$Res>  {
  factory $WeeklyProgressCopyWith(WeeklyProgress value, $Res Function(WeeklyProgress) _then) = _$WeeklyProgressCopyWithImpl;
@useResult
$Res call({
 int completed, int target, List<String?> days
});




}
/// @nodoc
class _$WeeklyProgressCopyWithImpl<$Res>
    implements $WeeklyProgressCopyWith<$Res> {
  _$WeeklyProgressCopyWithImpl(this._self, this._then);

  final WeeklyProgress _self;
  final $Res Function(WeeklyProgress) _then;

/// Create a copy of WeeklyProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? completed = null,Object? target = null,Object? days = null,}) {
  return _then(_self.copyWith(
completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<String?>,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklyProgress].
extension WeeklyProgressPatterns on WeeklyProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklyProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklyProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklyProgress value)  $default,){
final _that = this;
switch (_that) {
case _WeeklyProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklyProgress value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklyProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int completed,  int target,  List<String?> days)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklyProgress() when $default != null:
return $default(_that.completed,_that.target,_that.days);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int completed,  int target,  List<String?> days)  $default,) {final _that = this;
switch (_that) {
case _WeeklyProgress():
return $default(_that.completed,_that.target,_that.days);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int completed,  int target,  List<String?> days)?  $default,) {final _that = this;
switch (_that) {
case _WeeklyProgress() when $default != null:
return $default(_that.completed,_that.target,_that.days);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklyProgress extends WeeklyProgress {
  const _WeeklyProgress({this.completed = 0, this.target = 5, final  List<String?> days = const []}): _days = days,super._();
  factory _WeeklyProgress.fromJson(Map<String, dynamic> json) => _$WeeklyProgressFromJson(json);

@override@JsonKey() final  int completed;
@override@JsonKey() final  int target;
 final  List<String?> _days;
@override@JsonKey() List<String?> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}


/// Create a copy of WeeklyProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyProgressCopyWith<_WeeklyProgress> get copyWith => __$WeeklyProgressCopyWithImpl<_WeeklyProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeeklyProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklyProgress&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other._days, _days));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,completed,target,const DeepCollectionEquality().hash(_days));

@override
String toString() {
  return 'WeeklyProgress(completed: $completed, target: $target, days: $days)';
}


}

/// @nodoc
abstract mixin class _$WeeklyProgressCopyWith<$Res> implements $WeeklyProgressCopyWith<$Res> {
  factory _$WeeklyProgressCopyWith(_WeeklyProgress value, $Res Function(_WeeklyProgress) _then) = __$WeeklyProgressCopyWithImpl;
@override @useResult
$Res call({
 int completed, int target, List<String?> days
});




}
/// @nodoc
class __$WeeklyProgressCopyWithImpl<$Res>
    implements _$WeeklyProgressCopyWith<$Res> {
  __$WeeklyProgressCopyWithImpl(this._self, this._then);

  final _WeeklyProgress _self;
  final $Res Function(_WeeklyProgress) _then;

/// Create a copy of WeeklyProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? completed = null,Object? target = null,Object? days = null,}) {
  return _then(_WeeklyProgress(
completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<String?>,
  ));
}


}


/// @nodoc
mixin _$RecentActivity {

 String get title; String get subtitle; String get time; String get type;
/// Create a copy of RecentActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentActivityCopyWith<RecentActivity> get copyWith => _$RecentActivityCopyWithImpl<RecentActivity>(this as RecentActivity, _$identity);

  /// Serializes this RecentActivity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentActivity&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.time, time) || other.time == time)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,subtitle,time,type);

@override
String toString() {
  return 'RecentActivity(title: $title, subtitle: $subtitle, time: $time, type: $type)';
}


}

/// @nodoc
abstract mixin class $RecentActivityCopyWith<$Res>  {
  factory $RecentActivityCopyWith(RecentActivity value, $Res Function(RecentActivity) _then) = _$RecentActivityCopyWithImpl;
@useResult
$Res call({
 String title, String subtitle, String time, String type
});




}
/// @nodoc
class _$RecentActivityCopyWithImpl<$Res>
    implements $RecentActivityCopyWith<$Res> {
  _$RecentActivityCopyWithImpl(this._self, this._then);

  final RecentActivity _self;
  final $Res Function(RecentActivity) _then;

/// Create a copy of RecentActivity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? subtitle = null,Object? time = null,Object? type = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentActivity].
extension RecentActivityPatterns on RecentActivity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentActivity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentActivity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentActivity value)  $default,){
final _that = this;
switch (_that) {
case _RecentActivity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentActivity value)?  $default,){
final _that = this;
switch (_that) {
case _RecentActivity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String subtitle,  String time,  String type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentActivity() when $default != null:
return $default(_that.title,_that.subtitle,_that.time,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String subtitle,  String time,  String type)  $default,) {final _that = this;
switch (_that) {
case _RecentActivity():
return $default(_that.title,_that.subtitle,_that.time,_that.type);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String subtitle,  String time,  String type)?  $default,) {final _that = this;
switch (_that) {
case _RecentActivity() when $default != null:
return $default(_that.title,_that.subtitle,_that.time,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecentActivity extends RecentActivity {
  const _RecentActivity({required this.title, required this.subtitle, required this.time, required this.type}): super._();
  factory _RecentActivity.fromJson(Map<String, dynamic> json) => _$RecentActivityFromJson(json);

@override final  String title;
@override final  String subtitle;
@override final  String time;
@override final  String type;

/// Create a copy of RecentActivity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentActivityCopyWith<_RecentActivity> get copyWith => __$RecentActivityCopyWithImpl<_RecentActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecentActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentActivity&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.time, time) || other.time == time)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,subtitle,time,type);

@override
String toString() {
  return 'RecentActivity(title: $title, subtitle: $subtitle, time: $time, type: $type)';
}


}

/// @nodoc
abstract mixin class _$RecentActivityCopyWith<$Res> implements $RecentActivityCopyWith<$Res> {
  factory _$RecentActivityCopyWith(_RecentActivity value, $Res Function(_RecentActivity) _then) = __$RecentActivityCopyWithImpl;
@override @useResult
$Res call({
 String title, String subtitle, String time, String type
});




}
/// @nodoc
class __$RecentActivityCopyWithImpl<$Res>
    implements _$RecentActivityCopyWith<$Res> {
  __$RecentActivityCopyWithImpl(this._self, this._then);

  final _RecentActivity _self;
  final $Res Function(_RecentActivity) _then;

/// Create a copy of RecentActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? subtitle = null,Object? time = null,Object? type = null,}) {
  return _then(_RecentActivity(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TrainerInfo {

 String get id; String get name;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'is_online') bool get isOnline;
/// Create a copy of TrainerInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerInfoCopyWith<TrainerInfo> get copyWith => _$TrainerInfoCopyWithImpl<TrainerInfo>(this as TrainerInfo, _$identity);

  /// Serializes this TrainerInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl,isOnline);

@override
String toString() {
  return 'TrainerInfo(id: $id, name: $name, avatarUrl: $avatarUrl, isOnline: $isOnline)';
}


}

/// @nodoc
abstract mixin class $TrainerInfoCopyWith<$Res>  {
  factory $TrainerInfoCopyWith(TrainerInfo value, $Res Function(TrainerInfo) _then) = _$TrainerInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'is_online') bool isOnline
});




}
/// @nodoc
class _$TrainerInfoCopyWithImpl<$Res>
    implements $TrainerInfoCopyWith<$Res> {
  _$TrainerInfoCopyWithImpl(this._self, this._then);

  final TrainerInfo _self;
  final $Res Function(TrainerInfo) _then;

/// Create a copy of TrainerInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatarUrl = freezed,Object? isOnline = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerInfo].
extension TrainerInfoPatterns on TrainerInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerInfo value)  $default,){
final _that = this;
switch (_that) {
case _TrainerInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerInfo value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_online')  bool isOnline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerInfo() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.isOnline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_online')  bool isOnline)  $default,) {final _that = this;
switch (_that) {
case _TrainerInfo():
return $default(_that.id,_that.name,_that.avatarUrl,_that.isOnline);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_online')  bool isOnline)?  $default,) {final _that = this;
switch (_that) {
case _TrainerInfo() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.isOnline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerInfo extends TrainerInfo {
  const _TrainerInfo({required this.id, required this.name, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'is_online') this.isOnline = false}): super._();
  factory _TrainerInfo.fromJson(Map<String, dynamic> json) => _$TrainerInfoFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'is_online') final  bool isOnline;

/// Create a copy of TrainerInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerInfoCopyWith<_TrainerInfo> get copyWith => __$TrainerInfoCopyWithImpl<_TrainerInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl,isOnline);

@override
String toString() {
  return 'TrainerInfo(id: $id, name: $name, avatarUrl: $avatarUrl, isOnline: $isOnline)';
}


}

/// @nodoc
abstract mixin class _$TrainerInfoCopyWith<$Res> implements $TrainerInfoCopyWith<$Res> {
  factory _$TrainerInfoCopyWith(_TrainerInfo value, $Res Function(_TrainerInfo) _then) = __$TrainerInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'is_online') bool isOnline
});




}
/// @nodoc
class __$TrainerInfoCopyWithImpl<$Res>
    implements _$TrainerInfoCopyWith<$Res> {
  __$TrainerInfoCopyWithImpl(this._self, this._then);

  final _TrainerInfo _self;
  final $Res Function(_TrainerInfo) _then;

/// Create a copy of TrainerInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatarUrl = freezed,Object? isOnline = null,}) {
  return _then(_TrainerInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PlanProgress {

@JsonKey(name: 'plan_id') String get planId;@JsonKey(name: 'plan_name') String get planName;@JsonKey(name: 'current_week') int get currentWeek;@JsonKey(name: 'total_weeks') int? get totalWeeks;@JsonKey(name: 'percent_complete') int get percentComplete;@JsonKey(name: 'training_mode') TrainingMode get trainingMode;
/// Create a copy of PlanProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanProgressCopyWith<PlanProgress> get copyWith => _$PlanProgressCopyWithImpl<PlanProgress>(this as PlanProgress, _$identity);

  /// Serializes this PlanProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanProgress&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.currentWeek, currentWeek) || other.currentWeek == currentWeek)&&(identical(other.totalWeeks, totalWeeks) || other.totalWeeks == totalWeeks)&&(identical(other.percentComplete, percentComplete) || other.percentComplete == percentComplete)&&(identical(other.trainingMode, trainingMode) || other.trainingMode == trainingMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,planId,planName,currentWeek,totalWeeks,percentComplete,trainingMode);

@override
String toString() {
  return 'PlanProgress(planId: $planId, planName: $planName, currentWeek: $currentWeek, totalWeeks: $totalWeeks, percentComplete: $percentComplete, trainingMode: $trainingMode)';
}


}

/// @nodoc
abstract mixin class $PlanProgressCopyWith<$Res>  {
  factory $PlanProgressCopyWith(PlanProgress value, $Res Function(PlanProgress) _then) = _$PlanProgressCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'plan_id') String planId,@JsonKey(name: 'plan_name') String planName,@JsonKey(name: 'current_week') int currentWeek,@JsonKey(name: 'total_weeks') int? totalWeeks,@JsonKey(name: 'percent_complete') int percentComplete,@JsonKey(name: 'training_mode') TrainingMode trainingMode
});




}
/// @nodoc
class _$PlanProgressCopyWithImpl<$Res>
    implements $PlanProgressCopyWith<$Res> {
  _$PlanProgressCopyWithImpl(this._self, this._then);

  final PlanProgress _self;
  final $Res Function(PlanProgress) _then;

/// Create a copy of PlanProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? planId = null,Object? planName = null,Object? currentWeek = null,Object? totalWeeks = freezed,Object? percentComplete = null,Object? trainingMode = null,}) {
  return _then(_self.copyWith(
planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,currentWeek: null == currentWeek ? _self.currentWeek : currentWeek // ignore: cast_nullable_to_non_nullable
as int,totalWeeks: freezed == totalWeeks ? _self.totalWeeks : totalWeeks // ignore: cast_nullable_to_non_nullable
as int?,percentComplete: null == percentComplete ? _self.percentComplete : percentComplete // ignore: cast_nullable_to_non_nullable
as int,trainingMode: null == trainingMode ? _self.trainingMode : trainingMode // ignore: cast_nullable_to_non_nullable
as TrainingMode,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanProgress].
extension PlanProgressPatterns on PlanProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanProgress value)  $default,){
final _that = this;
switch (_that) {
case _PlanProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanProgress value)?  $default,){
final _that = this;
switch (_that) {
case _PlanProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'plan_id')  String planId, @JsonKey(name: 'plan_name')  String planName, @JsonKey(name: 'current_week')  int currentWeek, @JsonKey(name: 'total_weeks')  int? totalWeeks, @JsonKey(name: 'percent_complete')  int percentComplete, @JsonKey(name: 'training_mode')  TrainingMode trainingMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanProgress() when $default != null:
return $default(_that.planId,_that.planName,_that.currentWeek,_that.totalWeeks,_that.percentComplete,_that.trainingMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'plan_id')  String planId, @JsonKey(name: 'plan_name')  String planName, @JsonKey(name: 'current_week')  int currentWeek, @JsonKey(name: 'total_weeks')  int? totalWeeks, @JsonKey(name: 'percent_complete')  int percentComplete, @JsonKey(name: 'training_mode')  TrainingMode trainingMode)  $default,) {final _that = this;
switch (_that) {
case _PlanProgress():
return $default(_that.planId,_that.planName,_that.currentWeek,_that.totalWeeks,_that.percentComplete,_that.trainingMode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'plan_id')  String planId, @JsonKey(name: 'plan_name')  String planName, @JsonKey(name: 'current_week')  int currentWeek, @JsonKey(name: 'total_weeks')  int? totalWeeks, @JsonKey(name: 'percent_complete')  int percentComplete, @JsonKey(name: 'training_mode')  TrainingMode trainingMode)?  $default,) {final _that = this;
switch (_that) {
case _PlanProgress() when $default != null:
return $default(_that.planId,_that.planName,_that.currentWeek,_that.totalWeeks,_that.percentComplete,_that.trainingMode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanProgress extends PlanProgress {
  const _PlanProgress({@JsonKey(name: 'plan_id') required this.planId, @JsonKey(name: 'plan_name') required this.planName, @JsonKey(name: 'current_week') this.currentWeek = 1, @JsonKey(name: 'total_weeks') this.totalWeeks, @JsonKey(name: 'percent_complete') this.percentComplete = 0, @JsonKey(name: 'training_mode') this.trainingMode = TrainingMode.presencial}): super._();
  factory _PlanProgress.fromJson(Map<String, dynamic> json) => _$PlanProgressFromJson(json);

@override@JsonKey(name: 'plan_id') final  String planId;
@override@JsonKey(name: 'plan_name') final  String planName;
@override@JsonKey(name: 'current_week') final  int currentWeek;
@override@JsonKey(name: 'total_weeks') final  int? totalWeeks;
@override@JsonKey(name: 'percent_complete') final  int percentComplete;
@override@JsonKey(name: 'training_mode') final  TrainingMode trainingMode;

/// Create a copy of PlanProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanProgressCopyWith<_PlanProgress> get copyWith => __$PlanProgressCopyWithImpl<_PlanProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanProgress&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.currentWeek, currentWeek) || other.currentWeek == currentWeek)&&(identical(other.totalWeeks, totalWeeks) || other.totalWeeks == totalWeeks)&&(identical(other.percentComplete, percentComplete) || other.percentComplete == percentComplete)&&(identical(other.trainingMode, trainingMode) || other.trainingMode == trainingMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,planId,planName,currentWeek,totalWeeks,percentComplete,trainingMode);

@override
String toString() {
  return 'PlanProgress(planId: $planId, planName: $planName, currentWeek: $currentWeek, totalWeeks: $totalWeeks, percentComplete: $percentComplete, trainingMode: $trainingMode)';
}


}

/// @nodoc
abstract mixin class _$PlanProgressCopyWith<$Res> implements $PlanProgressCopyWith<$Res> {
  factory _$PlanProgressCopyWith(_PlanProgress value, $Res Function(_PlanProgress) _then) = __$PlanProgressCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'plan_id') String planId,@JsonKey(name: 'plan_name') String planName,@JsonKey(name: 'current_week') int currentWeek,@JsonKey(name: 'total_weeks') int? totalWeeks,@JsonKey(name: 'percent_complete') int percentComplete,@JsonKey(name: 'training_mode') TrainingMode trainingMode
});




}
/// @nodoc
class __$PlanProgressCopyWithImpl<$Res>
    implements _$PlanProgressCopyWith<$Res> {
  __$PlanProgressCopyWithImpl(this._self, this._then);

  final _PlanProgress _self;
  final $Res Function(_PlanProgress) _then;

/// Create a copy of PlanProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? planId = null,Object? planName = null,Object? currentWeek = null,Object? totalWeeks = freezed,Object? percentComplete = null,Object? trainingMode = null,}) {
  return _then(_PlanProgress(
planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,currentWeek: null == currentWeek ? _self.currentWeek : currentWeek // ignore: cast_nullable_to_non_nullable
as int,totalWeeks: freezed == totalWeeks ? _self.totalWeeks : totalWeeks // ignore: cast_nullable_to_non_nullable
as int?,percentComplete: null == percentComplete ? _self.percentComplete : percentComplete // ignore: cast_nullable_to_non_nullable
as int,trainingMode: null == trainingMode ? _self.trainingMode : trainingMode // ignore: cast_nullable_to_non_nullable
as TrainingMode,
  ));
}


}


/// @nodoc
mixin _$StudentDashboard {

 StudentStats get stats;@JsonKey(name: 'today_workout') TodayWorkout? get todayWorkout;@JsonKey(name: 'weekly_progress') WeeklyProgress get weeklyProgress;@JsonKey(name: 'recent_activity') List<RecentActivity> get recentActivity; TrainerInfo? get trainer;@JsonKey(name: 'plan_progress') PlanProgress? get planProgress;@JsonKey(name: 'unread_notes_count') int get unreadNotesCount;
/// Create a copy of StudentDashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentDashboardCopyWith<StudentDashboard> get copyWith => _$StudentDashboardCopyWithImpl<StudentDashboard>(this as StudentDashboard, _$identity);

  /// Serializes this StudentDashboard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentDashboard&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.todayWorkout, todayWorkout) || other.todayWorkout == todayWorkout)&&(identical(other.weeklyProgress, weeklyProgress) || other.weeklyProgress == weeklyProgress)&&const DeepCollectionEquality().equals(other.recentActivity, recentActivity)&&(identical(other.trainer, trainer) || other.trainer == trainer)&&(identical(other.planProgress, planProgress) || other.planProgress == planProgress)&&(identical(other.unreadNotesCount, unreadNotesCount) || other.unreadNotesCount == unreadNotesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stats,todayWorkout,weeklyProgress,const DeepCollectionEquality().hash(recentActivity),trainer,planProgress,unreadNotesCount);

@override
String toString() {
  return 'StudentDashboard(stats: $stats, todayWorkout: $todayWorkout, weeklyProgress: $weeklyProgress, recentActivity: $recentActivity, trainer: $trainer, planProgress: $planProgress, unreadNotesCount: $unreadNotesCount)';
}


}

/// @nodoc
abstract mixin class $StudentDashboardCopyWith<$Res>  {
  factory $StudentDashboardCopyWith(StudentDashboard value, $Res Function(StudentDashboard) _then) = _$StudentDashboardCopyWithImpl;
@useResult
$Res call({
 StudentStats stats,@JsonKey(name: 'today_workout') TodayWorkout? todayWorkout,@JsonKey(name: 'weekly_progress') WeeklyProgress weeklyProgress,@JsonKey(name: 'recent_activity') List<RecentActivity> recentActivity, TrainerInfo? trainer,@JsonKey(name: 'plan_progress') PlanProgress? planProgress,@JsonKey(name: 'unread_notes_count') int unreadNotesCount
});


$StudentStatsCopyWith<$Res> get stats;$TodayWorkoutCopyWith<$Res>? get todayWorkout;$WeeklyProgressCopyWith<$Res> get weeklyProgress;$TrainerInfoCopyWith<$Res>? get trainer;$PlanProgressCopyWith<$Res>? get planProgress;

}
/// @nodoc
class _$StudentDashboardCopyWithImpl<$Res>
    implements $StudentDashboardCopyWith<$Res> {
  _$StudentDashboardCopyWithImpl(this._self, this._then);

  final StudentDashboard _self;
  final $Res Function(StudentDashboard) _then;

/// Create a copy of StudentDashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stats = null,Object? todayWorkout = freezed,Object? weeklyProgress = null,Object? recentActivity = null,Object? trainer = freezed,Object? planProgress = freezed,Object? unreadNotesCount = null,}) {
  return _then(_self.copyWith(
stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as StudentStats,todayWorkout: freezed == todayWorkout ? _self.todayWorkout : todayWorkout // ignore: cast_nullable_to_non_nullable
as TodayWorkout?,weeklyProgress: null == weeklyProgress ? _self.weeklyProgress : weeklyProgress // ignore: cast_nullable_to_non_nullable
as WeeklyProgress,recentActivity: null == recentActivity ? _self.recentActivity : recentActivity // ignore: cast_nullable_to_non_nullable
as List<RecentActivity>,trainer: freezed == trainer ? _self.trainer : trainer // ignore: cast_nullable_to_non_nullable
as TrainerInfo?,planProgress: freezed == planProgress ? _self.planProgress : planProgress // ignore: cast_nullable_to_non_nullable
as PlanProgress?,unreadNotesCount: null == unreadNotesCount ? _self.unreadNotesCount : unreadNotesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of StudentDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StudentStatsCopyWith<$Res> get stats {
  
  return $StudentStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}/// Create a copy of StudentDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayWorkoutCopyWith<$Res>? get todayWorkout {
    if (_self.todayWorkout == null) {
    return null;
  }

  return $TodayWorkoutCopyWith<$Res>(_self.todayWorkout!, (value) {
    return _then(_self.copyWith(todayWorkout: value));
  });
}/// Create a copy of StudentDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeeklyProgressCopyWith<$Res> get weeklyProgress {
  
  return $WeeklyProgressCopyWith<$Res>(_self.weeklyProgress, (value) {
    return _then(_self.copyWith(weeklyProgress: value));
  });
}/// Create a copy of StudentDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrainerInfoCopyWith<$Res>? get trainer {
    if (_self.trainer == null) {
    return null;
  }

  return $TrainerInfoCopyWith<$Res>(_self.trainer!, (value) {
    return _then(_self.copyWith(trainer: value));
  });
}/// Create a copy of StudentDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanProgressCopyWith<$Res>? get planProgress {
    if (_self.planProgress == null) {
    return null;
  }

  return $PlanProgressCopyWith<$Res>(_self.planProgress!, (value) {
    return _then(_self.copyWith(planProgress: value));
  });
}
}


/// Adds pattern-matching-related methods to [StudentDashboard].
extension StudentDashboardPatterns on StudentDashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentDashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentDashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentDashboard value)  $default,){
final _that = this;
switch (_that) {
case _StudentDashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentDashboard value)?  $default,){
final _that = this;
switch (_that) {
case _StudentDashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StudentStats stats, @JsonKey(name: 'today_workout')  TodayWorkout? todayWorkout, @JsonKey(name: 'weekly_progress')  WeeklyProgress weeklyProgress, @JsonKey(name: 'recent_activity')  List<RecentActivity> recentActivity,  TrainerInfo? trainer, @JsonKey(name: 'plan_progress')  PlanProgress? planProgress, @JsonKey(name: 'unread_notes_count')  int unreadNotesCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentDashboard() when $default != null:
return $default(_that.stats,_that.todayWorkout,_that.weeklyProgress,_that.recentActivity,_that.trainer,_that.planProgress,_that.unreadNotesCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StudentStats stats, @JsonKey(name: 'today_workout')  TodayWorkout? todayWorkout, @JsonKey(name: 'weekly_progress')  WeeklyProgress weeklyProgress, @JsonKey(name: 'recent_activity')  List<RecentActivity> recentActivity,  TrainerInfo? trainer, @JsonKey(name: 'plan_progress')  PlanProgress? planProgress, @JsonKey(name: 'unread_notes_count')  int unreadNotesCount)  $default,) {final _that = this;
switch (_that) {
case _StudentDashboard():
return $default(_that.stats,_that.todayWorkout,_that.weeklyProgress,_that.recentActivity,_that.trainer,_that.planProgress,_that.unreadNotesCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StudentStats stats, @JsonKey(name: 'today_workout')  TodayWorkout? todayWorkout, @JsonKey(name: 'weekly_progress')  WeeklyProgress weeklyProgress, @JsonKey(name: 'recent_activity')  List<RecentActivity> recentActivity,  TrainerInfo? trainer, @JsonKey(name: 'plan_progress')  PlanProgress? planProgress, @JsonKey(name: 'unread_notes_count')  int unreadNotesCount)?  $default,) {final _that = this;
switch (_that) {
case _StudentDashboard() when $default != null:
return $default(_that.stats,_that.todayWorkout,_that.weeklyProgress,_that.recentActivity,_that.trainer,_that.planProgress,_that.unreadNotesCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentDashboard extends StudentDashboard {
  const _StudentDashboard({required this.stats, @JsonKey(name: 'today_workout') this.todayWorkout, @JsonKey(name: 'weekly_progress') required this.weeklyProgress, @JsonKey(name: 'recent_activity') final  List<RecentActivity> recentActivity = const [], this.trainer, @JsonKey(name: 'plan_progress') this.planProgress, @JsonKey(name: 'unread_notes_count') this.unreadNotesCount = 0}): _recentActivity = recentActivity,super._();
  factory _StudentDashboard.fromJson(Map<String, dynamic> json) => _$StudentDashboardFromJson(json);

@override final  StudentStats stats;
@override@JsonKey(name: 'today_workout') final  TodayWorkout? todayWorkout;
@override@JsonKey(name: 'weekly_progress') final  WeeklyProgress weeklyProgress;
 final  List<RecentActivity> _recentActivity;
@override@JsonKey(name: 'recent_activity') List<RecentActivity> get recentActivity {
  if (_recentActivity is EqualUnmodifiableListView) return _recentActivity;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentActivity);
}

@override final  TrainerInfo? trainer;
@override@JsonKey(name: 'plan_progress') final  PlanProgress? planProgress;
@override@JsonKey(name: 'unread_notes_count') final  int unreadNotesCount;

/// Create a copy of StudentDashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentDashboardCopyWith<_StudentDashboard> get copyWith => __$StudentDashboardCopyWithImpl<_StudentDashboard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentDashboardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentDashboard&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.todayWorkout, todayWorkout) || other.todayWorkout == todayWorkout)&&(identical(other.weeklyProgress, weeklyProgress) || other.weeklyProgress == weeklyProgress)&&const DeepCollectionEquality().equals(other._recentActivity, _recentActivity)&&(identical(other.trainer, trainer) || other.trainer == trainer)&&(identical(other.planProgress, planProgress) || other.planProgress == planProgress)&&(identical(other.unreadNotesCount, unreadNotesCount) || other.unreadNotesCount == unreadNotesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stats,todayWorkout,weeklyProgress,const DeepCollectionEquality().hash(_recentActivity),trainer,planProgress,unreadNotesCount);

@override
String toString() {
  return 'StudentDashboard(stats: $stats, todayWorkout: $todayWorkout, weeklyProgress: $weeklyProgress, recentActivity: $recentActivity, trainer: $trainer, planProgress: $planProgress, unreadNotesCount: $unreadNotesCount)';
}


}

/// @nodoc
abstract mixin class _$StudentDashboardCopyWith<$Res> implements $StudentDashboardCopyWith<$Res> {
  factory _$StudentDashboardCopyWith(_StudentDashboard value, $Res Function(_StudentDashboard) _then) = __$StudentDashboardCopyWithImpl;
@override @useResult
$Res call({
 StudentStats stats,@JsonKey(name: 'today_workout') TodayWorkout? todayWorkout,@JsonKey(name: 'weekly_progress') WeeklyProgress weeklyProgress,@JsonKey(name: 'recent_activity') List<RecentActivity> recentActivity, TrainerInfo? trainer,@JsonKey(name: 'plan_progress') PlanProgress? planProgress,@JsonKey(name: 'unread_notes_count') int unreadNotesCount
});


@override $StudentStatsCopyWith<$Res> get stats;@override $TodayWorkoutCopyWith<$Res>? get todayWorkout;@override $WeeklyProgressCopyWith<$Res> get weeklyProgress;@override $TrainerInfoCopyWith<$Res>? get trainer;@override $PlanProgressCopyWith<$Res>? get planProgress;

}
/// @nodoc
class __$StudentDashboardCopyWithImpl<$Res>
    implements _$StudentDashboardCopyWith<$Res> {
  __$StudentDashboardCopyWithImpl(this._self, this._then);

  final _StudentDashboard _self;
  final $Res Function(_StudentDashboard) _then;

/// Create a copy of StudentDashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stats = null,Object? todayWorkout = freezed,Object? weeklyProgress = null,Object? recentActivity = null,Object? trainer = freezed,Object? planProgress = freezed,Object? unreadNotesCount = null,}) {
  return _then(_StudentDashboard(
stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as StudentStats,todayWorkout: freezed == todayWorkout ? _self.todayWorkout : todayWorkout // ignore: cast_nullable_to_non_nullable
as TodayWorkout?,weeklyProgress: null == weeklyProgress ? _self.weeklyProgress : weeklyProgress // ignore: cast_nullable_to_non_nullable
as WeeklyProgress,recentActivity: null == recentActivity ? _self._recentActivity : recentActivity // ignore: cast_nullable_to_non_nullable
as List<RecentActivity>,trainer: freezed == trainer ? _self.trainer : trainer // ignore: cast_nullable_to_non_nullable
as TrainerInfo?,planProgress: freezed == planProgress ? _self.planProgress : planProgress // ignore: cast_nullable_to_non_nullable
as PlanProgress?,unreadNotesCount: null == unreadNotesCount ? _self.unreadNotesCount : unreadNotesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of StudentDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StudentStatsCopyWith<$Res> get stats {
  
  return $StudentStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}/// Create a copy of StudentDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayWorkoutCopyWith<$Res>? get todayWorkout {
    if (_self.todayWorkout == null) {
    return null;
  }

  return $TodayWorkoutCopyWith<$Res>(_self.todayWorkout!, (value) {
    return _then(_self.copyWith(todayWorkout: value));
  });
}/// Create a copy of StudentDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeeklyProgressCopyWith<$Res> get weeklyProgress {
  
  return $WeeklyProgressCopyWith<$Res>(_self.weeklyProgress, (value) {
    return _then(_self.copyWith(weeklyProgress: value));
  });
}/// Create a copy of StudentDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrainerInfoCopyWith<$Res>? get trainer {
    if (_self.trainer == null) {
    return null;
  }

  return $TrainerInfoCopyWith<$Res>(_self.trainer!, (value) {
    return _then(_self.copyWith(trainer: value));
  });
}/// Create a copy of StudentDashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanProgressCopyWith<$Res>? get planProgress {
    if (_self.planProgress == null) {
    return null;
  }

  return $PlanProgressCopyWith<$Res>(_self.planProgress!, (value) {
    return _then(_self.copyWith(planProgress: value));
  });
}
}

// dart format on
