import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkin_target.freezed.dart';
part 'checkin_target.g.dart';

/// Tipo de alvo do check-in
enum CheckInTargetType {
  /// Academia/Gym
  gym,

  /// Personal Trainer
  trainer,

  /// Aluno/Student
  student,

  /// Aula em grupo
  groupClass,

  /// Sessão agendada
  session,

  /// Equipamento específico
  equipment,
}

/// Papel de quem inicia o check-in
enum CheckInInitiatorRole {
  /// Aluno iniciando
  student,

  /// Personal/Trainer iniciando
  trainer,

  /// Staff da academia iniciando
  staff,

  /// Sistema automático (geolocalização, NFC, etc)
  system,
}

/// Tipo de check-in
enum CheckInType {
  /// Check-in individual (só na academia)
  facility,

  /// Sessão com personal (1:1)
  personalSession,

  /// Aula em grupo
  groupClass,

  /// Treino livre
  freeTraining,

  /// Check-in de trabalho (personal/staff)
  workShift,
}

/// Representa um alvo do check-in
@freezed
sealed class CheckInTarget with _$CheckInTarget {
  const CheckInTarget._();

  const factory CheckInTarget({
    required String id,
    required CheckInTargetType type,
    required String name,
    String? avatarUrl,
    String? subtitle,

    /// Se este alvo requer confirmação bilateral
    @Default(false) bool requiresConfirmation,

    /// Se já foi confirmado
    @Default(false) bool confirmed,

    /// Quando foi confirmado
    DateTime? confirmedAt,

    /// ID de quem confirmou
    String? confirmedBy,
  }) = _CheckInTarget;

  factory CheckInTarget.fromJson(Map<String, dynamic> json) =>
      _$CheckInTargetFromJson(json);

  /// Retorna ícone baseado no tipo
  String get iconName {
    switch (type) {
      case CheckInTargetType.gym:
        return 'building2';
      case CheckInTargetType.trainer:
        return 'user';
      case CheckInTargetType.student:
        return 'user';
      case CheckInTargetType.groupClass:
        return 'users';
      case CheckInTargetType.session:
        return 'calendar';
      case CheckInTargetType.equipment:
        return 'dumbbell';
    }
  }
}

/// Sessão agendada para check-in
@freezed
sealed class ScheduledSession with _$ScheduledSession {
  const ScheduledSession._();

  const factory ScheduledSession({
    required String id,
    required String title,
    required DateTime scheduledAt,
    required int durationMinutes,

    /// Personal trainer da sessão
    String? trainerId,
    String? trainerName,
    String? trainerAvatarUrl,

    /// Aluno da sessão
    String? studentId,
    String? studentName,
    String? studentAvatarUrl,

    /// Academia onde será a sessão
    String? gymId,
    String? gymName,

    /// Aula em grupo (se aplicável)
    String? classId,
    String? className,
    int? classCapacity,
    int? classEnrolled,

    /// Status da sessão
    @Default(SessionStatus.scheduled) SessionStatus status,

    /// Check-in já realizado?
    String? checkInId,
  }) = _ScheduledSession;

  factory ScheduledSession.fromJson(Map<String, dynamic> json) =>
      _$ScheduledSessionFromJson(json);

  bool get isPersonalSession => trainerId != null && studentId != null;
  bool get isGroupClass => classId != null;
  bool get hasCheckIn => checkInId != null;

  Duration get timeUntilStart => scheduledAt.difference(DateTime.now());
  bool get isStartingSoon => timeUntilStart.inMinutes <= 30 && timeUntilStart.inMinutes > 0;
  bool get isNow => timeUntilStart.inMinutes <= 0 && timeUntilStart.inMinutes > -durationMinutes;
  bool get isPast => timeUntilStart.inMinutes < -durationMinutes;
}

enum SessionStatus {
  scheduled,
  checkedIn,
  inProgress,
  completed,
  cancelled,
  noShow,
}

/// Confirmação pendente de check-in
@freezed
sealed class PendingConfirmation with _$PendingConfirmation {
  const PendingConfirmation._();

  const factory PendingConfirmation({
    required String checkInId,
    required String requesterId,
    required String requesterName,
    String? requesterAvatarUrl,
    required CheckInInitiatorRole requesterRole,
    required DateTime requestedAt,
    String? sessionId,
    String? message,

    /// Tipo de confirmação esperada
    @Default(ConfirmationType.presence) ConfirmationType type,
  }) = _PendingConfirmation;

  factory PendingConfirmation.fromJson(Map<String, dynamic> json) =>
      _$PendingConfirmationFromJson(json);

  Duration get waitingTime => DateTime.now().difference(requestedAt);
  bool get isExpired => waitingTime.inMinutes > 30;
}

enum ConfirmationType {
  /// Confirmar presença do aluno
  presence,

  /// Confirmar início de sessão
  sessionStart,

  /// Confirmar término de sessão
  sessionEnd,
}

/// Contexto atual do usuário para check-in
@freezed
sealed class CheckInContext with _$CheckInContext {
  const CheckInContext._();

  const factory CheckInContext({
    /// Papel atual do usuário
    required CheckInInitiatorRole userRole,

    /// Está próximo de uma academia?
    String? nearbyGymId,
    String? nearbyGymName,
    double? distanceToGym,

    /// Sessões agendadas para hoje
    @Default([]) List<ScheduledSession> todaySessions,

    /// Próxima sessão
    ScheduledSession? nextSession,

    /// Confirmações pendentes
    @Default([]) List<PendingConfirmation> pendingConfirmations,

    /// Aulas disponíveis agora
    @Default([]) List<ScheduledSession> availableClasses,

    /// Check-in ativo atual
    String? activeCheckInId,
  }) = _CheckInContext;

  factory CheckInContext.fromJson(Map<String, dynamic> json) =>
      _$CheckInContextFromJson(json);

  bool get hasNearbyGym => nearbyGymId != null;
  bool get hasUpcomingSession => nextSession != null && !nextSession!.isPast;
  bool get hasPendingConfirmations => pendingConfirmations.isNotEmpty;
  bool get hasActiveCheckIn => activeCheckInId != null;

  /// Sugere o melhor tipo de check-in baseado no contexto
  CheckInType get suggestedCheckInType {
    if (nextSession != null && nextSession!.isStartingSoon) {
      if (nextSession!.isPersonalSession) return CheckInType.personalSession;
      if (nextSession!.isGroupClass) return CheckInType.groupClass;
    }
    if (userRole == CheckInInitiatorRole.trainer) {
      return CheckInType.workShift;
    }
    return CheckInType.freeTraining;
  }
}
