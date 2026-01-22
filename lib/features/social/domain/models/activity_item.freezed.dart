// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActivityItem {

 String get id; ActivityType get type; String get userId; String get userName; String? get userAvatarUrl; DateTime get timestamp; Map<String, dynamic> get data; int get reactions; bool get hasReacted; List<String> get comments;
/// Create a copy of ActivityItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityItemCopyWith<ActivityItem> get copyWith => _$ActivityItemCopyWithImpl<ActivityItem>(this as ActivityItem, _$identity);

  /// Serializes this ActivityItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatarUrl, userAvatarUrl) || other.userAvatarUrl == userAvatarUrl)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.reactions, reactions) || other.reactions == reactions)&&(identical(other.hasReacted, hasReacted) || other.hasReacted == hasReacted)&&const DeepCollectionEquality().equals(other.comments, comments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,userId,userName,userAvatarUrl,timestamp,const DeepCollectionEquality().hash(data),reactions,hasReacted,const DeepCollectionEquality().hash(comments));

@override
String toString() {
  return 'ActivityItem(id: $id, type: $type, userId: $userId, userName: $userName, userAvatarUrl: $userAvatarUrl, timestamp: $timestamp, data: $data, reactions: $reactions, hasReacted: $hasReacted, comments: $comments)';
}


}

/// @nodoc
abstract mixin class $ActivityItemCopyWith<$Res>  {
  factory $ActivityItemCopyWith(ActivityItem value, $Res Function(ActivityItem) _then) = _$ActivityItemCopyWithImpl;
@useResult
$Res call({
 String id, ActivityType type, String userId, String userName, String? userAvatarUrl, DateTime timestamp, Map<String, dynamic> data, int reactions, bool hasReacted, List<String> comments
});




}
/// @nodoc
class _$ActivityItemCopyWithImpl<$Res>
    implements $ActivityItemCopyWith<$Res> {
  _$ActivityItemCopyWithImpl(this._self, this._then);

  final ActivityItem _self;
  final $Res Function(ActivityItem) _then;

/// Create a copy of ActivityItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? userId = null,Object? userName = null,Object? userAvatarUrl = freezed,Object? timestamp = null,Object? data = null,Object? reactions = null,Object? hasReacted = null,Object? comments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ActivityType,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatarUrl: freezed == userAvatarUrl ? _self.userAvatarUrl : userAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as int,hasReacted: null == hasReacted ? _self.hasReacted : hasReacted // ignore: cast_nullable_to_non_nullable
as bool,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityItem].
extension ActivityItemPatterns on ActivityItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityItem value)  $default,){
final _that = this;
switch (_that) {
case _ActivityItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityItem value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ActivityType type,  String userId,  String userName,  String? userAvatarUrl,  DateTime timestamp,  Map<String, dynamic> data,  int reactions,  bool hasReacted,  List<String> comments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityItem() when $default != null:
return $default(_that.id,_that.type,_that.userId,_that.userName,_that.userAvatarUrl,_that.timestamp,_that.data,_that.reactions,_that.hasReacted,_that.comments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ActivityType type,  String userId,  String userName,  String? userAvatarUrl,  DateTime timestamp,  Map<String, dynamic> data,  int reactions,  bool hasReacted,  List<String> comments)  $default,) {final _that = this;
switch (_that) {
case _ActivityItem():
return $default(_that.id,_that.type,_that.userId,_that.userName,_that.userAvatarUrl,_that.timestamp,_that.data,_that.reactions,_that.hasReacted,_that.comments);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ActivityType type,  String userId,  String userName,  String? userAvatarUrl,  DateTime timestamp,  Map<String, dynamic> data,  int reactions,  bool hasReacted,  List<String> comments)?  $default,) {final _that = this;
switch (_that) {
case _ActivityItem() when $default != null:
return $default(_that.id,_that.type,_that.userId,_that.userName,_that.userAvatarUrl,_that.timestamp,_that.data,_that.reactions,_that.hasReacted,_that.comments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityItem extends ActivityItem {
  const _ActivityItem({required this.id, required this.type, required this.userId, required this.userName, this.userAvatarUrl, required this.timestamp, required final  Map<String, dynamic> data, this.reactions = 0, this.hasReacted = false, final  List<String> comments = const []}): _data = data,_comments = comments,super._();
  factory _ActivityItem.fromJson(Map<String, dynamic> json) => _$ActivityItemFromJson(json);

@override final  String id;
@override final  ActivityType type;
@override final  String userId;
@override final  String userName;
@override final  String? userAvatarUrl;
@override final  DateTime timestamp;
 final  Map<String, dynamic> _data;
@override Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}

@override@JsonKey() final  int reactions;
@override@JsonKey() final  bool hasReacted;
 final  List<String> _comments;
@override@JsonKey() List<String> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}


/// Create a copy of ActivityItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityItemCopyWith<_ActivityItem> get copyWith => __$ActivityItemCopyWithImpl<_ActivityItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatarUrl, userAvatarUrl) || other.userAvatarUrl == userAvatarUrl)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.reactions, reactions) || other.reactions == reactions)&&(identical(other.hasReacted, hasReacted) || other.hasReacted == hasReacted)&&const DeepCollectionEquality().equals(other._comments, _comments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,userId,userName,userAvatarUrl,timestamp,const DeepCollectionEquality().hash(_data),reactions,hasReacted,const DeepCollectionEquality().hash(_comments));

@override
String toString() {
  return 'ActivityItem(id: $id, type: $type, userId: $userId, userName: $userName, userAvatarUrl: $userAvatarUrl, timestamp: $timestamp, data: $data, reactions: $reactions, hasReacted: $hasReacted, comments: $comments)';
}


}

/// @nodoc
abstract mixin class _$ActivityItemCopyWith<$Res> implements $ActivityItemCopyWith<$Res> {
  factory _$ActivityItemCopyWith(_ActivityItem value, $Res Function(_ActivityItem) _then) = __$ActivityItemCopyWithImpl;
@override @useResult
$Res call({
 String id, ActivityType type, String userId, String userName, String? userAvatarUrl, DateTime timestamp, Map<String, dynamic> data, int reactions, bool hasReacted, List<String> comments
});




}
/// @nodoc
class __$ActivityItemCopyWithImpl<$Res>
    implements _$ActivityItemCopyWith<$Res> {
  __$ActivityItemCopyWithImpl(this._self, this._then);

  final _ActivityItem _self;
  final $Res Function(_ActivityItem) _then;

/// Create a copy of ActivityItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? userId = null,Object? userName = null,Object? userAvatarUrl = freezed,Object? timestamp = null,Object? data = null,Object? reactions = null,Object? hasReacted = null,Object? comments = null,}) {
  return _then(_ActivityItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ActivityType,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatarUrl: freezed == userAvatarUrl ? _self.userAvatarUrl : userAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as int,hasReacted: null == hasReacted ? _self.hasReacted : hasReacted // ignore: cast_nullable_to_non_nullable
as bool,comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
