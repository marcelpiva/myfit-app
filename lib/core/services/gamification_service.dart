import 'package:dio/dio.dart';

import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Gamification service for points, achievements, and leaderboards
class GamificationService {
  final ApiClient _client;

  GamificationService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // ==================== Points ====================

  /// Get user's current points
  Future<Map<String, dynamic>> getMyPoints() async {
    try {
      final response = await _client.get(ApiEndpoints.points);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao carregar pontos');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar pontos', e);
    }
  }

  /// Get points transaction history
  Future<List<Map<String, dynamic>>> getPointsHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.pointsHistory,
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
          : UnknownApiException(e.message ?? 'Erro ao carregar histórico', e);
    }
  }

  /// Get streak information
  Future<Map<String, dynamic>> getStreak() async {
    try {
      final response = await _client.get(ApiEndpoints.pointsStreak);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao carregar streak');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar streak', e);
    }
  }

  // ==================== Achievements ====================

  /// Get all available achievements
  Future<List<Map<String, dynamic>>> getAllAchievements() async {
    try {
      final response = await _client.get(ApiEndpoints.achievements);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar conquistas', e);
    }
  }

  /// Get user's unlocked achievements
  Future<List<Map<String, dynamic>>> getMyAchievements() async {
    try {
      final response = await _client.get(ApiEndpoints.myAchievements);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar minhas conquistas', e);
    }
  }

  /// Award achievement (admin only)
  Future<Map<String, dynamic>> awardAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.awardAchievement,
        data: {
          'user_id': userId,
          'achievement_id': achievementId,
        },
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao conceder conquista');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao conceder conquista', e);
    }
  }

  // ==================== Leaderboard ====================

  /// Get leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard({
    String period = 'weekly',
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.leaderboard,
        queryParameters: {
          'period': period,
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
          : UnknownApiException(e.message ?? 'Erro ao carregar ranking', e);
    }
  }

  /// Get user's leaderboard position
  Future<Map<String, dynamic>?> getMyLeaderboardPosition({
    String period = 'weekly',
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.myLeaderboardPosition,
        queryParameters: {'period': period},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar posição', e);
    }
  }

  /// Refresh leaderboard (admin only)
  Future<void> refreshLeaderboard() async {
    try {
      await _client.post(ApiEndpoints.refreshLeaderboard);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar ranking', e);
    }
  }

  // ==================== Stats ====================

  /// Get gamification statistics
  Future<Map<String, dynamic>> getGamificationStats() async {
    try {
      final response = await _client.get(ApiEndpoints.gamificationStats);
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
