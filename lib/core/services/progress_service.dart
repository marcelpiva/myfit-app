import 'package:dio/dio.dart';

import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Progress service for weight, measurements, photos, and goals
class ProgressService {
  final ApiClient _client;

  ProgressService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // ==================== Weight Logs ====================

  /// Get weight logs with optional date filtering
  Future<List<Map<String, dynamic>>> getWeightLogs({
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
      if (fromDate != null) params['from_date'] = fromDate.toIso8601String().split('T')[0];
      if (toDate != null) params['to_date'] = toDate.toIso8601String().split('T')[0];

      final response = await _client.get(ApiEndpoints.weightLogs, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar pesos', e);
    }
  }

  /// Get latest weight log
  Future<Map<String, dynamic>?> getLatestWeight() async {
    try {
      final response = await _client.get(ApiEndpoints.weightLatest);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar peso', e);
    }
  }

  /// Create weight log
  Future<Map<String, dynamic>> createWeightLog({
    required double weightKg,
    DateTime? loggedAt,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'weight_kg': weightKg,
      };
      if (loggedAt != null) data['logged_at'] = loggedAt.toIso8601String();
      if (notes != null) data['notes'] = notes;

      final response = await _client.post(ApiEndpoints.weightLogs, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao registrar peso');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao registrar peso', e);
    }
  }

  /// Update weight log
  Future<Map<String, dynamic>> updateWeightLog(String logId, {
    double? weightKg,
    DateTime? loggedAt,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (weightKg != null) data['weight_kg'] = weightKg;
      if (loggedAt != null) data['logged_at'] = loggedAt.toIso8601String();
      if (notes != null) data['notes'] = notes;

      final response = await _client.put(ApiEndpoints.weightLog(logId), data: data);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar peso');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar peso', e);
    }
  }

  /// Delete weight log
  Future<void> deleteWeightLog(String logId) async {
    try {
      await _client.delete(ApiEndpoints.weightLog(logId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao excluir peso', e);
    }
  }

  // ==================== Measurements ====================

  /// Get measurement logs
  Future<List<Map<String, dynamic>>> getMeasurementLogs({
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
      if (fromDate != null) params['from_date'] = fromDate.toIso8601String().split('T')[0];
      if (toDate != null) params['to_date'] = toDate.toIso8601String().split('T')[0];

      final response = await _client.get(ApiEndpoints.measurementLogs, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar medidas', e);
    }
  }

  /// Get latest measurements
  Future<Map<String, dynamic>?> getLatestMeasurements() async {
    try {
      final response = await _client.get(ApiEndpoints.measurementLatest);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar medidas', e);
    }
  }

  /// Create measurement log
  Future<Map<String, dynamic>> createMeasurementLog({
    DateTime? loggedAt,
    double? chestCm,
    double? waistCm,
    double? hipsCm,
    double? bicepsCm,
    double? thighCm,
    double? calfCm,
    double? neckCm,
    double? forearmCm,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (loggedAt != null) data['logged_at'] = loggedAt.toIso8601String();
      if (chestCm != null) data['chest_cm'] = chestCm;
      if (waistCm != null) data['waist_cm'] = waistCm;
      if (hipsCm != null) data['hips_cm'] = hipsCm;
      if (bicepsCm != null) data['biceps_cm'] = bicepsCm;
      if (thighCm != null) data['thigh_cm'] = thighCm;
      if (calfCm != null) data['calf_cm'] = calfCm;
      if (neckCm != null) data['neck_cm'] = neckCm;
      if (forearmCm != null) data['forearm_cm'] = forearmCm;
      if (notes != null) data['notes'] = notes;

      final response = await _client.post(ApiEndpoints.measurementLogs, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao registrar medidas');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao registrar medidas', e);
    }
  }

  /// Update measurement log
  Future<Map<String, dynamic>> updateMeasurementLog(String logId, {
    double? chestCm,
    double? waistCm,
    double? hipsCm,
    double? bicepsCm,
    double? thighCm,
    double? calfCm,
    double? neckCm,
    double? forearmCm,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (chestCm != null) data['chest_cm'] = chestCm;
      if (waistCm != null) data['waist_cm'] = waistCm;
      if (hipsCm != null) data['hips_cm'] = hipsCm;
      if (bicepsCm != null) data['biceps_cm'] = bicepsCm;
      if (thighCm != null) data['thigh_cm'] = thighCm;
      if (calfCm != null) data['calf_cm'] = calfCm;
      if (neckCm != null) data['neck_cm'] = neckCm;
      if (forearmCm != null) data['forearm_cm'] = forearmCm;
      if (notes != null) data['notes'] = notes;

      final response = await _client.put(ApiEndpoints.measurementLog(logId), data: data);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar medidas');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar medidas', e);
    }
  }

  /// Delete measurement log
  Future<void> deleteMeasurementLog(String logId) async {
    try {
      await _client.delete(ApiEndpoints.measurementLog(logId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao excluir medidas', e);
    }
  }

  // ==================== Progress Photos ====================

  /// Get progress photos
  Future<List<Map<String, dynamic>>> getProgressPhotos({
    String? angle,
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
      if (angle != null) params['angle'] = angle;
      if (fromDate != null) params['from_date'] = fromDate.toIso8601String().split('T')[0];
      if (toDate != null) params['to_date'] = toDate.toIso8601String().split('T')[0];

      final response = await _client.get(ApiEndpoints.progressPhotos, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar fotos', e);
    }
  }

  /// Upload progress photo
  Future<Map<String, dynamic>> uploadProgressPhoto({
    required String photoUrl,
    required String angle,
    DateTime? loggedAt,
    String? notes,
    String? weightLogId,
    String? measurementLogId,
  }) async {
    try {
      final data = <String, dynamic>{
        'photo_url': photoUrl,
        'angle': angle,
      };
      if (loggedAt != null) data['logged_at'] = loggedAt.toIso8601String();
      if (notes != null) data['notes'] = notes;
      if (weightLogId != null) data['weight_log_id'] = weightLogId;
      if (measurementLogId != null) data['measurement_log_id'] = measurementLogId;

      final response = await _client.post(ApiEndpoints.progressPhotos, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao salvar foto');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao salvar foto', e);
    }
  }

  /// Delete progress photo
  Future<void> deleteProgressPhoto(String photoId) async {
    try {
      await _client.delete(ApiEndpoints.progressPhoto(photoId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao excluir foto', e);
    }
  }

  // ==================== Weight Goal ====================

  /// Get weight goal
  Future<Map<String, dynamic>?> getWeightGoal() async {
    try {
      final response = await _client.get(ApiEndpoints.weightGoal);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar meta', e);
    }
  }

  /// Create or update weight goal
  Future<Map<String, dynamic>> setWeightGoal({
    required double targetWeightKg,
    required double startWeightKg,
    DateTime? targetDate,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'target_weight_kg': targetWeightKg,
        'start_weight_kg': startWeightKg,
      };
      if (targetDate != null) data['target_date'] = targetDate.toIso8601String();
      if (notes != null) data['notes'] = notes;

      final response = await _client.post(ApiEndpoints.weightGoal, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao definir meta');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao definir meta', e);
    }
  }

  /// Delete weight goal
  Future<void> deleteWeightGoal() async {
    try {
      await _client.delete(ApiEndpoints.weightGoal);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao excluir meta', e);
    }
  }

  // ==================== Progress Stats ====================

  /// Get progress statistics
  Future<Map<String, dynamic>> getProgressStats({int days = 30}) async {
    try {
      final response = await _client.get(
        ApiEndpoints.progressStats,
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
