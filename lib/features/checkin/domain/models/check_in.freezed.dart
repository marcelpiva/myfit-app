// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckIn {

 String get id;// === Quem iniciou ===
 String get initiatorId; String get initiatorName; String? get initiatorAvatarUrl; CheckInInitiatorRole get initiatorRole;// === Alvos do check-in (pode ser múltiplos) ===
 List<CheckInTarget> get targets;// === Tipo e método ===
 CheckInType get type; CheckInMethod get method; CheckInSource get source;// === Organização principal ===
 String get organizationId; String get organizationName;// === Sessão vinculada (se aplicável) ===
 String? get sessionId; String? get classId;// === Treino vinculado ===
 String? get workoutId; String? get workoutName;// === Localização ===
 double? get latitude; double? get longitude;// === Status e timestamps ===
 CheckInStatus get status; DateTime get timestamp; DateTime? get confirmedAt; DateTime? get checkOutTime; int? get durationMinutes;// === Gamificação ===
 int get pointsEarned; List<String> get badgesEarned;// === Campos legados para compatibilidade ===
 String? get memberId; String? get memberName; String? get memberAvatarUrl; String? get trainerId; String? get trainerName;
/// Create a copy of CheckIn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInCopyWith<CheckIn> get copyWith => _$CheckInCopyWithImpl<CheckIn>(this as CheckIn, _$identity);

  /// Serializes this CheckIn to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckIn&&(identical(other.id, id) || other.id == id)&&(identical(other.initiatorId, initiatorId) || other.initiatorId == initiatorId)&&(identical(other.initiatorName, initiatorName) || other.initiatorName == initiatorName)&&(identical(other.initiatorAvatarUrl, initiatorAvatarUrl) || other.initiatorAvatarUrl == initiatorAvatarUrl)&&(identical(other.initiatorRole, initiatorRole) || other.initiatorRole == initiatorRole)&&const DeepCollectionEquality().equals(other.targets, targets)&&(identical(other.type, type) || other.type == type)&&(identical(other.method, method) || other.method == method)&&(identical(other.source, source) || other.source == source)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.organizationName, organizationName) || other.organizationName == organizationName)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.workoutName, workoutName) || other.workoutName == workoutName)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.status, status) || other.status == status)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.checkOutTime, checkOutTime) || other.checkOutTime == checkOutTime)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.pointsEarned, pointsEarned) || other.pointsEarned == pointsEarned)&&const DeepCollectionEquality().equals(other.badgesEarned, badgesEarned)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.memberAvatarUrl, memberAvatarUrl) || other.memberAvatarUrl == memberAvatarUrl)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.trainerName, trainerName) || other.trainerName == trainerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,initiatorId,initiatorName,initiatorAvatarUrl,initiatorRole,const DeepCollectionEquality().hash(targets),type,method,source,organizationId,organizationName,sessionId,classId,workoutId,workoutName,latitude,longitude,status,timestamp,confirmedAt,checkOutTime,durationMinutes,pointsEarned,const DeepCollectionEquality().hash(badgesEarned),memberId,memberName,memberAvatarUrl,trainerId,trainerName]);

@override
String toString() {
  return 'CheckIn(id: $id, initiatorId: $initiatorId, initiatorName: $initiatorName, initiatorAvatarUrl: $initiatorAvatarUrl, initiatorRole: $initiatorRole, targets: $targets, type: $type, method: $method, source: $source, organizationId: $organizationId, organizationName: $organizationName, sessionId: $sessionId, classId: $classId, workoutId: $workoutId, workoutName: $workoutName, latitude: $latitude, longitude: $longitude, status: $status, timestamp: $timestamp, confirmedAt: $confirmedAt, checkOutTime: $checkOutTime, durationMinutes: $durationMinutes, pointsEarned: $pointsEarned, badgesEarned: $badgesEarned, memberId: $memberId, memberName: $memberName, memberAvatarUrl: $memberAvatarUrl, trainerId: $trainerId, trainerName: $trainerName)';
}


}

/// @nodoc
abstract mixin class $CheckInCopyWith<$Res>  {
  factory $CheckInCopyWith(CheckIn value, $Res Function(CheckIn) _then) = _$CheckInCopyWithImpl;
@useResult
$Res call({
 String id, String initiatorId, String initiatorName, String? initiatorAvatarUrl, CheckInInitiatorRole initiatorRole, List<CheckInTarget> targets, CheckInType type, CheckInMethod method, CheckInSource source, String organizationId, String organizationName, String? sessionId, String? classId, String? workoutId, String? workoutName, double? latitude, double? longitude, CheckInStatus status, DateTime timestamp, DateTime? confirmedAt, DateTime? checkOutTime, int? durationMinutes, int pointsEarned, List<String> badgesEarned, String? memberId, String? memberName, String? memberAvatarUrl, String? trainerId, String? trainerName
});




}
/// @nodoc
class _$CheckInCopyWithImpl<$Res>
    implements $CheckInCopyWith<$Res> {
  _$CheckInCopyWithImpl(this._self, this._then);

  final CheckIn _self;
  final $Res Function(CheckIn) _then;

/// Create a copy of CheckIn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? initiatorId = null,Object? initiatorName = null,Object? initiatorAvatarUrl = freezed,Object? initiatorRole = null,Object? targets = null,Object? type = null,Object? method = null,Object? source = null,Object? organizationId = null,Object? organizationName = null,Object? sessionId = freezed,Object? classId = freezed,Object? workoutId = freezed,Object? workoutName = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? status = null,Object? timestamp = null,Object? confirmedAt = freezed,Object? checkOutTime = freezed,Object? durationMinutes = freezed,Object? pointsEarned = null,Object? badgesEarned = null,Object? memberId = freezed,Object? memberName = freezed,Object? memberAvatarUrl = freezed,Object? trainerId = freezed,Object? trainerName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,initiatorId: null == initiatorId ? _self.initiatorId : initiatorId // ignore: cast_nullable_to_non_nullable
as String,initiatorName: null == initiatorName ? _self.initiatorName : initiatorName // ignore: cast_nullable_to_non_nullable
as String,initiatorAvatarUrl: freezed == initiatorAvatarUrl ? _self.initiatorAvatarUrl : initiatorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,initiatorRole: null == initiatorRole ? _self.initiatorRole : initiatorRole // ignore: cast_nullable_to_non_nullable
as CheckInInitiatorRole,targets: null == targets ? _self.targets : targets // ignore: cast_nullable_to_non_nullable
as List<CheckInTarget>,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CheckInType,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as CheckInMethod,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as CheckInSource,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,organizationName: null == organizationName ? _self.organizationName : organizationName // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,classId: freezed == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String?,workoutId: freezed == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String?,workoutName: freezed == workoutName ? _self.workoutName : workoutName // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CheckInStatus,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,checkOutTime: freezed == checkOutTime ? _self.checkOutTime : checkOutTime // ignore: cast_nullable_to_non_nullable
as DateTime?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,pointsEarned: null == pointsEarned ? _self.pointsEarned : pointsEarned // ignore: cast_nullable_to_non_nullable
as int,badgesEarned: null == badgesEarned ? _self.badgesEarned : badgesEarned // ignore: cast_nullable_to_non_nullable
as List<String>,memberId: freezed == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String?,memberName: freezed == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String?,memberAvatarUrl: freezed == memberAvatarUrl ? _self.memberAvatarUrl : memberAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,trainerId: freezed == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String?,trainerName: freezed == trainerName ? _self.trainerName : trainerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckIn].
extension CheckInPatterns on CheckIn {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckIn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckIn() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckIn value)  $default,){
final _that = this;
switch (_that) {
case _CheckIn():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckIn value)?  $default,){
final _that = this;
switch (_that) {
case _CheckIn() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String initiatorId,  String initiatorName,  String? initiatorAvatarUrl,  CheckInInitiatorRole initiatorRole,  List<CheckInTarget> targets,  CheckInType type,  CheckInMethod method,  CheckInSource source,  String organizationId,  String organizationName,  String? sessionId,  String? classId,  String? workoutId,  String? workoutName,  double? latitude,  double? longitude,  CheckInStatus status,  DateTime timestamp,  DateTime? confirmedAt,  DateTime? checkOutTime,  int? durationMinutes,  int pointsEarned,  List<String> badgesEarned,  String? memberId,  String? memberName,  String? memberAvatarUrl,  String? trainerId,  String? trainerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckIn() when $default != null:
return $default(_that.id,_that.initiatorId,_that.initiatorName,_that.initiatorAvatarUrl,_that.initiatorRole,_that.targets,_that.type,_that.method,_that.source,_that.organizationId,_that.organizationName,_that.sessionId,_that.classId,_that.workoutId,_that.workoutName,_that.latitude,_that.longitude,_that.status,_that.timestamp,_that.confirmedAt,_that.checkOutTime,_that.durationMinutes,_that.pointsEarned,_that.badgesEarned,_that.memberId,_that.memberName,_that.memberAvatarUrl,_that.trainerId,_that.trainerName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String initiatorId,  String initiatorName,  String? initiatorAvatarUrl,  CheckInInitiatorRole initiatorRole,  List<CheckInTarget> targets,  CheckInType type,  CheckInMethod method,  CheckInSource source,  String organizationId,  String organizationName,  String? sessionId,  String? classId,  String? workoutId,  String? workoutName,  double? latitude,  double? longitude,  CheckInStatus status,  DateTime timestamp,  DateTime? confirmedAt,  DateTime? checkOutTime,  int? durationMinutes,  int pointsEarned,  List<String> badgesEarned,  String? memberId,  String? memberName,  String? memberAvatarUrl,  String? trainerId,  String? trainerName)  $default,) {final _that = this;
switch (_that) {
case _CheckIn():
return $default(_that.id,_that.initiatorId,_that.initiatorName,_that.initiatorAvatarUrl,_that.initiatorRole,_that.targets,_that.type,_that.method,_that.source,_that.organizationId,_that.organizationName,_that.sessionId,_that.classId,_that.workoutId,_that.workoutName,_that.latitude,_that.longitude,_that.status,_that.timestamp,_that.confirmedAt,_that.checkOutTime,_that.durationMinutes,_that.pointsEarned,_that.badgesEarned,_that.memberId,_that.memberName,_that.memberAvatarUrl,_that.trainerId,_that.trainerName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String initiatorId,  String initiatorName,  String? initiatorAvatarUrl,  CheckInInitiatorRole initiatorRole,  List<CheckInTarget> targets,  CheckInType type,  CheckInMethod method,  CheckInSource source,  String organizationId,  String organizationName,  String? sessionId,  String? classId,  String? workoutId,  String? workoutName,  double? latitude,  double? longitude,  CheckInStatus status,  DateTime timestamp,  DateTime? confirmedAt,  DateTime? checkOutTime,  int? durationMinutes,  int pointsEarned,  List<String> badgesEarned,  String? memberId,  String? memberName,  String? memberAvatarUrl,  String? trainerId,  String? trainerName)?  $default,) {final _that = this;
switch (_that) {
case _CheckIn() when $default != null:
return $default(_that.id,_that.initiatorId,_that.initiatorName,_that.initiatorAvatarUrl,_that.initiatorRole,_that.targets,_that.type,_that.method,_that.source,_that.organizationId,_that.organizationName,_that.sessionId,_that.classId,_that.workoutId,_that.workoutName,_that.latitude,_that.longitude,_that.status,_that.timestamp,_that.confirmedAt,_that.checkOutTime,_that.durationMinutes,_that.pointsEarned,_that.badgesEarned,_that.memberId,_that.memberName,_that.memberAvatarUrl,_that.trainerId,_that.trainerName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckIn extends CheckIn {
  const _CheckIn({required this.id, required this.initiatorId, required this.initiatorName, this.initiatorAvatarUrl, this.initiatorRole = CheckInInitiatorRole.student, final  List<CheckInTarget> targets = const [], this.type = CheckInType.freeTraining, this.method = CheckInMethod.qrCode, this.source = CheckInSource.appStudent, required this.organizationId, required this.organizationName, this.sessionId, this.classId, this.workoutId, this.workoutName, this.latitude, this.longitude, this.status = CheckInStatus.pending, required this.timestamp, this.confirmedAt, this.checkOutTime, this.durationMinutes, this.pointsEarned = 0, final  List<String> badgesEarned = const [], this.memberId, this.memberName, this.memberAvatarUrl, this.trainerId, this.trainerName}): _targets = targets,_badgesEarned = badgesEarned,super._();
  factory _CheckIn.fromJson(Map<String, dynamic> json) => _$CheckInFromJson(json);

@override final  String id;
// === Quem iniciou ===
@override final  String initiatorId;
@override final  String initiatorName;
@override final  String? initiatorAvatarUrl;
@override@JsonKey() final  CheckInInitiatorRole initiatorRole;
// === Alvos do check-in (pode ser múltiplos) ===
 final  List<CheckInTarget> _targets;
// === Alvos do check-in (pode ser múltiplos) ===
@override@JsonKey() List<CheckInTarget> get targets {
  if (_targets is EqualUnmodifiableListView) return _targets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targets);
}

// === Tipo e método ===
@override@JsonKey() final  CheckInType type;
@override@JsonKey() final  CheckInMethod method;
@override@JsonKey() final  CheckInSource source;
// === Organização principal ===
@override final  String organizationId;
@override final  String organizationName;
// === Sessão vinculada (se aplicável) ===
@override final  String? sessionId;
@override final  String? classId;
// === Treino vinculado ===
@override final  String? workoutId;
@override final  String? workoutName;
// === Localização ===
@override final  double? latitude;
@override final  double? longitude;
// === Status e timestamps ===
@override@JsonKey() final  CheckInStatus status;
@override final  DateTime timestamp;
@override final  DateTime? confirmedAt;
@override final  DateTime? checkOutTime;
@override final  int? durationMinutes;
// === Gamificação ===
@override@JsonKey() final  int pointsEarned;
 final  List<String> _badgesEarned;
@override@JsonKey() List<String> get badgesEarned {
  if (_badgesEarned is EqualUnmodifiableListView) return _badgesEarned;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badgesEarned);
}

// === Campos legados para compatibilidade ===
@override final  String? memberId;
@override final  String? memberName;
@override final  String? memberAvatarUrl;
@override final  String? trainerId;
@override final  String? trainerName;

/// Create a copy of CheckIn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckInCopyWith<_CheckIn> get copyWith => __$CheckInCopyWithImpl<_CheckIn>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckInToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckIn&&(identical(other.id, id) || other.id == id)&&(identical(other.initiatorId, initiatorId) || other.initiatorId == initiatorId)&&(identical(other.initiatorName, initiatorName) || other.initiatorName == initiatorName)&&(identical(other.initiatorAvatarUrl, initiatorAvatarUrl) || other.initiatorAvatarUrl == initiatorAvatarUrl)&&(identical(other.initiatorRole, initiatorRole) || other.initiatorRole == initiatorRole)&&const DeepCollectionEquality().equals(other._targets, _targets)&&(identical(other.type, type) || other.type == type)&&(identical(other.method, method) || other.method == method)&&(identical(other.source, source) || other.source == source)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.organizationName, organizationName) || other.organizationName == organizationName)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.workoutName, workoutName) || other.workoutName == workoutName)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.status, status) || other.status == status)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.checkOutTime, checkOutTime) || other.checkOutTime == checkOutTime)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.pointsEarned, pointsEarned) || other.pointsEarned == pointsEarned)&&const DeepCollectionEquality().equals(other._badgesEarned, _badgesEarned)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.memberAvatarUrl, memberAvatarUrl) || other.memberAvatarUrl == memberAvatarUrl)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.trainerName, trainerName) || other.trainerName == trainerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,initiatorId,initiatorName,initiatorAvatarUrl,initiatorRole,const DeepCollectionEquality().hash(_targets),type,method,source,organizationId,organizationName,sessionId,classId,workoutId,workoutName,latitude,longitude,status,timestamp,confirmedAt,checkOutTime,durationMinutes,pointsEarned,const DeepCollectionEquality().hash(_badgesEarned),memberId,memberName,memberAvatarUrl,trainerId,trainerName]);

@override
String toString() {
  return 'CheckIn(id: $id, initiatorId: $initiatorId, initiatorName: $initiatorName, initiatorAvatarUrl: $initiatorAvatarUrl, initiatorRole: $initiatorRole, targets: $targets, type: $type, method: $method, source: $source, organizationId: $organizationId, organizationName: $organizationName, sessionId: $sessionId, classId: $classId, workoutId: $workoutId, workoutName: $workoutName, latitude: $latitude, longitude: $longitude, status: $status, timestamp: $timestamp, confirmedAt: $confirmedAt, checkOutTime: $checkOutTime, durationMinutes: $durationMinutes, pointsEarned: $pointsEarned, badgesEarned: $badgesEarned, memberId: $memberId, memberName: $memberName, memberAvatarUrl: $memberAvatarUrl, trainerId: $trainerId, trainerName: $trainerName)';
}


}

/// @nodoc
abstract mixin class _$CheckInCopyWith<$Res> implements $CheckInCopyWith<$Res> {
  factory _$CheckInCopyWith(_CheckIn value, $Res Function(_CheckIn) _then) = __$CheckInCopyWithImpl;
@override @useResult
$Res call({
 String id, String initiatorId, String initiatorName, String? initiatorAvatarUrl, CheckInInitiatorRole initiatorRole, List<CheckInTarget> targets, CheckInType type, CheckInMethod method, CheckInSource source, String organizationId, String organizationName, String? sessionId, String? classId, String? workoutId, String? workoutName, double? latitude, double? longitude, CheckInStatus status, DateTime timestamp, DateTime? confirmedAt, DateTime? checkOutTime, int? durationMinutes, int pointsEarned, List<String> badgesEarned, String? memberId, String? memberName, String? memberAvatarUrl, String? trainerId, String? trainerName
});




}
/// @nodoc
class __$CheckInCopyWithImpl<$Res>
    implements _$CheckInCopyWith<$Res> {
  __$CheckInCopyWithImpl(this._self, this._then);

  final _CheckIn _self;
  final $Res Function(_CheckIn) _then;

/// Create a copy of CheckIn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? initiatorId = null,Object? initiatorName = null,Object? initiatorAvatarUrl = freezed,Object? initiatorRole = null,Object? targets = null,Object? type = null,Object? method = null,Object? source = null,Object? organizationId = null,Object? organizationName = null,Object? sessionId = freezed,Object? classId = freezed,Object? workoutId = freezed,Object? workoutName = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? status = null,Object? timestamp = null,Object? confirmedAt = freezed,Object? checkOutTime = freezed,Object? durationMinutes = freezed,Object? pointsEarned = null,Object? badgesEarned = null,Object? memberId = freezed,Object? memberName = freezed,Object? memberAvatarUrl = freezed,Object? trainerId = freezed,Object? trainerName = freezed,}) {
  return _then(_CheckIn(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,initiatorId: null == initiatorId ? _self.initiatorId : initiatorId // ignore: cast_nullable_to_non_nullable
as String,initiatorName: null == initiatorName ? _self.initiatorName : initiatorName // ignore: cast_nullable_to_non_nullable
as String,initiatorAvatarUrl: freezed == initiatorAvatarUrl ? _self.initiatorAvatarUrl : initiatorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,initiatorRole: null == initiatorRole ? _self.initiatorRole : initiatorRole // ignore: cast_nullable_to_non_nullable
as CheckInInitiatorRole,targets: null == targets ? _self._targets : targets // ignore: cast_nullable_to_non_nullable
as List<CheckInTarget>,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CheckInType,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as CheckInMethod,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as CheckInSource,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,organizationName: null == organizationName ? _self.organizationName : organizationName // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,classId: freezed == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String?,workoutId: freezed == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String?,workoutName: freezed == workoutName ? _self.workoutName : workoutName // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CheckInStatus,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,checkOutTime: freezed == checkOutTime ? _self.checkOutTime : checkOutTime // ignore: cast_nullable_to_non_nullable
as DateTime?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,pointsEarned: null == pointsEarned ? _self.pointsEarned : pointsEarned // ignore: cast_nullable_to_non_nullable
as int,badgesEarned: null == badgesEarned ? _self._badgesEarned : badgesEarned // ignore: cast_nullable_to_non_nullable
as List<String>,memberId: freezed == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String?,memberName: freezed == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String?,memberAvatarUrl: freezed == memberAvatarUrl ? _self.memberAvatarUrl : memberAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,trainerId: freezed == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String?,trainerName: freezed == trainerName ? _self.trainerName : trainerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CheckInStats {

 int get totalCheckIns; int get currentStreak; int get longestStreak; int get thisWeek; int get thisMonth; double get averageDuration; int get totalPoints;
/// Create a copy of CheckInStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInStatsCopyWith<CheckInStats> get copyWith => _$CheckInStatsCopyWithImpl<CheckInStats>(this as CheckInStats, _$identity);

  /// Serializes this CheckInStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInStats&&(identical(other.totalCheckIns, totalCheckIns) || other.totalCheckIns == totalCheckIns)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.thisWeek, thisWeek) || other.thisWeek == thisWeek)&&(identical(other.thisMonth, thisMonth) || other.thisMonth == thisMonth)&&(identical(other.averageDuration, averageDuration) || other.averageDuration == averageDuration)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCheckIns,currentStreak,longestStreak,thisWeek,thisMonth,averageDuration,totalPoints);

@override
String toString() {
  return 'CheckInStats(totalCheckIns: $totalCheckIns, currentStreak: $currentStreak, longestStreak: $longestStreak, thisWeek: $thisWeek, thisMonth: $thisMonth, averageDuration: $averageDuration, totalPoints: $totalPoints)';
}


}

/// @nodoc
abstract mixin class $CheckInStatsCopyWith<$Res>  {
  factory $CheckInStatsCopyWith(CheckInStats value, $Res Function(CheckInStats) _then) = _$CheckInStatsCopyWithImpl;
@useResult
$Res call({
 int totalCheckIns, int currentStreak, int longestStreak, int thisWeek, int thisMonth, double averageDuration, int totalPoints
});




}
/// @nodoc
class _$CheckInStatsCopyWithImpl<$Res>
    implements $CheckInStatsCopyWith<$Res> {
  _$CheckInStatsCopyWithImpl(this._self, this._then);

  final CheckInStats _self;
  final $Res Function(CheckInStats) _then;

/// Create a copy of CheckInStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCheckIns = null,Object? currentStreak = null,Object? longestStreak = null,Object? thisWeek = null,Object? thisMonth = null,Object? averageDuration = null,Object? totalPoints = null,}) {
  return _then(_self.copyWith(
totalCheckIns: null == totalCheckIns ? _self.totalCheckIns : totalCheckIns // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,thisWeek: null == thisWeek ? _self.thisWeek : thisWeek // ignore: cast_nullable_to_non_nullable
as int,thisMonth: null == thisMonth ? _self.thisMonth : thisMonth // ignore: cast_nullable_to_non_nullable
as int,averageDuration: null == averageDuration ? _self.averageDuration : averageDuration // ignore: cast_nullable_to_non_nullable
as double,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckInStats].
extension CheckInStatsPatterns on CheckInStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckInStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckInStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckInStats value)  $default,){
final _that = this;
switch (_that) {
case _CheckInStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckInStats value)?  $default,){
final _that = this;
switch (_that) {
case _CheckInStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalCheckIns,  int currentStreak,  int longestStreak,  int thisWeek,  int thisMonth,  double averageDuration,  int totalPoints)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckInStats() when $default != null:
return $default(_that.totalCheckIns,_that.currentStreak,_that.longestStreak,_that.thisWeek,_that.thisMonth,_that.averageDuration,_that.totalPoints);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalCheckIns,  int currentStreak,  int longestStreak,  int thisWeek,  int thisMonth,  double averageDuration,  int totalPoints)  $default,) {final _that = this;
switch (_that) {
case _CheckInStats():
return $default(_that.totalCheckIns,_that.currentStreak,_that.longestStreak,_that.thisWeek,_that.thisMonth,_that.averageDuration,_that.totalPoints);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalCheckIns,  int currentStreak,  int longestStreak,  int thisWeek,  int thisMonth,  double averageDuration,  int totalPoints)?  $default,) {final _that = this;
switch (_that) {
case _CheckInStats() when $default != null:
return $default(_that.totalCheckIns,_that.currentStreak,_that.longestStreak,_that.thisWeek,_that.thisMonth,_that.averageDuration,_that.totalPoints);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckInStats extends CheckInStats {
  const _CheckInStats({required this.totalCheckIns, required this.currentStreak, required this.longestStreak, required this.thisWeek, required this.thisMonth, required this.averageDuration, required this.totalPoints}): super._();
  factory _CheckInStats.fromJson(Map<String, dynamic> json) => _$CheckInStatsFromJson(json);

@override final  int totalCheckIns;
@override final  int currentStreak;
@override final  int longestStreak;
@override final  int thisWeek;
@override final  int thisMonth;
@override final  double averageDuration;
@override final  int totalPoints;

/// Create a copy of CheckInStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckInStatsCopyWith<_CheckInStats> get copyWith => __$CheckInStatsCopyWithImpl<_CheckInStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckInStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckInStats&&(identical(other.totalCheckIns, totalCheckIns) || other.totalCheckIns == totalCheckIns)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.thisWeek, thisWeek) || other.thisWeek == thisWeek)&&(identical(other.thisMonth, thisMonth) || other.thisMonth == thisMonth)&&(identical(other.averageDuration, averageDuration) || other.averageDuration == averageDuration)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCheckIns,currentStreak,longestStreak,thisWeek,thisMonth,averageDuration,totalPoints);

@override
String toString() {
  return 'CheckInStats(totalCheckIns: $totalCheckIns, currentStreak: $currentStreak, longestStreak: $longestStreak, thisWeek: $thisWeek, thisMonth: $thisMonth, averageDuration: $averageDuration, totalPoints: $totalPoints)';
}


}

/// @nodoc
abstract mixin class _$CheckInStatsCopyWith<$Res> implements $CheckInStatsCopyWith<$Res> {
  factory _$CheckInStatsCopyWith(_CheckInStats value, $Res Function(_CheckInStats) _then) = __$CheckInStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalCheckIns, int currentStreak, int longestStreak, int thisWeek, int thisMonth, double averageDuration, int totalPoints
});




}
/// @nodoc
class __$CheckInStatsCopyWithImpl<$Res>
    implements _$CheckInStatsCopyWith<$Res> {
  __$CheckInStatsCopyWithImpl(this._self, this._then);

  final _CheckInStats _self;
  final $Res Function(_CheckInStats) _then;

/// Create a copy of CheckInStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCheckIns = null,Object? currentStreak = null,Object? longestStreak = null,Object? thisWeek = null,Object? thisMonth = null,Object? averageDuration = null,Object? totalPoints = null,}) {
  return _then(_CheckInStats(
totalCheckIns: null == totalCheckIns ? _self.totalCheckIns : totalCheckIns // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,thisWeek: null == thisWeek ? _self.thisWeek : thisWeek // ignore: cast_nullable_to_non_nullable
as int,thisMonth: null == thisMonth ? _self.thisMonth : thisMonth // ignore: cast_nullable_to_non_nullable
as int,averageDuration: null == averageDuration ? _self.averageDuration : averageDuration // ignore: cast_nullable_to_non_nullable
as double,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GymLocation {

 String get id; String get name; double get latitude; double get longitude; double get radiusMeters; String? get address;
/// Create a copy of GymLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymLocationCopyWith<GymLocation> get copyWith => _$GymLocationCopyWithImpl<GymLocation>(this as GymLocation, _$identity);

  /// Serializes this GymLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GymLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.radiusMeters, radiusMeters) || other.radiusMeters == radiusMeters)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,latitude,longitude,radiusMeters,address);

@override
String toString() {
  return 'GymLocation(id: $id, name: $name, latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters, address: $address)';
}


}

/// @nodoc
abstract mixin class $GymLocationCopyWith<$Res>  {
  factory $GymLocationCopyWith(GymLocation value, $Res Function(GymLocation) _then) = _$GymLocationCopyWithImpl;
@useResult
$Res call({
 String id, String name, double latitude, double longitude, double radiusMeters, String? address
});




}
/// @nodoc
class _$GymLocationCopyWithImpl<$Res>
    implements $GymLocationCopyWith<$Res> {
  _$GymLocationCopyWithImpl(this._self, this._then);

  final GymLocation _self;
  final $Res Function(GymLocation) _then;

/// Create a copy of GymLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? latitude = null,Object? longitude = null,Object? radiusMeters = null,Object? address = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,radiusMeters: null == radiusMeters ? _self.radiusMeters : radiusMeters // ignore: cast_nullable_to_non_nullable
as double,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GymLocation].
extension GymLocationPatterns on GymLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GymLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GymLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GymLocation value)  $default,){
final _that = this;
switch (_that) {
case _GymLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GymLocation value)?  $default,){
final _that = this;
switch (_that) {
case _GymLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double latitude,  double longitude,  double radiusMeters,  String? address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GymLocation() when $default != null:
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.radiusMeters,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double latitude,  double longitude,  double radiusMeters,  String? address)  $default,) {final _that = this;
switch (_that) {
case _GymLocation():
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.radiusMeters,_that.address);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double latitude,  double longitude,  double radiusMeters,  String? address)?  $default,) {final _that = this;
switch (_that) {
case _GymLocation() when $default != null:
return $default(_that.id,_that.name,_that.latitude,_that.longitude,_that.radiusMeters,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GymLocation extends GymLocation {
  const _GymLocation({required this.id, required this.name, required this.latitude, required this.longitude, required this.radiusMeters, this.address}): super._();
  factory _GymLocation.fromJson(Map<String, dynamic> json) => _$GymLocationFromJson(json);

@override final  String id;
@override final  String name;
@override final  double latitude;
@override final  double longitude;
@override final  double radiusMeters;
@override final  String? address;

/// Create a copy of GymLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymLocationCopyWith<_GymLocation> get copyWith => __$GymLocationCopyWithImpl<_GymLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GymLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.radiusMeters, radiusMeters) || other.radiusMeters == radiusMeters)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,latitude,longitude,radiusMeters,address);

@override
String toString() {
  return 'GymLocation(id: $id, name: $name, latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters, address: $address)';
}


}

/// @nodoc
abstract mixin class _$GymLocationCopyWith<$Res> implements $GymLocationCopyWith<$Res> {
  factory _$GymLocationCopyWith(_GymLocation value, $Res Function(_GymLocation) _then) = __$GymLocationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double latitude, double longitude, double radiusMeters, String? address
});




}
/// @nodoc
class __$GymLocationCopyWithImpl<$Res>
    implements _$GymLocationCopyWith<$Res> {
  __$GymLocationCopyWithImpl(this._self, this._then);

  final _GymLocation _self;
  final $Res Function(_GymLocation) _then;

/// Create a copy of GymLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? latitude = null,Object? longitude = null,Object? radiusMeters = null,Object? address = freezed,}) {
  return _then(_GymLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,radiusMeters: null == radiusMeters ? _self.radiusMeters : radiusMeters // ignore: cast_nullable_to_non_nullable
as double,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
