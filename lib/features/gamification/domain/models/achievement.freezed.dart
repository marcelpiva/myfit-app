// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Achievement {

 String get id; String get name; String get description; String get icon; AchievementCategory get category; AchievementRarity get rarity; int get pointsReward; DateTime? get unlockedAt; double? get progress; int? get currentValue; int? get targetValue;
/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementCopyWith<Achievement> get copyWith => _$AchievementCopyWithImpl<Achievement>(this as Achievement, _$identity);

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Achievement&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.category, category) || other.category == category)&&(identical(other.rarity, rarity) || other.rarity == rarity)&&(identical(other.pointsReward, pointsReward) || other.pointsReward == pointsReward)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,icon,category,rarity,pointsReward,unlockedAt,progress,currentValue,targetValue);

@override
String toString() {
  return 'Achievement(id: $id, name: $name, description: $description, icon: $icon, category: $category, rarity: $rarity, pointsReward: $pointsReward, unlockedAt: $unlockedAt, progress: $progress, currentValue: $currentValue, targetValue: $targetValue)';
}


}

/// @nodoc
abstract mixin class $AchievementCopyWith<$Res>  {
  factory $AchievementCopyWith(Achievement value, $Res Function(Achievement) _then) = _$AchievementCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String icon, AchievementCategory category, AchievementRarity rarity, int pointsReward, DateTime? unlockedAt, double? progress, int? currentValue, int? targetValue
});




}
/// @nodoc
class _$AchievementCopyWithImpl<$Res>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._self, this._then);

  final Achievement _self;
  final $Res Function(Achievement) _then;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? icon = null,Object? category = null,Object? rarity = null,Object? pointsReward = null,Object? unlockedAt = freezed,Object? progress = freezed,Object? currentValue = freezed,Object? targetValue = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AchievementCategory,rarity: null == rarity ? _self.rarity : rarity // ignore: cast_nullable_to_non_nullable
as AchievementRarity,pointsReward: null == pointsReward ? _self.pointsReward : pointsReward // ignore: cast_nullable_to_non_nullable
as int,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,currentValue: freezed == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as int?,targetValue: freezed == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Achievement].
extension AchievementPatterns on Achievement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Achievement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Achievement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Achievement value)  $default,){
final _that = this;
switch (_that) {
case _Achievement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Achievement value)?  $default,){
final _that = this;
switch (_that) {
case _Achievement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String icon,  AchievementCategory category,  AchievementRarity rarity,  int pointsReward,  DateTime? unlockedAt,  double? progress,  int? currentValue,  int? targetValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.icon,_that.category,_that.rarity,_that.pointsReward,_that.unlockedAt,_that.progress,_that.currentValue,_that.targetValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String icon,  AchievementCategory category,  AchievementRarity rarity,  int pointsReward,  DateTime? unlockedAt,  double? progress,  int? currentValue,  int? targetValue)  $default,) {final _that = this;
switch (_that) {
case _Achievement():
return $default(_that.id,_that.name,_that.description,_that.icon,_that.category,_that.rarity,_that.pointsReward,_that.unlockedAt,_that.progress,_that.currentValue,_that.targetValue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String icon,  AchievementCategory category,  AchievementRarity rarity,  int pointsReward,  DateTime? unlockedAt,  double? progress,  int? currentValue,  int? targetValue)?  $default,) {final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.icon,_that.category,_that.rarity,_that.pointsReward,_that.unlockedAt,_that.progress,_that.currentValue,_that.targetValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Achievement extends Achievement {
  const _Achievement({required this.id, required this.name, required this.description, required this.icon, required this.category, required this.rarity, required this.pointsReward, this.unlockedAt, this.progress, this.currentValue, this.targetValue}): super._();
  factory _Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String icon;
@override final  AchievementCategory category;
@override final  AchievementRarity rarity;
@override final  int pointsReward;
@override final  DateTime? unlockedAt;
@override final  double? progress;
@override final  int? currentValue;
@override final  int? targetValue;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AchievementCopyWith<_Achievement> get copyWith => __$AchievementCopyWithImpl<_Achievement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AchievementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Achievement&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.category, category) || other.category == category)&&(identical(other.rarity, rarity) || other.rarity == rarity)&&(identical(other.pointsReward, pointsReward) || other.pointsReward == pointsReward)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,icon,category,rarity,pointsReward,unlockedAt,progress,currentValue,targetValue);

@override
String toString() {
  return 'Achievement(id: $id, name: $name, description: $description, icon: $icon, category: $category, rarity: $rarity, pointsReward: $pointsReward, unlockedAt: $unlockedAt, progress: $progress, currentValue: $currentValue, targetValue: $targetValue)';
}


}

/// @nodoc
abstract mixin class _$AchievementCopyWith<$Res> implements $AchievementCopyWith<$Res> {
  factory _$AchievementCopyWith(_Achievement value, $Res Function(_Achievement) _then) = __$AchievementCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String icon, AchievementCategory category, AchievementRarity rarity, int pointsReward, DateTime? unlockedAt, double? progress, int? currentValue, int? targetValue
});




}
/// @nodoc
class __$AchievementCopyWithImpl<$Res>
    implements _$AchievementCopyWith<$Res> {
  __$AchievementCopyWithImpl(this._self, this._then);

  final _Achievement _self;
  final $Res Function(_Achievement) _then;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? icon = null,Object? category = null,Object? rarity = null,Object? pointsReward = null,Object? unlockedAt = freezed,Object? progress = freezed,Object? currentValue = freezed,Object? targetValue = freezed,}) {
  return _then(_Achievement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AchievementCategory,rarity: null == rarity ? _self.rarity : rarity // ignore: cast_nullable_to_non_nullable
as AchievementRarity,pointsReward: null == pointsReward ? _self.pointsReward : pointsReward // ignore: cast_nullable_to_non_nullable
as int,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,currentValue: freezed == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as int?,targetValue: freezed == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$UserLevel {

 String get name; String get icon; int get minPoints; int get maxPoints; int get currentPoints;
/// Create a copy of UserLevel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserLevelCopyWith<UserLevel> get copyWith => _$UserLevelCopyWithImpl<UserLevel>(this as UserLevel, _$identity);

  /// Serializes this UserLevel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserLevel&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.minPoints, minPoints) || other.minPoints == minPoints)&&(identical(other.maxPoints, maxPoints) || other.maxPoints == maxPoints)&&(identical(other.currentPoints, currentPoints) || other.currentPoints == currentPoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,icon,minPoints,maxPoints,currentPoints);

@override
String toString() {
  return 'UserLevel(name: $name, icon: $icon, minPoints: $minPoints, maxPoints: $maxPoints, currentPoints: $currentPoints)';
}


}

/// @nodoc
abstract mixin class $UserLevelCopyWith<$Res>  {
  factory $UserLevelCopyWith(UserLevel value, $Res Function(UserLevel) _then) = _$UserLevelCopyWithImpl;
@useResult
$Res call({
 String name, String icon, int minPoints, int maxPoints, int currentPoints
});




}
/// @nodoc
class _$UserLevelCopyWithImpl<$Res>
    implements $UserLevelCopyWith<$Res> {
  _$UserLevelCopyWithImpl(this._self, this._then);

  final UserLevel _self;
  final $Res Function(UserLevel) _then;

/// Create a copy of UserLevel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? icon = null,Object? minPoints = null,Object? maxPoints = null,Object? currentPoints = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,minPoints: null == minPoints ? _self.minPoints : minPoints // ignore: cast_nullable_to_non_nullable
as int,maxPoints: null == maxPoints ? _self.maxPoints : maxPoints // ignore: cast_nullable_to_non_nullable
as int,currentPoints: null == currentPoints ? _self.currentPoints : currentPoints // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UserLevel].
extension UserLevelPatterns on UserLevel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserLevel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserLevel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserLevel value)  $default,){
final _that = this;
switch (_that) {
case _UserLevel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserLevel value)?  $default,){
final _that = this;
switch (_that) {
case _UserLevel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String icon,  int minPoints,  int maxPoints,  int currentPoints)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserLevel() when $default != null:
return $default(_that.name,_that.icon,_that.minPoints,_that.maxPoints,_that.currentPoints);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String icon,  int minPoints,  int maxPoints,  int currentPoints)  $default,) {final _that = this;
switch (_that) {
case _UserLevel():
return $default(_that.name,_that.icon,_that.minPoints,_that.maxPoints,_that.currentPoints);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String icon,  int minPoints,  int maxPoints,  int currentPoints)?  $default,) {final _that = this;
switch (_that) {
case _UserLevel() when $default != null:
return $default(_that.name,_that.icon,_that.minPoints,_that.maxPoints,_that.currentPoints);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserLevel extends UserLevel {
  const _UserLevel({required this.name, required this.icon, required this.minPoints, required this.maxPoints, required this.currentPoints}): super._();
  factory _UserLevel.fromJson(Map<String, dynamic> json) => _$UserLevelFromJson(json);

@override final  String name;
@override final  String icon;
@override final  int minPoints;
@override final  int maxPoints;
@override final  int currentPoints;

/// Create a copy of UserLevel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserLevelCopyWith<_UserLevel> get copyWith => __$UserLevelCopyWithImpl<_UserLevel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserLevelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserLevel&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.minPoints, minPoints) || other.minPoints == minPoints)&&(identical(other.maxPoints, maxPoints) || other.maxPoints == maxPoints)&&(identical(other.currentPoints, currentPoints) || other.currentPoints == currentPoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,icon,minPoints,maxPoints,currentPoints);

@override
String toString() {
  return 'UserLevel(name: $name, icon: $icon, minPoints: $minPoints, maxPoints: $maxPoints, currentPoints: $currentPoints)';
}


}

/// @nodoc
abstract mixin class _$UserLevelCopyWith<$Res> implements $UserLevelCopyWith<$Res> {
  factory _$UserLevelCopyWith(_UserLevel value, $Res Function(_UserLevel) _then) = __$UserLevelCopyWithImpl;
@override @useResult
$Res call({
 String name, String icon, int minPoints, int maxPoints, int currentPoints
});




}
/// @nodoc
class __$UserLevelCopyWithImpl<$Res>
    implements _$UserLevelCopyWith<$Res> {
  __$UserLevelCopyWithImpl(this._self, this._then);

  final _UserLevel _self;
  final $Res Function(_UserLevel) _then;

/// Create a copy of UserLevel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? icon = null,Object? minPoints = null,Object? maxPoints = null,Object? currentPoints = null,}) {
  return _then(_UserLevel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,minPoints: null == minPoints ? _self.minPoints : minPoints // ignore: cast_nullable_to_non_nullable
as int,maxPoints: null == maxPoints ? _self.maxPoints : maxPoints // ignore: cast_nullable_to_non_nullable
as int,currentPoints: null == currentPoints ? _self.currentPoints : currentPoints // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PointsTransaction {

 String get id; String get description; int get points; DateTime get timestamp; String get source; String? get relatedId;
/// Create a copy of PointsTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PointsTransactionCopyWith<PointsTransaction> get copyWith => _$PointsTransactionCopyWithImpl<PointsTransaction>(this as PointsTransaction, _$identity);

  /// Serializes this PointsTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PointsTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.points, points) || other.points == points)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.source, source) || other.source == source)&&(identical(other.relatedId, relatedId) || other.relatedId == relatedId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,points,timestamp,source,relatedId);

@override
String toString() {
  return 'PointsTransaction(id: $id, description: $description, points: $points, timestamp: $timestamp, source: $source, relatedId: $relatedId)';
}


}

/// @nodoc
abstract mixin class $PointsTransactionCopyWith<$Res>  {
  factory $PointsTransactionCopyWith(PointsTransaction value, $Res Function(PointsTransaction) _then) = _$PointsTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String description, int points, DateTime timestamp, String source, String? relatedId
});




}
/// @nodoc
class _$PointsTransactionCopyWithImpl<$Res>
    implements $PointsTransactionCopyWith<$Res> {
  _$PointsTransactionCopyWithImpl(this._self, this._then);

  final PointsTransaction _self;
  final $Res Function(PointsTransaction) _then;

/// Create a copy of PointsTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? description = null,Object? points = null,Object? timestamp = null,Object? source = null,Object? relatedId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,relatedId: freezed == relatedId ? _self.relatedId : relatedId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PointsTransaction].
extension PointsTransactionPatterns on PointsTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PointsTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PointsTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PointsTransaction value)  $default,){
final _that = this;
switch (_that) {
case _PointsTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PointsTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _PointsTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String description,  int points,  DateTime timestamp,  String source,  String? relatedId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PointsTransaction() when $default != null:
return $default(_that.id,_that.description,_that.points,_that.timestamp,_that.source,_that.relatedId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String description,  int points,  DateTime timestamp,  String source,  String? relatedId)  $default,) {final _that = this;
switch (_that) {
case _PointsTransaction():
return $default(_that.id,_that.description,_that.points,_that.timestamp,_that.source,_that.relatedId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String description,  int points,  DateTime timestamp,  String source,  String? relatedId)?  $default,) {final _that = this;
switch (_that) {
case _PointsTransaction() when $default != null:
return $default(_that.id,_that.description,_that.points,_that.timestamp,_that.source,_that.relatedId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PointsTransaction extends PointsTransaction {
  const _PointsTransaction({required this.id, required this.description, required this.points, required this.timestamp, required this.source, this.relatedId}): super._();
  factory _PointsTransaction.fromJson(Map<String, dynamic> json) => _$PointsTransactionFromJson(json);

@override final  String id;
@override final  String description;
@override final  int points;
@override final  DateTime timestamp;
@override final  String source;
@override final  String? relatedId;

/// Create a copy of PointsTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PointsTransactionCopyWith<_PointsTransaction> get copyWith => __$PointsTransactionCopyWithImpl<_PointsTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PointsTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PointsTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.points, points) || other.points == points)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.source, source) || other.source == source)&&(identical(other.relatedId, relatedId) || other.relatedId == relatedId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,points,timestamp,source,relatedId);

@override
String toString() {
  return 'PointsTransaction(id: $id, description: $description, points: $points, timestamp: $timestamp, source: $source, relatedId: $relatedId)';
}


}

/// @nodoc
abstract mixin class _$PointsTransactionCopyWith<$Res> implements $PointsTransactionCopyWith<$Res> {
  factory _$PointsTransactionCopyWith(_PointsTransaction value, $Res Function(_PointsTransaction) _then) = __$PointsTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, int points, DateTime timestamp, String source, String? relatedId
});




}
/// @nodoc
class __$PointsTransactionCopyWithImpl<$Res>
    implements _$PointsTransactionCopyWith<$Res> {
  __$PointsTransactionCopyWithImpl(this._self, this._then);

  final _PointsTransaction _self;
  final $Res Function(_PointsTransaction) _then;

/// Create a copy of PointsTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? points = null,Object? timestamp = null,Object? source = null,Object? relatedId = freezed,}) {
  return _then(_PointsTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,relatedId: freezed == relatedId ? _self.relatedId : relatedId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
