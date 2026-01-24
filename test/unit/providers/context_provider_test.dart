import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/core/domain/entities/entities.dart';
import 'package:myfit_app/core/providers/context_provider.dart';
import 'package:myfit_app/core/services/membership_service.dart';

import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

class MockMembershipService extends Mock implements MembershipService {}

void main() {
  late MockMembershipService mockMembershipService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValues();
  });

  setUp(() {
    mockMembershipService = MockMembershipService();
  });

  // Test data
  Organization createOrganization({
    String id = 'org-1',
    String name = 'Test Gym',
    OrganizationType type = OrganizationType.gym,
  }) {
    return Organization(
      id: id,
      name: name,
      type: type,
      createdAt: DateTime.now(),
    );
  }

  OrganizationMembership createMembership({
    String id = 'membership-1',
    Organization? organization,
    UserRole role = UserRole.student,
  }) {
    return OrganizationMembership(
      id: id,
      organization: organization ?? createOrganization(),
      role: role,
      joinedAt: DateTime.now(),
    );
  }

  ActiveContext createActiveContext({
    OrganizationMembership? membership,
    UserRole role = UserRole.student,
  }) {
    return ActiveContext(
      membership: membership ??
          createMembership(
            role: role,
            organization: createOrganization(),
          ),
    );
  }

  group('ActiveContext', () {
    test('should return correct organization and role', () {
      final org = createOrganization(id: 'org-123', name: 'My Gym');
      final membership = createMembership(
        organization: org,
        role: UserRole.trainer,
      );
      final context = ActiveContext(membership: membership);

      expect(context.organization.id, 'org-123');
      expect(context.organization.name, 'My Gym');
      expect(context.role, UserRole.trainer);
    });

    group('isStudent', () {
      test('should return true for student role', () {
        final context = createActiveContext(role: UserRole.student);
        expect(context.isStudent, true);
        expect(context.isTrainer, false);
      });

      test('should return false for non-student role', () {
        final context = createActiveContext(role: UserRole.trainer);
        expect(context.isStudent, false);
      });
    });

    group('isTrainer', () {
      test('should return true for trainer role', () {
        final context = createActiveContext(role: UserRole.trainer);
        expect(context.isTrainer, true);
        expect(context.isStudent, false);
      });

      test('should return true for coach role', () {
        final context = createActiveContext(role: UserRole.coach);
        expect(context.isTrainer, true);
      });

      test('should return false for student role', () {
        final context = createActiveContext(role: UserRole.student);
        expect(context.isTrainer, false);
      });
    });

    group('isNutritionist', () {
      test('should return true for nutritionist role', () {
        final context = createActiveContext(role: UserRole.nutritionist);
        expect(context.isNutritionist, true);
      });

      test('should return false for non-nutritionist role', () {
        final context = createActiveContext(role: UserRole.trainer);
        expect(context.isNutritionist, false);
      });
    });

    group('homeRoute', () {
      test('should return /home for student', () {
        final context = createActiveContext(role: UserRole.student);
        expect(context.homeRoute, '/home');
      });

      test('should return /trainer-home for trainer', () {
        final context = createActiveContext(role: UserRole.trainer);
        expect(context.homeRoute, '/trainer-home');
      });

      test('should return /nutritionist-home for nutritionist', () {
        final context = createActiveContext(role: UserRole.nutritionist);
        expect(context.homeRoute, '/nutritionist-home');
      });

      test('should return /gym-home for gym owner', () {
        final context = createActiveContext(role: UserRole.gymOwner);
        expect(context.homeRoute, '/gym-home');
      });
    });
  });

  group('ActiveContextNotifier', () {
    ProviderContainer createTestContainer() {
      return createContainer();
    }

    test('should have null initial state', () {
      final container = createTestContainer();

      final context = container.read(activeContextProvider);

      expect(context, isNull);
    });

    test('should set context', () {
      final container = createTestContainer();
      final notifier = container.read(activeContextProvider.notifier);
      final testContext = createActiveContext(role: UserRole.student);

      notifier.setContext(testContext);

      expect(container.read(activeContextProvider), testContext);
    });

    test('should clear context', () {
      final container = createTestContainer();
      final notifier = container.read(activeContextProvider.notifier);
      final testContext = createActiveContext(role: UserRole.student);

      notifier.setContext(testContext);
      expect(container.read(activeContextProvider), isNotNull);

      notifier.clearContext();

      expect(container.read(activeContextProvider), isNull);
    });

    test('should replace context when setting new one', () {
      final container = createTestContainer();
      final notifier = container.read(activeContextProvider.notifier);

      final context1 = createActiveContext(
        membership: createMembership(
          id: 'm1',
          organization: createOrganization(id: 'org-1'),
          role: UserRole.student,
        ),
      );
      final context2 = createActiveContext(
        membership: createMembership(
          id: 'm2',
          organization: createOrganization(id: 'org-2'),
          role: UserRole.trainer,
        ),
      );

      notifier.setContext(context1);
      expect(container.read(activeContextProvider)?.organization.id, 'org-1');
      expect(container.read(activeContextProvider)?.role, UserRole.student);

      notifier.setContext(context2);
      expect(container.read(activeContextProvider)?.organization.id, 'org-2');
      expect(container.read(activeContextProvider)?.role, UserRole.trainer);
    });

    test('should allow setting null context', () {
      final container = createTestContainer();
      final notifier = container.read(activeContextProvider.notifier);
      final testContext = createActiveContext(role: UserRole.student);

      notifier.setContext(testContext);
      expect(container.read(activeContextProvider), isNotNull);

      notifier.setContext(null);

      expect(container.read(activeContextProvider), isNull);
    });
  });

  group('groupedMembershipsProvider', () {
    ProviderContainer createTestContainer({
      List<OrganizationMembership>? memberships,
      AsyncValue<List<OrganizationMembership>>? membershipsAsyncValue,
    }) {
      return createContainer(
        overrides: [
          if (membershipsAsyncValue != null)
            membershipsProvider.overrideWith((ref) async {
              if (membershipsAsyncValue is AsyncData<List<OrganizationMembership>>) {
                return membershipsAsyncValue.value;
              }
              if (membershipsAsyncValue is AsyncError) {
                throw Exception('Test error');
              }
              return <OrganizationMembership>[];
            })
          else if (memberships != null)
            membershipsProvider.overrideWith((ref) async => memberships),
        ],
      );
    }

    test('should group memberships by role type', () async {
      final memberships = [
        createMembership(
          id: 'm1',
          organization: createOrganization(id: 'org-1', name: 'Student Org'),
          role: UserRole.student,
        ),
        createMembership(
          id: 'm2',
          organization: createOrganization(id: 'org-2', name: 'Trainer Org'),
          role: UserRole.trainer,
        ),
        createMembership(
          id: 'm3',
          organization: createOrganization(id: 'org-3', name: 'Gym'),
          role: UserRole.gymOwner,
        ),
      ];

      final container = createTestContainer(memberships: memberships);

      // Wait for memberships to load
      await container.read(membershipsProvider.future);

      final grouped = container.read(groupedMembershipsProvider);

      expect(grouped['student']?.length, 1);
      expect(grouped['trainer']?.length, 1);
      expect(grouped['gym']?.length, 1);
      expect(grouped['nutritionist']?.length, 0);
    });

    test('should return empty groups when loading', () {
      final container = createContainer(
        overrides: [
          // Override to be in loading state without triggering actual service
          membershipsProvider.overrideWith((ref) async {
            await Future.delayed(const Duration(hours: 1)); // Never completes
            return <OrganizationMembership>[];
          }),
        ],
      );

      // Don't wait for loading, read immediately
      final grouped = container.read(groupedMembershipsProvider);

      expect(grouped['student'], isEmpty);
      expect(grouped['trainer'], isEmpty);
      expect(grouped['nutritionist'], isEmpty);
      expect(grouped['gym'], isEmpty);
    });
  });

  group('hasTrainerRoleProvider', () {
    test('should return true when user has trainer membership', () async {
      final container = createContainer(
        overrides: [
          membershipsProvider.overrideWith((ref) async => [
                createMembership(role: UserRole.trainer),
              ]),
        ],
      );

      // Wait for memberships to load
      await container.read(membershipsProvider.future);

      expect(container.read(hasTrainerRoleProvider), true);
    });

    test('should return true when user has coach membership', () async {
      final container = createContainer(
        overrides: [
          membershipsProvider.overrideWith((ref) async => [
                createMembership(role: UserRole.coach),
              ]),
        ],
      );

      // Wait for memberships to load
      await container.read(membershipsProvider.future);

      expect(container.read(hasTrainerRoleProvider), true);
    });

    test('should return false when user has only student memberships', () async {
      final container = createContainer(
        overrides: [
          membershipsProvider.overrideWith((ref) async => [
                createMembership(role: UserRole.student),
              ]),
        ],
      );

      // Wait for memberships to load
      await container.read(membershipsProvider.future);

      expect(container.read(hasTrainerRoleProvider), false);
    });

    test('should return false when loading', () {
      final container = createContainer(
        overrides: [
          // Override to be in loading state without triggering actual service
          membershipsProvider.overrideWith((ref) async {
            await Future.delayed(const Duration(hours: 1)); // Never completes
            return <OrganizationMembership>[];
          }),
        ],
      );

      expect(container.read(hasTrainerRoleProvider), false);
    });
  });

  group('hasStudentRoleProvider', () {
    test('should return true when user has student membership', () async {
      final container = createContainer(
        overrides: [
          membershipsProvider.overrideWith((ref) async => [
                createMembership(role: UserRole.student),
              ]),
        ],
      );

      // Wait for memberships to load
      await container.read(membershipsProvider.future);

      expect(container.read(hasStudentRoleProvider), true);
    });

    test('should return false when user has only trainer memberships', () async {
      final container = createContainer(
        overrides: [
          membershipsProvider.overrideWith((ref) async => [
                createMembership(role: UserRole.trainer),
              ]),
        ],
      );

      // Wait for memberships to load
      await container.read(membershipsProvider.future);

      expect(container.read(hasStudentRoleProvider), false);
    });

    test('should return true when user has both student and trainer', () async {
      final container = createContainer(
        overrides: [
          membershipsProvider.overrideWith((ref) async => [
                createMembership(id: 'm1', role: UserRole.student),
                createMembership(id: 'm2', role: UserRole.trainer),
              ]),
        ],
      );

      // Wait for memberships to load
      await container.read(membershipsProvider.future);

      expect(container.read(hasStudentRoleProvider), true);
      expect(container.read(hasTrainerRoleProvider), true);
    });

    test('should return false when loading', () {
      final container = createContainer(
        overrides: [
          // Override to be in loading state without triggering actual service
          membershipsProvider.overrideWith((ref) async {
            await Future.delayed(const Duration(hours: 1)); // Never completes
            return <OrganizationMembership>[];
          }),
        ],
      );

      expect(container.read(hasStudentRoleProvider), false);
    });
  });

  group('Organization', () {
    test('should create from JSON', () {
      final json = {
        'id': 'org-1',
        'name': 'Test Gym',
        'type': 'gym',
        'logo_url': 'https://example.com/logo.png',
        'description': 'A test gym',
        'member_count': 50,
        'trainer_count': 5,
        'created_at': '2024-01-01T00:00:00Z',
      };

      final org = Organization.fromJson(json);

      expect(org.id, 'org-1');
      expect(org.name, 'Test Gym');
      expect(org.type, OrganizationType.gym);
      expect(org.logoUrl, 'https://example.com/logo.png');
      expect(org.memberCount, 50);
      expect(org.trainerCount, 5);
    });

    test('should return correct initials', () {
      final org1 = createOrganization(name: 'Test Gym');
      expect(org1.initials, 'TG');

      final org2 = createOrganization(name: 'Academy');
      expect(org2.initials, 'AC');
    });
  });

  group('OrganizationMembership', () {
    test('should create from JSON', () {
      final json = {
        'id': 'membership-1',
        'organization': {
          'id': 'org-1',
          'name': 'Test Gym',
          'type': 'personal',
          'created_at': '2024-01-01T00:00:00Z',
        },
        'role': 'trainer',
        'joined_at': '2024-01-15T00:00:00Z',
        'is_active': true,
      };

      final membership = OrganizationMembership.fromJson(json);

      expect(membership.id, 'membership-1');
      expect(membership.organization.id, 'org-1');
      expect(membership.role, UserRole.trainer);
      expect(membership.isActive, true);
    });
  });
}
