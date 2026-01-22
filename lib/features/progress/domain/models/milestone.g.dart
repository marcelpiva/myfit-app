// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Milestone _$MilestoneFromJson(Map<String, dynamic> json) => _Milestone(
  id: json['id'] as String,
  userId: json['userId'] as String,
  type: $enumDecode(_$MilestoneTypeEnumMap, json['type']),
  title: json['title'] as String,
  description: json['description'] as String?,
  targetValue: (json['targetValue'] as num).toDouble(),
  currentValue: (json['currentValue'] as num).toDouble(),
  unit: json['unit'] as String,
  status:
      $enumDecodeNullable(_$MilestoneStatusEnumMap, json['status']) ??
      MilestoneStatus.active,
  targetDate: json['targetDate'] == null
      ? null
      : DateTime.parse(json['targetDate'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  exerciseId: json['exerciseId'] as String?,
  exerciseName: json['exerciseName'] as String?,
  measurementType: json['measurementType'] as String?,
  aiInsight: json['aiInsight'] as String?,
  progressHistory:
      (json['progressHistory'] as List<dynamic>?)
          ?.map((e) => MilestoneProgress.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$MilestoneToJson(_Milestone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$MilestoneTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'targetValue': instance.targetValue,
      'currentValue': instance.currentValue,
      'unit': instance.unit,
      'status': _$MilestoneStatusEnumMap[instance.status]!,
      'targetDate': instance.targetDate?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'measurementType': instance.measurementType,
      'aiInsight': instance.aiInsight,
      'progressHistory': instance.progressHistory,
    };

const _$MilestoneTypeEnumMap = {
  MilestoneType.weightGoal: 'weight_goal',
  MilestoneType.measurementGoal: 'measurement_goal',
  MilestoneType.personalRecord: 'personal_record',
  MilestoneType.consistency: 'consistency',
  MilestoneType.workoutCount: 'workout_count',
  MilestoneType.strengthGain: 'strength_gain',
  MilestoneType.bodyFat: 'body_fat',
  MilestoneType.custom: 'custom',
};

const _$MilestoneStatusEnumMap = {
  MilestoneStatus.active: 'active',
  MilestoneStatus.completed: 'completed',
  MilestoneStatus.expired: 'expired',
  MilestoneStatus.paused: 'paused',
};

_MilestoneProgress _$MilestoneProgressFromJson(Map<String, dynamic> json) =>
    _MilestoneProgress(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$MilestoneProgressToJson(_MilestoneProgress instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
      'note': instance.note,
    };

_AIInsight _$AIInsightFromJson(Map<String, dynamic> json) => _AIInsight(
  id: json['id'] as String,
  userId: json['userId'] as String,
  category: json['category'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  recommendations:
      (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  relatedMilestoneId: json['relatedMilestoneId'] as String?,
  isDismissed: json['isDismissed'] as bool? ?? false,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  sentiment: json['sentiment'] as String? ?? 'neutral',
);

Map<String, dynamic> _$AIInsightToJson(_AIInsight instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'category': instance.category,
      'title': instance.title,
      'content': instance.content,
      'recommendations': instance.recommendations,
      'relatedMilestoneId': instance.relatedMilestoneId,
      'isDismissed': instance.isDismissed,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'sentiment': instance.sentiment,
    };

_MilestoneStats _$MilestoneStatsFromJson(Map<String, dynamic> json) =>
    _MilestoneStats(
      totalMilestones: (json['totalMilestones'] as num?)?.toInt() ?? 0,
      completedMilestones: (json['completedMilestones'] as num?)?.toInt() ?? 0,
      activeMilestones: (json['activeMilestones'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      lastAchievement: json['lastAchievement'] == null
          ? null
          : DateTime.parse(json['lastAchievement'] as String),
      recentAchievements:
          (json['recentAchievements'] as List<dynamic>?)
              ?.map((e) => Milestone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MilestoneStatsToJson(_MilestoneStats instance) =>
    <String, dynamic>{
      'totalMilestones': instance.totalMilestones,
      'completedMilestones': instance.completedMilestones,
      'activeMilestones': instance.activeMilestones,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastAchievement': instance.lastAchievement?.toIso8601String(),
      'recentAchievements': instance.recentAchievements,
    };
