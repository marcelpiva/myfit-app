import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../providers/program_wizard_provider.dart';

/// Step 5: Review the program before creating
class StepReview extends ConsumerWidget {
  const StepReview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(programWizardProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revisar Programa',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Confira todos os detalhes antes de criar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Program Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withAlpha(isDark ? 40 : 30),
                  AppColors.secondary.withAlpha(isDark ? 30 : 20),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withAlpha(50),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(isDark ? 30 : 200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.clipboard,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.programName.isEmpty
                                ? 'Programa sem nome'
                                : state.programName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: [
                              _Badge(
                                label: state.goal.name,
                                color: AppColors.primary,
                                isDark: isDark,
                              ),
                              _Badge(
                                label: state.difficultyName,
                                color: AppColors.secondary,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: LucideIcons.calendar,
                      value: state.splitTypeName,
                      label: 'Divisao',
                      theme: theme,
                    ),
                    _StatItem(
                      icon: LucideIcons.dumbbell,
                      value: '${state.workouts.length}',
                      label: 'Treinos',
                      theme: theme,
                    ),
                    _StatItem(
                      icon: LucideIcons.repeat,
                      value: '${state.totalExerciseCount}',
                      label: 'Exercicios',
                      theme: theme,
                    ),
                    if (state.durationWeeks != null)
                      _StatItem(
                        icon: LucideIcons.timer,
                        value: '${state.durationWeeks}',
                        label: 'Semanas',
                        theme: theme,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Workouts List
          Text(
            'Treinos do Programa',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          ...state.workouts.map((workout) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
                    : theme.colorScheme.surfaceContainerLowest.withAlpha(200),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            workout.label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${workout.exercises.length} exercicios',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        workout.exercises.isNotEmpty
                            ? LucideIcons.checkCircle2
                            : LucideIcons.alertCircle,
                        size: 20,
                        color: workout.exercises.isNotEmpty
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ],
                  ),
                  if (workout.exercises.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: workout.exercises.take(5).map((ex) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ex.name,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (workout.exercises.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '+${workout.exercises.length - 5} mais',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          }),

          // Template option
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                  : theme.colorScheme.surfaceContainerLow.withAlpha(200),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.bookmark,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Salvar como template',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Switch(
                  value: state.isTemplate,
                  onChanged: (value) {
                    ref.read(programWizardProvider.notifier).setIsTemplate(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  String get difficultyName {
    return 'intermediate'; // Will be replaced with actual state value
  }
}

extension on ProgramWizardState {
  String get splitTypeName {
    switch (splitType) {
      case _:
        return splitType.name.toUpperCase();
    }
  }

  String get difficultyName {
    switch (difficulty) {
      case _:
        return difficulty.name;
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _Badge({
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 50 : 30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ThemeData theme;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
