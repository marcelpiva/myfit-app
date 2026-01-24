/// SAGA 2: Co-Training - Treino Presencial Acompanhado
///
/// Esta saga testa o fluxo de UI de uma sessão de treino presencial
/// com acompanhamento em tempo real do Personal.
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

  group('SAGA 2: Co-Training', () {
    group('Fase 1: ALUNO - Início com Acompanhamento', () {
      testWidgets('should show co-training option on start', (tester) async {
        await tester.pumpSagaTestApp(
          _MockStartWorkoutOptions(),
        );

        // Então devo ver opção de treinar com Personal
        tester.expectText('Treinar Sozinho');
        tester.expectText('Treinar com Personal');
      });

      testWidgets('should show waiting for Personal', (tester) async {
        await tester.pumpSagaTestApp(
          _MockWaitingForTrainerPage(),
        );

        // Então devo ver status de aguardando
        tester.expectText('Aguardando Personal...');
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should show Personal connected indicator', (tester) async {
        await tester.pumpSagaTestApp(
          _MockCoTrainingActivePage(
            trainerConnected: true,
            trainerName: TestPersonal.name,
          ),
        );

        // Então devo ver indicador de Personal conectado
        tester.expectText('Personal conectado');
        expect(find.byIcon(Icons.person), findsOneWidget);
      });
    });

    group('Fase 4-5: PERSONAL - Ajustes em Tempo Real', () {
      testWidgets('should show adjustment notification', (tester) async {
        await tester.pumpSagaTestApp(
          _MockAdjustmentNotification(
            suggestedWeight: 30.0,
            note: 'Ótima execução! Pode aumentar.',
          ),
        );

        // Então devo ver a sugestão de ajuste
        tester.expectText('Personal sugere: 30.0kg');
        tester.expectText('Ótima execução! Pode aumentar.');
        tester.expectText('Aplicar');
        tester.expectText('Ignorar');
      });

      testWidgets('should apply adjustment', (tester) async {
        bool adjustmentApplied = false;

        await tester.pumpSagaTestApp(
          _MockAdjustmentNotification(
            suggestedWeight: 30.0,
            note: 'Ótima execução!',
            onApply: () {
              adjustmentApplied = true;
            },
          ),
        );

        // Quando aplico o ajuste
        await tester.tapText('Aplicar');

        // Então o ajuste deve ser aplicado
        expect(adjustmentApplied, isTrue);
      });
    });

    group('Fase 6-7: Mensagens Durante Treino', () {
      testWidgets('should show chat messages', (tester) async {
        await tester.pumpSagaTestApp(
          _MockSessionChatPage(
            messages: [
              _ChatMessage(
                sender: 'Personal',
                text: 'Mantenha as costas retas!',
                isTrainer: true,
              ),
            ],
          ),
        );

        // Então devo ver a mensagem
        tester.expectText('Mantenha as costas retas!');
      });

      testWidgets('should send message to Personal', (tester) async {
        bool messageSent = false;

        await tester.pumpSagaTestApp(
          _MockSessionChatPage(
            messages: [],
            onSendMessage: (msg) {
              messageSent = true;
            },
          ),
        );

        // Quando envio uma mensagem
        await tester.enterTextInField('chat-input', 'Posso aumentar a carga?');
        await tester.tapKey('send-button');

        // Então a mensagem deve ser enviada
        expect(messageSent, isTrue);
      });
    });

    group('Fase 10: ALUNO - Conclusão com Co-Training', () {
      testWidgets('should show co-training completion summary', (tester) async {
        await tester.pumpSagaTestApp(
          _MockCoTrainingCompletionPage(
            duration: const Duration(minutes: 55),
            exercisesCompleted: 5,
            adjustmentsReceived: 2,
            messagesExchanged: 4,
          ),
        );

        // Então devo ver o resumo com dados do co-training
        tester.expectText('Treino Concluído!');
        tester.expectText('55 min');
        tester.expectText('2 ajustes');
        tester.expectText('4 mensagens');
      });
    });

    group('Fase 11: PERSONAL - Visualização', () {
      testWidgets('should show student training now', (tester) async {
        await tester.pumpSagaTestApp(
          _MockTrainerDashboardWithActiveStudent(
            studentName: TestStudent.name,
            workoutName: 'Treino A - Peito e Tríceps',
            exerciseName: 'Supino Reto',
            currentSet: 2,
          ),
        );

        // Então devo ver o aluno treinando
        tester.expectText('Alunos Agora');
        expect(find.text(TestStudent.name), findsOneWidget);
        tester.expectText('Supino Reto - Série 2');
      });

      testWidgets('should join co-training session', (tester) async {
        bool sessionJoined = false;

        await tester.pumpSagaTestApp(
          _MockTrainerDashboardWithActiveStudent(
            studentName: TestStudent.name,
            workoutName: 'Treino A',
            exerciseName: 'Supino Reto',
            currentSet: 1,
            onJoinSession: () {
              sessionJoined = true;
            },
          ),
        );

        // Quando toco em acompanhar
        await tester.tapText('Acompanhar');

        // Então devo entrar na sessão
        expect(sessionJoined, isTrue);
      });

      testWidgets('should show co-training controls', (tester) async {
        await tester.pumpSagaTestApp(
          _MockTrainerCoTrainingPage(
            studentName: TestStudent.name,
            exerciseName: 'Supino Reto',
            currentSet: 2,
            totalSets: 4,
          ),
        );

        // Então devo ver os controles de co-training
        tester.expectText('Sugerir Ajuste');
        tester.expectText('Enviar Mensagem');
        tester.expectText('Sair da Sessão');
      });

      testWidgets('should send weight adjustment', (tester) async {
        bool adjustmentSent = false;

        await tester.pumpSagaTestApp(
          _MockTrainerAdjustmentForm(
            onSendAdjustment: (weight, note) {
              adjustmentSent = true;
            },
          ),
        );

        // Quando envio um ajuste
        await tester.enterTextInField('weight-field', '30');
        await tester.enterTextInField('note-field', 'Pode aumentar!');
        await tester.tapText('Enviar Ajuste');

        // Então o ajuste deve ser enviado
        expect(adjustmentSent, isTrue);
      });
    });
  });
}

// =============================================================================
// Mock Widgets for SAGA 2
// =============================================================================

class _MockStartWorkoutOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Treino')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Treinar Sozinho'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Treinar com Personal'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockWaitingForTrainerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Treino')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('Aguardando Personal...'),
          ],
        ),
      ),
    );
  }
}

class _MockCoTrainingActivePage extends StatelessWidget {
  final bool trainerConnected;
  final String trainerName;

  const _MockCoTrainingActivePage({
    required this.trainerConnected,
    required this.trainerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treino Ativo'),
        actions: [
          if (trainerConnected)
            Chip(
              avatar: const Icon(Icons.person, size: 16),
              label: const Text('Personal conectado'),
              backgroundColor: Colors.green.shade100,
            ),
        ],
      ),
      body: const Center(child: Text('Exercício atual')),
    );
  }
}

class _MockAdjustmentNotification extends StatelessWidget {
  final double suggestedWeight;
  final String note;
  final VoidCallback? onApply;

  const _MockAdjustmentNotification({
    required this.suggestedWeight,
    required this.note,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber, size: 48),
                const SizedBox(height: 16),
                Text('Personal sugere: ${suggestedWeight}kg'),
                Text(note),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Ignorar'),
                    ),
                    ElevatedButton(
                      onPressed: onApply,
                      child: const Text('Aplicar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String sender;
  final String text;
  final bool isTrainer;

  _ChatMessage({
    required this.sender,
    required this.text,
    required this.isTrainer,
  });
}

class _MockSessionChatPage extends StatelessWidget {
  final List<_ChatMessage> messages;
  final void Function(String)? onSendMessage;

  const _MockSessionChatPage({
    required this.messages,
    this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat da Sessão')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ListTile(
                  title: Text(msg.text),
                  subtitle: Text(msg.sender),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('chat-input'),
                    decoration: const InputDecoration(hintText: 'Mensagem...'),
                  ),
                ),
                IconButton(
                  key: const Key('send-button'),
                  onPressed: () => onSendMessage?.call(''),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MockCoTrainingCompletionPage extends StatelessWidget {
  final Duration duration;
  final int exercisesCompleted;
  final int adjustmentsReceived;
  final int messagesExchanged;

  const _MockCoTrainingCompletionPage({
    required this.duration,
    required this.exercisesCompleted,
    required this.adjustmentsReceived,
    required this.messagesExchanged,
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
            Text('$adjustmentsReceived ajustes'),
            Text('$messagesExchanged mensagens'),
          ],
        ),
      ),
    );
  }
}

class _MockTrainerDashboardWithActiveStudent extends StatelessWidget {
  final String studentName;
  final String workoutName;
  final String exerciseName;
  final int currentSet;
  final VoidCallback? onJoinSession;

  const _MockTrainerDashboardWithActiveStudent({
    required this.studentName,
    required this.workoutName,
    required this.exerciseName,
    required this.currentSet,
    this.onJoinSession,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Alunos Agora', style: TextStyle(fontSize: 18)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(studentName),
              subtitle: Text('$exerciseName - Série $currentSet'),
              trailing: ElevatedButton(
                onPressed: onJoinSession,
                child: const Text('Acompanhar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockTrainerCoTrainingPage extends StatelessWidget {
  final String studentName;
  final String exerciseName;
  final int currentSet;
  final int totalSets;

  const _MockTrainerCoTrainingPage({
    required this.studentName,
    required this.exerciseName,
    required this.currentSet,
    required this.totalSets,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Co-Training: $studentName')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(exerciseName, style: const TextStyle(fontSize: 20)),
                  Text('Série $currentSet/$totalSets'),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Sugerir Ajuste'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Enviar Mensagem'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text('Sair da Sessão'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MockTrainerAdjustmentForm extends StatelessWidget {
  final void Function(double weight, String note)? onSendAdjustment;

  const _MockTrainerAdjustmentForm({this.onSendAdjustment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sugerir Ajuste')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('weight-field'),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Peso Sugerido (kg)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('note-field'),
              decoration: const InputDecoration(
                labelText: 'Nota',
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => onSendAdjustment?.call(30, 'Pode aumentar!'),
              child: const Text('Enviar Ajuste'),
            ),
          ],
        ),
      ),
    );
  }
}
