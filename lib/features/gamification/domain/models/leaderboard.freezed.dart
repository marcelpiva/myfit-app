// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeaderboardEntry {

 int get rank; String get memberId; String get memberName; String? get memberAvatarUrl; int get points; int get checkIns; int get workoutsCompleted; int? get rankChange; String? get levelIcon; String? get levelName;
/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith => _$LeaderboardEntryCopyWithImpl<LeaderboardEntry>(this as LeaderboardEntry, _$identity);

  /// Serializes this LeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaderboardEntry&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.memberAvatarUrl, memberAvatarUrl) || other.memberAvatarUrl == memberAvatarUrl)&&(identical(other.points, points) || other.points == points)&&(identical(other.checkIns, checkIns) || other.checkIns == checkIns)&&(identical(other.workoutsCompleted, workoutsCompleted) || other.workoutsCompleted == workoutsCompleted)&&(identical(other.rankChange, rankChange) || other.rankChange == rankChange)&&(identical(other.levelIcon, levelIcon) || other.levelIcon == levelIcon)&&(identical(other.levelName, levelName) || other.levelName == levelName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,memberId,memberName,memberAvatarUrl,points,checkIns,workoutsCompleted,rankChange,levelIcon,levelName);

@override
String toString() {
  return 'LeaderboardEntry(rank: $rank, memberId: $memberId, memberName: $memberName, memberAvatarUrl: $memberAvatarUrl, points: $points, checkIns: $checkIns, workoutsCompleted: $workoutsCompleted, rankChange: $rankChange, levelIcon: $levelIcon, levelName: $levelName)';
}


}

/// @nodoc
abstract mixin class $LeaderboardEntryCopyWith<$Res>  {
  factory $LeaderboardEntryCopyWith(LeaderboardEntry value, $Res Function(LeaderboardEntry) _then) = _$LeaderboardEntryCopyWithImpl;
@useResult
$Res call({
 int rank, String memberId, String memberName, String? memberAvatarUrl, int points, int checkIns, int workoutsCompleted, int? rankChange, String? levelIcon, String? levelName
});




}
/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._self, this._then);

  final LeaderboardEntry _self;
  final $Res Function(LeaderboardEntry) _then;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? memberId = null,Object? memberName = null,Object? memberAvatarUrl = freezed,Object? points = null,Object? checkIns = null,Object? workoutsCompleted = null,Object? rankChange = freezed,Object? levelIcon = freezed,Object? levelName = freezed,}) {
  return _then(_self.copyWith(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,memberAvatarUrl: freezed == memberAvatarUrl ? _self.memberAvatarUrl : memberAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,checkIns: null == checkIns ? _self.checkIns : checkIns // ignore: cast_nullable_to_non_nullable
as int,workoutsCompleted: null == workoutsCompleted ? _self.workoutsCompleted : workoutsCompleted // ignore: cast_nullable_to_non_nullable
as int,rankChange: freezed == rankChange ? _self.rankChange : rankChange // ignore: cast_nullable_to_non_nullable
as int?,levelIcon: freezed == levelIcon ? _self.levelIcon : levelIcon // ignore: cast_nullable_to_non_nullable
as String?,levelName: freezed == levelName ? _self.levelName : levelName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaderboardEntry].
extension LeaderboardEntryPatterns on LeaderboardEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaderboardEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaderboardEntry value)  $default,){
final _that = this;
switch (_that) {
case _LeaderboardEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaderboardEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rank,  String memberId,  String memberName,  String? memberAvatarUrl,  int points,  int checkIns,  int workoutsCompleted,  int? rankChange,  String? levelIcon,  String? levelName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that.rank,_that.memberId,_that.memberName,_that.memberAvatarUrl,_that.points,_that.checkIns,_that.workoutsCompleted,_that.rankChange,_that.levelIcon,_that.levelName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rank,  String memberId,  String memberName,  String? memberAvatarUrl,  int points,  int checkIns,  int workoutsCompleted,  int? rankChange,  String? levelIcon,  String? levelName)  $default,) {final _that = this;
switch (_that) {
case _LeaderboardEntry():
return $default(_that.rank,_that.memberId,_that.memberName,_that.memberAvatarUrl,_that.points,_that.checkIns,_that.workoutsCompleted,_that.rankChange,_that.levelIcon,_that.levelName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rank,  String memberId,  String memberName,  String? memberAvatarUrl,  int points,  int checkIns,  int workoutsCompleted,  int? rankChange,  String? levelIcon,  String? levelName)?  $default,) {final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that.rank,_that.memberId,_that.memberName,_that.memberAvatarUrl,_that.points,_that.checkIns,_that.workoutsCompleted,_that.rankChange,_that.levelIcon,_that.levelName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaderboardEntry extends LeaderboardEntry {
  const _LeaderboardEntry({required this.rank, required this.memberId, required this.memberName, this.memberAvatarUrl, required this.points, required this.checkIns, required this.workoutsCompleted, this.rankChange, this.levelIcon, this.levelName}): super._();
  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);

@override final  int rank;
@override final  String memberId;
@override final  String memberName;
@override final  String? memberAvatarUrl;
@override final  int points;
@override final  int checkIns;
@override final  int workoutsCompleted;
@override final  int? rankChange;
@override final  String? levelIcon;
@override final  String? levelName;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaderboardEntryCopyWith<_LeaderboardEntry> get copyWith => __$LeaderboardEntryCopyWithImpl<_LeaderboardEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaderboardEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaderboardEntry&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.memberAvatarUrl, memberAvatarUrl) || other.memberAvatarUrl == memberAvatarUrl)&&(identical(other.points, points) || other.points == points)&&(identical(other.checkIns, checkIns) || other.checkIns == checkIns)&&(identical(other.workoutsCompleted, workoutsCompleted) || other.workoutsCompleted == workoutsCompleted)&&(identical(other.rankChange, rankChange) || other.rankChange == rankChange)&&(identical(other.levelIcon, levelIcon) || other.levelIcon == levelIcon)&&(identical(other.levelName, levelName) || other.levelName == levelName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,memberId,memberName,memberAvatarUrl,points,checkIns,workoutsCompleted,rankChange,levelIcon,levelName);

@override
String toString() {
  return 'LeaderboardEntry(rank: $rank, memberId: $memberId, memberName: $memberName, memberAvatarUrl: $memberAvatarUrl, points: $points, checkIns: $checkIns, workoutsCompleted: $workoutsCompleted, rankChange: $rankChange, levelIcon: $levelIcon, levelName: $levelName)';
}


}

/// @nodoc
abstract mixin class _$LeaderboardEntryCopyWith<$Res> implements $LeaderboardEntryCopyWith<$Res> {
  factory _$LeaderboardEntryCopyWith(_LeaderboardEntry value, $Res Function(_LeaderboardEntry) _then) = __$LeaderboardEntryCopyWithImpl;
@override @useResult
$Res call({
 int rank, String memberId, String memberName, String? memberAvatarUrl, int points, int checkIns, int workoutsCompleted, int? rankChange, String? levelIcon, String? levelName
});




}
/// @nodoc
class __$LeaderboardEntryCopyWithImpl<$Res>
    implements _$LeaderboardEntryCopyWith<$Res> {
  __$LeaderboardEntryCopyWithImpl(this._self, this._then);

  final _LeaderboardEntry _self;
  final $Res Function(_LeaderboardEntry) _then;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? memberId = null,Object? memberName = null,Object? memberAvatarUrl = freezed,Object? points = null,Object? checkIns = null,Object? workoutsCompleted = null,Object? rankChange = freezed,Object? levelIcon = freezed,Object? levelName = freezed,}) {
  return _then(_LeaderboardEntry(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,memberAvatarUrl: freezed == memberAvatarUrl ? _self.memberAvatarUrl : memberAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,checkIns: null == checkIns ? _self.checkIns : checkIns // ignore: cast_nullable_to_non_nullable
as int,workoutsCompleted: null == workoutsCompleted ? _self.workoutsCompleted : workoutsCompleted // ignore: cast_nullable_to_non_nullable
as int,rankChange: freezed == rankChange ? _self.rankChange : rankChange // ignore: cast_nullable_to_non_nullable
as int?,levelIcon: freezed == levelIcon ? _self.levelIcon : levelIcon // ignore: cast_nullable_to_non_nullable
as String?,levelName: freezed == levelName ? _self.levelName : levelName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Leaderboard {

 LeaderboardPeriod get period; List<LeaderboardEntry> get entries; LeaderboardEntry? get currentUserEntry; DateTime get updatedAt;
/// Create a copy of Leaderboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderboardCopyWith<Leaderboard> get copyWith => _$LeaderboardCopyWithImpl<Leaderboard>(this as Leaderboard, _$identity);

  /// Serializes this Leaderboard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Leaderboard&&(identical(other.period, period) || other.period == period)&&const DeepCollectionEquality().equals(other.entries, entries)&&(identical(other.currentUserEntry, currentUserEntry) || other.currentUserEntry == currentUserEntry)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,const DeepCollectionEquality().hash(entries),currentUserEntry,updatedAt);

@override
String toString() {
  return 'Leaderboard(period: $period, entries: $entries, currentUserEntry: $currentUserEntry, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $LeaderboardCopyWith<$Res>  {
  factory $LeaderboardCopyWith(Leaderboard value, $Res Function(Leaderboard) _then) = _$LeaderboardCopyWithImpl;
@useResult
$Res call({
 LeaderboardPeriod period, List<LeaderboardEntry> entries, LeaderboardEntry? currentUserEntry, DateTime updatedAt
});


$LeaderboardEntryCopyWith<$Res>? get currentUserEntry;

}
/// @nodoc
class _$LeaderboardCopyWithImpl<$Res>
    implements $LeaderboardCopyWith<$Res> {
  _$LeaderboardCopyWithImpl(this._self, this._then);

  final Leaderboard _self;
  final $Res Function(Leaderboard) _then;

/// Create a copy of Leaderboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? entries = null,Object? currentUserEntry = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as LeaderboardPeriod,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<LeaderboardEntry>,currentUserEntry: freezed == currentUserEntry ? _self.currentUserEntry : currentUserEntry // ignore: cast_nullable_to_non_nullable
as LeaderboardEntry?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Leaderboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeaderboardEntryCopyWith<$Res>? get currentUserEntry {
    if (_self.currentUserEntry == null) {
    return null;
  }

  return $LeaderboardEntryCopyWith<$Res>(_self.currentUserEntry!, (value) {
    return _then(_self.copyWith(currentUserEntry: value));
  });
}
}


/// Adds pattern-matching-related methods to [Leaderboard].
extension LeaderboardPatterns on Leaderboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Leaderboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Leaderboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Leaderboard value)  $default,){
final _that = this;
switch (_that) {
case _Leaderboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Leaderboard value)?  $default,){
final _that = this;
switch (_that) {
case _Leaderboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LeaderboardPeriod period,  List<LeaderboardEntry> entries,  LeaderboardEntry? currentUserEntry,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Leaderboard() when $default != null:
return $default(_that.period,_that.entries,_that.currentUserEntry,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LeaderboardPeriod period,  List<LeaderboardEntry> entries,  LeaderboardEntry? currentUserEntry,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Leaderboard():
return $default(_that.period,_that.entries,_that.currentUserEntry,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LeaderboardPeriod period,  List<LeaderboardEntry> entries,  LeaderboardEntry? currentUserEntry,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Leaderboard() when $default != null:
return $default(_that.period,_that.entries,_that.currentUserEntry,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Leaderboard extends Leaderboard {
  const _Leaderboard({required this.period, required final  List<LeaderboardEntry> entries, this.currentUserEntry, required this.updatedAt}): _entries = entries,super._();
  factory _Leaderboard.fromJson(Map<String, dynamic> json) => _$LeaderboardFromJson(json);

@override final  LeaderboardPeriod period;
 final  List<LeaderboardEntry> _entries;
@override List<LeaderboardEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override final  LeaderboardEntry? currentUserEntry;
@override final  DateTime updatedAt;

/// Create a copy of Leaderboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaderboardCopyWith<_Leaderboard> get copyWith => __$LeaderboardCopyWithImpl<_Leaderboard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaderboardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Leaderboard&&(identical(other.period, period) || other.period == period)&&const DeepCollectionEquality().equals(other._entries, _entries)&&(identical(other.currentUserEntry, currentUserEntry) || other.currentUserEntry == currentUserEntry)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,const DeepCollectionEquality().hash(_entries),currentUserEntry,updatedAt);

@override
String toString() {
  return 'Leaderboard(period: $period, entries: $entries, currentUserEntry: $currentUserEntry, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$LeaderboardCopyWith<$Res> implements $LeaderboardCopyWith<$Res> {
  factory _$LeaderboardCopyWith(_Leaderboard value, $Res Function(_Leaderboard) _then) = __$LeaderboardCopyWithImpl;
@override @useResult
$Res call({
 LeaderboardPeriod period, List<LeaderboardEntry> entries, LeaderboardEntry? currentUserEntry, DateTime updatedAt
});


@override $LeaderboardEntryCopyWith<$Res>? get currentUserEntry;

}
/// @nodoc
class __$LeaderboardCopyWithImpl<$Res>
    implements _$LeaderboardCopyWith<$Res> {
  __$LeaderboardCopyWithImpl(this._self, this._then);

  final _Leaderboard _self;
  final $Res Function(_Leaderboard) _then;

/// Create a copy of Leaderboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? entries = null,Object? currentUserEntry = freezed,Object? updatedAt = null,}) {
  return _then(_Leaderboard(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as LeaderboardPeriod,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<LeaderboardEntry>,currentUserEntry: freezed == currentUserEntry ? _self.currentUserEntry : currentUserEntry // ignore: cast_nullable_to_non_nullable
as LeaderboardEntry?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Leaderboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeaderboardEntryCopyWith<$Res>? get currentUserEntry {
    if (_self.currentUserEntry == null) {
    return null;
  }

  return $LeaderboardEntryCopyWith<$Res>(_self.currentUserEntry!, (value) {
    return _then(_self.copyWith(currentUserEntry: value));
  });
}
}

// dart format on
