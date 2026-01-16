import 'package:dio/dio.dart';

import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// User service for profile and settings management
class UserService {
  final ApiClient _client;

  UserService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _client.get(ApiEndpoints.userProfile);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao carregar perfil');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar perfil', e);
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    DateTime? birthDate,
    String? gender,
    double? heightCm,
    String? bio,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (birthDate != null) data['birth_date'] = birthDate.toIso8601String().split('T')[0];
      if (gender != null) data['gender'] = gender;
      if (heightCm != null) data['height_cm'] = heightCm;
      if (bio != null) data['bio'] = bio;

      final response = await _client.put(ApiEndpoints.userProfile, data: data);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar perfil');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar perfil', e);
    }
  }

  /// Upload avatar image
  Future<String> uploadAvatar(String filePath) async {
    try {
      final response = await _client.uploadFile(
        ApiEndpoints.userAvatar,
        filePath: filePath,
        fieldName: 'file',
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data['avatar_url'] as String;
      }
      throw const ServerException('Erro ao fazer upload do avatar');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao fazer upload', e);
    }
  }

  /// Get user settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await _client.get(ApiEndpoints.userSettings);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao carregar configurações');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar configurações', e);
    }
  }

  /// Update user settings
  Future<Map<String, dynamic>> updateSettings({
    String? theme,
    String? language,
    String? units,
    bool? notificationsEnabled,
    double? goalWeight,
    int? targetCalories,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (theme != null) data['theme'] = theme;
      if (language != null) data['language'] = language;
      if (units != null) data['units'] = units;
      if (notificationsEnabled != null) data['notifications_enabled'] = notificationsEnabled;
      if (goalWeight != null) data['goal_weight'] = goalWeight;
      if (targetCalories != null) data['target_calories'] = targetCalories;

      final response = await _client.put(ApiEndpoints.userSettings, data: data);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar configurações');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar configurações', e);
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _client.put(
        ApiEndpoints.userPassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      if (response.statusCode != 204) {
        throw const ServerException('Erro ao alterar senha');
      }
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao alterar senha', e);
    }
  }

  /// Search users
  Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _client.get(
        ApiEndpoints.userSearch,
        queryParameters: {
          'q': query,
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
          : UnknownApiException(e.message ?? 'Erro na busca', e);
    }
  }
}
