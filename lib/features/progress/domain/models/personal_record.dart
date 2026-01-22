import 'package:freezed_annotation/freezed_annotation.dart';

part 'personal_record.freezed.dart';
part 'personal_record.g.dart';

/// Types of Personal Records
enum PRType {
  @JsonValue('max_weight')
  maxWeight, // Heaviest weight lifted for any reps

  @JsonValue('max_reps')
  maxReps, // Most reps achieved at any weight

  @JsonValue('max_volume')
  maxVolume, // Total volume (sets * reps * weight)

  @JsonValue('estimated_1rm')
  estimated1RM, // Estimated 1 rep max
}

/// Extension for PR type display
extension PRTypeDisplay on PRType {
  String get displayName {
    switch (this) {
      case PRType.maxWeight:
        return 'Carga Máxima';
      case PRType.maxReps:
        return 'Máx. Repetições';
      case PRType.maxVolume:
        return 'Volume Máximo';
      case PRType.estimated1RM:
        return '1RM Estimado';
    }
  }

  String get shortName {
    switch (this) {
      case PRType.maxWeight:
        return 'Peso';
      case PRType.maxReps:
        return 'Reps';
      case PRType.maxVolume:
        return 'Volume';
      case PRType.estimated1RM:
        return '1RM';
    }
  }

  String get unit {
    switch (this) {
      case PRType.maxWeight:
        return 'kg';
      case PRType.maxReps:
        return 'reps';
      case PRType.maxVolume:
        return 'kg';
      case PRType.estimated1RM:
        return 'kg';
    }
  }
}

/// Personal Record model
@freezed
sealed class PersonalRecord with _$PersonalRecord {
  const PersonalRecord._();

  const factory PersonalRecord({
    required String id,
    @JsonKey(name: 'exercise_id') required String exerciseId,
    @JsonKey(name: 'exercise_name') required String exerciseName,
    @JsonKey(name: 'student_id') required String studentId,
    required PRType type,
    required double value,
    @JsonKey(name: 'achieved_at') required DateTime achievedAt,
    @JsonKey(name: 'previous_value') double? previousValue,
    @JsonKey(name: 'previous_date') DateTime? previousDate,
    @JsonKey(name: 'set_number') int? setNumber,
    int? reps,
    @JsonKey(name: 'weight_kg') double? weightKg,
    String? notes,
    @JsonKey(name: 'session_id') String? sessionId,
  }) = _PersonalRecord;

  factory PersonalRecord.fromJson(Map<String, dynamic> json) =>
      _$PersonalRecordFromJson(json);

  /// Calculate improvement percentage
  double? get improvementPercent {
    if (previousValue == null || previousValue == 0) return null;
    return ((value - previousValue!) / previousValue!) * 100;
  }

  /// Format the value with unit
  String get formattedValue {
    if (type == PRType.maxReps) {
      return '${value.toInt()} ${type.unit}';
    }
    return '${value.toStringAsFixed(1)} ${type.unit}';
  }
}

/// Summary of PRs for a single exercise
@freezed
sealed class ExercisePRSummary with _$ExercisePRSummary {
  const ExercisePRSummary._();

  const factory ExercisePRSummary({
    @JsonKey(name: 'exercise_id') required String exerciseId,
    @JsonKey(name: 'exercise_name') required String exerciseName,
    @JsonKey(name: 'exercise_image_url') String? exerciseImageUrl,
    @JsonKey(name: 'muscle_group') String? muscleGroup,

    // Current PRs
    @JsonKey(name: 'pr_max_weight') double? prMaxWeight,
    @JsonKey(name: 'pr_max_weight_date') DateTime? prMaxWeightDate,
    @JsonKey(name: 'pr_max_weight_reps') int? prMaxWeightReps,

    @JsonKey(name: 'pr_max_reps') int? prMaxReps,
    @JsonKey(name: 'pr_max_reps_date') DateTime? prMaxRepsDate,
    @JsonKey(name: 'pr_max_reps_weight') double? prMaxRepsWeight,

    @JsonKey(name: 'pr_max_volume') double? prMaxVolume,
    @JsonKey(name: 'pr_max_volume_date') DateTime? prMaxVolumeDate,

    @JsonKey(name: 'pr_estimated_1rm') double? prEstimated1RM,
    @JsonKey(name: 'pr_estimated_1rm_date') DateTime? prEstimated1RMDate,

    // Statistics
    @JsonKey(name: 'total_sessions') @Default(0) int totalSessions,
    @JsonKey(name: 'last_performed') DateTime? lastPerformed,

    // History
    @JsonKey(name: 'recent_prs') @Default([]) List<PersonalRecord> recentPRs,
  }) = _ExercisePRSummary;

  factory ExercisePRSummary.fromJson(Map<String, dynamic> json) =>
      _$ExercisePRSummaryFromJson(json);

  /// Check if any PR exists
  bool get hasPRs =>
      prMaxWeight != null ||
      prMaxReps != null ||
      prMaxVolume != null ||
      prEstimated1RM != null;

  /// Get the most recent PR date
  DateTime? get mostRecentPRDate {
    final dates = [
      prMaxWeightDate,
      prMaxRepsDate,
      prMaxVolumeDate,
      prEstimated1RMDate,
    ].whereType<DateTime>().toList();

    if (dates.isEmpty) return null;
    dates.sort((a, b) => b.compareTo(a));
    return dates.first;
  }
}

/// List response for PRs
@freezed
sealed class PersonalRecordList with _$PersonalRecordList {
  const factory PersonalRecordList({
    required List<ExercisePRSummary> exercises,
    @JsonKey(name: 'total_prs') @Default(0) int totalPRs,
    @JsonKey(name: 'prs_this_month') @Default(0) int prsThisMonth,
    @JsonKey(name: 'most_improved_exercise') String? mostImprovedExercise,
  }) = _PersonalRecordList;

  factory PersonalRecordList.fromJson(Map<String, dynamic> json) =>
      _$PersonalRecordListFromJson(json);
}

/// PR achieved during workout notification
@freezed
sealed class PRAchievement with _$PRAchievement {
  const PRAchievement._();

  const factory PRAchievement({
    @JsonKey(name: 'exercise_name') required String exerciseName,
    required PRType type,
    @JsonKey(name: 'new_value') required double newValue,
    @JsonKey(name: 'previous_value') double? previousValue,
    @JsonKey(name: 'improvement_percent') double? improvementPercent,
  }) = _PRAchievement;

  factory PRAchievement.fromJson(Map<String, dynamic> json) =>
      _$PRAchievementFromJson(json);

  /// Format improvement message
  String get improvementMessage {
    if (improvementPercent == null) return 'Novo PR!';
    final sign = improvementPercent! > 0 ? '+' : '';
    return '$sign${improvementPercent!.toStringAsFixed(1)}%';
  }
}
