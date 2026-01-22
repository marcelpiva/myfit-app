import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../progress/domain/models/personal_record.dart';
import '../../../progress/presentation/providers/personal_record_provider.dart';

/// Shows current PR for an exercise during active workout
/// Motivates user to beat their record
class PRIndicator extends ConsumerWidget {
  final String? exerciseId;
  final String exerciseName;
  final bool isDark;
  final double? currentWeight;

  const PRIndicator({
    super.key,
    this.exerciseId,
    required this.exerciseName,
    required this.isDark,
    this.currentWeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prsState = ref.watch(personalRecordsProvider);

    // Find PR for this exercise
    ExercisePRSummary? exercisePR;
    if (exerciseId != null) {
      exercisePR = prsState.exercises.firstWhere(
        (e) => e.exerciseId == exerciseId,
        orElse: () => ExercisePRSummary(
          exerciseId: exerciseId!,
          exerciseName: exerciseName,
        ),
      );
    } else {
      // Match by name if no ID
      exercisePR = prsState.exercises.firstWhere(
        (e) => e.exerciseName.toLowerCase() == exerciseName.toLowerCase(),
        orElse: () => ExercisePRSummary(
          exerciseId: '',
          exerciseName: exerciseName,
        ),
      );
    }

    // Don't show if no PRs
    if (!exercisePR.hasPRs) {
      return const SizedBox.shrink();
    }

    // Check if current weight beats the PR
    final isBeatingPR = currentWeight != null &&
        exercisePR.prMaxWeight != null &&
        currentWeight! > exercisePR.prMaxWeight!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBeatingPR
              ? [
                  AppColors.success.withAlpha(isDark ? 30 : 20),
                  AppColors.success.withAlpha(isDark ? 20 : 10),
                ]
              : [
                  AppColors.warning.withAlpha(isDark ? 30 : 20),
                  AppColors.accent.withAlpha(isDark ? 20 : 10),
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isBeatingPR
              ? AppColors.success.withAlpha(50)
              : AppColors.warning.withAlpha(40),
        ),
      ),
      child: Row(
        children: [
          // Trophy/flame icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (isBeatingPR ? AppColors.success : AppColors.warning)
                  .withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isBeatingPR ? LucideIcons.flame : LucideIcons.trophy,
              size: 16,
              color: isBeatingPR ? AppColors.success : AppColors.warning,
            ),
          ),

          const SizedBox(width: 10),

          // PR info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBeatingPR ? 'Novo PR!' : 'Seu PR',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isBeatingPR ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Row(
                  children: [
                    if (exercisePR.prMaxWeight != null) ...[
                      Text(
                        '${exercisePR.prMaxWeight!.toStringAsFixed(1)} kg',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (exercisePR.prMaxWeightReps != null)
                        Text(
                          ' × ${exercisePR.prMaxWeightReps}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                    if (exercisePR.prEstimated1RM != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '1RM: ${exercisePR.prEstimated1RM!.toStringAsFixed(0)}kg',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Beat it indicator
          if (!isBeatingPR && currentWeight != null && exercisePR.prMaxWeight != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Faltam',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '+${(exercisePR.prMaxWeight! - currentWeight! + 0.5).toStringAsFixed(1)} kg',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Compact PR badge to show next to exercise name
class PRBadge extends StatelessWidget {
  final double? prWeight;
  final bool isDark;

  const PRBadge({
    super.key,
    this.prWeight,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (prWeight == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(isDark ? 40 : 30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.trophy,
            size: 10,
            color: AppColors.warning,
          ),
          const SizedBox(width: 3),
          Text(
            '${prWeight!.toStringAsFixed(0)}kg',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
