import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/core/error/api_exceptions.dart';
import 'package:myfit_app/core/services/trainer_service.dart';

import '../../helpers/fixtures/student_fixtures.dart';
import '../../helpers/mock_services.dart';

void main() {
  late MockApiClient mockApiClient;
  late TrainerService trainerService;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockApiClient = MockApiClient();
    trainerService = TrainerService(client: mockApiClient);
  });

  group('TrainerService', () {
    group('getStudents', () {
      test('should return list of students on success', () async {
        final students = StudentFixtures.apiResponseList(count: 3);
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: students));

        final result = await trainerService.getStudents();

        expect(result.length, 3);
        verify(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).called(1);
      });

      test('should return empty list on 200 with null data', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: null, statusCode: 200));

        final result = await trainerService.getStudents();

        expect(result, isEmpty);
      });

      test('should apply status filter', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: []));

        await trainerService.getStudents(status: 'active');

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

        await trainerService.getStudents(query: 'João');

        verify(() => mockApiClient.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).called(1);
      });

      test('should apply pagination parameters', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: []));

        await trainerService.getStudents(limit: 20, offset: 10);

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
          () => trainerService.getStudents(),
          throwsA(isA<UnknownApiException>()),
        );
      });

      test('should rethrow ApiException from DioException error', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(createDioException(
          error: const ServerException('Server error'),
        ));

        expect(
          () => trainerService.getStudents(),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getStudent', () {
      test('should return student details on success', () async {
        final student = StudentFixtures.activeApiResponse();
        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => createResponse(data: student),
        );

        final result = await trainerService.getStudent('student-1');

        expect(result['user_id'], 'student-1');
      });

      test('should throw NotFoundException on 200 with null data', () async {
        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => createResponse(data: null, statusCode: 200),
        );

        expect(
          () => trainerService.getStudent('student-1'),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('should throw UnknownApiException on DioException', () async {
        when(() => mockApiClient.get(any()))
            .thenThrow(createDioException(message: 'Not found'));

        expect(
          () => trainerService.getStudent('student-1'),
          throwsA(isA<UnknownApiException>()),
        );
      });
    });

    group('getStudentStats', () {
      test('should return student stats on success', () async {
        final stats = {
          'total_workouts': 24,
          'completed_workouts': 20,
          'total_minutes': 1200,
        };
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: stats));

        final result = await trainerService.getStudentStats('student-1');

        expect(result['total_workouts'], 24);
      });

      test('should apply days parameter', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: <String, dynamic>{}));

        await trainerService.getStudentStats('student-1', days: 60);

        verify(() => mockApiClient.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).called(1);
      });

      test('should return empty map on null data', () async {
        when(() => mockApiClient.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => createResponse(data: null));

        final result = await trainerService.getStudentStats('student-1');

        expect(result, isEmpty);
      });
    });

    group('getStudentProgress', () {
      test('should return student progress on success', () async {
        final progress = {
          'current_weight': 75.0,
          'goal_weight': 70.0,
          'total_change': -2.5,
        };
        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => createResponse(data: progress),
        );

        final result = await trainerService.getStudentProgress('student-1');

        expect(result['current_weight'], 75.0);
      });

      test('should return empty map on null data', () async {
        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => createResponse(data: null),
        );

        final result = await trainerService.getStudentProgress('student-1');

        expect(result, isEmpty);
      });
    });

    group('addStudentNote', () {
      test('should create note on success', () async {
        final note = {
          'id': 'note-1',
          'content': 'Test note',
          'created_at': DateTime.now().toIso8601String(),
        };
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: note, statusCode: 201));

        final result = await trainerService.addStudentNote('student-1', 'Test note');

        expect(result['id'], 'note-1');
        expect(result['content'], 'Test note');
      });

      test('should throw ServerException on non-201 response', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: null, statusCode: 200));

        expect(
          () => trainerService.addStudentNote('student-1', 'Test'),
          throwsA(isA<ServerException>()),
        );
      });

      test('should throw UnknownApiException on DioException', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenThrow(createDioException(message: 'Error'));

        expect(
          () => trainerService.addStudentNote('student-1', 'Test'),
          throwsA(isA<UnknownApiException>()),
        );
      });
    });

    group('addStudent', () {
      test('should link student on success', () async {
        final student = StudentFixtures.activeApiResponse();
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: student, statusCode: 201));

        final result = await trainerService.addStudent('user-123');

        expect(result['user_id'], 'student-1');
      });

      test('should throw ServerException on non-201 response', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: null, statusCode: 200));

        expect(
          () => trainerService.addStudent('user-123'),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('updateStudent', () {
      test('should update student status on success', () async {
        final updated = {'user_id': 'student-1', 'status': 'inactive'};
        when(() => mockApiClient.put(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: updated));

        final result = await trainerService.updateStudent(
          'student-1',
          status: 'inactive',
        );

        expect(result['status'], 'inactive');
      });

      test('should update student notes on success', () async {
        final updated = {'user_id': 'student-1', 'notes': 'New notes'};
        when(() => mockApiClient.put(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: updated));

        final result = await trainerService.updateStudent(
          'student-1',
          notes: 'New notes',
        );

        expect(result['notes'], 'New notes');
      });
    });

    group('removeStudent', () {
      test('should remove student on success', () async {
        when(() => mockApiClient.delete(any())).thenAnswer(
          (_) async => createResponse(data: null, statusCode: 204),
        );

        await trainerService.removeStudent('student-1');

        verify(() => mockApiClient.delete(any())).called(1);
      });

      test('should throw UnknownApiException on DioException', () async {
        when(() => mockApiClient.delete(any()))
            .thenThrow(createDioException(message: 'Not found'));

        expect(
          () => trainerService.removeStudent('student-1'),
          throwsA(isA<UnknownApiException>()),
        );
      });
    });

    group('getInviteCode', () {
      test('should return invite code on success', () async {
        final inviteCode = {
          'code': 'ABC123',
          'expires_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        };
        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => createResponse(data: inviteCode),
        );

        final result = await trainerService.getInviteCode();

        expect(result['code'], 'ABC123');
      });

      test('should throw ServerException on null data', () async {
        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => createResponse(data: null),
        );

        expect(
          () => trainerService.getInviteCode(),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('regenerateInviteCode', () {
      test('should regenerate invite code on success', () async {
        final newCode = {
          'code': 'NEW456',
          'expires_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        };
        when(() => mockApiClient.post(any())).thenAnswer(
          (_) async => createResponse(data: newCode, statusCode: 201),
        );

        final result = await trainerService.regenerateInviteCode();

        expect(result['code'], 'NEW456');
      });
    });

    group('registerStudent', () {
      test('should register student with required fields', () async {
        final student = {
          'id': 'student-new',
          'name': 'João Silva',
          'email': 'joao@example.com',
        };
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: student, statusCode: 201));

        final result = await trainerService.registerStudent(
          name: 'João Silva',
          email: 'joao@example.com',
        );

        expect(result['name'], 'João Silva');
        expect(result['email'], 'joao@example.com');
      });

      test('should register student with optional fields', () async {
        final student = {
          'id': 'student-new',
          'name': 'João Silva',
          'email': 'joao@example.com',
          'phone': '11999999999',
          'goal': 'Hipertrofia',
          'notes': 'Novo aluno',
        };
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: student, statusCode: 201));

        final result = await trainerService.registerStudent(
          name: 'João Silva',
          email: 'joao@example.com',
          phone: '11999999999',
          goal: 'Hipertrofia',
          notes: 'Novo aluno',
        );

        expect(result['phone'], '11999999999');
        expect(result['goal'], 'Hipertrofia');
      });

      test('should throw ServerException on non-201 response', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: null, statusCode: 400));

        expect(
          () => trainerService.registerStudent(
            name: 'João',
            email: 'joao@example.com',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('sendInviteEmail', () {
      test('should send invite email on success', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: <String, dynamic>{}, statusCode: 200));

        await trainerService.sendInviteEmail('test@example.com');

        verify(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).called(1);
      });

      test('should accept 201 status code', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: <String, dynamic>{}, statusCode: 201));

        await trainerService.sendInviteEmail('test@example.com');

        verify(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).called(1);
      });

      test('should throw ServerException on error status', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => createResponse(data: null, statusCode: 400));

        expect(
          () => trainerService.sendInviteEmail('invalid-email'),
          throwsA(isA<ServerException>()),
        );
      });

      test('should throw UnknownApiException on DioException', () async {
        when(() => mockApiClient.post(
              any(),
              data: any(named: 'data'),
            )).thenThrow(createDioException(message: 'Error'));

        expect(
          () => trainerService.sendInviteEmail('test@example.com'),
          throwsA(isA<UnknownApiException>()),
        );
      });
    });

    group('getStudentWorkouts', () {
      test('should return list of student workouts on success', () async {
        final workouts = [
          {'id': 'workout-1', 'name': 'Treino A'},
          {'id': 'workout-2', 'name': 'Treino B'},
        ];
        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => createResponse(data: workouts),
        );

        final result = await trainerService.getStudentWorkouts('student-1');

        expect(result.length, 2);
        expect(result[0]['name'], 'Treino A');
      });

      test('should return empty list on null data', () async {
        when(() => mockApiClient.get(any())).thenAnswer(
          (_) async => createResponse(data: null),
        );

        final result = await trainerService.getStudentWorkouts('student-1');

        expect(result, isEmpty);
      });
    });
  });
}
