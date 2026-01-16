import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

enum AchievementCategory {
  consistency,
  progress,
  social,
  milestone,
  special,
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

@freezed
sealed class Achievement with _$Achievement {
  const Achievement._();

  const factory Achievement({
    required String id,
    required String name,
    required String description,
    required String icon,
    required AchievementCategory category,
    required AchievementRarity rarity,
    required int pointsReward,
    DateTime? unlockedAt,
    double? progress,
    int? currentValue,
    int? targetValue,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);
}

@freezed
sealed class UserLevel with _$UserLevel {
  const UserLevel._();

  const factory UserLevel({
    required String name,
    required String icon,
    required int minPoints,
    required int maxPoints,
    required int currentPoints,
  }) = _UserLevel;

  factory UserLevel.fromJson(Map<String, dynamic> json) => _$UserLevelFromJson(json);
}

@freezed
sealed class PointsTransaction with _$PointsTransaction {
  const PointsTransaction._();

  const factory PointsTransaction({
    required String id,
    required String description,
    required int points,
    required DateTime timestamp,
    required String source,
    String? relatedId,
  }) = _PointsTransaction;

  factory PointsTransaction.fromJson(Map<String, dynamic> json) => _$PointsTransactionFromJson(json);
}
