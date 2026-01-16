import 'package:dio/dio.dart';

import '../domain/entities/organization.dart';
import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Service for managing user memberships across organizations
class MembershipService {
  final ApiClient _client;

  MembershipService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// Get all memberships for the current user
  Future<List<OrganizationMembership>> getMemberships() async {
    try {
      final response = await _client.get(ApiEndpoints.userMemberships);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as List;
        return data
            .map((e) => OrganizationMembership.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar memberships', e);
    }
  }
}
