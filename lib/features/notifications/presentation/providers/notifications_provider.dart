import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/cache/cache.dart';
import '../../../../core/services/notification_service.dart';

/// Notification types
enum NotificationType { workout, checkin, message, achievement, system }

/// Notification model
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? json['message'] ?? '',
      type: _parseType(json['type']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isRead: json['is_read'] ?? json['read'] ?? false,
    );
  }

  static NotificationType _parseType(dynamic type) {
    if (type == null) return NotificationType.system;
    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'workout':
        return NotificationType.workout;
      case 'checkin':
      case 'check_in':
        return NotificationType.checkin;
      case 'message':
      case 'chat':
        return NotificationType.message;
      case 'achievement':
        return NotificationType.achievement;
      default:
        return NotificationType.system;
    }
  }
}

/// State for notifications
class NotificationsState implements CachedState<List<NotificationItem>> {
  @override
  final List<NotificationItem>? data;
  @override
  final bool isLoading;
  @override
  final String? error;
  @override
  final CacheMetadata cache;
  final int unreadCount;

  const NotificationsState({
    this.data,
    this.isLoading = false,
    this.error,
    this.cache = const CacheMetadata(),
    this.unreadCount = 0,
  });

  // CachedState implementation
  @override
  bool get hasData => data != null;

  @override
  bool isStale(CacheConfig config) => cache.isStale(config);

  @override
  bool get isBackgroundRefresh => cache.isRefreshing && hasData;

  // Backwards compatible getter
  List<NotificationItem> get notifications => data ?? const [];

  NotificationsState copyWith({
    List<NotificationItem>? notifications,
    bool? isLoading,
    String? error,
    CacheMetadata? cache,
    int? unreadCount,
  }) {
    return NotificationsState(
      data: notifications ?? data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      cache: cache ?? this.cache,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Notifications notifier
class NotificationsNotifier extends CachedStateNotifier<NotificationsState> {
  final NotificationService _service;

  NotificationsNotifier({
    required Ref ref,
    NotificationService? service,
  })  : _service = service ?? NotificationService(),
        super(
          const NotificationsState(),
          config: CacheConfigs.notifications, // 1 min TTL, auto-refresh
          ref: ref,
        );

  /// Events that should trigger a refresh of this provider
  @override
  Set<CacheEventType> get invalidationEvents => {
        CacheEventType.messageReceived,
        CacheEventType.achievementUnlocked,
        CacheEventType.appResumed,
      };

  @override
  Future<void> fetchData() async {
    try {
      final data = await _service.getNotifications();
      final notifications =
          data.map((e) => NotificationItem.fromJson(e)).toList();
      onFetchSuccess(notifications);
      // Update unread count after successful fetch
      final unreadCount = notifications.where((n) => !n.isRead).length;
      state = state.copyWith(unreadCount: unreadCount);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  NotificationsState updateStateWithData(
    dynamic data,
    CacheMetadata newCache,
  ) {
    final notifications = data as List<NotificationItem>;
    final unreadCount = notifications.where((n) => !n.isRead).length;
    return state.copyWith(
      notifications: notifications,
      isLoading: false,
      error: null,
      cache: newCache,
      unreadCount: unreadCount,
    );
  }

  @override
  NotificationsState updateStateForLoading(
    bool isLoading,
    CacheMetadata cache,
  ) {
    return state.copyWith(isLoading: isLoading, cache: cache);
  }

  @override
  NotificationsState updateStateForError(
    String error,
    CacheMetadata cache,
  ) {
    return state.copyWith(isLoading: false, error: error, cache: cache);
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    try {
      await _service.markAsRead(id);
      final updated = state.notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      final unreadCount = updated.where((n) => !n.isRead).length;
      state = state.copyWith(notifications: updated, unreadCount: unreadCount);
    } catch (e) {
      // Optimistically update locally even if API fails
      final updated = state.notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      final unreadCount = updated.where((n) => !n.isRead).length;
      state = state.copyWith(notifications: updated, unreadCount: unreadCount);
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      final updated =
          state.notifications.map((n) => n.copyWith(isRead: true)).toList();
      state = state.copyWith(notifications: updated, unreadCount: 0);
    } catch (e) {
      // Optimistically update locally even if API fails
      final updated =
          state.notifications.map((n) => n.copyWith(isRead: true)).toList();
      state = state.copyWith(notifications: updated, unreadCount: 0);
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String id) async {
    try {
      await _service.deleteNotification(id);
      final updated = state.notifications.where((n) => n.id != id).toList();
      final unreadCount = updated.where((n) => !n.isRead).length;
      state = state.copyWith(notifications: updated, unreadCount: unreadCount);
    } catch (e) {
      // Keep in list if delete fails
    }
  }

  // Keep old method name for backwards compatibility
  Future<void> loadNotifications() => loadData(forceRefresh: true);
}

/// Provider for notifications
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref: ref);
});
