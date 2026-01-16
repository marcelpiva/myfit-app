import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/checkin_service.dart';
import '../../../../core/services/schedule_service.dart';
import '../../domain/models/checkin_target.dart';

// Service providers
final _checkinServiceProvider = Provider<CheckinService>((ref) {
  return CheckinService();
});

final _scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService();
});

/// Provider que detecta o contexto atual do usuário para check-in
final checkInContextProvider = StateNotifierProvider<CheckInContextNotifier, CheckInContext>((ref) {
  final checkinService = ref.watch(_checkinServiceProvider);
  final scheduleService = ref.watch(_scheduleServiceProvider);
  return CheckInContextNotifier(checkinService, scheduleService);
});

class CheckInContextNotifier extends StateNotifier<CheckInContext> {
  final CheckinService _checkinService;
  final ScheduleService _scheduleService;

  CheckInContextNotifier(this._checkinService, this._scheduleService)
      : super(const CheckInContext(userRole: CheckInInitiatorRole.student)) {
    _loadContext();
  }

  Future<void> _loadContext() async {
    try {
      // Load active check-in
      final activeCheckin = await _checkinService.getActiveCheckin();
      final activeCheckInId = activeCheckin?['id'] as String?;

      // Load today's appointments/sessions
      final todayAppointments = await _scheduleService.getAppointmentsForDay(DateTime.now());
      final todaySessions = todayAppointments.map((apt) => _appointmentToSession(apt)).toList();

      // Find next session
      final now = DateTime.now();
      final upcomingSessions = todaySessions.where((s) => s.scheduledAt.isAfter(now)).toList();
      upcomingSessions.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      final nextSession = upcomingSessions.isNotEmpty ? upcomingSessions.first : null;

      // Load pending confirmations
      final pendingRequests = await _checkinService.getPendingRequests();
      final pendingConfirmations = pendingRequests.map((req) => PendingConfirmation(
        checkInId: req['id']?.toString() ?? '',
        requesterId: req['requester_id']?.toString() ?? '',
        requesterName: req['requester_name']?.toString() ?? 'Aluno',
        requesterRole: CheckInInitiatorRole.student,
        requestedAt: DateTime.tryParse(req['created_at']?.toString() ?? '') ?? DateTime.now(),
        message: req['reason']?.toString(),
      )).toList();

      state = state.copyWith(
        activeCheckInId: activeCheckInId,
        todaySessions: todaySessions,
        nextSession: nextSession,
        pendingConfirmations: pendingConfirmations,
      );
    } on ApiException catch (e) {
      // If API fails, start with empty state (user can retry)
      state = state.copyWith();
    } catch (e) {
      // Handle any other errors gracefully
      state = state.copyWith();
    }
  }

  ScheduledSession _appointmentToSession(Map<String, dynamic> apt) {
    return ScheduledSession(
      id: apt['id']?.toString() ?? '',
      title: apt['workout_type']?.toString() ?? apt['title']?.toString() ?? 'Sessão',
      scheduledAt: DateTime.tryParse(apt['date_time']?.toString() ?? '') ?? DateTime.now(),
      durationMinutes: apt['duration_minutes'] as int? ?? 60,
      trainerId: apt['trainer_id']?.toString(),
      trainerName: apt['trainer_name']?.toString(),
      studentId: apt['student_id']?.toString(),
      studentName: apt['student_name']?.toString(),
      gymId: apt['gym_id']?.toString(),
      gymName: apt['gym_name']?.toString(),
    );
  }

  void setUserRole(CheckInInitiatorRole role) {
    state = state.copyWith(userRole: role);
  }

  void updateLocation(double lat, double lng) {
    // TODO: Check proximity to gyms via location API
  }

  Future<void> refreshSessions() async {
    await _loadContext();
  }

  void addPendingConfirmation(PendingConfirmation confirmation) {
    state = state.copyWith(
      pendingConfirmations: [...state.pendingConfirmations, confirmation],
    );
  }

  void removePendingConfirmation(String checkInId) {
    state = state.copyWith(
      pendingConfirmations: state.pendingConfirmations
          .where((c) => c.checkInId != checkInId)
          .toList(),
    );
  }

  void setActiveCheckIn(String? checkInId) {
    state = state.copyWith(activeCheckInId: checkInId);
  }

  void refresh() => _loadContext();
}

/// Provider para contexto do trainer
final trainerContextProvider = StateNotifierProvider<TrainerContextNotifier, TrainerContext>((ref) {
  final checkinService = ref.watch(_checkinServiceProvider);
  final scheduleService = ref.watch(_scheduleServiceProvider);
  return TrainerContextNotifier(checkinService, scheduleService);
});

class TrainerContextNotifier extends StateNotifier<TrainerContext> {
  final CheckinService _checkinService;
  final ScheduleService _scheduleService;

  TrainerContextNotifier(this._checkinService, this._scheduleService) : super(const TrainerContext()) {
    _loadContext();
  }

  Future<void> _loadContext() async {
    try {
      // Load today's appointments
      final todayAppointments = await _scheduleService.getAppointmentsForDay(DateTime.now());
      final todaySessions = todayAppointments.map((apt) => _appointmentToSession(apt)).toList();

      // Load pending check-in confirmations
      final pendingRequests = await _checkinService.getPendingRequests();
      final pendingConfirmations = pendingRequests.map((req) => PendingConfirmation(
        checkInId: req['id']?.toString() ?? '',
        requesterId: req['requester_id']?.toString() ?? '',
        requesterName: req['requester_name']?.toString() ?? 'Aluno',
        requesterRole: CheckInInitiatorRole.student,
        requestedAt: DateTime.tryParse(req['created_at']?.toString() ?? '') ?? DateTime.now(),
        message: req['reason']?.toString(),
      )).toList();

      // Extract unique students from appointments
      final studentMap = <String, StudentInfo>{};
      for (final apt in todayAppointments) {
        final studentId = apt['student_id']?.toString();
        if (studentId != null && !studentMap.containsKey(studentId)) {
          studentMap[studentId] = StudentInfo(
            id: studentId,
            name: apt['student_name']?.toString() ?? 'Aluno',
            avatarUrl: apt['student_avatar']?.toString(),
            currentPlan: apt['workout_type']?.toString(),
            hasSessionToday: true,
          );
        }
      }

      state = state.copyWith(
        todaySessions: todaySessions,
        pendingConfirmations: pendingConfirmations,
        students: studentMap.values.toList(),
        totalStudents: studentMap.length,
        activeStudents: studentMap.length,
      );
    } on ApiException catch (e) {
      state = state.copyWith();
    } catch (e) {
      state = state.copyWith();
    }
  }

  ScheduledSession _appointmentToSession(Map<String, dynamic> apt) {
    return ScheduledSession(
      id: apt['id']?.toString() ?? '',
      title: apt['workout_type']?.toString() ?? apt['title']?.toString() ?? 'Sessão',
      scheduledAt: DateTime.tryParse(apt['date_time']?.toString() ?? '') ?? DateTime.now(),
      durationMinutes: apt['duration_minutes'] as int? ?? 60,
      trainerId: apt['trainer_id']?.toString(),
      trainerName: apt['trainer_name']?.toString(),
      studentId: apt['student_id']?.toString(),
      studentName: apt['student_name']?.toString(),
      gymId: apt['gym_id']?.toString(),
      gymName: apt['gym_name']?.toString(),
    );
  }

  void refreshStudents() => _loadContext();

  void refreshTodaySessions() => _loadContext();

  void refresh() => _loadContext();
}

/// Contexto específico do trainer
class TrainerContext {
  final List<StudentInfo> students;
  final List<ScheduledSession> todaySessions;
  final List<PendingConfirmation> pendingConfirmations;
  final int totalStudents;
  final int activeStudents;
  final bool isLoading;
  final String? error;

  const TrainerContext({
    this.students = const [],
    this.todaySessions = const [],
    this.pendingConfirmations = const [],
    this.totalStudents = 0,
    this.activeStudents = 0,
    this.isLoading = false,
    this.error,
  });

  TrainerContext copyWith({
    List<StudentInfo>? students,
    List<ScheduledSession>? todaySessions,
    List<PendingConfirmation>? pendingConfirmations,
    int? totalStudents,
    int? activeStudents,
    bool? isLoading,
    String? error,
  }) {
    return TrainerContext(
      students: students ?? this.students,
      todaySessions: todaySessions ?? this.todaySessions,
      pendingConfirmations: pendingConfirmations ?? this.pendingConfirmations,
      totalStudents: totalStudents ?? this.totalStudents,
      activeStudents: activeStudents ?? this.activeStudents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Info básica do aluno para o trainer
class StudentInfo {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? currentPlan;
  final DateTime? lastCheckIn;
  final int weeklyCheckIns;
  final bool hasSessionToday;

  const StudentInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.currentPlan,
    this.lastCheckIn,
    this.weeklyCheckIns = 0,
    this.hasSessionToday = false,
  });
}
