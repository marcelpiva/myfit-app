import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_item.freezed.dart';
part 'activity_item.g.dart';

/// Types of activities that can appear in the feed
enum ActivityType {
  workoutCompleted,
  personalRecord,
  achievementUnlocked,
  milestoneReached,
  streakMilestone,
  gymCheckin,
  firstWorkout,
  levelUp,
}

/// An activity item in the social feed
@freezed
sealed class ActivityItem with _$ActivityItem {
  const ActivityItem._();

  const factory ActivityItem({
    required String id,
    required ActivityType type,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required DateTime timestamp,
    required Map<String, dynamic> data,
    @Default(0) int reactions,
    @Default(false) bool hasReacted,
    @Default([]) List<String> comments,
  }) = _ActivityItem;

  factory ActivityItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemFromJson(json);
}

/// Helper extension for activity display
extension ActivityItemX on ActivityItem {
  String get title {
    switch (type) {
      case ActivityType.workoutCompleted:
        return 'Treino completo!';
      case ActivityType.personalRecord:
        return 'Novo recorde pessoal!';
      case ActivityType.achievementUnlocked:
        return 'Conquista desbloqueada!';
      case ActivityType.milestoneReached:
        return 'Marco alcançado!';
      case ActivityType.streakMilestone:
        return 'Sequência mantida!';
      case ActivityType.gymCheckin:
        return 'Check-in na academia!';
      case ActivityType.firstWorkout:
        return 'Primeiro treino!';
      case ActivityType.levelUp:
        return 'Subiu de nível!';
    }
  }

  String get description {
    switch (type) {
      case ActivityType.workoutCompleted:
        final workoutName = data['workout_name'] as String? ?? 'Treino';
        final duration = data['duration_minutes'] as int? ?? 0;
        final exerciseCount = data['exercise_count'] as int? ?? 0;
        return '$workoutName • ${duration}min • $exerciseCount exercícios';
      case ActivityType.personalRecord:
        final exerciseName = data['exercise_name'] as String? ?? 'Exercício';
        final value = data['value'] as num? ?? 0;
        final unit = data['unit'] as String? ?? 'kg';
        return '$exerciseName: $value$unit';
      case ActivityType.achievementUnlocked:
        final achievementName = data['achievement_name'] as String? ?? 'Conquista';
        return achievementName;
      case ActivityType.milestoneReached:
        final milestoneName = data['milestone_name'] as String? ?? 'Marco';
        return milestoneName;
      case ActivityType.streakMilestone:
        final days = data['days'] as int? ?? 0;
        return '$days dias consecutivos!';
      case ActivityType.gymCheckin:
        final gymName = data['gym_name'] as String? ?? 'Academia';
        return gymName;
      case ActivityType.firstWorkout:
        final workoutName = data['workout_name'] as String? ?? 'Treino';
        return '$workoutName - Parabéns pelo primeiro passo!';
      case ActivityType.levelUp:
        final level = data['level'] as int? ?? 1;
        return 'Nível $level alcançado!';
    }
  }

  String get emoji {
    switch (type) {
      case ActivityType.workoutCompleted:
        return '💪';
      case ActivityType.personalRecord:
        return '🏆';
      case ActivityType.achievementUnlocked:
        return '🎖️';
      case ActivityType.milestoneReached:
        return '🎯';
      case ActivityType.streakMilestone:
        return '🔥';
      case ActivityType.gymCheckin:
        return '📍';
      case ActivityType.firstWorkout:
        return '🌟';
      case ActivityType.levelUp:
        return '⬆️';
    }
  }
}
