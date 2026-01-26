import 'package:dio/dio.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/network/api_client.dart';

/// Service for sending broadcast messages to students
class BroadcastService {
  final ApiClient _client;

  BroadcastService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// Send broadcast message to students
  ///
  /// [orgId] - Organization ID
  /// [title] - Message title
  /// [message] - Message body
  /// [recipientType] - 'all', 'active', 'inactive', or 'selected'
  /// [recipientIds] - List of specific user IDs (when recipientType is 'selected')
  /// [scheduledAt] - Optional scheduled time (null = send immediately)
  Future<Map<String, dynamic>> sendBroadcast(
    String orgId, {
    required String title,
    required String message,
    required String recipientType,
    List<String>? recipientIds,
    DateTime? scheduledAt,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title,
        'message': message,
        'recipient_type': recipientType,
      };

      if (recipientIds != null && recipientIds.isNotEmpty) {
        data['recipient_ids'] = recipientIds;
      }

      if (scheduledAt != null) {
        data['scheduled_at'] = scheduledAt.toUtc().toIso8601String();
      }

      final response = await _client.post(
        '/organizations/$orgId/broadcasts',
        data: data,
      );

      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }

      throw const ServerException('Erro ao enviar mensagem');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao enviar mensagem', e);
    }
  }

  /// Get broadcast history
  Future<List<Map<String, dynamic>>> getBroadcastHistory(
    String orgId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client.get(
        '/organizations/$orgId/broadcasts',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar historico', e);
    }
  }

  /// Cancel a scheduled broadcast
  Future<void> cancelBroadcast(String orgId, String broadcastId) async {
    try {
      await _client.delete('/organizations/$orgId/broadcasts/$broadcastId');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao cancelar mensagem', e);
    }
  }
}
