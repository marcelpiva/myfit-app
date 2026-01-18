import 'package:flutter_test/flutter_test.dart';
import 'package:myfit_app/features/trainer_workout/domain/models/trainer_workout.dart';

import '../../helpers/fixtures/workout_fixtures.dart';

void main() {
  group('TrainerWorkout', () {
    test('should create with required fields', () {
      final workout = TrainerWorkout(
        id: 'workout-1',
        trainerId: 'trainer-1',
        trainerName: 'Personal João',
        studentId: 'student-1',
        studentName: 'João Silva',
        name: 'Treino A',
        createdAt: DateTime(2024, 1, 15),
      );

      expect(workout.id, 'workout-1');
      expect(workout.trainerId, 'trainer-1');
      expect(workout.trainerName, 'Personal João');
      expect(workout.studentId, 'student-1');
      expect(workout.studentName, 'João Silva');
      expect(workout.name, 'Treino A');
    });

    test('should have correct default values', () {
      final workout = TrainerWorkout(
        id: 'workout-1',
        trainerId: 'trainer-1',
        trainerName: 'Personal João',
        studentId: 'student-1',
        studentName: 'João Silva',
        name: 'Treino A',
        createdAt: DateTime(2024, 1, 15),
      );

      expect(workout.difficulty, WorkoutDifficulty.intermediate);
      expect(workout.status, WorkoutAssignmentStatus.draft);
      expect(workout.exercises, isEmpty);
      expect(workout.periodization, PeriodizationType.linear);
      expect(workout.totalSessions, 0);
      expect(workout.completedSessions, 0);
      expect(workout.estimatedDurationMinutes, 0);
      expect(workout.aiGenerated, false);
      expect(workout.version, 1);
    });

    group('progressPercent', () {
      test('should return 0 when totalSessions is 0', () {
        final workout = WorkoutFixtures.empty();
        expect(workout.progressPercent, 0);
      });

      test('should calculate correct progress percentage', () {
        final workout = WorkoutFixtures.withExercises().copyWith(
          totalSessions: 24,
          completedSessions: 6,
        );
        expect(workout.progressPercent, 25.0);
      });

      test('should return 100 when all sessions completed', () {
        final workout = WorkoutFixtures.completed();
        expect(workout.progressPercent, 100.0);
      });
    });

    group('isActive', () {
      test('should return true when status is active', () {
        final workout = WorkoutFixtures.withExercises(
          status: WorkoutAssignmentStatus.active,
        );
        expect(workout.isActive, true);
      });

      test('should return false when status is draft', () {
        final workout = WorkoutFixtures.draft();
        expect(workout.isActive, false);
      });

      test('should return false when status is paused', () {
        final workout = WorkoutFixtures.withExercises(
          status: WorkoutAssignmentStatus.paused,
        );
        expect(workout.isActive, false);
      });

      test('should return false when status is completed', () {
        final workout = WorkoutFixtures.completed();
        expect(workout.isActive, false);
      });

      test('should return false when status is archived', () {
        final workout = WorkoutFixtures.withExercises(
          status: WorkoutAssignmentStatus.archived,
        );
        expect(workout.isActive, false);
      });
    });

    group('exerciseCount', () {
      test('should return 0 for empty workout', () {
        final workout = WorkoutFixtures.empty();
        expect(workout.exerciseCount, 0);
      });

      test('should return correct count for workout with exercises', () {
        final workout = WorkoutFixtures.withExercises(exerciseCount: 6);
        expect(workout.exerciseCount, 6);
      });
    });

    group('totalVolume', () {
      test('should return 0 for empty workout', () {
        final workout = WorkoutFixtures.empty();
        expect(workout.totalVolume, 0);
      });

      test('should calculate total volume correctly', () {
        final workout = TrainerWorkout(
          id: 'workout-1',
          trainerId: 'trainer-1',
          trainerName: 'Personal',
          studentId: 'student-1',
          studentName: 'Student',
          name: 'Test',
          createdAt: DateTime.now(),
          exercises: [
            const WorkoutExercise(
              id: 'ex-1',
              exerciseId: 'e-1',
              exerciseName: 'Supino',
              sets: 4,
              repsMin: 8,
            ),
            const WorkoutExercise(
              id: 'ex-2',
              exerciseId: 'e-2',
              exerciseName: 'Puxada',
              sets: 3,
              repsMax: 12,
            ),
          ],
        );
        // (4 * 8) + (3 * 12) = 32 + 36 = 68
        expect(workout.totalVolume, 68);
      });

      test('should use default reps when repsMin and repsMax are null', () {
        final workout = TrainerWorkout(
          id: 'workout-1',
          trainerId: 'trainer-1',
          trainerName: 'Personal',
          studentId: 'student-1',
          studentName: 'Student',
          name: 'Test',
          createdAt: DateTime.now(),
          exercises: [
            const WorkoutExercise(
              id: 'ex-1',
              exerciseId: 'e-1',
              exerciseName: 'Supino',
              sets: 4,
            ),
          ],
        );
        // 4 * 10 (default) = 40
        expect(workout.totalVolume, 40);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = WorkoutFixtures.withExercises();
        final copy = original.copyWith(
          name: 'Updated Name',
          status: WorkoutAssignmentStatus.paused,
        );

        expect(copy.name, 'Updated Name');
        expect(copy.status, WorkoutAssignmentStatus.paused);
        expect(copy.id, original.id);
        expect(copy.trainerId, original.trainerId);
      });
    });

    group('fromJson/toJson', () {
      test('should parse from JSON correctly', () {
        final json = WorkoutFixtures.apiResponse();
        final workout = TrainerWorkout.fromJson(json);

        expect(workout.id, 'workout-1');
        expect(workout.name, 'Treino A');
        expect(workout.difficulty, WorkoutDifficulty.intermediate);
        expect(workout.status, WorkoutAssignmentStatus.active);
      });

      test('should handle null optional fields', () {
        final json = {
          'id': 'workout-1',
          'trainerId': 'trainer-1',
          'trainerName': 'Personal',
          'studentId': 'student-1',
          'studentName': 'Student',
          'name': 'Test',
          'createdAt': DateTime.now().toIso8601String(),
        };
        final workout = TrainerWorkout.fromJson(json);

        expect(workout.description, isNull);
        expect(workout.exercises, isEmpty);
        expect(workout.trainerNotes, isNull);
      });
    });
  });

  group('WorkoutExercise', () {
    test('should create with required fields', () {
      const exercise = WorkoutExercise(
        id: 'ex-1',
        exerciseId: 'bench-press',
        exerciseName: 'Supino Reto',
      );

      expect(exercise.id, 'ex-1');
      expect(exercise.exerciseId, 'bench-press');
      expect(exercise.exerciseName, 'Supino Reto');
    });

    test('should have correct default values', () {
      const exercise = WorkoutExercise(
        id: 'ex-1',
        exerciseId: 'bench-press',
        exerciseName: 'Supino Reto',
      );

      expect(exercise.sets, 3);
      expect(exercise.dropSet, false);
      expect(exercise.superSet, false);
      expect(exercise.order, 0);
    });

    group('setsRepsDescription', () {
      test('should format with reps range', () {
        const exercise = WorkoutExercise(
          id: 'ex-1',
          exerciseId: 'e-1',
          exerciseName: 'Test',
          sets: 4,
          repsMin: 8,
          repsMax: 12,
        );
        expect(exercise.setsRepsDescription, '4 x 8-12');
      });

      test('should format with single reps value', () {
        const exercise = WorkoutExercise(
          id: 'ex-1',
          exerciseId: 'e-1',
          exerciseName: 'Test',
          sets: 4,
          repsMax: 10,
        );
        expect(exercise.setsRepsDescription, '4 x 10');
      });

      test('should format with reps note', () {
        const exercise = WorkoutExercise(
          id: 'ex-1',
          exerciseId: 'e-1',
          exerciseName: 'Test',
          sets: 3,
          repsNote: 'até a falha',
        );
        expect(exercise.setsRepsDescription, '3 x até a falha');
      });

      test('should format with sets only when no reps info', () {
        const exercise = WorkoutExercise(
          id: 'ex-1',
          exerciseId: 'e-1',
          exerciseName: 'Test',
          sets: 4,
        );
        expect(exercise.setsRepsDescription, '4 séries');
      });

      test('should not show range when repsMin equals repsMax', () {
        const exercise = WorkoutExercise(
          id: 'ex-1',
          exerciseId: 'e-1',
          exerciseName: 'Test',
          sets: 4,
          repsMin: 10,
          repsMax: 10,
        );
        expect(exercise.setsRepsDescription, '4 x 10');
      });
    });

    group('weightDescription', () {
      test('should format with weight in kg', () {
        const exercise = WorkoutExercise(
          id: 'ex-1',
          exerciseId: 'e-1',
          exerciseName: 'Test',
          weightKg: 60.0,
        );
        expect(exercise.weightDescription, '60.0kg');
      });

      test('should format with weight note', () {
        const exercise = WorkoutExercise(
          id: 'ex-1',
          exerciseId: 'e-1',
          exerciseName: 'Test',
          weightNote: 'RPE 8',
        );
        expect(exercise.weightDescription, 'RPE 8');
      });

      test('should return dash when no weight info', () {
        const exercise = WorkoutExercise(
          id: 'ex-1',
          exerciseId: 'e-1',
          exerciseName: 'Test',
        );
        expect(exercise.weightDescription, '-');
      });

      test('should prefer weightKg over weightNote', () {
        const exercise = WorkoutExercise(
          id: 'ex-1',
          exerciseId: 'e-1',
          exerciseName: 'Test',
          weightKg: 50.0,
          weightNote: 'RPE 7',
        );
        expect(exercise.weightDescription, '50.0kg');
      });
    });

    group('fromJson/toJson', () {
      test('should parse from JSON correctly', () {
        final json = {
          'id': 'ex-1',
          'exerciseId': 'bench-press',
          'exerciseName': 'Supino Reto',
          'sets': 4,
          'repsMin': 8,
          'repsMax': 12,
          'weightKg': 60.0,
          'restSeconds': 90,
          'order': 0,
        };
        final exercise = WorkoutExercise.fromJson(json);

        expect(exercise.id, 'ex-1');
        expect(exercise.exerciseId, 'bench-press');
        expect(exercise.exerciseName, 'Supino Reto');
        expect(exercise.sets, 4);
        expect(exercise.weightKg, 60.0);
        expect(exercise.restSeconds, 90);
      });
    });
  });

  group('ExerciseProgress', () {
    test('should create with required fields', () {
      const progress = ExerciseProgress(
        id: 'progress-1',
        exerciseId: 'bench-press',
        exerciseName: 'Supino Reto',
        studentId: 'student-1',
      );

      expect(progress.id, 'progress-1');
      expect(progress.exerciseId, 'bench-press');
      expect(progress.exerciseName, 'Supino Reto');
      expect(progress.studentId, 'student-1');
    });

    test('should have correct default values', () {
      const progress = ExerciseProgress(
        id: 'progress-1',
        exerciseId: 'bench-press',
        exerciseName: 'Supino Reto',
        studentId: 'student-1',
      );

      expect(progress.logs, isEmpty);
      expect(progress.trend, ProgressTrend.stable);
    });

    test('should create with logs and PRs', () {
      final progress = WorkoutFixtures.exerciseProgress();

      expect(progress.logs.length, 2);
      expect(progress.pr1RM, 85.0);
      expect(progress.pr5RM, 72.5);
      expect(progress.pr10RM, 62.5);
      expect(progress.trend, ProgressTrend.improving);
    });
  });

  group('ExerciseLog', () {
    test('should create with required fields', () {
      final log = ExerciseLog(
        id: 'log-1',
        date: DateTime(2024, 1, 15),
        sets: 4,
        reps: 10,
      );

      expect(log.id, 'log-1');
      expect(log.sets, 4);
      expect(log.reps, 10);
      expect(log.isPR, false);
    });

    test('should create with optional fields', () {
      final log = ExerciseLog(
        id: 'log-1',
        date: DateTime(2024, 1, 15),
        sets: 4,
        reps: 10,
        weightKg: 62.5,
        rpe: 9,
        notes: 'Felt strong',
        isPR: true,
      );

      expect(log.weightKg, 62.5);
      expect(log.rpe, 9);
      expect(log.notes, 'Felt strong');
      expect(log.isPR, true);
    });
  });

  group('StudentProgress', () {
    test('should create with required fields', () {
      const progress = StudentProgress(
        studentId: 'student-1',
        studentName: 'João Silva',
      );

      expect(progress.studentId, 'student-1');
      expect(progress.studentName, 'João Silva');
    });

    test('should have correct default values', () {
      const progress = StudentProgress(
        studentId: 'student-1',
        studentName: 'João Silva',
      );

      expect(progress.totalWorkouts, 0);
      expect(progress.totalSessions, 0);
      expect(progress.totalMinutes, 0);
      expect(progress.currentStreak, 0);
      expect(progress.longestStreak, 0);
      expect(progress.exerciseProgress, isEmpty);
      expect(progress.milestones, isEmpty);
      expect(progress.aiSuggestions, isEmpty);
    });

    group('adherencePercent', () {
      test('should return 0 when totalSessions is 0', () {
        const progress = StudentProgress(
          studentId: 'student-1',
          studentName: 'João Silva',
          totalSessions: 0,
        );
        expect(progress.adherencePercent, 0);
      });

      test('should calculate correct adherence percentage', () {
        const progress = StudentProgress(
          studentId: 'student-1',
          studentName: 'João Silva',
          totalWorkouts: 20,
          totalSessions: 24,
        );
        // (20 / 24) * 100 = 83.33...
        expect(progress.adherencePercent, closeTo(83.33, 0.01));
      });
    });

    test('should create with full data from fixture', () {
      final progress = WorkoutFixtures.studentProgress();

      expect(progress.currentStreak, 5);
      expect(progress.longestStreak, 12);
      expect(progress.totalWorkouts, 24);
      expect(progress.milestones.length, 1);
      expect(progress.exerciseProgress.containsKey('bench-press'), true);
    });
  });

  group('ProgressMilestone', () {
    test('should create with required fields', () {
      final milestone = ProgressMilestone(
        id: 'milestone-1',
        title: 'First Workout',
        description: 'Completed first workout',
        achievedAt: DateTime(2024, 1, 15),
      );

      expect(milestone.id, 'milestone-1');
      expect(milestone.title, 'First Workout');
      expect(milestone.description, 'Completed first workout');
    });

    test('should create with optional fields', () {
      final milestone = ProgressMilestone(
        id: 'milestone-1',
        title: '100kg Supino',
        description: 'Levantou 100kg no supino',
        achievedAt: DateTime(2024, 1, 15),
        icon: '💪',
        exerciseId: 'bench-press',
        value: 100.0,
        unit: 'kg',
      );

      expect(milestone.icon, '💪');
      expect(milestone.exerciseId, 'bench-press');
      expect(milestone.value, 100.0);
      expect(milestone.unit, 'kg');
    });
  });

  group('AISuggestion', () {
    test('should create with required fields', () {
      final suggestion = AISuggestion(
        id: 'suggestion-1',
        type: AISuggestionType.increaseWeight,
        title: 'Aumentar carga',
        description: 'Sugerimos aumentar 2.5kg',
        rationale: 'Baseado nas últimas sessões',
        createdAt: DateTime(2024, 1, 15),
      );

      expect(suggestion.id, 'suggestion-1');
      expect(suggestion.type, AISuggestionType.increaseWeight);
      expect(suggestion.applied, false);
      expect(suggestion.dismissed, false);
    });

    test('should create with exercise-specific fields', () {
      final suggestion = WorkoutFixtures.aiSuggestion();

      expect(suggestion.exerciseId, 'bench-press');
      expect(suggestion.exerciseName, 'Supino Reto');
      expect(suggestion.suggestedWeight, 65.0);
      expect(suggestion.suggestedReps, 10);
    });

    test('should handle replacement suggestions', () {
      final suggestion = AISuggestion(
        id: 'suggestion-2',
        type: AISuggestionType.replaceExercise,
        title: 'Trocar exercício',
        description: 'Sugerimos trocar Supino Reto por Supino Inclinado',
        rationale: 'Melhor ativação do peitoral superior',
        createdAt: DateTime.now(),
        exerciseId: 'bench-press',
        exerciseName: 'Supino Reto',
        newExerciseId: 'incline-press',
        newExerciseName: 'Supino Inclinado',
        replacesExerciseId: 'bench-press',
      );

      expect(suggestion.type, AISuggestionType.replaceExercise);
      expect(suggestion.newExerciseId, 'incline-press');
      expect(suggestion.replacesExerciseId, 'bench-press');
    });
  });

  group('Enums', () {
    group('WorkoutAssignmentStatus', () {
      test('should have all expected values', () {
        expect(WorkoutAssignmentStatus.values, contains(WorkoutAssignmentStatus.draft));
        expect(WorkoutAssignmentStatus.values, contains(WorkoutAssignmentStatus.active));
        expect(WorkoutAssignmentStatus.values, contains(WorkoutAssignmentStatus.paused));
        expect(WorkoutAssignmentStatus.values, contains(WorkoutAssignmentStatus.completed));
        expect(WorkoutAssignmentStatus.values, contains(WorkoutAssignmentStatus.archived));
      });
    });

    group('WorkoutDifficulty', () {
      test('should have all expected values', () {
        expect(WorkoutDifficulty.values, contains(WorkoutDifficulty.beginner));
        expect(WorkoutDifficulty.values, contains(WorkoutDifficulty.intermediate));
        expect(WorkoutDifficulty.values, contains(WorkoutDifficulty.advanced));
        expect(WorkoutDifficulty.values, contains(WorkoutDifficulty.elite));
      });
    });

    group('PeriodizationType', () {
      test('should have all expected values', () {
        expect(PeriodizationType.values, contains(PeriodizationType.linear));
        expect(PeriodizationType.values, contains(PeriodizationType.undulating));
        expect(PeriodizationType.values, contains(PeriodizationType.block));
        expect(PeriodizationType.values, contains(PeriodizationType.conjugate));
        expect(PeriodizationType.values, contains(PeriodizationType.custom));
      });
    });

    group('ProgressTrend', () {
      test('should have all expected values', () {
        expect(ProgressTrend.values, contains(ProgressTrend.improving));
        expect(ProgressTrend.values, contains(ProgressTrend.stable));
        expect(ProgressTrend.values, contains(ProgressTrend.declining));
      });
    });

    group('AISuggestionType', () {
      test('should have all expected values', () {
        expect(AISuggestionType.values, contains(AISuggestionType.increaseWeight));
        expect(AISuggestionType.values, contains(AISuggestionType.increaseVolume));
        expect(AISuggestionType.values, contains(AISuggestionType.deload));
        expect(AISuggestionType.values, contains(AISuggestionType.replaceExercise));
        expect(AISuggestionType.values, contains(AISuggestionType.addExercise));
        expect(AISuggestionType.values, contains(AISuggestionType.removeExercise));
        expect(AISuggestionType.values, contains(AISuggestionType.changePeriodization));
        expect(AISuggestionType.values, contains(AISuggestionType.adjustFrequency));
        expect(AISuggestionType.values, contains(AISuggestionType.focusWeakPoint));
        expect(AISuggestionType.values, contains(AISuggestionType.general));
      });
    });
  });
}
