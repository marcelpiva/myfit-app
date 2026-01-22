import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_dashboard.freezed.dart';
part 'student_dashboard.g.dart';

/// Student statistics
@freezed
sealed class StudentStats with _$StudentStats {
  const StudentStats._();

  const factory StudentStats({
    @JsonKey(name: 'total_workouts') @Default(0) int totalWorkouts,
    @JsonKey(name: 'adherence_percent') @Default(0) int adherencePercent,
    @JsonKey(name: 'weight_change_kg') double? weightChangeKg,
    @JsonKey(name: 'current_streak') @Default(0) int currentStreak,
  }) = _StudentStats;

  factory StudentStats.fromJson(Map<String, dynamic> json) =>
      _$StudentStatsFromJson(json);
}

/// Today's workout info
@freezed
sealed class TodayWorkout with _$TodayWorkout {
  const TodayWorkout._();

  const factory TodayWorkout({
    required String id,
    required String name,
    required String label,
    @JsonKey(name: 'duration_minutes') @Default(60) int durationMinutes,
    @JsonKey(name: 'exercises_count') @Default(0) int exercisesCount,
    @JsonKey(name: 'plan_id') String? planId,
    @JsonKey(name: 'workout_id') required String workoutId,
  }) = _TodayWorkout;

  factory TodayWorkout.fromJson(Map<String, dynamic> json) =>
      _$TodayWorkoutFromJson(json);
}

/// Weekly workout progress
@freezed
sealed class WeeklyProgress with _$WeeklyProgress {
  const WeeklyProgress._();

  const factory WeeklyProgress({
    @Default(0) int completed,
    @Default(5) int target,
    @Default([]) List<String?> days,
  }) = _WeeklyProgress;

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) =>
      _$WeeklyProgressFromJson(json);
}

/// Recent activity item
@freezed
sealed class RecentActivity with _$RecentActivity {
  const RecentActivity._();

  const factory RecentActivity({
    required String title,
    required String subtitle,
    required String time,
    required String type,
  }) = _RecentActivity;

  factory RecentActivity.fromJson(Map<String, dynamic> json) =>
      _$RecentActivityFromJson(json);
}

/// Trainer info for student dashboard
@freezed
sealed class TrainerInfo with _$TrainerInfo {
  const TrainerInfo._();

  const factory TrainerInfo({
    required String id,
    required String name,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'is_online') @Default(false) bool isOnline,
  }) = _TrainerInfo;

  factory TrainerInfo.fromJson(Map<String, dynamic> json) =>
      _$TrainerInfoFromJson(json);
}

/// Training mode enum
enum TrainingMode {
  @JsonValue('presencial')
  presencial,
  @JsonValue('online')
  online,
  @JsonValue('hibrido')
  hibrido,
}

/// Current plan progress
@freezed
sealed class PlanProgress with _$PlanProgress {
  const PlanProgress._();

  const factory PlanProgress({
    @JsonKey(name: 'plan_id') required String planId,
    @JsonKey(name: 'plan_name') required String planName,
    @JsonKey(name: 'current_week') @Default(1) int currentWeek,
    @JsonKey(name: 'total_weeks') int? totalWeeks,
    @JsonKey(name: 'percent_complete') @Default(0) int percentComplete,
    @JsonKey(name: 'training_mode') @Default(TrainingMode.presencial) TrainingMode trainingMode,
  }) = _PlanProgress;

  factory PlanProgress.fromJson(Map<String, dynamic> json) =>
      _$PlanProgressFromJson(json);
}

/// Consolidated student dashboard response
@freezed
sealed class StudentDashboard with _$StudentDashboard {
  const StudentDashboard._();

  const factory StudentDashboard({
    required StudentStats stats,
    @JsonKey(name: 'today_workout') TodayWorkout? todayWorkout,
    @JsonKey(name: 'weekly_progress') required WeeklyProgress weeklyProgress,
    @JsonKey(name: 'recent_activity') @Default([]) List<RecentActivity> recentActivity,
    TrainerInfo? trainer,
    @JsonKey(name: 'plan_progress') PlanProgress? planProgress,
    @JsonKey(name: 'unread_notes_count') @Default(0) int unreadNotesCount,
  }) = _StudentDashboard;

  factory StudentDashboard.fromJson(Map<String, dynamic> json) =>
      _$StudentDashboardFromJson(json);
}
