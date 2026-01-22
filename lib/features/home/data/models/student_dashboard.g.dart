// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudentStats _$StudentStatsFromJson(Map<String, dynamic> json) =>
    _StudentStats(
      totalWorkouts: (json['total_workouts'] as num?)?.toInt() ?? 0,
      adherencePercent: (json['adherence_percent'] as num?)?.toInt() ?? 0,
      weightChangeKg: (json['weight_change_kg'] as num?)?.toDouble(),
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$StudentStatsToJson(_StudentStats instance) =>
    <String, dynamic>{
      'total_workouts': instance.totalWorkouts,
      'adherence_percent': instance.adherencePercent,
      'weight_change_kg': instance.weightChangeKg,
      'current_streak': instance.currentStreak,
    };

_TodayWorkout _$TodayWorkoutFromJson(Map<String, dynamic> json) =>
    _TodayWorkout(
      id: json['id'] as String,
      name: json['name'] as String,
      label: json['label'] as String,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 60,
      exercisesCount: (json['exercises_count'] as num?)?.toInt() ?? 0,
      planId: json['plan_id'] as String?,
      workoutId: json['workout_id'] as String,
    );

Map<String, dynamic> _$TodayWorkoutToJson(_TodayWorkout instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'label': instance.label,
      'duration_minutes': instance.durationMinutes,
      'exercises_count': instance.exercisesCount,
      'plan_id': instance.planId,
      'workout_id': instance.workoutId,
    };

_WeeklyProgress _$WeeklyProgressFromJson(Map<String, dynamic> json) =>
    _WeeklyProgress(
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      target: (json['target'] as num?)?.toInt() ?? 5,
      days:
          (json['days'] as List<dynamic>?)?.map((e) => e as String?).toList() ??
          const [],
    );

Map<String, dynamic> _$WeeklyProgressToJson(_WeeklyProgress instance) =>
    <String, dynamic>{
      'completed': instance.completed,
      'target': instance.target,
      'days': instance.days,
    };

_RecentActivity _$RecentActivityFromJson(Map<String, dynamic> json) =>
    _RecentActivity(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      time: json['time'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$RecentActivityToJson(_RecentActivity instance) =>
    <String, dynamic>{
      'title': instance.title,
      'subtitle': instance.subtitle,
      'time': instance.time,
      'type': instance.type,
    };

_TrainerInfo _$TrainerInfoFromJson(Map<String, dynamic> json) => _TrainerInfo(
  id: json['id'] as String,
  name: json['name'] as String,
  avatarUrl: json['avatar_url'] as String?,
  isOnline: json['is_online'] as bool? ?? false,
);

Map<String, dynamic> _$TrainerInfoToJson(_TrainerInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatar_url': instance.avatarUrl,
      'is_online': instance.isOnline,
    };

_PlanProgress _$PlanProgressFromJson(Map<String, dynamic> json) =>
    _PlanProgress(
      planId: json['plan_id'] as String,
      planName: json['plan_name'] as String,
      currentWeek: (json['current_week'] as num?)?.toInt() ?? 1,
      totalWeeks: (json['total_weeks'] as num?)?.toInt(),
      percentComplete: (json['percent_complete'] as num?)?.toInt() ?? 0,
      trainingMode:
          $enumDecodeNullable(_$TrainingModeEnumMap, json['training_mode']) ??
          TrainingMode.presencial,
    );

Map<String, dynamic> _$PlanProgressToJson(_PlanProgress instance) =>
    <String, dynamic>{
      'plan_id': instance.planId,
      'plan_name': instance.planName,
      'current_week': instance.currentWeek,
      'total_weeks': instance.totalWeeks,
      'percent_complete': instance.percentComplete,
      'training_mode': _$TrainingModeEnumMap[instance.trainingMode]!,
    };

const _$TrainingModeEnumMap = {
  TrainingMode.presencial: 'presencial',
  TrainingMode.online: 'online',
  TrainingMode.hibrido: 'hibrido',
};

_StudentDashboard _$StudentDashboardFromJson(
  Map<String, dynamic> json,
) => _StudentDashboard(
  stats: StudentStats.fromJson(json['stats'] as Map<String, dynamic>),
  todayWorkout: json['today_workout'] == null
      ? null
      : TodayWorkout.fromJson(json['today_workout'] as Map<String, dynamic>),
  weeklyProgress: WeeklyProgress.fromJson(
    json['weekly_progress'] as Map<String, dynamic>,
  ),
  recentActivity:
      (json['recent_activity'] as List<dynamic>?)
          ?.map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  trainer: json['trainer'] == null
      ? null
      : TrainerInfo.fromJson(json['trainer'] as Map<String, dynamic>),
  planProgress: json['plan_progress'] == null
      ? null
      : PlanProgress.fromJson(json['plan_progress'] as Map<String, dynamic>),
  unreadNotesCount: (json['unread_notes_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$StudentDashboardToJson(_StudentDashboard instance) =>
    <String, dynamic>{
      'stats': instance.stats,
      'today_workout': instance.todayWorkout,
      'weekly_progress': instance.weeklyProgress,
      'recent_activity': instance.recentActivity,
      'trainer': instance.trainer,
      'plan_progress': instance.planProgress,
      'unread_notes_count': instance.unreadNotesCount,
    };
