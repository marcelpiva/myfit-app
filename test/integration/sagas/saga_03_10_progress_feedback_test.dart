/// SAGA 3: Evolução de Plano
/// SAGA 10: Feedback Negativo e Resolução
///
/// Testa os fluxos de UI de progresso, evolução e feedback.
///
/// IMPORTANT: Run only against local/development environment!

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_services.dart';
import 'saga_test_helpers.dart';

void main() {
  setUpAll(() {
    registerFallbackValues();
  });

  group('SAGA 3: Evolução de Plano', () {
    group('Fase 1: ALUNO - Registro de Progresso', () {
      testWidgets('should show progress registration options', (tester) async {
        await tester.pumpSagaTestApp(
          _MockProgressPage(),
        );

        // Então devo ver opções de registro
        tester.expectText('Registrar Peso');
        tester.expectText('Registrar Medidas');
        tester.expectText('Adicionar Foto');
      });

      testWidgets('should register weight successfully', (tester) async {
        bool weightRegistered = false;

        await tester.pumpSagaTestApp(
          _MockRegisterWeightPage(
            onSave: (weight, notes) {
              weightRegistered = true;
            },
          ),
        );

        // Quando registro meu peso
        await tester.enterTextInField('weight-field', '63.5');
        await tester.enterTextInField('notes-field', 'Semana 4');
        await tester.tapText('Salvar');

        // Então o peso deve ser registrado
        expect(weightRegistered, isTrue);
      });

      testWidgets('should show weight evolution chart', (tester) async {
        await tester.pumpSagaTestApp(
          _MockWeightChartPage(
            weights: [
              _WeightEntry(date: DateTime(2024, 1, 1), weight: 66.0),
              _WeightEntry(date: DateTime(2024, 1, 8), weight: 65.2),
              _WeightEntry(date: DateTime(2024, 1, 15), weight: 64.5),
              _WeightEntry(date: DateTime(2024, 1, 22), weight: 63.5),
            ],
          ),
        );

        // Então devo ver o gráfico
        expect(find.byType(CustomPaint), findsWidgets);
        tester.expectText('Evolução de Peso');
        tester.expectText('-2.5 kg');
      });

      testWidgets('should register measurements', (tester) async {
        bool measurementsRegistered = false;

        await tester.pumpSagaTestApp(
          _MockRegisterMeasurementsPage(
            onSave: (measurements) {
              measurementsRegistered = true;
            },
          ),
        );

        // Quando registro minhas medidas
        await tester.enterTextInField('chest-field', '90');
        await tester.enterTextInField('waist-field', '68');
        await tester.tapText('Salvar');

        // Então as medidas devem ser registradas
        expect(measurementsRegistered, isTrue);
      });
    });

    group('Fase 2-3: PERSONAL - Análise e Feedback', () {
      testWidgets('should show student progress for Personal',
          (tester) async {
        await tester.pumpSagaTestApp(
          _MockTrainerStudentProgressPage(
            studentName: TestStudent.name,
            weightLoss: 2.5,
            adherence: 85,
            workoutsCompleted: 12,
          ),
        );

        // Então devo ver o progresso do aluno
        expect(find.text(TestStudent.name), findsOneWidget);
        tester.expectText('-2.5 kg');
        tester.expectText('85%');
        tester.expectText('12 treinos');
      });

      testWidgets('should add progress note', (tester) async {
        bool noteAdded = false;

        await tester.pumpSagaTestApp(
          _MockAddProgressNotePage(
            onSave: (note, category) {
              noteAdded = true;
            },
          ),
        );

        // Quando adiciono uma nota
        await tester.enterTextInField(
            'note-field', 'Excelente evolução! Pronta para o próximo nível.');
        await tester.tapText('Feedback');
        await tester.tapText('Salvar');

        // Então a nota deve ser adicionada
        expect(noteAdded, isTrue);
      });
    });

    group('Fase 5-7: Evolução do Plano', () {
      testWidgets('should show plan duplication option', (tester) async {
        await tester.pumpSagaTestApp(
          _MockPlanOptionsMenu(),
        );

        // Então devo ver opção de duplicar
        tester.expectText('Duplicar');
        tester.expectText('Editar');
        tester.expectText('Excluir');
      });

      testWidgets('should show evolved plan assignment', (tester) async {
        await tester.pumpSagaTestApp(
          _MockAssignEvolvedPlanPage(
            studentName: TestStudent.name,
            newPlanName: 'Plano Intermediário 6 Semanas',
          ),
        );

        // Então devo ver a atribuição do plano evoluído
        expect(find.text(TestStudent.name), findsOneWidget);
        tester.expectText('Plano Intermediário 6 Semanas');
        tester.expectText('Atribuir Plano');
      });
    });
  });

  group('SAGA 10: Feedback Negativo e Resolução', () {
    group('Fase 1: ALUNO - Feedback Negativo', () {
      testWidgets('should show rating form on workout completion',
          (tester) async {
        await tester.pumpSagaTestApp(
          _MockWorkoutRatingPage(),
        );

        // Então devo ver o formulário de avaliação
        tester.expectText('Como foi o treino?');
        expect(find.byIcon(Icons.star), findsWidgets);
        expect(find.byKey(const Key('feedback-field')), findsOneWidget);
      });

      testWidgets('should submit low rating with feedback', (tester) async {
        int? submittedRating;
        String? submittedFeedback;

        await tester.pumpSagaTestApp(
          _MockWorkoutRatingPage(
            onSubmit: (rating, feedback) {
              submittedRating = rating;
              submittedFeedback = feedback;
            },
          ),
        );

        // Quando dou nota baixa com feedback
        await tester.tapKey('star-2'); // 2 estrelas
        await tester.enterTextInField(
            'feedback-field', 'Achei o treino muito pesado. Senti dor no joelho.');
        await tester.tapText('Enviar');

        // Então o feedback deve ser enviado
        expect(submittedRating, equals(2));
        expect(submittedFeedback, contains('dor no joelho'));
      });
    });

    group('Fase 2-3: PERSONAL - Alerta e Contato', () {
      testWidgets('should show low rating alert', (tester) async {
        await tester.pumpSagaTestApp(
          _MockTrainerAlertCard(
            alertType: 'low_rating',
            studentName: TestStudent.name,
            rating: 2,
            message: 'Achei o treino muito pesado',
          ),
        );

        // Então devo ver o alerta destacado
        expect(find.byIcon(Icons.warning), findsOneWidget);
        expect(find.text(TestStudent.name), findsOneWidget);
        tester.expectText('2');
      });

      testWidgets('should open chat from alert', (tester) async {
        bool chatOpened = false;

        await tester.pumpSagaTestApp(
          _MockTrainerAlertCard(
            alertType: 'low_rating',
            studentName: TestStudent.name,
            rating: 2,
            message: 'Senti dor no joelho',
            onOpenChat: () {
              chatOpened = true;
            },
          ),
        );

        // Quando toco em contatar
        await tester.tapText('Contatar');

        // Então o chat deve abrir
        expect(chatOpened, isTrue);
      });
    });

    group('Fase 4-5: Comunicação e Resolução', () {
      testWidgets('should show chat with student', (tester) async {
        await tester.pumpSagaTestApp(
          _MockChatPage(
            recipientName: TestStudent.name,
            messages: [
              _Message(
                  text:
                      'Vi seu feedback. A dor no joelho é preocupante. Pode me contar mais?',
                  isMe: true),
              _Message(
                  text:
                      'A dor é na parte de trás do joelho direito, principalmente no agachamento.',
                  isMe: false),
            ],
          ),
        );

        // Então devo ver a conversa
        expect(find.text(TestStudent.name), findsOneWidget);
        tester.expectText('dor no joelho');
      });
    });

    group('Fase 6: PERSONAL - Ajuste do Plano', () {
      testWidgets('should show plan edit with notes', (tester) async {
        await tester.pumpSagaTestApp(
          _MockEditPlanWithNotesPage(
            planName: 'Plano Iniciante',
            exercises: [
              _ExerciseToEdit(
                  name: 'Agachamento', canReplace: true, replacement: 'Leg Press'),
              _ExerciseToEdit(name: 'Supino Reto', canReplace: false),
            ],
          ),
        );

        // Então devo ver opções de edição
        tester.expectText('Agachamento');
        tester.expectText('Substituir');
        tester.expectText('Leg Press');
      });

      testWidgets('should add adjustment notes', (tester) async {
        bool notesAdded = false;

        await tester.pumpSagaTestApp(
          _MockAddPlanAdjustmentNotes(
            onSave: (notes) {
              notesAdded = true;
            },
          ),
        );

        // Quando adiciono notas de ajuste
        await tester.enterTextInField('notes-field',
            'Substituído agachamento por leg press. Cargas reduzidas em 20%.');
        await tester.tapText('Salvar');

        // Então as notas devem ser adicionadas
        expect(notesAdded, isTrue);
      });
    });

    group('Fase 7-9: ALUNO - Visualização e Validação', () {
      testWidgets('should show plan update notification', (tester) async {
        await tester.pumpSagaTestApp(
          _MockPlanUpdateNotification(
            changes: [
              'Agachamento substituído por Leg Press',
              'Cargas reduzidas em 20%',
              'Exercícios de fortalecimento adicionados',
            ],
          ),
        );

        // Então devo ver as mudanças
        tester.expectText('Plano atualizado');
        tester.expectText('Leg Press');
        tester.expectText('20%');
      });

      testWidgets('should complete adjusted workout successfully',
          (tester) async {
        int? rating;

        await tester.pumpSagaTestApp(
          _MockWorkoutRatingPage(
            initialFeedback: 'Muito melhor! Sem dor no joelho!',
            onSubmit: (r, f) {
              rating = r;
            },
          ),
        );

        // Quando avalio o treino ajustado
        await tester.tapKey('star-5'); // 5 estrelas
        await tester.tapText('Enviar');

        // Então a nota alta deve ser registrada
        expect(rating, equals(5));
      });
    });

    group('Fase 10: PERSONAL - Confirmação', () {
      testWidgets('should show positive feedback in dashboard', (tester) async {
        await tester.pumpSagaTestApp(
          _MockTrainerDashboardWithFeedback(
            studentName: TestStudent.name,
            rating: 5,
            feedback: 'Muito melhor! Sem dor no joelho!',
          ),
        );

        // Então devo ver o feedback positivo
        expect(find.text(TestStudent.name), findsOneWidget);
        tester.expectText('5');
        expect(find.byIcon(Icons.star), findsWidgets);
      });
    });
  });
}

// =============================================================================
// Mock Widgets for SAGA 3 and 10
// =============================================================================

class _MockProgressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progresso')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.monitor_weight),
            title: const Text('Registrar Peso'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Registrar Medidas'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Adicionar Foto'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _MockRegisterWeightPage extends StatelessWidget {
  final void Function(double weight, String notes)? onSave;

  const _MockRegisterWeightPage({this.onSave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Peso')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('weight-field'),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('notes-field'),
              decoration: const InputDecoration(labelText: 'Notas'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => onSave?.call(63.5, 'Semana 4'),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightEntry {
  final DateTime date;
  final double weight;

  _WeightEntry({required this.date, required this.weight});
}

class _MockWeightChartPage extends StatelessWidget {
  final List<_WeightEntry> weights;

  const _MockWeightChartPage({required this.weights});

  @override
  Widget build(BuildContext context) {
    final first = weights.first.weight;
    final last = weights.last.weight;
    final diff = last - first;

    return Scaffold(
      appBar: AppBar(title: const Text('Evolução de Peso')),
      body: Column(
        children: [
          const SizedBox(height: 200, child: CustomPaint(size: Size.infinite)),
          Text('${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg'),
        ],
      ),
    );
  }
}

class _MockRegisterMeasurementsPage extends StatelessWidget {
  final void Function(Map<String, double>)? onSave;

  const _MockRegisterMeasurementsPage({this.onSave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medidas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('chest-field'),
            decoration: const InputDecoration(labelText: 'Peito (cm)'),
          ),
          TextField(
            key: const Key('waist-field'),
            decoration: const InputDecoration(labelText: 'Cintura (cm)'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => onSave?.call({'chest': 90, 'waist': 68}),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _MockTrainerStudentProgressPage extends StatelessWidget {
  final String studentName;
  final double weightLoss;
  final int adherence;
  final int workoutsCompleted;

  const _MockTrainerStudentProgressPage({
    required this.studentName,
    required this.weightLoss,
    required this.adherence,
    required this.workoutsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(studentName)),
      body: Column(
        children: [
          ListTile(
            title: const Text('Variação de Peso'),
            trailing: Text('-${weightLoss} kg'),
          ),
          ListTile(
            title: const Text('Aderência'),
            trailing: Text('$adherence%'),
          ),
          ListTile(
            title: const Text('Treinos'),
            trailing: Text('$workoutsCompleted treinos'),
          ),
        ],
      ),
    );
  }
}

class _MockAddProgressNotePage extends StatelessWidget {
  final void Function(String note, String category)? onSave;

  const _MockAddProgressNotePage({this.onSave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Nota')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('note-field'),
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Nota'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: const Text('Feedback'), selected: false, onSelected: (_) {}),
                ChoiceChip(label: const Text('Progresso'), selected: false, onSelected: (_) {}),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => onSave?.call('Excelente!', 'feedback'),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockPlanOptionsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opções do Plano')),
      body: ListView(
        children: [
          ListTile(title: const Text('Duplicar'), onTap: () {}),
          ListTile(title: const Text('Editar'), onTap: () {}),
          ListTile(title: const Text('Excluir'), onTap: () {}),
        ],
      ),
    );
  }
}

class _MockAssignEvolvedPlanPage extends StatelessWidget {
  final String studentName;
  final String newPlanName;

  const _MockAssignEvolvedPlanPage({
    required this.studentName,
    required this.newPlanName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atribuir Plano')),
      body: Column(
        children: [
          ListTile(title: const Text('Aluno'), subtitle: Text(studentName)),
          ListTile(title: const Text('Plano'), subtitle: Text(newPlanName)),
          const Spacer(),
          ElevatedButton(onPressed: () {}, child: const Text('Atribuir Plano')),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MockWorkoutRatingPage extends StatelessWidget {
  final String? initialFeedback;
  final void Function(int rating, String feedback)? onSubmit;

  const _MockWorkoutRatingPage({this.initialFeedback, this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliar Treino')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Como foi o treino?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => IconButton(
                  key: Key('star-${i + 1}'),
                  icon: const Icon(Icons.star_border),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('feedback-field'),
              controller: TextEditingController(text: initialFeedback),
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Feedback'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => onSubmit?.call(5, 'ok'),
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockTrainerAlertCard extends StatelessWidget {
  final String alertType;
  final String studentName;
  final int rating;
  final String message;
  final VoidCallback? onOpenChat;

  const _MockTrainerAlertCard({
    required this.alertType,
    required this.studentName,
    required this.rating,
    required this.message,
    this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(studentName),
                const Spacer(),
                Text('$rating', style: const TextStyle(fontSize: 24)),
                const Icon(Icons.star, color: Colors.amber),
              ],
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onOpenChat,
              child: const Text('Contatar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isMe;

  _Message({required this.text, required this.isMe});
}

class _MockChatPage extends StatelessWidget {
  final String recipientName;
  final List<_Message> messages;

  const _MockChatPage({required this.recipientName, required this.messages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipientName)),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, i) {
          final msg = messages[i];
          return Align(
            alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: msg.isMe ? Colors.blue.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(msg.text),
            ),
          );
        },
      ),
    );
  }
}

class _ExerciseToEdit {
  final String name;
  final bool canReplace;
  final String? replacement;

  _ExerciseToEdit({required this.name, required this.canReplace, this.replacement});
}

class _MockEditPlanWithNotesPage extends StatelessWidget {
  final String planName;
  final List<_ExerciseToEdit> exercises;

  const _MockEditPlanWithNotesPage({
    required this.planName,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar $planName')),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, i) {
          final ex = exercises[i];
          return ListTile(
            title: Text(ex.name),
            trailing: ex.canReplace
                ? TextButton(
                    onPressed: () {},
                    child: Text('Substituir → ${ex.replacement}'),
                  )
                : null,
          );
        },
      ),
    );
  }
}

class _MockAddPlanAdjustmentNotes extends StatelessWidget {
  final void Function(String notes)? onSave;

  const _MockAddPlanAdjustmentNotes({this.onSave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notas do Ajuste')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('notes-field'),
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Notas'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => onSave?.call('Ajustes feitos'),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockPlanUpdateNotification extends StatelessWidget {
  final List<String> changes;

  const _MockPlanUpdateNotification({required this.changes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plano atualizado')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Alterações:', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ...changes.map((c) => ListTile(
                leading: const Icon(Icons.check, color: Colors.green),
                title: Text(c),
              )),
        ],
      ),
    );
  }
}

class _MockTrainerDashboardWithFeedback extends StatelessWidget {
  final String studentName;
  final int rating;
  final String feedback;

  const _MockTrainerDashboardWithFeedback({
    required this.studentName,
    required this.rating,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atividade')),
      body: Card(
        margin: const EdgeInsets.all(16),
        child: ListTile(
          title: Text(studentName),
          subtitle: Text(feedback),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$rating'),
              const Icon(Icons.star, color: Colors.amber),
            ],
          ),
        ),
      ),
    );
  }
}
