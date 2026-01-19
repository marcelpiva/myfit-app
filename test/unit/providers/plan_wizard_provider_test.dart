import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfit_app/features/training_plan/domain/models/training_plan.dart';
import 'package:myfit_app/features/training_plan/presentation/providers/plan_wizard_provider.dart';

import '../../helpers/fixtures/exercise_group_fixtures.dart';
import '../../helpers/test_helpers.dart';

/// Extended notifier for testing that exposes state setter
class TestPlanWizardNotifier extends PlanWizardNotifier {
  void setTestWorkouts(List<WizardWorkout> workouts) {
    state = state.copyWith(workouts: workouts);
  }
}

void main() {
  group('PlanWizardNotifier', () {
    late ProviderContainer container;
    late TestPlanWizardNotifier notifier;

    setUp(() {
      notifier = TestPlanWizardNotifier();
      container = createContainer(
        overrides: [
          planWizardProvider.overrideWith((ref) => notifier),
        ],
      );
    });

    // Helper to set up a workout with exercises
    void setupWorkoutWithExercises(List<WizardExercise> exercises) {
      final workout = WizardWorkout(
        id: 'workout-1',
        label: 'A',
        name: 'Treino A',
        exercises: exercises,
      );
      notifier.setTestWorkouts([workout]);
    }

    // Helper to get exercises from the first workout
    List<WizardExercise> getExercises() {
      return container.read(planWizardProvider).workouts.first.exercises;
    }

    // ============================================
    // CREATE EXERCISE GROUP TESTS
    // ============================================

    group('createExerciseGroup', () {
      test('should create superset with 2 exercises', () {
        // Arrange
        setupWorkoutWithExercises([
          ExerciseGroupFixtures.normalExercise(id: 'ex-1', name: 'Supino'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-2', name: 'Puxada'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-3', name: 'Rosca'),
        ]);

        // Act
        final groupId = notifier.createExerciseGroup(
          workoutId: 'workout-1',
          exerciseIds: ['ex-1', 'ex-2'],
          techniqueType: TechniqueType.superset,
        );

        // Assert
        expect(groupId, isNotNull);
        final exercises = getExercises();
        final groupedExercises = exercises.where((e) => e.exerciseGroupId == groupId).toList();

        expect(groupedExercises.length, 2);
        expect(groupedExercises[0].techniqueType, TechniqueType.superset);
        expect(groupedExercises[1].techniqueType, TechniqueType.superset);
        expect(groupedExercises[0].exerciseGroupOrder, 0);
        expect(groupedExercises[1].exerciseGroupOrder, 1);
      });

      test('should create triset with 3 exercises', () {
        // Arrange
        setupWorkoutWithExercises([
          ExerciseGroupFixtures.normalExercise(id: 'ex-1', name: 'Exercício 1'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-2', name: 'Exercício 2'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-3', name: 'Exercício 3'),
        ]);

        // Act
        final groupId = notifier.createExerciseGroup(
          workoutId: 'workout-1',
          exerciseIds: ['ex-1', 'ex-2', 'ex-3'],
          techniqueType: TechniqueType.triset,
        );

        // Assert
        expect(groupId, isNotNull);
        final exercises = getExercises();
        final groupedExercises = exercises.where((e) => e.exerciseGroupId == groupId).toList();

        expect(groupedExercises.length, 3);
        expect(groupedExercises.every((e) => e.techniqueType == TechniqueType.triset), isTrue);
      });

      test('should create giantset with 4+ exercises', () {
        // Arrange
        setupWorkoutWithExercises([
          ExerciseGroupFixtures.normalExercise(id: 'ex-1', name: 'Exercício 1'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-2', name: 'Exercício 2'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-3', name: 'Exercício 3'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-4', name: 'Exercício 4'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-5', name: 'Exercício 5'),
        ]);

        // Act
        final groupId = notifier.createExerciseGroup(
          workoutId: 'workout-1',
          exerciseIds: ['ex-1', 'ex-2', 'ex-3', 'ex-4'],
          techniqueType: TechniqueType.giantset,
        );

        // Assert
        expect(groupId, isNotNull);
        final exercises = getExercises();
        final groupedExercises = exercises.where((e) => e.exerciseGroupId == groupId).toList();

        expect(groupedExercises.length, 4);
        expect(groupedExercises.every((e) => e.techniqueType == TechniqueType.giantset), isTrue);
      });

      test('should return null for single exercise group', () {
        // Arrange
        setupWorkoutWithExercises([
          ExerciseGroupFixtures.normalExercise(id: 'ex-1', name: 'Supino'),
        ]);

        // Act
        final groupId = notifier.createExerciseGroup(
          workoutId: 'workout-1',
          exerciseIds: ['ex-1'],
          techniqueType: TechniqueType.superset,
        );

        // Assert
        expect(groupId, isNull);
      });

      test('should generate unique groupId', () async {
        // Arrange
        setupWorkoutWithExercises([
          ExerciseGroupFixtures.normalExercise(id: 'ex-1', name: 'Exercício 1'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-2', name: 'Exercício 2'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-3', name: 'Exercício 3'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-4', name: 'Exercício 4'),
        ]);

        // Act
        final groupId1 = notifier.createExerciseGroup(
          workoutId: 'workout-1',
          exerciseIds: ['ex-1', 'ex-2'],
          techniqueType: TechniqueType.superset,
        );

        // Small delay to ensure different timestamps (millisecond precision)
        await Future.delayed(const Duration(milliseconds: 2));

        final groupId2 = notifier.createExerciseGroup(
          workoutId: 'workout-1',
          exerciseIds: ['ex-3', 'ex-4'],
          techniqueType: TechniqueType.superset,
        );

        // Assert
        expect(groupId1, isNot(equals(groupId2)));
      });

      test('should preserve non-grouped exercises', () {
        // Arrange
        setupWorkoutWithExercises([
          ExerciseGroupFixtures.normalExercise(id: 'ex-1', name: 'Exercício 1'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-2', name: 'Exercício 2'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-3', name: 'Exercício 3'),
        ]);

        // Act
        notifier.createExerciseGroup(
          workoutId: 'workout-1',
          exerciseIds: ['ex-1', 'ex-2'],
          techniqueType: TechniqueType.superset,
        );

        // Assert
        final exercises = getExercises();
        final normalExercise = exercises.firstWhere((e) => e.id == 'ex-3');

        expect(normalExercise.exerciseGroupId, isNull);
        expect(normalExercise.techniqueType, TechniqueType.normal);
      });
    });

    // ============================================
    // REMOVE FROM EXERCISE GROUP TESTS
    // ============================================

    group('removeFromExerciseGroup', () {
      test('should remove exercise from group', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises(superset);

        // Act
        notifier.removeFromExerciseGroup('workout-1', superset[0].id);

        // Assert
        final exercises = getExercises();
        final removedExercise = exercises.firstWhere((e) => e.id == superset[0].id);

        expect(removedExercise.exerciseGroupId, isNull);
        expect(removedExercise.techniqueType, TechniqueType.normal);
        expect(removedExercise.restSeconds, 60); // Reset to default
      });

      test('should auto-disband group when only 1 exercise remains', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises(superset);

        // Act
        notifier.removeFromExerciseGroup('workout-1', superset[0].id);

        // Assert - remaining exercise should also be disbanded
        final exercises = getExercises();
        final remainingExercise = exercises.firstWhere((e) => e.id == superset[1].id);

        expect(remainingExercise.exerciseGroupId, isNull);
        expect(remainingExercise.techniqueType, TechniqueType.normal);
      });

      test('should update technique type when triset becomes superset', () {
        // Arrange
        final triset = ExerciseGroupFixtures.triset(groupId: 'group-1');
        setupWorkoutWithExercises(triset);

        // Act
        notifier.removeFromExerciseGroup('workout-1', triset[0].id);

        // Assert - remaining 2 exercises should now be superset
        final exercises = getExercises();
        final remainingGroupExercises = exercises.where((e) => e.exerciseGroupId == 'group-1').toList();

        expect(remainingGroupExercises.length, 2);
        expect(remainingGroupExercises.every((e) => e.techniqueType == TechniqueType.superset), isTrue);
      });

      test('should update technique type when giantset becomes triset', () {
        // Arrange
        final giantset = ExerciseGroupFixtures.giantset(groupId: 'group-1', count: 4);
        setupWorkoutWithExercises(giantset);

        // Act
        notifier.removeFromExerciseGroup('workout-1', giantset[0].id);

        // Assert - remaining 3 exercises should now be triset
        final exercises = getExercises();
        final remainingGroupExercises = exercises.where((e) => e.exerciseGroupId == 'group-1').toList();

        expect(remainingGroupExercises.length, 3);
        expect(remainingGroupExercises.every((e) => e.techniqueType == TechniqueType.triset), isTrue);
      });

      test('should renumber exerciseGroupOrder after removal', () {
        // Arrange
        final triset = ExerciseGroupFixtures.triset(groupId: 'group-1');
        setupWorkoutWithExercises(triset);

        // Remove the first exercise (order 0)
        notifier.removeFromExerciseGroup('workout-1', triset[0].id);

        // Assert
        final exercises = getExercises();
        final remainingGroupExercises = exercises
            .where((e) => e.exerciseGroupId == 'group-1')
            .toList()
          ..sort((a, b) => a.exerciseGroupOrder.compareTo(b.exerciseGroupOrder));

        expect(remainingGroupExercises[0].exerciseGroupOrder, 0);
        expect(remainingGroupExercises[1].exerciseGroupOrder, 1);
      });
    });

    // ============================================
    // DISBAND EXERCISE GROUP TESTS
    // ============================================

    group('disbandExerciseGroup', () {
      test('should disband all exercises in group', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises(superset);

        // Act
        notifier.disbandExerciseGroup('workout-1', 'group-1');

        // Assert
        final exercises = getExercises();

        expect(exercises.every((e) => e.exerciseGroupId == null), isTrue);
        expect(exercises.every((e) => e.techniqueType == TechniqueType.normal), isTrue);
        expect(exercises.every((e) => e.exerciseGroupOrder == 0), isTrue);
      });

      test('should preserve exercise data when disbanding', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises(superset);
        final originalNames = superset.map((e) => e.name).toList();

        // Act
        notifier.disbandExerciseGroup('workout-1', 'group-1');

        // Assert
        final exercises = getExercises();
        final disbandedNames = exercises.map((e) => e.name).toList();

        expect(disbandedNames, containsAll(originalNames));
      });

      test('should not affect other groups', () {
        // Arrange
        final superset1 = ExerciseGroupFixtures.superset(
          groupId: 'group-1',
          ids: ['ex-1', 'ex-2'],
          names: ['Exercício 1', 'Exercício 2'],
        );
        final superset2 = ExerciseGroupFixtures.superset(
          groupId: 'group-2',
          ids: ['ex-3', 'ex-4'],
          names: ['Exercício 3', 'Exercício 4'],
        );
        setupWorkoutWithExercises([...superset1, ...superset2]);

        // Act
        notifier.disbandExerciseGroup('workout-1', 'group-1');

        // Assert
        final exercises = getExercises();
        final group2Exercises = exercises.where((e) => e.exerciseGroupId == 'group-2').toList();

        expect(group2Exercises.length, 2);
        expect(group2Exercises.every((e) => e.techniqueType == TechniqueType.superset), isTrue);
      });
    });

    // ============================================
    // DELETE EXERCISE GROUP TESTS
    // ============================================

    group('deleteExerciseGroup', () {
      test('should delete all exercises in group', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        final normalExercise = ExerciseGroupFixtures.normalExercise(id: 'normal-1');
        setupWorkoutWithExercises([...superset, normalExercise]);

        // Act
        notifier.deleteExerciseGroup('workout-1', 'group-1');

        // Assert
        final exercises = getExercises();

        expect(exercises.length, 1);
        expect(exercises.first.id, 'normal-1');
      });

      test('should not affect exercises outside the group', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        final normalExercise = ExerciseGroupFixtures.normalExercise(
          id: 'normal-1',
          name: 'Exercício Normal',
        );
        setupWorkoutWithExercises([...superset, normalExercise]);

        // Act
        notifier.deleteExerciseGroup('workout-1', 'group-1');

        // Assert
        final exercises = getExercises();

        expect(exercises.first.name, 'Exercício Normal');
        expect(exercises.first.techniqueType, TechniqueType.normal);
      });

      test('should handle deleting non-existent group gracefully', () {
        // Arrange
        final normalExercise = ExerciseGroupFixtures.normalExercise(id: 'normal-1');
        setupWorkoutWithExercises([normalExercise]);

        // Act - should not throw
        notifier.deleteExerciseGroup('workout-1', 'non-existent-group');

        // Assert
        final exercises = getExercises();
        expect(exercises.length, 1);
      });

      test('should delete giantset completely', () {
        // Arrange
        final giantset = ExerciseGroupFixtures.giantset(groupId: 'group-1', count: 6);
        setupWorkoutWithExercises(giantset);

        // Act
        notifier.deleteExerciseGroup('workout-1', 'group-1');

        // Assert
        final exercises = getExercises();
        expect(exercises.isEmpty, isTrue);
      });
    });

    // ============================================
    // ADD EXERCISE TO GROUP TESTS
    // ============================================

    group('addExerciseToGroup', () {
      test('should add exercise to existing superset', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises(superset);

        final newExercise = ExerciseGroupFixtures.catalogExercise(
          id: 'new-ex',
          name: 'Novo Exercício',
        );

        // Act
        notifier.addExerciseToGroup(
          workoutId: 'workout-1',
          groupId: 'group-1',
          exercise: newExercise,
        );

        // Assert
        final exercises = getExercises();
        final groupExercises = exercises.where((e) => e.exerciseGroupId == 'group-1').toList();

        expect(groupExercises.length, 3);
      });

      test('should update technique type when superset becomes triset', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises(superset);

        final newExercise = ExerciseGroupFixtures.catalogExercise(
          id: 'new-ex',
          name: 'Novo Exercício',
        );

        // Act
        notifier.addExerciseToGroup(
          workoutId: 'workout-1',
          groupId: 'group-1',
          exercise: newExercise,
        );

        // Assert
        final exercises = getExercises();
        final groupExercises = exercises.where((e) => e.exerciseGroupId == 'group-1').toList();

        expect(groupExercises.every((e) => e.techniqueType == TechniqueType.triset), isTrue);
      });

      test('should update technique type when triset becomes giantset', () {
        // Arrange
        final triset = ExerciseGroupFixtures.triset(groupId: 'group-1');
        setupWorkoutWithExercises(triset);

        final newExercise = ExerciseGroupFixtures.catalogExercise(
          id: 'new-ex',
          name: 'Novo Exercício',
        );

        // Act
        notifier.addExerciseToGroup(
          workoutId: 'workout-1',
          groupId: 'group-1',
          exercise: newExercise,
        );

        // Assert
        final exercises = getExercises();
        final groupExercises = exercises.where((e) => e.exerciseGroupId == 'group-1').toList();

        expect(groupExercises.length, 4);
        expect(groupExercises.every((e) => e.techniqueType == TechniqueType.giantset), isTrue);
      });

      test('should assign correct exerciseGroupOrder to new exercise', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises(superset);

        final newExercise = ExerciseGroupFixtures.catalogExercise(
          id: 'new-ex',
          name: 'Novo Exercício',
        );

        // Act
        notifier.addExerciseToGroup(
          workoutId: 'workout-1',
          groupId: 'group-1',
          exercise: newExercise,
        );

        // Assert
        final exercises = getExercises();
        final newGroupExercise = exercises.firstWhere((e) => e.name == 'Novo Exercício');

        expect(newGroupExercise.exerciseGroupOrder, 2); // Was 0 and 1, so new is 2
      });

      test('should set rest to 0 for non-last exercises in group', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises(superset);

        final newExercise = ExerciseGroupFixtures.catalogExercise(
          id: 'new-ex',
          name: 'Novo Exercício',
        );

        // Act
        notifier.addExerciseToGroup(
          workoutId: 'workout-1',
          groupId: 'group-1',
          exercise: newExercise,
        );

        // Assert
        final exercises = getExercises();
        final groupExercises = exercises
            .where((e) => e.exerciseGroupId == 'group-1')
            .toList()
          ..sort((a, b) => a.exerciseGroupOrder.compareTo(b.exerciseGroupOrder));

        // First two should have 0 rest, last should have rest
        expect(groupExercises[0].restSeconds, 0);
        expect(groupExercises[1].restSeconds, 0);
        expect(groupExercises[2].restSeconds, greaterThan(0));
      });

      test('should inherit execution instructions from group', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        // Update instructions on group
        setupWorkoutWithExercises(superset.map((e) =>
          e.copyWith(executionInstructions: 'Instruções do grupo')).toList());

        final newExercise = ExerciseGroupFixtures.catalogExercise(
          id: 'new-ex',
          name: 'Novo Exercício',
        );

        // Act
        notifier.addExerciseToGroup(
          workoutId: 'workout-1',
          groupId: 'group-1',
          exercise: newExercise,
        );

        // Assert
        final exercises = getExercises();
        final newGroupExercise = exercises.firstWhere((e) => e.name == 'Novo Exercício');

        expect(newGroupExercise.executionInstructions, 'Instruções do grupo');
      });

      test('should insert new exercise after last group exercise', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        final normalExercise = ExerciseGroupFixtures.normalExercise(
          id: 'normal-1',
          name: 'Exercício Normal',
        );
        setupWorkoutWithExercises([...superset, normalExercise]);

        final newExercise = ExerciseGroupFixtures.catalogExercise(
          id: 'new-ex',
          name: 'Novo Exercício',
        );

        // Act
        notifier.addExerciseToGroup(
          workoutId: 'workout-1',
          groupId: 'group-1',
          exercise: newExercise,
        );

        // Assert
        final exercises = getExercises();

        // New exercise should be inserted after the superset, before the normal exercise
        expect(exercises[2].name, 'Novo Exercício');
        expect(exercises[3].name, 'Exercício Normal');
      });

      test('should handle adding to non-existent group gracefully', () {
        // Arrange
        final normalExercise = ExerciseGroupFixtures.normalExercise(id: 'normal-1');
        setupWorkoutWithExercises([normalExercise]);

        final newExercise = ExerciseGroupFixtures.catalogExercise(
          id: 'new-ex',
          name: 'Novo Exercício',
        );

        // Act - should not throw
        notifier.addExerciseToGroup(
          workoutId: 'workout-1',
          groupId: 'non-existent-group',
          exercise: newExercise,
        );

        // Assert - no exercise should be added
        final exercises = getExercises();
        expect(exercises.length, 1);
      });
    });

    // ============================================
    // UPDATE GROUP INSTRUCTIONS TESTS
    // ============================================

    group('updateGroupInstructions', () {
      test('should update instructions for all exercises in group', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises(superset);

        // Act
        notifier.updateGroupInstructions(
          workoutId: 'workout-1',
          groupId: 'group-1',
          instructions: 'Novas instruções do grupo',
        );

        // Assert
        final exercises = getExercises();
        final groupExercises = exercises.where((e) => e.exerciseGroupId == 'group-1').toList();

        expect(groupExercises.every((e) => e.executionInstructions == 'Novas instruções do grupo'), isTrue);
      });

      test('should not affect exercises outside the group', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        final normalExercise = ExerciseGroupFixtures.normalExercise(
          id: 'normal-1',
          executionInstructions: 'Instruções originais',
        );
        setupWorkoutWithExercises([...superset, normalExercise]);

        // Act
        notifier.updateGroupInstructions(
          workoutId: 'workout-1',
          groupId: 'group-1',
          instructions: 'Novas instruções',
        );

        // Assert
        final exercises = getExercises();
        final normalEx = exercises.firstWhere((e) => e.id == 'normal-1');

        expect(normalEx.executionInstructions, 'Instruções originais');
      });

      test('should clear instructions when empty string is provided', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises(superset.map((e) =>
          e.copyWith(executionInstructions: 'Instruções antigas')).toList());

        // Act
        notifier.updateGroupInstructions(
          workoutId: 'workout-1',
          groupId: 'group-1',
          instructions: '',
        );

        // Assert
        final exercises = getExercises();
        final groupExercises = exercises.where((e) => e.exerciseGroupId == 'group-1').toList();

        expect(groupExercises.every((e) => e.executionInstructions.isEmpty), isTrue);
      });

      test('should handle non-existent group gracefully', () {
        // Arrange
        final normalExercise = ExerciseGroupFixtures.normalExercise(
          id: 'normal-1',
          executionInstructions: 'Original',
        );
        setupWorkoutWithExercises([normalExercise]);

        // Act - should not throw
        notifier.updateGroupInstructions(
          workoutId: 'workout-1',
          groupId: 'non-existent-group',
          instructions: 'Novas instruções',
        );

        // Assert - original exercise unchanged
        final exercises = getExercises();
        expect(exercises.first.executionInstructions, 'Original');
      });
    });

    // ============================================
    // EDGE CASES AND INTEGRATION TESTS
    // ============================================

    group('Edge Cases', () {
      test('should handle empty workout gracefully', () {
        // Arrange
        setupWorkoutWithExercises([]);

        // Act & Assert - should not throw
        notifier.createExerciseGroup(
          workoutId: 'workout-1',
          exerciseIds: ['ex-1', 'ex-2'],
          techniqueType: TechniqueType.superset,
        );

        notifier.disbandExerciseGroup('workout-1', 'group-1');
        notifier.deleteExerciseGroup('workout-1', 'group-1');

        final exercises = getExercises();
        expect(exercises.isEmpty, isTrue);
      });

      test('should handle wrong workout ID gracefully', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises(superset);

        // Act - using wrong workout ID
        notifier.deleteExerciseGroup('wrong-workout-id', 'group-1');

        // Assert - original exercises should remain
        final exercises = getExercises();
        expect(exercises.length, 2);
      });

      test('should maintain group integrity after multiple operations', () {
        // Arrange
        final triset = ExerciseGroupFixtures.triset(groupId: 'group-1');
        setupWorkoutWithExercises(triset);

        // Act - remove one, add one
        notifier.removeFromExerciseGroup('workout-1', triset[0].id);

        final newExercise = ExerciseGroupFixtures.catalogExercise(
          id: 'new-ex',
          name: 'Novo Exercício',
        );
        notifier.addExerciseToGroup(
          workoutId: 'workout-1',
          groupId: 'group-1',
          exercise: newExercise,
        );

        // Assert - should still have 3 exercises in group
        final exercises = getExercises();
        final groupExercises = exercises.where((e) => e.exerciseGroupId == 'group-1').toList();

        expect(groupExercises.length, 3);
        expect(groupExercises.every((e) => e.techniqueType == TechniqueType.triset), isTrue);
      });

      test('should handle consecutive removals until group disbands', () {
        // Arrange
        final triset = ExerciseGroupFixtures.triset(groupId: 'group-1');
        setupWorkoutWithExercises(triset);

        // Act - remove exercises one by one
        notifier.removeFromExerciseGroup('workout-1', triset[0].id); // 3 -> 2
        notifier.removeFromExerciseGroup('workout-1', triset[1].id); // 2 -> 1 (auto-disband)

        // Assert - all should be normal now
        final exercises = getExercises();

        expect(exercises.every((e) => e.exerciseGroupId == null), isTrue);
        expect(exercises.every((e) => e.techniqueType == TechniqueType.normal), isTrue);
      });
    });

    // ============================================
    // TECHNIQUE-SPECIFIC TESTS
    // ============================================

    group('Single-Exercise Techniques', () {
      test('should not affect dropset when working with groups', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        final dropset = ExerciseGroupFixtures.dropsetExercise(id: 'dropset-1');
        setupWorkoutWithExercises([...superset, dropset]);

        // Act
        notifier.disbandExerciseGroup('workout-1', 'group-1');

        // Assert
        final exercises = getExercises();
        final dropsetEx = exercises.firstWhere((e) => e.id == 'dropset-1');

        expect(dropsetEx.techniqueType, TechniqueType.dropset);
      });

      test('should preserve cluster technique when nearby groups change', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        final cluster = ExerciseGroupFixtures.clusterExercise(id: 'cluster-1');
        setupWorkoutWithExercises([...superset, cluster]);

        // Act
        notifier.deleteExerciseGroup('workout-1', 'group-1');

        // Assert
        final exercises = getExercises();

        expect(exercises.length, 1);
        expect(exercises.first.techniqueType, TechniqueType.cluster);
      });
    });

    // ============================================
    // WORKOUT WITH ALL TECHNIQUES
    // ============================================

    group('Mixed Techniques Workout', () {
      test('should handle workout with all technique types', () {
        // Arrange
        final workout = ExerciseGroupFixtures.workoutWithAllTechniques();
        notifier.setTestWorkouts([workout]);

        // Count exercises by technique
        final exercises = getExercises();
        final normalCount = exercises.where((e) => e.techniqueType == TechniqueType.normal).length;
        final supersetCount = exercises.where((e) => e.techniqueType == TechniqueType.superset).length;
        final trisetCount = exercises.where((e) => e.techniqueType == TechniqueType.triset).length;
        final giantsetCount = exercises.where((e) => e.techniqueType == TechniqueType.giantset).length;
        final dropsetCount = exercises.where((e) => e.techniqueType == TechniqueType.dropset).length;
        final restPauseCount = exercises.where((e) => e.techniqueType == TechniqueType.restPause).length;
        final clusterCount = exercises.where((e) => e.techniqueType == TechniqueType.cluster).length;

        // Assert
        expect(normalCount, greaterThan(0));
        expect(supersetCount, 2); // 2 exercises in superset
        expect(trisetCount, 3); // 3 exercises in triset
        expect(giantsetCount, 4); // 4 exercises in giantset
        expect(dropsetCount, 1);
        expect(restPauseCount, 1);
        expect(clusterCount, 1);
      });

      test('should correctly identify groups in mixed workout', () {
        // Arrange
        final workout = ExerciseGroupFixtures.workoutWithAllTechniques();
        notifier.setTestWorkouts([workout]);

        // Get unique group IDs
        final exercises = getExercises();
        final groupIds = exercises
            .where((e) => e.exerciseGroupId != null)
            .map((e) => e.exerciseGroupId)
            .toSet();

        // Assert - should have 3 groups (superset, triset, giantset)
        expect(groupIds.length, 3);
      });
    });

    // ============================================
    // REORDER EXERCISES TESTS
    // ============================================

    group('reorderExercises', () {
      test('should move single ungrouped exercise up', () {
        // Arrange - 3 ungrouped exercises
        setupWorkoutWithExercises([
          ExerciseGroupFixtures.normalExercise(id: 'ex-1', name: 'Exercício 1'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-2', name: 'Exercício 2'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-3', name: 'Exercício 3'),
        ]);

        // Act - move ex-3 (UI index 2) to position 0
        notifier.reorderExercises('workout-1', 2, 0);

        // Assert
        final exercises = getExercises();
        expect(exercises[0].name, 'Exercício 3');
        expect(exercises[1].name, 'Exercício 1');
        expect(exercises[2].name, 'Exercício 2');
      });

      test('should move single ungrouped exercise down', () {
        // Arrange - 3 ungrouped exercises
        setupWorkoutWithExercises([
          ExerciseGroupFixtures.normalExercise(id: 'ex-1', name: 'Exercício 1'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-2', name: 'Exercício 2'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-3', name: 'Exercício 3'),
        ]);

        // Act - move ex-1 (UI index 0) to position 3 (after last item)
        notifier.reorderExercises('workout-1', 0, 3);

        // Assert
        final exercises = getExercises();
        expect(exercises[0].name, 'Exercício 2');
        expect(exercises[1].name, 'Exercício 3');
        expect(exercises[2].name, 'Exercício 1');
      });

      test('should move single exercise before a group', () {
        // Arrange: [Ex1, Group(Ex2, Ex3), Ex4]
        // UI indices: [0, 1, 2]
        // Data indices: [0, 1, 2, 3]
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises([
          ExerciseGroupFixtures.normalExercise(id: 'ex-1', name: 'Exercício 1'),
          ...superset, // Ex 2 and 3 in group
          ExerciseGroupFixtures.normalExercise(id: 'ex-4', name: 'Exercício 4'),
        ]);

        // Act - move Ex4 (UI index 2) to position 0
        notifier.reorderExercises('workout-1', 2, 0);

        // Assert: [Ex4, Ex1, Group(Ex2, Ex3)]
        final exercises = getExercises();
        expect(exercises[0].name, 'Exercício 4');
        expect(exercises[1].name, 'Exercício 1');
        expect(exercises[2].exerciseGroupId, 'group-1'); // Group still intact
        expect(exercises[3].exerciseGroupId, 'group-1');
      });

      test('should move single exercise after a group', () {
        // Arrange: [Ex1, Group(Ex2, Ex3), Ex4]
        // UI indices: [0, 1, 2]
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises([
          ExerciseGroupFixtures.normalExercise(id: 'ex-1', name: 'Exercício 1'),
          ...superset,
          ExerciseGroupFixtures.normalExercise(id: 'ex-4', name: 'Exercício 4'),
        ]);

        // Act - move Ex1 (UI index 0) to position 2
        notifier.reorderExercises('workout-1', 0, 2);

        // Assert: [Group(Ex2, Ex3), Ex1, Ex4]
        final exercises = getExercises();
        expect(exercises[0].exerciseGroupId, 'group-1');
        expect(exercises[1].exerciseGroupId, 'group-1');
        expect(exercises[2].name, 'Exercício 1');
        expect(exercises[3].name, 'Exercício 4');
      });

      test('should move entire group up as a unit', () {
        // Arrange: [Ex1, Ex2, Group(Ex3, Ex4)]
        // UI indices: [0, 1, 2]
        // Data indices: [0, 1, 2, 3]
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises([
          ExerciseGroupFixtures.normalExercise(id: 'ex-1', name: 'Exercício 1'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-2', name: 'Exercício 2'),
          ...superset, // Group at UI index 2
        ]);

        // Act - move group (UI index 2) to position 0
        notifier.reorderExercises('workout-1', 2, 0);

        // Assert: [Group(Ex3, Ex4), Ex1, Ex2]
        final exercises = getExercises();
        expect(exercises[0].exerciseGroupId, 'group-1');
        expect(exercises[1].exerciseGroupId, 'group-1');
        expect(exercises[2].name, 'Exercício 1');
        expect(exercises[3].name, 'Exercício 2');
      });

      test('should move entire group down as a unit', () {
        // Arrange: [Group(Ex1, Ex2), Ex3, Ex4]
        // UI indices: [0, 1, 2]
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises([
          ...superset, // Group at UI index 0
          ExerciseGroupFixtures.normalExercise(id: 'ex-3', name: 'Exercício 3'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-4', name: 'Exercício 4'),
        ]);

        // Act - move group (UI index 0) to position 3 (end)
        notifier.reorderExercises('workout-1', 0, 3);

        // Assert: [Ex3, Ex4, Group(Ex1, Ex2)]
        final exercises = getExercises();
        expect(exercises[0].name, 'Exercício 3');
        expect(exercises[1].name, 'Exercício 4');
        expect(exercises[2].exerciseGroupId, 'group-1');
        expect(exercises[3].exerciseGroupId, 'group-1');
      });

      test('should handle reorder with multiple groups', () {
        // Arrange: [Group1(A, B), Ex1, Group2(C, D)]
        // UI indices: [0, 1, 2]
        final superset1 = ExerciseGroupFixtures.superset(groupId: 'group-1');
        final superset2 = ExerciseGroupFixtures.superset(groupId: 'group-2');
        // Rename exercises in superset2 for clarity
        final superset2Renamed = superset2.map((e) => e.copyWith(
          name: e.name == 'Supino Reto' ? 'Puxada Frontal' : 'Remada',
        )).toList();

        setupWorkoutWithExercises([
          ...superset1,
          ExerciseGroupFixtures.normalExercise(id: 'ex-1', name: 'Exercício Solo'),
          ...superset2Renamed,
        ]);

        // Act - move Group2 (UI index 2) to position 0
        notifier.reorderExercises('workout-1', 2, 0);

        // Assert: [Group2(C, D), Group1(A, B), Ex1]
        final exercises = getExercises();
        expect(exercises[0].exerciseGroupId, 'group-2');
        expect(exercises[1].exerciseGroupId, 'group-2');
        expect(exercises[2].exerciseGroupId, 'group-1');
        expect(exercises[3].exerciseGroupId, 'group-1');
        expect(exercises[4].name, 'Exercício Solo');
      });

      test('should not change state when moving to same position', () {
        // Arrange
        setupWorkoutWithExercises([
          ExerciseGroupFixtures.normalExercise(id: 'ex-1', name: 'Exercício 1'),
          ExerciseGroupFixtures.normalExercise(id: 'ex-2', name: 'Exercício 2'),
        ]);

        // Act - move ex-1 to same position
        notifier.reorderExercises('workout-1', 0, 0);

        // Assert - order unchanged
        final exercises = getExercises();
        expect(exercises[0].name, 'Exercício 1');
        expect(exercises[1].name, 'Exercício 2');
      });

      test('should handle invalid indices gracefully', () {
        // Arrange
        setupWorkoutWithExercises([
          ExerciseGroupFixtures.normalExercise(id: 'ex-1', name: 'Exercício 1'),
        ]);

        // Act - try to reorder with invalid index
        notifier.reorderExercises('workout-1', 99, 0);

        // Assert - no change
        final exercises = getExercises();
        expect(exercises.length, 1);
        expect(exercises[0].name, 'Exercício 1');
      });
    });

    // ============================================
    // REORDER WITHIN GROUP TESTS
    // ============================================

    group('reorderWithinGroup', () {
      test('should reorder exercises within a superset', () {
        // Arrange - superset with 2 exercises
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises(superset);

        // Get initial names for verification
        final initialFirst = getExercises()[0].name;
        final initialSecond = getExercises()[1].name;

        // Act - swap positions within group
        notifier.reorderWithinGroup('workout-1', 'group-1', 0, 1);

        // Assert
        final exercises = getExercises();
        expect(exercises[0].name, initialSecond);
        expect(exercises[1].name, initialFirst);
        expect(exercises[0].exerciseGroupOrder, 0);
        expect(exercises[1].exerciseGroupOrder, 1);
      });

      test('should reorder exercises within a triset', () {
        // Arrange - triset with 3 exercises
        final triset = ExerciseGroupFixtures.triset(groupId: 'group-1');
        setupWorkoutWithExercises(triset);

        // Act - move third exercise to first position
        notifier.reorderWithinGroup('workout-1', 'group-1', 2, 0);

        // Assert - exerciseGroupOrder should be renumbered
        final exercises = getExercises();
        expect(exercises[0].exerciseGroupOrder, 0);
        expect(exercises[1].exerciseGroupOrder, 1);
        expect(exercises[2].exerciseGroupOrder, 2);
      });

      test('should preserve group integrity after reorder', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        final normalExercise = ExerciseGroupFixtures.normalExercise(id: 'normal-1');
        setupWorkoutWithExercises([...superset, normalExercise]);

        // Act
        notifier.reorderWithinGroup('workout-1', 'group-1', 0, 1);

        // Assert - group exercises still grouped together, normal exercise after
        final exercises = getExercises();
        expect(exercises[0].exerciseGroupId, 'group-1');
        expect(exercises[1].exerciseGroupId, 'group-1');
        expect(exercises[2].exerciseGroupId, isNull);
      });

      test('should handle invalid group order gracefully', () {
        // Arrange
        final superset = ExerciseGroupFixtures.superset(groupId: 'group-1');
        setupWorkoutWithExercises(superset);

        // Act - try with invalid order
        notifier.reorderWithinGroup('workout-1', 'group-1', 0, 99);

        // Assert - no change (order should still be valid)
        final exercises = getExercises();
        expect(exercises.length, 2);
      });

      test('should handle non-existent group gracefully', () {
        // Arrange
        final normalExercise = ExerciseGroupFixtures.normalExercise(id: 'normal-1');
        setupWorkoutWithExercises([normalExercise]);

        // Act - try to reorder in non-existent group
        notifier.reorderWithinGroup('workout-1', 'non-existent', 0, 1);

        // Assert - no change
        final exercises = getExercises();
        expect(exercises.length, 1);
      });
    });
  });
}
