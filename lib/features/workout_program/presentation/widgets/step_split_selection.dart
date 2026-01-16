import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/models/workout_program.dart';
import '../providers/program_wizard_provider.dart';

/// Step 3: Training split selection
class StepSplitSelection extends ConsumerWidget {
  const StepSplitSelection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(programWizardProvider);
    final notifier = ref.read(programWizardProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final splits = [
      (
        SplitType.abc,
        'ABC',
        '3 treinos',
        'Classico para iniciantes e intermediarios',
        ['A', 'B', 'C'],
      ),
      (
        SplitType.abcd,
        'ABCD',
        '4 treinos',
        'Mais volume por grupo muscular',
        ['A', 'B', 'C', 'D'],
      ),
      (
        SplitType.abcde,
        'ABCDE',
        '5 treinos',
        'Para atletas avancados',
        ['A', 'B', 'C', 'D', 'E'],
      ),
      (
        SplitType.pushPullLegs,
        'Push/Pull/Legs',
        '3 treinos',
        'Empurrar, Puxar e Pernas',
        ['Push', 'Pull', 'Legs'],
      ),
      (
        SplitType.upperLower,
        'Upper/Lower',
        '2 treinos',
        'Superior e Inferior',
        ['Upper', 'Lower'],
      ),
      (
        SplitType.fullBody,
        'Full Body',
        '1 treino',
        'Corpo inteiro em cada sessao',
        ['Full'],
      ),
      (
        SplitType.custom,
        'Personalizado',
        'Flexivel',
        'Configure do seu jeito',
        <String>[],
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Divisao de Treino',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha como seu programa sera estruturado',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Split options
          ...splits.map((item) {
            final isSelected = state.splitType == item.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.selectSplit(item.$1);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withAlpha(20)
                        : (isDark
                            ? theme.colorScheme.surfaceContainerLowest
                                .withAlpha(150)
                            : theme.colorScheme.surfaceContainerLowest
                                .withAlpha(200)),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.primary
                                  : theme.colorScheme.outline
                                      .withValues(alpha: 0.2),
                            ),
                            child: isSelected
                                ? const Icon(
                                    LucideIcons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item.$2,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.primary
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.outline
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.$3,
                                        style:
                                            theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.$4,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (item.$5.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: item.$5.map((label) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withAlpha(30)
                                    : theme.colorScheme.outline
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                label,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
