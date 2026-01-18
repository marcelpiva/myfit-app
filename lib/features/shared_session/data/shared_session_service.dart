/// Service for shared workout sessions (co-training).
library;

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/environment.dart';
import '../../../core/error/api_exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/models/shared_session.dart';

/// Service for managing shared workout sessions.
class SharedSessionService {
  final ApiClient _client;
  StreamSubscription? _eventSubscription;
  final _eventController = StreamController<SessionEvent>.broadcast();

  SharedSessionService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// Stream of real-time session events.
  Stream<SessionEvent> get eventStream => _eventController.stream;

  /// Get list of active sessions (Students Now).
  Future<List<ActiveSession>> getActiveSessions({String? organizationId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (organizationId != null) {
        queryParams['organization_id'] = organizationId;
      }

      final response = await _client.get(
        '/workouts/sessions/active',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List;
        return data.map((e) => ActiveSession.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar sessões ativas', e);
    }
  }

  /// Get session details.
  Future<SharedSession> getSession(String sessionId) async {
    try {
      final response = await _client.get('/workouts/sessions/$sessionId');

      if (response.statusCode == 200 && response.data != null) {
        return SharedSession.fromJson(response.data as Map<String, dynamic>);
      }
      throw const NotFoundException('Sessão não encontrada');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar sessão', e);
    }
  }

  /// Trainer joins a session for co-training.
  Future<Map<String, dynamic>> joinSession(String sessionId) async {
    try {
      final response = await _client.post('/workouts/sessions/$sessionId/join');

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao entrar na sessão');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao entrar na sessão', e);
    }
  }

  /// Trainer leaves a co-training session.
  Future<void> leaveSession(String sessionId) async {
    try {
      await _client.post('/workouts/sessions/$sessionId/leave');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao sair da sessão', e);
    }
  }

  /// Update session status.
  Future<SharedSession> updateSessionStatus(
    String sessionId,
    SessionStatus status,
  ) async {
    try {
      final response = await _client.put(
        '/workouts/sessions/$sessionId/status',
        data: {'status': status.name},
      );

      if (response.statusCode == 200 && response.data != null) {
        return SharedSession.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Erro ao atualizar status');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar status', e);
    }
  }

  /// Record a set completion.
  Future<SessionSet> recordSet({
    required String sessionId,
    required String exerciseId,
    required int setNumber,
    required int repsCompleted,
    double? weightKg,
    int? durationSeconds,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'exercise_id': exerciseId,
        'set_number': setNumber,
        'reps_completed': repsCompleted,
      };
      if (weightKg != null) data['weight_kg'] = weightKg;
      if (durationSeconds != null) data['duration_seconds'] = durationSeconds;
      if (notes != null) data['notes'] = notes;

      final response = await _client.post(
        '/workouts/sessions/$sessionId/sets',
        data: data,
      );

      if (response.statusCode == 201 && response.data != null) {
        return SessionSet.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Erro ao registrar série');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao registrar série', e);
    }
  }

  /// Create trainer adjustment.
  Future<TrainerAdjustment> createAdjustment({
    required String sessionId,
    required String exerciseId,
    int? setNumber,
    double? suggestedWeightKg,
    int? suggestedReps,
    String? note,
  }) async {
    try {
      final data = <String, dynamic>{
        'session_id': sessionId,
        'exercise_id': exerciseId,
      };
      if (setNumber != null) data['set_number'] = setNumber;
      if (suggestedWeightKg != null) data['suggested_weight_kg'] = suggestedWeightKg;
      if (suggestedReps != null) data['suggested_reps'] = suggestedReps;
      if (note != null) data['note'] = note;

      final response = await _client.post(
        '/workouts/sessions/$sessionId/adjustments',
        data: data,
      );

      if (response.statusCode == 201 && response.data != null) {
        return TrainerAdjustment.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Erro ao criar ajuste');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao criar ajuste', e);
    }
  }

  /// Send a message during co-training.
  Future<SessionMessage> sendMessage({
    required String sessionId,
    required String message,
  }) async {
    try {
      final response = await _client.post(
        '/workouts/sessions/$sessionId/messages',
        data: {
          'session_id': sessionId,
          'message': message,
        },
      );

      if (response.statusCode == 201 && response.data != null) {
        return SessionMessage.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Erro ao enviar mensagem');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao enviar mensagem', e);
    }
  }

  /// Get messages from a session.
  Future<List<SessionMessage>> getMessages(
    String sessionId, {
    int limit = 50,
  }) async {
    try {
      final response = await _client.get(
        '/workouts/sessions/$sessionId/messages',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List;
        return data.map((e) => SessionMessage.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar mensagens', e);
    }
  }

  /// Subscribe to real-time session events via SSE.
  Future<void> subscribeToSession(String sessionId) async {
    await _eventSubscription?.cancel();

    final baseUrl = EnvironmentConfig.apiBaseUrl;
    final uri = Uri.parse('$baseUrl/workouts/sessions/$sessionId/stream');
    final request = http.Request('GET', uri);

    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final client = http.Client();
    try {
      final response = await client.send(request);

      if (response.statusCode != 200) {
        client.close();
        throw Exception('Failed to subscribe to session');
      }

      _eventSubscription = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (line.startsWith('data: ')) {
            try {
              final jsonStr = line.substring(6);
              final json = jsonDecode(jsonStr) as Map<String, dynamic>;
              final event = SessionEvent.fromJson(json);
              _eventController.add(event);
            } catch (e) {
              // Ignore parse errors (heartbeats, etc.)
            }
          }
        },
        onError: (error) {
          _eventController.addError(error);
        },
        onDone: () {
          client.close();
        },
      );
    } catch (e) {
      client.close();
      rethrow;
    }
  }

  /// Unsubscribe from real-time events.
  Future<void> unsubscribe() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  /// Dispose resources.
  void dispose() {
    _eventSubscription?.cancel();
    _eventController.close();
  }
}
