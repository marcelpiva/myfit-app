import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/core/services/trainer_service.dart';
import 'package:myfit_app/features/trainer_workout/presentation/providers/student_progress_provider.dart';

import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockTrainerService mockTrainerService;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockTrainerService = MockTrainerService();
  });

  group('StudentProgressNotifier', () {
    ProviderContainer createTestContainer() {
      return createContainer(
        overrides: [
          trainerServiceProvider.overrideWithValue(mockTrainerService),
        ],
      );
    }

    group('loadAll', () {
      test('should load progress data from API', () async {
        final progressData = {
          'start_date': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
          'duration_days': 60,
          'current_weight': 75.0,
          'goal_weight': 70.0,
          'total_change': -2.5,
          'initial_weight': 77.5,
          'weight_entries': [
            {'id': '1', 'weight': 77.5, 'formatted_date': '01 Jan', 'change': 0.0},
            {'id': '2', 'weight': 75.0, 'formatted_date': '15 Jan', 'change': -2.5},
          ],
          'measurements': [
            {'label': 'Cintura', 'value': 85.0, 'unit': 'cm', 'change': -2.0},
            {'label': 'Peito', 'value': 100.0, 'unit': 'cm', 'change': 1.5},
          ],
          'photos': [
            {'id': '1', 'formatted_date': '01 Jan', 'weight_at_photo': '77.5 kg'},
          ],
          'notes': [
            {'id': '1', 'formatted_date': '10 Jan', 'content': 'Treino excelente'},
          ],
          'chart_values': [77.5, 76.0, 75.5, 75.0],
          'chart_labels': ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'],
          'last_measurement_date': '15 Jan',
        };

        when(() => mockTrainerService.getStudentProgress(any()))
            .thenAnswer((_) async => progressData);

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          studentProgressNotifierProvider('student-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(studentProgressNotifierProvider('student-1'));

        expect(state.isLoading, false);
        expect(state.error, isNull);
        expect(state.summary.currentWeight, 75.0);
        expect(state.summary.goalWeight, 70.0);
        expect(state.summary.totalChange, -2.5);
        expect(state.weightEntries.length, 2);
        expect(state.measurements.length, 2);
        expect(state.photos.length, 1);
        expect(state.notes.length, 1);
        expect(state.chartValues.length, 4);
        expect(state.chartLabels.length, 4);
      });

      test('should set loading state during load', () async {
        when(() => mockTrainerService.getStudentProgress(any()))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return {};
        });

        final container = createTestContainer();

        final initialState = container.read(studentProgressNotifierProvider('student-1'));
        expect(initialState.isLoading, true);

        await Future.delayed(const Duration(milliseconds: 100));

        final finalState = container.read(studentProgressNotifierProvider('student-1'));
        expect(finalState.isLoading, false);
      });

      test('should handle empty data', () async {
        when(() => mockTrainerService.getStudentProgress(any()))
            .thenAnswer((_) async => {});

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          studentProgressNotifierProvider('student-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(studentProgressNotifierProvider('student-1'));

        expect(state.weightEntries, isEmpty);
        expect(state.measurements, isEmpty);
        expect(state.photos, isEmpty);
        expect(state.notes, isEmpty);
      });

      test('should handle API error', () async {
        when(() => mockTrainerService.getStudentProgress(any()))
            .thenThrow(Exception('API error'));

        final container = createTestContainer();

        // Wait for loading to complete
        await waitForProviderState(
          container,
          studentProgressNotifierProvider('student-1'),
          (state) => !state.isLoading,
        );

        final state = container.read(studentProgressNotifierProvider('student-1'));

        expect(state.isLoading, false);
        expect(state.error, 'Erro ao carregar progresso do aluno');
      });
    });

    group('refresh', () {
      test('should reload all data', () async {
        when(() => mockTrainerService.getStudentProgress(any()))
            .thenAnswer((_) async => {});

        final container = createTestContainer();
        final notifier = container.read(studentProgressNotifierProvider('student-1').notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          studentProgressNotifierProvider('student-1'),
          (state) => !state.isLoading,
        );

        await notifier.refresh();

        verify(() => mockTrainerService.getStudentProgress('student-1')).called(2);
      });
    });

    group('addNote', () {
      test('should add note and reload data', () async {
        when(() => mockTrainerService.getStudentProgress(any()))
            .thenAnswer((_) async => {});
        when(() => mockTrainerService.addStudentNote(any(), any()))
            .thenAnswer((_) async => {'id': 'new-note'});

        final container = createTestContainer();
        final notifier = container.read(studentProgressNotifierProvider('student-1').notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          studentProgressNotifierProvider('student-1'),
          (state) => !state.isLoading,
        );

        final result = await notifier.addNote('Test note content');

        expect(result, true);
        verify(() => mockTrainerService.addStudentNote('student-1', 'Test note content')).called(1);
        // Should reload after adding note
        verify(() => mockTrainerService.getStudentProgress('student-1')).called(2);
      });

      test('should return false on error', () async {
        when(() => mockTrainerService.getStudentProgress(any()))
            .thenAnswer((_) async => {});
        when(() => mockTrainerService.addStudentNote(any(), any()))
            .thenThrow(Exception('Error'));

        final container = createTestContainer();
        final notifier = container.read(studentProgressNotifierProvider('student-1').notifier);

        // Wait for loading to complete
        await waitForProviderState(
          container,
          studentProgressNotifierProvider('student-1'),
          (state) => !state.isLoading,
        );

        final result = await notifier.addNote('Test note');

        expect(result, false);
      });
    });
  });

  group('Convenience Providers', () {
    group('studentWeightEntriesProvider', () {
      test('should return weight entries', () {
        final entries = [
          const WeightEntry(id: '1', weight: 75.0, date: '15 Jan', change: -2.5),
        ];

        final container = createContainer(
          overrides: [
            studentWeightEntriesProvider('student-1').overrideWithValue(entries),
          ],
        );

        final result = container.read(studentWeightEntriesProvider('student-1'));

        expect(result.length, 1);
        expect(result.first.weight, 75.0);
      });
    });

    group('studentMeasurementsProvider', () {
      test('should return measurements', () {
        final measurements = [
          const Measurement(label: 'Cintura', value: 85.0, unit: 'cm', change: -2.0),
        ];

        final container = createContainer(
          overrides: [
            studentMeasurementsProvider('student-1').overrideWithValue(measurements),
          ],
        );

        final result = container.read(studentMeasurementsProvider('student-1'));

        expect(result.length, 1);
        expect(result.first.label, 'Cintura');
      });
    });

    group('studentPhotosProvider', () {
      test('should return photos', () {
        final photos = [
          const ProgressPhoto(id: '1', date: '01 Jan', weight: '75 kg'),
        ];

        final container = createContainer(
          overrides: [
            studentPhotosProvider('student-1').overrideWithValue(photos),
          ],
        );

        final result = container.read(studentPhotosProvider('student-1'));

        expect(result.length, 1);
        expect(result.first.date, '01 Jan');
      });
    });

    group('studentNotesProvider', () {
      test('should return notes', () {
        final notes = [
          const TrainerNote(id: '1', date: '10 Jan', content: 'Treino excelente'),
        ];

        final container = createContainer(
          overrides: [
            studentNotesProvider('student-1').overrideWithValue(notes),
          ],
        );

        final result = container.read(studentNotesProvider('student-1'));

        expect(result.length, 1);
        expect(result.first.content, 'Treino excelente');
      });
    });

    group('isStudentProgressLoadingProvider', () {
      test('should return loading state', () {
        final container = createContainer(
          overrides: [
            isStudentProgressLoadingProvider('student-1').overrideWithValue(true),
          ],
        );

        final isLoading = container.read(isStudentProgressLoadingProvider('student-1'));

        expect(isLoading, true);
      });
    });
  });

  group('Models', () {
    group('WeightEntry', () {
      test('should create from JSON', () {
        final json = {
          'id': '1',
          'weight': 75.0,
          'formatted_date': '15 Jan',
          'change': -2.5,
        };

        final entry = WeightEntry.fromJson(json);

        expect(entry.id, '1');
        expect(entry.weight, 75.0);
        expect(entry.date, '15 Jan');
        expect(entry.change, -2.5);
      });

      test('should handle missing fields', () {
        final json = <String, dynamic>{};

        final entry = WeightEntry.fromJson(json);

        expect(entry.id, '');
        expect(entry.weight, 0);
        expect(entry.date, '');
        expect(entry.change, 0);
      });

      test('should convert to map', () {
        const entry = WeightEntry(id: '1', weight: 75.0, date: '15 Jan', change: -2.5);

        final map = entry.toMap();

        expect(map['weight'], 75.0);
        expect(map['date'], '15 Jan');
        expect(map['change'], -2.5);
      });
    });

    group('Measurement', () {
      test('should create from JSON', () {
        final json = {
          'label': 'Cintura',
          'value': 85.0,
          'unit': 'cm',
          'change': -2.0,
        };

        final measurement = Measurement.fromJson(json);

        expect(measurement.label, 'Cintura');
        expect(measurement.value, 85.0);
        expect(measurement.unit, 'cm');
        expect(measurement.change, -2.0);
      });

      test('should use name as fallback for label', () {
        final json = {
          'name': 'Cintura',
          'value': 85.0,
        };

        final measurement = Measurement.fromJson(json);

        expect(measurement.label, 'Cintura');
      });
    });

    group('ProgressPhoto', () {
      test('should create from JSON', () {
        final json = {
          'id': '1',
          'formatted_date': '01 Jan',
          'weight_at_photo': '75 kg',
          'note': 'Before photo',
          'image_url': 'https://example.com/photo.jpg',
        };

        final photo = ProgressPhoto.fromJson(json);

        expect(photo.id, '1');
        expect(photo.date, '01 Jan');
        expect(photo.weight, '75 kg');
        expect(photo.note, 'Before photo');
        expect(photo.imageUrl, 'https://example.com/photo.jpg');
      });

      test('should use url as fallback for image_url', () {
        final json = {
          'id': '1',
          'date': '01 Jan',
          'weight': '75 kg',
          'url': 'https://example.com/photo.jpg',
        };

        final photo = ProgressPhoto.fromJson(json);

        expect(photo.imageUrl, 'https://example.com/photo.jpg');
      });
    });

    group('TrainerNote', () {
      test('should create from JSON', () {
        final json = {
          'id': '1',
          'formatted_date': '10 Jan',
          'content': 'Treino excelente',
        };

        final note = TrainerNote.fromJson(json);

        expect(note.id, '1');
        expect(note.date, '10 Jan');
        expect(note.content, 'Treino excelente');
      });
    });

    group('StudentProgressSummary', () {
      test('should create from JSON', () {
        final json = {
          'start_date': '2024-01-01T00:00:00.000Z',
          'duration_days': 60,
          'current_weight': 75.0,
          'goal_weight': 70.0,
          'total_change': -2.5,
          'initial_weight': 77.5,
        };

        final summary = StudentProgressSummary.fromJson(json);

        expect(summary.startDate, isNotNull);
        expect(summary.durationDays, 60);
        expect(summary.currentWeight, 75.0);
        expect(summary.goalWeight, 70.0);
        expect(summary.totalChange, -2.5);
        expect(summary.initialWeight, 77.5);
      });

      test('should use duration as fallback for duration_days', () {
        final json = {
          'duration': 60,
        };

        final summary = StudentProgressSummary.fromJson(json);

        expect(summary.durationDays, 60);
      });

      test('formattedStartDate should return formatted date', () {
        final summary = StudentProgressSummary(
          startDate: DateTime(2024, 1, 15),
        );

        expect(summary.formattedStartDate, '15 Jan');
      });

      test('formattedStartDate should return dash when null', () {
        const summary = StudentProgressSummary();

        expect(summary.formattedStartDate, '-');
      });

      test('formattedDuration should return formatted string', () {
        const summary = StudentProgressSummary(durationDays: 60);

        expect(summary.formattedDuration, '60 dias');
      });

      test('remainingToGoal should calculate correctly', () {
        const summary = StudentProgressSummary(
          currentWeight: 75.0,
          goalWeight: 70.0,
        );

        expect(summary.remainingToGoal, 5.0);
      });

      test('remainingToGoal should be negative when below goal', () {
        const summary = StudentProgressSummary(
          currentWeight: 68.0,
          goalWeight: 70.0,
        );

        expect(summary.remainingToGoal, -2.0);
      });
    });

    group('StudentProgressState', () {
      test('should have correct default values', () {
        const state = StudentProgressState();

        expect(state.summary.currentWeight, 0);
        expect(state.weightEntries, isEmpty);
        expect(state.measurements, isEmpty);
        expect(state.photos, isEmpty);
        expect(state.notes, isEmpty);
        expect(state.chartValues, isEmpty);
        expect(state.chartLabels, isEmpty);
        expect(state.isLoading, false);
        expect(state.error, isNull);
      });

      test('photoCount should return correct count', () {
        final state = StudentProgressState(
          photos: [
            const ProgressPhoto(id: '1', date: '01 Jan', weight: '75 kg'),
            const ProgressPhoto(id: '2', date: '15 Jan', weight: '74 kg'),
          ],
        );

        expect(state.photoCount, 2);
      });

      test('should copy with updated values', () {
        const original = StudentProgressState(
          isLoading: false,
        );

        final copy = original.copyWith(
          isLoading: true,
          error: 'Test error',
        );

        expect(copy.isLoading, true);
        expect(copy.error, 'Test error');
      });
    });
  });
}
