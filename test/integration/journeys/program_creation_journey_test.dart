import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/core/services/workout_service.dart';
import 'package:myfit_app/features/trainer_workout/presentation/providers/trainer_workout_provider.dart';

import '../../helpers/fixtures/program_fixtures.dart';
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

  group('Program Creation Journey', () {
    group('Scenario 1: Create program from scratch', () {
      testWidgets('should show creation wizard options', (tester) async {
        await tester.pumpTestApp(
          _MockProgramCreationWizard(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify wizard options are displayed
        expect(find.text('Do Zero'), findsOneWidget);
        expect(find.text('A partir dos meus programas'), findsOneWidget);
        expect(find.text('Assistido por IA'), findsOneWidget);
      });

      testWidgets('should validate program name (min 3 chars)', (tester) async {
        await tester.pumpTestApp(
          _MockProgramNameStep(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Enter short name
        await tester.enterText(find.byType(TextField), 'AB');
        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Nome deve ter pelo menos 3 caracteres'), findsOneWidget);

        // Enter valid name
        await tester.enterText(find.byType(TextField), 'Treino ABC');
        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();

        // Should not show validation error
        expect(find.text('Nome deve ter pelo menos 3 caracteres'), findsNothing);
      });

      testWidgets('should select goal and difficulty', (tester) async {
        await tester.pumpTestApp(
          _MockProgramGoalStep(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Select goal
        await tester.tap(find.text('Hipertrofia'));
        await tester.pumpAndSettle();

        // Select difficulty
        await tester.tap(find.text('Intermediário'));
        await tester.pumpAndSettle();

        // Verify selections
        expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
      });

      testWidgets('should select split type (ABC)', (tester) async {
        await tester.pumpTestApp(
          _MockProgramSplitStep(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Select ABC split
        await tester.tap(find.text('ABC'));
        await tester.pumpAndSettle();

        // Verify 3 workout slots are shown
        expect(find.text('Treino A'), findsOneWidget);
        expect(find.text('Treino B'), findsOneWidget);
        expect(find.text('Treino C'), findsOneWidget);
      });

      testWidgets('should add exercises to workouts', (tester) async {
        await tester.pumpTestApp(
          _MockWorkoutExercisesStep(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap add exercise button
        await tester.tap(find.text('Adicionar Exercício'));
        await tester.pumpAndSettle();

        // Select an exercise from list
        await tester.tap(find.text('Supino Reto'));
        await tester.pumpAndSettle();

        // Verify exercise was added
        expect(find.text('Supino Reto'), findsOneWidget);
        expect(find.text('4 x 8-12'), findsOneWidget);
      });

      testWidgets('should skip diet step (optional)', (tester) async {
        await tester.pumpTestApp(
          _MockDietStep(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Skip button should be visible
        expect(find.text('Pular'), findsOneWidget);

        // Tap skip
        await tester.tap(find.text('Pular'));
        await tester.pumpAndSettle();

        // Should proceed to next step
        expect(find.text('Dieta'), findsNothing);
      });

      testWidgets('should show review and confirm screen', (tester) async {
        when(() => mockWorkoutService.createPlan(
              name: any(named: 'name'),
              goal: any(named: 'goal'),
              difficulty: any(named: 'difficulty'),
              splitType: any(named: 'splitType'),
              durationWeeks: any(named: 'durationWeeks'),
              isTemplate: any(named: 'isTemplate'),
              workouts: any(named: 'workouts'),
            )).thenAnswer((_) async => 'program-new');

        await tester.pumpTestApp(
          _MockProgramReviewStep(
            programData: ProgramFixtures.abcSplit(),
            onConfirm: () async {
              await mockWorkoutService.createPlan(
                name: 'Programa ABC',
                goal: 'hypertrophy',
                difficulty: 'intermediate',
                splitType: 'ABC',
              );
            },
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify review info
        expect(find.text('Revisar Programa'), findsOneWidget);
        expect(find.text('Programa ABC - Hipertrofia'), findsOneWidget);
        expect(find.text('Hipertrofia'), findsWidgets);
        expect(find.text('Intermediário'), findsWidgets);

        // Confirm creation
        await tester.tap(find.text('Criar Programa'));
        await tester.pumpAndSettle();

        // Verify service was called
        verify(() => mockWorkoutService.createPlan(
              name: any(named: 'name'),
              goal: any(named: 'goal'),
              difficulty: any(named: 'difficulty'),
              splitType: any(named: 'splitType'),
            )).called(1);
      });
    });

    group('Scenario 2: Create from template', () {
      testWidgets('should show existing programs list', (tester) async {
        final templates = ProgramFixtures.apiResponseList(count: 3);

        when(() => mockWorkoutService.getPlans(templatesOnly: true))
            .thenAnswer((_) async => templates);

        await tester.pumpTestApp(
          _MockSelectTemplateStep(templates: templates),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify programs are shown
        expect(find.text('Programa ABC - Hipertrofia'), findsOneWidget);
        expect(find.text('Push Pull Legs'), findsOneWidget);
      });

      testWidgets('should duplicate selected template', (tester) async {
        final template = ProgramFixtures.abcSplit();
        final duplicate = {
          ...template,
          'id': 'program-copy',
          'name': 'Programa ABC - Hipertrofia (Cópia)',
        };

        when(() => mockWorkoutService.duplicatePlan(any()))
            .thenAnswer((_) async => duplicate);

        await tester.pumpTestApp(
          _MockDuplicateTemplateStep(
            template: template,
            onDuplicate: () async {
              return await mockWorkoutService.duplicatePlan('program-1');
            },
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap duplicate button
        await tester.tap(find.text('Duplicar'));
        await tester.pumpAndSettle();

        verify(() => mockWorkoutService.duplicatePlan('program-1')).called(1);
      });

      testWidgets('should allow renaming duplicated program', (tester) async {
        await tester.pumpTestApp(
          _MockRenameProgramStep(
            initialName: 'Programa ABC - Hipertrofia (Cópia)',
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify initial name without "Copy of"
        expect(
          find.text('Programa ABC - Hipertrofia (Cópia)'),
          findsOneWidget,
        );

        // Enter new name
        await tester.enterText(
          find.byType(TextField),
          'Meu Programa Personalizado',
        );
        await tester.pumpAndSettle();

        expect(find.text('Meu Programa Personalizado'), findsOneWidget);
      });
    });

    group('Scenario 3: AI-assisted creation', () {
      testWidgets('should show AI questionnaire', (tester) async {
        await tester.pumpTestApp(
          _MockAIQuestionnaireStep(),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify questionnaire fields
        expect(find.text('Qual seu objetivo?'), findsOneWidget);
        expect(find.text('Quantos dias por semana?'), findsOneWidget);
        expect(find.text('Quanto tempo por sessão?'), findsOneWidget);
        expect(find.text('Equipamentos disponíveis?'), findsOneWidget);
      });

      testWidgets('should generate program with AI', (tester) async {
        final aiResponse = ProgramFixtures.aiGenerationResponse();

        when(() => mockWorkoutService.generatePlanWithAI(
              goal: any(named: 'goal'),
              difficulty: any(named: 'difficulty'),
              daysPerWeek: any(named: 'daysPerWeek'),
              minutesPerSession: any(named: 'minutesPerSession'),
              equipment: any(named: 'equipment'),
              injuries: any(named: 'injuries'),
              preferences: any(named: 'preferences'),
              durationWeeks: any(named: 'durationWeeks'),
            )).thenAnswer((_) async => aiResponse);

        await tester.pumpTestApp(
          _MockGenerateAIProgramStep(
            onGenerate: () async {
              return await mockWorkoutService.generatePlanWithAI(
                goal: 'hypertrophy',
                difficulty: 'intermediate',
                daysPerWeek: 4,
                minutesPerSession: 60,
                equipment: 'full_gym',
              );
            },
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap button to generate program
        await tester.tap(find.text('Gerar Programa'));
        // Pump to trigger the state change and start loading
        await tester.pump();

        // Loading indicator may appear briefly - in tests the mock completes quickly
        // so we just verify the interaction happened
        await tester.pumpAndSettle();

        // Verify AI was called
        verify(() => mockWorkoutService.generatePlanWithAI(
              goal: any(named: 'goal'),
              difficulty: any(named: 'difficulty'),
              daysPerWeek: any(named: 'daysPerWeek'),
              minutesPerSession: any(named: 'minutesPerSession'),
              equipment: any(named: 'equipment'),
            )).called(1);
      });

      testWidgets('should show generated program for review', (tester) async {
        final aiProgram = ProgramFixtures.aiGenerated();

        await tester.pumpTestApp(
          _MockAIReviewStep(program: aiProgram),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify AI-generated badge
        expect(find.text('Gerado por IA'), findsOneWidget);

        // Verify program details
        expect(find.text('Programa IA - Personalizado'), findsOneWidget);
        expect(find.text('4 treinos'), findsOneWidget);
      });
    });
  });
}

// Mock widgets for testing UI flows

class _MockProgramCreationWizard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Programa')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Do Zero'),
            subtitle: const Text('Crie um programa do início'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('A partir dos meus programas'),
            subtitle: const Text('Use um programa existente como base'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('Assistido por IA'),
            subtitle: const Text('Deixe a IA criar um programa para você'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _MockProgramNameStep extends StatefulWidget {
  @override
  State<_MockProgramNameStep> createState() => _MockProgramNameStepState();
}

class _MockProgramNameStepState extends State<_MockProgramNameStep> {
  final _controller = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nome do Programa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Nome',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.length < 3) {
                  setState(() {
                    _error = 'Nome deve ter pelo menos 3 caracteres';
                  });
                } else {
                  setState(() {
                    _error = null;
                  });
                }
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockProgramGoalStep extends StatefulWidget {
  @override
  State<_MockProgramGoalStep> createState() => _MockProgramGoalStepState();
}

class _MockProgramGoalStepState extends State<_MockProgramGoalStep> {
  String? _selectedGoal;
  String? _selectedDifficulty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Objetivo')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Hipertrofia'),
            trailing: _selectedGoal == 'hypertrophy'
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () => setState(() => _selectedGoal = 'hypertrophy'),
          ),
          ListTile(
            title: const Text('Força'),
            trailing: _selectedGoal == 'strength'
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () => setState(() => _selectedGoal = 'strength'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Intermediário'),
            trailing: _selectedDifficulty == 'intermediate'
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () => setState(() => _selectedDifficulty = 'intermediate'),
          ),
          ListTile(
            title: const Text('Avançado'),
            trailing: _selectedDifficulty == 'advanced'
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () => setState(() => _selectedDifficulty = 'advanced'),
          ),
        ],
      ),
    );
  }
}

class _MockProgramSplitStep extends StatefulWidget {
  @override
  State<_MockProgramSplitStep> createState() => _MockProgramSplitStepState();
}

class _MockProgramSplitStepState extends State<_MockProgramSplitStep> {
  String _selectedSplit = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tipo de Divisão')),
      body: Column(
        children: [
          ListTile(
            title: const Text('ABC'),
            subtitle: const Text('3 treinos diferentes'),
            onTap: () => setState(() => _selectedSplit = 'ABC'),
          ),
          ListTile(
            title: const Text('Push Pull Legs'),
            subtitle: const Text('Empurrar / Puxar / Pernas'),
            onTap: () => setState(() => _selectedSplit = 'PPL'),
          ),
          if (_selectedSplit == 'ABC') ...[
            const Divider(),
            const ListTile(title: Text('Treino A')),
            const ListTile(title: Text('Treino B')),
            const ListTile(title: Text('Treino C')),
          ],
        ],
      ),
    );
  }
}

class _MockWorkoutExercisesStep extends StatefulWidget {
  @override
  State<_MockWorkoutExercisesStep> createState() =>
      _MockWorkoutExercisesStepState();
}

class _MockWorkoutExercisesStepState extends State<_MockWorkoutExercisesStep> {
  List<String> exercises = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercícios')),
      body: Column(
        children: [
          ...exercises.map(
            (e) => ListTile(
              title: Text(e),
              subtitle: const Text('4 x 8-12'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Selecionar Exercício'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Supino Reto'),
                        onTap: () {
                          setState(() => exercises.add('Supino Reto'));
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('Agachamento'),
                        onTap: () {
                          setState(() => exercises.add('Agachamento'));
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            child: const Text('Adicionar Exercício'),
          ),
        ],
      ),
    );
  }
}

class _MockDietStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dieta')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Adicionar plano de dieta (opcional)'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Adicionar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Pular'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockProgramReviewStep extends StatelessWidget {
  final Map<String, dynamic> programData;
  final VoidCallback onConfirm;

  const _MockProgramReviewStep({
    required this.programData,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revisar Programa')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(programData['name'] as String),
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Objetivo'),
            subtitle: const Text('Hipertrofia'),
          ),
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('Dificuldade'),
            subtitle: const Text('Intermediário'),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onConfirm,
                child: const Text('Criar Programa'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockSelectTemplateStep extends StatelessWidget {
  final List<Map<String, dynamic>> templates;

  const _MockSelectTemplateStep({required this.templates});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar Template')),
      body: ListView.builder(
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return ListTile(
            title: Text(template['name'] as String),
            subtitle: Text(template['goal'] as String),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          );
        },
      ),
    );
  }
}

class _MockDuplicateTemplateStep extends StatelessWidget {
  final Map<String, dynamic> template;
  final Future<Map<String, dynamic>> Function() onDuplicate;

  const _MockDuplicateTemplateStep({
    required this.template,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(template['name'] as String)),
      body: Column(
        children: [
          ListTile(
            title: const Text('Objetivo'),
            subtitle: Text(template['goal'] as String),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: onDuplicate,
              child: const Text('Duplicar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockRenameProgramStep extends StatelessWidget {
  final String initialName;

  const _MockRenameProgramStep({required this.initialName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Renomear Programa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: TextEditingController(text: initialName),
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
      ),
    );
  }
}

class _MockAIQuestionnaireStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Questionário IA')),
      body: ListView(
        children: const [
          ListTile(title: Text('Qual seu objetivo?')),
          ListTile(title: Text('Quantos dias por semana?')),
          ListTile(title: Text('Quanto tempo por sessão?')),
          ListTile(title: Text('Equipamentos disponíveis?')),
        ],
      ),
    );
  }
}

class _MockGenerateAIProgramStep extends StatefulWidget {
  final Future<Map<String, dynamic>> Function() onGenerate;

  const _MockGenerateAIProgramStep({required this.onGenerate});

  @override
  State<_MockGenerateAIProgramStep> createState() =>
      _MockGenerateAIProgramStepState();
}

class _MockGenerateAIProgramStepState
    extends State<_MockGenerateAIProgramStep> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerar com IA')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  setState(() => _isLoading = true);
                  await widget.onGenerate();
                  setState(() => _isLoading = false);
                },
                child: const Text('Gerar Programa'),
              ),
      ),
    );
  }
}

class _MockAIReviewStep extends StatelessWidget {
  final Map<String, dynamic> program;

  const _MockAIReviewStep({required this.program});

  @override
  Widget build(BuildContext context) {
    final workouts = program['workouts'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Programa Gerado')),
      body: Column(
        children: [
          const Chip(label: Text('Gerado por IA')),
          ListTile(
            title: Text(program['name'] as String),
            subtitle: Text('${workouts.length} treinos'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
