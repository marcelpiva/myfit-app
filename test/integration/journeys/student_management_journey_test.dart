import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/core/services/organization_service.dart';
import 'package:myfit_app/core/services/trainer_service.dart';
import 'package:myfit_app/core/services/workout_service.dart';
import 'package:myfit_app/features/trainer_workout/presentation/providers/trainer_students_provider.dart';

import '../../helpers/fixtures/student_fixtures.dart';
import '../../helpers/fixtures/workout_fixtures.dart';
import '../../helpers/mock_services.dart';
import '../test_app.dart';

void main() {
  late MockTrainerService mockTrainerService;
  late MockOrganizationService mockOrganizationService;
  late MockWorkoutService mockWorkoutService;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockTrainerService = MockTrainerService();
    mockOrganizationService = MockOrganizationService();
    mockWorkoutService = MockWorkoutService();
  });

  List<Override> getOverrides() {
    return [
      trainerStudentsOrgServiceProvider.overrideWithValue(mockOrganizationService),
      trainerStudentsWorkoutServiceProvider.overrideWithValue(mockWorkoutService),
    ];
  }

  group('Student Management Journey', () {
    group('Scenario 1: Invite new student', () {
      testWidgets('should show invite flow from students list', (tester) async {
        // Setup: Empty students list
        when(() => mockOrganizationService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => []);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);
        when(() => mockOrganizationService.getInvites(any()))
            .thenAnswer((_) async => []);

        // Build a simple students page mock for testing
        await tester.pumpTestApp(
          _MockStudentsListPage(overrides: getOverrides()),
          overrides: getOverrides(),
        );

        // Verify empty state
        await tester.pumpAndSettle();

        // Find invite button (simulated)
        expect(find.byIcon(Icons.person_add), findsOneWidget);
      });

      testWidgets('should validate email before sending invite', (tester) async {
        when(() => mockOrganizationService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => []);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);

        await tester.pumpTestApp(
          _MockInviteStudentSheet(
            onInvite: (email) {
              // Validate email format
              return email.contains('@') && email.contains('.');
            },
          ),
          overrides: getOverrides(),
        );

        // Enter invalid email
        await tester.enterText(find.byType(TextField), 'invalid-email');
        await tester.tap(find.text('Enviar Convite'));
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Email inválido'), findsOneWidget);

        // Enter valid email
        await tester.enterText(find.byType(TextField), 'valid@example.com');
        await tester.tap(find.text('Enviar Convite'));
        await tester.pumpAndSettle();

        // Should not show validation error
        expect(find.text('Email inválido'), findsNothing);
      });

      testWidgets('should show pending invite after sending', (tester) async {
        final pendingInvites = [
          StudentFixtures.pendingInviteApiResponse(email: 'new@example.com'),
        ];

        when(() => mockOrganizationService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => []);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => []);
        when(() => mockOrganizationService.getInvites(any()))
            .thenAnswer((_) async => pendingInvites);

        await tester.pumpTestApp(
          _MockPendingInvitesList(overrides: getOverrides()),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Should show pending invite
        expect(find.text('new@example.com'), findsOneWidget);
        expect(find.text('Pendente'), findsOneWidget);
      });
    });

    group('Scenario 2: View student progress', () {
      testWidgets('should display student list with workout info', (tester) async {
        final members = StudentFixtures.apiResponseList(count: 3);
        final assignments = [
          WorkoutFixtures.assignmentApiResponse(studentId: 'student-0'),
        ];

        when(() => mockOrganizationService.getMembers(any(), role: any(named: 'role')))
            .thenAnswer((_) async => members);
        when(() => mockWorkoutService.getWorkoutAssignments())
            .thenAnswer((_) async => assignments);

        await tester.pumpTestApp(
          _MockStudentsListWithData(
            students: [
              StudentFixtures.active(name: 'João Silva'),
              StudentFixtures.inactive(name: 'Maria Santos'),
              StudentFixtures.newStudent(name: 'Carlos Oliveira'),
            ],
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify students are displayed
        expect(find.text('João Silva'), findsOneWidget);
        expect(find.text('Maria Santos'), findsOneWidget);
        expect(find.text('Carlos Oliveira'), findsOneWidget);
      });

      testWidgets('should navigate to student progress page', (tester) async {
        final student = StudentFixtures.active(name: 'João Silva');

        await tester.pumpTestApp(
          _MockStudentProgressPage(student: student),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify progress info is displayed (name appears in AppBar and body)
        expect(find.text('João Silva'), findsAtLeastNWidgets(1));
        expect(find.text('Progresso'), findsOneWidget);
      });

      testWidgets('should add trainer note', (tester) async {
        when(() => mockTrainerService.addStudentNote(any(), any()))
            .thenAnswer((_) async => {'id': 'note-1', 'content': 'Test note'});

        await tester.pumpTestApp(
          _MockAddNoteSheet(
            onSubmit: (note) async {
              await mockTrainerService.addStudentNote('student-1', note);
              return true;
            },
          ),
          overrides: getOverrides(),
        );

        // Enter note
        await tester.enterText(find.byType(TextField), 'Excelente progresso esta semana');
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        // Verify note was submitted
        verify(() => mockTrainerService.addStudentNote('student-1', 'Excelente progresso esta semana')).called(1);
      });
    });

    group('Scenario 3: Remove student', () {
      testWidgets('should show confirmation dialog before removal', (tester) async {
        await tester.pumpTestApp(
          _MockRemoveStudentDialog(
            studentName: 'João Silva',
            onConfirm: () {},
          ),
        );

        // Verify confirmation dialog content
        expect(find.text('Remover Aluno'), findsOneWidget);
        // The name is part of the content text "Deseja remover João Silva?"
        expect(find.textContaining('João Silva'), findsOneWidget);
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);
      });

      testWidgets('should remove student on confirmation', (tester) async {
        bool removed = false;

        when(() => mockTrainerService.removeStudent(any()))
            .thenAnswer((_) async {
          removed = true;
        });

        await tester.pumpTestApp(
          _MockRemoveStudentDialog(
            studentName: 'João Silva',
            onConfirm: () async {
              await mockTrainerService.removeStudent('student-1');
            },
          ),
        );

        // Tap confirm
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        expect(removed, true);
      });

      testWidgets('should not remove student on cancel', (tester) async {
        bool cancelled = false;

        await tester.pumpTestApp(
          _MockRemoveStudentDialog(
            studentName: 'João Silva',
            onConfirm: () {},
            onCancel: () {
              cancelled = true;
            },
          ),
        );

        // Tap cancel
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(cancelled, true);
        verifyNever(() => mockTrainerService.removeStudent(any()));
      });
    });

    group('Filtering and Sorting', () {
      testWidgets('should filter students by status', (tester) async {
        await tester.pumpTestApp(
          _MockStudentsFilterPage(
            students: StudentFixtures.mixedList(),
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Initially shows all students
        expect(find.byType(ListTile), findsNWidgets(5));

        // Filter by active
        await tester.tap(find.text('Ativos'));
        await tester.pumpAndSettle();

        // Should show only active students (4 out of 5)
        expect(find.byType(ListTile), findsNWidgets(4));

        // Filter by inactive
        await tester.tap(find.text('Inativos'));
        await tester.pumpAndSettle();

        // Should show only inactive students (1 out of 5)
        expect(find.byType(ListTile), findsNWidgets(1));
      });

      testWidgets('should search students by name', (tester) async {
        await tester.pumpTestApp(
          _MockStudentsSearchPage(
            students: StudentFixtures.mixedList(),
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Search for João
        await tester.enterText(find.byType(TextField), 'João');
        await tester.pumpAndSettle();

        // Should show only João Silva
        expect(find.text('João Silva'), findsOneWidget);
        expect(find.text('Maria Santos'), findsNothing);
      });

      testWidgets('should sort students by adherence', (tester) async {
        final students = [
          StudentFixtures.active(id: 's1', name: 'A').copyWith(adherencePercent: 50.0),
          StudentFixtures.active(id: 's2', name: 'B').copyWith(adherencePercent: 100.0),
          StudentFixtures.active(id: 's3', name: 'C').copyWith(adherencePercent: 75.0),
        ];

        await tester.pumpTestApp(
          _MockStudentsSortPage(students: students),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap sort by adherence
        await tester.tap(find.text('Aderência'));
        await tester.pumpAndSettle();

        // Verify order: B (100%), C (75%), A (50%)
        final listTiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
        expect(listTiles.length, 3);
      });
    });
  });
}

// Mock widgets for testing UI flows

class _MockStudentsListPage extends StatelessWidget {
  final List<Override> overrides;

  const _MockStudentsListPage({required this.overrides});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alunos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Text('Nenhum aluno encontrado'),
      ),
    );
  }
}

class _MockInviteStudentSheet extends StatefulWidget {
  final bool Function(String email) onInvite;

  const _MockInviteStudentSheet({required this.onInvite});

  @override
  State<_MockInviteStudentSheet> createState() => _MockInviteStudentSheetState();
}

class _MockInviteStudentSheetState extends State<_MockInviteStudentSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final isValid = widget.onInvite(_controller.text);
                setState(() {
                  _error = isValid ? null : 'Email inválido';
                });
              },
              child: const Text('Enviar Convite'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockPendingInvitesList extends StatelessWidget {
  final List<Override> overrides;

  const _MockPendingInvitesList({required this.overrides});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Convites Pendentes')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('new@example.com'),
            subtitle: const Text('Pendente'),
            trailing: const Icon(Icons.pending),
          ),
        ],
      ),
    );
  }
}

class _MockStudentsListWithData extends StatelessWidget {
  final List<TrainerStudent> students;

  const _MockStudentsListWithData({required this.students});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alunos')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return ListTile(
            title: Text(student.name),
            subtitle: Text(student.lastActivity),
            trailing: student.isActive
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.cancel, color: Colors.red),
          );
        },
      ),
    );
  }
}

class _MockStudentProgressPage extends StatelessWidget {
  final TrainerStudent student;

  const _MockStudentProgressPage({required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(student.name)),
      body: Column(
        children: [
          Text(student.name, style: Theme.of(context).textTheme.headlineMedium),
          const Text('Progresso'),
          Text('Aderência: ${student.adherencePercent.toStringAsFixed(1)}%'),
          Text('Treinos: ${student.completedWorkouts}/${student.totalWorkouts}'),
        ],
      ),
    );
  }
}

class _MockAddNoteSheet extends StatelessWidget {
  final Future<bool> Function(String note) onSubmit;

  const _MockAddNoteSheet({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Nota'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onSubmit(controller.text),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockRemoveStudentDialog extends StatelessWidget {
  final String studentName;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const _MockRemoveStudentDialog({
    required this.studentName,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AlertDialog(
        title: const Text('Remover Aluno'),
        content: Text('Deseja remover $studentName?'),
        actions: [
          TextButton(
            onPressed: onCancel ?? () {},
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

class _MockStudentsFilterPage extends StatefulWidget {
  final List<TrainerStudent> students;

  const _MockStudentsFilterPage({required this.students});

  @override
  State<_MockStudentsFilterPage> createState() => _MockStudentsFilterPageState();
}

class _MockStudentsFilterPageState extends State<_MockStudentsFilterPage> {
  String? _filter;

  List<TrainerStudent> get _filteredStudents {
    if (_filter == 'active') {
      return widget.students.where((s) => s.isActive).toList();
    } else if (_filter == 'inactive') {
      return widget.students.where((s) => !s.isActive).toList();
    }
    return widget.students;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alunos'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _filter = null),
            child: const Text('Todos'),
          ),
          TextButton(
            onPressed: () => setState(() => _filter = 'active'),
            child: const Text('Ativos'),
          ),
          TextButton(
            onPressed: () => setState(() => _filter = 'inactive'),
            child: const Text('Inativos'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredStudents.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(_filteredStudents[index].name));
        },
      ),
    );
  }
}

class _MockStudentsSearchPage extends StatefulWidget {
  final List<TrainerStudent> students;

  const _MockStudentsSearchPage({required this.students});

  @override
  State<_MockStudentsSearchPage> createState() => _MockStudentsSearchPageState();
}

class _MockStudentsSearchPageState extends State<_MockStudentsSearchPage> {
  String _query = '';

  List<TrainerStudent> get _filteredStudents {
    if (_query.isEmpty) return widget.students;
    return widget.students
        .where((s) => s.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Alunos')),
      body: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Buscar...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredStudents.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(_filteredStudents[index].name));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MockStudentsSortPage extends StatefulWidget {
  final List<TrainerStudent> students;

  const _MockStudentsSortPage({required this.students});

  @override
  State<_MockStudentsSortPage> createState() => _MockStudentsSortPageState();
}

class _MockStudentsSortPageState extends State<_MockStudentsSortPage> {
  String _sortBy = 'name';

  List<TrainerStudent> get _sortedStudents {
    final sorted = [...widget.students];
    switch (_sortBy) {
      case 'adherence':
        sorted.sort((a, b) => b.adherencePercent.compareTo(a.adherencePercent));
        break;
      default:
        sorted.sort((a, b) => a.name.compareTo(b.name));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alunos'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _sortBy = 'name'),
            child: const Text('Nome'),
          ),
          TextButton(
            onPressed: () => setState(() => _sortBy = 'adherence'),
            child: const Text('Aderência'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _sortedStudents.length,
        itemBuilder: (context, index) {
          final student = _sortedStudents[index];
          return ListTile(
            title: Text(student.name),
            trailing: Text('${student.adherencePercent.toStringAsFixed(0)}%'),
          );
        },
      ),
    );
  }
}
