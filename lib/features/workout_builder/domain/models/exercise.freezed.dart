// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Exercise {

 String get id; String get name; MuscleGroup get muscleGroup; List<MuscleGroup> get secondaryMuscles; EquipmentType? get equipment; String? get description; String? get instructions; String? get imageUrl; String? get videoUrl; String get difficulty; bool get isCompound; bool get isCustom; String? get createdBy;
/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseCopyWith<Exercise> get copyWith => _$ExerciseCopyWithImpl<Exercise>(this as Exercise, _$identity);

  /// Serializes this Exercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Exercise&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&const DeepCollectionEquality().equals(other.secondaryMuscles, secondaryMuscles)&&(identical(other.equipment, equipment) || other.equipment == equipment)&&(identical(other.description, description) || other.description == description)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.isCompound, isCompound) || other.isCompound == isCompound)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,muscleGroup,const DeepCollectionEquality().hash(secondaryMuscles),equipment,description,instructions,imageUrl,videoUrl,difficulty,isCompound,isCustom,createdBy);

@override
String toString() {
  return 'Exercise(id: $id, name: $name, muscleGroup: $muscleGroup, secondaryMuscles: $secondaryMuscles, equipment: $equipment, description: $description, instructions: $instructions, imageUrl: $imageUrl, videoUrl: $videoUrl, difficulty: $difficulty, isCompound: $isCompound, isCustom: $isCustom, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class $ExerciseCopyWith<$Res>  {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) _then) = _$ExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String name, MuscleGroup muscleGroup, List<MuscleGroup> secondaryMuscles, EquipmentType? equipment, String? description, String? instructions, String? imageUrl, String? videoUrl, String difficulty, bool isCompound, bool isCustom, String? createdBy
});




}
/// @nodoc
class _$ExerciseCopyWithImpl<$Res>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._self, this._then);

  final Exercise _self;
  final $Res Function(Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? muscleGroup = null,Object? secondaryMuscles = null,Object? equipment = freezed,Object? description = freezed,Object? instructions = freezed,Object? imageUrl = freezed,Object? videoUrl = freezed,Object? difficulty = null,Object? isCompound = null,Object? isCustom = null,Object? createdBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,muscleGroup: null == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as MuscleGroup,secondaryMuscles: null == secondaryMuscles ? _self.secondaryMuscles : secondaryMuscles // ignore: cast_nullable_to_non_nullable
as List<MuscleGroup>,equipment: freezed == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as EquipmentType?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,isCompound: null == isCompound ? _self.isCompound : isCompound // ignore: cast_nullable_to_non_nullable
as bool,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Exercise].
extension ExercisePatterns on Exercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Exercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Exercise value)  $default,){
final _that = this;
switch (_that) {
case _Exercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Exercise value)?  $default,){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  MuscleGroup muscleGroup,  List<MuscleGroup> secondaryMuscles,  EquipmentType? equipment,  String? description,  String? instructions,  String? imageUrl,  String? videoUrl,  String difficulty,  bool isCompound,  bool isCustom,  String? createdBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.id,_that.name,_that.muscleGroup,_that.secondaryMuscles,_that.equipment,_that.description,_that.instructions,_that.imageUrl,_that.videoUrl,_that.difficulty,_that.isCompound,_that.isCustom,_that.createdBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  MuscleGroup muscleGroup,  List<MuscleGroup> secondaryMuscles,  EquipmentType? equipment,  String? description,  String? instructions,  String? imageUrl,  String? videoUrl,  String difficulty,  bool isCompound,  bool isCustom,  String? createdBy)  $default,) {final _that = this;
switch (_that) {
case _Exercise():
return $default(_that.id,_that.name,_that.muscleGroup,_that.secondaryMuscles,_that.equipment,_that.description,_that.instructions,_that.imageUrl,_that.videoUrl,_that.difficulty,_that.isCompound,_that.isCustom,_that.createdBy);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  MuscleGroup muscleGroup,  List<MuscleGroup> secondaryMuscles,  EquipmentType? equipment,  String? description,  String? instructions,  String? imageUrl,  String? videoUrl,  String difficulty,  bool isCompound,  bool isCustom,  String? createdBy)?  $default,) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.id,_that.name,_that.muscleGroup,_that.secondaryMuscles,_that.equipment,_that.description,_that.instructions,_that.imageUrl,_that.videoUrl,_that.difficulty,_that.isCompound,_that.isCustom,_that.createdBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Exercise extends Exercise {
  const _Exercise({required this.id, required this.name, required this.muscleGroup, final  List<MuscleGroup> secondaryMuscles = const [], this.equipment, this.description, this.instructions, this.imageUrl, this.videoUrl, this.difficulty = 'intermediate', this.isCompound = false, this.isCustom = false, this.createdBy}): _secondaryMuscles = secondaryMuscles,super._();
  factory _Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

@override final  String id;
@override final  String name;
@override final  MuscleGroup muscleGroup;
 final  List<MuscleGroup> _secondaryMuscles;
@override@JsonKey() List<MuscleGroup> get secondaryMuscles {
  if (_secondaryMuscles is EqualUnmodifiableListView) return _secondaryMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_secondaryMuscles);
}

@override final  EquipmentType? equipment;
@override final  String? description;
@override final  String? instructions;
@override final  String? imageUrl;
@override final  String? videoUrl;
@override@JsonKey() final  String difficulty;
@override@JsonKey() final  bool isCompound;
@override@JsonKey() final  bool isCustom;
@override final  String? createdBy;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseCopyWith<_Exercise> get copyWith => __$ExerciseCopyWithImpl<_Exercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Exercise&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&const DeepCollectionEquality().equals(other._secondaryMuscles, _secondaryMuscles)&&(identical(other.equipment, equipment) || other.equipment == equipment)&&(identical(other.description, description) || other.description == description)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.isCompound, isCompound) || other.isCompound == isCompound)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,muscleGroup,const DeepCollectionEquality().hash(_secondaryMuscles),equipment,description,instructions,imageUrl,videoUrl,difficulty,isCompound,isCustom,createdBy);

@override
String toString() {
  return 'Exercise(id: $id, name: $name, muscleGroup: $muscleGroup, secondaryMuscles: $secondaryMuscles, equipment: $equipment, description: $description, instructions: $instructions, imageUrl: $imageUrl, videoUrl: $videoUrl, difficulty: $difficulty, isCompound: $isCompound, isCustom: $isCustom, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class _$ExerciseCopyWith<$Res> implements $ExerciseCopyWith<$Res> {
  factory _$ExerciseCopyWith(_Exercise value, $Res Function(_Exercise) _then) = __$ExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, MuscleGroup muscleGroup, List<MuscleGroup> secondaryMuscles, EquipmentType? equipment, String? description, String? instructions, String? imageUrl, String? videoUrl, String difficulty, bool isCompound, bool isCustom, String? createdBy
});




}
/// @nodoc
class __$ExerciseCopyWithImpl<$Res>
    implements _$ExerciseCopyWith<$Res> {
  __$ExerciseCopyWithImpl(this._self, this._then);

  final _Exercise _self;
  final $Res Function(_Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? muscleGroup = null,Object? secondaryMuscles = null,Object? equipment = freezed,Object? description = freezed,Object? instructions = freezed,Object? imageUrl = freezed,Object? videoUrl = freezed,Object? difficulty = null,Object? isCompound = null,Object? isCustom = null,Object? createdBy = freezed,}) {
  return _then(_Exercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,muscleGroup: null == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as MuscleGroup,secondaryMuscles: null == secondaryMuscles ? _self._secondaryMuscles : secondaryMuscles // ignore: cast_nullable_to_non_nullable
as List<MuscleGroup>,equipment: freezed == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as EquipmentType?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,isCompound: null == isCompound ? _self.isCompound : isCompound // ignore: cast_nullable_to_non_nullable
as bool,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
