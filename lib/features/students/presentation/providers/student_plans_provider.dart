import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/workout_service.dart';

/// State for student's plan assignments
class StudentPlansState {
  /// Currently active plans (is_active=true AND start_date <= today)
  final List<Map<String, dynamic>> activePlans;

  /// Scheduled plans (is_active=true AND start_date > today)
  final List<Map<String, dynamic>> scheduledPlans;

  /// Historical plans (is_active=false)
  final List<Map<String, dynamic>> historyAssignments;

  final bool isLoading;
  final String? error;

  const StudentPlansState({
    this.activePlans = const [],
    this.scheduledPlans = const [],
    this.historyAssignments = const [],
    this.isLoading = false,
    this.error,
  });

  StudentPlansState copyWith({
    List<Map<String, dynamic>>? activePlans,
    List<Map<String, dynamic>>? scheduledPlans,
    List<Map<String, dynamic>>? historyAssignments,
    bool? isLoading,
    String? error,
  }) {
    return StudentPlansState(
      activePlans: activePlans ?? this.activePlans,
      scheduledPlans: scheduledPlans ?? this.scheduledPlans,
      historyAssignments: historyAssignments ?? this.historyAssignments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// For backwards compatibility - returns first active plan
  Map<String, dynamic>? get currentAssignment => activePlans.isNotEmpty ? activePlans.first : null;

  bool get hasCurrentPlan => activePlans.isNotEmpty;
  bool get hasScheduledPlans => scheduledPlans.isNotEmpty;
  bool get hasMultipleActivePlans => activePlans.length > 1;

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

      // Separate into: active, scheduled, and history
      final active = <Map<String, dynamic>>[];
      final scheduled = <Map<String, dynamic>>[];
      final history = <Map<String, dynamic>>[];

      for (final assignment in allAssignments) {
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
