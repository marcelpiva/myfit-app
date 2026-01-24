/// Helpers and fixtures for SAGA journey tests.
///
/// IMPORTANT: These tests must ONLY run against local/development APIs.
/// NEVER run against production.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

// =============================================================================
// Test Data Constants
// =============================================================================

/// Test Personal Trainer data
class TestPersonal {
  static const String name = 'João Silva';
  static const String email = 'joao.personal@test.local';
  static const String password = 'Test@123';
  static const String id = 'test-personal-001';
}

/// Test Student data
class TestStudent {
  static const String name = 'Maria Santos';
  static const String email = 'maria.aluna@test.local';
  static const String password = 'Test@456';
  static const String id = 'test-student-001';
}

/// Test Organization data
class TestOrganization {
  static const String name = 'Studio Fitness Teste';
  static const String id = 'test-org-001';
  static const String type = 'personal';
}

/// Test Plan data
class TestPlan {
  static const String name = 'Plano Teste Iniciante';
  static const String id = 'test-plan-001';
  static const String goal = 'general_fitness';
  static const String difficulty = 'beginner';
  static const int durationWeeks = 4;
}

// =============================================================================
// SAGA Test Fixtures
// =============================================================================

/// Fixture data for Personal Trainer
Map<String, dynamic> createPersonalFixture({
  String? id,
  String? email,
  String? name,
}) {
  return {
    'id': id ?? TestPersonal.id,
    'email': email ?? TestPersonal.email,
    'name': name ?? TestPersonal.name,
    'role': 'trainer',
    'is_active': true,
  };
}

/// Fixture data for Student
Map<String, dynamic> createStudentFixture({
  String? id,
  String? email,
  String? name,
}) {
  return {
    'id': id ?? TestStudent.id,
    'email': email ?? TestStudent.email,
    'name': name ?? TestStudent.name,
    'role': 'student',
    'is_active': true,
  };
}

/// Fixture data for Organization
Map<String, dynamic> createOrganizationFixture({
  String? id,
  String? name,
  String? type,
}) {
  return {
    'id': id ?? TestOrganization.id,
    'name': name ?? TestOrganization.name,
    'type': type ?? TestOrganization.type,
    'is_active': true,
  };
}

/// Fixture data for Training Plan
Map<String, dynamic> createPlanFixture({
  String? id,
  String? name,
  String? goal,
  String? difficulty,
  int? durationWeeks,
  List<Map<String, dynamic>>? workouts,
}) {
  return {
    'id': id ?? TestPlan.id,
    'name': name ?? TestPlan.name,
    'goal': goal ?? TestPlan.goal,
    'difficulty': difficulty ?? TestPlan.difficulty,
    'duration_weeks': durationWeeks ?? TestPlan.durationWeeks,
    'split_type': 'abc',
    'workouts': workouts ?? createDefaultWorkoutsFixture(),
  };
}

/// Fixture data for default workouts (ABC split)
List<Map<String, dynamic>> createDefaultWorkoutsFixture() {
  return [
    {
      'id': 'workout-a',
      'name': 'Treino A - Peito e Tríceps',
      'label': 'A',
      'exercises': [
        {'id': 'ex-1', 'name': 'Supino Reto', 'sets': 4, 'reps': '10-12'},
        {'id': 'ex-2', 'name': 'Crucifixo', 'sets': 3, 'reps': '12'},
        {'id': 'ex-3', 'name': 'Tríceps Pulley', 'sets': 3, 'reps': '12'},
      ],
    },
    {
      'id': 'workout-b',
      'name': 'Treino B - Costas e Bíceps',
      'label': 'B',
      'exercises': [
        {'id': 'ex-4', 'name': 'Puxada Frontal', 'sets': 4, 'reps': '10-12'},
        {'id': 'ex-5', 'name': 'Remada Curvada', 'sets': 3, 'reps': '12'},
        {'id': 'ex-6', 'name': 'Rosca Direta', 'sets': 3, 'reps': '12'},
      ],
    },
    {
      'id': 'workout-c',
      'name': 'Treino C - Pernas e Ombros',
      'label': 'C',
      'exercises': [
        {'id': 'ex-7', 'name': 'Agachamento', 'sets': 4, 'reps': '10-12'},
        {'id': 'ex-8', 'name': 'Leg Press', 'sets': 3, 'reps': '12'},
        {'id': 'ex-9', 'name': 'Desenvolvimento', 'sets': 3, 'reps': '12'},
      ],
    },
  ];
}

/// Fixture data for Plan Assignment
Map<String, dynamic> createAssignmentFixture({
  String? id,
  String? planId,
  String? studentId,
  String? status,
  String? trainingMode,
}) {
  return {
    'id': id ?? 'assignment-001',
    'plan_id': planId ?? TestPlan.id,
    'student_id': studentId ?? TestStudent.id,
    'status': status ?? 'pending',
    'training_mode': trainingMode ?? 'presencial',
    'start_date': DateTime.now().toIso8601String(),
    'end_date': DateTime.now().add(const Duration(days: 28)).toIso8601String(),
  };
}

/// Fixture data for Workout Session
Map<String, dynamic> createSessionFixture({
  String? id,
  String? workoutId,
  String? status,
  bool isShared = false,
}) {
  return {
    'id': id ?? 'session-001',
    'workout_id': workoutId ?? 'workout-a',
    'status': status ?? 'active',
    'is_shared': isShared,
    'started_at': DateTime.now().toIso8601String(),
  };
}

/// Fixture data for Progress entry
Map<String, dynamic> createProgressFixture({
  double? weightKg,
  String? notes,
}) {
  return {
    'id': 'progress-001',
    'weight_kg': weightKg ?? 65.0,
    'logged_at': DateTime.now().toIso8601String(),
    'notes': notes ?? 'Registro de teste',
  };
}

// =============================================================================
// SAGA Test Extensions
// =============================================================================

/// Extension for easier SAGA testing
extension SagaWidgetTesterExtension on WidgetTester {
  /// Pumps a test app with overrides for SAGA testing
  Future<void> pumpSagaTestApp(
    Widget child, {
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          home: child,
          theme: ThemeData.light(),
        ),
      ),
    );
    await pumpAndSettle();
  }

  /// Taps a widget with given text
  Future<void> tapText(String text) async {
    await tap(find.text(text));
    await pumpAndSettle();
  }

  /// Taps a widget with given key
  Future<void> tapKey(String key) async {
    await tap(find.byKey(Key(key)));
    await pumpAndSettle();
  }

  /// Enters text in a field with given key
  Future<void> enterTextInField(String key, String text) async {
    await enterText(find.byKey(Key(key)), text);
    await pumpAndSettle();
  }

  /// Scrolls until finding a widget with text
  Future<void> scrollToText(String text) async {
    await scrollUntilVisible(
      find.text(text),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpAndSettle();
  }

  /// Verifies text is present
  void expectText(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verifies text is not present
  void expectNoText(String text) {
    expect(find.text(text), findsNothing);
  }

  /// Verifies widget with key is present
  void expectKey(String key) {
    expect(find.byKey(Key(key)), findsOneWidget);
  }
}

// =============================================================================
// Mock Widget Helpers
// =============================================================================

/// Creates a mock login page for testing
Widget createMockLoginPage({
  VoidCallback? onLogin,
  VoidCallback? onRegister,
}) {
  return Scaffold(
    appBar: AppBar(title: const Text('Login')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            key: const Key('email-field'),
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('password-field'),
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Senha'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('login-button'),
            onPressed: onLogin,
            child: const Text('Entrar'),
          ),
          TextButton(
            key: const Key('register-button'),
            onPressed: onRegister,
            child: const Text('Criar conta'),
          ),
        ],
      ),
    ),
  );
}

/// Creates a mock dashboard for Personal Trainer
Widget createMockTrainerDashboard({
  int studentCount = 0,
  int activeWorkouts = 0,
  List<String> alerts = const [],
  VoidCallback? onInviteStudent,
  VoidCallback? onCreatePlan,
}) {
  return Scaffold(
    appBar: AppBar(title: const Text('Dashboard')),
    body: ListView(
      children: [
        // Stats cards
        Row(
          children: [
            _StatCard(title: 'Alunos', value: '$studentCount'),
            _StatCard(title: 'Treinos Ativos', value: '$activeWorkouts'),
          ],
        ),
        // Alerts
        if (alerts.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Alertas', style: TextStyle(fontSize: 18)),
          ),
          ...alerts.map((alert) => ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(alert),
              )),
        ],
        // Quick actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ElevatedButton(
                key: const Key('invite-student-button'),
                onPressed: onInviteStudent,
                child: const Text('Convidar Aluno'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                key: const Key('create-plan-button'),
                onPressed: onCreatePlan,
                child: const Text('Criar Plano'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Creates a mock dashboard for Student
Widget createMockStudentDashboard({
  String? trainerName,
  bool hasPendingPlan = false,
  String? todayWorkout,
  VoidCallback? onStartWorkout,
  VoidCallback? onViewPlan,
}) {
  return Scaffold(
    appBar: AppBar(title: const Text('Meu Treino')),
    body: ListView(
      children: [
        // Trainer card
        if (trainerName != null)
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('Personal: $trainerName'),
          ),
        // Pending plan notification
        if (hasPendingPlan)
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const Icon(Icons.notification_important),
              title: const Text('Novo plano disponível'),
              trailing: TextButton(
                key: const Key('view-plan-button'),
                onPressed: onViewPlan,
                child: const Text('Ver'),
              ),
            ),
          ),
        // Today's workout
        if (todayWorkout != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Treino de Hoje',
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    title: Text(todayWorkout),
                    trailing: ElevatedButton(
                      key: const Key('start-workout-button'),
                      onPressed: onStartWorkout,
                      child: const Text('Iniciar'),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
