import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../home/presentation/providers/student_home_provider.dart';
import '../providers/workout_provider.dart';
import 'start_workout_sheet.dart';

/// Bottom sheet for choosing which workout to start from the active plan.
/// Shows all workouts with the suggested one highlighted.
class WorkoutPickerSheet extends ConsumerWidget {
  const WorkoutPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final plansState = ref.watch(plansNotifierProvider);
    final dashboardState = ref.watch(studentDashboardProvider);
    final todayWorkout = dashboardState.todayWorkout;

    // Get all workouts from all active plans
    final allWorkouts = <_WorkoutItem>[];
    for (final plan in plansState.plans) {
      final planName = plan['name'] as String? ?? 'Plano';
      final planId = plan['id'] as String?;
      final workouts = plan['workouts'] as List<dynamic>? ??
                       plan['plan_workouts'] as List<dynamic>? ?? [];

      for (var i = 0; i < workouts.length; i++) {
        final workout = workouts[i] as Map<String, dynamic>;
        final workoutId = workout['id'] as String? ??
                         workout['workout_id'] as String?;
        final workoutName = workout['name'] as String? ?? 'Treino ${i + 1}';
        final label = _getWorkoutLabel(i);

        if (workoutId != null) {
          allWorkouts.add(_WorkoutItem(
            id: workoutId,
            name: workoutName,
            label: label,
            planName: planName,
            planId: planId,
            duration: workout['estimated_duration'] as int? ??
                     workout['estimated_duration_min'] as int? ?? 60,
            exercisesCount: (workout['exercises'] as List?)?.length ??
                           workout['exercises_count'] as int? ?? 0,
            isSuggested: todayWorkout?.workoutId == workoutId,
          ));
        }
      }
    }

    // If no workouts found in plans, check workouts provider
    if (allWorkouts.isEmpty) {
      final workoutsState = ref.watch(workoutsNotifierProvider);
      for (var i = 0; i < workoutsState.workouts.length; i++) {
        final workout = workoutsState.workouts[i];
        final workoutId = workout['id'] as String?;
        if (workoutId != null) {
          allWorkouts.add(_WorkoutItem(
            id: workoutId,
            name: workout['name'] as String? ?? 'Treino ${i + 1}',
            label: _getWorkoutLabel(i),
            planName: null,
            planId: null,
            duration: workout['estimated_duration'] as int? ??
                     workout['estimated_duration_min'] as int? ?? 60,
            exercisesCount: (workout['exercises'] as List?)?.length ?? 0,
            isSuggested: todayWorkout?.workoutId == workoutId,
          ));
        }
      }
    }

    // Sort: suggested first, then by label
    allWorkouts.sort((a, b) {
      if (a.isSuggested && !b.isSuggested) return -1;
      if (!a.isSuggested && b.isSuggested) return 1;
      return a.label.compareTo(b.label);
    });

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Escolha o Treino',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selecione qual treino deseja fazer',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

            // Loading or empty state
            if (plansState.isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
            else if (allWorkouts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.dumbbell,
                      size: 48,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum treino disponível',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aguarde seu Personal prescrever um plano',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              // Workout list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: allWorkouts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final workout = allWorkouts[index];
                    return _WorkoutCard(
                      workout: workout,
                      isDark: isDark,
                      onTap: () => _selectWorkout(context, ref, workout),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getWorkoutLabel(int index) {
    const labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    return index < labels.length ? 'Treino ${labels[index]}' : 'Treino ${index + 1}';
  }

  void _selectWorkout(BuildContext context, WidgetRef ref, _WorkoutItem workout) {
    HapticUtils.mediumImpact();
    Navigator.pop(context);

    // Show the start options sheet (alone vs with trainer)
    final dashboardState = ref.read(studentDashboardProvider);

    if (dashboardState.hasTrainer && dashboardState.canTrainWithPersonal) {
      // Has trainer - show options
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => StartWorkoutSheet(
          workoutId: workout.id,
          workoutName: workout.name,
        ),
      );
    } else {
      // No trainer - go directly to workout
      context.push('/workouts/active/${workout.id}');
    }
  }
}

class _WorkoutItem {
  final String id;
  final String name;
  final String label;
  final String? planName;
  final String? planId;
  final int duration;
  final int exercisesCount;
  final bool isSuggested;

  const _WorkoutItem({
    required this.id,
    required this.name,
    required this.label,
    this.planName,
    this.planId,
    required this.duration,
    required this.exercisesCount,
    this.isSuggested = false,
  });
}

class _WorkoutCard extends StatelessWidget {
  final _WorkoutItem workout;
  final bool isDark;
  final VoidCallback onTap;

  const _WorkoutCard({
    required this.workout,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSuggested = workout.isSuggested;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSuggested
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withAlpha(200),
                  ],
                )
              : null,
          color: isSuggested
              ? null
              : (isDark
                  ? AppColors.backgroundDark.withAlpha(150)
                  : AppColors.background),
          borderRadius: BorderRadius.circular(12),
          border: isSuggested
              ? null
              : Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  width: 1.5,
                ),
        ),
        child: Row(
          children: [
            // Label badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSuggested
                    ? Colors.white.withAlpha(30)
                    : AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  workout.label.replaceAll('Treino ', ''),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isSuggested
                        ? Colors.white
                        : (isDark ? AppColors.primaryDark : AppColors.primary),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          workout.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSuggested
                                ? Colors.white
                                : (isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground),
                          ),
                        ),
                      ),
                      if (isSuggested)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.star,
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Sugerido',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 12,
                        color: isSuggested
                            ? Colors.white70
                            : (isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '~${workout.duration} min',
                        style: TextStyle(
                          fontSize: 13,
                          color: isSuggested
                              ? Colors.white70
                              : (isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        LucideIcons.dumbbell,
                        size: 12,
                        color: isSuggested
                            ? Colors.white70
                            : (isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.exercisesCount} exercícios',
                        style: TextStyle(
                          fontSize: 13,
                          color: isSuggested
                              ? Colors.white70
                              : (isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Arrow
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isSuggested
                  ? Colors.white70
                  : (isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}
