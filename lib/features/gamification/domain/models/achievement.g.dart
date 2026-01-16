// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Achievement _$AchievementFromJson(Map<String, dynamic> json) => _Achievement(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  icon: json['icon'] as String,
  category: $enumDecode(_$AchievementCategoryEnumMap, json['category']),
  rarity: $enumDecode(_$AchievementRarityEnumMap, json['rarity']),
  pointsReward: (json['pointsReward'] as num).toInt(),
  unlockedAt: json['unlockedAt'] == null
      ? null
      : DateTime.parse(json['unlockedAt'] as String),
  progress: (json['progress'] as num?)?.toDouble(),
  currentValue: (json['currentValue'] as num?)?.toInt(),
  targetValue: (json['targetValue'] as num?)?.toInt(),
);

Map<String, dynamic> _$AchievementToJson(_Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'category': _$AchievementCategoryEnumMap[instance.category]!,
      'rarity': _$AchievementRarityEnumMap[instance.rarity]!,
      'pointsReward': instance.pointsReward,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
      'progress': instance.progress,
      'currentValue': instance.currentValue,
      'targetValue': instance.targetValue,
    };

const _$AchievementCategoryEnumMap = {
  AchievementCategory.consistency: 'consistency',
  AchievementCategory.progress: 'progress',
  AchievementCategory.social: 'social',
  AchievementCategory.milestone: 'milestone',
  AchievementCategory.special: 'special',
};

const _$AchievementRarityEnumMap = {
  AchievementRarity.common: 'common',
  AchievementRarity.rare: 'rare',
  AchievementRarity.epic: 'epic',
  AchievementRarity.legendary: 'legendary',
};

_UserLevel _$UserLevelFromJson(Map<String, dynamic> json) => _UserLevel(
  name: json['name'] as String,
  icon: json['icon'] as String,
  minPoints: (json['minPoints'] as num).toInt(),
  maxPoints: (json['maxPoints'] as num).toInt(),
  currentPoints: (json['currentPoints'] as num).toInt(),
);

Map<String, dynamic> _$UserLevelToJson(_UserLevel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'icon': instance.icon,
      'minPoints': instance.minPoints,
      'maxPoints': instance.maxPoints,
      'currentPoints': instance.currentPoints,
    };

_PointsTransaction _$PointsTransactionFromJson(Map<String, dynamic> json) =>
    _PointsTransaction(
      id: json['id'] as String,
      description: json['description'] as String,
      points: (json['points'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: json['source'] as String,
      relatedId: json['relatedId'] as String?,
    );

Map<String, dynamic> _$PointsTransactionToJson(_PointsTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'points': instance.points,
      'timestamp': instance.timestamp.toIso8601String(),
      'source': instance.source,
      'relatedId': instance.relatedId,
    };
