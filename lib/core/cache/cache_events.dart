import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Types of events that can trigger cache invalidation
enum CacheEventType {
  // Workout events
  workoutCreated,
  workoutUpdated,
  workoutDeleted,
  workoutCompleted,
  sessionStarted,
  sessionCompleted,

  // Plan events
  planCreated,
  planUpdated,
  planDeleted,
  planAssigned,
  planAcknowledged,

  // Student/membership events
  studentAdded,
  studentRemoved,
  membershipChanged,
  inviteCreated,
  inviteAccepted,
  inviteDeclined,

  // Check-in events
  checkInCompleted,

  // Progress events
  progressLogged,
  weightLogged,
  measurementLogged,

  // Gamification events
  achievementUnlocked,
  pointsEarned,

  // Chat events
  messageReceived,
  conversationUpdated,

  // Global events
  contextChanged,
  userLoggedOut,
  appResumed,
  forceRefreshAll,
}

/// Represents a cache invalidation event
class CacheEvent {
  final CacheEventType type;
  final String? entityId;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  CacheEvent({
    required this.type,
    this.entityId,
    this.metadata,
  }) : timestamp = DateTime.now();

  @override
  String toString() => 'CacheEvent($type, entityId: $entityId)';
}

/// Global provider for cache events - notifiers subscribe to this
final cacheEventProvider = StateProvider<CacheEvent?>((ref) => null);

/// Helper class to emit cache events throughout the app
class CacheEventEmitter {
  final Ref ref;

  CacheEventEmitter(this.ref);

  /// Emit a generic cache event
  void emit(CacheEventType type, {String? entityId, Map<String, dynamic>? metadata}) {
    ref.read(cacheEventProvider.notifier).state = CacheEvent(
      type: type,
      entityId: entityId,
      metadata: metadata,
    );
  }

  // Workout convenience methods
  void workoutCompleted(String workoutId) =>
      emit(CacheEventType.workoutCompleted, entityId: workoutId);

  void workoutCreated(String workoutId) =>
      emit(CacheEventType.workoutCreated, entityId: workoutId);

  void sessionCompleted(String sessionId) =>
      emit(CacheEventType.sessionCompleted, entityId: sessionId);

  // Plan convenience methods
  void planAssigned(String planId, {String? studentId}) => emit(
        CacheEventType.planAssigned,
        entityId: planId,
        metadata: studentId != null ? {'student_id': studentId} : null,
      );

  void planAcknowledged(String planId) =>
      emit(CacheEventType.planAcknowledged, entityId: planId);

  // Membership convenience methods
  void studentAdded(String studentId, String organizationId) => emit(
        CacheEventType.studentAdded,
        entityId: studentId,
        metadata: {'organization_id': organizationId},
      );

  void inviteCreated(String inviteId, {String? organizationId}) => emit(
        CacheEventType.inviteCreated,
        entityId: inviteId,
        metadata: organizationId != null ? {'organization_id': organizationId} : null,
      );

  void inviteAccepted(String inviteId) =>
      emit(CacheEventType.inviteAccepted, entityId: inviteId);

  void inviteDeclined(String inviteId) =>
      emit(CacheEventType.inviteDeclined, entityId: inviteId);

  void membershipChanged() => emit(CacheEventType.membershipChanged);

  // Check-in convenience methods
  void checkInCompleted(String organizationId) =>
      emit(CacheEventType.checkInCompleted, entityId: organizationId);

  // Progress convenience methods
  void weightLogged() => emit(CacheEventType.weightLogged);
  void progressLogged() => emit(CacheEventType.progressLogged);

  // Gamification convenience methods
  void achievementUnlocked(String achievementId) =>
      emit(CacheEventType.achievementUnlocked, entityId: achievementId);

  void pointsEarned(int points) =>
      emit(CacheEventType.pointsEarned, metadata: {'points': points});

  // Global convenience methods
  void contextChanged() => emit(CacheEventType.contextChanged);
  void appResumed() => emit(CacheEventType.appResumed);
  void userLoggedOut() => emit(CacheEventType.userLoggedOut);
  void forceRefreshAll() => emit(CacheEventType.forceRefreshAll);
}

/// Provider for the event emitter
final cacheEventEmitterProvider = Provider<CacheEventEmitter>((ref) {
  return CacheEventEmitter(ref);
});

/// Mapping of events to affected providers (for documentation/debugging)
const eventInvalidationMap = <CacheEventType, List<String>>{
  CacheEventType.workoutCompleted: [
    'studentDashboardProvider',
    'gamificationStatsProvider',
    'workoutSessionsProvider',
    'progressProvider',
  ],
  CacheEventType.planAssigned: [
    'studentDashboardProvider',
    'plansNotifierProvider',
    'studentPendingPlansProvider',
  ],
  CacheEventType.planAcknowledged: [
    'studentDashboardProvider',
    'plansNotifierProvider',
    'studentPlansProvider',
  ],
  CacheEventType.checkInCompleted: [
    'studentDashboardProvider',
    'gamificationStatsProvider',
    'checkInHistoryProvider',
  ],
  CacheEventType.membershipChanged: [
    'membershipsProvider',
    'groupedMembershipsProvider',
  ],
  CacheEventType.inviteCreated: [
    'pendingInvitesNotifierProvider',
  ],
  CacheEventType.inviteAccepted: [
    'membershipsProvider',
    'pendingInvitesNotifierProvider',
    'trainerStudentsNotifierProvider',
  ],
  CacheEventType.inviteDeclined: [
    'pendingInvitesNotifierProvider',
  ],
  CacheEventType.studentAdded: [
    'trainerStudentsNotifierProvider',
  ],
  CacheEventType.studentRemoved: [
    'trainerStudentsNotifierProvider',
  ],
  CacheEventType.contextChanged: [
    'studentDashboardProvider',
    'trainerStudentsNotifierProvider',
    'plansNotifierProvider',
    'workoutsNotifierProvider',
  ],
  CacheEventType.appResumed: [
    'studentDashboardProvider',
    'notificationsProvider',
    'pendingInvitesNotifierProvider',
  ],
};
