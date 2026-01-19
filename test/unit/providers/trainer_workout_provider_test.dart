import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/core/error/api_exceptions.dart';
import 'package:myfit_app/core/services/workout_service.dart';
import 'package:myfit_app/features/trainer_workout/domain/models/trainer_workout.dart';
import 'package:myfit_app/features/trainer_workout/presentation/providers/trainer_workout_provider.dart';

import '../../helpers/fixtures/workout_fixtures.dart';
import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockWorkoutService mockWorkoutService;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockWorkoutService = MockWorkoutService();
  });

  group('TrainerWorkoutsNotifier', () {
    ProviderContainer createTestContainer() {
      return createContainer(
        overrides: [
          workoutServiceProvider.overrideWithValue(mockWorkoutService),
        ],
      );
    }

    group('loadWorkouts', () {
      test('should load workouts from assignments', () async {
        final assignments = WorkoutFixtures.apiResponseList(count: 3);

        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => assignments);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerWorkoutsNotifierProvider,
          (state) => !state.isLoading,
        );

        final state = container.read(trainerWorkoutsNotifierProvider);

        expect(state.isLoading, false);
        expect(state.workouts.length, 3);
        expect(state.error, isNull);
      });

      test('should set loading state during load', () async {
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return [];
        });

        final container = createTestContainer();

        final initialState = container.read(trainerWorkoutsNotifierProvider);
        expect(initialState.isLoading, true);

        await Future.delayed(const Duration(milliseconds: 100));

        final finalState = container.read(trainerWorkoutsNotifierProvider);
        expect(finalState.isLoading, false);
      });

      test('should handle API exception', () async {
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenThrow(const ServerException('Server error'));

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerWorkoutsNotifierProvider,
          (state) => !state.isLoading,
        );

        final state = container.read(trainerWorkoutsNotifierProvider);

        expect(state.isLoading, false);
        expect(state.error, 'Server error');
      });

      test('should handle generic exception', () async {
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenThrow(Exception('Unknown error'));

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerWorkoutsNotifierProvider,
          (state) => !state.isLoading,
        );

        final state = container.read(trainerWorkoutsNotifierProvider);

        expect(state.error, 'Erro ao carregar treinos');
      });

      test('should map API response to TrainerWorkout models', () async {
        final assignments = [
          WorkoutFixtures.apiResponse(
            id: 'workout-1',
            name: 'Treino A',
            status: 'active',
          ),
        ];

        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => assignments);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerWorkoutsNotifierProvider,
          (state) => !state.isLoading,
        );

        final state = container.read(trainerWorkoutsNotifierProvider);
        final workout = state.workouts.first;

        expect(workout.id, 'workout-1');
        expect(workout.name, 'Treino A');
        expect(workout.status, WorkoutAssignmentStatus.active);
        expect(workout.exercises.isNotEmpty, true);
      });
    });

    group('addWorkout', () {
      test('should add workout to state on success', () async {
        final newWorkoutResponse = WorkoutFixtures.apiResponse(id: 'new-workout');

        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);
        when(() => mockWorkoutService.createWorkout(
              name: any(named: 'name'),
              description: any(named: 'description'),
              difficulty: any(named: 'difficulty'),
              estimatedDuration: any(named: 'estimatedDuration'),
              exercises: any(named: 'exercises'),
            )).thenAnswer((_) async => newWorkoutResponse);

        final container = createTestContainer();
        final notifier = container.read(trainerWorkoutsNotifierProvider.notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerWorkoutsNotifierProvider,
          (state) => !state.isLoading,
        );

        final newWorkout = WorkoutFixtures.withExercises(id: 'new-workout');
        await notifier.addWorkout(newWorkout);

        final state = container.read(trainerWorkoutsNotifierProvider);

        expect(state.workouts.length, 1);
        expect(state.workouts.first.id, 'new-workout');
      });

      test('should rethrow API exception', () async {
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);
        when(() => mockWorkoutService.createWorkout(
              name: any(named: 'name'),
              description: any(named: 'description'),
              difficulty: any(named: 'difficulty'),
              estimatedDuration: any(named: 'estimatedDuration'),
              exercises: any(named: 'exercises'),
            )).thenThrow(const ValidationException('Nome inválido'));

        final container = createTestContainer();
        final notifier = container.read(trainerWorkoutsNotifierProvider.notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerWorkoutsNotifierProvider,
          (state) => !state.isLoading,
        );

        final newWorkout = WorkoutFixtures.withExercises();

        expect(
          () => notifier.addWorkout(newWorkout),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('updateWorkout', () {
      test('should update workout in state on success', () async {
        final initialAssignments = [
          WorkoutFixtures.apiResponse(id: 'workout-1', name: 'Original'),
        ];
        final updatedResponse = WorkoutFixtures.apiResponse(
          id: 'workout-1',
          name: 'Updated',
        );

        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => initialAssignments);
        when(() => mockWorkoutService.updateWorkout(
              any(),
              name: any(named: 'name'),
              description: any(named: 'description'),
              difficulty: any(named: 'difficulty'),
              estimatedDuration: any(named: 'estimatedDuration'),
            )).thenAnswer((_) async => updatedResponse);

        final container = createTestContainer();
        final notifier = container.read(trainerWorkoutsNotifierProvider.notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerWorkoutsNotifierProvider,
          (state) => !state.isLoading,
        );

        final updatedWorkout = WorkoutFixtures.withExercises(
          id: 'workout-1',
          name: 'Updated',
        );
        await notifier.updateWorkout(updatedWorkout);

        final state = container.read(trainerWorkoutsNotifierProvider);

        expect(state.workouts.first.name, 'Updated');
      });
    });

    group('deleteWorkout', () {
      test('should remove workout from state on success', () async {
        final initialAssignments = [
          WorkoutFixtures.apiResponse(id: 'workout-1'),
          WorkoutFixtures.apiResponse(id: 'workout-2'),
        ];

        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => initialAssignments);
        when(() => mockWorkoutService.deleteWorkout(any()))
            .thenAnswer((_) async {});

        final container = createTestContainer();
        final notifier = container.read(trainerWorkoutsNotifierProvider.notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerWorkoutsNotifierProvider,
          (state) => !state.isLoading,
        );

        await notifier.deleteWorkout('workout-1');

        final state = container.read(trainerWorkoutsNotifierProvider);

        expect(state.workouts.length, 1);
        expect(state.workouts.first.id, 'workout-2');
      });
    });

    group('duplicateWorkout', () {
      test('should add duplicate to state on success', () async {
        final initialAssignments = [
          WorkoutFixtures.apiResponse(id: 'workout-1'),
        ];
        final duplicateResponse = WorkoutFixtures.apiResponse(id: 'workout-copy');

        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => initialAssignments);
        when(() => mockWorkoutService.duplicateWorkout(any()))
            .thenAnswer((_) async => duplicateResponse);

        final container = createTestContainer();
        final notifier = container.read(trainerWorkoutsNotifierProvider.notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerWorkoutsNotifierProvider,
          (state) => !state.isLoading,
        );

        final result = await notifier.duplicateWorkout('workout-1');

        expect(result?.id, 'workout-copy');

        final state = container.read(trainerWorkoutsNotifierProvider);
        expect(state.workouts.length, 2);
      });
    });

    group('pauseWorkout', () {
      test('should update workout status to paused', () async {
        final initialAssignments = [
          WorkoutFixtures.apiResponse(id: 'workout-1', status: 'active'),
        ];

        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => initialAssignments);

        final container = createTestContainer();
        final notifier = container.read(trainerWorkoutsNotifierProvider.notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerWorkoutsNotifierProvider,
          (state) => !state.isLoading,
        );

        notifier.pauseWorkout('workout-1');

        final state = container.read(trainerWorkoutsNotifierProvider);

        expect(state.workouts.first.status, WorkoutAssignmentStatus.paused);
      });
    });

    group('activateWorkout', () {
      test('should update workout status to active', () async {
        final initialAssignments = [
          WorkoutFixtures.apiResponse(id: 'workout-1', status: 'paused'),
        ];

        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => initialAssignments);

        final container = createTestContainer();
        final notifier = container.read(trainerWorkoutsNotifierProvider.notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerWorkoutsNotifierProvider,
          (state) => !state.isLoading,
        );

        notifier.activateWorkout('workout-1');

        final state = container.read(trainerWorkoutsNotifierProvider);

        expect(state.workouts.first.status, WorkoutAssignmentStatus.active);
      });
    });

    group('evolveWorkout', () {
      test('should update exercises and increment version', () async {
        final initialAssignments = [
          WorkoutFixtures.apiResponse(id: 'workout-1'),
        ];

        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => initialAssignments);

        final container = createTestContainer();
        final notifier = container.read(trainerWorkoutsNotifierProvider.notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerWorkoutsNotifierProvider,
          (state) => !state.isLoading,
        );

        final newExercises = [
          const WorkoutExercise(
            id: 'new-ex-1',
            exerciseId: 'bench-press',
            exerciseName: 'Supino Reto',
            sets: 5,
          ),
        ];

        await notifier.evolveWorkout('workout-1', newExercises);

        final state = container.read(trainerWorkoutsNotifierProvider);
        final workout = state.workouts.first;

        expect(workout.exercises.length, 1);
        expect(workout.exercises.first.sets, 5);
        expect(workout.version, 2);
      });
    });

    group('refresh', () {
      test('should reload workouts', () async {
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);

        final container = createTestContainer();
        final notifier = container.read(trainerWorkoutsNotifierProvider.notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          trainerWorkoutsNotifierProvider,
          (state) => !state.isLoading,
        );

        notifier.refresh();

        // Wait for refresh to complete
        await waitForProviderState(
          container,
          trainerWorkoutsNotifierProvider,
          (state) => !state.isLoading,
        );

        verify(() => mockWorkoutService.getWorkoutAssignments()).called(2);
      });
    });
  });

  group('studentWorkoutsProvider', () {
    test('should filter workouts by studentId', () {
      final workouts = [
        WorkoutFixtures.withExercises(id: 'w1').copyWith(studentId: 'student-1'),
        WorkoutFixtures.withExercises(id: 'w2').copyWith(studentId: 'student-2'),
        WorkoutFixtures.withExercises(id: 'w3').copyWith(studentId: 'student-1'),
      ];

      final container = createContainer(
        overrides: [
          trainerWorkoutsProvider.overrideWithValue(workouts),
        ],
      );

      final studentWorkouts = container.read(studentWorkoutsProvider('student-1'));

      expect(studentWorkouts.length, 2);
      expect(studentWorkouts.every((w) => w.studentId == 'student-1'), true);
    });
  });

  group('StudentProgressNotifier', () {
    ProviderContainer createTestContainer() {
      return createContainer(
        overrides: [
          workoutServiceProvider.overrideWithValue(mockWorkoutService),
        ],
      );
    }

    group('loadProgress', () {
      test('should calculate progress from sessions', () async {
        final sessions = WorkoutFixtures.sessionApiResponseList(count: 10);

        when(() => mockWorkoutService.getWorkoutSessions())
            .thenAnswer((_) async => sessions);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          studentProgressNotifierProvider('student-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(studentProgressNotifierProvider('student-1'));

        expect(state.isLoading, false);
        expect(state.progress.totalSessions, 10);
      });

      test('should handle empty sessions', () async {
        when(() => mockWorkoutService.getWorkoutSessions())
            .thenAnswer((_) async => []);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          studentProgressNotifierProvider('student-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(studentProgressNotifierProvider('student-1'));

        expect(state.progress.totalSessions, 0);
        expect(state.progress.currentStreak, 0);
        expect(state.progress.longestStreak, 0);
      });
    });

    group('applySuggestion', () {
      test('should mark suggestion as applied', () async {
        when(() => mockWorkoutService.getWorkoutSessions())
            .thenAnswer((_) async => []);

        final container = createTestContainer();
        final notifier = container.read(studentProgressNotifierProvider('student-1').notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          studentProgressNotifierProvider('student-1'),
          (state) => !state.isLoading,
        );

        // First add a suggestion to the state
        final suggestion = WorkoutFixtures.aiSuggestion(id: 'suggestion-1');
        final currentState = container.read(studentProgressNotifierProvider('student-1'));
        notifier.state = currentState.copyWith(
          progress: currentState.progress.copyWith(
            aiSuggestions: [suggestion],
          ),
        );

        notifier.applySuggestion('suggestion-1');

        final state = container.read(studentProgressNotifierProvider('student-1'));
        expect(state.progress.aiSuggestions.first.applied, true);
      });
    });

    group('dismissSuggestion', () {
      test('should mark suggestion as dismissed with reason', () async {
        when(() => mockWorkoutService.getWorkoutSessions())
            .thenAnswer((_) async => []);

        final container = createTestContainer();
        final notifier = container.read(studentProgressNotifierProvider('student-1').notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          studentProgressNotifierProvider('student-1'),
          (state) => !state.isLoading,
        );

        final suggestion = WorkoutFixtures.aiSuggestion(id: 'suggestion-1');
        final currentState = container.read(studentProgressNotifierProvider('student-1'));
        notifier.state = currentState.copyWith(
          progress: currentState.progress.copyWith(
            aiSuggestions: [suggestion],
          ),
        );

        notifier.dismissSuggestion('suggestion-1', 'Not relevant');

        final state = container.read(studentProgressNotifierProvider('student-1'));
        expect(state.progress.aiSuggestions.first.dismissed, true);
        expect(state.progress.aiSuggestions.first.dismissReason, 'Not relevant');
      });
    });

    group('addMilestone', () {
      test('should add milestone to state', () async {
        when(() => mockWorkoutService.getWorkoutSessions())
            .thenAnswer((_) async => []);

        final container = createTestContainer();
        final notifier = container.read(studentProgressNotifierProvider('student-1').notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          studentProgressNotifierProvider('student-1'),
          (state) => !state.isLoading,
        );

        final milestone = ProgressMilestone(
          id: 'milestone-1',
          title: 'First PR',
          description: '100kg Supino',
          achievedAt: DateTime.now(),
        );

        notifier.addMilestone(milestone);

        final state = container.read(studentProgressNotifierProvider('student-1'));
        expect(state.progress.milestones.length, 1);
        expect(state.progress.milestones.first.title, 'First PR');
      });
    });
  });

  group('aiSuggestionsProvider', () {
    test('should filter out dismissed suggestions', () {
      final progress = WorkoutFixtures.studentProgress().copyWith(
        aiSuggestions: [
          WorkoutFixtures.aiSuggestion(id: 's1'),
          WorkoutFixtures.aiSuggestion(id: 's2').copyWith(dismissed: true),
          WorkoutFixtures.aiSuggestion(id: 's3'),
        ],
      );

      final container = createContainer(
        overrides: [
          studentProgressProvider('student-1').overrideWithValue(progress),
        ],
      );

      final suggestions = container.read(aiSuggestionsProvider('student-1'));

      expect(suggestions.length, 2);
      expect(suggestions.every((s) => !s.dismissed), true);
    });
  });

  group('StudentProgramsNotifier', () {
    ProviderContainer createTestContainer() {
      return createContainer(
        overrides: [
          workoutServiceProvider.overrideWithValue(mockWorkoutService),
        ],
      );
    }

    test('should load programs for student', () async {
      final programs = [
        {'id': 'program-1', 'name': 'Program A'},
        {'id': 'program-2', 'name': 'Program B'},
      ];

      when(() => mockWorkoutService.getPlans(studentId: any(named: 'studentId')))
          .thenAnswer((_) async => programs);

      final container = createTestContainer();

      // Wait for loading to complete
      await waitForProviderState(
        container,
        studentProgramsNotifierProvider('student-1'),
        (state) => !state.isLoading,
      );

      final state = container.read(studentProgramsNotifierProvider('student-1'));

      expect(state.programs.length, 2);
      expect(state.isLoading, false);
    });

    test('should handle error', () async {
      when(() => mockWorkoutService.getPlans(studentId: any(named: 'studentId')))
          .thenThrow(const ServerException('Error'));

      final container = createTestContainer();

      // Wait for loading to complete
      await waitForProviderState(
        container,
        studentProgramsNotifierProvider('student-1'),
        (state) => !state.isLoading,
      );

      final state = container.read(studentProgramsNotifierProvider('student-1'));

      expect(state.error, 'Error');
    });
  });
}
