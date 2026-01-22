import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/personal_record.dart';

/// Card displaying a Personal Record summary for an exercise
class PRCard extends StatelessWidget {
  final ExercisePRSummary summary;
  final bool isDark;
  final VoidCallback? onTap;

  const PRCard({
    super.key,
    required this.summary,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with exercise name and muscle group
            Row(
              children: [
                // Exercise image or icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: summary.exerciseImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            summary.exerciseImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              LucideIcons.dumbbell,
                              size: 24,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : Icon(
                          LucideIcons.dumbbell,
                          size: 24,
                          color: AppColors.primary,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.exerciseName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (summary.muscleGroup != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          summary.muscleGroup!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // PR values grid
            Row(
              children: [
                if (summary.prMaxWeight != null)
                  Expanded(
                    child: _PRValue(
                      label: 'Carga Máx.',
                      value: '${summary.prMaxWeight!.toStringAsFixed(1)} kg',
                      subValue: summary.prMaxWeightReps != null
                          ? '${summary.prMaxWeightReps} reps'
                          : null,
                      isDark: isDark,
                      icon: LucideIcons.trophy,
                      iconColor: AppColors.warning,
                    ),
                  ),
                if (summary.prEstimated1RM != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PRValue(
                      label: '1RM Est.',
                      value: '${summary.prEstimated1RM!.toStringAsFixed(1)} kg',
                      isDark: isDark,
                      icon: LucideIcons.target,
                      iconColor: AppColors.accent,
                    ),
                  ),
                ],
                if (summary.prMaxReps != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PRValue(
                      label: 'Máx. Reps',
                      value: '${summary.prMaxReps} reps',
                      subValue: summary.prMaxRepsWeight != null
                          ? '${summary.prMaxRepsWeight!.toStringAsFixed(1)} kg'
                          : null,
                      isDark: isDark,
                      icon: LucideIcons.repeat,
                      iconColor: AppColors.success,
                    ),
                  ),
                ],
              ],
            ),

            // Last performed
            if (summary.lastPerformed != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Último treino: ${_formatDate(summary.lastPerformed!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return 'há ${diff.inDays} dias';

    return DateFormat('dd/MM/yyyy').format(date);
  }
}

/// Individual PR value display
class _PRValue extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final bool isDark;
  final IconData icon;
  final Color iconColor;

  const _PRValue({
    required this.label,
    required this.value,
    this.subValue,
    required this.isDark,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withAlpha(100)
            : AppColors.background.withAlpha(150),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: iconColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact PR card for lists
class PRCardCompact extends StatelessWidget {
  final PersonalRecord record;
  final bool isDark;
  final VoidCallback? onTap;

  const PRCardCompact({
    super.key,
    required this.record,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // PR type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.trophy,
                size: 20,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.exerciseName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    record.type.displayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record.formattedValue,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (record.improvementPercent != null) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '+${record.improvementPercent!.toStringAsFixed(1)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// PR achievement banner shown during workout
class PRAchievementBanner extends StatelessWidget {
  final PRAchievement achievement;
  final bool isDark;
  final VoidCallback? onDismiss;

  const PRAchievementBanner({
    super.key,
    required this.achievement,
    required this.isDark,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withAlpha(30),
            AppColors.accent.withAlpha(20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          // Trophy icon with pulse animation
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              LucideIcons.trophy,
              size: 24,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'NOVO PR!',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      achievement.improvementMessage,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.exerciseName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${achievement.type.displayName}: ${achievement.newValue.toStringAsFixed(1)} ${achievement.type.unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                LucideIcons.x,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
