import 'package:dio/dio.dart';

import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Service for managing chat conversations and messages
class ChatService {
  final ApiClient _client;

  ChatService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// Get all conversations
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final response = await _client.get(ApiEndpoints.chatConversations);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar conversas', e);
    }
  }

  /// Get messages for a conversation
  Future<List<Map<String, dynamic>>> getMessages(String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.chatMessages(conversationId),
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar mensagens', e);
    }
  }

  /// Send a message
  Future<Map<String, dynamic>> sendMessage(String conversationId, String text) async {
    try {
      final response = await _client.post(
        ApiEndpoints.chatSendMessage(conversationId),
        data: {'text': text},
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
}
