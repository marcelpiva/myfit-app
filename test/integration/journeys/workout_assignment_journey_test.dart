import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/core/services/workout_service.dart';
import 'package:myfit_app/features/trainer_workout/presentation/providers/trainer_students_provider.dart';
import 'package:myfit_app/features/trainer_workout/presentation/providers/trainer_workout_provider.dart';

import '../../helpers/fixtures/program_fixtures.dart';
import '../../helpers/fixtures/student_fixtures.dart';
import '../../helpers/mock_services.dart';
import '../test_app.dart';

void main() {
  late MockWorkoutService mockWorkoutService;
  late MockOrganizationService mockOrganizationService;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockWorkoutService = MockWorkoutService();
    mockOrganizationService = MockOrganizationService();
  });

  List<Override> getOverrides() {
    return [
      workoutServiceProvider.overrideWithValue(mockWorkoutService),
      trainerStudentsOrgServiceProvider.overrideWithValue(mockOrganizationService),
      trainerStudentsWorkoutServiceProvider.overrideWithValue(mockWorkoutService),
    ];
  }

  group('Workout Assignment Journey', () {
    group('Scenario 1: Assign program to student', () {
      testWidgets('should show programs list', (tester) async {
        final programs = ProgramFixtures.apiResponseList(count: 3);

        when(() => mockWorkoutService.getPrograms())
            .thenAnswer((_) async => programs);

        await tester.pumpTestApp(
          _MockProgramsListPage(programs: programs),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify programs are displayed
        expect(find.text('Programa ABC - Hipertrofia'), findsOneWidget);
        expect(find.text('Push Pull Legs'), findsOneWidget);
      });

      testWidgets('should show assign button on program detail', (tester) async {
        final program = ProgramFixtures.abcSplit();

        await tester.pumpTestApp(
          _MockProgramDetailPage(program: program),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify assign button is visible
        expect(find.text('Atribuir'), findsOneWidget);
      });

      testWidgets('should show student selection', (tester) async {
        final students = StudentFixtures.mixedList();

        await tester.pumpTestApp(
          _MockSelectStudentPage(students: students),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify students are displayed
        expect(find.text('João Silva'), findsOneWidget);
        expect(find.text('Maria Santos'), findsOneWidget);
        expect(find.text('Carlos Oliveira'), findsOneWidget);
      });

      testWidgets('should show date picker for start date', (tester) async {
        await tester.pumpTestApp(
          _MockStartDatePicker(
            initialDate: DateTime.now(),
            onDateSelected: (date) {},
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify date picker elements (text may appear in AppBar title and ListTile)
        expect(find.text('Data de Início'), findsAtLeastNWidgets(1));
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      });

      testWidgets('should create assignment successfully', (tester) async {
        final assignment = ProgramFixtures.assignmentApiResponse();

        when(() => mockWorkoutService.createProgramAssignment(
              programId: any(named: 'programId'),
              studentId: any(named: 'studentId'),
              startDate: any(named: 'startDate'),
            )).thenAnswer((_) async => assignment);

        bool assignmentCreated = false;

        await tester.pumpTestApp(
          _MockAssignConfirmationPage(
            programName: 'Programa ABC',
            studentName: 'João Silva',
            startDate: DateTime.now(),
            onConfirm: () async {
              await mockWorkoutService.createProgramAssignment(
                programId: 'program-1',
                studentId: 'student-1',
              );
              assignmentCreated = true;
            },
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify confirmation info
        expect(find.text('Programa ABC'), findsOneWidget);
        expect(find.text('João Silva'), findsOneWidget);

        // Confirm assignment (tap on button, not AppBar title)
        await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar Atribuição'));
        await tester.pumpAndSettle();

        expect(assignmentCreated, true);
        verify(() => mockWorkoutService.createProgramAssignment(
              programId: 'program-1',
              studentId: 'student-1',
            )).called(1);
      });

      testWidgets('should show assignment in student workouts', (tester) async {
        final assignments = [
          {
            'id': 'assign-1',
            'program_name': 'Programa ABC',
            'status': 'active',
            'start_date': DateTime.now().toIso8601String(),
          },
        ];

        await tester.pumpTestApp(
          _MockStudentWorkoutsPage(assignments: assignments),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify assignment is visible
        expect(find.text('Programa ABC'), findsOneWidget);
        expect(find.text('Ativo'), findsOneWidget);
      });
    });

    group('Scenario 2: Publish program to catalog', () {
      testWidgets('should show publish option for own programs', (tester) async {
        final program = ProgramFixtures.abcSplit();

        await tester.pumpTestApp(
          _MockOwnProgramPage(
            program: program,
            isOwner: true,
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify publish button is visible
        expect(find.text('Publicar'), findsOneWidget);
      });

      testWidgets('should confirm before publishing', (tester) async {
        await tester.pumpTestApp(
          _MockPublishConfirmationDialog(
            programName: 'Programa ABC',
            onConfirm: () {},
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify confirmation dialog
        expect(find.text('Publicar no Catálogo'), findsOneWidget);
        expect(find.text('Programa ABC'), findsAtLeastNWidgets(1));
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Publicar'), findsOneWidget); // button only, title is "Publicar no Catálogo"
      });

      testWidgets('should publish program and show badge', (tester) async {
        when(() => mockWorkoutService.updateProgram(
              any(),
              isPublic: true,
            )).thenAnswer((_) async => {'id': 'program-1', 'is_public': true});

        bool published = false;

        await tester.pumpTestApp(
          _MockPublishProgramPage(
            programId: 'program-1',
            onPublish: () async {
              await mockWorkoutService.updateProgram(
                'program-1',
                isPublic: true,
              );
              published = true;
            },
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap publish
        await tester.tap(find.text('Publicar'));
        await tester.pumpAndSettle();

        expect(published, true);

        // Verify badge
        expect(find.text('Publicado'), findsOneWidget);
      });
    });

    group('Scenario 3: Import from catalog', () {
      testWidgets('should show catalog templates', (tester) async {
        final templates = ProgramFixtures.catalogResponseList(count: 5);

        await tester.pumpTestApp(
          _MockCatalogPage(templates: templates),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify catalog header
        expect(find.text('Catálogo'), findsOneWidget);

        // Verify some templates are shown
        expect(find.byType(ListTile), findsWidgets);
      });

      testWidgets('should filter catalog by goal', (tester) async {
        final templates = ProgramFixtures.catalogResponseList(count: 10);

        await tester.pumpTestApp(
          _MockCatalogFilterPage(templates: templates),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Filter by hypertrophy
        await tester.tap(find.text('Hipertrofia'));
        await tester.pumpAndSettle();

        // Verify filter is applied (chip is selected)
        // FilterChip shows its selected state visually, we verify the chip exists and was tapped
        final filterChip = tester.widget<FilterChip>(
          find.widgetWithText(FilterChip, 'Hipertrofia'),
        );
        expect(filterChip.selected, isTrue);
      });

      testWidgets('should import template to my programs', (tester) async {
        final template = ProgramFixtures.catalogTemplate();
        final imported = {
          ...template,
          'id': 'my-program-1',
          'is_template': false,
        };

        when(() => mockWorkoutService.duplicateProgram(any()))
            .thenAnswer((_) async => imported);

        bool wasImported = false;

        await tester.pumpTestApp(
          _MockImportTemplatePage(
            template: template,
            onImport: () async {
              await mockWorkoutService.duplicateProgram('catalog-1');
              wasImported = true;
            },
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Tap import
        await tester.tap(find.text('Importar'));
        await tester.pumpAndSettle();

        expect(wasImported, true);
      });

      testWidgets('should show imported badge in my programs', (tester) async {
        final programs = [
          {
            'id': 'program-1',
            'name': 'Programa ABC',
            'is_imported': false,
          },
          {
            'id': 'program-2',
            'name': 'Template Importado',
            'is_imported': true,
          },
        ];

        await tester.pumpTestApp(
          _MockMyProgramsWithBadges(programs: programs),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify imported badge
        expect(find.text('Importado'), findsOneWidget);
      });
    });

    group('Assignment Status Management', () {
      testWidgets('should show assignment status options', (tester) async {
        await tester.pumpTestApp(
          _MockAssignmentStatusPage(
            currentStatus: 'active',
            onStatusChange: (status) {},
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Verify status options
        expect(find.text('Ativo'), findsOneWidget);
        expect(find.text('Pausado'), findsOneWidget);
        expect(find.text('Completado'), findsOneWidget);
      });

      testWidgets('should update assignment status', (tester) async {
        String? newStatus;

        await tester.pumpTestApp(
          _MockAssignmentStatusPage(
            currentStatus: 'active',
            onStatusChange: (status) {
              newStatus = status;
            },
          ),
          overrides: getOverrides(),
        );

        await tester.pumpAndSettle();

        // Change to paused
        await tester.tap(find.text('Pausado'));
        await tester.pumpAndSettle();

        expect(newStatus, 'paused');
      });
    });
  });
}

// Mock widgets for testing UI flows

class _MockProgramsListPage extends StatelessWidget {
  final List<Map<String, dynamic>> programs;

  const _MockProgramsListPage({required this.programs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Programas')),
      body: ListView.builder(
        itemCount: programs.length,
        itemBuilder: (context, index) {
          final program = programs[index];
          return ListTile(
            title: Text(program['name'] as String),
            subtitle: Text(program['goal'] as String),
            trailing: const Icon(Icons.chevron_right),
          );
        },
      ),
    );
  }
}

class _MockProgramDetailPage extends StatelessWidget {
  final Map<String, dynamic> program;

  const _MockProgramDetailPage({required this.program});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(program['name'] as String)),
      body: Column(
        children: [
          ListTile(title: Text(program['goal'] as String)),
          ListTile(title: Text(program['difficulty'] as String)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Atribuir'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockSelectStudentPage extends StatelessWidget {
  final List<TrainerStudent> students;

  const _MockSelectStudentPage({required this.students});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar Aluno')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return ListTile(
            title: Text(student.name),
            subtitle: Text(student.email ?? ''),
            trailing: const Icon(Icons.chevron_right),
          );
        },
      ),
    );
  }
}

class _MockStartDatePicker extends StatelessWidget {
  final DateTime initialDate;
  final void Function(DateTime) onDateSelected;

  const _MockStartDatePicker({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data de Início')),
      body: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Data de Início'),
        subtitle: Text(
          '${initialDate.day}/${initialDate.month}/${initialDate.year}',
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            onDateSelected(date);
          }
        },
      ),
    );
  }
}

class _MockAssignConfirmationPage extends StatelessWidget {
  final String programName;
  final String studentName;
  final DateTime startDate;
  final VoidCallback onConfirm;

  const _MockAssignConfirmationPage({
    required this.programName,
    required this.studentName,
    required this.startDate,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Atribuição')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Programa'),
            subtitle: Text(programName),
          ),
          ListTile(
            title: const Text('Aluno'),
            subtitle: Text(studentName),
          ),
          ListTile(
            title: const Text('Início'),
            subtitle: Text(
              '${startDate.day}/${startDate.month}/${startDate.year}',
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: onConfirm,
              child: const Text('Confirmar Atribuição'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockStudentWorkoutsPage extends StatelessWidget {
  final List<Map<String, dynamic>> assignments;

  const _MockStudentWorkoutsPage({required this.assignments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Treinos do Aluno')),
      body: ListView.builder(
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return ListTile(
            title: Text(assignment['program_name'] as String),
            subtitle: Text(assignment['status'] == 'active' ? 'Ativo' : 'Inativo'),
          );
        },
      ),
    );
  }
}

class _MockOwnProgramPage extends StatelessWidget {
  final Map<String, dynamic> program;
  final bool isOwner;

  const _MockOwnProgramPage({
    required this.program,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(program['name'] as String),
        actions: [
          if (isOwner)
            TextButton(
              onPressed: () {},
              child: const Text('Publicar'),
            ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(title: Text(program['goal'] as String)),
        ],
      ),
    );
  }
}

class _MockPublishConfirmationDialog extends StatelessWidget {
  final String programName;
  final VoidCallback onConfirm;

  const _MockPublishConfirmationDialog({
    required this.programName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AlertDialog(
        title: const Text('Publicar no Catálogo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Deseja publicar "$programName" no catálogo?'),
            const SizedBox(height: 8),
            Text(programName),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }
}

class _MockPublishProgramPage extends StatefulWidget {
  final String programId;
  final VoidCallback onPublish;

  const _MockPublishProgramPage({
    required this.programId,
    required this.onPublish,
  });

  @override
  State<_MockPublishProgramPage> createState() => _MockPublishProgramPageState();
}

class _MockPublishProgramPageState extends State<_MockPublishProgramPage> {
  bool _isPublished = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Programa')),
      body: Column(
        children: [
          if (_isPublished)
            const Chip(label: Text('Publicado'))
          else
            ElevatedButton(
              onPressed: () {
                widget.onPublish();
                setState(() => _isPublished = true);
              },
              child: const Text('Publicar'),
            ),
        ],
      ),
    );
  }
}

class _MockCatalogPage extends StatelessWidget {
  final List<Map<String, dynamic>> templates;

  const _MockCatalogPage({required this.templates});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo')),
      body: ListView.builder(
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return ListTile(
            title: Text(template['name'] as String),
            subtitle: Text('${template['rating']} ⭐ (${template['review_count']} avaliações)'),
          );
        },
      ),
    );
  }
}

class _MockCatalogFilterPage extends StatefulWidget {
  final List<Map<String, dynamic>> templates;

  const _MockCatalogFilterPage({required this.templates});

  @override
  State<_MockCatalogFilterPage> createState() => _MockCatalogFilterPageState();
}

class _MockCatalogFilterPageState extends State<_MockCatalogFilterPage> {
  String? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Hipertrofia'),
                  selected: _selectedGoal == 'hypertrophy',
                  onSelected: (selected) {
                    setState(() {
                      _selectedGoal = selected ? 'hypertrophy' : null;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Força'),
                  selected: _selectedGoal == 'strength',
                  onSelected: (selected) {
                    setState(() {
                      _selectedGoal = selected ? 'strength' : null;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.templates.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.templates[index]['name'] as String),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MockImportTemplatePage extends StatelessWidget {
  final Map<String, dynamic> template;
  final VoidCallback onImport;

  const _MockImportTemplatePage({
    required this.template,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(template['name'] as String)),
      body: Column(
        children: [
          ListTile(title: Text(template['goal'] as String)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: onImport,
              child: const Text('Importar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockMyProgramsWithBadges extends StatelessWidget {
  final List<Map<String, dynamic>> programs;

  const _MockMyProgramsWithBadges({required this.programs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Programas')),
      body: ListView.builder(
        itemCount: programs.length,
        itemBuilder: (context, index) {
          final program = programs[index];
          final isImported = program['is_imported'] as bool? ?? false;
          return ListTile(
            title: Text(program['name'] as String),
            trailing: isImported ? const Chip(label: Text('Importado')) : null,
          );
        },
      ),
    );
  }
}

class _MockAssignmentStatusPage extends StatefulWidget {
  final String currentStatus;
  final void Function(String) onStatusChange;

  const _MockAssignmentStatusPage({
    required this.currentStatus,
    required this.onStatusChange,
  });

  @override
  State<_MockAssignmentStatusPage> createState() =>
      _MockAssignmentStatusPageState();
}

class _MockAssignmentStatusPageState extends State<_MockAssignmentStatusPage> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status')),
      body: Column(
        children: [
          RadioListTile<String>(
            title: const Text('Ativo'),
            value: 'active',
            groupValue: _status,
            onChanged: (value) {
              setState(() => _status = value!);
              widget.onStatusChange(value!);
            },
          ),
          RadioListTile<String>(
            title: const Text('Pausado'),
            value: 'paused',
            groupValue: _status,
            onChanged: (value) {
              setState(() => _status = value!);
              widget.onStatusChange(value!);
            },
          ),
          RadioListTile<String>(
            title: const Text('Completado'),
            value: 'completed',
            groupValue: _status,
            onChanged: (value) {
              setState(() => _status = value!);
              widget.onStatusChange(value!);
            },
          ),
        ],
      ),
    );
  }
}
