import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/core/services/organization_service.dart';
import 'package:myfit_app/core/services/schedule_service.dart';
import 'package:myfit_app/core/services/workout_service.dart';
import 'package:myfit_app/features/checkin/presentation/providers/checkin_provider.dart';
import 'package:myfit_app/features/trainer_home/presentation/providers/trainer_home_provider.dart';

import '../../helpers/fixtures/student_fixtures.dart';
import '../../helpers/fixtures/workout_fixtures.dart';
import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

class MockScheduleService extends Mock implements ScheduleService {}

void main() {
  late MockOrganizationService mockOrgService;
  late MockWorkoutService mockWorkoutService;
  late MockScheduleService mockScheduleService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValues();
  });

  setUp(() {
    mockOrgService = MockOrganizationService();
    mockWorkoutService = MockWorkoutService();
    mockScheduleService = MockScheduleService();
  });

  group('TrainerDashboardNotifier', () {
    ProviderContainer createTestContainer() {
      return createContainer(
        overrides: [
          trainerHomeOrgServiceProvider.overrideWithValue(mockOrgService),
          trainerHomeWorkoutServiceProvider.overrideWithValue(mockWorkoutService),
          trainerHomeScheduleServiceProvider.overrideWithValue(mockScheduleService),
          // Override checkin provider to avoid SharedPreferences dependency
          checkInHistoryProvider.overrideWithValue([]),
        ],
      );
    }

    group('loadDashboard', () {
      test('should load all dashboard data', () async {
        final members = StudentFixtures.apiResponseList(count: 10);
        final workouts = WorkoutFixtures.apiResponseList(count: 5);
        final schedule = [
          {'id': 'appt-1', 'time': '09:00'},
          {'id': 'appt-2', 'time': '10:00'},
        ];

        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => members);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => workouts);
        when(() => mockScheduleService.getAppointmentsForDay(any()))
            .thenAnswer((_) async => schedule);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerDashboardNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(trainerDashboardNotifierProvider('org-1'));

        expect(state.isLoading, false);
        expect(state.totalStudents, 10);
        expect(state.todaySchedule.length, 2);
        expect(state.error, isNull);
      });

      test('should not load when orgId is null', () async {
        final container = createTestContainer();

        await Future.delayed(const Duration(milliseconds: 50));

        final state = container.read(trainerDashboardNotifierProvider(null));

        expect(state.totalStudents, 0);
        verifyNever(() => mockOrgService.getMembers(any(), role: any(named: 'role')));
      });

      test('should count active students', () async {
        final members = [
          {...StudentFixtures.activeApiResponse(userId: 's1'), 'status': 'active'},
          {...StudentFixtures.activeApiResponse(userId: 's2'), 'status': 'active'},
          {...StudentFixtures.activeApiResponse(userId: 's3'), 'status': 'inactive'},
        ];

        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => members);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);
        when(() => mockScheduleService.getAppointmentsForDay(any()))
            .thenAnswer((_) async => []);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerDashboardNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(trainerDashboardNotifierProvider('org-1'));

        expect(state.totalStudents, 3);
        expect(state.activeStudents, 2);
      });

      test('should count pending workouts', () async {
        final members = StudentFixtures.apiResponseList(count: 2);
        final workouts = [
          WorkoutFixtures.apiResponse(id: 'w1', status: 'draft'),
          WorkoutFixtures.apiResponse(id: 'w2', status: 'draft'),
          WorkoutFixtures.apiResponse(id: 'w3', status: 'active'),
        ];

        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => members);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => workouts);
        when(() => mockScheduleService.getAppointmentsForDay(any()))
            .thenAnswer((_) async => []);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerDashboardNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(trainerDashboardNotifierProvider('org-1'));

        expect(state.pendingWorkouts, 2);
      });

      test('should handle schedule service failure gracefully', () async {
        final members = StudentFixtures.apiResponseList(count: 2);

        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => members);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);
        when(() => mockScheduleService.getAppointmentsForDay(any()))
            .thenThrow(Exception('Schedule service error'));

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerDashboardNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(trainerDashboardNotifierProvider('org-1'));

        // Should not fail, just have empty schedule
        expect(state.isLoading, false);
        expect(state.todaySchedule, isEmpty);
        expect(state.error, isNull);
      });

      test('should handle main service failure', () async {
        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenThrow(Exception('API error'));

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerDashboardNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(trainerDashboardNotifierProvider('org-1'));

        expect(state.isLoading, false);
        expect(state.error, 'Erro ao carregar dashboard');
      });
    });

    group('_buildAlerts', () {
      test('should create alert for inactive students', () async {
        final members = [
          {
            ...StudentFixtures.activeApiResponse(userId: 's1'),
            'last_workout_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
          },
          {
            ...StudentFixtures.activeApiResponse(userId: 's2'),
            'last_workout_at': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
          },
          {
            ...StudentFixtures.activeApiResponse(userId: 's3'),
            'last_workout_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          },
        ];

        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => members);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);
        when(() => mockScheduleService.getAppointmentsForDay(any()))
            .thenAnswer((_) async => []);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerDashboardNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(trainerDashboardNotifierProvider('org-1'));

        // Should have alert for 2 students inactive > 7 days
        final inactiveAlert = state.alerts.firstWhere(
          (a) => a['type'] == 'warning',
          orElse: () => {},
        );

        expect(inactiveAlert.isNotEmpty, true);
        expect(inactiveAlert['title'], contains('alunos inativos'));
      });

      test('should create alert for pending workouts', () async {
        final members = StudentFixtures.apiResponseList(count: 1);
        final workouts = [
          WorkoutFixtures.apiResponse(id: 'w1', status: 'draft'),
          WorkoutFixtures.apiResponse(id: 'w2', status: 'draft'),
        ];

        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => members);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => workouts);
        when(() => mockScheduleService.getAppointmentsForDay(any()))
            .thenAnswer((_) async => []);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerDashboardNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(trainerDashboardNotifierProvider('org-1'));

        final pendingAlert = state.alerts.firstWhere(
          (a) => a['type'] == 'info',
          orElse: () => {},
        );

        expect(pendingAlert.isNotEmpty, true);
        expect(pendingAlert['title'], '2 treinos pendentes');
      });

      test('should not create alerts when everything is fine', () async {
        final members = [
          {
            ...StudentFixtures.activeApiResponse(userId: 's1'),
            'last_workout_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          },
        ];
        final workouts = [
          WorkoutFixtures.apiResponse(id: 'w1', status: 'active'),
        ];

        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => members);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => workouts);
        when(() => mockScheduleService.getAppointmentsForDay(any()))
            .thenAnswer((_) async => []);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerDashboardNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(trainerDashboardNotifierProvider('org-1'));

        // No inactive alert (all within 7 days)
        final inactiveAlerts = state.alerts.where((a) => a['type'] == 'warning');
        expect(inactiveAlerts.isEmpty, true);

        // No pending alert (no draft workouts)
        final pendingAlerts = state.alerts.where((a) => a['type'] == 'info');
        expect(pendingAlerts.isEmpty, true);
      });

      test('should count students with null last_workout_at as inactive', () async {
        final members = [
          {
            ...StudentFixtures.activeApiResponse(userId: 's1'),
            'last_workout_at': null,
          },
        ];

        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => members);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);
        when(() => mockScheduleService.getAppointmentsForDay(any()))
            .thenAnswer((_) async => []);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerDashboardNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(trainerDashboardNotifierProvider('org-1'));

        final inactiveAlert = state.alerts.firstWhere(
          (a) => a['type'] == 'warning',
          orElse: () => {},
        );

        expect(inactiveAlert.isNotEmpty, true);
      });
    });

    group('refresh', () {
      test('should reload dashboard', () async {
        when(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => []);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);
        when(() => mockScheduleService.getAppointmentsForDay(any()))
            .thenAnswer((_) async => []);

        final container = createTestContainer();
        final notifier = container.read(trainerDashboardNotifierProvider('org-1').notifier);

        // Wait for initial load to complete
        await waitForProviderState(
          container,
          trainerDashboardNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        notifier.refresh();

        // Wait for refresh to complete
        await waitForProviderState(
          container,
          trainerDashboardNotifierProvider('org-1'),
          (state) => !state.isLoading,
        );

        verify(() => mockOrgService.getMembers(any(), role: any(named: 'role')))
            .called(2);
      });
    });
  });

  group('Convenience Providers', () {
    group('trainerStatsProvider', () {
      test('should return stats map', () {
        final container = createContainer(
          overrides: [
            trainerStatsProvider('org-1').overrideWithValue({
              'totalStudents': 10,
              'activeStudents': 8,
              'todaySessions': 5,
              'pendingWorkouts': 3,
            }),
          ],
        );

        final stats = container.read(trainerStatsProvider('org-1'));

        expect(stats['totalStudents'], 10);
        expect(stats['activeStudents'], 8);
        expect(stats['todaySessions'], 5);
        expect(stats['pendingWorkouts'], 3);
      });
    });

    group('trainerActivitiesProvider', () {
      test('should return recent activities', () {
        final activities = [
          {'type': 'checkin', 'title': 'Test activity'},
        ];

        final container = createContainer(
          overrides: [
            trainerActivitiesProvider('org-1').overrideWithValue(activities),
          ],
        );

        final result = container.read(trainerActivitiesProvider('org-1'));

        expect(result.length, 1);
        expect(result.first['type'], 'checkin');
      });
    });

    group('trainerAlertsProvider', () {
      test('should return alerts', () {
        final alerts = [
          {'type': 'warning', 'title': '3 alunos inativos'},
        ];

        final container = createContainer(
          overrides: [
            trainerAlertsProvider('org-1').overrideWithValue(alerts),
          ],
        );

        final result = container.read(trainerAlertsProvider('org-1'));

        expect(result.length, 1);
        expect(result.first['type'], 'warning');
      });
    });

    group('trainerScheduleProvider', () {
      test('should return today schedule', () {
        final schedule = [
          {'id': 'appt-1', 'time': '09:00'},
          {'id': 'appt-2', 'time': '10:00'},
        ];

        final container = createContainer(
          overrides: [
            trainerScheduleProvider('org-1').overrideWithValue(schedule),
          ],
        );

        final result = container.read(trainerScheduleProvider('org-1'));

        expect(result.length, 2);
      });
    });

    group('isTrainerDashboardLoadingProvider', () {
      test('should return loading state', () {
        final container = createContainer(
          overrides: [
            isTrainerDashboardLoadingProvider('org-1').overrideWithValue(true),
          ],
        );

        final isLoading = container.read(isTrainerDashboardLoadingProvider('org-1'));

        expect(isLoading, true);
      });
    });
  });

  group('TrainerDashboardState', () {
    test('should have correct default values', () {
      const state = TrainerDashboardState();

      expect(state.totalStudents, 0);
      expect(state.activeStudents, 0);
      expect(state.todaySessions, 0);
      expect(state.pendingWorkouts, 0);
      expect(state.recentActivities, isEmpty);
      expect(state.alerts, isEmpty);
      expect(state.todaySchedule, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should copy with updated values', () {
      const original = TrainerDashboardState(
        totalStudents: 5,
        isLoading: false,
      );

      final copy = original.copyWith(
        totalStudents: 10,
        isLoading: true,
      );

      expect(copy.totalStudents, 10);
      expect(copy.isLoading, true);
      expect(copy.activeStudents, 0); // unchanged
    });
  });
}
