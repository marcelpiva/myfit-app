// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActivityItem _$ActivityItemFromJson(Map<String, dynamic> json) =>
    _ActivityItem(
      id: json['id'] as String,
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>,
      reactions: (json['reactions'] as num?)?.toInt() ?? 0,
      hasReacted: json['hasReacted'] as bool? ?? false,
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ActivityItemToJson(_ActivityItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'userId': instance.userId,
      'userName': instance.userName,
      'userAvatarUrl': instance.userAvatarUrl,
      'timestamp': instance.timestamp.toIso8601String(),
      'data': instance.data,
      'reactions': instance.reactions,
      'hasReacted': instance.hasReacted,
      'comments': instance.comments,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.workoutCompleted: 'workoutCompleted',
  ActivityType.personalRecord: 'personalRecord',
  ActivityType.achievementUnlocked: 'achievementUnlocked',
  ActivityType.milestoneReached: 'milestoneReached',
  ActivityType.streakMilestone: 'streakMilestone',
  ActivityType.gymCheckin: 'gymCheckin',
  ActivityType.firstWorkout: 'firstWorkout',
  ActivityType.levelUp: 'levelUp',
};
