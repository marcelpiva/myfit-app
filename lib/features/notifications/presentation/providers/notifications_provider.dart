import 'package:flutter_riverpod/flutter_riverpod.dart';

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
class NotificationsState {
  final List<NotificationItem> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    List<NotificationItem>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Notifications notifier
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationService _service;

  NotificationsNotifier({NotificationService? service})
      : _service = service ?? NotificationService(),
        super(const NotificationsState());

  /// Load notifications
  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getNotifications();
      final notifications = data.map((e) => NotificationItem.fromJson(e)).toList();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
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
      final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
      state = state.copyWith(notifications: updated, unreadCount: 0);
    } catch (e) {
      // Optimistically update locally even if API fails
      final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
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
}

/// Provider for notifications
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier();
});
