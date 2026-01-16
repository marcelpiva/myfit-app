import 'package:freezed_annotation/freezed_annotation.dart';

import 'checkin_target.dart';

part 'check_in.freezed.dart';
part 'check_in.g.dart';

enum CheckInSource {
  appStudent,
  appTrainer,
  totem,
  qrCode,
}

enum CheckInMethod {
  qrCode,
  manualCode,
  location,
  request,
  nfc,
  scheduled,
}

enum CheckInStatus {
  /// Aguardando confirmação
  pending,

  /// Confirmado/Verificado
  verified,

  /// Em andamento (sessão ativa)
  active,

  /// Completado
  completed,

  /// Cancelado
  cancelled,

  /// Expirado (sem confirmação)
  expired,
}

@freezed
sealed class CheckIn with _$CheckIn {
  const CheckIn._();

  const factory CheckIn({
    required String id,

    // === Quem iniciou ===
    required String initiatorId,
    required String initiatorName,
    String? initiatorAvatarUrl,
    @Default(CheckInInitiatorRole.student) CheckInInitiatorRole initiatorRole,

    // === Alvos do check-in (pode ser múltiplos) ===
    @Default([]) List<CheckInTarget> targets,

    // === Tipo e método ===
    @Default(CheckInType.freeTraining) CheckInType type,
    @Default(CheckInMethod.qrCode) CheckInMethod method,
    @Default(CheckInSource.appStudent) CheckInSource source,

    // === Organização principal ===
    required String organizationId,
    required String organizationName,

    // === Sessão vinculada (se aplicável) ===
    String? sessionId,
    String? classId,

    // === Treino vinculado ===
    String? workoutId,
    String? workoutName,

    // === Localização ===
    double? latitude,
    double? longitude,

    // === Status e timestamps ===
    @Default(CheckInStatus.pending) CheckInStatus status,
    required DateTime timestamp,
    DateTime? confirmedAt,
    DateTime? checkOutTime,
    int? durationMinutes,

    // === Gamificação ===
    @Default(0) int pointsEarned,
    @Default([]) List<String> badgesEarned,

    // === Campos legados para compatibilidade ===
    String? memberId,
    String? memberName,
    String? memberAvatarUrl,
    String? trainerId,
    String? trainerName,
  }) = _CheckIn;

  factory CheckIn.fromJson(Map<String, dynamic> json) => _$CheckInFromJson(json);

  /// Verifica se todos os alvos que requerem confirmação já confirmaram
  bool get isFullyConfirmed {
    final requiresConfirmation = targets.where((t) => t.requiresConfirmation);
    if (requiresConfirmation.isEmpty) return true;
    return requiresConfirmation.every((t) => t.confirmed);
  }

  /// Retorna alvos pendentes de confirmação
  List<CheckInTarget> get pendingTargets =>
      targets.where((t) => t.requiresConfirmation && !t.confirmed).toList();

  /// Verifica se inclui personal trainer
  bool get includesTrainer =>
      targets.any((t) => t.type == CheckInTargetType.trainer);

  /// Verifica se inclui academia
  bool get includesGym =>
      targets.any((t) => t.type == CheckInTargetType.gym);

  /// Verifica se é uma sessão de personal
  bool get isPersonalSession => type == CheckInType.personalSession;

  /// Verifica se é uma aula em grupo
  bool get isGroupClass => type == CheckInType.groupClass;

  /// Nome formatado dos alvos
  String get targetNames => targets.map((t) => t.name).join(' + ');
}

@freezed
sealed class CheckInStats with _$CheckInStats {
  const CheckInStats._();

  const factory CheckInStats({
    required int totalCheckIns,
    required int currentStreak,
    required int longestStreak,
    required int thisWeek,
    required int thisMonth,
    required double averageDuration,
    required int totalPoints,
  }) = _CheckInStats;

  factory CheckInStats.fromJson(Map<String, dynamic> json) => _$CheckInStatsFromJson(json);
}

@freezed
sealed class GymLocation with _$GymLocation {
  const GymLocation._();

  const factory GymLocation({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required double radiusMeters,
    String? address,
  }) = _GymLocation;

  factory GymLocation.fromJson(Map<String, dynamic> json) => _$GymLocationFromJson(json);
}
