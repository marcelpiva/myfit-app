// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckIn _$CheckInFromJson(Map<String, dynamic> json) => _CheckIn(
  id: json['id'] as String,
  initiatorId: json['initiatorId'] as String,
  initiatorName: json['initiatorName'] as String,
  initiatorAvatarUrl: json['initiatorAvatarUrl'] as String?,
  initiatorRole:
      $enumDecodeNullable(
        _$CheckInInitiatorRoleEnumMap,
        json['initiatorRole'],
      ) ??
      CheckInInitiatorRole.student,
  targets:
      (json['targets'] as List<dynamic>?)
          ?.map((e) => CheckInTarget.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  type:
      $enumDecodeNullable(_$CheckInTypeEnumMap, json['type']) ??
      CheckInType.freeTraining,
  method:
      $enumDecodeNullable(_$CheckInMethodEnumMap, json['method']) ??
      CheckInMethod.qrCode,
  source:
      $enumDecodeNullable(_$CheckInSourceEnumMap, json['source']) ??
      CheckInSource.appStudent,
  organizationId: json['organizationId'] as String,
  organizationName: json['organizationName'] as String,
  sessionId: json['sessionId'] as String?,
  classId: json['classId'] as String?,
  workoutId: json['workoutId'] as String?,
  workoutName: json['workoutName'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  status:
      $enumDecodeNullable(_$CheckInStatusEnumMap, json['status']) ??
      CheckInStatus.pending,
  timestamp: DateTime.parse(json['timestamp'] as String),
  confirmedAt: json['confirmedAt'] == null
      ? null
      : DateTime.parse(json['confirmedAt'] as String),
  checkOutTime: json['checkOutTime'] == null
      ? null
      : DateTime.parse(json['checkOutTime'] as String),
  durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
  pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
  badgesEarned:
      (json['badgesEarned'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  memberId: json['memberId'] as String?,
  memberName: json['memberName'] as String?,
  memberAvatarUrl: json['memberAvatarUrl'] as String?,
  trainerId: json['trainerId'] as String?,
  trainerName: json['trainerName'] as String?,
);

Map<String, dynamic> _$CheckInToJson(_CheckIn instance) => <String, dynamic>{
  'id': instance.id,
  'initiatorId': instance.initiatorId,
  'initiatorName': instance.initiatorName,
  'initiatorAvatarUrl': instance.initiatorAvatarUrl,
  'initiatorRole': _$CheckInInitiatorRoleEnumMap[instance.initiatorRole]!,
  'targets': instance.targets,
  'type': _$CheckInTypeEnumMap[instance.type]!,
  'method': _$CheckInMethodEnumMap[instance.method]!,
  'source': _$CheckInSourceEnumMap[instance.source]!,
  'organizationId': instance.organizationId,
  'organizationName': instance.organizationName,
  'sessionId': instance.sessionId,
  'classId': instance.classId,
  'workoutId': instance.workoutId,
  'workoutName': instance.workoutName,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'status': _$CheckInStatusEnumMap[instance.status]!,
  'timestamp': instance.timestamp.toIso8601String(),
  'confirmedAt': instance.confirmedAt?.toIso8601String(),
  'checkOutTime': instance.checkOutTime?.toIso8601String(),
  'durationMinutes': instance.durationMinutes,
  'pointsEarned': instance.pointsEarned,
  'badgesEarned': instance.badgesEarned,
  'memberId': instance.memberId,
  'memberName': instance.memberName,
  'memberAvatarUrl': instance.memberAvatarUrl,
  'trainerId': instance.trainerId,
  'trainerName': instance.trainerName,
};

const _$CheckInInitiatorRoleEnumMap = {
  CheckInInitiatorRole.student: 'student',
  CheckInInitiatorRole.trainer: 'trainer',
  CheckInInitiatorRole.staff: 'staff',
  CheckInInitiatorRole.system: 'system',
};

const _$CheckInTypeEnumMap = {
  CheckInType.facility: 'facility',
  CheckInType.personalSession: 'personalSession',
  CheckInType.groupClass: 'groupClass',
  CheckInType.freeTraining: 'freeTraining',
  CheckInType.workShift: 'workShift',
};

const _$CheckInMethodEnumMap = {
  CheckInMethod.qrCode: 'qrCode',
  CheckInMethod.manualCode: 'manualCode',
  CheckInMethod.location: 'location',
  CheckInMethod.request: 'request',
  CheckInMethod.nfc: 'nfc',
  CheckInMethod.scheduled: 'scheduled',
};

const _$CheckInSourceEnumMap = {
  CheckInSource.appStudent: 'appStudent',
  CheckInSource.appTrainer: 'appTrainer',
  CheckInSource.totem: 'totem',
  CheckInSource.qrCode: 'qrCode',
};

const _$CheckInStatusEnumMap = {
  CheckInStatus.pending: 'pending',
  CheckInStatus.verified: 'verified',
  CheckInStatus.active: 'active',
  CheckInStatus.completed: 'completed',
  CheckInStatus.cancelled: 'cancelled',
  CheckInStatus.expired: 'expired',
};

_CheckInStats _$CheckInStatsFromJson(Map<String, dynamic> json) =>
    _CheckInStats(
      totalCheckIns: (json['totalCheckIns'] as num).toInt(),
      currentStreak: (json['currentStreak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      thisWeek: (json['thisWeek'] as num).toInt(),
      thisMonth: (json['thisMonth'] as num).toInt(),
      averageDuration: (json['averageDuration'] as num).toDouble(),
      totalPoints: (json['totalPoints'] as num).toInt(),
    );

Map<String, dynamic> _$CheckInStatsToJson(_CheckInStats instance) =>
    <String, dynamic>{
      'totalCheckIns': instance.totalCheckIns,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'thisWeek': instance.thisWeek,
      'thisMonth': instance.thisMonth,
      'averageDuration': instance.averageDuration,
      'totalPoints': instance.totalPoints,
    };

_GymLocation _$GymLocationFromJson(Map<String, dynamic> json) => _GymLocation(
  id: json['id'] as String,
  name: json['name'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  radiusMeters: (json['radiusMeters'] as num).toDouble(),
  address: json['address'] as String?,
);

Map<String, dynamic> _$GymLocationToJson(_GymLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radiusMeters': instance.radiusMeters,
      'address': instance.address,
    };
