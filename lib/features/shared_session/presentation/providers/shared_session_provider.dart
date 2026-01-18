/// Riverpod providers for shared workout sessions.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/shared_session_service.dart';
import '../../domain/models/shared_session.dart';

/// Provider for SharedSessionService.
final sharedSessionServiceProvider = Provider<SharedSessionService>((ref) {
  final service = SharedSessionService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for active sessions (Students Now).
final activeSessionsProvider = FutureProvider.family<List<ActiveSession>, String?>(
  (ref, organizationId) async {
    final service = ref.watch(sharedSessionServiceProvider);
    return service.getActiveSessions(organizationId: organizationId);
  },
);

/// State for a shared session.
class SharedSessionState {
  final SharedSession? session;
  final List<SessionEvent> events;
  final bool isConnected;
  final bool isLoading;
  final String? error;

  const SharedSessionState({
    this.session,
    this.events = const [],
    this.isConnected = false,
    this.isLoading = false,
    this.error,
  });

  SharedSessionState copyWith({
    SharedSession? session,
    List<SessionEvent>? events,
    bool? isConnected,
    bool? isLoading,
    String? error,
  }) {
    return SharedSessionState(
      session: session ?? this.session,
      events: events ?? this.events,
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing a shared session.
class SharedSessionNotifier extends StateNotifier<SharedSessionState> {
  final SharedSessionService _service;
  final String sessionId;
  StreamSubscription? _eventSubscription;

  SharedSessionNotifier(this._service, this.sessionId)
      : super(const SharedSessionState(isLoading: true)) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Load session details
      final session = await _service.getSession(sessionId);
      state = state.copyWith(session: session, isLoading: false);

      // Subscribe to real-time events
      await _subscribeToEvents();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _subscribeToEvents() async {
    try {
      await _service.subscribeToSession(sessionId);
      state = state.copyWith(isConnected: true);

      _eventSubscription = _service.eventStream.listen(
        _handleEvent,
        onError: (error) {
          state = state.copyWith(isConnected: false, error: error.toString());
        },
      );
    } catch (e) {
      state = state.copyWith(isConnected: false, error: e.toString());
    }
  }

  void _handleEvent(SessionEvent event) {
    // Add event to list
    final newEvents = [...state.events, event];
    state = state.copyWith(events: newEvents);

    // Update session based on event type
    final session = state.session;
    if (session == null) return;

    switch (event.eventType) {
      case SessionEventType.trainerJoined:
        state = state.copyWith(
          session: session.copyWith(
            trainerId: event.data['trainer_id'] as String?,
            isShared: true,
          ),
        );
        break;

      case SessionEventType.trainerLeft:
        state = state.copyWith(
          session: session.copyWith(
            trainerId: null,
            isShared: false,
          ),
        );
        break;

      case SessionEventType.sessionCompleted:
        state = state.copyWith(
          session: session.copyWith(
            status: SessionStatus.completed,
          ),
        );
        break;

      case SessionEventType.sessionPaused:
        state = state.copyWith(
          session: session.copyWith(
            status: SessionStatus.paused,
          ),
        );
        break;

      case SessionEventType.sessionStarted:
      case SessionEventType.sessionResumed:
        state = state.copyWith(
          session: session.copyWith(
            status: SessionStatus.active,
          ),
        );
        break;

      case SessionEventType.setCompleted:
        final setData = event.data;
        final newSet = SessionSet(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          exerciseId: setData['exercise_id'] as String,
          setNumber: setData['set_number'] as int,
          repsCompleted: setData['reps'] as int,
          weightKg: (setData['weight_kg'] as num?)?.toDouble(),
          performedAt: DateTime.now(),
        );
        state = state.copyWith(
          session: session.copyWith(
            sets: [...session.sets, newSet],
          ),
        );
        break;

      case SessionEventType.trainerAdjustment:
        final adjData = event.data;
        final newAdj = TrainerAdjustment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sessionId: sessionId,
          trainerId: event.senderId ?? '',
          exerciseId: adjData['exercise_id'] as String,
          setNumber: adjData['set_number'] as int?,
          suggestedWeightKg: (adjData['suggested_weight_kg'] as num?)?.toDouble(),
          suggestedReps: adjData['suggested_reps'] as int?,
          note: adjData['note'] as String?,
          createdAt: DateTime.now(),
        );
        state = state.copyWith(
          session: session.copyWith(
            adjustments: [...session.adjustments, newAdj],
          ),
        );
        break;

      case SessionEventType.messageSent:
        final msgData = event.data;
        final newMsg = SessionMessage(
          id: msgData['message_id'] as String,
          sessionId: sessionId,
          senderId: event.senderId ?? '',
          senderName: msgData['sender_name'] as String?,
          message: msgData['message'] as String,
          sentAt: event.timestamp,
        );
        state = state.copyWith(
          session: session.copyWith(
            messages: [...session.messages, newMsg],
          ),
        );
        break;

      case SessionEventType.syncResponse:
        // Full state sync from server
        _handleSyncResponse(event.data);
        break;

      default:
        break;
    }
  }

  void _handleSyncResponse(Map<String, dynamic> data) {
    // Parse full session state from sync
    final sets = (data['completed_sets'] as List<dynamic>?)
            ?.map((e) => SessionSet(
                  id: e['id'] as String,
                  exerciseId: e['exercise_id'] as String,
                  setNumber: e['set_number'] as int,
                  repsCompleted: e['reps_completed'] as int,
                  weightKg: (e['weight_kg'] as num?)?.toDouble(),
                  performedAt: DateTime.parse(e['performed_at'] as String),
                ))
            .toList() ??
        [];

    final messages = (data['messages'] as List<dynamic>?)
            ?.map((e) => SessionMessage(
                  id: e['id'] as String,
                  sessionId: sessionId,
                  senderId: e['sender_id'] as String,
                  message: e['message'] as String,
                  sentAt: DateTime.parse(e['sent_at'] as String),
                ))
            .toList() ??
        [];

    final adjustments = (data['adjustments'] as List<dynamic>?)
            ?.map((e) => TrainerAdjustment(
                  id: e['id'] as String,
                  sessionId: sessionId,
                  trainerId: '',
                  exerciseId: e['exercise_id'] as String,
                  setNumber: e['set_number'] as int?,
                  suggestedWeightKg: (e['suggested_weight_kg'] as num?)?.toDouble(),
                  suggestedReps: e['suggested_reps'] as int?,
                  note: e['note'] as String?,
                  createdAt: DateTime.now(),
                ))
            .toList() ??
        [];

    final statusStr = data['status'] as String? ?? 'waiting';
    final status = SessionStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => SessionStatus.waiting,
    );

    state = state.copyWith(
      session: state.session?.copyWith(
        trainerId: data['trainer_id'] as String?,
        isShared: data['is_shared'] as bool? ?? false,
        status: status,
        sets: sets,
        messages: messages,
        adjustments: adjustments,
      ),
    );
  }

  /// Join session as trainer.
  Future<void> joinAsTrainer() async {
    try {
      await _service.joinSession(sessionId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Leave session as trainer.
  Future<void> leaveAsTrainer() async {
    try {
      await _service.leaveSession(sessionId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update session status.
  Future<void> updateStatus(SessionStatus status) async {
    try {
      await _service.updateSessionStatus(sessionId, status);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Record a set.
  Future<void> recordSet({
    required String exerciseId,
    required int setNumber,
    required int reps,
    double? weight,
  }) async {
    try {
      await _service.recordSet(
        sessionId: sessionId,
        exerciseId: exerciseId,
        setNumber: setNumber,
        repsCompleted: reps,
        weightKg: weight,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Create trainer adjustment.
  Future<void> createAdjustment({
    required String exerciseId,
    int? setNumber,
    double? suggestedWeight,
    int? suggestedReps,
    String? note,
  }) async {
    try {
      await _service.createAdjustment(
        sessionId: sessionId,
        exerciseId: exerciseId,
        setNumber: setNumber,
        suggestedWeightKg: suggestedWeight,
        suggestedReps: suggestedReps,
        note: note,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Send a message.
  Future<void> sendMessage(String message) async {
    try {
      await _service.sendMessage(sessionId: sessionId, message: message);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Refresh session data.
  Future<void> refresh() async {
    try {
      final session = await _service.getSession(sessionId);
      state = state.copyWith(session: session);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _service.unsubscribe();
    super.dispose();
  }
}

/// Provider for a specific shared session.
final sharedSessionProvider = StateNotifierProvider.family<
    SharedSessionNotifier, SharedSessionState, String>(
  (ref, sessionId) {
    final service = ref.watch(sharedSessionServiceProvider);
    return SharedSessionNotifier(service, sessionId);
  },
);
