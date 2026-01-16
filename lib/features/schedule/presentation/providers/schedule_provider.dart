import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/organization_service.dart';
import '../../../../core/services/schedule_service.dart';

// Service providers
final scheduleOrganizationServiceProvider = Provider<OrganizationService>((ref) {
  return OrganizationService();
});

final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService();
});

// ==================== Schedule Sessions State ====================

class ScheduleSession {
  final String id;
  final String studentId;
  final String studentName;
  final String? studentAvatarUrl;
  final TimeOfDay time;
  final int durationMinutes;
  final String workoutType;
  final String status; // confirmed, pending, cancelled, completed
  final DateTime date;
  final String? notes;

  const ScheduleSession({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.studentAvatarUrl,
    required this.time,
    required this.durationMinutes,
    required this.workoutType,
    required this.status,
    required this.date,
    this.notes,
  });

  ScheduleSession copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? studentAvatarUrl,
    TimeOfDay? time,
    int? durationMinutes,
    String? workoutType,
    String? status,
    DateTime? date,
    String? notes,
  }) {
    return ScheduleSession(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentAvatarUrl: studentAvatarUrl ?? this.studentAvatarUrl,
      time: time ?? this.time,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      workoutType: workoutType ?? this.workoutType,
      status: status ?? this.status,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  factory ScheduleSession.fromJson(Map<String, dynamic> json) {
    final dateTimeStr = json['date_time'] as String? ?? json['datetime'] as String?;
    final dateTime = dateTimeStr != null ? DateTime.tryParse(dateTimeStr) : null;
    final date = dateTime ?? DateTime.now();

    return ScheduleSession(
      id: json['id'] as String,
      studentId: json['student_id'] as String? ?? '',
      studentName: json['student_name'] as String? ?? 'Aluno',
      studentAvatarUrl: json['student_avatar_url'] as String?,
      time: TimeOfDay(hour: date.hour, minute: date.minute),
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      workoutType: json['workout_type'] as String? ?? 'Treino',
      status: json['status'] as String? ?? 'pending',
      date: DateTime(date.year, date.month, date.day),
      notes: json['notes'] as String?,
    );
  }
}

class ScheduleSessionsState {
  final List<ScheduleSession> sessions;
  final bool isLoading;
  final String? error;

  const ScheduleSessionsState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
  });

  ScheduleSessionsState copyWith({
    List<ScheduleSession>? sessions,
    bool? isLoading,
    String? error,
  }) {
    return ScheduleSessionsState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ScheduleSessionsNotifier extends StateNotifier<ScheduleSessionsState> {
  final ScheduleService _scheduleService;
  DateTime _currentDate = DateTime.now();

  ScheduleSessionsNotifier(this._scheduleService) : super(const ScheduleSessionsState());

  Future<void> loadSessions({DateTime? date}) async {
    final targetDate = date ?? _currentDate;
    _currentDate = targetDate;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _scheduleService.getAppointmentsForDay(targetDate);
      final sessions = data.map((json) => ScheduleSession.fromJson(json)).toList();
      state = state.copyWith(sessions: sessions, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar agenda');
    }
  }

  Future<void> createSession({
    required String studentId,
    required DateTime dateTime,
    required int durationMinutes,
    String? workoutType,
    String? notes,
  }) async {
    try {
      final data = await _scheduleService.createAppointment(
        studentId: studentId,
        dateTime: dateTime,
        durationMinutes: durationMinutes,
        workoutType: workoutType,
        notes: notes,
      );
      final session = ScheduleSession.fromJson(data);
      state = state.copyWith(sessions: [session, ...state.sessions]);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> updateSession(String sessionId, {String? status, String? notes}) async {
    try {
      await _scheduleService.updateAppointment(sessionId, notes: notes);
      state = state.copyWith(
        sessions: state.sessions.map((s) {
          if (s.id == sessionId) {
            return s.copyWith(status: status, notes: notes);
          }
          return s;
        }).toList(),
      );
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> cancelSession(String sessionId) async {
    try {
      await _scheduleService.cancelAppointment(sessionId);
      state = state.copyWith(
        sessions: state.sessions.map((s) {
          if (s.id == sessionId) {
            return s.copyWith(status: 'cancelled');
          }
          return s;
        }).toList(),
      );
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> confirmSession(String sessionId) async {
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
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  void refresh() => loadSessions(date: _currentDate);
}

final scheduleSessionsNotifierProvider =
    StateNotifierProvider<ScheduleSessionsNotifier, ScheduleSessionsState>((ref) {
  final scheduleService = ref.watch(scheduleServiceProvider);
  return ScheduleSessionsNotifier(scheduleService);
});

// Simple provider for backward compatibility
final scheduleSessionsProvider = Provider<List<ScheduleSession>>((ref) {
  return ref.watch(scheduleSessionsNotifierProvider).sessions;
});

// ==================== Students for Scheduling ====================

class ScheduleStudentsState {
  final List<Map<String, dynamic>> students;
  final bool isLoading;
  final String? error;

  const ScheduleStudentsState({
    this.students = const [],
    this.isLoading = false,
    this.error,
  });

  ScheduleStudentsState copyWith({
    List<Map<String, dynamic>>? students,
    bool? isLoading,
    String? error,
  }) {
    return ScheduleStudentsState(
      students: students ?? this.students,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ScheduleStudentsNotifier extends StateNotifier<ScheduleStudentsState> {
  final OrganizationService _service;
  final String? orgId;

  ScheduleStudentsNotifier(this._service, this.orgId) : super(const ScheduleStudentsState()) {
    if (orgId != null) {
      loadStudents();
    }
  }

  Future<void> loadStudents() async {
    if (orgId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final members = await _service.getMembers(orgId!, role: 'student');
      state = state.copyWith(students: members, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar alunos');
    }
  }

  void refresh() => loadStudents();
}

final scheduleStudentsNotifierProvider =
    StateNotifierProvider.family<ScheduleStudentsNotifier, ScheduleStudentsState, String?>((ref, orgId) {
  final service = ref.watch(scheduleOrganizationServiceProvider);
  return ScheduleStudentsNotifier(service, orgId);
});

// Simple provider for backward compatibility
final scheduleStudentsProvider = Provider.family<List<Map<String, dynamic>>, String?>((ref, orgId) {
  return ref.watch(scheduleStudentsNotifierProvider(orgId)).students;
});

// ==================== Selected Date Provider ====================

final selectedScheduleDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// ==================== Sessions for Selected Date ====================

final sessionsForDateProvider = Provider.family<List<ScheduleSession>, DateTime>((ref, date) {
  final sessions = ref.watch(scheduleSessionsProvider);
  return sessions.where((s) {
    return s.date.year == date.year && s.date.month == date.month && s.date.day == date.day;
  }).toList();
});

// ==================== Schedule Stats ====================

final scheduleStatsProvider = Provider<Map<String, int>>((ref) {
  final sessions = ref.watch(scheduleSessionsProvider);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(Duration(days: today.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 7));

  final todaySessions = sessions.where((s) {
    return s.date.year == today.year && s.date.month == today.month && s.date.day == today.day;
  }).length;

  final weekSessions = sessions.where((s) {
    return s.date.isAfter(weekStart.subtract(const Duration(days: 1))) && s.date.isBefore(weekEnd);
  }).length;

  final pendingSessions = sessions.where((s) => s.status == 'pending').length;
  final confirmedSessions = sessions.where((s) => s.status == 'confirmed').length;

  return {
    'today': todaySessions,
    'week': weekSessions,
    'pending': pendingSessions,
    'confirmed': confirmedSessions,
  };
});
