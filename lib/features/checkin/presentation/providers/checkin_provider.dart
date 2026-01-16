import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/checkin_service.dart';
import '../../../../core/services/workout_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/check_in.dart';
import '../../domain/models/checkin_target.dart';

// Service provider
final checkinServiceProvider = Provider<CheckinService>((ref) {
  return CheckinService();
});

// Active check-in state
class ActiveCheckInState {
  final CheckIn? checkIn;
  final bool isLoading;
  final String? error;

  const ActiveCheckInState({
    this.checkIn,
    this.isLoading = false,
    this.error,
  });

  ActiveCheckInState copyWith({
    CheckIn? checkIn,
    bool? isLoading,
    String? error,
    bool clearCheckIn = false,
  }) {
    return ActiveCheckInState(
      checkIn: clearCheckIn ? null : (checkIn ?? this.checkIn),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Active check-in notifier
class ActiveCheckInNotifier extends StateNotifier<ActiveCheckInState> {
  final CheckinService _service;

  ActiveCheckInNotifier(this._service) : super(const ActiveCheckInState()) {
    loadActiveCheckIn();
  }

  Future<void> loadActiveCheckIn() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getActiveCheckin();
      if (data != null) {
        final checkIn = _mapToCheckIn(data);
        state = state.copyWith(checkIn: checkIn, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, clearCheckIn: true);
      }
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao verificar check-in');
    }
  }

  void setCheckIn(CheckIn checkIn) {
    state = state.copyWith(checkIn: checkIn);
  }

  void clearCheckIn() {
    state = state.copyWith(clearCheckIn: true);
  }

  void refresh() => loadActiveCheckIn();
}

final activeCheckInNotifierProvider = StateNotifierProvider<ActiveCheckInNotifier, ActiveCheckInState>((ref) {
  final service = ref.watch(checkinServiceProvider);
  return ActiveCheckInNotifier(service);
});

// Simple provider for backward compatibility
final activeCheckInProvider = Provider<CheckIn?>((ref) {
  return ref.watch(activeCheckInNotifierProvider).checkIn;
});

// Check-in history state
class CheckInHistoryState {
  final List<CheckIn> history;
  final bool isLoading;
  final String? error;

  const CheckInHistoryState({
    this.history = const [],
    this.isLoading = false,
    this.error,
  });

  CheckInHistoryState copyWith({
    List<CheckIn>? history,
    bool? isLoading,
    String? error,
  }) {
    return CheckInHistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Check-in history notifier
class CheckInHistoryNotifier extends StateNotifier<CheckInHistoryState> {
  final CheckinService _service;

  CheckInHistoryNotifier(this._service) : super(const CheckInHistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory({int limit = 50, int offset = 0}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getCheckins(limit: limit, offset: offset);
      final history = data.map((e) => _mapToCheckIn(e)).toList();
      state = state.copyWith(history: history, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar histórico');
    }
  }

  void addCheckIn(CheckIn checkIn) {
    state = state.copyWith(history: [checkIn, ...state.history]);
  }

  void updateCheckIn(String id, CheckIn updated) {
    state = state.copyWith(
      history: state.history.map((c) => c.id == id ? updated : c).toList(),
    );
  }

  void refresh() => loadHistory();
}

final checkInHistoryNotifierProvider = StateNotifierProvider<CheckInHistoryNotifier, CheckInHistoryState>((ref) {
  final service = ref.watch(checkinServiceProvider);
  return CheckInHistoryNotifier(service);
});

// Simple provider for backward compatibility
final checkInHistoryProvider = Provider<List<CheckIn>>((ref) {
  return ref.watch(checkInHistoryNotifierProvider).history;
});

// Check-in stats state
class CheckInStatsState {
  final CheckInStats stats;
  final bool isLoading;
  final String? error;

  const CheckInStatsState({
    this.stats = const CheckInStats(
      totalCheckIns: 0,
      currentStreak: 0,
      longestStreak: 0,
      thisWeek: 0,
      thisMonth: 0,
      averageDuration: 0,
      totalPoints: 0,
    ),
    this.isLoading = false,
    this.error,
  });

  CheckInStatsState copyWith({
    CheckInStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return CheckInStatsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Check-in stats notifier
class CheckInStatsNotifier extends StateNotifier<CheckInStatsState> {
  final CheckinService _service;

  CheckInStatsNotifier(this._service) : super(const CheckInStatsState()) {
    loadStats();
  }

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getCheckinStats();
      final stats = CheckInStats(
        totalCheckIns: data['total_checkins'] as int? ?? 0,
        currentStreak: data['current_streak'] as int? ?? 0,
        longestStreak: data['longest_streak'] as int? ?? 0,
        thisWeek: data['this_week'] as int? ?? 0,
        thisMonth: data['this_month'] as int? ?? 0,
        averageDuration: (data['average_duration'] as num?)?.toDouble() ?? 0,
        totalPoints: data['total_points'] as int? ?? 0,
      );
      state = state.copyWith(stats: stats, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar estatísticas');
    }
  }

  void refresh() => loadStats();
}

final checkInStatsNotifierProvider = StateNotifierProvider<CheckInStatsNotifier, CheckInStatsState>((ref) {
  final service = ref.watch(checkinServiceProvider);
  return CheckInStatsNotifier(service);
});

// Simple provider for backward compatibility
final checkInStatsProvider = Provider<CheckInStats>((ref) {
  return ref.watch(checkInStatsNotifierProvider).stats;
});

// Gyms state for nearby detection
class GymsState {
  final List<GymLocation> gyms;
  final GymLocation? nearbyGym;
  final bool isLoading;
  final String? error;

  const GymsState({
    this.gyms = const [],
    this.nearbyGym,
    this.isLoading = false,
    this.error,
  });

  GymsState copyWith({
    List<GymLocation>? gyms,
    GymLocation? nearbyGym,
    bool? isLoading,
    String? error,
    bool clearNearby = false,
  }) {
    return GymsState(
      gyms: gyms ?? this.gyms,
      nearbyGym: clearNearby ? null : (nearbyGym ?? this.nearbyGym),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Gyms notifier
class GymsNotifier extends StateNotifier<GymsState> {
  final CheckinService _service;

  GymsNotifier(this._service) : super(const GymsState()) {
    loadGyms();
  }

  Future<void> loadGyms() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getGyms();
      final gyms = data.map((e) => GymLocation(
        id: e['id'] as String,
        name: e['name'] as String,
        latitude: (e['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (e['longitude'] as num?)?.toDouble() ?? 0,
        radiusMeters: (e['radius_meters'] as num?)?.toDouble() ?? 50,
        address: e['address'] as String?,
      )).toList();

      state = state.copyWith(gyms: gyms, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar academias');
    }
  }

  void setNearbyGym(GymLocation? gym) {
    state = state.copyWith(nearbyGym: gym, clearNearby: gym == null);
  }

  void refresh() => loadGyms();
}

final gymsNotifierProvider = StateNotifierProvider<GymsNotifier, GymsState>((ref) {
  final service = ref.watch(checkinServiceProvider);
  return GymsNotifier(service);
});

// Simple provider for backward compatibility
final nearbyGymProvider = Provider<GymLocation?>((ref) {
  return ref.watch(gymsNotifierProvider).nearbyGym;
});

// Workout service provider for checkin
final checkinWorkoutServiceProvider = Provider<WorkoutService>((ref) {
  return WorkoutService();
});

// Today's scheduled workout (from workouts feature)
final todayWorkoutProvider = FutureProvider<Map<String, String>?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;

  try {
    final workoutService = ref.watch(checkinWorkoutServiceProvider);
    final assignments = await workoutService.getWorkoutAssignments(
      studentId: currentUser.id,
      active: true,
    );

    if (assignments.isEmpty) return null;

    // Find today's workout or the first active one
    final today = DateTime.now();
    for (final assignment in assignments) {
      final startDate = assignment['start_date'] as String?;
      final endDate = assignment['end_date'] as String?;

      // Check if today is within the assignment date range
      if (startDate != null) {
        final start = DateTime.tryParse(startDate);
        if (start != null && today.isBefore(start)) continue;
      }
      if (endDate != null) {
        final end = DateTime.tryParse(endDate);
        if (end != null && today.isAfter(end)) continue;
      }

      // This assignment is valid for today
      final workout = assignment['workout'] as Map<String, dynamic>?;
      if (workout != null) {
        return {
          'id': workout['id']?.toString() ?? '',
          'name': workout['name']?.toString() ?? 'Treino do dia',
          'description': workout['description']?.toString() ?? '',
        };
      }
    }

    // If no specific date match, return the first active assignment
    final firstAssignment = assignments.first;
    final workout = firstAssignment['workout'] as Map<String, dynamic>?;
    if (workout != null) {
      return {
        'id': workout['id']?.toString() ?? '',
        'name': workout['name']?.toString() ?? 'Treino do dia',
        'description': workout['description']?.toString() ?? '',
      };
    }

    return null;
  } catch (_) {
    return null; // Fail silently - todayWorkout is not critical
  }
});

// Check-in actions
class CheckInActionsNotifier extends StateNotifier<bool> {
  final CheckinService _service;
  final Ref _ref;

  CheckInActionsNotifier(this._service, this._ref) : super(false);

  Future<CheckIn?> performCheckInManual({
    required String gymId,
    String? notes,
  }) async {
    state = true;
    try {
      final data = await _service.checkinManual(gymId: gymId, notes: notes);
      final checkIn = _mapToCheckIn(data);

      _ref.read(activeCheckInNotifierProvider.notifier).setCheckIn(checkIn);
      _ref.read(checkInHistoryNotifierProvider.notifier).addCheckIn(checkIn);

      state = false;
      return checkIn;
    } on ApiException {
      state = false;
      rethrow;
    } catch (_) {
      state = false;
      throw const ServerException('Erro ao fazer check-in');
    }
  }

  Future<CheckIn?> performCheckInByCode(String code) async {
    state = true;
    try {
      final data = await _service.checkinByCode(code);
      final checkIn = _mapToCheckIn(data);

      _ref.read(activeCheckInNotifierProvider.notifier).setCheckIn(checkIn);
      _ref.read(checkInHistoryNotifierProvider.notifier).addCheckIn(checkIn);

      state = false;
      return checkIn;
    } on ApiException {
      state = false;
      rethrow;
    } catch (_) {
      state = false;
      throw const ServerException('Código inválido ou expirado');
    }
  }

  Future<CheckIn?> performCheckInByLocation({
    required double latitude,
    required double longitude,
  }) async {
    state = true;
    try {
      final data = await _service.checkinByLocation(
        latitude: latitude,
        longitude: longitude,
      );
      final checkIn = _mapToCheckIn(data);

      _ref.read(activeCheckInNotifierProvider.notifier).setCheckIn(checkIn);
      _ref.read(checkInHistoryNotifierProvider.notifier).addCheckIn(checkIn);

      state = false;
      return checkIn;
    } on ApiException {
      state = false;
      rethrow;
    } catch (_) {
      state = false;
      throw const ServerException('Você não está próximo de uma academia');
    }
  }

  Future<void> performCheckOut({String? notes}) async {
    state = true;
    try {
      final data = await _service.checkout(notes: notes);
      final checkIn = _mapToCheckIn(data);

      _ref.read(activeCheckInNotifierProvider.notifier).clearCheckIn();
      _ref.read(checkInHistoryNotifierProvider.notifier).updateCheckIn(checkIn.id, checkIn);
      _ref.read(checkInStatsNotifierProvider.notifier).refresh();

      state = false;
    } on ApiException {
      state = false;
      rethrow;
    } catch (_) {
      state = false;
      throw const ServerException('Erro ao fazer checkout');
    }
  }
}

final checkInActionsProvider = StateNotifierProvider<CheckInActionsNotifier, bool>((ref) {
  final service = ref.watch(checkinServiceProvider);
  return CheckInActionsNotifier(service, ref);
});

// Helper function to map API response to CheckIn model
CheckIn _mapToCheckIn(Map<String, dynamic> data) {
  return CheckIn(
    id: data['id'] as String,
    initiatorId: data['user_id'] as String? ?? '',
    initiatorName: data['user_name'] as String? ?? '',
    initiatorAvatarUrl: data['user_avatar_url'] as String?,
    initiatorRole: _parseInitiatorRole(data['initiator_role'] as String?),
    targets: _parseTargets(data['targets'] as List?),
    type: _parseCheckInType(data['type'] as String?),
    method: _parseMethod(data['method'] as String?),
    source: _parseSource(data['source'] as String?),
    organizationId: data['gym_id'] as String? ?? data['organization_id'] as String? ?? '',
    organizationName: data['gym_name'] as String? ?? data['organization_name'] as String? ?? '',
    sessionId: data['session_id'] as String?,
    classId: data['class_id'] as String?,
    workoutId: data['workout_id'] as String?,
    workoutName: data['workout_name'] as String?,
    latitude: (data['latitude'] as num?)?.toDouble(),
    longitude: (data['longitude'] as num?)?.toDouble(),
    status: _parseStatus(data['status'] as String?),
    timestamp: DateTime.tryParse(data['checked_in_at'] as String? ?? '') ?? DateTime.now(),
    confirmedAt: data['confirmed_at'] != null ? DateTime.tryParse(data['confirmed_at'] as String) : null,
    checkOutTime: data['checked_out_at'] != null ? DateTime.tryParse(data['checked_out_at'] as String) : null,
    durationMinutes: data['duration_minutes'] as int?,
    pointsEarned: data['points_earned'] as int? ?? 0,
    badgesEarned: (data['badges_earned'] as List?)?.cast<String>() ?? [],
    memberId: data['user_id'] as String?,
    memberName: data['user_name'] as String?,
    memberAvatarUrl: data['user_avatar_url'] as String?,
    trainerId: data['trainer_id'] as String?,
    trainerName: data['trainer_name'] as String?,
  );
}

CheckInInitiatorRole _parseInitiatorRole(String? role) {
  switch (role?.toLowerCase()) {
    case 'student':
      return CheckInInitiatorRole.student;
    case 'trainer':
      return CheckInInitiatorRole.trainer;
    case 'staff':
      return CheckInInitiatorRole.staff;
    case 'system':
      return CheckInInitiatorRole.system;
    default:
      return CheckInInitiatorRole.student;
  }
}

List<CheckInTarget> _parseTargets(List? targets) {
  if (targets == null) return [];
  return targets.map((t) {
    final map = t as Map<String, dynamic>;
    return CheckInTarget(
      id: map['id'] as String,
      type: _parseTargetType(map['type'] as String?),
      name: map['name'] as String,
      avatarUrl: map['avatar_url'] as String?,
      subtitle: map['subtitle'] as String?,
      requiresConfirmation: map['requires_confirmation'] as bool? ?? false,
      confirmed: map['confirmed'] as bool? ?? false,
      confirmedAt: map['confirmed_at'] != null ? DateTime.tryParse(map['confirmed_at'] as String) : null,
      confirmedBy: map['confirmed_by'] as String?,
    );
  }).toList();
}

CheckInTargetType _parseTargetType(String? type) {
  switch (type?.toLowerCase()) {
    case 'gym':
      return CheckInTargetType.gym;
    case 'trainer':
      return CheckInTargetType.trainer;
    case 'student':
      return CheckInTargetType.student;
    case 'group_class':
      return CheckInTargetType.groupClass;
    case 'session':
      return CheckInTargetType.session;
    case 'equipment':
      return CheckInTargetType.equipment;
    default:
      return CheckInTargetType.gym;
  }
}

CheckInType _parseCheckInType(String? type) {
  switch (type?.toLowerCase()) {
    case 'facility':
      return CheckInType.facility;
    case 'personal_session':
      return CheckInType.personalSession;
    case 'group_class':
      return CheckInType.groupClass;
    case 'free_training':
      return CheckInType.freeTraining;
    case 'work_shift':
      return CheckInType.workShift;
    default:
      return CheckInType.freeTraining;
  }
}

CheckInMethod _parseMethod(String? method) {
  switch (method?.toUpperCase()) {
    case 'QR_CODE':
      return CheckInMethod.qrCode;
    case 'MANUAL':
    case 'MANUAL_CODE':
      return CheckInMethod.manualCode;
    case 'LOCATION':
      return CheckInMethod.location;
    case 'REQUEST':
      return CheckInMethod.request;
    case 'NFC':
      return CheckInMethod.nfc;
    case 'SCHEDULED':
      return CheckInMethod.scheduled;
    default:
      return CheckInMethod.manualCode;
  }
}

CheckInSource _parseSource(String? source) {
  switch (source?.toLowerCase()) {
    case 'app_student':
      return CheckInSource.appStudent;
    case 'app_trainer':
      return CheckInSource.appTrainer;
    case 'totem':
      return CheckInSource.totem;
    case 'qr_code':
      return CheckInSource.qrCode;
    default:
      return CheckInSource.appStudent;
  }
}

CheckInStatus _parseStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'pending':
      return CheckInStatus.pending;
    case 'verified':
      return CheckInStatus.verified;
    case 'active':
      return CheckInStatus.active;
    case 'completed':
      return CheckInStatus.completed;
    case 'cancelled':
      return CheckInStatus.cancelled;
    case 'expired':
      return CheckInStatus.expired;
    default:
      return CheckInStatus.pending;
  }
}
