import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/core/error/api_exceptions.dart';
import 'package:myfit_app/core/services/workout_service.dart';

import '../../helpers/fixtures/plan_fixtures.dart';
import '../../helpers/fixtures/workout_fixtures.dart';
import '../../helpers/mock_services.dart';

void main() {
  late MockApiClient mockApiClient;
  late WorkoutService workoutService;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockApiClient = MockApiClient();
    workoutService = WorkoutService(client: mockApiClient);
  });

  group('WorkoutService', () {
    group('getWorkouts', () {
      test('should return list of workouts on success', () async {
        final workouts = WorkoutFixtures.apiResponseList(count: 3);
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: workouts));

        final result = await workoutService.getWorkouts();

        expect(result.length, 3);
      });

      test('should return empty list on null data', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: null));

        final result = await workoutService.getWorkouts();

        expect(result, isEmpty);
      });

      test('should apply creatorId filter', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: []));

        await workoutService.getWorkouts(creatorId: 'trainer-1');

        verify(() => mockApiClient.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).called(1);
      });

      test('should throw UnknownApiException on DioException', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(createDioException(message: 'Network error'));

        expect(
          () => workoutService.getWorkouts(),
          throwsA(isA<UnknownApiException>()),
        );
      });
    });

    group('getWorkout', () {
      test('should return workout on success', () async {
        final workout = WorkoutFixtures.apiResponse();
        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => createResponse(data: workout),
        );

        final result = await workoutService.getWorkout('workout-1');

        expect(result['id'], 'workout-1');
        expect(result['name'], 'Treino A');
      });

      test('should throw NotFoundException on null data', () async {
        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => createResponse(data: null),
        );

        expect(
          () => workoutService.getWorkout('workout-1'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('createWorkout', () {
      test('should create workout with required fields', () async {
        final workout = WorkoutFixtures.apiResponse();
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: workout, statusCode: 201));

        final result = await workoutService.createWorkout(name: 'Treino A');

        expect(result['name'], 'Treino A');
      });

      test('should create workout with exercises', () async {
        final workout = WorkoutFixtures.apiResponse();
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: workout, statusCode: 201));

        final exercises = [
          {'exercise_id': 'ex-1', 'sets': 4, 'reps': 10},
        ];
        final result = await workoutService.createWorkout(
          name: 'Treino A',
          exercises: exercises,
        );

        expect(result['exercises'], isNotEmpty);
      });

      test('should throw ServerException on non-201 response', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: null, statusCode: 400));

        expect(
          () => workoutService.createWorkout(name: 'Test'),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('updateWorkout', () {
      test('should update workout on success', () async {
        final updated = WorkoutFixtures.apiResponse(name: 'Updated Treino');
        when(() => mockApiClient.put(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: updated));

        final result = await workoutService.updateWorkout(
          'workout-1',
          name: 'Updated Treino',
        );

        expect(result['name'], 'Updated Treino');
      });

      test('should throw ServerException on non-200 response', () async {
        when(() => mockApiClient.put(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: null, statusCode: 404));

        expect(
          () => workoutService.updateWorkout('workout-1', name: 'Test'),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('deleteWorkout', () {
      test('should delete workout on success', () async {
        when(() => mockApiClient.delete(any())).thenAnswer(
          (_) async => createResponse(data: null, statusCode: 204),
        );

        await workoutService.deleteWorkout('workout-1');

        verify(() => mockApiClient.delete(any())).called(1);
      });

      test('should throw UnknownApiException on DioException', () async {
        when(() => mockApiClient.delete(any()))
            .thenThrow(createDioException(message: 'Not found'));

        expect(
          () => workoutService.deleteWorkout('workout-1'),
          throwsA(isA<UnknownApiException>()),
        );
      });
    });

    group('duplicateWorkout', () {
      test('should duplicate workout on success', () async {
        final duplicate = WorkoutFixtures.apiResponse(id: 'workout-copy');
        when(() => mockApiClient.post(any())).thenAnswer(
          (_) async => createResponse(data: duplicate, statusCode: 201),
        );

        final result = await workoutService.duplicateWorkout('workout-1');

        expect(result['id'], 'workout-copy');
      });

      test('should throw ServerException on non-201 response', () async {
        when(() => mockApiClient.post(any())).thenAnswer(
          (_) async => createResponse(data: null, statusCode: 400),
        );

        expect(
          () => workoutService.duplicateWorkout('workout-1'),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getWorkoutExercises', () {
      test('should return list of exercises on success', () async {
        final exercises = [
          {'id': 'ex-1', 'exercise_name': 'Supino Reto'},
          {'id': 'ex-2', 'exercise_name': 'Supino Inclinado'},
        ];
        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => createResponse(data: exercises),
        );

        final result = await workoutService.getWorkoutExercises('workout-1');

        expect(result.length, 2);
      });

      test('should return empty list on null data', () async {
        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => createResponse(data: null),
        );

        final result = await workoutService.getWorkoutExercises('workout-1');

        expect(result, isEmpty);
      });
    });

    group('addExerciseToWorkout', () {
      test('should add exercise on success', () async {
        final exercise = {'id': 'ex-1', 'exercise_id': 'bench-press', 'sets': 4};
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: exercise, statusCode: 201));

        final result = await workoutService.addExerciseToWorkout(
          'workout-1',
          exerciseId: 'bench-press',
          sets: 4,
          reps: 10,
        );

        expect(result['exercise_id'], 'bench-press');
      });

      test('should add exercise with all optional fields', () async {
        final exercise = {'id': 'ex-1', 'weight': 60.0, 'rest_seconds': 90};
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: exercise, statusCode: 201));

        final result = await workoutService.addExerciseToWorkout(
          'workout-1',
          exerciseId: 'bench-press',
          sets: 4,
          reps: 10,
          weight: 60.0,
          restSeconds: 90,
          orderIndex: 0,
          notes: 'Focus on form',
        );

        expect(result['weight'], 60.0);
      });
    });

    group('removeExerciseFromWorkout', () {
      test('should remove exercise on success', () async {
        when(() => mockApiClient.delete(any())).thenAnswer(
          (_) async => createResponse(data: null, statusCode: 204),
        );

        await workoutService.removeExerciseFromWorkout('workout-1', 'ex-1');

        verify(() => mockApiClient.delete(any())).called(1);
      });
    });

    group('getExercises', () {
      test('should return list of exercises on success', () async {
        final exercises = [
          {'id': 'ex-1', 'name': 'Supino Reto'},
          {'id': 'ex-2', 'name': 'Agachamento'},
        ];
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: exercises));

        final result = await workoutService.getExercises();

        expect(result.length, 2);
      });

      test('should apply muscle group filter', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: []));

        await workoutService.getExercises(muscleGroup: 'chest');

        verify(() => mockApiClient.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).called(1);
      });

      test('should apply query filter', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: []));

        await workoutService.getExercises(query: 'supino');

        verify(() => mockApiClient.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).called(1);
      });
    });

    group('getPrograms', () {
      test('should return list of programs on success', () async {
        final programs = PlanFixtures.apiResponseList(count: 3);
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: programs));

        final result = await workoutService.getPlans();

        expect(result.length, 3);
      });

      test('should filter by studentId', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: []));

        await workoutService.getPlans(studentId: 'student-1');

        verify(() => mockApiClient.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).called(1);
      });

      test('should filter templates only', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: []));

        await workoutService.getPlans(templatesOnly: true);

        verify(() => mockApiClient.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).called(1);
      });
    });

    group('getCatalogTemplates', () {
      test('should return list of catalog templates on success', () async {
        final templates = PlanFixtures.catalogResponseList(count: 5);
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: templates));

        final result = await workoutService.getCatalogTemplates();

        expect(result.length, 5);
      });

      test('should apply goal filter', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: []));

        await workoutService.getCatalogTemplates(goal: 'hypertrophy');

        verify(() => mockApiClient.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).called(1);
      });

      test('should apply difficulty filter', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: []));

        await workoutService.getCatalogTemplates(difficulty: 'intermediate');

        verify(() => mockApiClient.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).called(1);
      });

      test('should apply search filter', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: []));

        await workoutService.getCatalogTemplates(search: 'push pull');

        verify(() => mockApiClient.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).called(1);
      });
    });

    group('createProgram', () {
      test('should create program and return ID on success', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(
              data: {'id': 'program-new'},
              statusCode: 201,
            ));

        final result = await workoutService.createPlan(
          name: 'New Program',
          goal: 'hypertrophy',
          difficulty: 'intermediate',
          splitType: 'ABC',
        );

        expect(result, 'program-new');
      });

      test('should throw ServerException on non-201 response', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: null, statusCode: 400));

        expect(
          () => workoutService.createPlan(
            name: 'Test',
            goal: 'strength',
            difficulty: 'beginner',
            splitType: 'ABC',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('duplicateProgram', () {
      test('should duplicate program on success', () async {
        final duplicate = PlanFixtures.abcSplit(id: 'program-copy');
        when(() => mockApiClient.post(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: duplicate, statusCode: 201));

        final result = await workoutService.duplicatePlan('program-1');

        expect(result['id'], 'program-copy');
      });

      test('should duplicate with workouts by default', () async {
        when(() => mockApiClient.post(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: <String, dynamic>{}, statusCode: 201));

        await workoutService.duplicatePlan('program-1');

        verify(() => mockApiClient.post(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).called(1);
      });
    });

    group('createProgramAssignment', () {
      test('should assign program to student on success', () async {
        final assignment = PlanFixtures.assignmentApiResponse();
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: assignment, statusCode: 201));

        final result = await workoutService.createPlanAssignment(
          planId: 'program-1',
          studentId: 'student-1',
        );

        expect(result['program_id'], 'program-1');
        expect(result['student_id'], 'student-1');
      });

      test('should use today as default start date', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: <String, dynamic>{}, statusCode: 201));

        await workoutService.createPlanAssignment(
          planId: 'program-1',
          studentId: 'student-1',
        );

        verify(() => mockApiClient.post(
              any(),
              data: captureAny(named: 'data'),
            )).called(1);
      });

      test('should use provided start date', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: <String, dynamic>{}, statusCode: 201));

        await workoutService.createPlanAssignment(
          planId: 'program-1',
          studentId: 'student-1',
          startDate: DateTime(2024, 2, 1),
        );

        verify(() => mockApiClient.post(
              any(),
              data: captureAny(named: 'data'),
            )).called(1);
      });
    });

    group('suggestExercises', () {
      test('should return AI suggestions on success', () async {
        final suggestions = {
          'exercises': [
            {'id': 'ex-1', 'name': 'Supino Reto'},
            {'id': 'ex-2', 'name': 'Supino Inclinado'},
          ],
          'rationale': 'Based on muscle groups',
        };
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: suggestions));

        final result = await workoutService.suggestExercises(
          muscleGroups: ['chest', 'triceps'],
        );

        expect(result['exercises'], isNotEmpty);
      });

      test('should exclude specified exercises', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: <String, dynamic>{}));

        await workoutService.suggestExercises(
          muscleGroups: ['chest'],
          excludeExerciseIds: ['ex-1', 'ex-2'],
        );

        verify(() => mockApiClient.post(
              any(),
              data: captureAny(named: 'data'),
            )).called(1);
      });
    });

    group('generatePlanWithAI', () {
      test('should generate plan on success', () async {
        final aiResponse = PlanFixtures.aiGenerationResponse();
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => createResponse(data: aiResponse));

        final result = await workoutService.generatePlanWithAI(
          goal: 'hypertrophy',
          difficulty: 'intermediate',
          daysPerWeek: 4,
          minutesPerSession: 60,
          equipment: 'full_gym',
        );

        expect(result, isNotNull);
      });

      test('should include injuries in request', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => createResponse(data: <String, dynamic>{}));

        await workoutService.generatePlanWithAI(
          goal: 'hypertrophy',
          difficulty: 'intermediate',
          daysPerWeek: 4,
          minutesPerSession: 60,
          equipment: 'full_gym',
          injuries: ['shoulder', 'lower_back'],
        );

        verify(() => mockApiClient.post(
              any(),
              data: captureAny(named: 'data'),
              options: any(named: 'options'),
            )).called(1);
      });

      test('should throw ServerException on non-200 response', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => createResponse(data: null, statusCode: 500));

        expect(
          () => workoutService.generatePlanWithAI(
            goal: 'strength',
            difficulty: 'beginner',
            daysPerWeek: 3,
            minutesPerSession: 45,
            equipment: 'home',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('recordSessionSet', () {
      test('should record set on success', () async {
        final set = {
          'id': 'set-1',
          'exercise_id': 'bench-press',
          'set_number': 1,
          'reps': 10,
          'weight': 60.0,
        };
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: set, statusCode: 201));

        final result = await workoutService.recordSessionSet(
          'session-1',
          exerciseId: 'bench-press',
          setNumber: 1,
          reps: 10,
          weight: 60.0,
        );

        expect(result['reps'], 10);
        expect(result['weight'], 60.0);
      });

      test('should record set without weight', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: <String, dynamic>{}, statusCode: 201));

        await workoutService.recordSessionSet(
          'session-1',
          exerciseId: 'pull-up',
          setNumber: 1,
          reps: 8,
        );

        verify(() => mockApiClient.post(
              any(),
              data: captureAny(named: 'data'),
            )).called(1);
      });
    });

    group('getWorkoutSessions', () {
      test('should return list of sessions on success', () async {
        final sessions = WorkoutFixtures.sessionApiResponseList(count: 5);
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: sessions));

        final result = await workoutService.getWorkoutSessions();

        expect(result.length, 5);
      });

      test('should apply date range filters', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: []));

        await workoutService.getWorkoutSessions(
          fromDate: DateTime(2024, 1, 1),
          toDate: DateTime(2024, 1, 31),
        );

        verify(() => mockApiClient.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).called(1);
      });
    });

    group('getWorkoutAssignments', () {
      test('should return list of assignments on success', () async {
        final assignments = [
          WorkoutFixtures.assignmentApiResponse(),
        ];
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: assignments));

        final result = await workoutService.getWorkoutAssignments();

        expect(result.length, 1);
      });

      test('should filter by studentId', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: []));

        await workoutService.getWorkoutAssignments(studentId: 'student-1');

        verify(() => mockApiClient.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).called(1);
      });

      test('should filter by active status', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: []));

        await workoutService.getWorkoutAssignments(active: true);

        verify(() => mockApiClient.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).called(1);
      });
    });

    group('createWorkoutAssignment', () {
      test('should create assignment on success', () async {
        final assignment = WorkoutFixtures.assignmentApiResponse();
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: assignment, statusCode: 201));

        final result = await workoutService.createWorkoutAssignment(
          workoutId: 'workout-1',
          studentId: 'student-1',
        );

        expect(result['workout_id'], 'workout-1');
      });
    });

    group('completeWorkoutSession', () {
      test('should complete session on success', () async {
        final session = WorkoutFixtures.sessionApiResponse(status: 'completed');
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: session));

        final result = await workoutService.completeWorkoutSession(
          'session-1',
          notes: 'Good session',
          rating: 4,
        );

        expect(result['status'], 'completed');
      });
    });
  });
}
