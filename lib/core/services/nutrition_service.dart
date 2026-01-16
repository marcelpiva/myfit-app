import 'package:dio/dio.dart';

import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Nutrition service for foods, diet plans, meal logs, and summaries
class NutritionService {
  final ApiClient _client;

  NutritionService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // ==================== Foods ====================

  /// Search foods
  Future<List<Map<String, dynamic>>> searchFoods({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.foods,
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
          : UnknownApiException(e.message ?? 'Erro ao buscar alimentos', e);
    }
  }

  /// Get food by ID
  Future<Map<String, dynamic>> getFood(String foodId) async {
    try {
      final response = await _client.get(ApiEndpoints.food(foodId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Alimento não encontrado');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar alimento', e);
    }
  }

  /// Get food by barcode
  Future<Map<String, dynamic>?> getFoodByBarcode(String barcode) async {
    try {
      final response = await _client.get(ApiEndpoints.foodBarcode(barcode));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao buscar por código de barras', e);
    }
  }

  /// Get favorite foods
  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final response = await _client.get(ApiEndpoints.foodFavorites);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar favoritos', e);
    }
  }

  /// Add food to favorites
  Future<void> addFavorite(String foodId) async {
    try {
      await _client.post(ApiEndpoints.foodFavorite(foodId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao adicionar favorito', e);
    }
  }

  /// Remove food from favorites
  Future<void> removeFavorite(String foodId) async {
    try {
      await _client.delete(ApiEndpoints.foodFavorite(foodId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao remover favorito', e);
    }
  }

  /// Create custom food
  Future<Map<String, dynamic>> createFood({
    required String name,
    required double calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    String? servingSize,
    String? barcode,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'calories': calories,
      };
      if (protein != null) data['protein'] = protein;
      if (carbs != null) data['carbs'] = carbs;
      if (fat != null) data['fat'] = fat;
      if (fiber != null) data['fiber'] = fiber;
      if (servingSize != null) data['serving_size'] = servingSize;
      if (barcode != null) data['barcode'] = barcode;

      final response = await _client.post(ApiEndpoints.foods, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao criar alimento');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao criar alimento', e);
    }
  }

  // ==================== Diet Plans ====================

  /// Get diet plans
  Future<List<Map<String, dynamic>>> getDietPlans({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.dietPlans,
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
          : UnknownApiException(e.message ?? 'Erro ao carregar planos', e);
    }
  }

  /// Get diet plan by ID
  Future<Map<String, dynamic>> getDietPlan(String planId) async {
    try {
      final response = await _client.get(ApiEndpoints.dietPlan(planId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Plano não encontrado');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar plano', e);
    }
  }

  /// Create diet plan
  Future<Map<String, dynamic>> createDietPlan({
    required String name,
    String? description,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
    List<Map<String, dynamic>>? meals,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
      };
      if (description != null) data['description'] = description;
      if (targetCalories != null) data['target_calories'] = targetCalories;
      if (targetProtein != null) data['target_protein'] = targetProtein;
      if (targetCarbs != null) data['target_carbs'] = targetCarbs;
      if (targetFat != null) data['target_fat'] = targetFat;
      if (meals != null) data['meals'] = meals;

      final response = await _client.post(ApiEndpoints.dietPlans, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao criar plano');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao criar plano', e);
    }
  }

  /// Update diet plan
  Future<Map<String, dynamic>> updateDietPlan(String planId, {
    String? name,
    String? description,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (targetCalories != null) data['target_calories'] = targetCalories;
      if (targetProtein != null) data['target_protein'] = targetProtein;
      if (targetCarbs != null) data['target_carbs'] = targetCarbs;
      if (targetFat != null) data['target_fat'] = targetFat;

      final response = await _client.put(ApiEndpoints.dietPlan(planId), data: data);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar plano');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar plano', e);
    }
  }

  /// Delete diet plan
  Future<void> deleteDietPlan(String planId) async {
    try {
      await _client.delete(ApiEndpoints.dietPlan(planId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao excluir plano', e);
    }
  }

  // ==================== Meal Logs ====================

  /// Get meal logs
  Future<List<Map<String, dynamic>>> getMealLogs({
    DateTime? date,
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
      if (date != null) params['date'] = date.toIso8601String().split('T')[0];
      if (fromDate != null) params['from_date'] = fromDate.toIso8601String().split('T')[0];
      if (toDate != null) params['to_date'] = toDate.toIso8601String().split('T')[0];

      final response = await _client.get(ApiEndpoints.mealLogs, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar refeições', e);
    }
  }

  /// Create meal log
  Future<Map<String, dynamic>> createMealLog({
    required String foodId,
    required String mealType,
    required double quantity,
    DateTime? loggedAt,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'food_id': foodId,
        'meal_type': mealType,
        'quantity': quantity,
      };
      if (loggedAt != null) data['logged_at'] = loggedAt.toIso8601String();
      if (notes != null) data['notes'] = notes;

      final response = await _client.post(ApiEndpoints.mealLogs, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao registrar refeição');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao registrar refeição', e);
    }
  }

  /// Update meal log
  Future<Map<String, dynamic>> updateMealLog(String logId, {
    String? mealType,
    double? quantity,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (mealType != null) data['meal_type'] = mealType;
      if (quantity != null) data['quantity'] = quantity;
      if (notes != null) data['notes'] = notes;

      final response = await _client.put(ApiEndpoints.mealLog(logId), data: data);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar refeição');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar refeição', e);
    }
  }

  /// Delete meal log
  Future<void> deleteMealLog(String logId) async {
    try {
      await _client.delete(ApiEndpoints.mealLog(logId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao excluir refeição', e);
    }
  }

  // ==================== Summaries ====================

  /// Get daily nutrition summary
  Future<Map<String, dynamic>> getDailySummary({DateTime? date}) async {
    try {
      final params = <String, dynamic>{};
      if (date != null) params['date'] = date.toIso8601String().split('T')[0];

      final response = await _client.get(
        ApiEndpoints.nutritionDailySummary,
        queryParameters: params,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao carregar resumo');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar resumo diário', e);
    }
  }

  /// Get weekly nutrition summary
  Future<Map<String, dynamic>> getWeeklySummary({DateTime? startDate}) async {
    try {
      final params = <String, dynamic>{};
      if (startDate != null) params['start_date'] = startDate.toIso8601String().split('T')[0];

      final response = await _client.get(
        ApiEndpoints.nutritionWeeklySummary,
        queryParameters: params,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao carregar resumo');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar resumo semanal', e);
    }
  }

  // ==================== Diet Assignments ====================

  /// Get diet assignments
  Future<List<Map<String, dynamic>>> getDietAssignments() async {
    try {
      final response = await _client.get(ApiEndpoints.dietAssignments);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar atribuições', e);
    }
  }

  /// Create diet assignment (for nutritionists)
  Future<Map<String, dynamic>> createDietAssignment({
    required String dietPlanId,
    required String patientId,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'diet_plan_id': dietPlanId,
        'patient_id': patientId,
      };
      if (startDate != null) data['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) data['end_date'] = endDate.toIso8601String().split('T')[0];
      if (notes != null) data['notes'] = notes;

      final response = await _client.post(ApiEndpoints.dietAssignments, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atribuir plano');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atribuir plano', e);
    }
  }

  /// Delete diet assignment
  Future<void> deleteDietAssignment(String assignmentId) async {
    try {
      await _client.delete(ApiEndpoints.dietAssignment(assignmentId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao remover atribuição', e);
    }
  }

  // ==================== Patient Notes ====================

  /// Get patient notes (for nutritionists)
  Future<List<Map<String, dynamic>>> getPatientNotes(String patientId) async {
    try {
      final response = await _client.get(ApiEndpoints.patientNotes(patientId));
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar anotações', e);
    }
  }

  /// Create patient note
  Future<Map<String, dynamic>> createPatientNote({
    required String patientId,
    required String content,
    String? category,
  }) async {
    try {
      final data = <String, dynamic>{
        'content': content,
      };
      if (category != null) data['category'] = category;

      final response = await _client.post(
        ApiEndpoints.patientNotes(patientId),
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao criar anotação');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao criar anotação', e);
    }
  }

  // ==================== Patient Diet Plan ====================

  /// Get patient's current diet plan (for nutritionists)
  Future<Map<String, dynamic>> getPatientDietPlan(String patientId) async {
    try {
      final response = await _client.get(ApiEndpoints.patientDietPlan(patientId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Plano de dieta não encontrado');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar plano de dieta', e);
    }
  }

  /// Get patient's diet plan history (for nutritionists)
  Future<List<Map<String, dynamic>>> getPatientDietHistory(String patientId) async {
    try {
      final response = await _client.get(ApiEndpoints.patientDietHistory(patientId));
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar histórico de dietas', e);
    }
  }
}
