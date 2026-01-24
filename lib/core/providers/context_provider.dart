import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/entities.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/interceptors/organization_interceptor.dart';
import '../services/membership_service.dart';
import '../../features/trainer_workout/presentation/providers/trainer_students_provider.dart';

/// Provider for MembershipService
final membershipServiceProvider = Provider<MembershipService>((ref) {
  return MembershipService();
});

/// Provider for all user memberships (async from API)
final membershipsProvider = FutureProvider<List<OrganizationMembership>>((ref) async {
  final service = ref.read(membershipServiceProvider);
  return service.getMemberships();
});

/// Provider for grouped memberships by role type
final groupedMembershipsProvider =
    Provider<Map<String, List<OrganizationMembership>>>((ref) {
  final membershipsAsync = ref.watch(membershipsProvider);

  return membershipsAsync.when(
    data: (memberships) {
      final studentMemberships =
          memberships.where((m) => m.role == UserRole.student).toList();
      final trainerMemberships =
          memberships.where((m) => m.role == UserRole.trainer || m.role == UserRole.coach).toList();
      final nutritionistMemberships =
          memberships.where((m) => m.role == UserRole.nutritionist).toList();
      final gymMemberships =
          memberships.where((m) => m.role.isGymRole).toList();

      return {
        'student': studentMemberships,
        'trainer': trainerMemberships,
        'nutritionist': nutritionistMemberships,
        'gym': gymMemberships,
      };
    },
    loading: () => {
      'student': <OrganizationMembership>[],
      'trainer': <OrganizationMembership>[],
      'nutritionist': <OrganizationMembership>[],
      'gym': <OrganizationMembership>[],
    },
    error: (_, __) => {
      'student': <OrganizationMembership>[],
      'trainer': <OrganizationMembership>[],
      'nutritionist': <OrganizationMembership>[],
      'gym': <OrganizationMembership>[],
    },
  );
});

/// Notifier for the currently active context
/// Also updates the organization interceptor when context changes
class ActiveContextNotifier extends StateNotifier<ActiveContext?> {
  ActiveContextNotifier() : super(null) {
    // Initialize the organization ID getter
    OrganizationInterceptor.setOrganizationIdGetter(_getOrganizationId);
  }

  String? _getOrganizationId() {
    return state?.organization.id;
  }

  void setContext(ActiveContext? context) {
    state = context;
  }

  void clearContext() {
    state = null;
  }
}

/// Provider for the currently active context
final activeContextProvider =
    StateNotifierProvider<ActiveContextNotifier, ActiveContext?>((ref) {
  return ActiveContextNotifier();
});

/// Provider to check if user has any trainer/professional roles
final hasTrainerRoleProvider = Provider<bool>((ref) {
  final membershipsAsync = ref.watch(membershipsProvider);
  return membershipsAsync.when(
    data: (memberships) => memberships.any((m) => m.role.canManageStudents),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider to check if user has any student roles
final hasStudentRoleProvider = Provider<bool>((ref) {
  final membershipsAsync = ref.watch(membershipsProvider);
  return membershipsAsync.when(
    data: (memberships) => memberships.any((m) => m.role == UserRole.student),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for pending invites for the current user
final pendingInvitesForUserProvider = FutureProvider<List<PendingInvite>>((ref) async {
  try {
    debugPrint('[PENDING_INVITES] Fetching pending invites...');
    final response = await ApiClient.instance.get(ApiEndpoints.userPendingInvites);
    debugPrint('[PENDING_INVITES] Response: ${response.statusCode}');
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as List;
      debugPrint('[PENDING_INVITES] Found ${data.length} invites');
      return data.map((e) => PendingInvite.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  } catch (e) {
    debugPrint('[PENDING_INVITES] Error: $e');
    return [];
  }
});
