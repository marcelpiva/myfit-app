import 'package:dio/dio.dart';

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

  // ==================== Workout Programs ====================

  /// Get list of workout programs
  Future<List<Map<String, dynamic>>> getPrograms({
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

      final response = await _client.get(ApiEndpoints.programs, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar programas', e);
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

      final response = await _client.get(ApiEndpoints.programsCatalog, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar catálogo', e);
    }
  }

  /// Get program by ID
  Future<Map<String, dynamic>> getProgram(String programId) async {
    try {
      final response = await _client.get(ApiEndpoints.program(programId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Programa não encontrado');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar programa', e);
    }
  }

  /// Create workout program
  Future<String> createProgram({
    required String name,
    required String goal,
    required String difficulty,
    required String splitType,
    int? durationWeeks,
    bool isTemplate = false,
    List<Map<String, dynamic>>? workouts,
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
      if (workouts != null) data['workouts'] = workouts;

      final response = await _client.post(ApiEndpoints.programs, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return (response.data as Map<String, dynamic>)['id'] as String;
      }
      throw const ServerException('Erro ao criar programa');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao criar programa', e);
    }
  }

  /// Update workout program
  Future<Map<String, dynamic>> updateProgram(String programId, {
    String? name,
    String? goal,
    String? difficulty,
    String? splitType,
    int? durationWeeks,
    bool? isTemplate,
    bool? isPublic,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (goal != null) data['goal'] = goal;
      if (difficulty != null) data['difficulty'] = difficulty;
      if (splitType != null) data['split_type'] = splitType;
      if (durationWeeks != null) data['duration_weeks'] = durationWeeks;
      if (isTemplate != null) data['is_template'] = isTemplate;
      if (isPublic != null) data['is_public'] = isPublic;

      final response = await _client.put(ApiEndpoints.program(programId), data: data);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar programa');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar programa', e);
    }
  }

  /// Delete workout program
  Future<void> deleteProgram(String programId) async {
    try {
      await _client.delete(ApiEndpoints.program(programId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao excluir programa', e);
    }
  }

  /// Duplicate workout program
  Future<Map<String, dynamic>> duplicateProgram(String programId, {
    bool duplicateWorkouts = true,
  }) async {
    try {
      final params = <String, dynamic>{
        'duplicate_workouts': duplicateWorkouts,
      };
      final response = await _client.post(
        ApiEndpoints.programDuplicate(programId),
        queryParameters: params,
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao duplicar programa');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao duplicar programa', e);
    }
  }

  /// Add workout to program
  Future<Map<String, dynamic>> addWorkoutToProgram(
    String programId, {
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
        ApiEndpoints.programWorkouts(programId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao adicionar treino ao programa');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao adicionar treino', e);
    }
  }

  /// Remove workout from program
  Future<void> removeWorkoutFromProgram(String programId, String programWorkoutId) async {
    try {
      await _client.delete(ApiEndpoints.programWorkout(programId, programWorkoutId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao remover treino do programa', e);
    }
  }

  /// Create program assignment
  Future<Map<String, dynamic>> createProgramAssignment({
    required String programId,
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'program_id': programId,
        'student_id': studentId,
        'start_date': (startDate ?? DateTime.now()).toIso8601String().split('T')[0],
      };
      if (endDate != null) data['end_date'] = endDate.toIso8601String().split('T')[0];
      if (notes != null) data['notes'] = notes;

      final response = await _client.post(ApiEndpoints.programAssignments, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atribuir programa');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atribuir programa', e);
    }
  }

  // ==================== AI Exercise Suggestions ====================

  /// Suggest exercises based on muscle groups and training goal
  Future<Map<String, dynamic>> suggestExercises({
    required List<String> muscleGroups,
    String goal = 'hypertrophy',
    String difficulty = 'intermediate',
    int count = 6,
    List<String>? excludeExerciseIds,
  }) async {
    try {
      final data = <String, dynamic>{
        'muscle_groups': muscleGroups,
        'goal': goal,
        'difficulty': difficulty,
        'count': count,
      };
      if (excludeExerciseIds != null && excludeExerciseIds.isNotEmpty) {
        data['exclude_exercise_ids'] = excludeExerciseIds;
      }

      final response = await _client.post(ApiEndpoints.exercisesSuggest, data: data);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao obter sugestoes');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao obter sugestoes', e);
    }
  }

  /// Generate workout program with AI based on questionnaire
  Future<Map<String, dynamic>> generateProgramWithAI({
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

      final response = await _client.post(ApiEndpoints.programsGenerateAI, data: data);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao gerar programa');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao gerar programa', e);
    }
  }
}
