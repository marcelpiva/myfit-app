// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkin_target.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckInTarget {

 String get id; CheckInTargetType get type; String get name; String? get avatarUrl; String? get subtitle;/// Se este alvo requer confirmação bilateral
 bool get requiresConfirmation;/// Se já foi confirmado
 bool get confirmed;/// Quando foi confirmado
 DateTime? get confirmedAt;/// ID de quem confirmou
 String? get confirmedBy;
/// Create a copy of CheckInTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInTargetCopyWith<CheckInTarget> get copyWith => _$CheckInTargetCopyWithImpl<CheckInTarget>(this as CheckInTarget, _$identity);

  /// Serializes this CheckInTarget to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInTarget&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.requiresConfirmation, requiresConfirmation) || other.requiresConfirmation == requiresConfirmation)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.confirmedBy, confirmedBy) || other.confirmedBy == confirmedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,avatarUrl,subtitle,requiresConfirmation,confirmed,confirmedAt,confirmedBy);

@override
String toString() {
  return 'CheckInTarget(id: $id, type: $type, name: $name, avatarUrl: $avatarUrl, subtitle: $subtitle, requiresConfirmation: $requiresConfirmation, confirmed: $confirmed, confirmedAt: $confirmedAt, confirmedBy: $confirmedBy)';
}


}

/// @nodoc
abstract mixin class $CheckInTargetCopyWith<$Res>  {
  factory $CheckInTargetCopyWith(CheckInTarget value, $Res Function(CheckInTarget) _then) = _$CheckInTargetCopyWithImpl;
@useResult
$Res call({
 String id, CheckInTargetType type, String name, String? avatarUrl, String? subtitle, bool requiresConfirmation, bool confirmed, DateTime? confirmedAt, String? confirmedBy
});




}
/// @nodoc
class _$CheckInTargetCopyWithImpl<$Res>
    implements $CheckInTargetCopyWith<$Res> {
  _$CheckInTargetCopyWithImpl(this._self, this._then);

  final CheckInTarget _self;
  final $Res Function(CheckInTarget) _then;

/// Create a copy of CheckInTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? avatarUrl = freezed,Object? subtitle = freezed,Object? requiresConfirmation = null,Object? confirmed = null,Object? confirmedAt = freezed,Object? confirmedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CheckInTargetType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,requiresConfirmation: null == requiresConfirmation ? _self.requiresConfirmation : requiresConfirmation // ignore: cast_nullable_to_non_nullable
as bool,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as bool,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,confirmedBy: freezed == confirmedBy ? _self.confirmedBy : confirmedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckInTarget].
extension CheckInTargetPatterns on CheckInTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckInTarget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckInTarget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckInTarget value)  $default,){
final _that = this;
switch (_that) {
case _CheckInTarget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckInTarget value)?  $default,){
final _that = this;
switch (_that) {
case _CheckInTarget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  CheckInTargetType type,  String name,  String? avatarUrl,  String? subtitle,  bool requiresConfirmation,  bool confirmed,  DateTime? confirmedAt,  String? confirmedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckInTarget() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.avatarUrl,_that.subtitle,_that.requiresConfirmation,_that.confirmed,_that.confirmedAt,_that.confirmedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  CheckInTargetType type,  String name,  String? avatarUrl,  String? subtitle,  bool requiresConfirmation,  bool confirmed,  DateTime? confirmedAt,  String? confirmedBy)  $default,) {final _that = this;
switch (_that) {
case _CheckInTarget():
return $default(_that.id,_that.type,_that.name,_that.avatarUrl,_that.subtitle,_that.requiresConfirmation,_that.confirmed,_that.confirmedAt,_that.confirmedBy);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  CheckInTargetType type,  String name,  String? avatarUrl,  String? subtitle,  bool requiresConfirmation,  bool confirmed,  DateTime? confirmedAt,  String? confirmedBy)?  $default,) {final _that = this;
switch (_that) {
case _CheckInTarget() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.avatarUrl,_that.subtitle,_that.requiresConfirmation,_that.confirmed,_that.confirmedAt,_that.confirmedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckInTarget extends CheckInTarget {
  const _CheckInTarget({required this.id, required this.type, required this.name, this.avatarUrl, this.subtitle, this.requiresConfirmation = false, this.confirmed = false, this.confirmedAt, this.confirmedBy}): super._();
  factory _CheckInTarget.fromJson(Map<String, dynamic> json) => _$CheckInTargetFromJson(json);

@override final  String id;
@override final  CheckInTargetType type;
@override final  String name;
@override final  String? avatarUrl;
@override final  String? subtitle;
/// Se este alvo requer confirmação bilateral
@override@JsonKey() final  bool requiresConfirmation;
/// Se já foi confirmado
@override@JsonKey() final  bool confirmed;
/// Quando foi confirmado
@override final  DateTime? confirmedAt;
/// ID de quem confirmou
@override final  String? confirmedBy;

/// Create a copy of CheckInTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckInTargetCopyWith<_CheckInTarget> get copyWith => __$CheckInTargetCopyWithImpl<_CheckInTarget>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckInTargetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckInTarget&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.requiresConfirmation, requiresConfirmation) || other.requiresConfirmation == requiresConfirmation)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.confirmedBy, confirmedBy) || other.confirmedBy == confirmedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,avatarUrl,subtitle,requiresConfirmation,confirmed,confirmedAt,confirmedBy);

@override
String toString() {
  return 'CheckInTarget(id: $id, type: $type, name: $name, avatarUrl: $avatarUrl, subtitle: $subtitle, requiresConfirmation: $requiresConfirmation, confirmed: $confirmed, confirmedAt: $confirmedAt, confirmedBy: $confirmedBy)';
}


}

/// @nodoc
abstract mixin class _$CheckInTargetCopyWith<$Res> implements $CheckInTargetCopyWith<$Res> {
  factory _$CheckInTargetCopyWith(_CheckInTarget value, $Res Function(_CheckInTarget) _then) = __$CheckInTargetCopyWithImpl;
@override @useResult
$Res call({
 String id, CheckInTargetType type, String name, String? avatarUrl, String? subtitle, bool requiresConfirmation, bool confirmed, DateTime? confirmedAt, String? confirmedBy
});




}
/// @nodoc
class __$CheckInTargetCopyWithImpl<$Res>
    implements _$CheckInTargetCopyWith<$Res> {
  __$CheckInTargetCopyWithImpl(this._self, this._then);

  final _CheckInTarget _self;
  final $Res Function(_CheckInTarget) _then;

/// Create a copy of CheckInTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? avatarUrl = freezed,Object? subtitle = freezed,Object? requiresConfirmation = null,Object? confirmed = null,Object? confirmedAt = freezed,Object? confirmedBy = freezed,}) {
  return _then(_CheckInTarget(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CheckInTargetType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,requiresConfirmation: null == requiresConfirmation ? _self.requiresConfirmation : requiresConfirmation // ignore: cast_nullable_to_non_nullable
as bool,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as bool,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,confirmedBy: freezed == confirmedBy ? _self.confirmedBy : confirmedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ScheduledSession {

 String get id; String get title; DateTime get scheduledAt; int get durationMinutes;/// Personal trainer da sessão
 String? get trainerId; String? get trainerName; String? get trainerAvatarUrl;/// Aluno da sessão
 String? get studentId; String? get studentName; String? get studentAvatarUrl;/// Academia onde será a sessão
 String? get gymId; String? get gymName;/// Aula em grupo (se aplicável)
 String? get classId; String? get className; int? get classCapacity; int? get classEnrolled;/// Status da sessão
 SessionStatus get status;/// Check-in já realizado?
 String? get checkInId;
/// Create a copy of ScheduledSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduledSessionCopyWith<ScheduledSession> get copyWith => _$ScheduledSessionCopyWithImpl<ScheduledSession>(this as ScheduledSession, _$identity);

  /// Serializes this ScheduledSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduledSession&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.trainerName, trainerName) || other.trainerName == trainerName)&&(identical(other.trainerAvatarUrl, trainerAvatarUrl) || other.trainerAvatarUrl == trainerAvatarUrl)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentAvatarUrl, studentAvatarUrl) || other.studentAvatarUrl == studentAvatarUrl)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.gymName, gymName) || other.gymName == gymName)&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.className, className) || other.className == className)&&(identical(other.classCapacity, classCapacity) || other.classCapacity == classCapacity)&&(identical(other.classEnrolled, classEnrolled) || other.classEnrolled == classEnrolled)&&(identical(other.status, status) || other.status == status)&&(identical(other.checkInId, checkInId) || other.checkInId == checkInId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,scheduledAt,durationMinutes,trainerId,trainerName,trainerAvatarUrl,studentId,studentName,studentAvatarUrl,gymId,gymName,classId,className,classCapacity,classEnrolled,status,checkInId);

@override
String toString() {
  return 'ScheduledSession(id: $id, title: $title, scheduledAt: $scheduledAt, durationMinutes: $durationMinutes, trainerId: $trainerId, trainerName: $trainerName, trainerAvatarUrl: $trainerAvatarUrl, studentId: $studentId, studentName: $studentName, studentAvatarUrl: $studentAvatarUrl, gymId: $gymId, gymName: $gymName, classId: $classId, className: $className, classCapacity: $classCapacity, classEnrolled: $classEnrolled, status: $status, checkInId: $checkInId)';
}


}

/// @nodoc
abstract mixin class $ScheduledSessionCopyWith<$Res>  {
  factory $ScheduledSessionCopyWith(ScheduledSession value, $Res Function(ScheduledSession) _then) = _$ScheduledSessionCopyWithImpl;
@useResult
$Res call({
 String id, String title, DateTime scheduledAt, int durationMinutes, String? trainerId, String? trainerName, String? trainerAvatarUrl, String? studentId, String? studentName, String? studentAvatarUrl, String? gymId, String? gymName, String? classId, String? className, int? classCapacity, int? classEnrolled, SessionStatus status, String? checkInId
});




}
/// @nodoc
class _$ScheduledSessionCopyWithImpl<$Res>
    implements $ScheduledSessionCopyWith<$Res> {
  _$ScheduledSessionCopyWithImpl(this._self, this._then);

  final ScheduledSession _self;
  final $Res Function(ScheduledSession) _then;

/// Create a copy of ScheduledSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? scheduledAt = null,Object? durationMinutes = null,Object? trainerId = freezed,Object? trainerName = freezed,Object? trainerAvatarUrl = freezed,Object? studentId = freezed,Object? studentName = freezed,Object? studentAvatarUrl = freezed,Object? gymId = freezed,Object? gymName = freezed,Object? classId = freezed,Object? className = freezed,Object? classCapacity = freezed,Object? classEnrolled = freezed,Object? status = null,Object? checkInId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,trainerId: freezed == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String?,trainerName: freezed == trainerName ? _self.trainerName : trainerName // ignore: cast_nullable_to_non_nullable
as String?,trainerAvatarUrl: freezed == trainerAvatarUrl ? _self.trainerAvatarUrl : trainerAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,studentName: freezed == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String?,studentAvatarUrl: freezed == studentAvatarUrl ? _self.studentAvatarUrl : studentAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,gymId: freezed == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String?,gymName: freezed == gymName ? _self.gymName : gymName // ignore: cast_nullable_to_non_nullable
as String?,classId: freezed == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String?,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,classCapacity: freezed == classCapacity ? _self.classCapacity : classCapacity // ignore: cast_nullable_to_non_nullable
as int?,classEnrolled: freezed == classEnrolled ? _self.classEnrolled : classEnrolled // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SessionStatus,checkInId: freezed == checkInId ? _self.checkInId : checkInId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduledSession].
extension ScheduledSessionPatterns on ScheduledSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduledSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduledSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduledSession value)  $default,){
final _that = this;
switch (_that) {
case _ScheduledSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduledSession value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduledSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  DateTime scheduledAt,  int durationMinutes,  String? trainerId,  String? trainerName,  String? trainerAvatarUrl,  String? studentId,  String? studentName,  String? studentAvatarUrl,  String? gymId,  String? gymName,  String? classId,  String? className,  int? classCapacity,  int? classEnrolled,  SessionStatus status,  String? checkInId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduledSession() when $default != null:
return $default(_that.id,_that.title,_that.scheduledAt,_that.durationMinutes,_that.trainerId,_that.trainerName,_that.trainerAvatarUrl,_that.studentId,_that.studentName,_that.studentAvatarUrl,_that.gymId,_that.gymName,_that.classId,_that.className,_that.classCapacity,_that.classEnrolled,_that.status,_that.checkInId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  DateTime scheduledAt,  int durationMinutes,  String? trainerId,  String? trainerName,  String? trainerAvatarUrl,  String? studentId,  String? studentName,  String? studentAvatarUrl,  String? gymId,  String? gymName,  String? classId,  String? className,  int? classCapacity,  int? classEnrolled,  SessionStatus status,  String? checkInId)  $default,) {final _that = this;
switch (_that) {
case _ScheduledSession():
return $default(_that.id,_that.title,_that.scheduledAt,_that.durationMinutes,_that.trainerId,_that.trainerName,_that.trainerAvatarUrl,_that.studentId,_that.studentName,_that.studentAvatarUrl,_that.gymId,_that.gymName,_that.classId,_that.className,_that.classCapacity,_that.classEnrolled,_that.status,_that.checkInId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  DateTime scheduledAt,  int durationMinutes,  String? trainerId,  String? trainerName,  String? trainerAvatarUrl,  String? studentId,  String? studentName,  String? studentAvatarUrl,  String? gymId,  String? gymName,  String? classId,  String? className,  int? classCapacity,  int? classEnrolled,  SessionStatus status,  String? checkInId)?  $default,) {final _that = this;
switch (_that) {
case _ScheduledSession() when $default != null:
return $default(_that.id,_that.title,_that.scheduledAt,_that.durationMinutes,_that.trainerId,_that.trainerName,_that.trainerAvatarUrl,_that.studentId,_that.studentName,_that.studentAvatarUrl,_that.gymId,_that.gymName,_that.classId,_that.className,_that.classCapacity,_that.classEnrolled,_that.status,_that.checkInId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduledSession extends ScheduledSession {
  const _ScheduledSession({required this.id, required this.title, required this.scheduledAt, required this.durationMinutes, this.trainerId, this.trainerName, this.trainerAvatarUrl, this.studentId, this.studentName, this.studentAvatarUrl, this.gymId, this.gymName, this.classId, this.className, this.classCapacity, this.classEnrolled, this.status = SessionStatus.scheduled, this.checkInId}): super._();
  factory _ScheduledSession.fromJson(Map<String, dynamic> json) => _$ScheduledSessionFromJson(json);

@override final  String id;
@override final  String title;
@override final  DateTime scheduledAt;
@override final  int durationMinutes;
/// Personal trainer da sessão
@override final  String? trainerId;
@override final  String? trainerName;
@override final  String? trainerAvatarUrl;
/// Aluno da sessão
@override final  String? studentId;
@override final  String? studentName;
@override final  String? studentAvatarUrl;
/// Academia onde será a sessão
@override final  String? gymId;
@override final  String? gymName;
/// Aula em grupo (se aplicável)
@override final  String? classId;
@override final  String? className;
@override final  int? classCapacity;
@override final  int? classEnrolled;
/// Status da sessão
@override@JsonKey() final  SessionStatus status;
/// Check-in já realizado?
@override final  String? checkInId;

/// Create a copy of ScheduledSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduledSessionCopyWith<_ScheduledSession> get copyWith => __$ScheduledSessionCopyWithImpl<_ScheduledSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduledSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduledSession&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.trainerName, trainerName) || other.trainerName == trainerName)&&(identical(other.trainerAvatarUrl, trainerAvatarUrl) || other.trainerAvatarUrl == trainerAvatarUrl)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentAvatarUrl, studentAvatarUrl) || other.studentAvatarUrl == studentAvatarUrl)&&(identical(other.gymId, gymId) || other.gymId == gymId)&&(identical(other.gymName, gymName) || other.gymName == gymName)&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.className, className) || other.className == className)&&(identical(other.classCapacity, classCapacity) || other.classCapacity == classCapacity)&&(identical(other.classEnrolled, classEnrolled) || other.classEnrolled == classEnrolled)&&(identical(other.status, status) || other.status == status)&&(identical(other.checkInId, checkInId) || other.checkInId == checkInId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,scheduledAt,durationMinutes,trainerId,trainerName,trainerAvatarUrl,studentId,studentName,studentAvatarUrl,gymId,gymName,classId,className,classCapacity,classEnrolled,status,checkInId);

@override
String toString() {
  return 'ScheduledSession(id: $id, title: $title, scheduledAt: $scheduledAt, durationMinutes: $durationMinutes, trainerId: $trainerId, trainerName: $trainerName, trainerAvatarUrl: $trainerAvatarUrl, studentId: $studentId, studentName: $studentName, studentAvatarUrl: $studentAvatarUrl, gymId: $gymId, gymName: $gymName, classId: $classId, className: $className, classCapacity: $classCapacity, classEnrolled: $classEnrolled, status: $status, checkInId: $checkInId)';
}


}

/// @nodoc
abstract mixin class _$ScheduledSessionCopyWith<$Res> implements $ScheduledSessionCopyWith<$Res> {
  factory _$ScheduledSessionCopyWith(_ScheduledSession value, $Res Function(_ScheduledSession) _then) = __$ScheduledSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DateTime scheduledAt, int durationMinutes, String? trainerId, String? trainerName, String? trainerAvatarUrl, String? studentId, String? studentName, String? studentAvatarUrl, String? gymId, String? gymName, String? classId, String? className, int? classCapacity, int? classEnrolled, SessionStatus status, String? checkInId
});




}
/// @nodoc
class __$ScheduledSessionCopyWithImpl<$Res>
    implements _$ScheduledSessionCopyWith<$Res> {
  __$ScheduledSessionCopyWithImpl(this._self, this._then);

  final _ScheduledSession _self;
  final $Res Function(_ScheduledSession) _then;

/// Create a copy of ScheduledSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? scheduledAt = null,Object? durationMinutes = null,Object? trainerId = freezed,Object? trainerName = freezed,Object? trainerAvatarUrl = freezed,Object? studentId = freezed,Object? studentName = freezed,Object? studentAvatarUrl = freezed,Object? gymId = freezed,Object? gymName = freezed,Object? classId = freezed,Object? className = freezed,Object? classCapacity = freezed,Object? classEnrolled = freezed,Object? status = null,Object? checkInId = freezed,}) {
  return _then(_ScheduledSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,trainerId: freezed == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String?,trainerName: freezed == trainerName ? _self.trainerName : trainerName // ignore: cast_nullable_to_non_nullable
as String?,trainerAvatarUrl: freezed == trainerAvatarUrl ? _self.trainerAvatarUrl : trainerAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,studentName: freezed == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String?,studentAvatarUrl: freezed == studentAvatarUrl ? _self.studentAvatarUrl : studentAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,gymId: freezed == gymId ? _self.gymId : gymId // ignore: cast_nullable_to_non_nullable
as String?,gymName: freezed == gymName ? _self.gymName : gymName // ignore: cast_nullable_to_non_nullable
as String?,classId: freezed == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String?,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,classCapacity: freezed == classCapacity ? _self.classCapacity : classCapacity // ignore: cast_nullable_to_non_nullable
as int?,classEnrolled: freezed == classEnrolled ? _self.classEnrolled : classEnrolled // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SessionStatus,checkInId: freezed == checkInId ? _self.checkInId : checkInId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PendingConfirmation {

 String get checkInId; String get requesterId; String get requesterName; String? get requesterAvatarUrl; CheckInInitiatorRole get requesterRole; DateTime get requestedAt; String? get sessionId; String? get message;/// Tipo de confirmação esperada
 ConfirmationType get type;
/// Create a copy of PendingConfirmation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingConfirmationCopyWith<PendingConfirmation> get copyWith => _$PendingConfirmationCopyWithImpl<PendingConfirmation>(this as PendingConfirmation, _$identity);

  /// Serializes this PendingConfirmation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingConfirmation&&(identical(other.checkInId, checkInId) || other.checkInId == checkInId)&&(identical(other.requesterId, requesterId) || other.requesterId == requesterId)&&(identical(other.requesterName, requesterName) || other.requesterName == requesterName)&&(identical(other.requesterAvatarUrl, requesterAvatarUrl) || other.requesterAvatarUrl == requesterAvatarUrl)&&(identical(other.requesterRole, requesterRole) || other.requesterRole == requesterRole)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.message, message) || other.message == message)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,checkInId,requesterId,requesterName,requesterAvatarUrl,requesterRole,requestedAt,sessionId,message,type);

@override
String toString() {
  return 'PendingConfirmation(checkInId: $checkInId, requesterId: $requesterId, requesterName: $requesterName, requesterAvatarUrl: $requesterAvatarUrl, requesterRole: $requesterRole, requestedAt: $requestedAt, sessionId: $sessionId, message: $message, type: $type)';
}


}

/// @nodoc
abstract mixin class $PendingConfirmationCopyWith<$Res>  {
  factory $PendingConfirmationCopyWith(PendingConfirmation value, $Res Function(PendingConfirmation) _then) = _$PendingConfirmationCopyWithImpl;
@useResult
$Res call({
 String checkInId, String requesterId, String requesterName, String? requesterAvatarUrl, CheckInInitiatorRole requesterRole, DateTime requestedAt, String? sessionId, String? message, ConfirmationType type
});




}
/// @nodoc
class _$PendingConfirmationCopyWithImpl<$Res>
    implements $PendingConfirmationCopyWith<$Res> {
  _$PendingConfirmationCopyWithImpl(this._self, this._then);

  final PendingConfirmation _self;
  final $Res Function(PendingConfirmation) _then;

/// Create a copy of PendingConfirmation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? checkInId = null,Object? requesterId = null,Object? requesterName = null,Object? requesterAvatarUrl = freezed,Object? requesterRole = null,Object? requestedAt = null,Object? sessionId = freezed,Object? message = freezed,Object? type = null,}) {
  return _then(_self.copyWith(
checkInId: null == checkInId ? _self.checkInId : checkInId // ignore: cast_nullable_to_non_nullable
as String,requesterId: null == requesterId ? _self.requesterId : requesterId // ignore: cast_nullable_to_non_nullable
as String,requesterName: null == requesterName ? _self.requesterName : requesterName // ignore: cast_nullable_to_non_nullable
as String,requesterAvatarUrl: freezed == requesterAvatarUrl ? _self.requesterAvatarUrl : requesterAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,requesterRole: null == requesterRole ? _self.requesterRole : requesterRole // ignore: cast_nullable_to_non_nullable
as CheckInInitiatorRole,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConfirmationType,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingConfirmation].
extension PendingConfirmationPatterns on PendingConfirmation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingConfirmation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingConfirmation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingConfirmation value)  $default,){
final _that = this;
switch (_that) {
case _PendingConfirmation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingConfirmation value)?  $default,){
final _that = this;
switch (_that) {
case _PendingConfirmation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String checkInId,  String requesterId,  String requesterName,  String? requesterAvatarUrl,  CheckInInitiatorRole requesterRole,  DateTime requestedAt,  String? sessionId,  String? message,  ConfirmationType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingConfirmation() when $default != null:
return $default(_that.checkInId,_that.requesterId,_that.requesterName,_that.requesterAvatarUrl,_that.requesterRole,_that.requestedAt,_that.sessionId,_that.message,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String checkInId,  String requesterId,  String requesterName,  String? requesterAvatarUrl,  CheckInInitiatorRole requesterRole,  DateTime requestedAt,  String? sessionId,  String? message,  ConfirmationType type)  $default,) {final _that = this;
switch (_that) {
case _PendingConfirmation():
return $default(_that.checkInId,_that.requesterId,_that.requesterName,_that.requesterAvatarUrl,_that.requesterRole,_that.requestedAt,_that.sessionId,_that.message,_that.type);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String checkInId,  String requesterId,  String requesterName,  String? requesterAvatarUrl,  CheckInInitiatorRole requesterRole,  DateTime requestedAt,  String? sessionId,  String? message,  ConfirmationType type)?  $default,) {final _that = this;
switch (_that) {
case _PendingConfirmation() when $default != null:
return $default(_that.checkInId,_that.requesterId,_that.requesterName,_that.requesterAvatarUrl,_that.requesterRole,_that.requestedAt,_that.sessionId,_that.message,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingConfirmation extends PendingConfirmation {
  const _PendingConfirmation({required this.checkInId, required this.requesterId, required this.requesterName, this.requesterAvatarUrl, required this.requesterRole, required this.requestedAt, this.sessionId, this.message, this.type = ConfirmationType.presence}): super._();
  factory _PendingConfirmation.fromJson(Map<String, dynamic> json) => _$PendingConfirmationFromJson(json);

@override final  String checkInId;
@override final  String requesterId;
@override final  String requesterName;
@override final  String? requesterAvatarUrl;
@override final  CheckInInitiatorRole requesterRole;
@override final  DateTime requestedAt;
@override final  String? sessionId;
@override final  String? message;
/// Tipo de confirmação esperada
@override@JsonKey() final  ConfirmationType type;

/// Create a copy of PendingConfirmation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingConfirmationCopyWith<_PendingConfirmation> get copyWith => __$PendingConfirmationCopyWithImpl<_PendingConfirmation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingConfirmationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingConfirmation&&(identical(other.checkInId, checkInId) || other.checkInId == checkInId)&&(identical(other.requesterId, requesterId) || other.requesterId == requesterId)&&(identical(other.requesterName, requesterName) || other.requesterName == requesterName)&&(identical(other.requesterAvatarUrl, requesterAvatarUrl) || other.requesterAvatarUrl == requesterAvatarUrl)&&(identical(other.requesterRole, requesterRole) || other.requesterRole == requesterRole)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.message, message) || other.message == message)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,checkInId,requesterId,requesterName,requesterAvatarUrl,requesterRole,requestedAt,sessionId,message,type);

@override
String toString() {
  return 'PendingConfirmation(checkInId: $checkInId, requesterId: $requesterId, requesterName: $requesterName, requesterAvatarUrl: $requesterAvatarUrl, requesterRole: $requesterRole, requestedAt: $requestedAt, sessionId: $sessionId, message: $message, type: $type)';
}


}

/// @nodoc
abstract mixin class _$PendingConfirmationCopyWith<$Res> implements $PendingConfirmationCopyWith<$Res> {
  factory _$PendingConfirmationCopyWith(_PendingConfirmation value, $Res Function(_PendingConfirmation) _then) = __$PendingConfirmationCopyWithImpl;
@override @useResult
$Res call({
 String checkInId, String requesterId, String requesterName, String? requesterAvatarUrl, CheckInInitiatorRole requesterRole, DateTime requestedAt, String? sessionId, String? message, ConfirmationType type
});




}
/// @nodoc
class __$PendingConfirmationCopyWithImpl<$Res>
    implements _$PendingConfirmationCopyWith<$Res> {
  __$PendingConfirmationCopyWithImpl(this._self, this._then);

  final _PendingConfirmation _self;
  final $Res Function(_PendingConfirmation) _then;

/// Create a copy of PendingConfirmation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? checkInId = null,Object? requesterId = null,Object? requesterName = null,Object? requesterAvatarUrl = freezed,Object? requesterRole = null,Object? requestedAt = null,Object? sessionId = freezed,Object? message = freezed,Object? type = null,}) {
  return _then(_PendingConfirmation(
checkInId: null == checkInId ? _self.checkInId : checkInId // ignore: cast_nullable_to_non_nullable
as String,requesterId: null == requesterId ? _self.requesterId : requesterId // ignore: cast_nullable_to_non_nullable
as String,requesterName: null == requesterName ? _self.requesterName : requesterName // ignore: cast_nullable_to_non_nullable
as String,requesterAvatarUrl: freezed == requesterAvatarUrl ? _self.requesterAvatarUrl : requesterAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,requesterRole: null == requesterRole ? _self.requesterRole : requesterRole // ignore: cast_nullable_to_non_nullable
as CheckInInitiatorRole,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConfirmationType,
  ));
}


}


/// @nodoc
mixin _$CheckInContext {

/// Papel atual do usuário
 CheckInInitiatorRole get userRole;/// Está próximo de uma academia?
 String? get nearbyGymId; String? get nearbyGymName; double? get distanceToGym;/// Sessões agendadas para hoje
 List<ScheduledSession> get todaySessions;/// Próxima sessão
 ScheduledSession? get nextSession;/// Confirmações pendentes
 List<PendingConfirmation> get pendingConfirmations;/// Aulas disponíveis agora
 List<ScheduledSession> get availableClasses;/// Check-in ativo atual
 String? get activeCheckInId;
/// Create a copy of CheckInContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInContextCopyWith<CheckInContext> get copyWith => _$CheckInContextCopyWithImpl<CheckInContext>(this as CheckInContext, _$identity);

  /// Serializes this CheckInContext to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInContext&&(identical(other.userRole, userRole) || other.userRole == userRole)&&(identical(other.nearbyGymId, nearbyGymId) || other.nearbyGymId == nearbyGymId)&&(identical(other.nearbyGymName, nearbyGymName) || other.nearbyGymName == nearbyGymName)&&(identical(other.distanceToGym, distanceToGym) || other.distanceToGym == distanceToGym)&&const DeepCollectionEquality().equals(other.todaySessions, todaySessions)&&(identical(other.nextSession, nextSession) || other.nextSession == nextSession)&&const DeepCollectionEquality().equals(other.pendingConfirmations, pendingConfirmations)&&const DeepCollectionEquality().equals(other.availableClasses, availableClasses)&&(identical(other.activeCheckInId, activeCheckInId) || other.activeCheckInId == activeCheckInId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userRole,nearbyGymId,nearbyGymName,distanceToGym,const DeepCollectionEquality().hash(todaySessions),nextSession,const DeepCollectionEquality().hash(pendingConfirmations),const DeepCollectionEquality().hash(availableClasses),activeCheckInId);

@override
String toString() {
  return 'CheckInContext(userRole: $userRole, nearbyGymId: $nearbyGymId, nearbyGymName: $nearbyGymName, distanceToGym: $distanceToGym, todaySessions: $todaySessions, nextSession: $nextSession, pendingConfirmations: $pendingConfirmations, availableClasses: $availableClasses, activeCheckInId: $activeCheckInId)';
}


}

/// @nodoc
abstract mixin class $CheckInContextCopyWith<$Res>  {
  factory $CheckInContextCopyWith(CheckInContext value, $Res Function(CheckInContext) _then) = _$CheckInContextCopyWithImpl;
@useResult
$Res call({
 CheckInInitiatorRole userRole, String? nearbyGymId, String? nearbyGymName, double? distanceToGym, List<ScheduledSession> todaySessions, ScheduledSession? nextSession, List<PendingConfirmation> pendingConfirmations, List<ScheduledSession> availableClasses, String? activeCheckInId
});


$ScheduledSessionCopyWith<$Res>? get nextSession;

}
/// @nodoc
class _$CheckInContextCopyWithImpl<$Res>
    implements $CheckInContextCopyWith<$Res> {
  _$CheckInContextCopyWithImpl(this._self, this._then);

  final CheckInContext _self;
  final $Res Function(CheckInContext) _then;

/// Create a copy of CheckInContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userRole = null,Object? nearbyGymId = freezed,Object? nearbyGymName = freezed,Object? distanceToGym = freezed,Object? todaySessions = null,Object? nextSession = freezed,Object? pendingConfirmations = null,Object? availableClasses = null,Object? activeCheckInId = freezed,}) {
  return _then(_self.copyWith(
userRole: null == userRole ? _self.userRole : userRole // ignore: cast_nullable_to_non_nullable
as CheckInInitiatorRole,nearbyGymId: freezed == nearbyGymId ? _self.nearbyGymId : nearbyGymId // ignore: cast_nullable_to_non_nullable
as String?,nearbyGymName: freezed == nearbyGymName ? _self.nearbyGymName : nearbyGymName // ignore: cast_nullable_to_non_nullable
as String?,distanceToGym: freezed == distanceToGym ? _self.distanceToGym : distanceToGym // ignore: cast_nullable_to_non_nullable
as double?,todaySessions: null == todaySessions ? _self.todaySessions : todaySessions // ignore: cast_nullable_to_non_nullable
as List<ScheduledSession>,nextSession: freezed == nextSession ? _self.nextSession : nextSession // ignore: cast_nullable_to_non_nullable
as ScheduledSession?,pendingConfirmations: null == pendingConfirmations ? _self.pendingConfirmations : pendingConfirmations // ignore: cast_nullable_to_non_nullable
as List<PendingConfirmation>,availableClasses: null == availableClasses ? _self.availableClasses : availableClasses // ignore: cast_nullable_to_non_nullable
as List<ScheduledSession>,activeCheckInId: freezed == activeCheckInId ? _self.activeCheckInId : activeCheckInId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CheckInContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScheduledSessionCopyWith<$Res>? get nextSession {
    if (_self.nextSession == null) {
    return null;
  }

  return $ScheduledSessionCopyWith<$Res>(_self.nextSession!, (value) {
    return _then(_self.copyWith(nextSession: value));
  });
}
}


/// Adds pattern-matching-related methods to [CheckInContext].
extension CheckInContextPatterns on CheckInContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckInContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckInContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckInContext value)  $default,){
final _that = this;
switch (_that) {
case _CheckInContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckInContext value)?  $default,){
final _that = this;
switch (_that) {
case _CheckInContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CheckInInitiatorRole userRole,  String? nearbyGymId,  String? nearbyGymName,  double? distanceToGym,  List<ScheduledSession> todaySessions,  ScheduledSession? nextSession,  List<PendingConfirmation> pendingConfirmations,  List<ScheduledSession> availableClasses,  String? activeCheckInId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckInContext() when $default != null:
return $default(_that.userRole,_that.nearbyGymId,_that.nearbyGymName,_that.distanceToGym,_that.todaySessions,_that.nextSession,_that.pendingConfirmations,_that.availableClasses,_that.activeCheckInId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CheckInInitiatorRole userRole,  String? nearbyGymId,  String? nearbyGymName,  double? distanceToGym,  List<ScheduledSession> todaySessions,  ScheduledSession? nextSession,  List<PendingConfirmation> pendingConfirmations,  List<ScheduledSession> availableClasses,  String? activeCheckInId)  $default,) {final _that = this;
switch (_that) {
case _CheckInContext():
return $default(_that.userRole,_that.nearbyGymId,_that.nearbyGymName,_that.distanceToGym,_that.todaySessions,_that.nextSession,_that.pendingConfirmations,_that.availableClasses,_that.activeCheckInId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CheckInInitiatorRole userRole,  String? nearbyGymId,  String? nearbyGymName,  double? distanceToGym,  List<ScheduledSession> todaySessions,  ScheduledSession? nextSession,  List<PendingConfirmation> pendingConfirmations,  List<ScheduledSession> availableClasses,  String? activeCheckInId)?  $default,) {final _that = this;
switch (_that) {
case _CheckInContext() when $default != null:
return $default(_that.userRole,_that.nearbyGymId,_that.nearbyGymName,_that.distanceToGym,_that.todaySessions,_that.nextSession,_that.pendingConfirmations,_that.availableClasses,_that.activeCheckInId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckInContext extends CheckInContext {
  const _CheckInContext({required this.userRole, this.nearbyGymId, this.nearbyGymName, this.distanceToGym, final  List<ScheduledSession> todaySessions = const [], this.nextSession, final  List<PendingConfirmation> pendingConfirmations = const [], final  List<ScheduledSession> availableClasses = const [], this.activeCheckInId}): _todaySessions = todaySessions,_pendingConfirmations = pendingConfirmations,_availableClasses = availableClasses,super._();
  factory _CheckInContext.fromJson(Map<String, dynamic> json) => _$CheckInContextFromJson(json);

/// Papel atual do usuário
@override final  CheckInInitiatorRole userRole;
/// Está próximo de uma academia?
@override final  String? nearbyGymId;
@override final  String? nearbyGymName;
@override final  double? distanceToGym;
/// Sessões agendadas para hoje
 final  List<ScheduledSession> _todaySessions;
/// Sessões agendadas para hoje
@override@JsonKey() List<ScheduledSession> get todaySessions {
  if (_todaySessions is EqualUnmodifiableListView) return _todaySessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_todaySessions);
}

/// Próxima sessão
@override final  ScheduledSession? nextSession;
/// Confirmações pendentes
 final  List<PendingConfirmation> _pendingConfirmations;
/// Confirmações pendentes
@override@JsonKey() List<PendingConfirmation> get pendingConfirmations {
  if (_pendingConfirmations is EqualUnmodifiableListView) return _pendingConfirmations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendingConfirmations);
}

/// Aulas disponíveis agora
 final  List<ScheduledSession> _availableClasses;
/// Aulas disponíveis agora
@override@JsonKey() List<ScheduledSession> get availableClasses {
  if (_availableClasses is EqualUnmodifiableListView) return _availableClasses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableClasses);
}

/// Check-in ativo atual
@override final  String? activeCheckInId;

/// Create a copy of CheckInContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckInContextCopyWith<_CheckInContext> get copyWith => __$CheckInContextCopyWithImpl<_CheckInContext>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckInContextToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckInContext&&(identical(other.userRole, userRole) || other.userRole == userRole)&&(identical(other.nearbyGymId, nearbyGymId) || other.nearbyGymId == nearbyGymId)&&(identical(other.nearbyGymName, nearbyGymName) || other.nearbyGymName == nearbyGymName)&&(identical(other.distanceToGym, distanceToGym) || other.distanceToGym == distanceToGym)&&const DeepCollectionEquality().equals(other._todaySessions, _todaySessions)&&(identical(other.nextSession, nextSession) || other.nextSession == nextSession)&&const DeepCollectionEquality().equals(other._pendingConfirmations, _pendingConfirmations)&&const DeepCollectionEquality().equals(other._availableClasses, _availableClasses)&&(identical(other.activeCheckInId, activeCheckInId) || other.activeCheckInId == activeCheckInId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userRole,nearbyGymId,nearbyGymName,distanceToGym,const DeepCollectionEquality().hash(_todaySessions),nextSession,const DeepCollectionEquality().hash(_pendingConfirmations),const DeepCollectionEquality().hash(_availableClasses),activeCheckInId);

@override
String toString() {
  return 'CheckInContext(userRole: $userRole, nearbyGymId: $nearbyGymId, nearbyGymName: $nearbyGymName, distanceToGym: $distanceToGym, todaySessions: $todaySessions, nextSession: $nextSession, pendingConfirmations: $pendingConfirmations, availableClasses: $availableClasses, activeCheckInId: $activeCheckInId)';
}


}

/// @nodoc
abstract mixin class _$CheckInContextCopyWith<$Res> implements $CheckInContextCopyWith<$Res> {
  factory _$CheckInContextCopyWith(_CheckInContext value, $Res Function(_CheckInContext) _then) = __$CheckInContextCopyWithImpl;
@override @useResult
$Res call({
 CheckInInitiatorRole userRole, String? nearbyGymId, String? nearbyGymName, double? distanceToGym, List<ScheduledSession> todaySessions, ScheduledSession? nextSession, List<PendingConfirmation> pendingConfirmations, List<ScheduledSession> availableClasses, String? activeCheckInId
});


@override $ScheduledSessionCopyWith<$Res>? get nextSession;

}
/// @nodoc
class __$CheckInContextCopyWithImpl<$Res>
    implements _$CheckInContextCopyWith<$Res> {
  __$CheckInContextCopyWithImpl(this._self, this._then);

  final _CheckInContext _self;
  final $Res Function(_CheckInContext) _then;

/// Create a copy of CheckInContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userRole = null,Object? nearbyGymId = freezed,Object? nearbyGymName = freezed,Object? distanceToGym = freezed,Object? todaySessions = null,Object? nextSession = freezed,Object? pendingConfirmations = null,Object? availableClasses = null,Object? activeCheckInId = freezed,}) {
  return _then(_CheckInContext(
userRole: null == userRole ? _self.userRole : userRole // ignore: cast_nullable_to_non_nullable
as CheckInInitiatorRole,nearbyGymId: freezed == nearbyGymId ? _self.nearbyGymId : nearbyGymId // ignore: cast_nullable_to_non_nullable
as String?,nearbyGymName: freezed == nearbyGymName ? _self.nearbyGymName : nearbyGymName // ignore: cast_nullable_to_non_nullable
as String?,distanceToGym: freezed == distanceToGym ? _self.distanceToGym : distanceToGym // ignore: cast_nullable_to_non_nullable
as double?,todaySessions: null == todaySessions ? _self._todaySessions : todaySessions // ignore: cast_nullable_to_non_nullable
as List<ScheduledSession>,nextSession: freezed == nextSession ? _self.nextSession : nextSession // ignore: cast_nullable_to_non_nullable
as ScheduledSession?,pendingConfirmations: null == pendingConfirmations ? _self._pendingConfirmations : pendingConfirmations // ignore: cast_nullable_to_non_nullable
as List<PendingConfirmation>,availableClasses: null == availableClasses ? _self._availableClasses : availableClasses // ignore: cast_nullable_to_non_nullable
as List<ScheduledSession>,activeCheckInId: freezed == activeCheckInId ? _self.activeCheckInId : activeCheckInId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CheckInContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScheduledSessionCopyWith<$Res>? get nextSession {
    if (_self.nextSession == null) {
    return null;
  }

  return $ScheduledSessionCopyWith<$Res>(_self.nextSession!, (value) {
    return _then(_self.copyWith(nextSession: value));
  });
}
}

// dart format on
