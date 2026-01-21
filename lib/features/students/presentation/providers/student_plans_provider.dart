import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/workout_service.dart';

/// State for student's plan assignments
class StudentPlansState {
  final Map<String, dynamic>? currentAssignment;
  final List<Map<String, dynamic>> historyAssignments;
  final bool isLoading;
  final String? error;

  const StudentPlansState({
    this.currentAssignment,
    this.historyAssignments = const [],
    this.isLoading = false,
    this.error,
  });

  StudentPlansState copyWith({
    Map<String, dynamic>? currentAssignment,
    List<Map<String, dynamic>>? historyAssignments,
    bool? isLoading,
    String? error,
    bool clearCurrent = false,
  }) {
    return StudentPlansState(
      currentAssignment: clearCurrent ? null : (currentAssignment ?? this.currentAssignment),
      historyAssignments: historyAssignments ?? this.historyAssignments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasCurrentPlan => currentAssignment != null;

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

      // Separate current (active) from history (inactive)
      Map<String, dynamic>? current;
      final history = <Map<String, dynamic>>[];

      for (final assignment in allAssignments) {
        if (assignment['is_active'] == true) {
          current = assignment;
        } else {
          history.add(assignment);
        }
      }

      // Sort history by end_date or created_at descending
      history.sort((a, b) {
        final aDate = DateTime.tryParse(a['end_date'] as String? ?? a['created_at'] as String? ?? '');
        final bDate = DateTime.tryParse(b['end_date'] as String? ?? b['created_at'] as String? ?? '');
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

      state = state.copyWith(
        currentAssignment: current,
        historyAssignments: history,
        isLoading: false,
        clearCurrent: current == null,
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

    try {
      await _workoutService.updatePlanAssignment(
        state.currentAssignmentId!,
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
