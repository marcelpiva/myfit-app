// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) =>
    _LeaderboardEntry(
      rank: (json['rank'] as num).toInt(),
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      memberAvatarUrl: json['memberAvatarUrl'] as String?,
      points: (json['points'] as num).toInt(),
      checkIns: (json['checkIns'] as num).toInt(),
      workoutsCompleted: (json['workoutsCompleted'] as num).toInt(),
      rankChange: (json['rankChange'] as num?)?.toInt(),
      levelIcon: json['levelIcon'] as String?,
      levelName: json['levelName'] as String?,
    );

Map<String, dynamic> _$LeaderboardEntryToJson(_LeaderboardEntry instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'memberId': instance.memberId,
      'memberName': instance.memberName,
      'memberAvatarUrl': instance.memberAvatarUrl,
      'points': instance.points,
      'checkIns': instance.checkIns,
      'workoutsCompleted': instance.workoutsCompleted,
      'rankChange': instance.rankChange,
      'levelIcon': instance.levelIcon,
      'levelName': instance.levelName,
    };

_Leaderboard _$LeaderboardFromJson(Map<String, dynamic> json) => _Leaderboard(
  period: $enumDecode(_$LeaderboardPeriodEnumMap, json['period']),
  entries: (json['entries'] as List<dynamic>)
      .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  currentUserEntry: json['currentUserEntry'] == null
      ? null
      : LeaderboardEntry.fromJson(
          json['currentUserEntry'] as Map<String, dynamic>,
        ),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$LeaderboardToJson(_Leaderboard instance) =>
    <String, dynamic>{
      'period': _$LeaderboardPeriodEnumMap[instance.period]!,
      'entries': instance.entries,
      'currentUserEntry': instance.currentUserEntry,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$LeaderboardPeriodEnumMap = {
  LeaderboardPeriod.weekly: 'weekly',
  LeaderboardPeriod.monthly: 'monthly',
  LeaderboardPeriod.allTime: 'allTime',
};
