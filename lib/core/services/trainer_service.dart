import 'package:dio/dio.dart';

import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Trainer service for personal trainers managing students/clients
class TrainerService {
  final ApiClient _client;

  TrainerService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // ==================== Students ====================

  /// Get list of trainer's students
  Future<List<Map<String, dynamic>>> getStudents({
    String? status,
    String? query,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (status != null) params['status'] = status;
      if (query != null && query.isNotEmpty) params['q'] = query;

      final response = await _client.get(
        ApiEndpoints.trainerStudents,
        queryParameters: params,
      );
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar alunos', e);
    }
  }

  /// Get student details
  Future<Map<String, dynamic>> getStudent(String studentId) async {
    try {
      final response = await _client.get(ApiEndpoints.trainerStudent(studentId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Aluno não encontrado');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar aluno', e);
    }
  }

  /// Get student statistics
  Future<Map<String, dynamic>> getStudentStats(String studentId, {int days = 30}) async {
    try {
      final response = await _client.get(
        ApiEndpoints.trainerStudentStats(studentId),
        queryParameters: {'days': days},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar estatísticas', e);
    }
  }

  /// Get student's workouts
  Future<List<Map<String, dynamic>>> getStudentWorkouts(String studentId) async {
    try {
      final response = await _client.get(ApiEndpoints.trainerStudentWorkouts(studentId));
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

  /// Get student's progress
  Future<Map<String, dynamic>> getStudentProgress(String studentId) async {
    try {
      final response = await _client.get(ApiEndpoints.trainerStudentProgress(studentId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar progresso', e);
    }
  }

  /// Add note to student progress
  Future<Map<String, dynamic>> addStudentNote(
    String studentId,
    String content,
  ) async {
    try {
      final response = await _client.post(
        '${ApiEndpoints.trainerStudentProgress(studentId)}/notes',
        data: {'content': content},
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao adicionar nota');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao adicionar nota', e);
    }
  }

  /// Add student (link existing user)
  Future<Map<String, dynamic>> addStudent(String userId) async {
    try {
      final response = await _client.post(
        ApiEndpoints.trainerStudents,
        data: {'user_id': userId},
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao adicionar aluno');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao adicionar aluno', e);
    }
  }

  /// Update student status
  Future<Map<String, dynamic>> updateStudent(
    String studentId, {
    String? status,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (status != null) data['status'] = status;
      if (notes != null) data['notes'] = notes;

      final response = await _client.put(
        ApiEndpoints.trainerStudent(studentId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar aluno');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar aluno', e);
    }
  }

  /// Update student status (activate/deactivate)
  Future<Map<String, dynamic>> updateStudentStatus(String studentUserId, bool isActive) async {
    try {
      final response = await _client.patch(
        '${ApiEndpoints.trainerStudents}/$studentUserId/status',
        queryParameters: {'is_active': isActive},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar status do aluno');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar status do aluno', e);
    }
  }

  /// Remove student
  Future<void> removeStudent(String studentId) async {
    try {
      await _client.delete(ApiEndpoints.trainerStudent(studentId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao remover aluno', e);
    }
  }

  /// Get invite code for new students
  Future<Map<String, dynamic>> getInviteCode() async {
    try {
      final response = await _client.get(ApiEndpoints.trainerInviteCode);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao obter código de convite');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao obter código de convite', e);
    }
  }

  /// Regenerate invite code
  Future<Map<String, dynamic>> regenerateInviteCode() async {
    try {
      final response = await _client.post(ApiEndpoints.trainerInviteCode);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao gerar novo código');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao gerar novo código', e);
    }
  }

  /// Register a new student directly (creates user account and links to trainer)
  Future<Map<String, dynamic>> registerStudent({
    required String name,
    required String email,
    String? phone,
    String? goal,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'email': email,
      };
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      if (goal != null && goal.isNotEmpty) data['goal'] = goal;
      if (notes != null && notes.isNotEmpty) data['notes'] = notes;

      final response = await _client.post(
        '${ApiEndpoints.trainerStudents}/register',
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao cadastrar aluno');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao cadastrar aluno', e);
    }
  }

  /// Send invite to email
  Future<void> sendInviteEmail(String email) async {
    try {
      final response = await _client.post(
        '${ApiEndpoints.trainerInviteCode}/send',
        data: {'email': email},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw const ServerException('Erro ao enviar convite');
      }
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao enviar convite', e);
    }
  }
}
