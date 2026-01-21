import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Workout service for workouts, exercises, assignments, and sessions
class WorkoutService {
  final ApiClient _client;

  WorkoutService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // ==================== Workouts ====================

  /// Get list of workouts
  Future<List<Map<String, dynamic>>> getWorkouts({
    String? creatorId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (creatorId != null) params['creator_id'] = creatorId;

      final response = await _client.get(ApiEndpoints.workouts, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar treinos', e);
    }
  }

  /// Get workout by ID
  Future<Map<String, dynamic>> getWorkout(String workoutId) async {
    try {
      final response = await _client.get(ApiEndpoints.workout(workoutId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Treino não encontrado');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar treino', e);
    }
  }

  /// Create workout
  Future<Map<String, dynamic>> createWorkout({
    required String name,
    String? description,
    String? difficulty,
    int? estimatedDuration,
    List<String>? muscleGroups,
    List<Map<String, dynamic>>? exercises,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
      };
      if (description != null) data['description'] = description;
      if (difficulty != null) data['difficulty'] = difficulty;
      if (estimatedDuration != null) data['estimated_duration_min'] = estimatedDuration;
      if (muscleGroups != null) data['target_muscles'] = muscleGroups;
      if (exercises != null) data['exercises'] = exercises;

      final response = await _client.post(ApiEndpoints.workouts, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao criar treino');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao criar treino', e);
    }
  }

  /// Update workout
  Future<Map<String, dynamic>> updateWorkout(String workoutId, {
    String? name,
    String? description,
    String? difficulty,
    int? estimatedDuration,
    List<String>? muscleGroups,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (difficulty != null) data['difficulty'] = difficulty;
      if (estimatedDuration != null) data['estimated_duration_min'] = estimatedDuration;
      if (muscleGroups != null) data['target_muscles'] = muscleGroups;

      final response = await _client.put(ApiEndpoints.workout(workoutId), data: data);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar treino');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar treino', e);
    }
  }

  /// Delete workout
  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _client.delete(ApiEndpoints.workout(workoutId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao excluir treino', e);
    }
  }

  /// Duplicate workout
  Future<Map<String, dynamic>> duplicateWorkout(String workoutId) async {
    try {
      final response = await _client.post(ApiEndpoints.workoutDuplicate(workoutId));
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao duplicar treino');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao duplicar treino', e);
    }
  }

  // ==================== Workout Exercises ====================

  /// Get workout exercises
  Future<List<Map<String, dynamic>>> getWorkoutExercises(String workoutId) async {
    try {
      final response = await _client.get(ApiEndpoints.workoutExercises(workoutId));
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar exercícios', e);
    }
  }

  /// Add exercise to workout
  Future<Map<String, dynamic>> addExerciseToWorkout(
    String workoutId, {
    required String exerciseId,
    required int sets,
    required int reps,
    double? weight,
    int? restSeconds,
    int? orderIndex,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'exercise_id': exerciseId,
        'sets': sets,
        'reps': reps,
      };
      if (weight != null) data['weight'] = weight;
      if (restSeconds != null) data['rest_seconds'] = restSeconds;
      if (orderIndex != null) data['order_index'] = orderIndex;
      if (notes != null) data['notes'] = notes;

      final response = await _client.post(
        ApiEndpoints.workoutExercises(workoutId),
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao adicionar exercício');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao adicionar exercício', e);
    }
  }

  /// Update workout exercise
  Future<Map<String, dynamic>> updateWorkoutExercise(
    String workoutId,
    String exerciseId, {
    int? sets,
    int? reps,
    double? weight,
    int? restSeconds,
    int? orderIndex,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (sets != null) data['sets'] = sets;
      if (reps != null) data['reps'] = reps;
      if (weight != null) data['weight'] = weight;
      if (restSeconds != null) data['rest_seconds'] = restSeconds;
      if (orderIndex != null) data['order_index'] = orderIndex;
      if (notes != null) data['notes'] = notes;

      final response = await _client.put(
        ApiEndpoints.workoutExercise(workoutId, exerciseId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar exercício');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar exercício', e);
    }
  }

  /// Remove exercise from workout
  Future<void> removeExerciseFromWorkout(String workoutId, String exerciseId) async {
    try {
      await _client.delete(ApiEndpoints.workoutExercise(workoutId, exerciseId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao remover exercício', e);
    }
  }

  // ==================== Exercises Library ====================

  /// Get exercises library
  Future<List<Map<String, dynamic>>> getExercises({
    String? muscleGroup,
    String? equipment,
    String? difficulty,
    String? query,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      // Convert camelCase to snake_case for backend compatibility
      if (muscleGroup != null) {
        final snakeCaseMuscle = muscleGroup.replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        );
        params['muscle_group'] = snakeCaseMuscle;
      }
      if (equipment != null) params['equipment'] = equipment;
      if (difficulty != null) params['difficulty'] = difficulty;
      if (query != null) params['search'] = query;

      final response = await _client.get(ApiEndpoints.exercises, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar exercícios', e);
    }
  }

  /// Get exercise by ID
  Future<Map<String, dynamic>> getExercise(String exerciseId) async {
    try {
      final response = await _client.get(ApiEndpoints.exercise(exerciseId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Exercício não encontrado');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar exercício', e);
    }
  }

  /// Create exercise
  Future<Map<String, dynamic>> createExercise({
    required String name,
    required String muscleGroup,
    String? description,
    String? equipment,
    String? difficulty,
    String? videoUrl,
    String? instructions,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'muscle_group': muscleGroup,
      };
      if (description != null) data['description'] = description;
      if (equipment != null) data['equipment'] = equipment;
      if (difficulty != null) data['difficulty'] = difficulty;
      if (videoUrl != null) data['video_url'] = videoUrl;
      if (instructions != null) data['instructions'] = instructions;

      final response = await _client.post(ApiEndpoints.exercises, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao criar exercício');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao criar exercício', e);
    }
  }

  // ==================== Workout Assignments ====================

  /// Get workout assignments
  Future<List<Map<String, dynamic>>> getWorkoutAssignments({
    String? studentId,
    String? trainerId,
    bool? active,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (studentId != null) params['student_id'] = studentId;
      if (trainerId != null) params['trainer_id'] = trainerId;
      if (active != null) params['active'] = active;

      final response = await _client.get(
        ApiEndpoints.workoutAssignments,
        queryParameters: params,
      );
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

  /// Create workout assignment
  Future<Map<String, dynamic>> createWorkoutAssignment({
    required String workoutId,
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'workout_id': workoutId,
        'student_id': studentId,
      };
      if (startDate != null) data['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) data['end_date'] = endDate.toIso8601String().split('T')[0];
      if (notes != null) data['notes'] = notes;

      final response = await _client.post(ApiEndpoints.workoutAssignments, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atribuir treino');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atribuir treino', e);
    }
  }

  /// Delete workout assignment
  Future<void> deleteWorkoutAssignment(String assignmentId) async {
    try {
      await _client.delete(ApiEndpoints.workoutAssignment(assignmentId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao remover atribuição', e);
    }
  }

  // ==================== Workout Sessions ====================

  /// Get workout sessions
  Future<List<Map<String, dynamic>>> getWorkoutSessions({
    String? workoutId,
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
      if (workoutId != null) params['workout_id'] = workoutId;
      if (fromDate != null) params['from_date'] = fromDate.toIso8601String().split('T')[0];
      if (toDate != null) params['to_date'] = toDate.toIso8601String().split('T')[0];

      final response = await _client.get(ApiEndpoints.workoutSessions, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar sessões', e);
    }
  }

  /// Get workout session by ID
  Future<Map<String, dynamic>> getWorkoutSession(String sessionId) async {
    try {
      final response = await _client.get(ApiEndpoints.workoutSession(sessionId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Sessão não encontrada');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar sessão', e);
    }
  }

  /// Start a new workout session
  Future<Map<String, dynamic>> startWorkoutSession({
    required String workoutId,
    String? assignmentId,
  }) async {
    try {
      final data = <String, dynamic>{
        'workout_id': workoutId,
      };
      if (assignmentId != null) data['assignment_id'] = assignmentId;

      final response = await _client.post(ApiEndpoints.workoutSessions, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao iniciar sessão');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao iniciar sessão', e);
    }
  }

  /// Record a set in session
  Future<Map<String, dynamic>> recordSessionSet(
    String sessionId, {
    required String exerciseId,
    required int setNumber,
    required int reps,
    double? weight,
    int? durationSeconds,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'exercise_id': exerciseId,
        'set_number': setNumber,
        'reps': reps,
      };
      if (weight != null) data['weight'] = weight;
      if (durationSeconds != null) data['duration_seconds'] = durationSeconds;
      if (notes != null) data['notes'] = notes;

      final response = await _client.post(
        ApiEndpoints.workoutSessionSets(sessionId),
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao registrar série');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao registrar série', e);
    }
  }

  /// Complete workout session
  Future<Map<String, dynamic>> completeWorkoutSession(
    String sessionId, {
    String? notes,
    int? rating,
    int? perceivedExertion,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (notes != null) data['notes'] = notes;
      if (rating != null) data['rating'] = rating;
      if (perceivedExertion != null) data['perceived_exertion'] = perceivedExertion;

      final response = await _client.post(
        ApiEndpoints.workoutSessionComplete(sessionId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao finalizar sessão');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao finalizar sessão', e);
    }
  }

  // ==================== Training Plans ====================

  /// Get list of training plans
  Future<List<Map<String, dynamic>>> getPlans({
    bool? templatesOnly,
    String? search,
    String? studentId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (templatesOnly != null) params['templates_only'] = templatesOnly;
      if (search != null) params['search'] = search;
      if (studentId != null) params['student_id'] = studentId;

      debugPrint('getPlans: Fetching from ${ApiEndpoints.plans} with params: $params');
      final response = await _client.get(ApiEndpoints.plans, queryParameters: params);
      debugPrint('getPlans: Response status: ${response.statusCode}');
      debugPrint('getPlans: Response data type: ${response.data?.runtimeType}');

      if (response.statusCode == 200 && response.data != null) {
        // Handle both array response and paginated response formats
        final data = response.data;
        if (data is List) {
          debugPrint('getPlans: Data is List with ${data.length} items');
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['data'] is List) {
          debugPrint('getPlans: Data is Map with data[] key');
          return (data['data'] as List).cast<Map<String, dynamic>>();
        } else if (data is Map && data['items'] is List) {
          debugPrint('getPlans: Data is Map with items[] key');
          return (data['items'] as List).cast<Map<String, dynamic>>();
        } else if (data is Map && data['results'] is List) {
          debugPrint('getPlans: Data is Map with results[] key');
          return (data['results'] as List).cast<Map<String, dynamic>>();
        } else {
          debugPrint('getPlans: Unexpected data format: $data');
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint('getPlans DioException: ${e.message}');
      debugPrint('getPlans response: ${e.response?.data}');
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.response?.data?['detail'] ?? e.message ?? 'Erro ao carregar planos', e);
    } catch (e, stackTrace) {
      debugPrint('getPlans Error: $e');
      debugPrint('getPlans StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Get catalog templates (public templates from platform)
  Future<List<Map<String, dynamic>>> getCatalogTemplates({
    String? search,
    String? goal,
    String? difficulty,
    String? splitType,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (goal != null) params['goal'] = goal;
      if (difficulty != null) params['difficulty'] = difficulty;
      if (splitType != null) params['split_type'] = splitType;

      debugPrint('getCatalogTemplates: Fetching from ${ApiEndpoints.plansCatalog} with params: $params');
      final response = await _client.get(ApiEndpoints.plansCatalog, queryParameters: params);
      debugPrint('getCatalogTemplates: Response status: ${response.statusCode}');
      debugPrint('getCatalogTemplates: Response data type: ${response.data?.runtimeType}');

      if (response.statusCode == 200 && response.data != null) {
        // Handle both array response and paginated response formats
        final data = response.data;
        if (data is List) {
          debugPrint('getCatalogTemplates: Data is List with ${data.length} items');
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['data'] is List) {
          debugPrint('getCatalogTemplates: Data is Map with data[] key');
          return (data['data'] as List).cast<Map<String, dynamic>>();
        } else if (data is Map && data['items'] is List) {
          debugPrint('getCatalogTemplates: Data is Map with items[] key');
          return (data['items'] as List).cast<Map<String, dynamic>>();
        } else if (data is Map && data['results'] is List) {
          debugPrint('getCatalogTemplates: Data is Map with results[] key');
          return (data['results'] as List).cast<Map<String, dynamic>>();
        } else {
          debugPrint('getCatalogTemplates: Unexpected data format: $data');
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint('getCatalogTemplates DioException: ${e.message}');
      debugPrint('getCatalogTemplates response: ${e.response?.data}');
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.response?.data?['detail'] ?? e.message ?? 'Erro ao carregar catálogo', e);
    } catch (e, stackTrace) {
      debugPrint('getCatalogTemplates Error: $e');
      debugPrint('getCatalogTemplates StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Get plan by ID
  Future<Map<String, dynamic>> getPlan(String planId) async {
    try {
      final response = await _client.get(ApiEndpoints.plan(planId));
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

  /// Create training plan
  Future<String> createPlan({
    required String name,
    required String goal,
    required String difficulty,
    required String splitType,
    int? durationWeeks,
    int? targetWorkoutMinutes,
    bool isTemplate = false,
    List<Map<String, dynamic>>? workouts,
    // Diet fields
    bool? includeDiet,
    String? dietType,
    int? dailyCalories,
    int? proteinGrams,
    int? carbsGrams,
    int? fatGrams,
    int? mealsPerDay,
    String? dietNotes,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'goal': goal,
        'difficulty': difficulty,
        'split_type': splitType,
        'is_template': isTemplate,
      };
      if (durationWeeks != null) data['duration_weeks'] = durationWeeks;
      if (targetWorkoutMinutes != null) data['target_workout_minutes'] = targetWorkoutMinutes;
      if (workouts != null) data['workouts'] = workouts;
      // Diet fields
      if (includeDiet != null) data['include_diet'] = includeDiet;
      if (dietType != null) data['diet_type'] = dietType;
      if (dailyCalories != null) data['daily_calories'] = dailyCalories;
      if (proteinGrams != null) data['protein_grams'] = proteinGrams;
      if (carbsGrams != null) data['carbs_grams'] = carbsGrams;
      if (fatGrams != null) data['fat_grams'] = fatGrams;
      if (mealsPerDay != null) data['meals_per_day'] = mealsPerDay;
      if (dietNotes != null) data['diet_notes'] = dietNotes;

      final response = await _client.post(ApiEndpoints.plans, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return (response.data as Map<String, dynamic>)['id'] as String;
      }
      debugPrint('createPlan: Unexpected response - status: ${response.statusCode}, data: ${response.data}');
      throw ServerException('Erro ao criar plano (status: ${response.statusCode})');
    } on DioException catch (e) {
      debugPrint('createPlan DioException: ${e.message}');
      debugPrint('createPlan response: ${e.response?.data}');
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.response?.data?['detail'] ?? e.message ?? 'Erro ao criar plano', e);
    }
  }

  /// Update training plan
  Future<Map<String, dynamic>> updatePlan(String planId, {
    String? name,
    String? goal,
    String? difficulty,
    String? splitType,
    int? durationWeeks,
    int? targetWorkoutMinutes,
    bool? isTemplate,
    bool? isPublic,
    List<Map<String, dynamic>>? workouts,
    // Diet fields
    bool? includeDiet,
    String? dietType,
    int? dailyCalories,
    int? proteinGrams,
    int? carbsGrams,
    int? fatGrams,
    int? mealsPerDay,
    String? dietNotes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (goal != null) data['goal'] = goal;
      if (difficulty != null) data['difficulty'] = difficulty;
      if (splitType != null) data['split_type'] = splitType;
      if (durationWeeks != null) data['duration_weeks'] = durationWeeks;
      if (targetWorkoutMinutes != null) data['target_workout_minutes'] = targetWorkoutMinutes;
      if (isTemplate != null) data['is_template'] = isTemplate;
      if (isPublic != null) data['is_public'] = isPublic;
      if (workouts != null) data['workouts'] = workouts;
      // Diet fields
      if (includeDiet != null) data['include_diet'] = includeDiet;
      if (dietType != null) data['diet_type'] = dietType;
      if (dailyCalories != null) data['daily_calories'] = dailyCalories;
      if (proteinGrams != null) data['protein_grams'] = proteinGrams;
      if (carbsGrams != null) data['carbs_grams'] = carbsGrams;
      if (fatGrams != null) data['fat_grams'] = fatGrams;
      if (mealsPerDay != null) data['meals_per_day'] = mealsPerDay;
      if (dietNotes != null) data['diet_notes'] = dietNotes;

      final response = await _client.put(ApiEndpoints.plan(planId), data: data);
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

  /// Delete training plan
  Future<void> deletePlan(String planId) async {
    try {
      await _client.delete(ApiEndpoints.plan(planId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao excluir plano', e);
    }
  }

  /// Duplicate training plan
  /// If [fromCatalog] is true, tracks the original plan as source_template_id
  Future<Map<String, dynamic>> duplicatePlan(String planId, {
    bool duplicateWorkouts = true,
    String? newName,
    bool fromCatalog = false,
  }) async {
    try {
      final params = <String, dynamic>{
        'duplicate_workouts': duplicateWorkouts,
        'from_catalog': fromCatalog,
      };
      if (newName != null) params['new_name'] = newName;
      final response = await _client.post(
        ApiEndpoints.planDuplicate(planId),
        queryParameters: params,
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao duplicar plano');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao duplicar plano', e);
    }
  }

  /// Add workout to plan
  Future<Map<String, dynamic>> addWorkoutToPlan(
    String planId, {
    String? workoutId,
    String? workoutName,
    required String label,
    int order = 0,
    int? dayOfWeek,
    List<Map<String, dynamic>>? exercises,
  }) async {
    try {
      final data = <String, dynamic>{
        'label': label,
        'order': order,
      };
      if (workoutId != null) data['workout_id'] = workoutId;
      if (workoutName != null) data['workout_name'] = workoutName;
      if (dayOfWeek != null) data['day_of_week'] = dayOfWeek;
      if (exercises != null) data['workout_exercises'] = exercises;

      final response = await _client.post(
        ApiEndpoints.planWorkouts(planId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao adicionar treino ao plano');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao adicionar treino', e);
    }
  }

  /// Remove workout from plan
  Future<void> removeWorkoutFromPlan(String planId, String planWorkoutId) async {
    try {
      await _client.delete(ApiEndpoints.planWorkout(planId, planWorkoutId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao remover treino do plano', e);
    }
  }

  /// Create plan assignment
  Future<Map<String, dynamic>> createPlanAssignment({
    required String planId,
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'plan_id': planId,
        'student_id': studentId,
        'start_date': (startDate ?? DateTime.now()).toIso8601String().split('T')[0],
      };
      if (endDate != null) data['end_date'] = endDate.toIso8601String().split('T')[0];
      if (notes != null) data['notes'] = notes;

      final response = await _client.post(ApiEndpoints.planAssignments, data: data);
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

  /// Get plan assignments for a student or trainer
  Future<List<Map<String, dynamic>>> getPlanAssignments({
    String? studentId,
    bool asTrainer = false,
    bool activeOnly = true,
  }) async {
    try {
      final params = <String, dynamic>{
        'as_trainer': asTrainer,
        'active_only': activeOnly,
      };
      if (studentId != null) params['student_id'] = studentId;

      final response = await _client.get(
        ApiEndpoints.planAssignments,
        queryParameters: params,
      );
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

  /// Update a plan assignment
  Future<Map<String, dynamic>> updatePlanAssignment(
    String assignmentId, {
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (startDate != null) data['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) data['end_date'] = endDate.toIso8601String().split('T')[0];
      if (isActive != null) data['is_active'] = isActive;
      if (notes != null) data['notes'] = notes;

      final response = await _client.put(
        '${ApiEndpoints.planAssignments}/$assignmentId',
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar atribuição');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar atribuição', e);
    }
  }

  /// Delete/cancel a plan assignment (only pending assignments)
  Future<void> deletePlanAssignment(String assignmentId) async {
    try {
      await _client.delete('${ApiEndpoints.planAssignments}/$assignmentId');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao cancelar atribuição', e);
    }
  }

  // ==================== AI Exercise Suggestions ====================

  /// Suggest exercises based on muscle groups, training goal, and workout context
  Future<Map<String, dynamic>> suggestExercises({
    required List<String> muscleGroups,
    String goal = 'hypertrophy',
    String difficulty = 'intermediate',
    int count = 6,
    List<String>? excludeExerciseIds,
    // Workout context parameters
    String? workoutName,
    String? workoutLabel,
    String? planName,
    String? planGoal,
    String? planSplitType,
    List<String>? existingExercises,
    int existingExerciseCount = 0,
    bool allowAdvancedTechniques = true,
    List<String>? allowedTechniques,
  }) async {
    try {
      final data = <String, dynamic>{
        'muscle_groups': muscleGroups,
        'goal': goal,
        'difficulty': difficulty,
        'count': count,
        'allow_advanced_techniques': allowAdvancedTechniques,
      };
      if (excludeExerciseIds != null && excludeExerciseIds.isNotEmpty) {
        data['exclude_exercise_ids'] = excludeExerciseIds;
      }
      if (allowedTechniques != null && allowedTechniques.isNotEmpty) {
        data['allowed_techniques'] = allowedTechniques;
      }

      // Build context if any context parameter is provided
      if (workoutName != null ||
          workoutLabel != null ||
          planName != null ||
          planGoal != null ||
          planSplitType != null ||
          (existingExercises != null && existingExercises.isNotEmpty)) {
        data['context'] = <String, dynamic>{
          if (workoutName != null) 'workout_name': workoutName,
          if (workoutLabel != null) 'workout_label': workoutLabel,
          if (planName != null) 'plan_name': planName,
          if (planGoal != null) 'plan_goal': planGoal,
          if (planSplitType != null) 'plan_split_type': planSplitType,
          if (existingExercises != null && existingExercises.isNotEmpty)
            'existing_exercises': existingExercises,
          'existing_exercise_count': existingExerciseCount,
        };
      }

      // AI suggestion can take longer, use extended timeout
      final response = await _client.post(
        ApiEndpoints.exercisesSuggest,
        data: data,
        options: Options(
          sendTimeout: const Duration(seconds: 90),
          receiveTimeout: const Duration(seconds: 90),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao obter sugestões');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao obter sugestões', e);
    }
  }

  /// Generate training plan with AI based on questionnaire
  Future<Map<String, dynamic>> generatePlanWithAI({
    required String goal,
    required String difficulty,
    required int daysPerWeek,
    required int minutesPerSession,
    required String equipment,
    List<String>? injuries,
    String preferences = 'mixed',
    int durationWeeks = 8,
  }) async {
    try {
      final data = <String, dynamic>{
        'goal': goal,
        'difficulty': difficulty,
        'days_per_week': daysPerWeek,
        'minutes_per_session': minutesPerSession,
        'equipment': equipment,
        'preferences': preferences,
        'duration_weeks': durationWeeks,
      };
      if (injuries != null && injuries.isNotEmpty) {
        data['injuries'] = injuries;
      }

      // AI generation can take longer, use extended timeout
      final response = await _client.post(
        ApiEndpoints.plansGenerateAI,
        data: data,
        options: Options(
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao gerar plano');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao gerar plano', e);
    }
  }

  // ==================== Prescription Notes ====================

  /// Get prescription notes for a specific context
  Future<Map<String, dynamic>> getPrescriptionNotes({
    required String contextType,
    required String contextId,
    String? organizationId,
  }) async {
    try {
      final params = <String, dynamic>{
        'context_type': contextType,
        'context_id': contextId,
      };
      if (organizationId != null) params['organization_id'] = organizationId;

      final response = await _client.get(
        ApiEndpoints.prescriptionNotes,
        queryParameters: params,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return {'notes': [], 'total': 0, 'unread_count': 0};
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar notas', e);
    }
  }

  /// Get a single prescription note by ID
  Future<Map<String, dynamic>> getPrescriptionNote(String noteId) async {
    try {
      final response = await _client.get(ApiEndpoints.prescriptionNote(noteId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Nota não encontrada');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar nota', e);
    }
  }

  /// Create a new prescription note
  Future<Map<String, dynamic>> createPrescriptionNote({
    required String contextType,
    required String contextId,
    required String content,
    bool isPinned = false,
    String? organizationId,
  }) async {
    try {
      final data = <String, dynamic>{
        'context_type': contextType,
        'context_id': contextId,
        'content': content,
        'is_pinned': isPinned,
      };
      if (organizationId != null) data['organization_id'] = organizationId;

      final response = await _client.post(
        ApiEndpoints.prescriptionNotes,
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao criar nota');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao criar nota', e);
    }
  }

  /// Update a prescription note
  Future<Map<String, dynamic>> updatePrescriptionNote(
    String noteId, {
    String? content,
    bool? isPinned,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (content != null) data['content'] = content;
      if (isPinned != null) data['is_pinned'] = isPinned;

      final response = await _client.put(
        ApiEndpoints.prescriptionNote(noteId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar nota');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar nota', e);
    }
  }

  /// Mark a prescription note as read
  Future<Map<String, dynamic>> markPrescriptionNoteAsRead(String noteId) async {
    try {
      final response = await _client.post(
        ApiEndpoints.prescriptionNoteRead(noteId),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao marcar nota como lida');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao marcar nota como lida', e);
    }
  }

  /// Delete a prescription note
  Future<void> deletePrescriptionNote(String noteId) async {
    try {
      await _client.delete(ApiEndpoints.prescriptionNote(noteId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao excluir nota', e);
    }
  }
}
