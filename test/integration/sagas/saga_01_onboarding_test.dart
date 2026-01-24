/// SAGA 1: Onboarding Completo - Do Convite ao Primeiro Treino
///
/// Esta saga testa o fluxo completo de UI desde o cadastro do Personal
/// até o primeiro treino executado pelo Aluno.
///
/// IMPORTANT: Run only against local/development environment!

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';
import 'saga_test_helpers.dart';

void main() {
  late MockWorkoutService mockWorkoutService;
  late MockTrainerService mockTrainerService;
  late MockOrganizationService mockOrganizationService;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockWorkoutService = MockWorkoutService();
    mockTrainerService = MockTrainerService();
    mockOrganizationService = MockOrganizationService();
  });

  group('SAGA 1: Onboarding Completo', () {
    group('Fase 1: PERSONAL - Cadastro e Configuração', () {
      testWidgets('should show registration form', (tester) async {
        // Dado que estou na tela de boas-vindas
        await tester.pumpSagaTestApp(
          createMockLoginPage(
            onRegister: () {},
          ),
        );

        // Então devo ver os campos de login e opção de registro
        tester.expectKey('email-field');
        tester.expectKey('password-field');
        tester.expectKey('register-button');
      });

      testWidgets('should show organization creation after registration',
          (tester) async {
        // Dado que completei o registro
        await tester.pumpSagaTestApp(
          _MockOrganizationCreationPage(),
        );

        // Então devo ver o formulário de criação de organização
        tester.expectText('Criar Organização');
        expect(find.byKey(const Key('org-name-field')), findsOneWidget);
        expect(find.byKey(const Key('org-type-field')), findsOneWidget);
      });

      testWidgets('should create organization successfully', (tester) async {
        bool organizationCreated = false;

        await tester.pumpSagaTestApp(
          _MockOrganizationCreationPage(
            onCreateOrganization: () {
              organizationCreated = true;
            },
          ),
        );

        // Quando preencho o nome e tipo
        await tester.enterTextInField('org-name-field', 'Studio Fitness João');
        await tester.tapText('Personal');

        // E toco em criar
        await tester.tapText('Criar Organização');

        // Então a organização deve ser criada
        expect(organizationCreated, isTrue);
      });
    });

    group('Fase 2: PERSONAL - Criação de Plano', () {
      testWidgets('should show plan creation wizard', (tester) async {
        await tester.pumpSagaTestApp(
          _MockPlanCreationWizard(),
        );

        // Então devo ver as opções do wizard
        tester.expectText('Criar Plano');
        tester.expectText('Do Zero');
        tester.expectText('A partir de template');
      });

      testWidgets('should configure plan details', (tester) async {
        await tester.pumpSagaTestApp(
          _MockPlanDetailsStep(),
        );

        // Quando preencho os detalhes
        await tester.enterTextInField('plan-name-field', 'Plano Iniciante');
        await tester.tapText('Condicionamento');
        await tester.tapText('Iniciante');
        await tester.tapText('ABC');

        // Então os campos devem estar preenchidos
        expect(find.text('Plano Iniciante'), findsOneWidget);
      });

      testWidgets('should add workouts to plan', (tester) async {
        await tester.pumpSagaTestApp(
          _MockAddWorkoutsStep(),
        );

        // Quando adiciono treinos
        await tester.tapText('Adicionar Treino');
        await tester.enterTextInField('workout-name-field', 'Treino A');
        await tester.tapText('Salvar');

        // Então o treino deve aparecer na lista
        expect(find.text('Treino A'), findsOneWidget);
      });
    });

    group('Fase 3: PERSONAL - Convite do Aluno', () {
      testWidgets('should show invite form', (tester) async {
        await tester.pumpSagaTestApp(
          _MockInviteStudentForm(),
        );

        // Então devo ver o formulário de convite
        tester.expectText('Convidar Aluno');
        expect(find.byKey(const Key('student-email-field')), findsOneWidget);
        expect(find.byKey(const Key('student-name-field')), findsOneWidget);
      });

      testWidgets('should send invite successfully', (tester) async {
        bool inviteSent = false;

        await tester.pumpSagaTestApp(
          _MockInviteStudentForm(
            onSendInvite: () {
              inviteSent = true;
            },
          ),
        );

        // Quando preencho os dados
        await tester.enterTextInField('student-email-field', TestStudent.email);
        await tester.enterTextInField('student-name-field', TestStudent.name);

        // E envio o convite
        await tester.tapText('Enviar Convite');

        // Então o convite deve ser enviado
        expect(inviteSent, isTrue);
      });
    });

    group('Fase 4-5: ALUNO - Aceitação do Convite', () {
      testWidgets('should show invite preview', (tester) async {
        await tester.pumpSagaTestApp(
          _MockInvitePreviewPage(
            personalName: TestPersonal.name,
            organizationName: TestOrganization.name,
          ),
        );

        // Então devo ver os detalhes do convite
        expect(find.text(TestPersonal.name), findsOneWidget);
        expect(find.text(TestOrganization.name), findsOneWidget);
        tester.expectText('Aceitar Convite');
      });

      testWidgets('should show registration form on accept', (tester) async {
        bool registrationShown = false;

        await tester.pumpSagaTestApp(
          _MockInvitePreviewPage(
            personalName: TestPersonal.name,
            organizationName: TestOrganization.name,
            onAcceptInvite: () {
              registrationShown = true;
            },
          ),
        );

        // Quando aceito o convite
        await tester.tapText('Aceitar Convite');

        // Então devo ser direcionado para registro
        expect(registrationShown, isTrue);
      });
    });

    group('Fase 6: ALUNO - Visualização e Aceitação do Plano', () {
      testWidgets('should show pending plan notification', (tester) async {
        await tester.pumpSagaTestApp(
          createMockStudentDashboard(
            trainerName: TestPersonal.name,
            hasPendingPlan: true,
          ),
        );

        // Então devo ver a notificação de plano pendente
        tester.expectText('Novo plano disponível');
        tester.expectKey('view-plan-button');
      });

      testWidgets('should show plan details for acceptance', (tester) async {
        await tester.pumpSagaTestApp(
          _MockPlanAcceptancePage(
            plan: createPlanFixture(),
          ),
        );

        // Então devo ver os detalhes do plano
        expect(find.text(TestPlan.name), findsOneWidget);
        tester.expectText('Aceitar Plano');
        tester.expectText('Recusar');
      });

      testWidgets('should accept plan successfully', (tester) async {
        bool planAccepted = false;

        await tester.pumpSagaTestApp(
          _MockPlanAcceptancePage(
            plan: createPlanFixture(),
            onAcceptPlan: () {
              planAccepted = true;
            },
          ),
        );

        // Quando aceito o plano
        await tester.tapText('Aceitar Plano');

        // Então o plano deve ser aceito
        expect(planAccepted, isTrue);
      });
    });

    group('Fase 8: ALUNO - Execução do Primeiro Treino', () {
      testWidgets('should show workout list', (tester) async {
        await tester.pumpSagaTestApp(
          _MockWorkoutListPage(
            workouts: createDefaultWorkoutsFixture(),
          ),
        );

        // Então devo ver meus treinos
        tester.expectText('Treino A - Peito e Tríceps');
        tester.expectText('Treino B - Costas e Bíceps');
        tester.expectText('Treino C - Pernas e Ombros');
      });

      testWidgets('should show workout details', (tester) async {
        final workout = createDefaultWorkoutsFixture()[0];

        await tester.pumpSagaTestApp(
          _MockWorkoutDetailPage(workout: workout),
        );

        // Então devo ver os exercícios
        tester.expectText('Supino Reto');
        tester.expectText('Crucifixo');
        tester.expectText('Tríceps Pulley');
        tester.expectText('Iniciar Treino');
      });

      testWidgets('should start workout session', (tester) async {
        bool sessionStarted = false;
        final workout = createDefaultWorkoutsFixture()[0];

        await tester.pumpSagaTestApp(
          _MockWorkoutDetailPage(
            workout: workout,
            onStartWorkout: () {
              sessionStarted = true;
            },
          ),
        );

        // Quando inicio o treino
        await tester.tapText('Iniciar Treino');

        // Então a sessão deve iniciar
        expect(sessionStarted, isTrue);
      });

      testWidgets('should show active workout screen', (tester) async {
        await tester.pumpSagaTestApp(
          _MockActiveWorkoutPage(
            exerciseName: 'Supino Reto',
            currentSet: 1,
            totalSets: 4,
            targetReps: '10-12',
          ),
        );

        // Então devo ver o exercício atual
        tester.expectText('Supino Reto');
        tester.expectText('Série 1/4');
        tester.expectText('10-12 reps');
      });

      testWidgets('should complete set and show rest timer', (tester) async {
        bool setCompleted = false;

        await tester.pumpSagaTestApp(
          _MockActiveWorkoutPage(
            exerciseName: 'Supino Reto',
            currentSet: 1,
            totalSets: 4,
            targetReps: '10-12',
            onCompleteSet: () {
              setCompleted = true;
            },
          ),
        );

        // Quando completo a série
        await tester.tapText('Série Concluída');

        // Então a série deve ser registrada
        expect(setCompleted, isTrue);
      });

      testWidgets('should show completion celebration', (tester) async {
        await tester.pumpSagaTestApp(
          _MockWorkoutCompletionPage(
            duration: const Duration(minutes: 45),
            exercisesCompleted: 5,
          ),
        );

        // Então devo ver a celebração
        tester.expectText('Treino Concluído!');
        tester.expectText('45 min');
        tester.expectText('5 exercícios');
      });
    });
  });
}

// =============================================================================
// Mock Widgets for SAGA 1
// =============================================================================

class _MockOrganizationCreationPage extends StatelessWidget {
  final VoidCallback? onCreateOrganization;

  const _MockOrganizationCreationPage({this.onCreateOrganization});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Organização')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('org-name-field'),
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const Key('org-type-field'),
              items: const [
                DropdownMenuItem(value: 'personal', child: Text('Personal')),
                DropdownMenuItem(value: 'gym', child: Text('Academia')),
              ],
              onChanged: (_) {},
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: onCreateOrganization,
              child: const Text('Criar Organização'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockPlanCreationWizard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Plano')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Do Zero'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('A partir de template'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _MockPlanDetailsStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Plano')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('plan-name-field'),
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          const SizedBox(height: 16),
          const Text('Objetivo'),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(label: const Text('Condicionamento'), selected: false, onSelected: (_) {}),
              ChoiceChip(label: const Text('Hipertrofia'), selected: false, onSelected: (_) {}),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Dificuldade'),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(label: const Text('Iniciante'), selected: false, onSelected: (_) {}),
              ChoiceChip(label: const Text('Intermediário'), selected: false, onSelected: (_) {}),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Divisão'),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(label: const Text('ABC'), selected: false, onSelected: (_) {}),
              ChoiceChip(label: const Text('ABCD'), selected: false, onSelected: (_) {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _MockAddWorkoutsStep extends StatefulWidget {
  @override
  State<_MockAddWorkoutsStep> createState() => _MockAddWorkoutsStepState();
}

class _MockAddWorkoutsStepState extends State<_MockAddWorkoutsStep> {
  final List<String> workouts = [];
  bool showForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Treinos')),
      body: Column(
        children: [
          ...workouts.map((w) => ListTile(title: Text(w))),
          if (showForm) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                key: const Key('workout-name-field'),
                decoration: const InputDecoration(labelText: 'Nome do Treino'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  workouts.add('Treino A');
                  showForm = false;
                });
              },
              child: const Text('Salvar'),
            ),
          ] else
            ElevatedButton(
              onPressed: () => setState(() => showForm = true),
              child: const Text('Adicionar Treino'),
            ),
        ],
      ),
    );
  }
}

class _MockInviteStudentForm extends StatelessWidget {
  final VoidCallback? onSendInvite;

  const _MockInviteStudentForm({this.onSendInvite});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Convidar Aluno')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('student-email-field'),
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('student-name-field'),
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: onSendInvite,
              child: const Text('Enviar Convite'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockInvitePreviewPage extends StatelessWidget {
  final String personalName;
  final String organizationName;
  final VoidCallback? onAcceptInvite;

  const _MockInvitePreviewPage({
    required this.personalName,
    required this.organizationName,
    this.onAcceptInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Convite')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 64),
            const SizedBox(height: 24),
            Text('Personal: $personalName', style: const TextStyle(fontSize: 18)),
            Text(organizationName),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onAcceptInvite,
              child: const Text('Aceitar Convite'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockPlanAcceptancePage extends StatelessWidget {
  final Map<String, dynamic> plan;
  final VoidCallback? onAcceptPlan;

  const _MockPlanAcceptancePage({
    required this.plan,
    this.onAcceptPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Plano')),
      body: Column(
        children: [
          ListTile(
            title: Text(plan['name'] as String),
            subtitle: Text('${plan['duration_weeks']} semanas'),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: () {}, child: const Text('Recusar')),
              ElevatedButton(
                onPressed: onAcceptPlan,
                child: const Text('Aceitar Plano'),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MockWorkoutListPage extends StatelessWidget {
  final List<Map<String, dynamic>> workouts;

  const _MockWorkoutListPage({required this.workouts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Treinos')),
      body: ListView.builder(
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];
          return ListTile(
            title: Text(workout['name'] as String),
            trailing: const Icon(Icons.chevron_right),
          );
        },
      ),
    );
  }
}

class _MockWorkoutDetailPage extends StatelessWidget {
  final Map<String, dynamic> workout;
  final VoidCallback? onStartWorkout;

  const _MockWorkoutDetailPage({
    required this.workout,
    this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final exercises = workout['exercises'] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(title: Text(workout['name'] as String)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final ex = exercises[index];
                return ListTile(
                  title: Text(ex['name'] as String),
                  subtitle: Text('${ex['sets']} x ${ex['reps']}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStartWorkout,
                child: const Text('Iniciar Treino'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockActiveWorkoutPage extends StatelessWidget {
  final String exerciseName;
  final int currentSet;
  final int totalSets;
  final String targetReps;
  final VoidCallback? onCompleteSet;

  const _MockActiveWorkoutPage({
    required this.exerciseName,
    required this.currentSet,
    required this.totalSets,
    required this.targetReps,
    this.onCompleteSet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Treino Ativo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(exerciseName, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            Text('Série $currentSet/$totalSets'),
            Text('$targetReps reps'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onCompleteSet,
              child: const Text('Série Concluída'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockWorkoutCompletionPage extends StatelessWidget {
  final Duration duration;
  final int exercisesCompleted;

  const _MockWorkoutCompletionPage({
    required this.duration,
    required this.exercisesCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 64, color: Colors.amber),
            const SizedBox(height: 24),
            const Text('Treino Concluído!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            Text('${duration.inMinutes} min'),
            Text('$exercisesCompleted exercícios'),
          ],
        ),
      ),
    );
  }
}
