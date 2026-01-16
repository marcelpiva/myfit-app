import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_workout.freezed.dart';
part 'trainer_workout.g.dart';

/// Status do treino atribuído
enum WorkoutAssignmentStatus {
  /// Rascunho, ainda não enviado ao aluno
  draft,

  /// Ativo e disponível para o aluno
  active,

  /// Pausado temporariamente
  paused,

  /// Completado (ciclo finalizado)
  completed,

  /// Arquivado
  archived,
}

/// Nível de dificuldade do treino
enum WorkoutDifficulty {
  beginner,
  intermediate,
  advanced,
  elite,
}

/// Tipo de periodização
enum PeriodizationType {
  linear,
  undulating,
  block,
  conjugate,
  custom,
}

/// Treino criado pelo trainer para o aluno
@freezed
sealed class TrainerWorkout with _$TrainerWorkout {
  const TrainerWorkout._();

  const factory TrainerWorkout({
    required String id,

    // === Quem criou ===
    required String trainerId,
    required String trainerName,

    // === Para quem ===
    required String studentId,
    required String studentName,
    String? studentAvatarUrl,

    // === Info básica ===
    required String name,
    String? description,
    @Default(WorkoutDifficulty.intermediate) WorkoutDifficulty difficulty,
    @Default(WorkoutAssignmentStatus.draft) WorkoutAssignmentStatus status,

    // === Exercícios ===
    @Default([]) List<WorkoutExercise> exercises,

    // === Periodização ===
    @Default(PeriodizationType.linear) PeriodizationType periodization,
    int? weekNumber,
    int? totalWeeks,
    String? phase, // Ex: "Hipertrofia", "Força", "Cutting"

    // === Datas ===
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? startDate,
    DateTime? endDate,

    // === Métricas ===
    @Default(0) int totalSessions,
    @Default(0) int completedSessions,
    @Default(0) int estimatedDurationMinutes,

    // === Notas ===
    String? trainerNotes,
    String? studentFeedback,

    // === IA ===
    @Default(false) bool aiGenerated,
    String? aiSuggestionId,

    // === Versioning ===
    @Default(1) int version,
    String? previousVersionId,
  }) = _TrainerWorkout;

  factory TrainerWorkout.fromJson(Map<String, dynamic> json) =>
      _$TrainerWorkoutFromJson(json);

  /// Progresso percentual
  double get progressPercent =>
      totalSessions > 0 ? (completedSessions / totalSessions) * 100 : 0;

  /// Está ativo?
  bool get isActive => status == WorkoutAssignmentStatus.active;

  /// Total de exercícios
  int get exerciseCount => exercises.length;

  /// Volume total (séries * reps)
  int get totalVolume => exercises.fold(
      0, (sum, e) => sum + (e.sets * (e.repsMin ?? e.repsMax ?? 10)));
}

/// Exercício no treino do trainer
@freezed
sealed class WorkoutExercise with _$WorkoutExercise {
  const WorkoutExercise._();

  const factory WorkoutExercise({
    required String id,
    required String exerciseId,
    required String exerciseName,
    String? exerciseImageUrl,
    String? exerciseVideoUrl,

    // === Prescrição ===
    @Default(3) int sets,
    int? repsMin,
    int? repsMax,
    String? repsNote, // Ex: "até a falha", "AMRAP"
    int? restSeconds,

    // === Carga ===
    double? weightKg,
    String? weightNote, // Ex: "RPE 8", "70% 1RM"
    @Default(false) bool dropSet,
    @Default(false) bool superSet,
    String? superSetWith,

    // === Tempo ===
    String? tempo, // Ex: "3-1-2-0"
    int? durationSeconds, // Para exercícios isométricos

    // === Organização ===
    @Default(0) int order,
    String? groupId, // Para agrupar exercícios (superset, circuit)
    String? notes,

    // === Progressão sugerida ===
    String? progressionNote,
    double? nextWeightKg,
    int? nextRepsTarget,
  }) = _WorkoutExercise;

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseFromJson(json);

  /// Descrição formatada das séries/reps
  String get setsRepsDescription {
    if (repsMin != null && repsMax != null && repsMin != repsMax) {
      return '$sets x $repsMin-$repsMax';
    }
    if (repsMax != null) {
      return '$sets x $repsMax';
    }
    if (repsNote != null) {
      return '$sets x $repsNote';
    }
    return '$sets séries';
  }

  /// Descrição da carga
  String get weightDescription {
    if (weightKg != null) {
      return '${weightKg!.toStringAsFixed(1)}kg';
    }
    if (weightNote != null) {
      return weightNote!;
    }
    return '-';
  }
}

/// Progresso do aluno em um exercício específico
@freezed
sealed class ExerciseProgress with _$ExerciseProgress {
  const ExerciseProgress._();

  const factory ExerciseProgress({
    required String id,
    required String exerciseId,
    required String exerciseName,
    required String studentId,

    // === Histórico de cargas ===
    @Default([]) List<ExerciseLog> logs,

    // === PRs (Personal Records) ===
    double? pr1RM,
    double? pr5RM,
    double? pr10RM,
    DateTime? lastPrDate,

    // === Tendência ===
    @Default(ProgressTrend.stable) ProgressTrend trend,
    double? averageWeightLast4Weeks,
    double? averageRepsLast4Weeks,
  }) = _ExerciseProgress;

  factory ExerciseProgress.fromJson(Map<String, dynamic> json) =>
      _$ExerciseProgressFromJson(json);
}

/// Tendência de progresso
enum ProgressTrend {
  improving,
  stable,
  declining,
}

/// Log de um exercício executado
@freezed
sealed class ExerciseLog with _$ExerciseLog {
  const ExerciseLog._();

  const factory ExerciseLog({
    required String id,
    required DateTime date,
    required int sets,
    required int reps,
    double? weightKg,
    int? rpe, // Rate of Perceived Exertion (1-10)
    String? notes,
    @Default(false) bool isPR,
  }) = _ExerciseLog;

  factory ExerciseLog.fromJson(Map<String, dynamic> json) =>
      _$ExerciseLogFromJson(json);
}

/// Progresso geral do aluno
@freezed
sealed class StudentProgress with _$StudentProgress {
  const StudentProgress._();

  const factory StudentProgress({
    required String studentId,
    required String studentName,
    String? studentAvatarUrl,

    // === Métricas gerais ===
    @Default(0) int totalWorkouts,
    @Default(0) int totalSessions,
    @Default(0) int totalMinutes,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,

    // === Frequência ===
    @Default(0) int sessionsThisWeek,
    @Default(0) int sessionsThisMonth,
    double? averageSessionsPerWeek,

    // === Evolução ===
    @Default({}) Map<String, ExerciseProgress> exerciseProgress,
    @Default([]) List<ProgressMilestone> milestones,

    // === Notas do trainer ===
    String? trainerNotes,
    DateTime? lastEvaluation,

    // === Próximas ações sugeridas pela IA ===
    @Default([]) List<AISuggestion> aiSuggestions,
  }) = _StudentProgress;

  factory StudentProgress.fromJson(Map<String, dynamic> json) =>
      _$StudentProgressFromJson(json);

  /// Aderência percentual (sessões feitas / planejadas)
  double get adherencePercent =>
      totalSessions > 0 ? (totalWorkouts / totalSessions) * 100 : 0;
}

/// Marco de progresso
@freezed
sealed class ProgressMilestone with _$ProgressMilestone {
  const ProgressMilestone._();

  const factory ProgressMilestone({
    required String id,
    required String title,
    required String description,
    required DateTime achievedAt,
    String? icon,
    String? exerciseId,
    double? value,
    String? unit,
  }) = _ProgressMilestone;

  factory ProgressMilestone.fromJson(Map<String, dynamic> json) =>
      _$ProgressMilestoneFromJson(json);
}

/// Sugestão da IA para evolução do treino
@freezed
sealed class AISuggestion with _$AISuggestion {
  const AISuggestion._();

  const factory AISuggestion({
    required String id,
    required AISuggestionType type,
    required String title,
    required String description,
    required String rationale,

    // === Dados específicos ===
    String? exerciseId,
    String? exerciseName,
    double? suggestedWeight,
    int? suggestedReps,
    int? suggestedSets,

    // === Novo exercício sugerido ===
    String? newExerciseId,
    String? newExerciseName,
    String? replacesExerciseId,

    // === Meta ===
    required DateTime createdAt,
    @Default(false) bool applied,
    @Default(false) bool dismissed,
    String? dismissReason,
  }) = _AISuggestion;

  factory AISuggestion.fromJson(Map<String, dynamic> json) =>
      _$AISuggestionFromJson(json);
}

/// Tipo de sugestão da IA
enum AISuggestionType {
  /// Aumentar carga
  increaseWeight,

  /// Aumentar volume
  increaseVolume,

  /// Reduzir carga (deload)
  deload,

  /// Trocar exercício
  replaceExercise,

  /// Adicionar exercício
  addExercise,

  /// Remover exercício
  removeExercise,

  /// Mudar periodização
  changePeriodization,

  /// Ajustar frequência
  adjustFrequency,

  /// Focar em grupo muscular fraco
  focusWeakPoint,

  /// Geral
  general,
}
