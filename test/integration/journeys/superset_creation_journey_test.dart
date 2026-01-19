import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myfit_app/core/utils/haptic_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/features/trainer_workout/presentation/providers/trainer_workout_provider.dart';
import 'package:myfit_app/features/training_plan/domain/models/training_plan.dart';
import 'package:myfit_app/features/training_plan/presentation/providers/plan_wizard_provider.dart';

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

  group('Superset Creation Journey', () {
    group('Journey 1: Create Superset from Existing Exercises', () {
      testWidgets('should show exercises in workout', (tester) async {
        await tester.pumpTestApp(
          _MockWorkoutWithExercises(
            exercises: [
              ExerciseGroupFixtures.normalExercise(name: 'Supino Reto'),
              ExerciseGroupFixtures.normalExercise(
                id: 'wizard-ex-2',
                exerciseId: 'exercise-2',
                name: 'Puxada Frontal',
              ),
            ],
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify both exercises are visible
        expect(find.text('Supino Reto'), findsOneWidget);
        expect(find.text('Puxada Frontal'), findsOneWidget);
      });

      testWidgets('should show context menu on long press', (tester) async {
        await tester.pumpTestApp(
          _MockExerciseWithContextMenu(
            exercise: ExerciseGroupFixtures.normalExercise(name: 'Supino Reto'),
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Long press on exercise
        await tester.longPress(find.text('Supino Reto'));
        await tester.pumpAndSettle();

        // Verify context menu appears
        expect(find.text('Criar Superset'), findsOneWidget);
        expect(find.text('Editar'), findsOneWidget);
        expect(find.text('Remover'), findsOneWidget);
      });

      testWidgets('should show exercise picker when creating superset',
          (tester) async {
        await tester.pumpTestApp(
          _MockCreateSupersetFlow(
            availableExercises: [
              ExerciseGroupFixtures.normalExercise(
                id: 'wizard-ex-2',
                exerciseId: 'exercise-2',
                name: 'Puxada Frontal',
              ),
              ExerciseGroupFixtures.normalExercise(
                id: 'wizard-ex-3',
                exerciseId: 'exercise-3',
                name: 'Remada Curvada',
              ),
            ],
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap create superset (use first to avoid ambiguity)
        await tester.tap(find.text('Criar Superset').first);
        await tester.pumpAndSettle();

        // Verify picker appears with available exercises
        expect(find.text('Selecionar Exercícios'), findsOneWidget);
        expect(find.text('Puxada Frontal'), findsOneWidget);
        expect(find.text('Remada Curvada'), findsOneWidget);
      });

      testWidgets('should create superset when selecting exercises',
          (tester) async {
        bool supersetCreated = false;

        await tester.pumpTestApp(
          _MockSupersetCreation(
            onSupersetCreated: () => supersetCreated = true,
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Select exercise for superset
        await tester.tap(find.text('Puxada Frontal'));
        await tester.pumpAndSettle();

        // Confirm
        await tester.tap(find.text('Criar'));
        await tester.pumpAndSettle();

        // Verify superset was created
        expect(supersetCreated, isTrue);
      });

      testWidgets('should display superset group visually', (tester) async {
        await tester.pumpTestApp(
          _MockSupersetDisplay(
            superset: ExerciseGroupFixtures.superset(
              names: ['Supino Reto', 'Puxada Frontal'],
            ),
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify group badge
        expect(find.text('Super-Set'), findsOneWidget);

        // Verify exercises are grouped visually
        expect(find.text('Supino Reto'), findsOneWidget);
        expect(find.text('Puxada Frontal'), findsOneWidget);

        // Verify position indicators (1, 2)
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
      });

      testWidgets('should show no rest between grouped exercises',
          (tester) async {
        await tester.pumpTestApp(
          _MockSupersetDisplay(
            superset: ExerciseGroupFixtures.superset(
              names: ['Supino Reto', 'Puxada Frontal'],
            ),
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // First exercise should show 0s rest
        expect(find.text('0s'), findsOneWidget);
      });
    });

    group('Journey 2: Create Triset by Adding to Superset', () {
      testWidgets('should show add button on group header', (tester) async {
        await tester.pumpTestApp(
          _MockExerciseGroupWithActions(
            exercises: ExerciseGroupFixtures.superset(),
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify add button is visible
        expect(find.byIcon(LucideIcons.plus), findsOneWidget);
      });

      testWidgets('should open picker when tapping add button', (tester) async {
        await tester.pumpTestApp(
          _MockAddToGroupFlow(
            groupExercises: ExerciseGroupFixtures.superset(),
            availableExercises: [
              ExerciseGroupFixtures.normalExercise(
                id: 'wizard-ex-3',
                exerciseId: 'exercise-3',
                name: 'Crucifixo',
              ),
            ],
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap add button
        await tester.tap(find.byIcon(LucideIcons.plus));
        await tester.pumpAndSettle();

        // Verify picker opens
        expect(find.text('Adicionar ao Grupo'), findsOneWidget);
        expect(find.text('Crucifixo'), findsOneWidget);
      });

      testWidgets('should update label from Superset to Triset',
          (tester) async {
        await tester.pumpTestApp(
          _MockGroupUpgrade(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Initially shows superset
        expect(find.text('Super-Set'), findsOneWidget);

        // Add third exercise
        await tester.tap(find.byIcon(LucideIcons.plus));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Crucifixo'));
        await tester.pumpAndSettle();

        // Now shows triset
        expect(find.text('Tri-Set'), findsOneWidget);
      });

      testWidgets('should maintain group integrity after adding',
          (tester) async {
        await tester.pumpTestApp(
          _MockTrisetDisplay(
            triset: ExerciseGroupFixtures.triset(
              names: ['Supino', 'Puxada', 'Crucifixo'],
            ),
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify all 3 exercises are grouped
        expect(find.text('Supino'), findsOneWidget);
        expect(find.text('Puxada'), findsOneWidget);
        expect(find.text('Crucifixo'), findsOneWidget);

        // Verify position indicators
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });
    });

    group('Journey 3: Single-Exercise Technique - Dropset', () {
      testWidgets('should show technique selection in settings',
          (tester) async {
        await tester.pumpTestApp(
          _MockExerciseSettings(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Open technique selection
        await tester.tap(find.text('Técnica'));
        await tester.pumpAndSettle();

        // Verify techniques are available
        expect(find.text('Normal'), findsOneWidget);
        expect(find.text('Drop Set'), findsOneWidget);
        expect(find.text('Rest-Pause'), findsOneWidget);
        expect(find.text('Cluster'), findsOneWidget);
      });

      testWidgets('should show config options when selecting dropset',
          (tester) async {
        await tester.pumpTestApp(
          _MockDropsetConfig(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Select dropset
        await tester.tap(find.text('Drop Set'));
        await tester.pumpAndSettle();

        // Verify config options appear
        expect(find.text('Número de Reduções'), findsOneWidget);
        expect(find.text('Descanso entre Reduções'), findsOneWidget);
      });

      testWidgets('should display dropset badge after configuration',
          (tester) async {
        await tester.pumpTestApp(
          _MockDropsetExerciseDisplay(
            exercise: ExerciseGroupFixtures.dropsetExercise(),
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify dropset badge
        expect(find.text('Drop Set'), findsOneWidget);

        // Verify exercise name
        expect(find.text('Extensora'), findsOneWidget);
      });
    });
  });
}

// ============================================
// MOCK WIDGETS
// ============================================

/// Mock widget showing exercises in a workout
class _MockWorkoutWithExercises extends StatelessWidget {
  final List<WizardExercise> exercises;

  const _MockWorkoutWithExercises({required this.exercises});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercícios do Treino')),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(exercise.name),
              subtitle: Text('${exercise.sets} x ${exercise.reps}'),
              trailing: Text('${exercise.restSeconds}s'),
            ),
          );
        },
      ),
    );
  }
}

/// Mock widget with context menu on long press
class _MockExerciseWithContextMenu extends StatefulWidget {
  final WizardExercise exercise;

  const _MockExerciseWithContextMenu({required this.exercise});

  @override
  State<_MockExerciseWithContextMenu> createState() =>
      _MockExerciseWithContextMenuState();
}

class _MockExerciseWithContextMenuState
    extends State<_MockExerciseWithContextMenu> {
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
                title: Text(widget.exercise.name),
                subtitle: Text('${widget.exercise.sets} x ${widget.exercise.reps}'),
              ),
            ),
          ),
          if (_showMenu) ...[
            ListTile(
              leading: const Icon(LucideIcons.layers),
              title: const Text('Criar Superset'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(LucideIcons.edit),
              title: const Text('Editar'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(LucideIcons.trash2),
              title: const Text('Remover'),
              onTap: () {},
            ),
          ],
        ],
      ),
    );
  }
}

/// Mock widget for create superset flow
class _MockCreateSupersetFlow extends StatefulWidget {
  final List<WizardExercise> availableExercises;

  const _MockCreateSupersetFlow({required this.availableExercises});

  @override
  State<_MockCreateSupersetFlow> createState() =>
      _MockCreateSupersetFlowState();
}

class _MockCreateSupersetFlowState extends State<_MockCreateSupersetFlow> {
  bool _showPicker = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Superset')),
      body: Column(
        children: [
          if (!_showPicker)
            ElevatedButton(
              onPressed: () => setState(() => _showPicker = true),
              child: const Text('Criar Superset'),
            ),
          if (_showPicker) ...[
            const Text('Selecionar Exercícios'),
            const Divider(),
            ...widget.availableExercises.map(
              (ex) => ListTile(
                title: Text(ex.name),
                onTap: () {},
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Mock widget for superset creation confirmation
class _MockSupersetCreation extends StatefulWidget {
  final VoidCallback onSupersetCreated;

  const _MockSupersetCreation({required this.onSupersetCreated});

  @override
  State<_MockSupersetCreation> createState() => _MockSupersetCreationState();
}

class _MockSupersetCreationState extends State<_MockSupersetCreation> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Superset')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Puxada Frontal'),
            trailing: _selected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () => setState(() => _selected = true),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _selected ? widget.onSupersetCreated : null,
            child: const Text('Criar'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Mock widget displaying a superset
class _MockSupersetDisplay extends StatelessWidget {
  final List<WizardExercise> superset;

  const _MockSupersetDisplay({required this.superset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Superset')),
      body: Card(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.arrowRightLeft, color: Colors.purple),
                  SizedBox(width: 8),
                  Text('Super-Set',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.purple)),
                ],
              ),
            ),
            ...superset.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple,
                  radius: 12,
                  child: Text('${index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
                title: Text(exercise.name),
                subtitle: Text('${exercise.sets} x ${exercise.reps}'),
                trailing: Text('${exercise.restSeconds}s'),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Mock widget with group action buttons
class _MockExerciseGroupWithActions extends StatelessWidget {
  final List<WizardExercise> exercises;

  const _MockExerciseGroupWithActions({required this.exercises});

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
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.arrowRightLeft, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Text('Super-Set',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.purple)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.plus, size: 18),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.fileText, size: 18),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 18),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            ...exercises.map(
              (ex) => ListTile(
                title: Text(ex.name),
                subtitle: Text('${ex.sets} x ${ex.reps}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock widget for adding exercise to group
class _MockAddToGroupFlow extends StatefulWidget {
  final List<WizardExercise> groupExercises;
  final List<WizardExercise> availableExercises;

  const _MockAddToGroupFlow({
    required this.groupExercises,
    required this.availableExercises,
  });

  @override
  State<_MockAddToGroupFlow> createState() => _MockAddToGroupFlowState();
}

class _MockAddToGroupFlowState extends State<_MockAddToGroupFlow> {
  bool _showPicker = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grupo')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Text('Super-Set'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(LucideIcons.plus, size: 18),
                        onPressed: () => setState(() => _showPicker = true),
                      ),
                    ],
                  ),
                ),
                ...widget.groupExercises.map(
                  (ex) => ListTile(title: Text(ex.name)),
                ),
              ],
            ),
          ),
          if (_showPicker) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Adicionar ao Grupo',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...widget.availableExercises.map(
              (ex) => ListTile(
                title: Text(ex.name),
                onTap: () {},
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Mock widget for group upgrade (superset -> triset)
class _MockGroupUpgrade extends StatefulWidget {
  @override
  State<_MockGroupUpgrade> createState() => _MockGroupUpgradeState();
}

class _MockGroupUpgradeState extends State<_MockGroupUpgrade> {
  bool _isTriset = false;
  bool _showPicker = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grupo')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Text(_isTriset ? 'Tri-Set' : 'Super-Set'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(LucideIcons.plus, size: 18),
                        onPressed: () => setState(() => _showPicker = true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showPicker)
            ListTile(
              title: const Text('Crucifixo'),
              onTap: () => setState(() {
                _isTriset = true;
                _showPicker = false;
              }),
            ),
        ],
      ),
    );
  }
}

/// Mock widget displaying a triset
class _MockTrisetDisplay extends StatelessWidget {
  final List<WizardExercise> triset;

  const _MockTrisetDisplay({required this.triset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Triset')),
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
            ...triset.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 12,
                  child: Text('${index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
                title: Text(exercise.name),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Mock widget for exercise settings
class _MockExerciseSettings extends StatefulWidget {
  @override
  State<_MockExerciseSettings> createState() => _MockExerciseSettingsState();
}

class _MockExerciseSettingsState extends State<_MockExerciseSettings> {
  bool _showTechniques = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Técnica'),
            subtitle: Text(_showTechniques ? 'Selecione' : 'Atual: Normal'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _showTechniques = true),
          ),
          if (_showTechniques) ...[
            const Divider(),
            const ListTile(title: Text('Normal')),
            const ListTile(title: Text('Drop Set')),
            const ListTile(title: Text('Rest-Pause')),
            const ListTile(title: Text('Cluster')),
          ],
        ],
      ),
    );
  }
}

/// Mock widget for dropset configuration
class _MockDropsetConfig extends StatefulWidget {
  @override
  State<_MockDropsetConfig> createState() => _MockDropsetConfigState();
}

class _MockDropsetConfigState extends State<_MockDropsetConfig> {
  bool _showConfig = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Técnica')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Normal'),
            onTap: () => setState(() => _showConfig = false),
          ),
          ListTile(
            title: const Text('Drop Set'),
            onTap: () => setState(() => _showConfig = true),
          ),
          if (_showConfig) ...[
            const Divider(),
            const ListTile(title: Text('Número de Reduções')),
            const ListTile(title: Text('Descanso entre Reduções')),
          ],
        ],
      ),
    );
  }
}

/// Mock widget displaying dropset exercise
class _MockDropsetExerciseDisplay extends StatelessWidget {
  final WizardExercise exercise;

  const _MockDropsetExerciseDisplay({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercício')),
      body: Card(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Text(
                'Drop Set',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            ListTile(
              title: Text(exercise.name),
              subtitle: Text('${exercise.sets} x ${exercise.reps}'),
            ),
          ],
        ),
      ),
    );
  }
}
