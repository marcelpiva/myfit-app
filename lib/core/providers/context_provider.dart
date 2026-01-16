import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/entities.dart';
import '../services/membership_service.dart';

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

/// Provider for the currently active context
final activeContextProvider =
    StateProvider<ActiveContext?>((ref) => null);

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
