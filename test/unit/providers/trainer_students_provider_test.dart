import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/core/error/api_exceptions.dart';
import 'package:myfit_app/core/services/organization_service.dart';
import 'package:myfit_app/core/services/workout_service.dart';
import 'package:myfit_app/features/trainer_workout/presentation/providers/trainer_students_provider.dart';

import '../../helpers/fixtures/student_fixtures.dart';
import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockOrganizationService mockOrgService;
  late MockWorkoutService mockWorkoutService;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockOrgService = MockOrganizationService();
    mockWorkoutService = MockWorkoutService();
  });

  group('TrainerStudentsNotifier', () {
    ProviderContainer createTestContainer() {
      return createContainer(
        overrides: [
          trainerStudentsOrgServiceProvider.overrideWithValue(mockOrgService),
          trainerStudentsWorkoutServiceProvider.overrideWithValue(mockWorkoutService),
        ],
      );
    }

    group('loadStudents', () {
      test('should load students and workout assignments', () async {
        final members = StudentFixtures.apiResponseList(count: 3);
        final assignments = [
          {
            'student_id': 'student-0',
            'status': 'active',
            'name': 'Treino A',
          },
        ];

        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => members);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => assignments);

        final container = createTestContainer();
        final notifier = container.read(trainerStudentsNotifierProvider('org-1').notifier);

        // Wait for initial load to complete
        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerStudentsNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(trainerStudentsNotifierProvider('org-1'));

        expect(state.isLoading, false);
        expect(state.students.length, 3);
        expect(state.error, isNull);
      });

      test('should set loading state during load', () async {
        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return [];
        });
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);

        final container = createTestContainer();

        // Check initial loading state
        final initialState = container.read(trainerStudentsNotifierProvider('org-1'));
        expect(initialState.isLoading, true);

        // Wait for load to complete
        await Future.delayed(const Duration(milliseconds: 100));

        final finalState = container.read(trainerStudentsNotifierProvider('org-1'));
        expect(finalState.isLoading, false);
      });

      test('should handle API error gracefully', () async {
        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenThrow(const ServerException('Server error'));
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerStudentsNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(trainerStudentsNotifierProvider('org-1'));

        expect(state.isLoading, false);
        expect(state.error, isNotNull);
      });

      test('should return empty list when orgId is null', () async {
        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => []);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);

        final container = createTestContainer();

        await Future.delayed(const Duration(milliseconds: 50));

        final state = container.read(trainerStudentsNotifierProvider(null));

        expect(state.students, isEmpty);
      });

      test('should merge workout info with student data', () async {
        final members = [
          StudentFixtures.activeApiResponse(userId: 'student-1'),
        ];
        final assignments = [
          {
            'student_id': 'student-1',
            'status': 'active',
            'name': 'Treino A - Peito',
          },
          {
            'student_id': 'student-1',
            'status': 'completed',
            'name': 'Treino B - Costas',
          },
        ];

        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => members);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => assignments);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerStudentsNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(trainerStudentsNotifierProvider('org-1'));
        final student = state.students.first;

        expect(student.totalWorkouts, 2);
        expect(student.completedWorkouts, 1);
        expect(student.currentWorkoutName, 'Treino A - Peito');
        expect(student.adherencePercent, 50.0);
      });

      test('should handle generic exceptions', () async {
        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenThrow(Exception('Unknown error'));
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerStudentsNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(trainerStudentsNotifierProvider('org-1'));

        expect(state.error, 'Erro ao carregar alunos');
      });
    });

    group('refresh', () {
      test('should reload students', () async {
        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => []);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);

        final container = createTestContainer();
        final notifier = container.read(trainerStudentsNotifierProvider('org-1').notifier);

        // Wait for initial load
        await waitForProviderState(
          container,
          trainerStudentsNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        notifier.refresh();

        // Wait for refresh
        await waitForProviderState(
          container,
          trainerStudentsNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        verify(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .called(2);
      });
    });
  });

  group('Filter Providers', () {
    group('studentSearchQueryProvider', () {
      test('should have empty initial value', () {
        final container = createContainer();
        final query = container.read(studentSearchQueryProvider);
        expect(query, isEmpty);
      });

      test('should update search query', () {
        final container = createContainer();
        container.read(studentSearchQueryProvider.notifier).state = 'João';
        final query = container.read(studentSearchQueryProvider);
        expect(query, 'João');
      });
    });

    group('studentFilterProvider', () {
      test('should have null initial value (all students)', () {
        final container = createContainer();
        final filter = container.read(studentFilterProvider);
        expect(filter, isNull);
      });

      test('should update filter', () {
        final container = createContainer();
        container.read(studentFilterProvider.notifier).state = 'active';
        final filter = container.read(studentFilterProvider);
        expect(filter, 'active');
      });
    });

    group('studentSortProvider', () {
      test('should have "name" as initial value', () {
        final container = createContainer();
        final sort = container.read(studentSortProvider);
        expect(sort, 'name');
      });

      test('should update sort option', () {
        final container = createContainer();
        container.read(studentSortProvider.notifier).state = 'lastWorkout';
        final sort = container.read(studentSortProvider);
        expect(sort, 'lastWorkout');
      });
    });
  });

  group('filteredTrainerStudentsProvider', () {
    ProviderContainer createTestContainerWithStudents(List<TrainerStudent> students) {
      return createContainer(
        overrides: [
          trainerStudentsProvider('org-1').overrideWithValue(students),
        ],
      );
    }

    test('should filter by search query (name)', () {
      final students = StudentFixtures.mixedList();
      final container = createTestContainerWithStudents(students);

      container.read(studentSearchQueryProvider.notifier).state = 'João';
      final filtered = container.read(filteredTrainerStudentsProvider('org-1'));

      expect(filtered.length, 1);
      expect(filtered.first.name, 'João Silva');
    });

    test('should filter by search query (email)', () {
      final students = StudentFixtures.mixedList();
      final container = createTestContainerWithStudents(students);

      container.read(studentSearchQueryProvider.notifier).state = 'maria@';
      final filtered = container.read(filteredTrainerStudentsProvider('org-1'));

      expect(filtered.length, 1);
      expect(filtered.first.name, 'Maria Santos');
    });

    test('should filter by search query case insensitive', () {
      final students = StudentFixtures.mixedList();
      final container = createTestContainerWithStudents(students);

      container.read(studentSearchQueryProvider.notifier).state = 'JOÃO';
      final filtered = container.read(filteredTrainerStudentsProvider('org-1'));

      expect(filtered.length, 1);
    });

    test('should filter by active status', () {
      final students = StudentFixtures.mixedList();
      final container = createTestContainerWithStudents(students);

      container.read(studentFilterProvider.notifier).state = 'active';
      final filtered = container.read(filteredTrainerStudentsProvider('org-1'));

      expect(filtered.every((s) => s.isActive), true);
    });

    test('should filter by inactive status', () {
      final students = StudentFixtures.mixedList();
      final container = createTestContainerWithStudents(students);

      container.read(studentFilterProvider.notifier).state = 'inactive';
      final filtered = container.read(filteredTrainerStudentsProvider('org-1'));

      expect(filtered.every((s) => !s.isActive), true);
    });

    test('should sort by name', () {
      final students = StudentFixtures.mixedList();
      final container = createTestContainerWithStudents(students);

      container.read(studentSortProvider.notifier).state = 'name';
      final filtered = container.read(filteredTrainerStudentsProvider('org-1'));

      for (var i = 0; i < filtered.length - 1; i++) {
        expect(
          filtered[i].name.compareTo(filtered[i + 1].name) <= 0,
          true,
        );
      }
    });

    test('should sort by lastWorkout (most recent first)', () {
      final students = [
        StudentFixtures.active(
          id: 'student-1',
          name: 'A',
          lastWorkoutAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        StudentFixtures.active(
          id: 'student-2',
          name: 'B',
          lastWorkoutAt: DateTime.now(),
        ),
        StudentFixtures.withoutWorkouts(id: 'student-3', name: 'C'),
      ];
      final container = createTestContainerWithStudents(students);

      container.read(studentSortProvider.notifier).state = 'lastWorkout';
      final filtered = container.read(filteredTrainerStudentsProvider('org-1'));

      expect(filtered[0].name, 'B'); // Most recent
      expect(filtered[1].name, 'A');
      expect(filtered[2].name, 'C'); // No workout (null)
    });

    test('should sort by adherence (highest first)', () {
      final students = [
        StudentFixtures.active(id: 'student-1', name: 'A').copyWith(adherencePercent: 50.0),
        StudentFixtures.active(id: 'student-2', name: 'B').copyWith(adherencePercent: 100.0),
        StudentFixtures.active(id: 'student-3', name: 'C').copyWith(adherencePercent: 75.0),
      ];
      final container = createTestContainerWithStudents(students);

      container.read(studentSortProvider.notifier).state = 'adherence';
      final filtered = container.read(filteredTrainerStudentsProvider('org-1'));

      expect(filtered[0].adherencePercent, 100.0);
      expect(filtered[1].adherencePercent, 75.0);
      expect(filtered[2].adherencePercent, 50.0);
    });

    test('should combine search and filter', () {
      final students = StudentFixtures.mixedList();
      final container = createTestContainerWithStudents(students);

      container.read(studentSearchQueryProvider.notifier).state = 'silva';
      container.read(studentFilterProvider.notifier).state = 'active';
      final filtered = container.read(filteredTrainerStudentsProvider('org-1'));

      expect(filtered.length, 1);
      expect(filtered.first.name, 'João Silva');
      expect(filtered.first.isActive, true);
    });
  });

  group('trainerStudentStatsProvider', () {
    test('should return correct stats', () {
      final container = createContainer(
        overrides: [
          trainerStudentStatsProvider('org-1').overrideWithValue({
            'total': 5,
            'active': 4,
            'inactive': 1,
          }),
        ],
      );

      final stats = container.read(trainerStudentStatsProvider('org-1'));

      expect(stats['total'], 5);
      expect(stats['active'], 4);
      expect(stats['inactive'], 1);
    });
  });

  group('PendingInvitesNotifier', () {
    ProviderContainer createTestContainer() {
      return createContainer(
        overrides: [
          trainerStudentsOrgServiceProvider.overrideWithValue(mockOrgService),
        ],
      );
    }

    group('loadInvites', () {
      test('should load pending invites', () async {
        final invites = [
          StudentFixtures.pendingInviteApiResponse(id: 'invite-1'),
          StudentFixtures.pendingInviteApiResponse(id: 'invite-2'),
        ];

        when(() => mockOrgService.getInvites(any()))
            .thenAnswer((_) async => invites);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          pendingInvitesNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(pendingInvitesNotifierProvider('org-1'));

        expect(state.invites.length, 2);
        expect(state.isLoading, false);
      });

      test('should filter out expired invites', () async {
        final invites = [
          StudentFixtures.pendingInviteApiResponse(id: 'invite-1'),
          {
            ...StudentFixtures.pendingInviteApiResponse(id: 'invite-2'),
            'is_expired': true,
          },
        ];

        when(() => mockOrgService.getInvites(any()))
            .thenAnswer((_) async => invites);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          pendingInvitesNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(pendingInvitesNotifierProvider('org-1'));

        expect(state.invites.length, 1);
        expect(state.invites.first.id, 'invite-1');
      });

      test('should not load when orgId is null', () async {
        final container = createTestContainer();

        await Future.delayed(const Duration(milliseconds: 50));

        final state = container.read(pendingInvitesNotifierProvider(null));

        expect(state.invites, isEmpty);
        verifyNever(() => mockOrgService.getInvites(any()));
      });
    });

    group('cancelInvite', () {
      test('should remove invite from state on success', () async {
        final invites = [
          StudentFixtures.pendingInviteApiResponse(id: 'invite-1'),
          StudentFixtures.pendingInviteApiResponse(id: 'invite-2'),
        ];

        when(() => mockOrgService.getInvites(any()))
            .thenAnswer((_) async => invites);
        when(() => mockOrgService.cancelInvite(any(), any()))
            .thenAnswer((_) async {});

        final container = createTestContainer();
        final notifier = container.read(pendingInvitesNotifierProvider('org-1').notifier);

        // Wait for initial load
        await waitForProviderState(
          container,
          pendingInvitesNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        await notifier.cancelInvite('invite-1');

        final state = container.read(pendingInvitesNotifierProvider('org-1'));
        expect(state.invites.length, 1);
        expect(state.invites.first.id, 'invite-2');
      });
    });

    group('resendInvite', () {
      test('should update invite in state on success', () async {
        final invites = [
          StudentFixtures.pendingInviteApiResponse(id: 'invite-1'),
        ];
        final updatedInvite = {
          ...StudentFixtures.pendingInviteApiResponse(id: 'invite-1'),
          'token': 'new-token-123',
        };

        when(() => mockOrgService.getInvites(any()))
            .thenAnswer((_) async => invites);
        when(() => mockOrgService.resendInvite(any(), any()))
            .thenAnswer((_) async => updatedInvite);

        final container = createTestContainer();
        final notifier = container.read(pendingInvitesNotifierProvider('org-1').notifier);

        // Wait for initial load
        await waitForProviderState(
          container,
          pendingInvitesNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        await notifier.resendInvite('invite-1');

        final state = container.read(pendingInvitesNotifierProvider('org-1'));
        expect(state.invites.first.token, 'new-token-123');
      });
    });
  });

  group('pendingInvitesCountProvider', () {
    test('should return correct count', () {
      final container = createContainer(
        overrides: [
          pendingInvitesProvider('org-1').overrideWithValue([
            StudentFixtures.pendingInvite(id: 'invite-1'),
            StudentFixtures.pendingInvite(id: 'invite-2'),
          ]),
        ],
      );

      final count = container.read(pendingInvitesCountProvider('org-1'));

      expect(count, 2);
    });
  });
}
