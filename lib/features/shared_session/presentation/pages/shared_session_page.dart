/// Shared workout session page for co-training.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/providers/context_provider.dart';
import '../../domain/models/shared_session.dart';
import '../providers/shared_session_provider.dart';
import '../widgets/live_indicator.dart';
import '../widgets/session_chat.dart';
import '../widgets/trainer_controls.dart';

/// Mode for the shared session page.
enum SessionMode {
  student,  // User is executing the workout
  trainer,  // User is observing/guiding
}

/// Page for viewing/managing a shared workout session.
class SharedSessionPage extends ConsumerStatefulWidget {
  final String sessionId;
  final SessionMode mode;

  const SharedSessionPage({
    super.key,
    required this.sessionId,
    required this.mode,
  });

  @override
  ConsumerState<SharedSessionPage> createState() => _SharedSessionPageState();
}

class _SharedSessionPageState extends ConsumerState<SharedSessionPage> {
  bool _showChat = false;

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sharedSessionProvider(widget.sessionId));
    final theme = Theme.of(context);

    if (sessionState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carregando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (sessionState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.alertCircle, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar sessão',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                sessionState.error!,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => ref
                    .read(sharedSessionProvider(widget.sessionId).notifier)
                    .refresh(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final session = sessionState.session;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sessão não encontrada')),
        body: const Center(child: Text('Sessão não encontrada')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == SessionMode.trainer ? 'Acompanhando' : 'Treino'),
        actions: [
          // Live indicator
          LiveIndicator(
            isConnected: sessionState.isConnected,
            isShared: session.isShared,
          ),
          // Chat toggle
          IconButton(
            icon: Badge(
              isLabelVisible: session.messages.isNotEmpty,
              label: Text('${session.messages.length}'),
              child: Icon(_showChat ? LucideIcons.x : LucideIcons.messageCircle),
            ),
            onPressed: () => setState(() => _showChat = !_showChat),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          _buildMainContent(context, session, sessionState),

          // Chat overlay
          if (_showChat)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.35,
              child: SessionChat(
                sessionId: widget.sessionId,
                messages: session.messages,
                onClose: () => setState(() => _showChat = false),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, session),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    SharedSession session,
    SharedSessionState state,
  ) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        // Status header
        SliverToBoxAdapter(
          child: _buildStatusHeader(context, session),
        ),

        // Current exercise info
        SliverToBoxAdapter(
          child: _buildCurrentExercise(context, session),
        ),

        // Trainer adjustments (if any)
        if (session.adjustments.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildAdjustmentsSection(context, session),
          ),

        // Sets completed
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Séries Completadas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (session.sets.isEmpty)
                  Text(
                    'Nenhuma série completada ainda',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  ...session.sets.reversed.take(10).map(
                        (set) => _buildSetCard(context, set),
                      ),
              ],
            ),
          ),
        ),

        // Trainer controls (if trainer mode)
        if (widget.mode == SessionMode.trainer)
          SliverToBoxAdapter(
            child: TrainerControls(
              sessionId: widget.sessionId,
              currentExerciseId: _getCurrentExerciseId(session),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusHeader(BuildContext context, SharedSession session) {
    final theme = Theme.of(context);

    final statusInfo = _getStatusInfo(session.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusInfo.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusInfo.icon, color: statusInfo.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getElapsedTime(session.startedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (session.isShared)
            Chip(
              avatar: const Icon(LucideIcons.users, size: 16),
              label: const Text('Co-Training'),
              backgroundColor: theme.colorScheme.primaryContainer,
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentExercise(BuildContext context, SharedSession session) {
    final theme = Theme.of(context);

    // TODO: Get actual current exercise from workout
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.dumbbell,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Exercício Atual',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Supino Reto', // TODO: Get from workout
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildExerciseChip(context, '4 séries', LucideIcons.repeat),
              const SizedBox(width: 8),
              _buildExerciseChip(context, '10-12 reps', LucideIcons.hash),
              const SizedBox(width: 8),
              _buildExerciseChip(context, '60s descanso', LucideIcons.timer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseChip(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentsSection(BuildContext context, SharedSession session) {
    final theme = Theme.of(context);
    final latestAdjustment = session.adjustments.last;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.secondary),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.sparkles,
              color: theme.colorScheme.onSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajuste do Personal',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatAdjustment(latestAdjustment),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetCard(BuildContext context, SessionSet set) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text('${set.setNumber}'),
        ),
        title: Text('${set.repsCompleted} reps'),
        subtitle: set.weightKg != null ? Text('${set.weightKg} kg') : null,
        trailing: Text(
          _formatTime(set.performedAt),
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, SharedSession session) {
    final theme = Theme.of(context);
    final notifier = ref.read(sharedSessionProvider(widget.sessionId).notifier);

    if (session.status == SessionStatus.completed) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Voltar'),
          ),
        ),
      );
    }

    if (widget.mode == SessionMode.trainer) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => notifier.leaveAsTrainer(),
                  icon: const Icon(LucideIcons.logOut),
                  label: const Text('Sair'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    // Open adjustment dialog
                    _showAdjustmentDialog(context);
                  },
                  icon: const Icon(LucideIcons.sliders),
                  label: const Text('Ajustar'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Student mode
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (session.status == SessionStatus.active)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => notifier.updateStatus(SessionStatus.paused),
                  icon: const Icon(LucideIcons.pause),
                  label: const Text('Pausar'),
                ),
              )
            else if (session.status == SessionStatus.paused)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => notifier.updateStatus(SessionStatus.active),
                  icon: const Icon(LucideIcons.play),
                  label: const Text('Continuar'),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => notifier.updateStatus(SessionStatus.completed),
                icon: const Icon(LucideIcons.checkCircle),
                label: const Text('Finalizar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustmentDialog(BuildContext context) {
    final notifier = ref.read(sharedSessionProvider(widget.sessionId).notifier);
    final weightController = TextEditingController();
    final repsController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sugerir Ajuste',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Nota (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final weight = double.tryParse(weightController.text);
                final reps = int.tryParse(repsController.text);
                final note = noteController.text.isEmpty ? null : noteController.text;

                notifier.createAdjustment(
                  exerciseId: _getCurrentExerciseId(ref.read(sharedSessionProvider(widget.sessionId)).session!) ?? '',
                  suggestedWeight: weight,
                  suggestedReps: reps,
                  note: note,
                );

                Navigator.pop(context);
              },
              child: const Text('Enviar Ajuste'),
            ),
          ],
        ),
      ),
    );
  }

  String? _getCurrentExerciseId(SharedSession session) {
    // TODO: Implement based on workout progress
    return null;
  }

  ({String label, IconData icon, Color color}) _getStatusInfo(SessionStatus status) {
    switch (status) {
      case SessionStatus.waiting:
        return (label: 'Aguardando', icon: LucideIcons.clock, color: Colors.orange);
      case SessionStatus.active:
        return (label: 'Em andamento', icon: LucideIcons.play, color: Colors.green);
      case SessionStatus.paused:
        return (label: 'Pausado', icon: LucideIcons.pause, color: Colors.amber);
      case SessionStatus.completed:
        return (label: 'Finalizado', icon: LucideIcons.checkCircle, color: Colors.blue);
    }
  }

  String _getElapsedTime(DateTime startedAt) {
    final elapsed = DateTime.now().difference(startedAt);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    return '${minutes}min ${seconds}s';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatAdjustment(TrainerAdjustment adj) {
    final parts = <String>[];
    if (adj.suggestedWeightKg != null) {
      parts.add('${adj.suggestedWeightKg}kg');
    }
    if (adj.suggestedReps != null) {
      parts.add('${adj.suggestedReps} reps');
    }
    if (adj.note != null) {
      parts.add(adj.note!);
    }
    return parts.join(' - ');
  }
}
