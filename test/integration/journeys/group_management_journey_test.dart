import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myfit_app/core/utils/haptic_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/features/trainer_workout/presentation/providers/trainer_workout_provider.dart';
import 'package:myfit_app/features/workout_program/domain/models/workout_program.dart';
import 'package:myfit_app/features/workout_program/presentation/providers/program_wizard_provider.dart';

import '../../helpers/fixtures/exercise_group_fixtures.dart';
import '../../helpers/mock_services.dart';
import '../test_app.dart';

void main() {
  late MockWorkoutService mockWorkoutService;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockWorkoutService = MockWorkoutService();
  });

  List<Override> getOverrides() {
    return [
      workoutServiceProvider.overrideWithValue(mockWorkoutService),
    ];
  }

  group('Group Management Journey', () {
    group('Journey 4: Remove Exercise from Triset', () {
      testWidgets('should display triset with 3 exercises', (tester) async {
        await tester.pumpTestApp(
          _MockTrisetWithRemove(
            triset: ExerciseGroupFixtures.triset(
              names: ['Supino', 'Crucifixo', 'Peck Deck'],
            ),
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify triset label
        expect(find.text('Tri-Set'), findsOneWidget);

        // Verify all 3 exercises
        expect(find.text('Supino'), findsOneWidget);
        expect(find.text('Crucifixo'), findsOneWidget);
        expect(find.text('Peck Deck'), findsOneWidget);
      });

      testWidgets('should show context menu on long press of grouped exercise',
          (tester) async {
        await tester.pumpTestApp(
          _MockGroupedExerciseContextMenu(
            exercise: ExerciseGroupFixtures.triset()[1], // middle exercise
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Long press on exercise
        await tester.longPress(find.text('Crucifixo'));
        await tester.pumpAndSettle();

        // Verify context menu options
        expect(find.text('Remover do Grupo'), findsOneWidget);
        expect(find.text('Editar'), findsOneWidget);
      });

      testWidgets('should remove exercise from group', (tester) async {
        bool exerciseRemoved = false;

        await tester.pumpTestApp(
          _MockRemoveFromGroupFlow(
            onRemoved: () => exerciseRemoved = true,
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Long press to show menu
        await tester.longPress(find.text('Crucifixo'));
        await tester.pumpAndSettle();

        // Tap remove
        await tester.tap(find.text('Remover do Grupo'));
        await tester.pumpAndSettle();

        expect(exerciseRemoved, isTrue);
      });

      testWidgets('should update group type when removing (triset -> superset)',
          (tester) async {
        await tester.pumpTestApp(
          _MockGroupDowngrade(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Initially shows triset
        expect(find.text('Tri-Set'), findsOneWidget);

        // Remove middle exercise
        await tester.longPress(find.text('Crucifixo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Remover do Grupo'));
        await tester.pumpAndSettle();

        // Now shows superset
        expect(find.text('Super-Set'), findsOneWidget);
        expect(find.text('Crucifixo'), findsNothing);
      });

      testWidgets('removed exercise should become normal', (tester) async {
        await tester.pumpTestApp(
          _MockRemovedExerciseBecomesNormal(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify there's a grouped section and a normal section
        expect(find.text('Super-Set'), findsOneWidget);
        expect(find.text('Exercício Normal'), findsOneWidget);
      });

      testWidgets('should renumber positions after removal', (tester) async {
        await tester.pumpTestApp(
          _MockPositionRenumbering(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Remove middle exercise
        await tester.tap(find.text('Remover Exercício 2'));
        await tester.pumpAndSettle();

        // Verify positions are renumbered (1, 2 instead of 1, 3)
        expect(find.text('Posição: 1'), findsOneWidget);
        expect(find.text('Posição: 2'), findsOneWidget);
        expect(find.text('Posição: 3'), findsNothing);
      });
    });

    group('Journey 5: Disband Group', () {
      testWidgets('should show disband option in group menu', (tester) async {
        await tester.pumpTestApp(
          _MockGroupWithMenu(
            exercises: ExerciseGroupFixtures.superset(),
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap group menu
        await tester.tap(find.byIcon(LucideIcons.moreVertical));
        await tester.pumpAndSettle();

        // Verify disband option
        expect(find.text('Desbandar Grupo'), findsOneWidget);
      });

      testWidgets('should show confirmation dialog when disbanding',
          (tester) async {
        await tester.pumpTestApp(
          _MockDisbandConfirmation(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Open menu and tap disband
        await tester.tap(find.byIcon(LucideIcons.unlink));
        await tester.pumpAndSettle();

        // Verify confirmation dialog
        expect(find.text('Desbandar Grupo?'), findsOneWidget);
        expect(
          find.text(
              'Todos os exercícios voltarão a ser exercícios individuais.'),
          findsOneWidget,
        );
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Desbandar'), findsOneWidget);
      });

      testWidgets('should disband group on confirmation', (tester) async {
        bool disbanded = false;

        await tester.pumpTestApp(
          _MockDisbandFlow(onDisbanded: () => disbanded = true),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap disband button
        await tester.tap(find.byIcon(LucideIcons.unlink));
        await tester.pumpAndSettle();

        // Confirm
        await tester.tap(find.text('Desbandar'));
        await tester.pumpAndSettle();

        expect(disbanded, isTrue);
      });

      testWidgets('all exercises should become normal after disband',
          (tester) async {
        await tester.pumpTestApp(
          _MockDisbandedExercises(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Initially shows superset
        expect(find.text('Super-Set'), findsOneWidget);

        // Disband
        await tester.tap(find.byIcon(LucideIcons.unlink));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Desbandar'));
        await tester.pumpAndSettle();

        // Now shows normal exercises
        expect(find.text('Super-Set'), findsNothing);
        expect(find.text('Exercício 1'), findsOneWidget);
        expect(find.text('Exercício 2'), findsOneWidget);
        expect(find.byIcon(LucideIcons.dumbbell), findsNWidgets(2));
      });
    });

    group('Journey 6: Delete Entire Group', () {
      testWidgets('should show delete option in group menu', (tester) async {
        await tester.pumpTestApp(
          _MockGroupWithMenu(
            exercises: ExerciseGroupFixtures.superset(),
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap group menu
        await tester.tap(find.byIcon(LucideIcons.moreVertical));
        await tester.pumpAndSettle();

        // Verify delete option
        expect(find.text('Excluir Grupo'), findsOneWidget);
      });

      testWidgets('should show confirmation dialog when deleting',
          (tester) async {
        await tester.pumpTestApp(
          _MockDeleteGroupConfirmation(
            exercises: ExerciseGroupFixtures.superset(),
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap delete button
        await tester.tap(find.byIcon(LucideIcons.trash2));
        await tester.pumpAndSettle();

        // Verify confirmation dialog
        expect(find.text('Excluir Grupo?'), findsOneWidget);
        expect(
          find.text('2 exercícios serão removidos do treino.'),
          findsOneWidget,
        );
      });

      testWidgets('should delete all exercises in group', (tester) async {
        bool deleted = false;

        await tester.pumpTestApp(
          _MockDeleteGroupFlow(onDeleted: () => deleted = true),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap delete
        await tester.tap(find.byIcon(LucideIcons.trash2));
        await tester.pumpAndSettle();

        // Confirm
        await tester.tap(find.text('Excluir'));
        await tester.pumpAndSettle();

        expect(deleted, isTrue);
      });

      testWidgets('should show empty state after deleting group',
          (tester) async {
        await tester.pumpTestApp(
          _MockDeleteGroupResult(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Initially shows group
        expect(find.text('Super-Set'), findsOneWidget);

        // Delete group
        await tester.tap(find.byIcon(LucideIcons.trash2));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Excluir'));
        await tester.pumpAndSettle();

        // Group is gone
        expect(find.text('Super-Set'), findsNothing);
        expect(find.text('Nenhum exercício'), findsOneWidget);
      });
    });

    group('Journey 7: Edit Group Instructions', () {
      testWidgets('should show edit instructions button', (tester) async {
        await tester.pumpTestApp(
          _MockGroupWithMenu(
            exercises: ExerciseGroupFixtures.superset(),
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap group menu
        await tester.tap(find.byIcon(LucideIcons.moreVertical));
        await tester.pumpAndSettle();

        // Verify edit instructions option
        expect(find.text('Editar Instruções'), findsOneWidget);
      });

      testWidgets('should open instructions dialog', (tester) async {
        await tester.pumpTestApp(
          _MockEditInstructionsDialog(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap edit instructions
        await tester.tap(find.byIcon(LucideIcons.fileText));
        await tester.pumpAndSettle();

        // Verify dialog
        expect(find.text('Instruções do Grupo'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('should save instructions', (tester) async {
        String? savedInstructions;

        await tester.pumpTestApp(
          _MockSaveInstructions(
            onSave: (instructions) => savedInstructions = instructions,
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Enter instructions
        await tester.enterText(
          find.byType(TextField),
          'Execução lenta, 3s na excêntrica',
        );
        await tester.pumpAndSettle();

        // Save
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        expect(savedInstructions, equals('Execução lenta, 3s na excêntrica'));
      });
    });

    group('Edge Cases', () {
      testWidgets('should auto-disband when only 1 exercise remains',
          (tester) async {
        await tester.pumpTestApp(
          _MockAutoDisband(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Initially superset with 2 exercises
        expect(find.text('Super-Set'), findsOneWidget);

        // Remove one exercise
        await tester.tap(find.text('Remover Exercício 1'));
        await tester.pumpAndSettle();

        // Group should be automatically disbanded
        expect(find.text('Super-Set'), findsNothing);
        expect(find.text('Exercício convertido para normal'), findsOneWidget);
      });

      testWidgets('should block adding more than 8 exercises to giantset',
          (tester) async {
        await tester.pumpTestApp(
          _MockMaxGroupSize(
            giantset: ExerciseGroupFixtures.maxSizeGiantset(),
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify giantset with 8 exercises
        expect(find.text('Giant Set'), findsOneWidget);
        expect(find.text('8 exercícios'), findsOneWidget);

        // Try to add another
        await tester.tap(find.byIcon(LucideIcons.plus));
        await tester.pumpAndSettle();

        // Should show warning
        expect(find.text('Máximo de 8 exercícios por grupo'), findsOneWidget);
      });

      testWidgets('should preserve exercise order after group operations',
          (tester) async {
        await tester.pumpTestApp(
          _MockOrderPreservation(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify order: Exercise 1, Exercise 2, Exercise 3
        final texts = find.byType(Text);
        final orderedTexts = texts.evaluate().map((e) {
          final widget = e.widget as Text;
          return widget.data;
        }).where((t) => t != null && t.startsWith('Exercício')).toList();

        expect(orderedTexts, ['Exercício 1', 'Exercício 2', 'Exercício 3']);
      });
    });
  });
}

// ============================================
// MOCK WIDGETS
// ============================================

/// Mock triset with remove capability
class _MockTrisetWithRemove extends StatelessWidget {
  final List<WizardExercise> triset;

  const _MockTrisetWithRemove({required this.triset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Treino')),
      body: Card(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.triangle, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Tri-Set',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
            ),
            ...triset.map((ex) => ListTile(title: Text(ex.name))),
          ],
        ),
      ),
    );
  }
}

/// Mock grouped exercise with context menu
class _MockGroupedExerciseContextMenu extends StatefulWidget {
  final WizardExercise exercise;

  const _MockGroupedExerciseContextMenu({required this.exercise});

  @override
  State<_MockGroupedExerciseContextMenu> createState() =>
      _MockGroupedExerciseContextMenuState();
}

class _MockGroupedExerciseContextMenuState
    extends State<_MockGroupedExerciseContextMenu> {
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercício')),
      body: Column(
        children: [
          GestureDetector(
            onLongPress: () {
              HapticUtils.mediumImpact();
              setState(() => _showMenu = true);
            },
            child: Card(
              margin: const EdgeInsets.all(16),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text('2', style: TextStyle(color: Colors.white)),
                ),
                title: Text(widget.exercise.name),
              ),
            ),
          ),
          if (_showMenu) ...[
            ListTile(
              leading: const Icon(LucideIcons.unlink),
              title: const Text('Remover do Grupo'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(LucideIcons.edit),
              title: const Text('Editar'),
              onTap: () {},
            ),
          ],
        ],
      ),
    );
  }
}

/// Mock remove from group flow
class _MockRemoveFromGroupFlow extends StatefulWidget {
  final VoidCallback onRemoved;

  const _MockRemoveFromGroupFlow({required this.onRemoved});

  @override
  State<_MockRemoveFromGroupFlow> createState() =>
      _MockRemoveFromGroupFlowState();
}

class _MockRemoveFromGroupFlowState extends State<_MockRemoveFromGroupFlow> {
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remover')),
      body: Column(
        children: [
          GestureDetector(
            onLongPress: () => setState(() => _showMenu = true),
            child: const Card(
              margin: EdgeInsets.all(16),
              child: ListTile(title: Text('Crucifixo')),
            ),
          ),
          if (_showMenu)
            ListTile(
              title: const Text('Remover do Grupo'),
              onTap: widget.onRemoved,
            ),
        ],
      ),
    );
  }
}

/// Mock group downgrade (triset -> superset)
class _MockGroupDowngrade extends StatefulWidget {
  @override
  State<_MockGroupDowngrade> createState() => _MockGroupDowngradeState();
}

class _MockGroupDowngradeState extends State<_MockGroupDowngrade> {
  bool _isSuperset = false;
  bool _showMenu = false;
  List<String> exercises = ['Supino', 'Crucifixo', 'Peck Deck'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grupo')),
      body: Card(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                _isSuperset ? 'Super-Set' : 'Tri-Set',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...exercises.map((name) => GestureDetector(
                  onLongPress: () => setState(() => _showMenu = true),
                  child: ListTile(title: Text(name)),
                )),
            if (_showMenu)
              ListTile(
                title: const Text('Remover do Grupo'),
                onTap: () => setState(() {
                  exercises.remove('Crucifixo');
                  _isSuperset = true;
                  _showMenu = false;
                }),
              ),
          ],
        ),
      ),
    );
  }
}

/// Mock removed exercise becomes normal
class _MockRemovedExerciseBecomesNormal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Treino')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.purple.withValues(alpha: 0.1),
                  child: const Text('Super-Set',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const ListTile(title: Text('Supino')),
                const ListTile(title: Text('Peck Deck')),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: const ListTile(
              leading: Icon(LucideIcons.dumbbell),
              title: Text('Exercício Normal'),
              subtitle: Text('Crucifixo'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mock position renumbering
class _MockPositionRenumbering extends StatefulWidget {
  @override
  State<_MockPositionRenumbering> createState() =>
      _MockPositionRenumberingState();
}

class _MockPositionRenumberingState extends State<_MockPositionRenumbering> {
  List<int> positions = [1, 2, 3];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posições')),
      body: Column(
        children: [
          ...positions.map((pos) => ListTile(
                title: Text('Exercício $pos'),
                subtitle: Text('Posição: $pos'),
                trailing: TextButton(
                  onPressed: () => setState(() {
                    positions.remove(pos);
                    // Renumber
                    positions =
                        List.generate(positions.length, (i) => i + 1);
                  }),
                  child: Text('Remover Exercício $pos'),
                ),
              )),
        ],
      ),
    );
  }
}

/// Mock group with menu
class _MockGroupWithMenu extends StatefulWidget {
  final List<WizardExercise> exercises;

  const _MockGroupWithMenu({required this.exercises});

  @override
  State<_MockGroupWithMenu> createState() => _MockGroupWithMenuState();
}

class _MockGroupWithMenuState extends State<_MockGroupWithMenu> {
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grupo')),
      body: Card(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Text('Super-Set',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.moreVertical),
                    onPressed: () => setState(() => _showMenu = !_showMenu),
                  ),
                ],
              ),
            ),
            if (_showMenu) ...[
              const ListTile(title: Text('Editar Instruções')),
              const ListTile(title: Text('Desbandar Grupo')),
              const ListTile(title: Text('Excluir Grupo')),
            ],
            ...widget.exercises.map((ex) => ListTile(title: Text(ex.name))),
          ],
        ),
      ),
    );
  }
}

/// Mock disband confirmation
class _MockDisbandConfirmation extends StatefulWidget {
  @override
  State<_MockDisbandConfirmation> createState() =>
      _MockDisbandConfirmationState();
}

class _MockDisbandConfirmationState extends State<_MockDisbandConfirmation> {
  bool _showDialog = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grupo')),
      body: Stack(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Super-Set'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(LucideIcons.unlink),
                      onPressed: () => setState(() => _showDialog = true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_showDialog)
            AlertDialog(
              title: const Text('Desbandar Grupo?'),
              content: const Text(
                  'Todos os exercícios voltarão a ser exercícios individuais.'),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _showDialog = false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Desbandar'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Mock disband flow
class _MockDisbandFlow extends StatefulWidget {
  final VoidCallback onDisbanded;

  const _MockDisbandFlow({required this.onDisbanded});

  @override
  State<_MockDisbandFlow> createState() => _MockDisbandFlowState();
}

class _MockDisbandFlowState extends State<_MockDisbandFlow> {
  bool _showDialog = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Ação')),
      body: Stack(
        children: [
          Center(
            child: IconButton(
              icon: const Icon(LucideIcons.unlink),
              onPressed: () => setState(() => _showDialog = true),
            ),
          ),
          if (_showDialog)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Confirmar?'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () =>
                                setState(() => _showDialog = false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: widget.onDisbanded,
                            child: const Text('Desbandar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Mock disbanded exercises display
class _MockDisbandedExercises extends StatefulWidget {
  @override
  State<_MockDisbandedExercises> createState() =>
      _MockDisbandedExercisesState();
}

class _MockDisbandedExercisesState extends State<_MockDisbandedExercises> {
  bool _isDisbanded = false;
  bool _showDialog = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercícios')),
      body: Stack(
        children: [
          if (!_isDisbanded)
            Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Super-Set'),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(LucideIcons.unlink),
                        onPressed: () => setState(() => _showDialog = true),
                      ),
                    ],
                  ),
                  const ListTile(title: Text('Exercício 1')),
                  const ListTile(title: Text('Exercício 2')),
                ],
              ),
            )
          else
            Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: ListTile(
                    leading: const Icon(LucideIcons.dumbbell),
                    title: const Text('Exercício 1'),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListTile(
                    leading: const Icon(LucideIcons.dumbbell),
                    title: const Text('Exercício 2'),
                  ),
                ),
              ],
            ),
          if (_showDialog)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Desbandar?'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _isDisbanded = true;
                          _showDialog = false;
                        }),
                        child: const Text('Desbandar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Mock delete group confirmation
class _MockDeleteGroupConfirmation extends StatefulWidget {
  final List<WizardExercise> exercises;

  const _MockDeleteGroupConfirmation({required this.exercises});

  @override
  State<_MockDeleteGroupConfirmation> createState() =>
      _MockDeleteGroupConfirmationState();
}

class _MockDeleteGroupConfirmationState
    extends State<_MockDeleteGroupConfirmation> {
  bool _showDialog = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Excluir')),
      body: Stack(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Super-Set'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2),
                      onPressed: () => setState(() => _showDialog = true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_showDialog)
            AlertDialog(
              title: const Text('Excluir Grupo?'),
              content:
                  Text('${widget.exercises.length} exercícios serão removidos do treino.'),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _showDialog = false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Excluir'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Mock delete group flow
class _MockDeleteGroupFlow extends StatefulWidget {
  final VoidCallback onDeleted;

  const _MockDeleteGroupFlow({required this.onDeleted});

  @override
  State<_MockDeleteGroupFlow> createState() => _MockDeleteGroupFlowState();
}

class _MockDeleteGroupFlowState extends State<_MockDeleteGroupFlow> {
  bool _showDialog = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Exclusão')),
      body: Stack(
        children: [
          Center(
            child: IconButton(
              icon: const Icon(LucideIcons.trash2),
              onPressed: () => setState(() => _showDialog = true),
            ),
          ),
          if (_showDialog)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Confirmar exclusão?'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: widget.onDeleted,
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Mock delete group result (empty state)
class _MockDeleteGroupResult extends StatefulWidget {
  @override
  State<_MockDeleteGroupResult> createState() => _MockDeleteGroupResultState();
}

class _MockDeleteGroupResultState extends State<_MockDeleteGroupResult> {
  bool _deleted = false;
  bool _showDialog = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Treino')),
      body: Stack(
        children: [
          if (!_deleted)
            Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Super-Set'),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2),
                        onPressed: () => setState(() => _showDialog = true),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.inbox, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhum exercício'),
                ],
              ),
            ),
          if (_showDialog)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      _deleted = true;
                      _showDialog = false;
                    }),
                    child: const Text('Excluir'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Mock edit instructions dialog
class _MockEditInstructionsDialog extends StatefulWidget {
  @override
  State<_MockEditInstructionsDialog> createState() =>
      _MockEditInstructionsDialogState();
}

class _MockEditInstructionsDialogState
    extends State<_MockEditInstructionsDialog> {
  bool _showDialog = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instruções')),
      body: Stack(
        children: [
          Center(
            child: IconButton(
              icon: const Icon(LucideIcons.fileText),
              onPressed: () => setState(() => _showDialog = true),
            ),
          ),
          if (_showDialog)
            AlertDialog(
              title: const Text('Instruções do Grupo'),
              content: const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Digite as instruções...',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _showDialog = false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Salvar'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Mock save instructions
class _MockSaveInstructions extends StatelessWidget {
  final void Function(String) onSave;

  const _MockSaveInstructions({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Instruções')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onSave(controller.text),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock auto-disband when only 1 exercise remains
class _MockAutoDisband extends StatefulWidget {
  @override
  State<_MockAutoDisband> createState() => _MockAutoDisbandState();
}

class _MockAutoDisbandState extends State<_MockAutoDisband> {
  bool _autoDisbanded = false;
  List<String> exercises = ['Exercício 1', 'Exercício 2'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Disband')),
      body: Column(
        children: [
          if (!_autoDisbanded)
            Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Super-Set'),
                  ),
                  ...exercises.map((name) => ListTile(
                        title: Text(name),
                        trailing: TextButton(
                          onPressed: () => setState(() {
                            exercises.remove(name);
                            if (exercises.length == 1) {
                              _autoDisbanded = true;
                            }
                          }),
                          child: Text('Remover Exercício'),
                        ),
                      )),
                ],
              ),
            )
          else
            const Card(
              margin: EdgeInsets.all(16),
              child: ListTile(
                title: Text('Exercício 2'),
                subtitle: Text('Exercício convertido para normal'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Mock max group size (8 exercises)
class _MockMaxGroupSize extends StatefulWidget {
  final List<WizardExercise> giantset;

  const _MockMaxGroupSize({required this.giantset});

  @override
  State<_MockMaxGroupSize> createState() => _MockMaxGroupSizeState();
}

class _MockMaxGroupSizeState extends State<_MockMaxGroupSize> {
  bool _showWarning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grupo Máximo')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Giant Set'),
                    ),
                    const Spacer(),
                    Text('${widget.giantset.length} exercicios'),
                    IconButton(
                      icon: const Icon(LucideIcons.plus),
                      onPressed: () => setState(() => _showWarning = true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_showWarning)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.alertTriangle, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Máximo de 8 exercícios por grupo'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Mock order preservation
class _MockOrderPreservation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ordem')),
      body: ListView(
        children: const [
          ListTile(title: Text('Exercício 1')),
          ListTile(title: Text('Exercício 2')),
          ListTile(title: Text('Exercício 3')),
        ],
      ),
    );
  }
}
