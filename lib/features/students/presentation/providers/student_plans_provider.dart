import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/workout_service.dart';

/// State for student's plan assignments
class StudentPlansState {
  /// Currently active plans (is_active=true AND start_date <= today AND status=accepted)
  final List<Map<String, dynamic>> activePlans;

  /// Scheduled plans (is_active=true AND start_date > today AND status=accepted)
  final List<Map<String, dynamic>> scheduledPlans;

  /// Pending plans awaiting student response (status=pending)
  final List<Map<String, dynamic>> pendingPlans;

  /// Historical plans (is_active=false OR status=declined)
  final List<Map<String, dynamic>> historyAssignments;

  final bool isLoading;
  final bool isResponding;
  final String? error;

  const StudentPlansState({
    this.activePlans = const [],
    this.scheduledPlans = const [],
    this.pendingPlans = const [],
    this.historyAssignments = const [],
    this.isLoading = false,
    this.isResponding = false,
    this.error,
  });

  StudentPlansState copyWith({
    List<Map<String, dynamic>>? activePlans,
    List<Map<String, dynamic>>? scheduledPlans,
    List<Map<String, dynamic>>? pendingPlans,
    List<Map<String, dynamic>>? historyAssignments,
    bool? isLoading,
    bool? isResponding,
    String? error,
  }) {
    return StudentPlansState(
      activePlans: activePlans ?? this.activePlans,
      scheduledPlans: scheduledPlans ?? this.scheduledPlans,
      pendingPlans: pendingPlans ?? this.pendingPlans,
      historyAssignments: historyAssignments ?? this.historyAssignments,
      isLoading: isLoading ?? this.isLoading,
      isResponding: isResponding ?? this.isResponding,
      error: error,
    );
  }

  /// For backwards compatibility - returns first active plan
  Map<String, dynamic>? get currentAssignment => activePlans.isNotEmpty ? activePlans.first : null;

  bool get hasCurrentPlan => activePlans.isNotEmpty;
  bool get hasScheduledPlans => scheduledPlans.isNotEmpty;
  bool get hasPendingPlans => pendingPlans.isNotEmpty;
  bool get hasMultipleActivePlans => activePlans.length > 1;
  int get pendingCount => pendingPlans.length;

  String? get currentPlanName => currentAssignment?['plan_name'] as String?;
  String? get currentPlanId => currentAssignment?['plan_id'] as String?;
  String? get currentAssignmentId => currentAssignment?['id'] as String?;
}

/// Notifier for managing student's plan assignments
class StudentPlansNotifier extends StateNotifier<StudentPlansState> {
  final WorkoutService _workoutService;
  final String studentUserId;

  StudentPlansNotifier({
    required WorkoutService workoutService,
    required this.studentUserId,
  })  : _workoutService = workoutService,
        super(const StudentPlansState()) {
    loadAssignments();
  }

  /// Load all plan assignments for the student
  Future<void> loadAssignments() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load all assignments (active and inactive) as trainer
      final allAssignments = await _workoutService.getPlanAssignments(
        studentId: studentUserId,
        asTrainer: true,
        activeOnly: false,
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Separate into: pending, active, scheduled, and history
      final pending = <Map<String, dynamic>>[];
      final active = <Map<String, dynamic>>[];
      final scheduled = <Map<String, dynamic>>[];
      final history = <Map<String, dynamic>>[];

      for (final assignment in allAssignments) {
        final status = assignment['status'] as String?;

        // Check if pending (awaiting student response)
        if (status == 'pending') {
          pending.add(assignment);
          continue;
        }

        // Check if declined
        if (status == 'declined') {
          history.add(assignment);
          continue;
        }

        if (assignment['is_active'] != true) {
          // Inactive = history
          history.add(assignment);
        } else {
          // Active - check if scheduled for future
          final startDateStr = assignment['start_date'] as String?;
          if (startDateStr != null) {
            try {
              final startDate = DateTime.parse(startDateStr);
              if (startDate.isAfter(today)) {
                // Starts in the future = scheduled
                scheduled.add(assignment);
              } else {
                // Already started = active
                active.add(assignment);
              }
            } catch (_) {
              active.add(assignment);
            }
          } else {
            active.add(assignment);
          }
        }
      }

      // Sort pending by created_at descending (newest first)
      pending.sort((a, b) {
        final aDate = DateTime.tryParse(a['created_at'] as String? ?? '');
        final bDate = DateTime.tryParse(b['created_at'] as String? ?? '');
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

      // Sort active plans by start_date ascending (oldest first = primary)
      active.sort((a, b) {
        final aDate = DateTime.tryParse(a['start_date'] as String? ?? '');
        final bDate = DateTime.tryParse(b['start_date'] as String? ?? '');
        if (aDate == null || bDate == null) return 0;
        return aDate.compareTo(bDate);
      });

      // Sort scheduled by start_date ascending (soonest first)
      scheduled.sort((a, b) {
        final aDate = DateTime.tryParse(a['start_date'] as String? ?? '');
        final bDate = DateTime.tryParse(b['start_date'] as String? ?? '');
        if (aDate == null || bDate == null) return 0;
        return aDate.compareTo(bDate);
      });

      // Sort history by end_date or created_at descending (newest first)
      history.sort((a, b) {
        final aDate = DateTime.tryParse(a['end_date'] as String? ?? a['created_at'] as String? ?? '');
        final bDate = DateTime.tryParse(b['end_date'] as String? ?? b['created_at'] as String? ?? '');
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

      state = state.copyWith(
        pendingPlans: pending,
        activePlans: active,
        scheduledPlans: scheduled,
        historyAssignments: history,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Assign a plan to the student
  Future<bool> assignPlan({
    required String planId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await _workoutService.createPlanAssignment(
        planId: planId,
        studentId: studentUserId,
        startDate: startDate,
        endDate: endDate,
      );
      await loadAssignments();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Deactivate current assignment (move to history)
  Future<bool> deactivateCurrentPlan() async {
    if (state.currentAssignmentId == null) return false;
    return deactivateAssignment(state.currentAssignmentId!);
  }

  /// Deactivate a specific assignment (move to history)
  Future<bool> deactivateAssignment(String assignmentId) async {
    try {
      await _workoutService.updatePlanAssignment(
        assignmentId,
        isActive: false,
        endDate: DateTime.now(),
      );
      await loadAssignments();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Extend current assignment end date
  Future<bool> extendCurrentPlan(DateTime newEndDate) async {
    if (state.currentAssignmentId == null) return false;

    try {
      await _workoutService.updatePlanAssignment(
        state.currentAssignmentId!,
        endDate: newEndDate,
      );
      await loadAssignments();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Cancel/delete a pending assignment
  Future<bool> cancelAssignment(String assignmentId) async {
    try {
      await _workoutService.deletePlanAssignment(assignmentId);
      await loadAssignments();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Accept a pending plan assignment
  Future<bool> acceptAssignment(String assignmentId) async {
    try {
      state = state.copyWith(isResponding: true, error: null);
      await _workoutService.respondToPlanAssignment(
        assignmentId,
        accept: true,
      );
      await loadAssignments();
      state = state.copyWith(isResponding: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isResponding: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Decline a pending plan assignment with optional reason
  Future<bool> declineAssignment(String assignmentId, {String? reason}) async {
    try {
      state = state.copyWith(isResponding: true, error: null);
      await _workoutService.respondToPlanAssignment(
        assignmentId,
        accept: false,
        declinedReason: reason,
      );
      await loadAssignments();
      state = state.copyWith(isResponding: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isResponding: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void refresh() => loadAssignments();
}

/// Provider for student plans by user ID
final studentPlansProvider = StateNotifierProvider.autoDispose
    .family<StudentPlansNotifier, StudentPlansState, String>((ref, studentUserId) {
  return StudentPlansNotifier(
    workoutService: WorkoutService(),
    studentUserId: studentUserId,
  );
});
