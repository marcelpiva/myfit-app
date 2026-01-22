import 'package:freezed_annotation/freezed_annotation.dart';

part 'milestone.freezed.dart';
part 'milestone.g.dart';

/// Types of milestones users can achieve
enum MilestoneType {
  @JsonValue('weight_goal')
  weightGoal,
  @JsonValue('measurement_goal')
  measurementGoal,
  @JsonValue('personal_record')
  personalRecord,
  @JsonValue('consistency')
  consistency,
  @JsonValue('workout_count')
  workoutCount,
  @JsonValue('strength_gain')
  strengthGain,
  @JsonValue('body_fat')
  bodyFat,
  @JsonValue('custom')
  custom,
}

/// Status of a milestone
enum MilestoneStatus {
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('expired')
  expired,
  @JsonValue('paused')
  paused,
}

/// Represents a fitness milestone/goal
@freezed
sealed class Milestone with _$Milestone {
  const Milestone._();

  const factory Milestone({
    required String id,
    required String userId,
    required MilestoneType type,
    required String title,
    String? description,
    required double targetValue,
    required double currentValue,
    required String unit,
    @Default(MilestoneStatus.active) MilestoneStatus status,
    DateTime? targetDate,
    DateTime? completedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
    // For PR milestones
    String? exerciseId,
    String? exerciseName,
    // For measurement milestones
    String? measurementType,
    // AI-generated insights
    String? aiInsight,
    // Progress history
    @Default([]) List<MilestoneProgress> progressHistory,
  }) = _Milestone;

  factory Milestone.fromJson(Map<String, dynamic> json) =>
      _$MilestoneFromJson(json);

  /// Calculate progress percentage (0-100)
  double get progressPercentage {
    if (targetValue == 0) return 0;

    // For weight loss goals, progress is reversed
    if (type == MilestoneType.weightGoal && targetValue < currentValue) {
      final startValue = progressHistory.isNotEmpty
          ? progressHistory.first.value
          : currentValue;
      if (startValue == targetValue) return 100;
      final progress = ((startValue - currentValue) / (startValue - targetValue)) * 100;
      return progress.clamp(0, 100);
    }

    // For weight gain or other goals
    final progress = (currentValue / targetValue) * 100;
    return progress.clamp(0, 100);
  }

  /// Check if milestone is completed
  bool get isCompleted => status == MilestoneStatus.completed;

  /// Check if milestone is overdue
  bool get isOverdue {
    if (targetDate == null) return false;
    return DateTime.now().isAfter(targetDate!) && status == MilestoneStatus.active;
  }

  /// Days remaining until target date
  int? get daysRemaining {
    if (targetDate == null) return null;
    final diff = targetDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Difference between current and target
  double get remainingValue => (targetValue - currentValue).abs();

  /// Human-readable type name
  String get typeName {
    switch (type) {
      case MilestoneType.weightGoal:
        return 'Meta de Peso';
      case MilestoneType.measurementGoal:
        return 'Meta de Medida';
      case MilestoneType.personalRecord:
        return 'Recorde Pessoal';
      case MilestoneType.consistency:
        return 'Consistência';
      case MilestoneType.workoutCount:
        return 'Total de Treinos';
      case MilestoneType.strengthGain:
        return 'Ganho de Força';
      case MilestoneType.bodyFat:
        return 'Gordura Corporal';
      case MilestoneType.custom:
        return 'Personalizado';
    }
  }

  /// Status display name
  String get statusName {
    switch (status) {
      case MilestoneStatus.active:
        return 'Em Andamento';
      case MilestoneStatus.completed:
        return 'Concluído';
      case MilestoneStatus.expired:
        return 'Expirado';
      case MilestoneStatus.paused:
        return 'Pausado';
    }
  }
}

/// Progress entry for a milestone
@freezed
sealed class MilestoneProgress with _$MilestoneProgress {
  const factory MilestoneProgress({
    required DateTime date,
    required double value,
    String? note,
  }) = _MilestoneProgress;

  factory MilestoneProgress.fromJson(Map<String, dynamic> json) =>
      _$MilestoneProgressFromJson(json);
}

/// AI-generated insight about user's progress
@freezed
sealed class AIInsight with _$AIInsight {
  const AIInsight._();

  const factory AIInsight({
    required String id,
    required String userId,
    required String category,
    required String title,
    required String content,
    @Default([]) List<String> recommendations,
    String? relatedMilestoneId,
    @Default(false) bool isDismissed,
    required DateTime generatedAt,
    DateTime? expiresAt,
    // Sentiment: positive, neutral, warning
    @Default('neutral') String sentiment,
  }) = _AIInsight;

  factory AIInsight.fromJson(Map<String, dynamic> json) =>
      _$AIInsightFromJson(json);

  /// Check if insight is still valid
  bool get isValid {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// Check if insight is positive
  bool get isPositive => sentiment == 'positive';

  /// Check if insight is a warning
  bool get isWarning => sentiment == 'warning';
}

/// Stats summary for milestones
@freezed
sealed class MilestoneStats with _$MilestoneStats {
  const factory MilestoneStats({
    @Default(0) int totalMilestones,
    @Default(0) int completedMilestones,
    @Default(0) int activeMilestones,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    DateTime? lastAchievement,
    @Default([]) List<Milestone> recentAchievements,
  }) = _MilestoneStats;

  factory MilestoneStats.fromJson(Map<String, dynamic> json) =>
      _$MilestoneStatsFromJson(json);
}
