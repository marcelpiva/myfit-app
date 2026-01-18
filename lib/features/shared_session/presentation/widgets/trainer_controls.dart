/// Trainer controls widget for co-training sessions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/shared_session_provider.dart';

/// Controls for trainer during co-training session.
class TrainerControls extends ConsumerStatefulWidget {
  final String sessionId;
  final String? currentExerciseId;

  const TrainerControls({
    super.key,
    required this.sessionId,
    this.currentExerciseId,
  });

  @override
  ConsumerState<TrainerControls> createState() => _TrainerControlsState();
}

class _TrainerControlsState extends ConsumerState<TrainerControls> {
  double? _suggestedWeight;
  int? _suggestedReps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  LucideIcons.sliders,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Controles do Personal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick weight adjustments
          Text(
            'Ajustar Peso',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _WeightChip(
                label: '-5kg',
                onTap: () => _adjustWeight(-5),
                isSelected: _suggestedWeight == -5,
              ),
              _WeightChip(
                label: '-2.5kg',
                onTap: () => _adjustWeight(-2.5),
                isSelected: _suggestedWeight == -2.5,
              ),
              _WeightChip(
                label: '+2.5kg',
                onTap: () => _adjustWeight(2.5),
                isSelected: _suggestedWeight == 2.5,
              ),
              _WeightChip(
                label: '+5kg',
                onTap: () => _adjustWeight(5),
                isSelected: _suggestedWeight == 5,
              ),
              _WeightChip(
                label: '+10kg',
                onTap: () => _adjustWeight(10),
                isSelected: _suggestedWeight == 10,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick reps adjustments
          Text(
            'Ajustar Reps',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _RepsChip(
                label: '-2 reps',
                onTap: () => _adjustReps(-2),
                isSelected: _suggestedReps == -2,
              ),
              _RepsChip(
                label: '-1 rep',
                onTap: () => _adjustReps(-1),
                isSelected: _suggestedReps == -1,
              ),
              _RepsChip(
                label: '+1 rep',
                onTap: () => _adjustReps(1),
                isSelected: _suggestedReps == 1,
              ),
              _RepsChip(
                label: '+2 reps',
                onTap: () => _adjustReps(2),
                isSelected: _suggestedReps == 2,
              ),
              _RepsChip(
                label: 'AMRAP',
                onTap: () => _adjustReps(99),
                isSelected: _suggestedReps == 99,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick notes
          Text(
            'Mensagens Rapidas',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _NoteChip(
                icon: LucideIcons.thumbsUp,
                label: 'Otimo!',
                onTap: () => _sendNote('Otimo trabalho!'),
              ),
              _NoteChip(
                icon: LucideIcons.focus,
                label: 'Foco',
                onTap: () => _sendNote('Mantenha o foco!'),
              ),
              _NoteChip(
                icon: LucideIcons.arrowDown,
                label: 'Devagar',
                onTap: () => _sendNote('Execute mais devagar'),
              ),
              _NoteChip(
                icon: LucideIcons.ruler,
                label: 'Amplitude',
                onTap: () => _sendNote('Aumentar amplitude'),
              ),
              _NoteChip(
                icon: LucideIcons.coffee,
                label: 'Descanso',
                onTap: () => _sendNote('Pode descansar mais'),
              ),
            ],
          ),

          // Send button
          if (_suggestedWeight != null || _suggestedReps != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sendAdjustment,
                icon: const Icon(LucideIcons.send),
                label: Text(_buildAdjustmentLabel()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _adjustWeight(double delta) {
    setState(() {
      _suggestedWeight = _suggestedWeight == delta ? null : delta;
    });
  }

  void _adjustReps(int delta) {
    setState(() {
      _suggestedReps = _suggestedReps == delta ? null : delta;
    });
  }

  void _sendNote(String note) {
    ref
        .read(sharedSessionProvider(widget.sessionId).notifier)
        .sendMessage(note);
  }

  void _sendAdjustment() {
    if (widget.currentExerciseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum exercicio atual')),
      );
      return;
    }

    ref.read(sharedSessionProvider(widget.sessionId).notifier).createAdjustment(
      exerciseId: widget.currentExerciseId!,
      suggestedWeight: _suggestedWeight,
      suggestedReps: _suggestedReps,
    );

    setState(() {
      _suggestedWeight = null;
      _suggestedReps = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ajuste enviado!')),
    );
  }

  String _buildAdjustmentLabel() {
    final parts = <String>[];
    if (_suggestedWeight != null) {
      final sign = _suggestedWeight! > 0 ? '+' : '';
      parts.add('$sign${_suggestedWeight}kg');
    }
    if (_suggestedReps != null) {
      if (_suggestedReps == 99) {
        parts.add('AMRAP');
      } else {
        final sign = _suggestedReps! > 0 ? '+' : '';
        parts.add('$sign${_suggestedReps} reps');
      }
    }
    return 'Enviar: ${parts.join(', ')}';
  }
}

class _WeightChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _WeightChip({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
    );
  }
}

class _RepsChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _RepsChip({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.secondaryContainer,
      checkmarkColor: theme.colorScheme.secondary,
    );
  }
}

class _NoteChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NoteChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
