// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_target.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckInTarget _$CheckInTargetFromJson(Map<String, dynamic> json) =>
    _CheckInTarget(
      id: json['id'] as String,
      type: $enumDecode(_$CheckInTargetTypeEnumMap, json['type']),
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      subtitle: json['subtitle'] as String?,
      requiresConfirmation: json['requiresConfirmation'] as bool? ?? false,
      confirmed: json['confirmed'] as bool? ?? false,
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
      confirmedBy: json['confirmedBy'] as String?,
    );

Map<String, dynamic> _$CheckInTargetToJson(_CheckInTarget instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$CheckInTargetTypeEnumMap[instance.type]!,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'subtitle': instance.subtitle,
      'requiresConfirmation': instance.requiresConfirmation,
      'confirmed': instance.confirmed,
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
      'confirmedBy': instance.confirmedBy,
    };

const _$CheckInTargetTypeEnumMap = {
  CheckInTargetType.gym: 'gym',
  CheckInTargetType.trainer: 'trainer',
  CheckInTargetType.student: 'student',
  CheckInTargetType.groupClass: 'groupClass',
  CheckInTargetType.session: 'session',
  CheckInTargetType.equipment: 'equipment',
};

_ScheduledSession _$ScheduledSessionFromJson(Map<String, dynamic> json) =>
    _ScheduledSession(
      id: json['id'] as String,
      title: json['title'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      trainerId: json['trainerId'] as String?,
      trainerName: json['trainerName'] as String?,
      trainerAvatarUrl: json['trainerAvatarUrl'] as String?,
      studentId: json['studentId'] as String?,
      studentName: json['studentName'] as String?,
      studentAvatarUrl: json['studentAvatarUrl'] as String?,
      gymId: json['gymId'] as String?,
      gymName: json['gymName'] as String?,
      classId: json['classId'] as String?,
      className: json['className'] as String?,
      classCapacity: (json['classCapacity'] as num?)?.toInt(),
      classEnrolled: (json['classEnrolled'] as num?)?.toInt(),
      status:
          $enumDecodeNullable(_$SessionStatusEnumMap, json['status']) ??
          SessionStatus.scheduled,
      checkInId: json['checkInId'] as String?,
    );

Map<String, dynamic> _$ScheduledSessionToJson(_ScheduledSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'trainerId': instance.trainerId,
      'trainerName': instance.trainerName,
      'trainerAvatarUrl': instance.trainerAvatarUrl,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'studentAvatarUrl': instance.studentAvatarUrl,
      'gymId': instance.gymId,
      'gymName': instance.gymName,
      'classId': instance.classId,
      'className': instance.className,
      'classCapacity': instance.classCapacity,
      'classEnrolled': instance.classEnrolled,
      'status': _$SessionStatusEnumMap[instance.status]!,
      'checkInId': instance.checkInId,
    };

const _$SessionStatusEnumMap = {
  SessionStatus.scheduled: 'scheduled',
  SessionStatus.checkedIn: 'checkedIn',
  SessionStatus.inProgress: 'inProgress',
  SessionStatus.completed: 'completed',
  SessionStatus.cancelled: 'cancelled',
  SessionStatus.noShow: 'noShow',
};

_PendingConfirmation _$PendingConfirmationFromJson(Map<String, dynamic> json) =>
    _PendingConfirmation(
      checkInId: json['checkInId'] as String,
      requesterId: json['requesterId'] as String,
      requesterName: json['requesterName'] as String,
      requesterAvatarUrl: json['requesterAvatarUrl'] as String?,
      requesterRole: $enumDecode(
        _$CheckInInitiatorRoleEnumMap,
        json['requesterRole'],
      ),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      sessionId: json['sessionId'] as String?,
      message: json['message'] as String?,
      type:
          $enumDecodeNullable(_$ConfirmationTypeEnumMap, json['type']) ??
          ConfirmationType.presence,
    );

Map<String, dynamic> _$PendingConfirmationToJson(
  _PendingConfirmation instance,
) => <String, dynamic>{
  'checkInId': instance.checkInId,
  'requesterId': instance.requesterId,
  'requesterName': instance.requesterName,
  'requesterAvatarUrl': instance.requesterAvatarUrl,
  'requesterRole': _$CheckInInitiatorRoleEnumMap[instance.requesterRole]!,
  'requestedAt': instance.requestedAt.toIso8601String(),
  'sessionId': instance.sessionId,
  'message': instance.message,
  'type': _$ConfirmationTypeEnumMap[instance.type]!,
};

const _$CheckInInitiatorRoleEnumMap = {
  CheckInInitiatorRole.student: 'student',
  CheckInInitiatorRole.trainer: 'trainer',
  CheckInInitiatorRole.staff: 'staff',
  CheckInInitiatorRole.system: 'system',
};

const _$ConfirmationTypeEnumMap = {
  ConfirmationType.presence: 'presence',
  ConfirmationType.sessionStart: 'sessionStart',
  ConfirmationType.sessionEnd: 'sessionEnd',
};

_CheckInContext _$CheckInContextFromJson(
  Map<String, dynamic> json,
) => _CheckInContext(
  userRole: $enumDecode(_$CheckInInitiatorRoleEnumMap, json['userRole']),
  nearbyGymId: json['nearbyGymId'] as String?,
  nearbyGymName: json['nearbyGymName'] as String?,
  distanceToGym: (json['distanceToGym'] as num?)?.toDouble(),
  todaySessions:
      (json['todaySessions'] as List<dynamic>?)
          ?.map((e) => ScheduledSession.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  nextSession: json['nextSession'] == null
      ? null
      : ScheduledSession.fromJson(json['nextSession'] as Map<String, dynamic>),
  pendingConfirmations:
      (json['pendingConfirmations'] as List<dynamic>?)
          ?.map((e) => PendingConfirmation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  availableClasses:
      (json['availableClasses'] as List<dynamic>?)
          ?.map((e) => ScheduledSession.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  activeCheckInId: json['activeCheckInId'] as String?,
);

Map<String, dynamic> _$CheckInContextToJson(_CheckInContext instance) =>
    <String, dynamic>{
      'userRole': _$CheckInInitiatorRoleEnumMap[instance.userRole]!,
      'nearbyGymId': instance.nearbyGymId,
      'nearbyGymName': instance.nearbyGymName,
      'distanceToGym': instance.distanceToGym,
      'todaySessions': instance.todaySessions,
      'nextSession': instance.nextSession,
      'pendingConfirmations': instance.pendingConfirmations,
      'availableClasses': instance.availableClasses,
      'activeCheckInId': instance.activeCheckInId,
    };
