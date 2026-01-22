import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/schedule_service.dart';

/// Student's session model - includes trainer info instead of student
class StudentSession {
  final String id;
  final String trainerId;
  final String trainerName;
  final String? trainerAvatarUrl;
  final TimeOfDay time;
  final int durationMinutes;
  final String workoutType;
  final String status; // confirmed, pending, cancelled, completed, reschedule_requested
  final DateTime date;
  final String? notes;
  final String? location;

  const StudentSession({
    required this.id,
    required this.trainerId,
    required this.trainerName,
    this.trainerAvatarUrl,
    required this.time,
    required this.durationMinutes,
    required this.workoutType,
    required this.status,
    required this.date,
    this.notes,
    this.location,
  });

  StudentSession copyWith({
    String? id,
    String? trainerId,
    String? trainerName,
    String? trainerAvatarUrl,
    TimeOfDay? time,
    int? durationMinutes,
    String? workoutType,
    String? status,
    DateTime? date,
    String? notes,
    String? location,
  }) {
    return StudentSession(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      trainerName: trainerName ?? this.trainerName,
      trainerAvatarUrl: trainerAvatarUrl ?? this.trainerAvatarUrl,
      time: time ?? this.time,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      workoutType: workoutType ?? this.workoutType,
      status: status ?? this.status,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      location: location ?? this.location,
    );
  }

  factory StudentSession.fromJson(Map<String, dynamic> json) {
    final dateTimeStr = json['date_time'] as String? ?? json['datetime'] as String?;
    final dateTime = dateTimeStr != null ? DateTime.tryParse(dateTimeStr) : null;
    final date = dateTime ?? DateTime.now();

    return StudentSession(
      id: json['id'] as String,
      trainerId: json['trainer_id'] as String? ?? '',
      trainerName: json['trainer_name'] as String? ?? 'Personal',
      trainerAvatarUrl: json['trainer_avatar_url'] as String?,
      time: TimeOfDay(hour: date.hour, minute: date.minute),
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      workoutType: json['workout_type'] as String? ?? 'Treino',
      status: json['status'] as String? ?? 'pending',
      date: DateTime(date.year, date.month, date.day),
      notes: json['notes'] as String?,
      location: json['location'] as String?,
    );
  }

  /// Check if session is upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    final sessionDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return sessionDateTime.isAfter(now);
  }

  /// Check if session is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if session needs confirmation
  bool get needsConfirmation => status == 'pending' && isUpcoming;

  /// Check if reschedule was requested
  bool get rescheduleRequested => status == 'reschedule_requested';
}

// ==================== State ====================

class StudentScheduleState {
  final List<StudentSession> sessions;
  final bool isLoading;
  final String? error;

  const StudentScheduleState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
  });

  StudentScheduleState copyWith({
    List<StudentSession>? sessions,
    bool? isLoading,
    String? error,
  }) {
    return StudentScheduleState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get upcoming sessions
  List<StudentSession> get upcomingSessions =>
      sessions.where((s) => s.isUpcoming && s.status != 'cancelled').toList()
        ..sort((a, b) {
          final aDate = DateTime(a.date.year, a.date.month, a.date.day, a.time.hour, a.time.minute);
          final bDate = DateTime(b.date.year, b.date.month, b.date.day, b.time.hour, b.time.minute);
          return aDate.compareTo(bDate);
        });

  /// Get today's sessions
  List<StudentSession> get todaySessions =>
      sessions.where((s) => s.isToday && s.status != 'cancelled').toList();

  /// Get sessions needing confirmation
  List<StudentSession> get pendingSessions =>
      sessions.where((s) => s.needsConfirmation).toList();

  /// Get next session
  StudentSession? get nextSession {
    final upcoming = upcomingSessions;
    return upcoming.isNotEmpty ? upcoming.first : null;
  }
}

// ==================== Notifier ====================

class StudentScheduleNotifier extends StateNotifier<StudentScheduleState> {
  final ScheduleService _scheduleService;

  StudentScheduleNotifier(this._scheduleService) : super(const StudentScheduleState()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _scheduleService.getMyAppointments(
        fromDate: DateTime.now().subtract(const Duration(days: 7)),
      );
      final sessions = data.map((json) => StudentSession.fromJson(json)).toList();
      state = state.copyWith(sessions: sessions, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar sessões');
    }
  }

  Future<bool> confirmSession(String sessionId) async {
    try {
      await _scheduleService.confirmAppointment(sessionId);
      state = state.copyWith(
        sessions: state.sessions.map((s) {
          if (s.id == sessionId) {
            return s.copyWith(status: 'confirmed');
          }
          return s;
        }).toList(),
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    }
  }

  Future<bool> requestReschedule(
    String sessionId, {
    DateTime? preferredDateTime,
    String? reason,
  }) async {
    try {
      await _scheduleService.requestReschedule(
        sessionId,
        preferredDateTime: preferredDateTime,
        reason: reason,
      );
      state = state.copyWith(
        sessions: state.sessions.map((s) {
          if (s.id == sessionId) {
            return s.copyWith(status: 'reschedule_requested');
          }
          return s;
        }).toList(),
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    }
  }

  Future<bool> cancelSession(String sessionId, {String? reason}) async {
    try {
      await _scheduleService.cancelAppointment(sessionId, reason: reason);
      state = state.copyWith(
        sessions: state.sessions.map((s) {
          if (s.id == sessionId) {
            return s.copyWith(status: 'cancelled');
          }
          return s;
        }).toList(),
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    }
  }

  void refresh() => loadSessions();
}

// ==================== Providers ====================

final studentScheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService();
});

final studentScheduleProvider =
    StateNotifierProvider<StudentScheduleNotifier, StudentScheduleState>((ref) {
  final service = ref.watch(studentScheduleServiceProvider);
  return StudentScheduleNotifier(service);
});

// Convenience providers
final upcomingSessionsProvider = Provider<List<StudentSession>>((ref) {
  return ref.watch(studentScheduleProvider).upcomingSessions;
});

final nextSessionProvider = Provider<StudentSession?>((ref) {
  return ref.watch(studentScheduleProvider).nextSession;
});

final pendingSessionsProvider = Provider<List<StudentSession>>((ref) {
  return ref.watch(studentScheduleProvider).pendingSessions;
});

final todaySessionsProvider = Provider<List<StudentSession>>((ref) {
  return ref.watch(studentScheduleProvider).todaySessions;
});
