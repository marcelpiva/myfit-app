import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/models/trainer_workout.dart';

/// Card que exibe uma sugestão da IA para evolução do treino
class AISuggestionCard extends StatelessWidget {
  final AISuggestion suggestion;
  final VoidCallback? onApply;
  final VoidCallback? onDismiss;
  final bool expanded;

  const AISuggestionCard({
    super.key,
    required this.suggestion,
    this.onApply,
    this.onDismiss,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(15),
            AppColors.secondary.withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getTypeColor().withAlpha(25),
                ),
                child: Icon(_getTypeIcon(), size: 16, color: _getTypeColor()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    Text(
                      _getTypeLabel(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTypeColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Sparkles badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.sparkles, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'IA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            suggestion.description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),

          // Details (if available)
          if (suggestion.suggestedWeight != null ||
              suggestion.suggestedReps != null ||
              suggestion.newExerciseName != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (suggestion.exerciseName != null) ...[
                    Row(
                      children: [
                        Icon(
                          LucideIcons.dumbbell,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          suggestion.exerciseName!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      if (suggestion.suggestedWeight != null)
                        _buildDetail(
                          isDark,
                          'Carga',
                          '${suggestion.suggestedWeight!.toStringAsFixed(1)}kg',
                          LucideIcons.dumbbell,
                        ),
                      if (suggestion.suggestedReps != null)
                        _buildDetail(
                          isDark,
                          'Reps',
                          '${suggestion.suggestedReps}',
                          LucideIcons.repeat,
                        ),
                      if (suggestion.suggestedSets != null)
                        _buildDetail(
                          isDark,
                          'Séries',
                          '${suggestion.suggestedSets}',
                          LucideIcons.layers,
                        ),
                    ],
                  ),
                  if (suggestion.newExerciseName != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(LucideIcons.plus, size: 14, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Adicionar: ${suggestion.newExerciseName}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Rationale (expandable)
          if (expanded || suggestion.rationale.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withAlpha(15),
                border: Border.all(color: AppColors.info.withAlpha(30)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.lightbulb, size: 16, color: AppColors.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion.rationale,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Actions
          if (onApply != null || onDismiss != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onDismiss != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDismiss,
                      icon: const Icon(LucideIcons.x, size: 16),
                      label: const Text('Ignorar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                    ),
                  ),
                if (onApply != null && onDismiss != null) const SizedBox(width: 12),
                if (onApply != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApply,
                      icon: const Icon(LucideIcons.check, size: 16),
                      label: const Text('Aplicar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetail(bool isDark, String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (suggestion.type) {
      case AISuggestionType.increaseWeight:
        return AppColors.success;
      case AISuggestionType.increaseVolume:
        return AppColors.info;
      case AISuggestionType.deload:
        return AppColors.warning;
      case AISuggestionType.replaceExercise:
        return AppColors.secondary;
      case AISuggestionType.addExercise:
        return AppColors.success;
      case AISuggestionType.removeExercise:
        return AppColors.destructive;
      case AISuggestionType.changePeriodization:
        return AppColors.primary;
      case AISuggestionType.adjustFrequency:
        return AppColors.info;
      case AISuggestionType.focusWeakPoint:
        return AppColors.warning;
      case AISuggestionType.general:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon() {
    switch (suggestion.type) {
      case AISuggestionType.increaseWeight:
        return LucideIcons.trendingUp;
      case AISuggestionType.increaseVolume:
        return LucideIcons.layers;
      case AISuggestionType.deload:
        return LucideIcons.trendingDown;
      case AISuggestionType.replaceExercise:
        return LucideIcons.refreshCw;
      case AISuggestionType.addExercise:
        return LucideIcons.plus;
      case AISuggestionType.removeExercise:
        return LucideIcons.minus;
      case AISuggestionType.changePeriodization:
        return LucideIcons.calendar;
      case AISuggestionType.adjustFrequency:
        return LucideIcons.clock;
      case AISuggestionType.focusWeakPoint:
        return LucideIcons.target;
      case AISuggestionType.general:
        return LucideIcons.sparkles;
    }
  }

  String _getTypeLabel() {
    switch (suggestion.type) {
      case AISuggestionType.increaseWeight:
        return 'Progressão de Carga';
      case AISuggestionType.increaseVolume:
        return 'Aumento de Volume';
      case AISuggestionType.deload:
        return 'Semana de Deload';
      case AISuggestionType.replaceExercise:
        return 'Substituição';
      case AISuggestionType.addExercise:
        return 'Novo Exercício';
      case AISuggestionType.removeExercise:
        return 'Remoção';
      case AISuggestionType.changePeriodization:
        return 'Periodização';
      case AISuggestionType.adjustFrequency:
        return 'Frequência';
      case AISuggestionType.focusWeakPoint:
        return 'Ponto Fraco';
      case AISuggestionType.general:
        return 'Sugestão Geral';
    }
  }
}

/// Card compacto para lista de sugestões
class AISuggestionChip extends StatelessWidget {
  final AISuggestion suggestion;
  final VoidCallback? onTap;

  const AISuggestionChip({
    super.key,
    required this.suggestion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withAlpha(15),
              AppColors.secondary.withAlpha(10),
            ],
          ),
          border: Border.all(color: AppColors.primary.withAlpha(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.sparkles, size: 14, color: AppColors.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                suggestion.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              LucideIcons.chevronRight,
              size: 14,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
