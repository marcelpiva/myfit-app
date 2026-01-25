// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_wizard_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WizardExercise {

 String get id; String get exerciseId; String get name; String get muscleGroup; int get sets; String get reps; int get restSeconds; String get notes;// Advanced technique fields
 String get executionInstructions;// Individual exercise instructions
 String get groupInstructions;// Group instructions (for bi-set, tri-set, etc.)
 int? get isometricSeconds; TechniqueType get techniqueType; String? get exerciseGroupId; int get exerciseGroupOrder;// Structured technique parameters (for dropset, rest-pause, cluster)
 int? get dropCount;// Dropset: number of drops (2-5)
 int? get restBetweenDrops;// Dropset: seconds between drops (0, 5, 10, 15)
 int? get pauseDuration;// Rest-Pause/Cluster: pause duration in seconds
 int? get miniSetCount;// Cluster: number of mini-sets (3-6)
// Exercise mode (strength vs aerobic)
 ExerciseMode get exerciseMode;// Aerobic exercise fields - Duration mode (continuous cardio)
 int? get durationMinutes;// Total duration in minutes
 String? get intensity;// low, moderate, high, max
// Aerobic exercise fields - Interval mode (HIIT)
 int? get workSeconds;// Work interval duration
 int? get intervalRestSeconds;// Rest between intervals
 int? get rounds;// Number of rounds
// Aerobic exercise fields - Distance mode (running)
 double? get distanceKm;// Distance in kilometers
 double? get targetPaceMinPerKm;
/// Create a copy of WizardExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WizardExerciseCopyWith<WizardExercise> get copyWith => _$WizardExerciseCopyWithImpl<WizardExercise>(this as WizardExercise, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WizardExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.executionInstructions, executionInstructions) || other.executionInstructions == executionInstructions)&&(identical(other.groupInstructions, groupInstructions) || other.groupInstructions == groupInstructions)&&(identical(other.isometricSeconds, isometricSeconds) || other.isometricSeconds == isometricSeconds)&&(identical(other.techniqueType, techniqueType) || other.techniqueType == techniqueType)&&(identical(other.exerciseGroupId, exerciseGroupId) || other.exerciseGroupId == exerciseGroupId)&&(identical(other.exerciseGroupOrder, exerciseGroupOrder) || other.exerciseGroupOrder == exerciseGroupOrder)&&(identical(other.dropCount, dropCount) || other.dropCount == dropCount)&&(identical(other.restBetweenDrops, restBetweenDrops) || other.restBetweenDrops == restBetweenDrops)&&(identical(other.pauseDuration, pauseDuration) || other.pauseDuration == pauseDuration)&&(identical(other.miniSetCount, miniSetCount) || other.miniSetCount == miniSetCount)&&(identical(other.exerciseMode, exerciseMode) || other.exerciseMode == exerciseMode)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.intensity, intensity) || other.intensity == intensity)&&(identical(other.workSeconds, workSeconds) || other.workSeconds == workSeconds)&&(identical(other.intervalRestSeconds, intervalRestSeconds) || other.intervalRestSeconds == intervalRestSeconds)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.targetPaceMinPerKm, targetPaceMinPerKm) || other.targetPaceMinPerKm == targetPaceMinPerKm));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,exerciseId,name,muscleGroup,sets,reps,restSeconds,notes,executionInstructions,groupInstructions,isometricSeconds,techniqueType,exerciseGroupId,exerciseGroupOrder,dropCount,restBetweenDrops,pauseDuration,miniSetCount,exerciseMode,durationMinutes,intensity,workSeconds,intervalRestSeconds,rounds,distanceKm,targetPaceMinPerKm]);

@override
String toString() {
  return 'WizardExercise(id: $id, exerciseId: $exerciseId, name: $name, muscleGroup: $muscleGroup, sets: $sets, reps: $reps, restSeconds: $restSeconds, notes: $notes, executionInstructions: $executionInstructions, groupInstructions: $groupInstructions, isometricSeconds: $isometricSeconds, techniqueType: $techniqueType, exerciseGroupId: $exerciseGroupId, exerciseGroupOrder: $exerciseGroupOrder, dropCount: $dropCount, restBetweenDrops: $restBetweenDrops, pauseDuration: $pauseDuration, miniSetCount: $miniSetCount, exerciseMode: $exerciseMode, durationMinutes: $durationMinutes, intensity: $intensity, workSeconds: $workSeconds, intervalRestSeconds: $intervalRestSeconds, rounds: $rounds, distanceKm: $distanceKm, targetPaceMinPerKm: $targetPaceMinPerKm)';
}


}

/// @nodoc
abstract mixin class $WizardExerciseCopyWith<$Res>  {
  factory $WizardExerciseCopyWith(WizardExercise value, $Res Function(WizardExercise) _then) = _$WizardExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, String name, String muscleGroup, int sets, String reps, int restSeconds, String notes, String executionInstructions, String groupInstructions, int? isometricSeconds, TechniqueType techniqueType, String? exerciseGroupId, int exerciseGroupOrder, int? dropCount, int? restBetweenDrops, int? pauseDuration, int? miniSetCount, ExerciseMode exerciseMode, int? durationMinutes, String? intensity, int? workSeconds, int? intervalRestSeconds, int? rounds, double? distanceKm, double? targetPaceMinPerKm
});




}
/// @nodoc
class _$WizardExerciseCopyWithImpl<$Res>
    implements $WizardExerciseCopyWith<$Res> {
  _$WizardExerciseCopyWithImpl(this._self, this._then);

  final WizardExercise _self;
  final $Res Function(WizardExercise) _then;

/// Create a copy of WizardExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? name = null,Object? muscleGroup = null,Object? sets = null,Object? reps = null,Object? restSeconds = null,Object? notes = null,Object? executionInstructions = null,Object? groupInstructions = null,Object? isometricSeconds = freezed,Object? techniqueType = null,Object? exerciseGroupId = freezed,Object? exerciseGroupOrder = null,Object? dropCount = freezed,Object? restBetweenDrops = freezed,Object? pauseDuration = freezed,Object? miniSetCount = freezed,Object? exerciseMode = null,Object? durationMinutes = freezed,Object? intensity = freezed,Object? workSeconds = freezed,Object? intervalRestSeconds = freezed,Object? rounds = freezed,Object? distanceKm = freezed,Object? targetPaceMinPerKm = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,muscleGroup: null == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as String,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,executionInstructions: null == executionInstructions ? _self.executionInstructions : executionInstructions // ignore: cast_nullable_to_non_nullable
as String,groupInstructions: null == groupInstructions ? _self.groupInstructions : groupInstructions // ignore: cast_nullable_to_non_nullable
as String,isometricSeconds: freezed == isometricSeconds ? _self.isometricSeconds : isometricSeconds // ignore: cast_nullable_to_non_nullable
as int?,techniqueType: null == techniqueType ? _self.techniqueType : techniqueType // ignore: cast_nullable_to_non_nullable
as TechniqueType,exerciseGroupId: freezed == exerciseGroupId ? _self.exerciseGroupId : exerciseGroupId // ignore: cast_nullable_to_non_nullable
as String?,exerciseGroupOrder: null == exerciseGroupOrder ? _self.exerciseGroupOrder : exerciseGroupOrder // ignore: cast_nullable_to_non_nullable
as int,dropCount: freezed == dropCount ? _self.dropCount : dropCount // ignore: cast_nullable_to_non_nullable
as int?,restBetweenDrops: freezed == restBetweenDrops ? _self.restBetweenDrops : restBetweenDrops // ignore: cast_nullable_to_non_nullable
as int?,pauseDuration: freezed == pauseDuration ? _self.pauseDuration : pauseDuration // ignore: cast_nullable_to_non_nullable
as int?,miniSetCount: freezed == miniSetCount ? _self.miniSetCount : miniSetCount // ignore: cast_nullable_to_non_nullable
as int?,exerciseMode: null == exerciseMode ? _self.exerciseMode : exerciseMode // ignore: cast_nullable_to_non_nullable
as ExerciseMode,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,intensity: freezed == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as String?,workSeconds: freezed == workSeconds ? _self.workSeconds : workSeconds // ignore: cast_nullable_to_non_nullable
as int?,intervalRestSeconds: freezed == intervalRestSeconds ? _self.intervalRestSeconds : intervalRestSeconds // ignore: cast_nullable_to_non_nullable
as int?,rounds: freezed == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,targetPaceMinPerKm: freezed == targetPaceMinPerKm ? _self.targetPaceMinPerKm : targetPaceMinPerKm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [WizardExercise].
extension WizardExercisePatterns on WizardExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WizardExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WizardExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WizardExercise value)  $default,){
final _that = this;
switch (_that) {
case _WizardExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WizardExercise value)?  $default,){
final _that = this;
switch (_that) {
case _WizardExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String name,  String muscleGroup,  int sets,  String reps,  int restSeconds,  String notes,  String executionInstructions,  String groupInstructions,  int? isometricSeconds,  TechniqueType techniqueType,  String? exerciseGroupId,  int exerciseGroupOrder,  int? dropCount,  int? restBetweenDrops,  int? pauseDuration,  int? miniSetCount,  ExerciseMode exerciseMode,  int? durationMinutes,  String? intensity,  int? workSeconds,  int? intervalRestSeconds,  int? rounds,  double? distanceKm,  double? targetPaceMinPerKm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WizardExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.name,_that.muscleGroup,_that.sets,_that.reps,_that.restSeconds,_that.notes,_that.executionInstructions,_that.groupInstructions,_that.isometricSeconds,_that.techniqueType,_that.exerciseGroupId,_that.exerciseGroupOrder,_that.dropCount,_that.restBetweenDrops,_that.pauseDuration,_that.miniSetCount,_that.exerciseMode,_that.durationMinutes,_that.intensity,_that.workSeconds,_that.intervalRestSeconds,_that.rounds,_that.distanceKm,_that.targetPaceMinPerKm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String name,  String muscleGroup,  int sets,  String reps,  int restSeconds,  String notes,  String executionInstructions,  String groupInstructions,  int? isometricSeconds,  TechniqueType techniqueType,  String? exerciseGroupId,  int exerciseGroupOrder,  int? dropCount,  int? restBetweenDrops,  int? pauseDuration,  int? miniSetCount,  ExerciseMode exerciseMode,  int? durationMinutes,  String? intensity,  int? workSeconds,  int? intervalRestSeconds,  int? rounds,  double? distanceKm,  double? targetPaceMinPerKm)  $default,) {final _that = this;
switch (_that) {
case _WizardExercise():
return $default(_that.id,_that.exerciseId,_that.name,_that.muscleGroup,_that.sets,_that.reps,_that.restSeconds,_that.notes,_that.executionInstructions,_that.groupInstructions,_that.isometricSeconds,_that.techniqueType,_that.exerciseGroupId,_that.exerciseGroupOrder,_that.dropCount,_that.restBetweenDrops,_that.pauseDuration,_that.miniSetCount,_that.exerciseMode,_that.durationMinutes,_that.intensity,_that.workSeconds,_that.intervalRestSeconds,_that.rounds,_that.distanceKm,_that.targetPaceMinPerKm);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  String name,  String muscleGroup,  int sets,  String reps,  int restSeconds,  String notes,  String executionInstructions,  String groupInstructions,  int? isometricSeconds,  TechniqueType techniqueType,  String? exerciseGroupId,  int exerciseGroupOrder,  int? dropCount,  int? restBetweenDrops,  int? pauseDuration,  int? miniSetCount,  ExerciseMode exerciseMode,  int? durationMinutes,  String? intensity,  int? workSeconds,  int? intervalRestSeconds,  int? rounds,  double? distanceKm,  double? targetPaceMinPerKm)?  $default,) {final _that = this;
switch (_that) {
case _WizardExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.name,_that.muscleGroup,_that.sets,_that.reps,_that.restSeconds,_that.notes,_that.executionInstructions,_that.groupInstructions,_that.isometricSeconds,_that.techniqueType,_that.exerciseGroupId,_that.exerciseGroupOrder,_that.dropCount,_that.restBetweenDrops,_that.pauseDuration,_that.miniSetCount,_that.exerciseMode,_that.durationMinutes,_that.intensity,_that.workSeconds,_that.intervalRestSeconds,_that.rounds,_that.distanceKm,_that.targetPaceMinPerKm);case _:
  return null;

}
}

}

/// @nodoc


class _WizardExercise extends WizardExercise {
  const _WizardExercise({required this.id, required this.exerciseId, required this.name, required this.muscleGroup, this.sets = 3, this.reps = '10-12', this.restSeconds = 60, this.notes = '', this.executionInstructions = '', this.groupInstructions = '', this.isometricSeconds, this.techniqueType = TechniqueType.normal, this.exerciseGroupId, this.exerciseGroupOrder = 0, this.dropCount, this.restBetweenDrops, this.pauseDuration, this.miniSetCount, this.exerciseMode = ExerciseMode.strength, this.durationMinutes, this.intensity, this.workSeconds, this.intervalRestSeconds, this.rounds, this.distanceKm, this.targetPaceMinPerKm}): super._();
  

@override final  String id;
@override final  String exerciseId;
@override final  String name;
@override final  String muscleGroup;
@override@JsonKey() final  int sets;
@override@JsonKey() final  String reps;
@override@JsonKey() final  int restSeconds;
@override@JsonKey() final  String notes;
// Advanced technique fields
@override@JsonKey() final  String executionInstructions;
// Individual exercise instructions
@override@JsonKey() final  String groupInstructions;
// Group instructions (for bi-set, tri-set, etc.)
@override final  int? isometricSeconds;
@override@JsonKey() final  TechniqueType techniqueType;
@override final  String? exerciseGroupId;
@override@JsonKey() final  int exerciseGroupOrder;
// Structured technique parameters (for dropset, rest-pause, cluster)
@override final  int? dropCount;
// Dropset: number of drops (2-5)
@override final  int? restBetweenDrops;
// Dropset: seconds between drops (0, 5, 10, 15)
@override final  int? pauseDuration;
// Rest-Pause/Cluster: pause duration in seconds
@override final  int? miniSetCount;
// Cluster: number of mini-sets (3-6)
// Exercise mode (strength vs aerobic)
@override@JsonKey() final  ExerciseMode exerciseMode;
// Aerobic exercise fields - Duration mode (continuous cardio)
@override final  int? durationMinutes;
// Total duration in minutes
@override final  String? intensity;
// low, moderate, high, max
// Aerobic exercise fields - Interval mode (HIIT)
@override final  int? workSeconds;
// Work interval duration
@override final  int? intervalRestSeconds;
// Rest between intervals
@override final  int? rounds;
// Number of rounds
// Aerobic exercise fields - Distance mode (running)
@override final  double? distanceKm;
// Distance in kilometers
@override final  double? targetPaceMinPerKm;

/// Create a copy of WizardExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WizardExerciseCopyWith<_WizardExercise> get copyWith => __$WizardExerciseCopyWithImpl<_WizardExercise>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WizardExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.executionInstructions, executionInstructions) || other.executionInstructions == executionInstructions)&&(identical(other.groupInstructions, groupInstructions) || other.groupInstructions == groupInstructions)&&(identical(other.isometricSeconds, isometricSeconds) || other.isometricSeconds == isometricSeconds)&&(identical(other.techniqueType, techniqueType) || other.techniqueType == techniqueType)&&(identical(other.exerciseGroupId, exerciseGroupId) || other.exerciseGroupId == exerciseGroupId)&&(identical(other.exerciseGroupOrder, exerciseGroupOrder) || other.exerciseGroupOrder == exerciseGroupOrder)&&(identical(other.dropCount, dropCount) || other.dropCount == dropCount)&&(identical(other.restBetweenDrops, restBetweenDrops) || other.restBetweenDrops == restBetweenDrops)&&(identical(other.pauseDuration, pauseDuration) || other.pauseDuration == pauseDuration)&&(identical(other.miniSetCount, miniSetCount) || other.miniSetCount == miniSetCount)&&(identical(other.exerciseMode, exerciseMode) || other.exerciseMode == exerciseMode)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.intensity, intensity) || other.intensity == intensity)&&(identical(other.workSeconds, workSeconds) || other.workSeconds == workSeconds)&&(identical(other.intervalRestSeconds, intervalRestSeconds) || other.intervalRestSeconds == intervalRestSeconds)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.targetPaceMinPerKm, targetPaceMinPerKm) || other.targetPaceMinPerKm == targetPaceMinPerKm));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,exerciseId,name,muscleGroup,sets,reps,restSeconds,notes,executionInstructions,groupInstructions,isometricSeconds,techniqueType,exerciseGroupId,exerciseGroupOrder,dropCount,restBetweenDrops,pauseDuration,miniSetCount,exerciseMode,durationMinutes,intensity,workSeconds,intervalRestSeconds,rounds,distanceKm,targetPaceMinPerKm]);

@override
String toString() {
  return 'WizardExercise(id: $id, exerciseId: $exerciseId, name: $name, muscleGroup: $muscleGroup, sets: $sets, reps: $reps, restSeconds: $restSeconds, notes: $notes, executionInstructions: $executionInstructions, groupInstructions: $groupInstructions, isometricSeconds: $isometricSeconds, techniqueType: $techniqueType, exerciseGroupId: $exerciseGroupId, exerciseGroupOrder: $exerciseGroupOrder, dropCount: $dropCount, restBetweenDrops: $restBetweenDrops, pauseDuration: $pauseDuration, miniSetCount: $miniSetCount, exerciseMode: $exerciseMode, durationMinutes: $durationMinutes, intensity: $intensity, workSeconds: $workSeconds, intervalRestSeconds: $intervalRestSeconds, rounds: $rounds, distanceKm: $distanceKm, targetPaceMinPerKm: $targetPaceMinPerKm)';
}


}

/// @nodoc
abstract mixin class _$WizardExerciseCopyWith<$Res> implements $WizardExerciseCopyWith<$Res> {
  factory _$WizardExerciseCopyWith(_WizardExercise value, $Res Function(_WizardExercise) _then) = __$WizardExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, String name, String muscleGroup, int sets, String reps, int restSeconds, String notes, String executionInstructions, String groupInstructions, int? isometricSeconds, TechniqueType techniqueType, String? exerciseGroupId, int exerciseGroupOrder, int? dropCount, int? restBetweenDrops, int? pauseDuration, int? miniSetCount, ExerciseMode exerciseMode, int? durationMinutes, String? intensity, int? workSeconds, int? intervalRestSeconds, int? rounds, double? distanceKm, double? targetPaceMinPerKm
});




}
/// @nodoc
class __$WizardExerciseCopyWithImpl<$Res>
    implements _$WizardExerciseCopyWith<$Res> {
  __$WizardExerciseCopyWithImpl(this._self, this._then);

  final _WizardExercise _self;
  final $Res Function(_WizardExercise) _then;

/// Create a copy of WizardExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? name = null,Object? muscleGroup = null,Object? sets = null,Object? reps = null,Object? restSeconds = null,Object? notes = null,Object? executionInstructions = null,Object? groupInstructions = null,Object? isometricSeconds = freezed,Object? techniqueType = null,Object? exerciseGroupId = freezed,Object? exerciseGroupOrder = null,Object? dropCount = freezed,Object? restBetweenDrops = freezed,Object? pauseDuration = freezed,Object? miniSetCount = freezed,Object? exerciseMode = null,Object? durationMinutes = freezed,Object? intensity = freezed,Object? workSeconds = freezed,Object? intervalRestSeconds = freezed,Object? rounds = freezed,Object? distanceKm = freezed,Object? targetPaceMinPerKm = freezed,}) {
  return _then(_WizardExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,muscleGroup: null == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as String,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,executionInstructions: null == executionInstructions ? _self.executionInstructions : executionInstructions // ignore: cast_nullable_to_non_nullable
as String,groupInstructions: null == groupInstructions ? _self.groupInstructions : groupInstructions // ignore: cast_nullable_to_non_nullable
as String,isometricSeconds: freezed == isometricSeconds ? _self.isometricSeconds : isometricSeconds // ignore: cast_nullable_to_non_nullable
as int?,techniqueType: null == techniqueType ? _self.techniqueType : techniqueType // ignore: cast_nullable_to_non_nullable
as TechniqueType,exerciseGroupId: freezed == exerciseGroupId ? _self.exerciseGroupId : exerciseGroupId // ignore: cast_nullable_to_non_nullable
as String?,exerciseGroupOrder: null == exerciseGroupOrder ? _self.exerciseGroupOrder : exerciseGroupOrder // ignore: cast_nullable_to_non_nullable
as int,dropCount: freezed == dropCount ? _self.dropCount : dropCount // ignore: cast_nullable_to_non_nullable
as int?,restBetweenDrops: freezed == restBetweenDrops ? _self.restBetweenDrops : restBetweenDrops // ignore: cast_nullable_to_non_nullable
as int?,pauseDuration: freezed == pauseDuration ? _self.pauseDuration : pauseDuration // ignore: cast_nullable_to_non_nullable
as int?,miniSetCount: freezed == miniSetCount ? _self.miniSetCount : miniSetCount // ignore: cast_nullable_to_non_nullable
as int?,exerciseMode: null == exerciseMode ? _self.exerciseMode : exerciseMode // ignore: cast_nullable_to_non_nullable
as ExerciseMode,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,intensity: freezed == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as String?,workSeconds: freezed == workSeconds ? _self.workSeconds : workSeconds // ignore: cast_nullable_to_non_nullable
as int?,intervalRestSeconds: freezed == intervalRestSeconds ? _self.intervalRestSeconds : intervalRestSeconds // ignore: cast_nullable_to_non_nullable
as int?,rounds: freezed == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,targetPaceMinPerKm: freezed == targetPaceMinPerKm ? _self.targetPaceMinPerKm : targetPaceMinPerKm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$WizardWorkout {

 String get id; String get label; String get name; List<String> get muscleGroups; List<WizardExercise> get exercises; int get order; int? get dayOfWeek;
/// Create a copy of WizardWorkout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WizardWorkoutCopyWith<WizardWorkout> get copyWith => _$WizardWorkoutCopyWithImpl<WizardWorkout>(this as WizardWorkout, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WizardWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.muscleGroups, muscleGroups)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.order, order) || other.order == order)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,name,const DeepCollectionEquality().hash(muscleGroups),const DeepCollectionEquality().hash(exercises),order,dayOfWeek);

@override
String toString() {
  return 'WizardWorkout(id: $id, label: $label, name: $name, muscleGroups: $muscleGroups, exercises: $exercises, order: $order, dayOfWeek: $dayOfWeek)';
}


}

/// @nodoc
abstract mixin class $WizardWorkoutCopyWith<$Res>  {
  factory $WizardWorkoutCopyWith(WizardWorkout value, $Res Function(WizardWorkout) _then) = _$WizardWorkoutCopyWithImpl;
@useResult
$Res call({
 String id, String label, String name, List<String> muscleGroups, List<WizardExercise> exercises, int order, int? dayOfWeek
});




}
/// @nodoc
class _$WizardWorkoutCopyWithImpl<$Res>
    implements $WizardWorkoutCopyWith<$Res> {
  _$WizardWorkoutCopyWithImpl(this._self, this._then);

  final WizardWorkout _self;
  final $Res Function(WizardWorkout) _then;

/// Create a copy of WizardWorkout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? name = null,Object? muscleGroups = null,Object? exercises = null,Object? order = null,Object? dayOfWeek = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,muscleGroups: null == muscleGroups ? _self.muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<String>,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<WizardExercise>,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,dayOfWeek: freezed == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [WizardWorkout].
extension WizardWorkoutPatterns on WizardWorkout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WizardWorkout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WizardWorkout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WizardWorkout value)  $default,){
final _that = this;
switch (_that) {
case _WizardWorkout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WizardWorkout value)?  $default,){
final _that = this;
switch (_that) {
case _WizardWorkout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String name,  List<String> muscleGroups,  List<WizardExercise> exercises,  int order,  int? dayOfWeek)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WizardWorkout() when $default != null:
return $default(_that.id,_that.label,_that.name,_that.muscleGroups,_that.exercises,_that.order,_that.dayOfWeek);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String name,  List<String> muscleGroups,  List<WizardExercise> exercises,  int order,  int? dayOfWeek)  $default,) {final _that = this;
switch (_that) {
case _WizardWorkout():
return $default(_that.id,_that.label,_that.name,_that.muscleGroups,_that.exercises,_that.order,_that.dayOfWeek);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String name,  List<String> muscleGroups,  List<WizardExercise> exercises,  int order,  int? dayOfWeek)?  $default,) {final _that = this;
switch (_that) {
case _WizardWorkout() when $default != null:
return $default(_that.id,_that.label,_that.name,_that.muscleGroups,_that.exercises,_that.order,_that.dayOfWeek);case _:
  return null;

}
}

}

/// @nodoc


class _WizardWorkout implements WizardWorkout {
  const _WizardWorkout({required this.id, required this.label, required this.name, final  List<String> muscleGroups = const [], final  List<WizardExercise> exercises = const [], this.order = 0, this.dayOfWeek}): _muscleGroups = muscleGroups,_exercises = exercises;
  

@override final  String id;
@override final  String label;
@override final  String name;
 final  List<String> _muscleGroups;
@override@JsonKey() List<String> get muscleGroups {
  if (_muscleGroups is EqualUnmodifiableListView) return _muscleGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_muscleGroups);
}

 final  List<WizardExercise> _exercises;
@override@JsonKey() List<WizardExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

@override@JsonKey() final  int order;
@override final  int? dayOfWeek;

/// Create a copy of WizardWorkout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WizardWorkoutCopyWith<_WizardWorkout> get copyWith => __$WizardWorkoutCopyWithImpl<_WizardWorkout>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WizardWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._muscleGroups, _muscleGroups)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.order, order) || other.order == order)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,name,const DeepCollectionEquality().hash(_muscleGroups),const DeepCollectionEquality().hash(_exercises),order,dayOfWeek);

@override
String toString() {
  return 'WizardWorkout(id: $id, label: $label, name: $name, muscleGroups: $muscleGroups, exercises: $exercises, order: $order, dayOfWeek: $dayOfWeek)';
}


}

/// @nodoc
abstract mixin class _$WizardWorkoutCopyWith<$Res> implements $WizardWorkoutCopyWith<$Res> {
  factory _$WizardWorkoutCopyWith(_WizardWorkout value, $Res Function(_WizardWorkout) _then) = __$WizardWorkoutCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String name, List<String> muscleGroups, List<WizardExercise> exercises, int order, int? dayOfWeek
});




}
/// @nodoc
class __$WizardWorkoutCopyWithImpl<$Res>
    implements _$WizardWorkoutCopyWith<$Res> {
  __$WizardWorkoutCopyWithImpl(this._self, this._then);

  final _WizardWorkout _self;
  final $Res Function(_WizardWorkout) _then;

/// Create a copy of WizardWorkout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? name = null,Object? muscleGroups = null,Object? exercises = null,Object? order = null,Object? dayOfWeek = freezed,}) {
  return _then(_WizardWorkout(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,muscleGroups: null == muscleGroups ? _self._muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<String>,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<WizardExercise>,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,dayOfWeek: freezed == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$PlanWizardState {

 int get currentStep; CreationMethod? get method; String get planName; WorkoutGoal get goal; PlanDifficulty get difficulty; SplitType get splitType; int? get durationWeeks; int? get targetWorkoutMinutes;// Target duration per workout in minutes (null = free/unlimited)
 List<WizardWorkout> get workouts; bool get isLoading; String? get error; bool get isTemplate; String? get templateId; String? get studentId; bool get isDirectPrescription;// Create directly for student (not saved as Model)
 String? get editingPlanId;// Periodization fields
 String? get basePlanId;// Source plan for periodization
 PeriodizationPhase? get phaseType;// Type of periodization phase
// Diet fields
 bool get includeDiet; DietType? get dietType; int? get dailyCalories; int? get proteinGrams; int? get carbsGrams; int? get fatGrams; int? get mealsPerDay; String? get dietNotes;// UI state for collapse/expand (survives reordering)
 Set<String> get collapsedExerciseIds; Set<String> get collapsedGroupIds;
/// Create a copy of PlanWizardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanWizardStateCopyWith<PlanWizardState> get copyWith => _$PlanWizardStateCopyWithImpl<PlanWizardState>(this as PlanWizardState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanWizardState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.method, method) || other.method == method)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.splitType, splitType) || other.splitType == splitType)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.targetWorkoutMinutes, targetWorkoutMinutes) || other.targetWorkoutMinutes == targetWorkoutMinutes)&&const DeepCollectionEquality().equals(other.workouts, workouts)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.isTemplate, isTemplate) || other.isTemplate == isTemplate)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.isDirectPrescription, isDirectPrescription) || other.isDirectPrescription == isDirectPrescription)&&(identical(other.editingPlanId, editingPlanId) || other.editingPlanId == editingPlanId)&&(identical(other.basePlanId, basePlanId) || other.basePlanId == basePlanId)&&(identical(other.phaseType, phaseType) || other.phaseType == phaseType)&&(identical(other.includeDiet, includeDiet) || other.includeDiet == includeDiet)&&(identical(other.dietType, dietType) || other.dietType == dietType)&&(identical(other.dailyCalories, dailyCalories) || other.dailyCalories == dailyCalories)&&(identical(other.proteinGrams, proteinGrams) || other.proteinGrams == proteinGrams)&&(identical(other.carbsGrams, carbsGrams) || other.carbsGrams == carbsGrams)&&(identical(other.fatGrams, fatGrams) || other.fatGrams == fatGrams)&&(identical(other.mealsPerDay, mealsPerDay) || other.mealsPerDay == mealsPerDay)&&(identical(other.dietNotes, dietNotes) || other.dietNotes == dietNotes)&&const DeepCollectionEquality().equals(other.collapsedExerciseIds, collapsedExerciseIds)&&const DeepCollectionEquality().equals(other.collapsedGroupIds, collapsedGroupIds));
}


@override
int get hashCode => Object.hashAll([runtimeType,currentStep,method,planName,goal,difficulty,splitType,durationWeeks,targetWorkoutMinutes,const DeepCollectionEquality().hash(workouts),isLoading,error,isTemplate,templateId,studentId,isDirectPrescription,editingPlanId,basePlanId,phaseType,includeDiet,dietType,dailyCalories,proteinGrams,carbsGrams,fatGrams,mealsPerDay,dietNotes,const DeepCollectionEquality().hash(collapsedExerciseIds),const DeepCollectionEquality().hash(collapsedGroupIds)]);

@override
String toString() {
  return 'PlanWizardState(currentStep: $currentStep, method: $method, planName: $planName, goal: $goal, difficulty: $difficulty, splitType: $splitType, durationWeeks: $durationWeeks, targetWorkoutMinutes: $targetWorkoutMinutes, workouts: $workouts, isLoading: $isLoading, error: $error, isTemplate: $isTemplate, templateId: $templateId, studentId: $studentId, isDirectPrescription: $isDirectPrescription, editingPlanId: $editingPlanId, basePlanId: $basePlanId, phaseType: $phaseType, includeDiet: $includeDiet, dietType: $dietType, dailyCalories: $dailyCalories, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, mealsPerDay: $mealsPerDay, dietNotes: $dietNotes, collapsedExerciseIds: $collapsedExerciseIds, collapsedGroupIds: $collapsedGroupIds)';
}


}

/// @nodoc
abstract mixin class $PlanWizardStateCopyWith<$Res>  {
  factory $PlanWizardStateCopyWith(PlanWizardState value, $Res Function(PlanWizardState) _then) = _$PlanWizardStateCopyWithImpl;
@useResult
$Res call({
 int currentStep, CreationMethod? method, String planName, WorkoutGoal goal, PlanDifficulty difficulty, SplitType splitType, int? durationWeeks, int? targetWorkoutMinutes, List<WizardWorkout> workouts, bool isLoading, String? error, bool isTemplate, String? templateId, String? studentId, bool isDirectPrescription, String? editingPlanId, String? basePlanId, PeriodizationPhase? phaseType, bool includeDiet, DietType? dietType, int? dailyCalories, int? proteinGrams, int? carbsGrams, int? fatGrams, int? mealsPerDay, String? dietNotes, Set<String> collapsedExerciseIds, Set<String> collapsedGroupIds
});




}
/// @nodoc
class _$PlanWizardStateCopyWithImpl<$Res>
    implements $PlanWizardStateCopyWith<$Res> {
  _$PlanWizardStateCopyWithImpl(this._self, this._then);

  final PlanWizardState _self;
  final $Res Function(PlanWizardState) _then;

/// Create a copy of PlanWizardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStep = null,Object? method = freezed,Object? planName = null,Object? goal = null,Object? difficulty = null,Object? splitType = null,Object? durationWeeks = freezed,Object? targetWorkoutMinutes = freezed,Object? workouts = null,Object? isLoading = null,Object? error = freezed,Object? isTemplate = null,Object? templateId = freezed,Object? studentId = freezed,Object? isDirectPrescription = null,Object? editingPlanId = freezed,Object? basePlanId = freezed,Object? phaseType = freezed,Object? includeDiet = null,Object? dietType = freezed,Object? dailyCalories = freezed,Object? proteinGrams = freezed,Object? carbsGrams = freezed,Object? fatGrams = freezed,Object? mealsPerDay = freezed,Object? dietNotes = freezed,Object? collapsedExerciseIds = null,Object? collapsedGroupIds = null,}) {
  return _then(_self.copyWith(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,method: freezed == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as CreationMethod?,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as WorkoutGoal,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as PlanDifficulty,splitType: null == splitType ? _self.splitType : splitType // ignore: cast_nullable_to_non_nullable
as SplitType,durationWeeks: freezed == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int?,targetWorkoutMinutes: freezed == targetWorkoutMinutes ? _self.targetWorkoutMinutes : targetWorkoutMinutes // ignore: cast_nullable_to_non_nullable
as int?,workouts: null == workouts ? _self.workouts : workouts // ignore: cast_nullable_to_non_nullable
as List<WizardWorkout>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,isTemplate: null == isTemplate ? _self.isTemplate : isTemplate // ignore: cast_nullable_to_non_nullable
as bool,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,isDirectPrescription: null == isDirectPrescription ? _self.isDirectPrescription : isDirectPrescription // ignore: cast_nullable_to_non_nullable
as bool,editingPlanId: freezed == editingPlanId ? _self.editingPlanId : editingPlanId // ignore: cast_nullable_to_non_nullable
as String?,basePlanId: freezed == basePlanId ? _self.basePlanId : basePlanId // ignore: cast_nullable_to_non_nullable
as String?,phaseType: freezed == phaseType ? _self.phaseType : phaseType // ignore: cast_nullable_to_non_nullable
as PeriodizationPhase?,includeDiet: null == includeDiet ? _self.includeDiet : includeDiet // ignore: cast_nullable_to_non_nullable
as bool,dietType: freezed == dietType ? _self.dietType : dietType // ignore: cast_nullable_to_non_nullable
as DietType?,dailyCalories: freezed == dailyCalories ? _self.dailyCalories : dailyCalories // ignore: cast_nullable_to_non_nullable
as int?,proteinGrams: freezed == proteinGrams ? _self.proteinGrams : proteinGrams // ignore: cast_nullable_to_non_nullable
as int?,carbsGrams: freezed == carbsGrams ? _self.carbsGrams : carbsGrams // ignore: cast_nullable_to_non_nullable
as int?,fatGrams: freezed == fatGrams ? _self.fatGrams : fatGrams // ignore: cast_nullable_to_non_nullable
as int?,mealsPerDay: freezed == mealsPerDay ? _self.mealsPerDay : mealsPerDay // ignore: cast_nullable_to_non_nullable
as int?,dietNotes: freezed == dietNotes ? _self.dietNotes : dietNotes // ignore: cast_nullable_to_non_nullable
as String?,collapsedExerciseIds: null == collapsedExerciseIds ? _self.collapsedExerciseIds : collapsedExerciseIds // ignore: cast_nullable_to_non_nullable
as Set<String>,collapsedGroupIds: null == collapsedGroupIds ? _self.collapsedGroupIds : collapsedGroupIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanWizardState].
extension PlanWizardStatePatterns on PlanWizardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanWizardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanWizardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanWizardState value)  $default,){
final _that = this;
switch (_that) {
case _PlanWizardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanWizardState value)?  $default,){
final _that = this;
switch (_that) {
case _PlanWizardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentStep,  CreationMethod? method,  String planName,  WorkoutGoal goal,  PlanDifficulty difficulty,  SplitType splitType,  int? durationWeeks,  int? targetWorkoutMinutes,  List<WizardWorkout> workouts,  bool isLoading,  String? error,  bool isTemplate,  String? templateId,  String? studentId,  bool isDirectPrescription,  String? editingPlanId,  String? basePlanId,  PeriodizationPhase? phaseType,  bool includeDiet,  DietType? dietType,  int? dailyCalories,  int? proteinGrams,  int? carbsGrams,  int? fatGrams,  int? mealsPerDay,  String? dietNotes,  Set<String> collapsedExerciseIds,  Set<String> collapsedGroupIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanWizardState() when $default != null:
return $default(_that.currentStep,_that.method,_that.planName,_that.goal,_that.difficulty,_that.splitType,_that.durationWeeks,_that.targetWorkoutMinutes,_that.workouts,_that.isLoading,_that.error,_that.isTemplate,_that.templateId,_that.studentId,_that.isDirectPrescription,_that.editingPlanId,_that.basePlanId,_that.phaseType,_that.includeDiet,_that.dietType,_that.dailyCalories,_that.proteinGrams,_that.carbsGrams,_that.fatGrams,_that.mealsPerDay,_that.dietNotes,_that.collapsedExerciseIds,_that.collapsedGroupIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentStep,  CreationMethod? method,  String planName,  WorkoutGoal goal,  PlanDifficulty difficulty,  SplitType splitType,  int? durationWeeks,  int? targetWorkoutMinutes,  List<WizardWorkout> workouts,  bool isLoading,  String? error,  bool isTemplate,  String? templateId,  String? studentId,  bool isDirectPrescription,  String? editingPlanId,  String? basePlanId,  PeriodizationPhase? phaseType,  bool includeDiet,  DietType? dietType,  int? dailyCalories,  int? proteinGrams,  int? carbsGrams,  int? fatGrams,  int? mealsPerDay,  String? dietNotes,  Set<String> collapsedExerciseIds,  Set<String> collapsedGroupIds)  $default,) {final _that = this;
switch (_that) {
case _PlanWizardState():
return $default(_that.currentStep,_that.method,_that.planName,_that.goal,_that.difficulty,_that.splitType,_that.durationWeeks,_that.targetWorkoutMinutes,_that.workouts,_that.isLoading,_that.error,_that.isTemplate,_that.templateId,_that.studentId,_that.isDirectPrescription,_that.editingPlanId,_that.basePlanId,_that.phaseType,_that.includeDiet,_that.dietType,_that.dailyCalories,_that.proteinGrams,_that.carbsGrams,_that.fatGrams,_that.mealsPerDay,_that.dietNotes,_that.collapsedExerciseIds,_that.collapsedGroupIds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentStep,  CreationMethod? method,  String planName,  WorkoutGoal goal,  PlanDifficulty difficulty,  SplitType splitType,  int? durationWeeks,  int? targetWorkoutMinutes,  List<WizardWorkout> workouts,  bool isLoading,  String? error,  bool isTemplate,  String? templateId,  String? studentId,  bool isDirectPrescription,  String? editingPlanId,  String? basePlanId,  PeriodizationPhase? phaseType,  bool includeDiet,  DietType? dietType,  int? dailyCalories,  int? proteinGrams,  int? carbsGrams,  int? fatGrams,  int? mealsPerDay,  String? dietNotes,  Set<String> collapsedExerciseIds,  Set<String> collapsedGroupIds)?  $default,) {final _that = this;
switch (_that) {
case _PlanWizardState() when $default != null:
return $default(_that.currentStep,_that.method,_that.planName,_that.goal,_that.difficulty,_that.splitType,_that.durationWeeks,_that.targetWorkoutMinutes,_that.workouts,_that.isLoading,_that.error,_that.isTemplate,_that.templateId,_that.studentId,_that.isDirectPrescription,_that.editingPlanId,_that.basePlanId,_that.phaseType,_that.includeDiet,_that.dietType,_that.dailyCalories,_that.proteinGrams,_that.carbsGrams,_that.fatGrams,_that.mealsPerDay,_that.dietNotes,_that.collapsedExerciseIds,_that.collapsedGroupIds);case _:
  return null;

}
}

}

/// @nodoc


class _PlanWizardState extends PlanWizardState {
  const _PlanWizardState({this.currentStep = 0, this.method, this.planName = '', this.goal = WorkoutGoal.hypertrophy, this.difficulty = PlanDifficulty.intermediate, this.splitType = SplitType.abc, this.durationWeeks, this.targetWorkoutMinutes, final  List<WizardWorkout> workouts = const [], this.isLoading = false, this.error, this.isTemplate = false, this.templateId, this.studentId, this.isDirectPrescription = false, this.editingPlanId, this.basePlanId, this.phaseType, this.includeDiet = false, this.dietType, this.dailyCalories, this.proteinGrams, this.carbsGrams, this.fatGrams, this.mealsPerDay, this.dietNotes, final  Set<String> collapsedExerciseIds = const {}, final  Set<String> collapsedGroupIds = const {}}): _workouts = workouts,_collapsedExerciseIds = collapsedExerciseIds,_collapsedGroupIds = collapsedGroupIds,super._();
  

@override@JsonKey() final  int currentStep;
@override final  CreationMethod? method;
@override@JsonKey() final  String planName;
@override@JsonKey() final  WorkoutGoal goal;
@override@JsonKey() final  PlanDifficulty difficulty;
@override@JsonKey() final  SplitType splitType;
@override final  int? durationWeeks;
@override final  int? targetWorkoutMinutes;
// Target duration per workout in minutes (null = free/unlimited)
 final  List<WizardWorkout> _workouts;
// Target duration per workout in minutes (null = free/unlimited)
@override@JsonKey() List<WizardWorkout> get workouts {
  if (_workouts is EqualUnmodifiableListView) return _workouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workouts);
}

@override@JsonKey() final  bool isLoading;
@override final  String? error;
@override@JsonKey() final  bool isTemplate;
@override final  String? templateId;
@override final  String? studentId;
@override@JsonKey() final  bool isDirectPrescription;
// Create directly for student (not saved as Model)
@override final  String? editingPlanId;
// Periodization fields
@override final  String? basePlanId;
// Source plan for periodization
@override final  PeriodizationPhase? phaseType;
// Type of periodization phase
// Diet fields
@override@JsonKey() final  bool includeDiet;
@override final  DietType? dietType;
@override final  int? dailyCalories;
@override final  int? proteinGrams;
@override final  int? carbsGrams;
@override final  int? fatGrams;
@override final  int? mealsPerDay;
@override final  String? dietNotes;
// UI state for collapse/expand (survives reordering)
 final  Set<String> _collapsedExerciseIds;
// UI state for collapse/expand (survives reordering)
@override@JsonKey() Set<String> get collapsedExerciseIds {
  if (_collapsedExerciseIds is EqualUnmodifiableSetView) return _collapsedExerciseIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_collapsedExerciseIds);
}

 final  Set<String> _collapsedGroupIds;
@override@JsonKey() Set<String> get collapsedGroupIds {
  if (_collapsedGroupIds is EqualUnmodifiableSetView) return _collapsedGroupIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_collapsedGroupIds);
}


/// Create a copy of PlanWizardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanWizardStateCopyWith<_PlanWizardState> get copyWith => __$PlanWizardStateCopyWithImpl<_PlanWizardState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanWizardState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.method, method) || other.method == method)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.splitType, splitType) || other.splitType == splitType)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.targetWorkoutMinutes, targetWorkoutMinutes) || other.targetWorkoutMinutes == targetWorkoutMinutes)&&const DeepCollectionEquality().equals(other._workouts, _workouts)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.isTemplate, isTemplate) || other.isTemplate == isTemplate)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.isDirectPrescription, isDirectPrescription) || other.isDirectPrescription == isDirectPrescription)&&(identical(other.editingPlanId, editingPlanId) || other.editingPlanId == editingPlanId)&&(identical(other.basePlanId, basePlanId) || other.basePlanId == basePlanId)&&(identical(other.phaseType, phaseType) || other.phaseType == phaseType)&&(identical(other.includeDiet, includeDiet) || other.includeDiet == includeDiet)&&(identical(other.dietType, dietType) || other.dietType == dietType)&&(identical(other.dailyCalories, dailyCalories) || other.dailyCalories == dailyCalories)&&(identical(other.proteinGrams, proteinGrams) || other.proteinGrams == proteinGrams)&&(identical(other.carbsGrams, carbsGrams) || other.carbsGrams == carbsGrams)&&(identical(other.fatGrams, fatGrams) || other.fatGrams == fatGrams)&&(identical(other.mealsPerDay, mealsPerDay) || other.mealsPerDay == mealsPerDay)&&(identical(other.dietNotes, dietNotes) || other.dietNotes == dietNotes)&&const DeepCollectionEquality().equals(other._collapsedExerciseIds, _collapsedExerciseIds)&&const DeepCollectionEquality().equals(other._collapsedGroupIds, _collapsedGroupIds));
}


@override
int get hashCode => Object.hashAll([runtimeType,currentStep,method,planName,goal,difficulty,splitType,durationWeeks,targetWorkoutMinutes,const DeepCollectionEquality().hash(_workouts),isLoading,error,isTemplate,templateId,studentId,isDirectPrescription,editingPlanId,basePlanId,phaseType,includeDiet,dietType,dailyCalories,proteinGrams,carbsGrams,fatGrams,mealsPerDay,dietNotes,const DeepCollectionEquality().hash(_collapsedExerciseIds),const DeepCollectionEquality().hash(_collapsedGroupIds)]);

@override
String toString() {
  return 'PlanWizardState(currentStep: $currentStep, method: $method, planName: $planName, goal: $goal, difficulty: $difficulty, splitType: $splitType, durationWeeks: $durationWeeks, targetWorkoutMinutes: $targetWorkoutMinutes, workouts: $workouts, isLoading: $isLoading, error: $error, isTemplate: $isTemplate, templateId: $templateId, studentId: $studentId, isDirectPrescription: $isDirectPrescription, editingPlanId: $editingPlanId, basePlanId: $basePlanId, phaseType: $phaseType, includeDiet: $includeDiet, dietType: $dietType, dailyCalories: $dailyCalories, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, mealsPerDay: $mealsPerDay, dietNotes: $dietNotes, collapsedExerciseIds: $collapsedExerciseIds, collapsedGroupIds: $collapsedGroupIds)';
}


}

/// @nodoc
abstract mixin class _$PlanWizardStateCopyWith<$Res> implements $PlanWizardStateCopyWith<$Res> {
  factory _$PlanWizardStateCopyWith(_PlanWizardState value, $Res Function(_PlanWizardState) _then) = __$PlanWizardStateCopyWithImpl;
@override @useResult
$Res call({
 int currentStep, CreationMethod? method, String planName, WorkoutGoal goal, PlanDifficulty difficulty, SplitType splitType, int? durationWeeks, int? targetWorkoutMinutes, List<WizardWorkout> workouts, bool isLoading, String? error, bool isTemplate, String? templateId, String? studentId, bool isDirectPrescription, String? editingPlanId, String? basePlanId, PeriodizationPhase? phaseType, bool includeDiet, DietType? dietType, int? dailyCalories, int? proteinGrams, int? carbsGrams, int? fatGrams, int? mealsPerDay, String? dietNotes, Set<String> collapsedExerciseIds, Set<String> collapsedGroupIds
});




}
/// @nodoc
class __$PlanWizardStateCopyWithImpl<$Res>
    implements _$PlanWizardStateCopyWith<$Res> {
  __$PlanWizardStateCopyWithImpl(this._self, this._then);

  final _PlanWizardState _self;
  final $Res Function(_PlanWizardState) _then;

/// Create a copy of PlanWizardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStep = null,Object? method = freezed,Object? planName = null,Object? goal = null,Object? difficulty = null,Object? splitType = null,Object? durationWeeks = freezed,Object? targetWorkoutMinutes = freezed,Object? workouts = null,Object? isLoading = null,Object? error = freezed,Object? isTemplate = null,Object? templateId = freezed,Object? studentId = freezed,Object? isDirectPrescription = null,Object? editingPlanId = freezed,Object? basePlanId = freezed,Object? phaseType = freezed,Object? includeDiet = null,Object? dietType = freezed,Object? dailyCalories = freezed,Object? proteinGrams = freezed,Object? carbsGrams = freezed,Object? fatGrams = freezed,Object? mealsPerDay = freezed,Object? dietNotes = freezed,Object? collapsedExerciseIds = null,Object? collapsedGroupIds = null,}) {
  return _then(_PlanWizardState(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,method: freezed == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as CreationMethod?,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as WorkoutGoal,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as PlanDifficulty,splitType: null == splitType ? _self.splitType : splitType // ignore: cast_nullable_to_non_nullable
as SplitType,durationWeeks: freezed == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int?,targetWorkoutMinutes: freezed == targetWorkoutMinutes ? _self.targetWorkoutMinutes : targetWorkoutMinutes // ignore: cast_nullable_to_non_nullable
as int?,workouts: null == workouts ? _self._workouts : workouts // ignore: cast_nullable_to_non_nullable
as List<WizardWorkout>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,isTemplate: null == isTemplate ? _self.isTemplate : isTemplate // ignore: cast_nullable_to_non_nullable
as bool,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,isDirectPrescription: null == isDirectPrescription ? _self.isDirectPrescription : isDirectPrescription // ignore: cast_nullable_to_non_nullable
as bool,editingPlanId: freezed == editingPlanId ? _self.editingPlanId : editingPlanId // ignore: cast_nullable_to_non_nullable
as String?,basePlanId: freezed == basePlanId ? _self.basePlanId : basePlanId // ignore: cast_nullable_to_non_nullable
as String?,phaseType: freezed == phaseType ? _self.phaseType : phaseType // ignore: cast_nullable_to_non_nullable
as PeriodizationPhase?,includeDiet: null == includeDiet ? _self.includeDiet : includeDiet // ignore: cast_nullable_to_non_nullable
as bool,dietType: freezed == dietType ? _self.dietType : dietType // ignore: cast_nullable_to_non_nullable
as DietType?,dailyCalories: freezed == dailyCalories ? _self.dailyCalories : dailyCalories // ignore: cast_nullable_to_non_nullable
as int?,proteinGrams: freezed == proteinGrams ? _self.proteinGrams : proteinGrams // ignore: cast_nullable_to_non_nullable
as int?,carbsGrams: freezed == carbsGrams ? _self.carbsGrams : carbsGrams // ignore: cast_nullable_to_non_nullable
as int?,fatGrams: freezed == fatGrams ? _self.fatGrams : fatGrams // ignore: cast_nullable_to_non_nullable
as int?,mealsPerDay: freezed == mealsPerDay ? _self.mealsPerDay : mealsPerDay // ignore: cast_nullable_to_non_nullable
as int?,dietNotes: freezed == dietNotes ? _self.dietNotes : dietNotes // ignore: cast_nullable_to_non_nullable
as String?,collapsedExerciseIds: null == collapsedExerciseIds ? _self._collapsedExerciseIds : collapsedExerciseIds // ignore: cast_nullable_to_non_nullable
as Set<String>,collapsedGroupIds: null == collapsedGroupIds ? _self._collapsedGroupIds : collapsedGroupIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
