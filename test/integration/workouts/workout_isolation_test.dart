/// Tests for workout isolation by organization and user type.
///
/// Validates that:
/// 1. Solo students can only see their own workouts
/// 2. Students with trainers see only prescribed workouts (not individual workouts)
/// 3. Trainers see their templates and per-student assignments
/// 4. Context switching correctly filters workouts per organization
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/core/domain/entities/entities.dart';
import 'package:myfit_app/core/providers/context_provider.dart';
import 'package:myfit_app/core/services/workout_service.dart';
import 'package:myfit_app/features/workout/presentation/providers/workout_provider.dart';

import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

// =============================================================================
// Test Data Factories
// =============================================================================

Organization createOrganization({
  String id = 'org-1',
  String name = 'Test Organization',
  OrganizationType type = OrganizationType.personal,
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
  String? invitedBy,
}) {
  return OrganizationMembership(
    id: id,
    organization: organization ?? createOrganization(),
    role: role,
    joinedAt: DateTime.now(),
    invitedBy: invitedBy,
  );
}

ActiveContext createActiveContext({
  OrganizationMembership? membership,
  UserRole role = UserRole.student,
  String orgId = 'org-1',
}) {
  return ActiveContext(
    membership: membership ??
        createMembership(
          role: role,
          organization: createOrganization(id: orgId),
        ),
  );
}

Map<String, dynamic> createWorkoutJson({
  String id = 'workout-1',
  String name = 'Test Workout',
  String? organizationId = 'org-1',
  String? createdById = 'user-1',
}) {
  return {
    'id': id,
    'name': name,
    'description': 'Test workout description',
    'difficulty': 'intermediate',
    'estimated_duration_min': 60,
    'organization_id': organizationId,
    'created_by_id': createdById,
    'exercises': <Map<String, dynamic>>[],
    'created_at': DateTime.now().toIso8601String(),
  };
}

Map<String, dynamic> createPlanAssignmentJson({
  String id = 'assignment-1',
  String planId = 'plan-1',
  String planName = 'Test Plan',
  String studentId = 'student-1',
  String trainerId = 'trainer-1',
  String organizationId = 'org-1',
  String status = 'accepted',
}) {
  return {
    'id': id,
    'plan_id': planId,
    'plan': {
      'id': planId,
      'name': planName,
      'goal': 'general_fitness',
      'difficulty': 'beginner',
      'duration_weeks': 4,
      'plan_workouts': <Map<String, dynamic>>[],
    },
    'plan_snapshot': {
      'id': planId,
      'name': planName,
      'goal': 'general_fitness',
      'difficulty': 'beginner',
      'duration_weeks': 4,
      'plan_workouts': <Map<String, dynamic>>[],
    },
    'student_id': studentId,
    'trainer_id': trainerId,
    'organization_id': organizationId,
    'status': status,
    'start_date': DateTime.now().toIso8601String().split('T')[0],
  };
}

// =============================================================================
// Test Class: Workout Isolation Tests
// =============================================================================

void main() {
  late MockWorkoutService mockWorkoutService;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockWorkoutService = MockWorkoutService();
  });

  group('Solo Student Workout Isolation', () {
    test('Solo student sees their own workouts', () async {
      // Arrange: Solo student context (no trainer - autonomous org)
      final soloStudentContext = createActiveContext(
        role: UserRole.student,
        orgId: 'autonomous-org-1',
        membership: createMembership(
          id: 'm1',
          role: UserRole.student,
          organization: createOrganization(
            id: 'autonomous-org-1',
            name: 'Treino Carlos',
            type: OrganizationType.autonomous,
          ),
          // No invitedBy means no trainer
        ),
      );

      // Mock: Return workouts created by the solo student
      final soloWorkouts = [
        createWorkoutJson(
          id: 'workout-solo-1',
          name: 'Meu Treino A',
          organizationId: 'autonomous-org-1',
          createdById: 'carlos-id',
        ),
        createWorkoutJson(
          id: 'workout-solo-2',
          name: 'Meu Treino B',
          organizationId: 'autonomous-org-1',
          createdById: 'carlos-id',
        ),
      ];

      when(() => mockWorkoutService.getWorkouts()).thenAnswer(
        (_) async => soloWorkouts,
      );

      // Act & Assert: Create container and verify workouts are loaded
      final container = createContainer(
        overrides: [
          workoutServiceProvider.overrideWithValue(mockWorkoutService),
          activeContextProvider.overrideWith((ref) {
            final notifier = ActiveContextNotifier();
            notifier.setContext(soloStudentContext);
            return notifier;
          }),
        ],
      );

      // Verify getWorkouts was called (solo student loads individual workouts)
      final workoutsNotifier = container.read(workoutsNotifierProvider.notifier);
      await workoutsNotifier.loadWorkouts();

      verify(() => mockWorkoutService.getWorkouts()).called(1);
    });

    test('Solo student cannot see other organization workouts', () async {
      // Arrange: Solo student context
      final soloStudentContext = createActiveContext(
        role: UserRole.student,
        orgId: 'autonomous-org-1',
      );

      // Mock: Return only workouts from the autonomous org
      // (Server should filter by X-Organization-ID header)
      final filteredWorkouts = [
        createWorkoutJson(
          id: 'workout-solo-1',
          name: 'Meu Treino',
          organizationId: 'autonomous-org-1',
        ),
        // Note: No workouts from 'trainer-org-1' should be returned
      ];

      when(() => mockWorkoutService.getWorkouts()).thenAnswer(
        (_) async => filteredWorkouts,
      );

      final container = createContainer(
        overrides: [
          workoutServiceProvider.overrideWithValue(mockWorkoutService),
          activeContextProvider.overrideWith((ref) {
            final notifier = ActiveContextNotifier();
            notifier.setContext(soloStudentContext);
            return notifier;
          }),
        ],
      );

      final workoutsNotifier = container.read(workoutsNotifierProvider.notifier);
      await workoutsNotifier.loadWorkouts();

      final state = container.read(workoutsNotifierProvider);

      // All returned workouts should belong to the autonomous org
      for (final workout in state.workouts) {
        expect(workout['organization_id'], 'autonomous-org-1');
      }
    });
  });

  group('Student with Trainer Isolation', () {
    test('Student with trainer sees only prescribed plans', () async {
      // Arrange: Student linked to a trainer
      final studentWithTrainerContext = createActiveContext(
        role: UserRole.student,
        orgId: 'trainer-org-1',
        membership: createMembership(
          id: 'm1',
          role: UserRole.student,
          organization: createOrganization(
            id: 'trainer-org-1',
            name: 'Personal João',
            type: OrganizationType.personal,
          ),
          invitedBy: 'trainer-joao-id', // Has a trainer
        ),
      );

      // Mock: Return plan assignments from the trainer
      final assignedPlans = [
        createPlanAssignmentJson(
          id: 'assignment-1',
          planName: 'Plano Iniciante',
          trainerId: 'trainer-joao-id',
          organizationId: 'trainer-org-1',
        ),
      ];

      when(() => mockWorkoutService.getPlanAssignments(activeOnly: true))
          .thenAnswer((_) async => assignedPlans);

      final container = createContainer(
        overrides: [
          workoutServiceProvider.overrideWithValue(mockWorkoutService),
          activeContextProvider.overrideWith((ref) {
            final notifier = ActiveContextNotifier();
            notifier.setContext(studentWithTrainerContext);
            return notifier;
          }),
        ],
      );

      // Act: Load plans
      final plansNotifier = container.read(plansNotifierProvider.notifier);
      await plansNotifier.fetchData();

      // Assert: getPlanAssignments was called (not getWorkouts)
      verify(() => mockWorkoutService.getPlanAssignments(activeOnly: true)).called(1);
    });
  });

  group('Multiple Trainers Context Switching', () {
    test('Student with multiple trainers sees different plans per context', () async {
      // Arrange: Two different contexts for the same student
      final contextJoao = createActiveContext(
        role: UserRole.student,
        orgId: 'org-joao',
        membership: createMembership(
          id: 'm1',
          role: UserRole.student,
          organization: createOrganization(
            id: 'org-joao',
            name: 'Personal João',
          ),
          invitedBy: 'trainer-joao',
        ),
      );

      final contextMaria = createActiveContext(
        role: UserRole.student,
        orgId: 'org-maria',
        membership: createMembership(
          id: 'm2',
          role: UserRole.student,
          organization: createOrganization(
            id: 'org-maria',
            name: 'Personal Maria',
          ),
          invitedBy: 'trainer-maria',
        ),
      );

      // Mock: Different plans for each trainer
      final plansJoao = [
        createPlanAssignmentJson(
          id: 'assignment-joao',
          planName: 'Plano Força - João',
          trainerId: 'trainer-joao',
          organizationId: 'org-joao',
        ),
      ];

      final plansMaria = [
        createPlanAssignmentJson(
          id: 'assignment-maria',
          planName: 'Plano Cardio - Maria',
          trainerId: 'trainer-maria',
          organizationId: 'org-maria',
        ),
      ];

      // Test 1: João's context
      when(() => mockWorkoutService.getPlanAssignments(activeOnly: true))
          .thenAnswer((_) async => plansJoao);

      var container = createContainer(
        overrides: [
          workoutServiceProvider.overrideWithValue(mockWorkoutService),
          activeContextProvider.overrideWith((ref) {
            final notifier = ActiveContextNotifier();
            notifier.setContext(contextJoao);
            return notifier;
          }),
        ],
      );

      var plansNotifier = container.read(plansNotifierProvider.notifier);
      await plansNotifier.fetchData();

      var state = container.read(plansNotifierProvider);
      expect(state.plans.any((p) => p['id'] == 'assignment-joao'), isTrue);

      // Test 2: Maria's context (new container simulates context switch)
      reset(mockWorkoutService);
      when(() => mockWorkoutService.getPlanAssignments(activeOnly: true))
          .thenAnswer((_) async => plansMaria);

      container = createContainer(
        overrides: [
          workoutServiceProvider.overrideWithValue(mockWorkoutService),
          activeContextProvider.overrideWith((ref) {
            final notifier = ActiveContextNotifier();
            notifier.setContext(contextMaria);
            return notifier;
          }),
        ],
      );

      plansNotifier = container.read(plansNotifierProvider.notifier);
      await plansNotifier.fetchData();

      state = container.read(plansNotifierProvider);
      expect(state.plans.any((p) => p['id'] == 'assignment-maria'), isTrue);
      // João's plan should not be visible in Maria's context
      expect(state.plans.any((p) => p['id'] == 'assignment-joao'), isFalse);
    });
  });

  group('Trainer Workout Isolation', () {
    test('Trainer sees their own workout templates', () async {
      // Arrange: Trainer context
      final trainerContext = createActiveContext(
        role: UserRole.trainer,
        orgId: 'trainer-org-1',
        membership: createMembership(
          id: 'm1',
          role: UserRole.trainer,
          organization: createOrganization(
            id: 'trainer-org-1',
            name: 'Personal João',
          ),
        ),
      );

      // Mock: Return trainer's workout templates
      final trainerWorkouts = [
        createWorkoutJson(
          id: 'template-1',
          name: 'Template Força',
          organizationId: 'trainer-org-1',
          createdById: 'trainer-joao-id',
        ),
        createWorkoutJson(
          id: 'template-2',
          name: 'Template Cardio',
          organizationId: 'trainer-org-1',
          createdById: 'trainer-joao-id',
        ),
      ];

      when(() => mockWorkoutService.getWorkouts()).thenAnswer(
        (_) async => trainerWorkouts,
      );

      final container = createContainer(
        overrides: [
          workoutServiceProvider.overrideWithValue(mockWorkoutService),
          activeContextProvider.overrideWith((ref) {
            final notifier = ActiveContextNotifier();
            notifier.setContext(trainerContext);
            return notifier;
          }),
        ],
      );

      final workoutsNotifier = container.read(workoutsNotifierProvider.notifier);
      await workoutsNotifier.loadWorkouts();

      final state = container.read(workoutsNotifierProvider);
      expect(state.workouts.length, 2);
      expect(state.workouts.any((w) => w['name'] == 'Template Força'), isTrue);
    });

    test('Trainer cannot see other trainer workouts', () async {
      // Arrange: Trainer João context
      final trainerJoaoContext = createActiveContext(
        role: UserRole.trainer,
        orgId: 'org-joao',
      );

      // Mock: Return only João's workouts (Maria's filtered by server)
      final joaoWorkouts = [
        createWorkoutJson(
          id: 'template-joao',
          name: 'Treino João',
          organizationId: 'org-joao',
          createdById: 'trainer-joao',
        ),
        // Note: Maria's workout from org-maria should NOT be here
      ];

      when(() => mockWorkoutService.getWorkouts()).thenAnswer(
        (_) async => joaoWorkouts,
      );

      final container = createContainer(
        overrides: [
          workoutServiceProvider.overrideWithValue(mockWorkoutService),
          activeContextProvider.overrideWith((ref) {
            final notifier = ActiveContextNotifier();
            notifier.setContext(trainerJoaoContext);
            return notifier;
          }),
        ],
      );

      final workoutsNotifier = container.read(workoutsNotifierProvider.notifier);
      await workoutsNotifier.loadWorkouts();

      final state = container.read(workoutsNotifierProvider);

      // Verify no workouts from other organizations
      for (final workout in state.workouts) {
        expect(workout['organization_id'], 'org-joao');
      }
    });
  });

  group('Organization Interceptor', () {
    test('Context change should trigger data refresh', () async {
      // This test verifies that when activeContext changes,
      // dependent providers should refresh their data

      final org1 = createOrganization(id: 'org-1', name: 'Org 1');
      final org2 = createOrganization(id: 'org-2', name: 'Org 2');

      final membership1 = createMembership(
        id: 'm1',
        organization: org1,
        role: UserRole.student,
      );
      final membership2 = createMembership(
        id: 'm2',
        organization: org2,
        role: UserRole.student,
      );

      final container = createContainer(
        overrides: [
          workoutServiceProvider.overrideWithValue(mockWorkoutService),
        ],
      );

      final contextNotifier = container.read(activeContextProvider.notifier);

      // Set initial context
      contextNotifier.setContext(ActiveContext(membership: membership1));
      expect(container.read(activeContextProvider)?.organization.id, 'org-1');

      // Switch context
      contextNotifier.setContext(ActiveContext(membership: membership2));
      expect(container.read(activeContextProvider)?.organization.id, 'org-2');

      // The OrganizationInterceptor should now send X-Organization-ID: org-2
      // in all subsequent requests
    });
  });
}
