import 'package:dio/dio.dart';

import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Organization service for gym/organization management
class OrganizationService {
  final ApiClient _client;

  OrganizationService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // ==================== Organizations ====================

  /// Get list of organizations
  Future<List<Map<String, dynamic>>> getOrganizations({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.organizations,
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
          : UnknownApiException(e.message ?? 'Erro ao carregar organizações', e);
    }
  }

  /// Get organization by ID
  Future<Map<String, dynamic>> getOrganization(String orgId) async {
    try {
      final response = await _client.get(ApiEndpoints.organization(orgId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Organização não encontrada');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar organização', e);
    }
  }

  /// Create organization
  Future<Map<String, dynamic>> createOrganization({
    required String name,
    String? description,
    String? type,
    String? address,
    String? phone,
    String? email,
    String? logoUrl,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
      };
      if (description != null) data['description'] = description;
      if (type != null) data['type'] = type;
      if (address != null) data['address'] = address;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (logoUrl != null) data['logo_url'] = logoUrl;

      final response = await _client.post(ApiEndpoints.organizations, data: data);
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao criar organização');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao criar organização', e);
    }
  }

  /// Update organization
  Future<Map<String, dynamic>> updateOrganization(String orgId, {
    String? name,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? logoUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (address != null) data['address'] = address;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (logoUrl != null) data['logo_url'] = logoUrl;

      final response = await _client.put(ApiEndpoints.organization(orgId), data: data);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar organização');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar organização', e);
    }
  }

  /// Delete organization
  Future<void> deleteOrganization(String orgId) async {
    try {
      await _client.delete(ApiEndpoints.organization(orgId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao excluir organização', e);
    }
  }

  // ==================== Members ====================

  /// Get organization members
  Future<List<Map<String, dynamic>>> getMembers(
    String orgId, {
    String? role,
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (role != null) params['role'] = role;
      if (status != null) params['status'] = status;

      final response = await _client.get(
        ApiEndpoints.organizationMembers(orgId),
        queryParameters: params,
      );
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar membros', e);
    }
  }

  /// Get member details
  Future<Map<String, dynamic>> getMember(String orgId, String userId) async {
    try {
      final response = await _client.get(ApiEndpoints.organizationMember(orgId, userId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Membro não encontrado');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar membro', e);
    }
  }

  /// Update member role/status
  Future<Map<String, dynamic>> updateMember(
    String orgId,
    String userId, {
    String? role,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (role != null) data['role'] = role;
      if (status != null) data['status'] = status;

      final response = await _client.put(
        ApiEndpoints.organizationMember(orgId, userId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar membro');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar membro', e);
    }
  }

  /// Remove member from organization
  Future<void> removeMember(String orgId, String userId) async {
    try {
      await _client.delete(ApiEndpoints.organizationMember(orgId, userId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao remover membro', e);
    }
  }

  // ==================== Invites ====================

  /// Get pending invites
  Future<List<Map<String, dynamic>>> getInvites(String orgId) async {
    try {
      final response = await _client.get(ApiEndpoints.organizationInvites(orgId));
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar convites', e);
    }
  }

  /// Send invite
  Future<Map<String, dynamic>> sendInvite(
    String orgId, {
    required String email,
    required String role,
  }) async {
    try {
      final data = <String, dynamic>{
        'email': email,
        'role': role,
      };

      final response = await _client.post(
        ApiEndpoints.organizationInvite(orgId),
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao enviar convite');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao enviar convite', e);
    }
  }

  /// Accept invite
  Future<Map<String, dynamic>> acceptInvite(String inviteToken) async {
    try {
      final response = await _client.post(
        ApiEndpoints.acceptInvite,
        data: {'token': inviteToken},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao aceitar convite');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Convite inválido ou expirado', e);
    }
  }

  /// Cancel a pending invite
  Future<void> cancelInvite(String orgId, String inviteId) async {
    try {
      await _client.delete(ApiEndpoints.cancelInvite(orgId, inviteId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao cancelar convite', e);
    }
  }

  /// Resend invite (regenerates token and extends expiration)
  Future<Map<String, dynamic>> resendInvite(String orgId, String inviteId) async {
    try {
      final response = await _client.post(
        ApiEndpoints.resendInvite(orgId, inviteId),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao reenviar convite');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao reenviar convite', e);
    }
  }

  /// Generate invite link from token
  String generateInviteLink(String token) {
    return 'myfit://invite/$token';
  }

  /// Get invite preview (public, no auth required)
  /// Returns organization name, inviter name, role, and email
  Future<Map<String, dynamic>> getInvitePreview(String token) async {
    try {
      final response = await _client.get(ApiEndpoints.invitePreview(token));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Convite não encontrado');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Convite inválido ou expirado', e);
    }
  }

  // ==================== Stats ====================

  /// Get organization statistics
  Future<Map<String, dynamic>> getOrganizationStats(String orgId, {int days = 30}) async {
    try {
      final response = await _client.get(
        '${ApiEndpoints.organization(orgId)}/stats',
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

  // ==================== Reports ====================

  /// Get organization reports
  Future<Map<String, dynamic>> getOrganizationReport(
    String orgId, {
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, dynamic>{
        'report_type': reportType,
      };
      if (startDate != null) params['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) params['end_date'] = endDate.toIso8601String().split('T')[0];

      final response = await _client.get(
        '${ApiEndpoints.organization(orgId)}/reports',
        queryParameters: params,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao gerar relatório');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao gerar relatório', e);
    }
  }
}
