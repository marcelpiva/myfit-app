import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/models/activity_item.dart';

/// State for the activity feed
class ActivityFeedState {
  final List<ActivityItem> activities;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int page;

  const ActivityFeedState({
    this.activities = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.page = 1,
  });

  ActivityFeedState copyWith({
    List<ActivityItem>? activities,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    int? page,
  }) {
    return ActivityFeedState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

/// Provider for the activity feed
class ActivityFeedNotifier extends StateNotifier<ActivityFeedState> {
  final ApiClient _apiClient;

  ActivityFeedNotifier(this._apiClient) : super(const ActivityFeedState()) {
    loadActivities();
  }

  /// Load activities from various sources
  Future<void> loadActivities() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final activities = await _fetchActivities();
      state = state.copyWith(
        activities: activities,
        isLoading: false,
        page: 1,
        hasMore: activities.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more activities (pagination)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final newActivities = await _fetchActivities(page: state.page + 1);
      state = state.copyWith(
        activities: [...state.activities, ...newActivities],
        isLoadingMore: false,
        page: state.page + 1,
        hasMore: newActivities.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Fetch activities from multiple API sources
  Future<List<ActivityItem>> _fetchActivities({int page = 1}) async {
    final activities = <ActivityItem>[];

    // Fetch recent workout sessions
    try {
      final sessionsResponse = await _apiClient.get(
        ApiEndpoints.workoutSessions,
        queryParameters: {'page': page, 'limit': 10, 'status': 'completed'},
      );

      if (sessionsResponse.statusCode == 200 && sessionsResponse.data != null) {
        final sessions = sessionsResponse.data['items'] as List? ?? [];
        for (final session in sessions) {
          activities.add(ActivityItem(
            id: 'session_${session['id']}',
            type: ActivityType.workoutCompleted,
            userId: session['user_id'] as String? ?? '',
            userName: session['user_name'] as String? ?? 'Usuário',
            userAvatarUrl: session['user_avatar'] as String?,
            timestamp: DateTime.tryParse(session['completed_at'] as String? ?? '') ?? DateTime.now(),
            data: {
              'workout_name': session['workout_name'] ?? 'Treino',
              'duration_minutes': session['duration_minutes'] ?? 0,
              'exercise_count': session['exercise_count'] ?? 0,
            },
          ));
        }
      }
    } catch (_) {
      // Continue even if this source fails
    }

    // Fetch recent personal records
    try {
      final prsResponse = await _apiClient.get(
        ApiEndpoints.personalRecordsRecent,
        queryParameters: {'page': page, 'limit': 10},
      );

      if (prsResponse.statusCode == 200 && prsResponse.data != null) {
        final prs = prsResponse.data['items'] as List? ?? prsResponse.data as List? ?? [];
        for (final pr in prs) {
          activities.add(ActivityItem(
            id: 'pr_${pr['id']}',
            type: ActivityType.personalRecord,
            userId: pr['user_id'] as String? ?? '',
            userName: pr['user_name'] as String? ?? 'Usuário',
            userAvatarUrl: pr['user_avatar'] as String?,
            timestamp: DateTime.tryParse(pr['achieved_at'] as String? ?? pr['created_at'] as String? ?? '') ?? DateTime.now(),
            data: {
              'exercise_name': pr['exercise_name'] ?? 'Exercício',
              'value': pr['value'] ?? 0,
              'unit': pr['unit'] ?? 'kg',
            },
          ));
        }
      }
    } catch (_) {
      // Continue even if this source fails
    }

    // Fetch recent achievements
    try {
      final achievementsResponse = await _apiClient.get(
        ApiEndpoints.myAchievements,
        queryParameters: {'page': page, 'limit': 10, 'recent': true},
      );

      if (achievementsResponse.statusCode == 200 && achievementsResponse.data != null) {
        final achievements = achievementsResponse.data['items'] as List? ?? achievementsResponse.data as List? ?? [];
        for (final achievement in achievements) {
          activities.add(ActivityItem(
            id: 'achievement_${achievement['id']}',
            type: ActivityType.achievementUnlocked,
            userId: achievement['user_id'] as String? ?? '',
            userName: achievement['user_name'] as String? ?? 'Usuário',
            userAvatarUrl: achievement['user_avatar'] as String?,
            timestamp: DateTime.tryParse(achievement['unlocked_at'] as String? ?? achievement['created_at'] as String? ?? '') ?? DateTime.now(),
            data: {
              'achievement_name': achievement['name'] ?? 'Conquista',
              'description': achievement['description'],
              'icon': achievement['icon'],
            },
          ));
        }
      }
    } catch (_) {
      // Continue even if this source fails
    }

    // Fetch recent milestones
    try {
      final milestonesResponse = await _apiClient.get(
        ApiEndpoints.milestones,
        queryParameters: {'page': page, 'limit': 10, 'status': 'completed'},
      );

      if (milestonesResponse.statusCode == 200 && milestonesResponse.data != null) {
        final milestones = milestonesResponse.data['items'] as List? ?? milestonesResponse.data as List? ?? [];
        for (final milestone in milestones) {
          activities.add(ActivityItem(
            id: 'milestone_${milestone['id']}',
            type: ActivityType.milestoneReached,
            userId: milestone['user_id'] as String? ?? '',
            userName: milestone['user_name'] as String? ?? 'Usuário',
            userAvatarUrl: milestone['user_avatar'] as String?,
            timestamp: DateTime.tryParse(milestone['completed_at'] as String? ?? milestone['created_at'] as String? ?? '') ?? DateTime.now(),
            data: {
              'milestone_name': milestone['name'] ?? 'Marco',
              'description': milestone['description'],
            },
          ));
        }
      }
    } catch (_) {
      // Continue even if this source fails
    }

    // Sort by timestamp descending
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activities;
  }

  /// Toggle reaction on an activity
  void toggleReaction(String activityId) {
    final index = state.activities.indexWhere((a) => a.id == activityId);
    if (index == -1) return;

    final activity = state.activities[index];
    final updatedActivity = ActivityItem(
      id: activity.id,
      type: activity.type,
      userId: activity.userId,
      userName: activity.userName,
      userAvatarUrl: activity.userAvatarUrl,
      timestamp: activity.timestamp,
      data: activity.data,
      reactions: activity.hasReacted ? activity.reactions - 1 : activity.reactions + 1,
      hasReacted: !activity.hasReacted,
      comments: activity.comments,
    );

    final newActivities = [...state.activities];
    newActivities[index] = updatedActivity;
    state = state.copyWith(activities: newActivities);
  }

  /// Refresh the feed
  Future<void> refresh() async {
    state = state.copyWith(page: 1, hasMore: true);
    await loadActivities();
  }
}

/// Provider instance
final activityFeedProvider =
    StateNotifierProvider.autoDispose<ActivityFeedNotifier, ActivityFeedState>((ref) {
  return ActivityFeedNotifier(ApiClient.instance);
});
