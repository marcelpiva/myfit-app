// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_program.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutProgram {

 String get id; String get name; WorkoutGoal get goal; ProgramDifficulty get difficulty; SplitType get splitType; String? get description; int? get durationWeeks; bool get isTemplate; bool get isPublic; String get createdById; String? get organizationId; DateTime? get createdAt; List<ProgramWorkout> get programWorkouts;
/// Create a copy of WorkoutProgram
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutProgramCopyWith<WorkoutProgram> get copyWith => _$WorkoutProgramCopyWithImpl<WorkoutProgram>(this as WorkoutProgram, _$identity);

  /// Serializes this WorkoutProgram to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutProgram&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.splitType, splitType) || other.splitType == splitType)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.isTemplate, isTemplate) || other.isTemplate == isTemplate)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.programWorkouts, programWorkouts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,goal,difficulty,splitType,description,durationWeeks,isTemplate,isPublic,createdById,organizationId,createdAt,const DeepCollectionEquality().hash(programWorkouts));

@override
String toString() {
  return 'WorkoutProgram(id: $id, name: $name, goal: $goal, difficulty: $difficulty, splitType: $splitType, description: $description, durationWeeks: $durationWeeks, isTemplate: $isTemplate, isPublic: $isPublic, createdById: $createdById, organizationId: $organizationId, createdAt: $createdAt, programWorkouts: $programWorkouts)';
}


}

/// @nodoc
abstract mixin class $WorkoutProgramCopyWith<$Res>  {
  factory $WorkoutProgramCopyWith(WorkoutProgram value, $Res Function(WorkoutProgram) _then) = _$WorkoutProgramCopyWithImpl;
@useResult
$Res call({
 String id, String name, WorkoutGoal goal, ProgramDifficulty difficulty, SplitType splitType, String? description, int? durationWeeks, bool isTemplate, bool isPublic, String createdById, String? organizationId, DateTime? createdAt, List<ProgramWorkout> programWorkouts
});




}
/// @nodoc
class _$WorkoutProgramCopyWithImpl<$Res>
    implements $WorkoutProgramCopyWith<$Res> {
  _$WorkoutProgramCopyWithImpl(this._self, this._then);

  final WorkoutProgram _self;
  final $Res Function(WorkoutProgram) _then;

/// Create a copy of WorkoutProgram
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? goal = null,Object? difficulty = null,Object? splitType = null,Object? description = freezed,Object? durationWeeks = freezed,Object? isTemplate = null,Object? isPublic = null,Object? createdById = null,Object? organizationId = freezed,Object? createdAt = freezed,Object? programWorkouts = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as WorkoutGoal,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as ProgramDifficulty,splitType: null == splitType ? _self.splitType : splitType // ignore: cast_nullable_to_non_nullable
as SplitType,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationWeeks: freezed == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int?,isTemplate: null == isTemplate ? _self.isTemplate : isTemplate // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,createdById: null == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,programWorkouts: null == programWorkouts ? _self.programWorkouts : programWorkouts // ignore: cast_nullable_to_non_nullable
as List<ProgramWorkout>,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutProgram].
extension WorkoutProgramPatterns on WorkoutProgram {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutProgram value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutProgram() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutProgram value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutProgram():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutProgram value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutProgram() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  WorkoutGoal goal,  ProgramDifficulty difficulty,  SplitType splitType,  String? description,  int? durationWeeks,  bool isTemplate,  bool isPublic,  String createdById,  String? organizationId,  DateTime? createdAt,  List<ProgramWorkout> programWorkouts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutProgram() when $default != null:
return $default(_that.id,_that.name,_that.goal,_that.difficulty,_that.splitType,_that.description,_that.durationWeeks,_that.isTemplate,_that.isPublic,_that.createdById,_that.organizationId,_that.createdAt,_that.programWorkouts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  WorkoutGoal goal,  ProgramDifficulty difficulty,  SplitType splitType,  String? description,  int? durationWeeks,  bool isTemplate,  bool isPublic,  String createdById,  String? organizationId,  DateTime? createdAt,  List<ProgramWorkout> programWorkouts)  $default,) {final _that = this;
switch (_that) {
case _WorkoutProgram():
return $default(_that.id,_that.name,_that.goal,_that.difficulty,_that.splitType,_that.description,_that.durationWeeks,_that.isTemplate,_that.isPublic,_that.createdById,_that.organizationId,_that.createdAt,_that.programWorkouts);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  WorkoutGoal goal,  ProgramDifficulty difficulty,  SplitType splitType,  String? description,  int? durationWeeks,  bool isTemplate,  bool isPublic,  String createdById,  String? organizationId,  DateTime? createdAt,  List<ProgramWorkout> programWorkouts)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutProgram() when $default != null:
return $default(_that.id,_that.name,_that.goal,_that.difficulty,_that.splitType,_that.description,_that.durationWeeks,_that.isTemplate,_that.isPublic,_that.createdById,_that.organizationId,_that.createdAt,_that.programWorkouts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutProgram extends WorkoutProgram {
  const _WorkoutProgram({required this.id, required this.name, required this.goal, required this.difficulty, required this.splitType, this.description, this.durationWeeks, this.isTemplate = false, this.isPublic = false, required this.createdById, this.organizationId, this.createdAt, final  List<ProgramWorkout> programWorkouts = const []}): _programWorkouts = programWorkouts,super._();
  factory _WorkoutProgram.fromJson(Map<String, dynamic> json) => _$WorkoutProgramFromJson(json);

@override final  String id;
@override final  String name;
@override final  WorkoutGoal goal;
@override final  ProgramDifficulty difficulty;
@override final  SplitType splitType;
@override final  String? description;
@override final  int? durationWeeks;
@override@JsonKey() final  bool isTemplate;
@override@JsonKey() final  bool isPublic;
@override final  String createdById;
@override final  String? organizationId;
@override final  DateTime? createdAt;
 final  List<ProgramWorkout> _programWorkouts;
@override@JsonKey() List<ProgramWorkout> get programWorkouts {
  if (_programWorkouts is EqualUnmodifiableListView) return _programWorkouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_programWorkouts);
}


/// Create a copy of WorkoutProgram
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutProgramCopyWith<_WorkoutProgram> get copyWith => __$WorkoutProgramCopyWithImpl<_WorkoutProgram>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutProgramToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutProgram&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.splitType, splitType) || other.splitType == splitType)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.isTemplate, isTemplate) || other.isTemplate == isTemplate)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._programWorkouts, _programWorkouts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,goal,difficulty,splitType,description,durationWeeks,isTemplate,isPublic,createdById,organizationId,createdAt,const DeepCollectionEquality().hash(_programWorkouts));

@override
String toString() {
  return 'WorkoutProgram(id: $id, name: $name, goal: $goal, difficulty: $difficulty, splitType: $splitType, description: $description, durationWeeks: $durationWeeks, isTemplate: $isTemplate, isPublic: $isPublic, createdById: $createdById, organizationId: $organizationId, createdAt: $createdAt, programWorkouts: $programWorkouts)';
}


}

/// @nodoc
abstract mixin class _$WorkoutProgramCopyWith<$Res> implements $WorkoutProgramCopyWith<$Res> {
  factory _$WorkoutProgramCopyWith(_WorkoutProgram value, $Res Function(_WorkoutProgram) _then) = __$WorkoutProgramCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, WorkoutGoal goal, ProgramDifficulty difficulty, SplitType splitType, String? description, int? durationWeeks, bool isTemplate, bool isPublic, String createdById, String? organizationId, DateTime? createdAt, List<ProgramWorkout> programWorkouts
});




}
/// @nodoc
class __$WorkoutProgramCopyWithImpl<$Res>
    implements _$WorkoutProgramCopyWith<$Res> {
  __$WorkoutProgramCopyWithImpl(this._self, this._then);

  final _WorkoutProgram _self;
  final $Res Function(_WorkoutProgram) _then;

/// Create a copy of WorkoutProgram
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? goal = null,Object? difficulty = null,Object? splitType = null,Object? description = freezed,Object? durationWeeks = freezed,Object? isTemplate = null,Object? isPublic = null,Object? createdById = null,Object? organizationId = freezed,Object? createdAt = freezed,Object? programWorkouts = null,}) {
  return _then(_WorkoutProgram(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as WorkoutGoal,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as ProgramDifficulty,splitType: null == splitType ? _self.splitType : splitType // ignore: cast_nullable_to_non_nullable
as SplitType,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationWeeks: freezed == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int?,isTemplate: null == isTemplate ? _self.isTemplate : isTemplate // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,createdById: null == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,programWorkouts: null == programWorkouts ? _self._programWorkouts : programWorkouts // ignore: cast_nullable_to_non_nullable
as List<ProgramWorkout>,
  ));
}


}


/// @nodoc
mixin _$ProgramWorkout {

 String get id; String get workoutId; int get order; String get label; int? get dayOfWeek; ProgramWorkoutDetail? get workout;
/// Create a copy of ProgramWorkout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgramWorkoutCopyWith<ProgramWorkout> get copyWith => _$ProgramWorkoutCopyWithImpl<ProgramWorkout>(this as ProgramWorkout, _$identity);

  /// Serializes this ProgramWorkout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgramWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.order, order) || other.order == order)&&(identical(other.label, label) || other.label == label)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.workout, workout) || other.workout == workout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workoutId,order,label,dayOfWeek,workout);

@override
String toString() {
  return 'ProgramWorkout(id: $id, workoutId: $workoutId, order: $order, label: $label, dayOfWeek: $dayOfWeek, workout: $workout)';
}


}

/// @nodoc
abstract mixin class $ProgramWorkoutCopyWith<$Res>  {
  factory $ProgramWorkoutCopyWith(ProgramWorkout value, $Res Function(ProgramWorkout) _then) = _$ProgramWorkoutCopyWithImpl;
@useResult
$Res call({
 String id, String workoutId, int order, String label, int? dayOfWeek, ProgramWorkoutDetail? workout
});


$ProgramWorkoutDetailCopyWith<$Res>? get workout;

}
/// @nodoc
class _$ProgramWorkoutCopyWithImpl<$Res>
    implements $ProgramWorkoutCopyWith<$Res> {
  _$ProgramWorkoutCopyWithImpl(this._self, this._then);

  final ProgramWorkout _self;
  final $Res Function(ProgramWorkout) _then;

/// Create a copy of ProgramWorkout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workoutId = null,Object? order = null,Object? label = null,Object? dayOfWeek = freezed,Object? workout = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: freezed == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int?,workout: freezed == workout ? _self.workout : workout // ignore: cast_nullable_to_non_nullable
as ProgramWorkoutDetail?,
  ));
}
/// Create a copy of ProgramWorkout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgramWorkoutDetailCopyWith<$Res>? get workout {
    if (_self.workout == null) {
    return null;
  }

  return $ProgramWorkoutDetailCopyWith<$Res>(_self.workout!, (value) {
    return _then(_self.copyWith(workout: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProgramWorkout].
extension ProgramWorkoutPatterns on ProgramWorkout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgramWorkout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgramWorkout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgramWorkout value)  $default,){
final _that = this;
switch (_that) {
case _ProgramWorkout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgramWorkout value)?  $default,){
final _that = this;
switch (_that) {
case _ProgramWorkout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workoutId,  int order,  String label,  int? dayOfWeek,  ProgramWorkoutDetail? workout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgramWorkout() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workoutId,  int order,  String label,  int? dayOfWeek,  ProgramWorkoutDetail? workout)  $default,) {final _that = this;
switch (_that) {
case _ProgramWorkout():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workoutId,  int order,  String label,  int? dayOfWeek,  ProgramWorkoutDetail? workout)?  $default,) {final _that = this;
switch (_that) {
case _ProgramWorkout() when $default != null:
return $default(_that.id,_that.workoutId,_that.order,_that.label,_that.dayOfWeek,_that.workout);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProgramWorkout extends ProgramWorkout {
  const _ProgramWorkout({required this.id, required this.workoutId, required this.order, required this.label, this.dayOfWeek, this.workout}): super._();
  factory _ProgramWorkout.fromJson(Map<String, dynamic> json) => _$ProgramWorkoutFromJson(json);

@override final  String id;
@override final  String workoutId;
@override final  int order;
@override final  String label;
@override final  int? dayOfWeek;
@override final  ProgramWorkoutDetail? workout;

/// Create a copy of ProgramWorkout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgramWorkoutCopyWith<_ProgramWorkout> get copyWith => __$ProgramWorkoutCopyWithImpl<_ProgramWorkout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProgramWorkoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgramWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.order, order) || other.order == order)&&(identical(other.label, label) || other.label == label)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.workout, workout) || other.workout == workout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workoutId,order,label,dayOfWeek,workout);

@override
String toString() {
  return 'ProgramWorkout(id: $id, workoutId: $workoutId, order: $order, label: $label, dayOfWeek: $dayOfWeek, workout: $workout)';
}


}

/// @nodoc
abstract mixin class _$ProgramWorkoutCopyWith<$Res> implements $ProgramWorkoutCopyWith<$Res> {
  factory _$ProgramWorkoutCopyWith(_ProgramWorkout value, $Res Function(_ProgramWorkout) _then) = __$ProgramWorkoutCopyWithImpl;
@override @useResult
$Res call({
 String id, String workoutId, int order, String label, int? dayOfWeek, ProgramWorkoutDetail? workout
});


@override $ProgramWorkoutDetailCopyWith<$Res>? get workout;

}
/// @nodoc
class __$ProgramWorkoutCopyWithImpl<$Res>
    implements _$ProgramWorkoutCopyWith<$Res> {
  __$ProgramWorkoutCopyWithImpl(this._self, this._then);

  final _ProgramWorkout _self;
  final $Res Function(_ProgramWorkout) _then;

/// Create a copy of ProgramWorkout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workoutId = null,Object? order = null,Object? label = null,Object? dayOfWeek = freezed,Object? workout = freezed,}) {
  return _then(_ProgramWorkout(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: freezed == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int?,workout: freezed == workout ? _self.workout : workout // ignore: cast_nullable_to_non_nullable
as ProgramWorkoutDetail?,
  ));
}

/// Create a copy of ProgramWorkout
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgramWorkoutDetailCopyWith<$Res>? get workout {
    if (_self.workout == null) {
    return null;
  }

  return $ProgramWorkoutDetailCopyWith<$Res>(_self.workout!, (value) {
    return _then(_self.copyWith(workout: value));
  });
}
}


/// @nodoc
mixin _$ProgramWorkoutDetail {

 String get id; String get name; String? get description; String get difficulty; int get estimatedDurationMin; List<String>? get targetMuscles; List<ProgramExercise> get exercises;
/// Create a copy of ProgramWorkoutDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgramWorkoutDetailCopyWith<ProgramWorkoutDetail> get copyWith => _$ProgramWorkoutDetailCopyWithImpl<ProgramWorkoutDetail>(this as ProgramWorkoutDetail, _$identity);

  /// Serializes this ProgramWorkoutDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgramWorkoutDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedDurationMin, estimatedDurationMin) || other.estimatedDurationMin == estimatedDurationMin)&&const DeepCollectionEquality().equals(other.targetMuscles, targetMuscles)&&const DeepCollectionEquality().equals(other.exercises, exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,difficulty,estimatedDurationMin,const DeepCollectionEquality().hash(targetMuscles),const DeepCollectionEquality().hash(exercises));

@override
String toString() {
  return 'ProgramWorkoutDetail(id: $id, name: $name, description: $description, difficulty: $difficulty, estimatedDurationMin: $estimatedDurationMin, targetMuscles: $targetMuscles, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class $ProgramWorkoutDetailCopyWith<$Res>  {
  factory $ProgramWorkoutDetailCopyWith(ProgramWorkoutDetail value, $Res Function(ProgramWorkoutDetail) _then) = _$ProgramWorkoutDetailCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String difficulty, int estimatedDurationMin, List<String>? targetMuscles, List<ProgramExercise> exercises
});




}
/// @nodoc
class _$ProgramWorkoutDetailCopyWithImpl<$Res>
    implements $ProgramWorkoutDetailCopyWith<$Res> {
  _$ProgramWorkoutDetailCopyWithImpl(this._self, this._then);

  final ProgramWorkoutDetail _self;
  final $Res Function(ProgramWorkoutDetail) _then;

/// Create a copy of ProgramWorkoutDetail
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
as List<ProgramExercise>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgramWorkoutDetail].
extension ProgramWorkoutDetailPatterns on ProgramWorkoutDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgramWorkoutDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgramWorkoutDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgramWorkoutDetail value)  $default,){
final _that = this;
switch (_that) {
case _ProgramWorkoutDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgramWorkoutDetail value)?  $default,){
final _that = this;
switch (_that) {
case _ProgramWorkoutDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String difficulty,  int estimatedDurationMin,  List<String>? targetMuscles,  List<ProgramExercise> exercises)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgramWorkoutDetail() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String difficulty,  int estimatedDurationMin,  List<String>? targetMuscles,  List<ProgramExercise> exercises)  $default,) {final _that = this;
switch (_that) {
case _ProgramWorkoutDetail():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String difficulty,  int estimatedDurationMin,  List<String>? targetMuscles,  List<ProgramExercise> exercises)?  $default,) {final _that = this;
switch (_that) {
case _ProgramWorkoutDetail() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.difficulty,_that.estimatedDurationMin,_that.targetMuscles,_that.exercises);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProgramWorkoutDetail extends ProgramWorkoutDetail {
  const _ProgramWorkoutDetail({required this.id, required this.name, this.description, required this.difficulty, required this.estimatedDurationMin, final  List<String>? targetMuscles, final  List<ProgramExercise> exercises = const []}): _targetMuscles = targetMuscles,_exercises = exercises,super._();
  factory _ProgramWorkoutDetail.fromJson(Map<String, dynamic> json) => _$ProgramWorkoutDetailFromJson(json);

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

 final  List<ProgramExercise> _exercises;
@override@JsonKey() List<ProgramExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}


/// Create a copy of ProgramWorkoutDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgramWorkoutDetailCopyWith<_ProgramWorkoutDetail> get copyWith => __$ProgramWorkoutDetailCopyWithImpl<_ProgramWorkoutDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProgramWorkoutDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgramWorkoutDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedDurationMin, estimatedDurationMin) || other.estimatedDurationMin == estimatedDurationMin)&&const DeepCollectionEquality().equals(other._targetMuscles, _targetMuscles)&&const DeepCollectionEquality().equals(other._exercises, _exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,difficulty,estimatedDurationMin,const DeepCollectionEquality().hash(_targetMuscles),const DeepCollectionEquality().hash(_exercises));

@override
String toString() {
  return 'ProgramWorkoutDetail(id: $id, name: $name, description: $description, difficulty: $difficulty, estimatedDurationMin: $estimatedDurationMin, targetMuscles: $targetMuscles, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class _$ProgramWorkoutDetailCopyWith<$Res> implements $ProgramWorkoutDetailCopyWith<$Res> {
  factory _$ProgramWorkoutDetailCopyWith(_ProgramWorkoutDetail value, $Res Function(_ProgramWorkoutDetail) _then) = __$ProgramWorkoutDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String difficulty, int estimatedDurationMin, List<String>? targetMuscles, List<ProgramExercise> exercises
});




}
/// @nodoc
class __$ProgramWorkoutDetailCopyWithImpl<$Res>
    implements _$ProgramWorkoutDetailCopyWith<$Res> {
  __$ProgramWorkoutDetailCopyWithImpl(this._self, this._then);

  final _ProgramWorkoutDetail _self;
  final $Res Function(_ProgramWorkoutDetail) _then;

/// Create a copy of ProgramWorkoutDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? difficulty = null,Object? estimatedDurationMin = null,Object? targetMuscles = freezed,Object? exercises = null,}) {
  return _then(_ProgramWorkoutDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,estimatedDurationMin: null == estimatedDurationMin ? _self.estimatedDurationMin : estimatedDurationMin // ignore: cast_nullable_to_non_nullable
as int,targetMuscles: freezed == targetMuscles ? _self._targetMuscles : targetMuscles // ignore: cast_nullable_to_non_nullable
as List<String>?,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ProgramExercise>,
  ));
}


}


/// @nodoc
mixin _$ProgramExercise {

 String get id; String get exerciseId; int get order; int get sets; String get reps; int get restSeconds; String? get notes; String? get supersetWith;// Advanced technique fields
 String? get executionInstructions; int? get isometricSeconds; TechniqueType get techniqueType; String? get exerciseGroupId; int get exerciseGroupOrder; ProgramExerciseDetail? get exercise;
/// Create a copy of ProgramExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgramExerciseCopyWith<ProgramExercise> get copyWith => _$ProgramExerciseCopyWithImpl<ProgramExercise>(this as ProgramExercise, _$identity);

  /// Serializes this ProgramExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgramExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.order, order) || other.order == order)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.supersetWith, supersetWith) || other.supersetWith == supersetWith)&&(identical(other.executionInstructions, executionInstructions) || other.executionInstructions == executionInstructions)&&(identical(other.isometricSeconds, isometricSeconds) || other.isometricSeconds == isometricSeconds)&&(identical(other.techniqueType, techniqueType) || other.techniqueType == techniqueType)&&(identical(other.exerciseGroupId, exerciseGroupId) || other.exerciseGroupId == exerciseGroupId)&&(identical(other.exerciseGroupOrder, exerciseGroupOrder) || other.exerciseGroupOrder == exerciseGroupOrder)&&(identical(other.exercise, exercise) || other.exercise == exercise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,order,sets,reps,restSeconds,notes,supersetWith,executionInstructions,isometricSeconds,techniqueType,exerciseGroupId,exerciseGroupOrder,exercise);

@override
String toString() {
  return 'ProgramExercise(id: $id, exerciseId: $exerciseId, order: $order, sets: $sets, reps: $reps, restSeconds: $restSeconds, notes: $notes, supersetWith: $supersetWith, executionInstructions: $executionInstructions, isometricSeconds: $isometricSeconds, techniqueType: $techniqueType, exerciseGroupId: $exerciseGroupId, exerciseGroupOrder: $exerciseGroupOrder, exercise: $exercise)';
}


}

/// @nodoc
abstract mixin class $ProgramExerciseCopyWith<$Res>  {
  factory $ProgramExerciseCopyWith(ProgramExercise value, $Res Function(ProgramExercise) _then) = _$ProgramExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, int order, int sets, String reps, int restSeconds, String? notes, String? supersetWith, String? executionInstructions, int? isometricSeconds, TechniqueType techniqueType, String? exerciseGroupId, int exerciseGroupOrder, ProgramExerciseDetail? exercise
});


$ProgramExerciseDetailCopyWith<$Res>? get exercise;

}
/// @nodoc
class _$ProgramExerciseCopyWithImpl<$Res>
    implements $ProgramExerciseCopyWith<$Res> {
  _$ProgramExerciseCopyWithImpl(this._self, this._then);

  final ProgramExercise _self;
  final $Res Function(ProgramExercise) _then;

/// Create a copy of ProgramExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? order = null,Object? sets = null,Object? reps = null,Object? restSeconds = null,Object? notes = freezed,Object? supersetWith = freezed,Object? executionInstructions = freezed,Object? isometricSeconds = freezed,Object? techniqueType = null,Object? exerciseGroupId = freezed,Object? exerciseGroupOrder = null,Object? exercise = freezed,}) {
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
as int,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as ProgramExerciseDetail?,
  ));
}
/// Create a copy of ProgramExercise
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgramExerciseDetailCopyWith<$Res>? get exercise {
    if (_self.exercise == null) {
    return null;
  }

  return $ProgramExerciseDetailCopyWith<$Res>(_self.exercise!, (value) {
    return _then(_self.copyWith(exercise: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProgramExercise].
extension ProgramExercisePatterns on ProgramExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgramExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgramExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgramExercise value)  $default,){
final _that = this;
switch (_that) {
case _ProgramExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgramExercise value)?  $default,){
final _that = this;
switch (_that) {
case _ProgramExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  int order,  int sets,  String reps,  int restSeconds,  String? notes,  String? supersetWith,  String? executionInstructions,  int? isometricSeconds,  TechniqueType techniqueType,  String? exerciseGroupId,  int exerciseGroupOrder,  ProgramExerciseDetail? exercise)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgramExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.order,_that.sets,_that.reps,_that.restSeconds,_that.notes,_that.supersetWith,_that.executionInstructions,_that.isometricSeconds,_that.techniqueType,_that.exerciseGroupId,_that.exerciseGroupOrder,_that.exercise);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  int order,  int sets,  String reps,  int restSeconds,  String? notes,  String? supersetWith,  String? executionInstructions,  int? isometricSeconds,  TechniqueType techniqueType,  String? exerciseGroupId,  int exerciseGroupOrder,  ProgramExerciseDetail? exercise)  $default,) {final _that = this;
switch (_that) {
case _ProgramExercise():
return $default(_that.id,_that.exerciseId,_that.order,_that.sets,_that.reps,_that.restSeconds,_that.notes,_that.supersetWith,_that.executionInstructions,_that.isometricSeconds,_that.techniqueType,_that.exerciseGroupId,_that.exerciseGroupOrder,_that.exercise);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  int order,  int sets,  String reps,  int restSeconds,  String? notes,  String? supersetWith,  String? executionInstructions,  int? isometricSeconds,  TechniqueType techniqueType,  String? exerciseGroupId,  int exerciseGroupOrder,  ProgramExerciseDetail? exercise)?  $default,) {final _that = this;
switch (_that) {
case _ProgramExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.order,_that.sets,_that.reps,_that.restSeconds,_that.notes,_that.supersetWith,_that.executionInstructions,_that.isometricSeconds,_that.techniqueType,_that.exerciseGroupId,_that.exerciseGroupOrder,_that.exercise);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProgramExercise extends ProgramExercise {
  const _ProgramExercise({required this.id, required this.exerciseId, required this.order, required this.sets, required this.reps, required this.restSeconds, this.notes, this.supersetWith, this.executionInstructions, this.isometricSeconds, this.techniqueType = TechniqueType.normal, this.exerciseGroupId, this.exerciseGroupOrder = 0, this.exercise}): super._();
  factory _ProgramExercise.fromJson(Map<String, dynamic> json) => _$ProgramExerciseFromJson(json);

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
@override final  ProgramExerciseDetail? exercise;

/// Create a copy of ProgramExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgramExerciseCopyWith<_ProgramExercise> get copyWith => __$ProgramExerciseCopyWithImpl<_ProgramExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProgramExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgramExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.order, order) || other.order == order)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.supersetWith, supersetWith) || other.supersetWith == supersetWith)&&(identical(other.executionInstructions, executionInstructions) || other.executionInstructions == executionInstructions)&&(identical(other.isometricSeconds, isometricSeconds) || other.isometricSeconds == isometricSeconds)&&(identical(other.techniqueType, techniqueType) || other.techniqueType == techniqueType)&&(identical(other.exerciseGroupId, exerciseGroupId) || other.exerciseGroupId == exerciseGroupId)&&(identical(other.exerciseGroupOrder, exerciseGroupOrder) || other.exerciseGroupOrder == exerciseGroupOrder)&&(identical(other.exercise, exercise) || other.exercise == exercise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,order,sets,reps,restSeconds,notes,supersetWith,executionInstructions,isometricSeconds,techniqueType,exerciseGroupId,exerciseGroupOrder,exercise);

@override
String toString() {
  return 'ProgramExercise(id: $id, exerciseId: $exerciseId, order: $order, sets: $sets, reps: $reps, restSeconds: $restSeconds, notes: $notes, supersetWith: $supersetWith, executionInstructions: $executionInstructions, isometricSeconds: $isometricSeconds, techniqueType: $techniqueType, exerciseGroupId: $exerciseGroupId, exerciseGroupOrder: $exerciseGroupOrder, exercise: $exercise)';
}


}

/// @nodoc
abstract mixin class _$ProgramExerciseCopyWith<$Res> implements $ProgramExerciseCopyWith<$Res> {
  factory _$ProgramExerciseCopyWith(_ProgramExercise value, $Res Function(_ProgramExercise) _then) = __$ProgramExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, int order, int sets, String reps, int restSeconds, String? notes, String? supersetWith, String? executionInstructions, int? isometricSeconds, TechniqueType techniqueType, String? exerciseGroupId, int exerciseGroupOrder, ProgramExerciseDetail? exercise
});


@override $ProgramExerciseDetailCopyWith<$Res>? get exercise;

}
/// @nodoc
class __$ProgramExerciseCopyWithImpl<$Res>
    implements _$ProgramExerciseCopyWith<$Res> {
  __$ProgramExerciseCopyWithImpl(this._self, this._then);

  final _ProgramExercise _self;
  final $Res Function(_ProgramExercise) _then;

/// Create a copy of ProgramExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? order = null,Object? sets = null,Object? reps = null,Object? restSeconds = null,Object? notes = freezed,Object? supersetWith = freezed,Object? executionInstructions = freezed,Object? isometricSeconds = freezed,Object? techniqueType = null,Object? exerciseGroupId = freezed,Object? exerciseGroupOrder = null,Object? exercise = freezed,}) {
  return _then(_ProgramExercise(
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
as int,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as ProgramExerciseDetail?,
  ));
}

/// Create a copy of ProgramExercise
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgramExerciseDetailCopyWith<$Res>? get exercise {
    if (_self.exercise == null) {
    return null;
  }

  return $ProgramExerciseDetailCopyWith<$Res>(_self.exercise!, (value) {
    return _then(_self.copyWith(exercise: value));
  });
}
}


/// @nodoc
mixin _$ProgramExerciseDetail {

 String get id; String get name; String get muscleGroup; String? get description; String? get instructions; String? get imageUrl; String? get videoUrl;
/// Create a copy of ProgramExerciseDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgramExerciseDetailCopyWith<ProgramExerciseDetail> get copyWith => _$ProgramExerciseDetailCopyWithImpl<ProgramExerciseDetail>(this as ProgramExerciseDetail, _$identity);

  /// Serializes this ProgramExerciseDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgramExerciseDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&(identical(other.description, description) || other.description == description)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,muscleGroup,description,instructions,imageUrl,videoUrl);

@override
String toString() {
  return 'ProgramExerciseDetail(id: $id, name: $name, muscleGroup: $muscleGroup, description: $description, instructions: $instructions, imageUrl: $imageUrl, videoUrl: $videoUrl)';
}


}

/// @nodoc
abstract mixin class $ProgramExerciseDetailCopyWith<$Res>  {
  factory $ProgramExerciseDetailCopyWith(ProgramExerciseDetail value, $Res Function(ProgramExerciseDetail) _then) = _$ProgramExerciseDetailCopyWithImpl;
@useResult
$Res call({
 String id, String name, String muscleGroup, String? description, String? instructions, String? imageUrl, String? videoUrl
});




}
/// @nodoc
class _$ProgramExerciseDetailCopyWithImpl<$Res>
    implements $ProgramExerciseDetailCopyWith<$Res> {
  _$ProgramExerciseDetailCopyWithImpl(this._self, this._then);

  final ProgramExerciseDetail _self;
  final $Res Function(ProgramExerciseDetail) _then;

/// Create a copy of ProgramExerciseDetail
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


/// Adds pattern-matching-related methods to [ProgramExerciseDetail].
extension ProgramExerciseDetailPatterns on ProgramExerciseDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgramExerciseDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgramExerciseDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgramExerciseDetail value)  $default,){
final _that = this;
switch (_that) {
case _ProgramExerciseDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgramExerciseDetail value)?  $default,){
final _that = this;
switch (_that) {
case _ProgramExerciseDetail() when $default != null:
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
case _ProgramExerciseDetail() when $default != null:
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
case _ProgramExerciseDetail():
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
case _ProgramExerciseDetail() when $default != null:
return $default(_that.id,_that.name,_that.muscleGroup,_that.description,_that.instructions,_that.imageUrl,_that.videoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProgramExerciseDetail implements ProgramExerciseDetail {
  const _ProgramExerciseDetail({required this.id, required this.name, required this.muscleGroup, this.description, this.instructions, this.imageUrl, this.videoUrl});
  factory _ProgramExerciseDetail.fromJson(Map<String, dynamic> json) => _$ProgramExerciseDetailFromJson(json);

@override final  String id;
@override final  String name;
@override final  String muscleGroup;
@override final  String? description;
@override final  String? instructions;
@override final  String? imageUrl;
@override final  String? videoUrl;

/// Create a copy of ProgramExerciseDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgramExerciseDetailCopyWith<_ProgramExerciseDetail> get copyWith => __$ProgramExerciseDetailCopyWithImpl<_ProgramExerciseDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProgramExerciseDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgramExerciseDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&(identical(other.description, description) || other.description == description)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,muscleGroup,description,instructions,imageUrl,videoUrl);

@override
String toString() {
  return 'ProgramExerciseDetail(id: $id, name: $name, muscleGroup: $muscleGroup, description: $description, instructions: $instructions, imageUrl: $imageUrl, videoUrl: $videoUrl)';
}


}

/// @nodoc
abstract mixin class _$ProgramExerciseDetailCopyWith<$Res> implements $ProgramExerciseDetailCopyWith<$Res> {
  factory _$ProgramExerciseDetailCopyWith(_ProgramExerciseDetail value, $Res Function(_ProgramExerciseDetail) _then) = __$ProgramExerciseDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String muscleGroup, String? description, String? instructions, String? imageUrl, String? videoUrl
});




}
/// @nodoc
class __$ProgramExerciseDetailCopyWithImpl<$Res>
    implements _$ProgramExerciseDetailCopyWith<$Res> {
  __$ProgramExerciseDetailCopyWithImpl(this._self, this._then);

  final _ProgramExerciseDetail _self;
  final $Res Function(_ProgramExerciseDetail) _then;

/// Create a copy of ProgramExerciseDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? muscleGroup = null,Object? description = freezed,Object? instructions = freezed,Object? imageUrl = freezed,Object? videoUrl = freezed,}) {
  return _then(_ProgramExerciseDetail(
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
