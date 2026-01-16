import 'package:dio/dio.dart';

import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Service for managing user notifications
class NotificationService {
  final ApiClient _client;

  NotificationService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// Get all notifications
  Future<List<Map<String, dynamic>>> getNotifications({
    int limit = 50,
    int offset = 0,
    bool? unreadOnly,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (unreadOnly != null) params['unread_only'] = unreadOnly;

      final response = await _client.get(
        ApiEndpoints.notifications,
        queryParameters: params,
      );
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar notificações', e);
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await _client.get(ApiEndpoints.notificationsUnreadCount);
      if (response.statusCode == 200 && response.data != null) {
        return response.data['count'] as int? ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar contagem', e);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client.post(ApiEndpoints.notificationRead(notificationId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao marcar como lida', e);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _client.post(ApiEndpoints.notificationsReadAll);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao marcar todas como lidas', e);
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _client.delete(ApiEndpoints.notification(notificationId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao excluir notificação', e);
    }
  }
}
