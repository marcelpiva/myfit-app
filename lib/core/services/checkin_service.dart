import 'package:dio/dio.dart';

import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Check-in service for gym check-ins
class CheckinService {
  final ApiClient _client;

  CheckinService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // ==================== Gyms ====================

  /// Get list of gyms
  Future<List<Map<String, dynamic>>> getGyms({
    String? organizationId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (organizationId != null) params['organization_id'] = organizationId;

      final response = await _client.get(ApiEndpoints.gyms, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar academias', e);
    }
  }

  /// Get gym details
  Future<Map<String, dynamic>> getGym(String gymId) async {
    try {
      final response = await _client.get(ApiEndpoints.gym(gymId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Academia não encontrada');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar academia', e);
    }
  }

  // ==================== Check-ins ====================

  /// Get check-in history
  Future<List<Map<String, dynamic>>> getCheckins({
    String? gymId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (gymId != null) params['gym_id'] = gymId;
      if (fromDate != null) params['from_date'] = fromDate.toIso8601String().split('T')[0];
      if (toDate != null) params['to_date'] = toDate.toIso8601String().split('T')[0];

      final response = await _client.get(ApiEndpoints.checkins, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar check-ins', e);
    }
  }

  /// Get active check-in (if any)
  Future<Map<String, dynamic>?> getActiveCheckin() async {
    try {
      final response = await _client.get(ApiEndpoints.checkinActive);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao verificar check-in', e);
    }
  }

  /// Manual check-in
  Future<Map<String, dynamic>> checkinManual({
    required String gymId,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'gym_id': gymId,
        'method': 'MANUAL',
      };
      if (notes != null) data['notes'] = notes;

      final response = await _client.post(ApiEndpoints.checkins, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao fazer check-in');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao fazer check-in', e);
    }
  }

  /// Check-in by code
  Future<Map<String, dynamic>> checkinByCode(String code) async {
    try {
      final response = await _client.post(
        ApiEndpoints.checkinByCode,
        data: {'code': code},
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao fazer check-in');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Código inválido ou expirado', e);
    }
  }

  /// Check-in by location
  Future<Map<String, dynamic>> checkinByLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.checkinByLocation,
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao fazer check-in');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Você não está próximo de uma academia', e);
    }
  }

  /// Checkout
  Future<Map<String, dynamic>> checkout({String? notes}) async {
    try {
      final data = <String, dynamic>{};
      if (notes != null) data['notes'] = notes;

      final response = await _client.post(ApiEndpoints.checkout, data: data);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao fazer checkout');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Você não está em check-in', e);
    }
  }

  // ==================== Check-in Codes ====================

  /// Create check-in code (for gym admins)
  Future<Map<String, dynamic>> createCheckinCode({
    required String gymId,
    DateTime? expiresAt,
    int? maxUses,
  }) async {
    try {
      final data = <String, dynamic>{
        'gym_id': gymId,
      };
      if (expiresAt != null) data['expires_at'] = expiresAt.toIso8601String();
      if (maxUses != null) data['max_uses'] = maxUses;

      final response = await _client.post(ApiEndpoints.checkinCodes, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao criar código');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao criar código', e);
    }
  }

  /// Deactivate check-in code
  Future<void> deactivateCheckinCode(String code) async {
    try {
      await _client.delete(ApiEndpoints.checkinCode(code));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao desativar código', e);
    }
  }

  // ==================== Check-in Requests ====================

  /// Get pending check-in requests (for trainers/admins)
  Future<List<Map<String, dynamic>>> getPendingRequests({String? gymId}) async {
    try {
      final params = <String, dynamic>{};
      if (gymId != null) params['gym_id'] = gymId;

      final response = await _client.get(ApiEndpoints.checkinRequests, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar solicitações', e);
    }
  }

  /// Create check-in request
  Future<Map<String, dynamic>> createCheckinRequest({
    required String gymId,
    required String approverId,
    String? reason,
  }) async {
    try {
      final data = <String, dynamic>{
        'gym_id': gymId,
        'approver_id': approverId,
      };
      if (reason != null) data['reason'] = reason;

      final response = await _client.post(ApiEndpoints.checkinRequests, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao criar solicitação');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao criar solicitação', e);
    }
  }

  /// Respond to check-in request
  Future<Map<String, dynamic>> respondToRequest({
    required String requestId,
    required bool approved,
    String? responseNote,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.checkinRequestRespond(requestId),
        data: {
          'approved': approved,
          if (responseNote != null) 'response_note': responseNote,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao responder solicitação');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao responder solicitação', e);
    }
  }

  // ==================== Stats ====================

  /// Get check-in statistics
  Future<Map<String, dynamic>> getCheckinStats({int days = 30}) async {
    try {
      final response = await _client.get(
        ApiEndpoints.checkinStats,
        queryParameters: {'days': days},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao carregar estatísticas');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar estatísticas', e);
    }
  }
}
