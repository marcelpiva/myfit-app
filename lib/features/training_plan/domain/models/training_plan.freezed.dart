// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainingPlan {

 String get id; String get name; WorkoutGoal get goal; PlanDifficulty get difficulty; SplitType get splitType; String? get description; int? get durationWeeks; bool get isTemplate; bool get isPublic; String get createdById; String? get organizationId; DateTime? get createdAt; List<PlanWorkout> get planWorkouts;
/// Create a copy of TrainingPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainingPlanCopyWith<TrainingPlan> get copyWith => _$TrainingPlanCopyWithImpl<TrainingPlan>(this as TrainingPlan, _$identity);

  /// Serializes this TrainingPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainingPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.splitType, splitType) || other.splitType == splitType)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.isTemplate, isTemplate) || other.isTemplate == isTemplate)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.planWorkouts, planWorkouts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,goal,difficulty,splitType,description,durationWeeks,isTemplate,isPublic,createdById,organizationId,createdAt,const DeepCollectionEquality().hash(planWorkouts));

@override
String toString() {
  return 'TrainingPlan(id: $id, name: $name, goal: $goal, difficulty: $difficulty, splitType: $splitType, description: $description, durationWeeks: $durationWeeks, isTemplate: $isTemplate, isPublic: $isPublic, createdById: $createdById, organizationId: $organizationId, createdAt: $createdAt, planWorkouts: $planWorkouts)';
}


}

/// @nodoc
abstract mixin class $TrainingPlanCopyWith<$Res>  {
  factory $TrainingPlanCopyWith(TrainingPlan value, $Res Function(TrainingPlan) _then) = _$TrainingPlanCopyWithImpl;
@useResult
$Res call({
 String id, String name, WorkoutGoal goal, PlanDifficulty difficulty, SplitType splitType, String? description, int? durationWeeks, bool isTemplate, bool isPublic, String createdById, String? organizationId, DateTime? createdAt, List<PlanWorkout> planWorkouts
});




}
/// @nodoc
class _$TrainingPlanCopyWithImpl<$Res>
    implements $TrainingPlanCopyWith<$Res> {
  _$TrainingPlanCopyWithImpl(this._self, this._then);

  final TrainingPlan _self;
  final $Res Function(TrainingPlan) _then;

/// Create a copy of TrainingPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? goal = null,Object? difficulty = null,Object? splitType = null,Object? description = freezed,Object? durationWeeks = freezed,Object? isTemplate = null,Object? isPublic = null,Object? createdById = null,Object? organizationId = freezed,Object? createdAt = freezed,Object? planWorkouts = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as WorkoutGoal,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as PlanDifficulty,splitType: null == splitType ? _self.splitType : splitType // ignore: cast_nullable_to_non_nullable
as SplitType,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationWeeks: freezed == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int?,isTemplate: null == isTemplate ? _self.isTemplate : isTemplate // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,createdById: null == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,planWorkouts: null == planWorkouts ? _self.planWorkouts : planWorkouts // ignore: cast_nullable_to_non_nullable
as List<PlanWorkout>,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainingPlan].
extension TrainingPlanPatterns on TrainingPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainingPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainingPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainingPlan value)  $default,){
final _that = this;
switch (_that) {
case _TrainingPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainingPlan value)?  $default,){
final _that = this;
switch (_that) {
case _TrainingPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  WorkoutGoal goal,  PlanDifficulty difficulty,  SplitType splitType,  String? description,  int? durationWeeks,  bool isTemplate,  bool isPublic,  String createdById,  String? organizationId,  DateTime? createdAt,  List<PlanWorkout> planWorkouts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainingPlan() when $default != null:
return $default(_that.id,_that.name,_that.goal,_that.difficulty,_that.splitType,_that.description,_that.durationWeeks,_that.isTemplate,_that.isPublic,_that.createdById,_that.organizationId,_that.createdAt,_that.planWorkouts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  WorkoutGoal goal,  PlanDifficulty difficulty,  SplitType splitType,  String? description,  int? durationWeeks,  bool isTemplate,  bool isPublic,  String createdById,  String? organizationId,  DateTime? createdAt,  List<PlanWorkout> planWorkouts)  $default,) {final _that = this;
switch (_that) {
case _TrainingPlan():
return $default(_that.id,_that.name,_that.goal,_that.difficulty,_that.splitType,_that.description,_that.durationWeeks,_that.isTemplate,_that.isPublic,_that.createdById,_that.organizationId,_that.createdAt,_that.planWorkouts);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  WorkoutGoal goal,  PlanDifficulty difficulty,  SplitType splitType,  String? description,  int? durationWeeks,  bool isTemplate,  bool isPublic,  String createdById,  String? organizationId,  DateTime? createdAt,  List<PlanWorkout> planWorkouts)?  $default,) {final _that = this;
switch (_that) {
case _TrainingPlan() when $default != null:
return $default(_that.id,_that.name,_that.goal,_that.difficulty,_that.splitType,_that.description,_that.durationWeeks,_that.isTemplate,_that.isPublic,_that.createdById,_that.organizationId,_that.createdAt,_that.planWorkouts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainingPlan extends TrainingPlan {
  const _TrainingPlan({required this.id, required this.name, required this.goal, required this.difficulty, required this.splitType, this.description, this.durationWeeks, this.isTemplate = false, this.isPublic = false, required this.createdById, this.organizationId, this.createdAt, final  List<PlanWorkout> planWorkouts = const []}): _planWorkouts = planWorkouts,super._();
  factory _TrainingPlan.fromJson(Map<String, dynamic> json) => _$TrainingPlanFromJson(json);

@override final  String id;
@override final  String name;
@override final  WorkoutGoal goal;
@override final  PlanDifficulty difficulty;
@override final  SplitType splitType;
@override final  String? description;
@override final  int? durationWeeks;
@override@JsonKey() final  bool isTemplate;
@override@JsonKey() final  bool isPublic;
@override final  String createdById;
@override final  String? organizationId;
@override final  DateTime? createdAt;
 final  List<PlanWorkout> _planWorkouts;
@override@JsonKey() List<PlanWorkout> get planWorkouts {
  if (_planWorkouts is EqualUnmodifiableListView) return _planWorkouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_planWorkouts);
}


/// Create a copy of TrainingPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainingPlanCopyWith<_TrainingPlan> get copyWith => __$TrainingPlanCopyWithImpl<_TrainingPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainingPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainingPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.splitType, splitType) || other.splitType == splitType)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.isTemplate, isTemplate) || other.isTemplate == isTemplate)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._planWorkouts, _planWorkouts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,goal,difficulty,splitType,description,durationWeeks,isTemplate,isPublic,createdById,organizationId,createdAt,const DeepCollectionEquality().hash(_planWorkouts));

@override
String toString() {
  return 'TrainingPlan(id: $id, name: $name, goal: $goal, difficulty: $difficulty, splitType: $splitType, description: $description, durationWeeks: $durationWeeks, isTemplate: $isTemplate, isPublic: $isPublic, createdById: $createdById, organizationId: $organizationId, createdAt: $createdAt, planWorkouts: $planWorkouts)';
}


}

/// @nodoc
abstract mixin class _$TrainingPlanCopyWith<$Res> implements $TrainingPlanCopyWith<$Res> {
  factory _$TrainingPlanCopyWith(_TrainingPlan value, $Res Function(_TrainingPlan) _then) = __$TrainingPlanCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, WorkoutGoal goal, PlanDifficulty difficulty, SplitType splitType, String? description, int? durationWeeks, bool isTemplate, bool isPublic, String createdById, String? organizationId, DateTime? createdAt, List<PlanWorkout> planWorkouts
});




}
/// @nodoc
class __$TrainingPlanCopyWithImpl<$Res>
    implements _$TrainingPlanCopyWith<$Res> {
  __$TrainingPlanCopyWithImpl(this._self, this._then);

  final _TrainingPlan _self;
  final $Res Function(_TrainingPlan) _then;

/// Create a copy of TrainingPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? goal = null,Object? difficulty = null,Object? splitType = null,Object? description = freezed,Object? durationWeeks = freezed,Object? isTemplate = null,Object? isPublic = null,Object? createdById = null,Object? organizationId = freezed,Object? createdAt = freezed,Object? planWorkouts = null,}) {
  return _then(_TrainingPlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as WorkoutGoal,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as PlanDifficulty,splitType: null == splitType ? _self.splitType : splitType // ignore: cast_nullable_to_non_nullable
as SplitType,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationWeeks: freezed == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int?,isTemplate: null == isTemplate ? _self.isTemplate : isTemplate // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,createdById: null == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,planWorkouts: null == planWorkouts ? _self._planWorkouts : planWorkouts // ignore: cast_nullable_to_non_nullable
as List<PlanWorkout>,
  ));
}


}


/// @nodoc
mixin _$PlanWorkout {

 String get id; String get workoutId; int get order; String get label; int? get dayOfWeek; PlanWorkoutDetail? get workout;
/// Create a copy of PlanWorkout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanWorkoutCopyWith<PlanWorkout> get copyWith => _$PlanWorkoutCopyWithImpl<PlanWorkout>(this as PlanWorkout, _$identity);

  /// Serializes this PlanWorkout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.order, order) || other.order == order)&&(identical(other.label, label) || other.label == label)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.workout, workout) || other.workout == workout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workoutId,order,label,dayOfWeek,workout);

@override
String toString() {
  return 'PlanWorkout(id: $id, workoutId: $workoutId, order: $order, label: $label, dayOfWeek: $dayOfWeek, workout: $workout)';
}


}

/// @nodoc
abstract mixin class $PlanWorkoutCopyWith<$Res>  {
  factory $PlanWorkoutCopyWith(PlanWorkout value, $Res Function(PlanWorkout) _then) = _$PlanWorkoutCopyWithImpl;
@useResult
$Res call({
 String id, String workoutId, int order, String label, int? dayOfWeek, PlanWorkoutDetail? workout
});


$PlanWorkoutDetailCopyWith<$Res>? get workout;

}
/// @nodoc
class _$PlanWorkoutCopyWithImpl<$Res>
    implements $PlanWorkoutCopyWith<$Res> {
  _$PlanWorkoutCopyWithImpl(this._self, this._then);

  final PlanWorkout _self;
  final $Res Function(PlanWorkout) _then;

/// Create a copy of PlanWorkout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workoutId = null,Object? order = null,Object? label = null,Object? dayOfWeek = freezed,Object? workout = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: freezed == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int?,workout: freezed == workout ? _self.workout : workout // ignore: cast_nullable_to_non_nullable
as PlanWorkoutDetail?,
  ));
}
/// Create a copy of PlanWorkout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanWorkoutDetailCopyWith<$Res>? get workout {
    if (_self.workout == null) {
    return null;
  }

  return $PlanWorkoutDetailCopyWith<$Res>(_self.workout!, (value) {
    return _then(_self.copyWith(workout: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlanWorkout].
extension PlanWorkoutPatterns on PlanWorkout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanWorkout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanWorkout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanWorkout value)  $default,){
final _that = this;
switch (_that) {
case _PlanWorkout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanWorkout value)?  $default,){
final _that = this;
switch (_that) {
case _PlanWorkout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workoutId,  int order,  String label,  int? dayOfWeek,  PlanWorkoutDetail? workout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanWorkout() when $default != null:
return $default(_that.id,_that.workoutId,_that.order,_that.label,_that.dayOfWeek,_that.workout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workoutId,  int order,  String label,  int? dayOfWeek,  PlanWorkoutDetail? workout)  $default,) {final _that = this;
switch (_that) {
case _PlanWorkout():
return $default(_that.id,_that.workoutId,_that.order,_that.label,_that.dayOfWeek,_that.workout);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workoutId,  int order,  String label,  int? dayOfWeek,  PlanWorkoutDetail? workout)?  $default,) {final _that = this;
switch (_that) {
case _PlanWorkout() when $default != null:
return $default(_that.id,_that.workoutId,_that.order,_that.label,_that.dayOfWeek,_that.workout);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanWorkout extends PlanWorkout {
  const _PlanWorkout({required this.id, required this.workoutId, required this.order, required this.label, this.dayOfWeek, this.workout}): super._();
  factory _PlanWorkout.fromJson(Map<String, dynamic> json) => _$PlanWorkoutFromJson(json);

@override final  String id;
@override final  String workoutId;
@override final  int order;
@override final  String label;
@override final  int? dayOfWeek;
@override final  PlanWorkoutDetail? workout;

/// Create a copy of PlanWorkout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanWorkoutCopyWith<_PlanWorkout> get copyWith => __$PlanWorkoutCopyWithImpl<_PlanWorkout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanWorkoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.order, order) || other.order == order)&&(identical(other.label, label) || other.label == label)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.workout, workout) || other.workout == workout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workoutId,order,label,dayOfWeek,workout);

@override
String toString() {
  return 'PlanWorkout(id: $id, workoutId: $workoutId, order: $order, label: $label, dayOfWeek: $dayOfWeek, workout: $workout)';
}


}

/// @nodoc
abstract mixin class _$PlanWorkoutCopyWith<$Res> implements $PlanWorkoutCopyWith<$Res> {
  factory _$PlanWorkoutCopyWith(_PlanWorkout value, $Res Function(_PlanWorkout) _then) = __$PlanWorkoutCopyWithImpl;
@override @useResult
$Res call({
 String id, String workoutId, int order, String label, int? dayOfWeek, PlanWorkoutDetail? workout
});


@override $PlanWorkoutDetailCopyWith<$Res>? get workout;

}
/// @nodoc
class __$PlanWorkoutCopyWithImpl<$Res>
    implements _$PlanWorkoutCopyWith<$Res> {
  __$PlanWorkoutCopyWithImpl(this._self, this._then);

  final _PlanWorkout _self;
  final $Res Function(_PlanWorkout) _then;

/// Create a copy of PlanWorkout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workoutId = null,Object? order = null,Object? label = null,Object? dayOfWeek = freezed,Object? workout = freezed,}) {
  return _then(_PlanWorkout(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: freezed == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int?,workout: freezed == workout ? _self.workout : workout // ignore: cast_nullable_to_non_nullable
as PlanWorkoutDetail?,
  ));
}

/// Create a copy of PlanWorkout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanWorkoutDetailCopyWith<$Res>? get workout {
    if (_self.workout == null) {
    return null;
  }

  return $PlanWorkoutDetailCopyWith<$Res>(_self.workout!, (value) {
    return _then(_self.copyWith(workout: value));
  });
}
}


/// @nodoc
mixin _$PlanWorkoutDetail {

 String get id; String get name; String? get description; String get difficulty; int get estimatedDurationMin; List<String>? get targetMuscles; List<PlanExercise> get exercises;
/// Create a copy of PlanWorkoutDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanWorkoutDetailCopyWith<PlanWorkoutDetail> get copyWith => _$PlanWorkoutDetailCopyWithImpl<PlanWorkoutDetail>(this as PlanWorkoutDetail, _$identity);

  /// Serializes this PlanWorkoutDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanWorkoutDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedDurationMin, estimatedDurationMin) || other.estimatedDurationMin == estimatedDurationMin)&&const DeepCollectionEquality().equals(other.targetMuscles, targetMuscles)&&const DeepCollectionEquality().equals(other.exercises, exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,difficulty,estimatedDurationMin,const DeepCollectionEquality().hash(targetMuscles),const DeepCollectionEquality().hash(exercises));

@override
String toString() {
  return 'PlanWorkoutDetail(id: $id, name: $name, description: $description, difficulty: $difficulty, estimatedDurationMin: $estimatedDurationMin, targetMuscles: $targetMuscles, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class $PlanWorkoutDetailCopyWith<$Res>  {
  factory $PlanWorkoutDetailCopyWith(PlanWorkoutDetail value, $Res Function(PlanWorkoutDetail) _then) = _$PlanWorkoutDetailCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String difficulty, int estimatedDurationMin, List<String>? targetMuscles, List<PlanExercise> exercises
});




}
/// @nodoc
class _$PlanWorkoutDetailCopyWithImpl<$Res>
    implements $PlanWorkoutDetailCopyWith<$Res> {
  _$PlanWorkoutDetailCopyWithImpl(this._self, this._then);

  final PlanWorkoutDetail _self;
  final $Res Function(PlanWorkoutDetail) _then;

/// Create a copy of PlanWorkoutDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? difficulty = null,Object? estimatedDurationMin = null,Object? targetMuscles = freezed,Object? exercises = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,estimatedDurationMin: null == estimatedDurationMin ? _self.estimatedDurationMin : estimatedDurationMin // ignore: cast_nullable_to_non_nullable
as int,targetMuscles: freezed == targetMuscles ? _self.targetMuscles : targetMuscles // ignore: cast_nullable_to_non_nullable
as List<String>?,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<PlanExercise>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanWorkoutDetail].
extension PlanWorkoutDetailPatterns on PlanWorkoutDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanWorkoutDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanWorkoutDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanWorkoutDetail value)  $default,){
final _that = this;
switch (_that) {
case _PlanWorkoutDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanWorkoutDetail value)?  $default,){
final _that = this;
switch (_that) {
case _PlanWorkoutDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String difficulty,  int estimatedDurationMin,  List<String>? targetMuscles,  List<PlanExercise> exercises)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanWorkoutDetail() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.difficulty,_that.estimatedDurationMin,_that.targetMuscles,_that.exercises);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String difficulty,  int estimatedDurationMin,  List<String>? targetMuscles,  List<PlanExercise> exercises)  $default,) {final _that = this;
switch (_that) {
case _PlanWorkoutDetail():
return $default(_that.id,_that.name,_that.description,_that.difficulty,_that.estimatedDurationMin,_that.targetMuscles,_that.exercises);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String difficulty,  int estimatedDurationMin,  List<String>? targetMuscles,  List<PlanExercise> exercises)?  $default,) {final _that = this;
switch (_that) {
case _PlanWorkoutDetail() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.difficulty,_that.estimatedDurationMin,_that.targetMuscles,_that.exercises);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanWorkoutDetail extends PlanWorkoutDetail {
  const _PlanWorkoutDetail({required this.id, required this.name, this.description, required this.difficulty, required this.estimatedDurationMin, final  List<String>? targetMuscles, final  List<PlanExercise> exercises = const []}): _targetMuscles = targetMuscles,_exercises = exercises,super._();
  factory _PlanWorkoutDetail.fromJson(Map<String, dynamic> json) => _$PlanWorkoutDetailFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String difficulty;
@override final  int estimatedDurationMin;
 final  List<String>? _targetMuscles;
@override List<String>? get targetMuscles {
  final value = _targetMuscles;
  if (value == null) return null;
  if (_targetMuscles is EqualUnmodifiableListView) return _targetMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<PlanExercise> _exercises;
@override@JsonKey() List<PlanExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}


/// Create a copy of PlanWorkoutDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanWorkoutDetailCopyWith<_PlanWorkoutDetail> get copyWith => __$PlanWorkoutDetailCopyWithImpl<_PlanWorkoutDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanWorkoutDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanWorkoutDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedDurationMin, estimatedDurationMin) || other.estimatedDurationMin == estimatedDurationMin)&&const DeepCollectionEquality().equals(other._targetMuscles, _targetMuscles)&&const DeepCollectionEquality().equals(other._exercises, _exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,difficulty,estimatedDurationMin,const DeepCollectionEquality().hash(_targetMuscles),const DeepCollectionEquality().hash(_exercises));

@override
String toString() {
  return 'PlanWorkoutDetail(id: $id, name: $name, description: $description, difficulty: $difficulty, estimatedDurationMin: $estimatedDurationMin, targetMuscles: $targetMuscles, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class _$PlanWorkoutDetailCopyWith<$Res> implements $PlanWorkoutDetailCopyWith<$Res> {
  factory _$PlanWorkoutDetailCopyWith(_PlanWorkoutDetail value, $Res Function(_PlanWorkoutDetail) _then) = __$PlanWorkoutDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String difficulty, int estimatedDurationMin, List<String>? targetMuscles, List<PlanExercise> exercises
});




}
/// @nodoc
class __$PlanWorkoutDetailCopyWithImpl<$Res>
    implements _$PlanWorkoutDetailCopyWith<$Res> {
  __$PlanWorkoutDetailCopyWithImpl(this._self, this._then);

  final _PlanWorkoutDetail _self;
  final $Res Function(_PlanWorkoutDetail) _then;

/// Create a copy of PlanWorkoutDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? difficulty = null,Object? estimatedDurationMin = null,Object? targetMuscles = freezed,Object? exercises = null,}) {
  return _then(_PlanWorkoutDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,estimatedDurationMin: null == estimatedDurationMin ? _self.estimatedDurationMin : estimatedDurationMin // ignore: cast_nullable_to_non_nullable
as int,targetMuscles: freezed == targetMuscles ? _self._targetMuscles : targetMuscles // ignore: cast_nullable_to_non_nullable
as List<String>?,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<PlanExercise>,
  ));
}


}


/// @nodoc
mixin _$PlanExercise {

 String get id; String get exerciseId; int get order; int get sets; String get reps; int get restSeconds; String? get notes; String? get supersetWith;// Advanced technique fields
 String? get executionInstructions; int? get isometricSeconds; TechniqueType get techniqueType; String? get exerciseGroupId; int get exerciseGroupOrder; int get estimatedSeconds; PlanExerciseDetail? get exercise;
/// Create a copy of PlanExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanExerciseCopyWith<PlanExercise> get copyWith => _$PlanExerciseCopyWithImpl<PlanExercise>(this as PlanExercise, _$identity);

  /// Serializes this PlanExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.order, order) || other.order == order)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.supersetWith, supersetWith) || other.supersetWith == supersetWith)&&(identical(other.executionInstructions, executionInstructions) || other.executionInstructions == executionInstructions)&&(identical(other.isometricSeconds, isometricSeconds) || other.isometricSeconds == isometricSeconds)&&(identical(other.techniqueType, techniqueType) || other.techniqueType == techniqueType)&&(identical(other.exerciseGroupId, exerciseGroupId) || other.exerciseGroupId == exerciseGroupId)&&(identical(other.exerciseGroupOrder, exerciseGroupOrder) || other.exerciseGroupOrder == exerciseGroupOrder)&&(identical(other.estimatedSeconds, estimatedSeconds) || other.estimatedSeconds == estimatedSeconds)&&(identical(other.exercise, exercise) || other.exercise == exercise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,order,sets,reps,restSeconds,notes,supersetWith,executionInstructions,isometricSeconds,techniqueType,exerciseGroupId,exerciseGroupOrder,estimatedSeconds,exercise);

@override
String toString() {
  return 'PlanExercise(id: $id, exerciseId: $exerciseId, order: $order, sets: $sets, reps: $reps, restSeconds: $restSeconds, notes: $notes, supersetWith: $supersetWith, executionInstructions: $executionInstructions, isometricSeconds: $isometricSeconds, techniqueType: $techniqueType, exerciseGroupId: $exerciseGroupId, exerciseGroupOrder: $exerciseGroupOrder, estimatedSeconds: $estimatedSeconds, exercise: $exercise)';
}


}

/// @nodoc
abstract mixin class $PlanExerciseCopyWith<$Res>  {
  factory $PlanExerciseCopyWith(PlanExercise value, $Res Function(PlanExercise) _then) = _$PlanExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, int order, int sets, String reps, int restSeconds, String? notes, String? supersetWith, String? executionInstructions, int? isometricSeconds, TechniqueType techniqueType, String? exerciseGroupId, int exerciseGroupOrder, int estimatedSeconds, PlanExerciseDetail? exercise
});


$PlanExerciseDetailCopyWith<$Res>? get exercise;

}
/// @nodoc
class _$PlanExerciseCopyWithImpl<$Res>
    implements $PlanExerciseCopyWith<$Res> {
  _$PlanExerciseCopyWithImpl(this._self, this._then);

  final PlanExercise _self;
  final $Res Function(PlanExercise) _then;

/// Create a copy of PlanExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? order = null,Object? sets = null,Object? reps = null,Object? restSeconds = null,Object? notes = freezed,Object? supersetWith = freezed,Object? executionInstructions = freezed,Object? isometricSeconds = freezed,Object? techniqueType = null,Object? exerciseGroupId = freezed,Object? exerciseGroupOrder = null,Object? estimatedSeconds = null,Object? exercise = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as String,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,supersetWith: freezed == supersetWith ? _self.supersetWith : supersetWith // ignore: cast_nullable_to_non_nullable
as String?,executionInstructions: freezed == executionInstructions ? _self.executionInstructions : executionInstructions // ignore: cast_nullable_to_non_nullable
as String?,isometricSeconds: freezed == isometricSeconds ? _self.isometricSeconds : isometricSeconds // ignore: cast_nullable_to_non_nullable
as int?,techniqueType: null == techniqueType ? _self.techniqueType : techniqueType // ignore: cast_nullable_to_non_nullable
as TechniqueType,exerciseGroupId: freezed == exerciseGroupId ? _self.exerciseGroupId : exerciseGroupId // ignore: cast_nullable_to_non_nullable
as String?,exerciseGroupOrder: null == exerciseGroupOrder ? _self.exerciseGroupOrder : exerciseGroupOrder // ignore: cast_nullable_to_non_nullable
as int,estimatedSeconds: null == estimatedSeconds ? _self.estimatedSeconds : estimatedSeconds // ignore: cast_nullable_to_non_nullable
as int,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as PlanExerciseDetail?,
  ));
}
/// Create a copy of PlanExercise
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanExerciseDetailCopyWith<$Res>? get exercise {
    if (_self.exercise == null) {
    return null;
  }

  return $PlanExerciseDetailCopyWith<$Res>(_self.exercise!, (value) {
    return _then(_self.copyWith(exercise: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlanExercise].
extension PlanExercisePatterns on PlanExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanExercise value)  $default,){
final _that = this;
switch (_that) {
case _PlanExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanExercise value)?  $default,){
final _that = this;
switch (_that) {
case _PlanExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  int order,  int sets,  String reps,  int restSeconds,  String? notes,  String? supersetWith,  String? executionInstructions,  int? isometricSeconds,  TechniqueType techniqueType,  String? exerciseGroupId,  int exerciseGroupOrder,  int estimatedSeconds,  PlanExerciseDetail? exercise)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.order,_that.sets,_that.reps,_that.restSeconds,_that.notes,_that.supersetWith,_that.executionInstructions,_that.isometricSeconds,_that.techniqueType,_that.exerciseGroupId,_that.exerciseGroupOrder,_that.estimatedSeconds,_that.exercise);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  int order,  int sets,  String reps,  int restSeconds,  String? notes,  String? supersetWith,  String? executionInstructions,  int? isometricSeconds,  TechniqueType techniqueType,  String? exerciseGroupId,  int exerciseGroupOrder,  int estimatedSeconds,  PlanExerciseDetail? exercise)  $default,) {final _that = this;
switch (_that) {
case _PlanExercise():
return $default(_that.id,_that.exerciseId,_that.order,_that.sets,_that.reps,_that.restSeconds,_that.notes,_that.supersetWith,_that.executionInstructions,_that.isometricSeconds,_that.techniqueType,_that.exerciseGroupId,_that.exerciseGroupOrder,_that.estimatedSeconds,_that.exercise);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  int order,  int sets,  String reps,  int restSeconds,  String? notes,  String? supersetWith,  String? executionInstructions,  int? isometricSeconds,  TechniqueType techniqueType,  String? exerciseGroupId,  int exerciseGroupOrder,  int estimatedSeconds,  PlanExerciseDetail? exercise)?  $default,) {final _that = this;
switch (_that) {
case _PlanExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.order,_that.sets,_that.reps,_that.restSeconds,_that.notes,_that.supersetWith,_that.executionInstructions,_that.isometricSeconds,_that.techniqueType,_that.exerciseGroupId,_that.exerciseGroupOrder,_that.estimatedSeconds,_that.exercise);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanExercise extends PlanExercise {
  const _PlanExercise({required this.id, required this.exerciseId, required this.order, required this.sets, required this.reps, required this.restSeconds, this.notes, this.supersetWith, this.executionInstructions, this.isometricSeconds, this.techniqueType = TechniqueType.normal, this.exerciseGroupId, this.exerciseGroupOrder = 0, this.estimatedSeconds = 0, this.exercise}): super._();
  factory _PlanExercise.fromJson(Map<String, dynamic> json) => _$PlanExerciseFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  int order;
@override final  int sets;
@override final  String reps;
@override final  int restSeconds;
@override final  String? notes;
@override final  String? supersetWith;
// Advanced technique fields
@override final  String? executionInstructions;
@override final  int? isometricSeconds;
@override@JsonKey() final  TechniqueType techniqueType;
@override final  String? exerciseGroupId;
@override@JsonKey() final  int exerciseGroupOrder;
@override@JsonKey() final  int estimatedSeconds;
@override final  PlanExerciseDetail? exercise;

/// Create a copy of PlanExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanExerciseCopyWith<_PlanExercise> get copyWith => __$PlanExerciseCopyWithImpl<_PlanExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.order, order) || other.order == order)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.supersetWith, supersetWith) || other.supersetWith == supersetWith)&&(identical(other.executionInstructions, executionInstructions) || other.executionInstructions == executionInstructions)&&(identical(other.isometricSeconds, isometricSeconds) || other.isometricSeconds == isometricSeconds)&&(identical(other.techniqueType, techniqueType) || other.techniqueType == techniqueType)&&(identical(other.exerciseGroupId, exerciseGroupId) || other.exerciseGroupId == exerciseGroupId)&&(identical(other.exerciseGroupOrder, exerciseGroupOrder) || other.exerciseGroupOrder == exerciseGroupOrder)&&(identical(other.estimatedSeconds, estimatedSeconds) || other.estimatedSeconds == estimatedSeconds)&&(identical(other.exercise, exercise) || other.exercise == exercise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,order,sets,reps,restSeconds,notes,supersetWith,executionInstructions,isometricSeconds,techniqueType,exerciseGroupId,exerciseGroupOrder,estimatedSeconds,exercise);

@override
String toString() {
  return 'PlanExercise(id: $id, exerciseId: $exerciseId, order: $order, sets: $sets, reps: $reps, restSeconds: $restSeconds, notes: $notes, supersetWith: $supersetWith, executionInstructions: $executionInstructions, isometricSeconds: $isometricSeconds, techniqueType: $techniqueType, exerciseGroupId: $exerciseGroupId, exerciseGroupOrder: $exerciseGroupOrder, estimatedSeconds: $estimatedSeconds, exercise: $exercise)';
}


}

/// @nodoc
abstract mixin class _$PlanExerciseCopyWith<$Res> implements $PlanExerciseCopyWith<$Res> {
  factory _$PlanExerciseCopyWith(_PlanExercise value, $Res Function(_PlanExercise) _then) = __$PlanExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, int order, int sets, String reps, int restSeconds, String? notes, String? supersetWith, String? executionInstructions, int? isometricSeconds, TechniqueType techniqueType, String? exerciseGroupId, int exerciseGroupOrder, int estimatedSeconds, PlanExerciseDetail? exercise
});


@override $PlanExerciseDetailCopyWith<$Res>? get exercise;

}
/// @nodoc
class __$PlanExerciseCopyWithImpl<$Res>
    implements _$PlanExerciseCopyWith<$Res> {
  __$PlanExerciseCopyWithImpl(this._self, this._then);

  final _PlanExercise _self;
  final $Res Function(_PlanExercise) _then;

/// Create a copy of PlanExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? order = null,Object? sets = null,Object? reps = null,Object? restSeconds = null,Object? notes = freezed,Object? supersetWith = freezed,Object? executionInstructions = freezed,Object? isometricSeconds = freezed,Object? techniqueType = null,Object? exerciseGroupId = freezed,Object? exerciseGroupOrder = null,Object? estimatedSeconds = null,Object? exercise = freezed,}) {
  return _then(_PlanExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as String,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,supersetWith: freezed == supersetWith ? _self.supersetWith : supersetWith // ignore: cast_nullable_to_non_nullable
as String?,executionInstructions: freezed == executionInstructions ? _self.executionInstructions : executionInstructions // ignore: cast_nullable_to_non_nullable
as String?,isometricSeconds: freezed == isometricSeconds ? _self.isometricSeconds : isometricSeconds // ignore: cast_nullable_to_non_nullable
as int?,techniqueType: null == techniqueType ? _self.techniqueType : techniqueType // ignore: cast_nullable_to_non_nullable
as TechniqueType,exerciseGroupId: freezed == exerciseGroupId ? _self.exerciseGroupId : exerciseGroupId // ignore: cast_nullable_to_non_nullable
as String?,exerciseGroupOrder: null == exerciseGroupOrder ? _self.exerciseGroupOrder : exerciseGroupOrder // ignore: cast_nullable_to_non_nullable
as int,estimatedSeconds: null == estimatedSeconds ? _self.estimatedSeconds : estimatedSeconds // ignore: cast_nullable_to_non_nullable
as int,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as PlanExerciseDetail?,
  ));
}

/// Create a copy of PlanExercise
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanExerciseDetailCopyWith<$Res>? get exercise {
    if (_self.exercise == null) {
    return null;
  }

  return $PlanExerciseDetailCopyWith<$Res>(_self.exercise!, (value) {
    return _then(_self.copyWith(exercise: value));
  });
}
}


/// @nodoc
mixin _$PlanExerciseDetail {

 String get id; String get name; String get muscleGroup; String? get description; String? get instructions; String? get imageUrl; String? get videoUrl;
/// Create a copy of PlanExerciseDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanExerciseDetailCopyWith<PlanExerciseDetail> get copyWith => _$PlanExerciseDetailCopyWithImpl<PlanExerciseDetail>(this as PlanExerciseDetail, _$identity);

  /// Serializes this PlanExerciseDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanExerciseDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&(identical(other.description, description) || other.description == description)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,muscleGroup,description,instructions,imageUrl,videoUrl);

@override
String toString() {
  return 'PlanExerciseDetail(id: $id, name: $name, muscleGroup: $muscleGroup, description: $description, instructions: $instructions, imageUrl: $imageUrl, videoUrl: $videoUrl)';
}


}

/// @nodoc
abstract mixin class $PlanExerciseDetailCopyWith<$Res>  {
  factory $PlanExerciseDetailCopyWith(PlanExerciseDetail value, $Res Function(PlanExerciseDetail) _then) = _$PlanExerciseDetailCopyWithImpl;
@useResult
$Res call({
 String id, String name, String muscleGroup, String? description, String? instructions, String? imageUrl, String? videoUrl
});




}
/// @nodoc
class _$PlanExerciseDetailCopyWithImpl<$Res>
    implements $PlanExerciseDetailCopyWith<$Res> {
  _$PlanExerciseDetailCopyWithImpl(this._self, this._then);

  final PlanExerciseDetail _self;
  final $Res Function(PlanExerciseDetail) _then;

/// Create a copy of PlanExerciseDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? muscleGroup = null,Object? description = freezed,Object? instructions = freezed,Object? imageUrl = freezed,Object? videoUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,muscleGroup: null == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanExerciseDetail].
extension PlanExerciseDetailPatterns on PlanExerciseDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanExerciseDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanExerciseDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanExerciseDetail value)  $default,){
final _that = this;
switch (_that) {
case _PlanExerciseDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanExerciseDetail value)?  $default,){
final _that = this;
switch (_that) {
case _PlanExerciseDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String muscleGroup,  String? description,  String? instructions,  String? imageUrl,  String? videoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanExerciseDetail() when $default != null:
return $default(_that.id,_that.name,_that.muscleGroup,_that.description,_that.instructions,_that.imageUrl,_that.videoUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String muscleGroup,  String? description,  String? instructions,  String? imageUrl,  String? videoUrl)  $default,) {final _that = this;
switch (_that) {
case _PlanExerciseDetail():
return $default(_that.id,_that.name,_that.muscleGroup,_that.description,_that.instructions,_that.imageUrl,_that.videoUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String muscleGroup,  String? description,  String? instructions,  String? imageUrl,  String? videoUrl)?  $default,) {final _that = this;
switch (_that) {
case _PlanExerciseDetail() when $default != null:
return $default(_that.id,_that.name,_that.muscleGroup,_that.description,_that.instructions,_that.imageUrl,_that.videoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanExerciseDetail implements PlanExerciseDetail {
  const _PlanExerciseDetail({required this.id, required this.name, required this.muscleGroup, this.description, this.instructions, this.imageUrl, this.videoUrl});
  factory _PlanExerciseDetail.fromJson(Map<String, dynamic> json) => _$PlanExerciseDetailFromJson(json);

@override final  String id;
@override final  String name;
@override final  String muscleGroup;
@override final  String? description;
@override final  String? instructions;
@override final  String? imageUrl;
@override final  String? videoUrl;

/// Create a copy of PlanExerciseDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanExerciseDetailCopyWith<_PlanExerciseDetail> get copyWith => __$PlanExerciseDetailCopyWithImpl<_PlanExerciseDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanExerciseDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanExerciseDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&(identical(other.description, description) || other.description == description)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,muscleGroup,description,instructions,imageUrl,videoUrl);

@override
String toString() {
  return 'PlanExerciseDetail(id: $id, name: $name, muscleGroup: $muscleGroup, description: $description, instructions: $instructions, imageUrl: $imageUrl, videoUrl: $videoUrl)';
}


}

/// @nodoc
abstract mixin class _$PlanExerciseDetailCopyWith<$Res> implements $PlanExerciseDetailCopyWith<$Res> {
  factory _$PlanExerciseDetailCopyWith(_PlanExerciseDetail value, $Res Function(_PlanExerciseDetail) _then) = __$PlanExerciseDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String muscleGroup, String? description, String? instructions, String? imageUrl, String? videoUrl
});




}
/// @nodoc
class __$PlanExerciseDetailCopyWithImpl<$Res>
    implements _$PlanExerciseDetailCopyWith<$Res> {
  __$PlanExerciseDetailCopyWithImpl(this._self, this._then);

  final _PlanExerciseDetail _self;
  final $Res Function(_PlanExerciseDetail) _then;

/// Create a copy of PlanExerciseDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? muscleGroup = null,Object? description = freezed,Object? instructions = freezed,Object? imageUrl = freezed,Object? videoUrl = freezed,}) {
  return _then(_PlanExerciseDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,muscleGroup: null == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
