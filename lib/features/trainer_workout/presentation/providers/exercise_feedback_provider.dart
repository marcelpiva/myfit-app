import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/workout_service.dart';

/// State for trainer's exercise feedbacks
class ExerciseFeedbacksState {
  final List<Map<String, dynamic>> feedbacks;
  final List<Map<String, dynamic>> swapRequests;
  final bool isLoading;
  final bool isResponding;
  final String? error;

  const ExerciseFeedbacksState({
    this.feedbacks = const [],
    this.swapRequests = const [],
    this.isLoading = false,
    this.isResponding = false,
    this.error,
  });

  ExerciseFeedbacksState copyWith({
    List<Map<String, dynamic>>? feedbacks,
    List<Map<String, dynamic>>? swapRequests,
    bool? isLoading,
    bool? isResponding,
    String? error,
  }) {
    return ExerciseFeedbacksState(
      feedbacks: feedbacks ?? this.feedbacks,
      swapRequests: swapRequests ?? this.swapRequests,
      isLoading: isLoading ?? this.isLoading,
      isResponding: isResponding ?? this.isResponding,
      error: error,
    );
  }

  int get totalCount => feedbacks.length;
  int get swapRequestCount => swapRequests.length;
  int get pendingSwapCount => swapRequests.where((f) => f['responded_at'] == null).length;
  bool get hasSwapRequests => swapRequests.isNotEmpty;
  bool get hasPendingSwaps => pendingSwapCount > 0;
}

class ExerciseFeedbacksNotifier extends StateNotifier<ExerciseFeedbacksState> {
  final WorkoutService _workoutService;
  final String? _studentId;

  ExerciseFeedbacksNotifier({
    WorkoutService? workoutService,
    String? studentId,
  })  : _workoutService = workoutService ?? WorkoutService(),
        _studentId = studentId,
        super(const ExerciseFeedbacksState()) {
    loadFeedbacks();
  }

  Future<void> loadFeedbacks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final feedbacks = await _workoutService.getTrainerExerciseFeedbacks(
        studentId: _studentId,
      );

      // Separate swap requests from other feedbacks
      final swaps = feedbacks.where((f) => f['feedback_type'] == 'swap').toList();

      // Sort by created_at descending
      feedbacks.sort((a, b) {
        final aDate = DateTime.tryParse(a['created_at'] as String? ?? '');
        final bDate = DateTime.tryParse(b['created_at'] as String? ?? '');
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

      // Sort swaps by pending first, then by date
      swaps.sort((a, b) {
        final aResponded = a['responded_at'] != null;
        final bResponded = b['responded_at'] != null;
        if (aResponded != bResponded) {
          return aResponded ? 1 : -1; // Pending first
        }
        final aDate = DateTime.tryParse(a['created_at'] as String? ?? '');
        final bDate = DateTime.tryParse(b['created_at'] as String? ?? '');
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

      state = state.copyWith(
        feedbacks: feedbacks,
        swapRequests: swaps,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar feedbacks: $e',
      );
    }
  }

  Future<bool> respondToSwap(
    String feedbackId, {
    required String response,
    String? replacementExerciseId,
  }) async {
    state = state.copyWith(isResponding: true, error: null);
    try {
      await _workoutService.respondToExerciseFeedback(
        feedbackId,
        response: response,
        replacementExerciseId: replacementExerciseId,
      );

      // Reload feedbacks to get updated data
      await loadFeedbacks();
      state = state.copyWith(isResponding: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isResponding: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isResponding: false,
        error: 'Erro ao responder feedback: $e',
      );
      return false;
    }
  }

  void refresh() => loadFeedbacks();
}

/// Provider for all trainer feedbacks
final trainerFeedbacksProvider =
    StateNotifierProvider.autoDispose<ExerciseFeedbacksNotifier, ExerciseFeedbacksState>(
  (ref) => ExerciseFeedbacksNotifier(),
);

/// Provider for feedbacks filtered by student
final studentFeedbacksProvider = StateNotifierProvider.autoDispose
    .family<ExerciseFeedbacksNotifier, ExerciseFeedbacksState, String>(
  (ref, studentId) => ExerciseFeedbacksNotifier(studentId: studentId),
);

/// Provider for pending swap count (for badges)
final pendingSwapCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(trainerFeedbacksProvider).pendingSwapCount;
});
