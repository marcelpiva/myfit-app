import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../providers/plan_wizard_provider.dart';

/// Step 5: Review the program before creating
class StepReview extends ConsumerWidget {
  const StepReview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(planWizardProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revisar Plano',
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
                            state.planName.isEmpty
                                ? 'Plano sem nome'
                                : state.planName,
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
                // First row of stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: LucideIcons.calendar,
                      value: state.splitTypeName,
                      label: 'Divisão',
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
                      label: 'Exercícios',
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
                // Second row: time stats
                Builder(
                  builder: (context) {
                    final totalMinutes = state.workouts.fold<int>(
                      0,
                      (sum, w) => sum + w.exercises.fold<int>(
                        0,
                        (es, e) => es + e.estimatedSeconds,
                      ),
                    ) ~/ 60;
                    final targetPerWorkout = state.targetWorkoutMinutes;
                    final hasTimeTarget = targetPerWorkout != null;

                    // Format total time
                    String formatTime(int minutes) {
                      if (minutes >= 60) {
                        final hours = minutes ~/ 60;
                        final mins = minutes % 60;
                        return mins > 0 ? '${hours}h${mins}m' : '${hours}h';
                      }
                      return '${minutes}m';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: LucideIcons.clock,
                            value: hasTimeTarget ? '${targetPerWorkout}m' : 'Livre',
                            label: 'Por Treino',
                            theme: theme,
                          ),
                          _StatItem(
                            icon: LucideIcons.timerReset,
                            value: formatTime(totalMinutes),
                            label: 'Tempo Total',
                            theme: theme,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Workouts List
          Text(
            'Treinos do Plano',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          ...state.workouts.map((workout) {
            // Calculate workout duration
            final workoutMinutes = workout.exercises.fold<int>(
              0,
              (sum, e) => sum + e.estimatedSeconds,
            ) ~/ 60;
            final targetMinutes = state.targetWorkoutMinutes;
            final hasTimeTarget = targetMinutes != null;
            final isOverTime = hasTimeTarget && workoutMinutes > (targetMinutes * 1.2);

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
                            Row(
                              children: [
                                Text(
                                  '${workout.exercises.length} exercícios',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                if (workout.exercises.isNotEmpty) ...[
                                  Text(
                                    ' · ',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  Icon(
                                    LucideIcons.clock,
                                    size: 12,
                                    color: isOverTime
                                        ? AppColors.warning
                                        : theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$workoutMinutes min',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isOverTime
                                          ? AppColors.warning
                                          : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                      fontWeight: isOverTime
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Time warning chip if over time
                      if (workout.exercises.isNotEmpty && isOverTime) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withAlpha(isDark ? 40 : 25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.alertTriangle,
                                size: 10,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '>$targetMinutes',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
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

          // Diet Summary (if included)
          if (state.includeDiet) ...[
            const SizedBox(height: 24),
            Text(
              'Plano Alimentar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                    : theme.colorScheme.surfaceContainerLow.withAlpha(200),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withAlpha(50),
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
                          color: AppColors.success.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.utensils,
                          size: 20,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.dietType?.displayName ?? 'Dieta configurada',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (state.mealsPerDay != null)
                              Text(
                                '${state.mealsPerDay} refeições por dia',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        LucideIcons.checkCircle2,
                        size: 20,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  if (state.dailyCalories != null || state.proteinGrams != null) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (state.dailyCalories != null)
                          _DietStat(
                            value: '${state.dailyCalories}',
                            label: 'kcal',
                            theme: theme,
                          ),
                        if (state.proteinGrams != null)
                          _DietStat(
                            value: '${state.proteinGrams}g',
                            label: 'Proteína',
                            theme: theme,
                          ),
                        if (state.carbsGrams != null)
                          _DietStat(
                            value: '${state.carbsGrams}g',
                            label: 'Carbs',
                            theme: theme,
                          ),
                        if (state.fatGrams != null)
                          _DietStat(
                            value: '${state.fatGrams}g',
                            label: 'Gordura',
                            theme: theme,
                          ),
                      ],
                    ),
                  ],
                  if (state.dietNotes != null && state.dietNotes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.dietNotes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  String get difficultyName {
    return 'intermediate'; // Will be replaced with actual state value
  }
}

extension on PlanWizardState {
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

class _DietStat extends StatelessWidget {
  final String value;
  final String label;
  final ThemeData theme;

  const _DietStat({
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.success,
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
