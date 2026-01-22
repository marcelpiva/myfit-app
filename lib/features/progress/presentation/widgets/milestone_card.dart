import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/milestone.dart';

/// Card displaying a milestone with progress
class MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const MilestoneCard({
    super.key,
    required this.milestone,
    required this.isDark,
    this.onTap,
    this.onComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = milestone.progressPercentage;
    final isAlmostDone = progress >= 80;

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isAlmostDone
                ? AppColors.success.withAlpha(100)
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isAlmostDone ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _buildTypeIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (milestone.description != null)
                        Text(
                          milestone.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (milestone.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.checkCircle2,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Concluído',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress bar
            _buildProgressBar(theme, progress),

            const SizedBox(height: 12),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Current / Target
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '${milestone.currentValue.toStringAsFixed(1)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: ' / ${milestone.targetValue.toStringAsFixed(1)} ${milestone.unit}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Days remaining or completion date
                if (milestone.isCompleted && milestone.completedAt != null)
                  Text(
                    DateFormat('d MMM yyyy', 'pt_BR').format(milestone.completedAt!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else if (milestone.daysRemaining != null)
                  _buildDaysRemaining(theme),
              ],
            ),

            // Actions
            if (!milestone.isCompleted && (onComplete != null || onDelete != null)) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onDelete != null)
                    TextButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        onDelete?.call();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.destructive,
                      ),
                      child: const Text('Excluir'),
                    ),
                  if (isAlmostDone && onComplete != null) ...[
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () {
                        HapticUtils.heavyImpact();
                        onComplete?.call();
                      },
                      icon: const Icon(LucideIcons.check, size: 16),
                      label: const Text('Completar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    final (icon, color) = _getTypeIconAndColor();

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 20,
        color: color,
      ),
    );
  }

  (IconData, Color) _getTypeIconAndColor() {
    switch (milestone.type) {
      case MilestoneType.weightGoal:
        return (LucideIcons.scale, AppColors.primary);
      case MilestoneType.measurementGoal:
        return (LucideIcons.ruler, AppColors.accent);
      case MilestoneType.personalRecord:
        return (LucideIcons.trophy, AppColors.warning);
      case MilestoneType.consistency:
        return (LucideIcons.flame, AppColors.destructive);
      case MilestoneType.workoutCount:
        return (LucideIcons.dumbbell, AppColors.secondary);
      case MilestoneType.strengthGain:
        return (LucideIcons.trendingUp, AppColors.success);
      case MilestoneType.bodyFat:
        return (LucideIcons.activity, AppColors.info);
      case MilestoneType.custom:
        return (LucideIcons.target, AppColors.primary);
    }
  }

  Widget _buildProgressBar(ThemeData theme, double progress) {
    final color = progress >= 80
        ? AppColors.success
        : progress >= 50
            ? AppColors.warning
            : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${progress.toStringAsFixed(0)}%',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(4),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * (progress / 100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withAlpha(180)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDaysRemaining(ThemeData theme) {
    final days = milestone.daysRemaining!;
    final isOverdue = milestone.isOverdue;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isOverdue ? LucideIcons.alertCircle : LucideIcons.clock,
          size: 14,
          color: isOverdue ? AppColors.destructive : theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          isOverdue
              ? 'Vencido'
              : days == 0
                  ? 'Hoje'
                  : days == 1
                      ? '1 dia restante'
                      : '$days dias restantes',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isOverdue ? AppColors.destructive : theme.colorScheme.onSurfaceVariant,
            fontWeight: isOverdue ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
}

/// Compact milestone card for summaries
class MilestoneCardCompact extends StatelessWidget {
  final Milestone milestone;
  final bool isDark;
  final VoidCallback? onTap;

  const MilestoneCardCompact({
    super.key,
    required this.milestone,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = milestone.progressPercentage;

    return GestureDetector(
      onTap: onTap,
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
            // Progress circle
            SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress / 100,
                    strokeWidth: 4,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 80 ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  Text(
                    '${progress.toInt()}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${milestone.currentValue.toStringAsFixed(1)} / ${milestone.targetValue.toStringAsFixed(1)} ${milestone.unit}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Status icon
            if (milestone.isCompleted)
              Icon(
                LucideIcons.checkCircle2,
                size: 20,
                color: AppColors.success,
              )
            else if (milestone.isOverdue)
              Icon(
                LucideIcons.alertCircle,
                size: 20,
                color: AppColors.destructive,
              ),
          ],
        ),
      ),
    );
  }
}

/// Banner showing milestone achievement celebration
class MilestoneAchievementBanner extends StatelessWidget {
  final Milestone milestone;
  final bool isDark;
  final VoidCallback? onDismiss;

  const MilestoneAchievementBanner({
    super.key,
    required this.milestone,
    required this.isDark,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withAlpha(30),
            AppColors.primary.withAlpha(20),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.success.withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          // Trophy icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.trophy,
              color: AppColors.success,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meta Alcançada!',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  milestone.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (milestone.completedAt != null)
                  Text(
                    'Concluído em ${DateFormat('d MMM', 'pt_BR').format(milestone.completedAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),

          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                LucideIcons.x,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

/// Widget showing milestone stats summary
class MilestoneStatsSummary extends StatelessWidget {
  final MilestoneStats stats;
  final bool isDark;

  const MilestoneStatsSummary({
    super.key,
    required this.stats,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'Em Andamento',
            value: stats.activeMilestones.toString(),
            icon: LucideIcons.target,
            color: AppColors.primary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            label: 'Concluídas',
            value: stats.completedMilestones.toString(),
            icon: LucideIcons.checkCircle2,
            color: AppColors.success,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            label: 'Sequência',
            value: '${stats.currentStreak}',
            icon: LucideIcons.flame,
            color: AppColors.warning,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 20 : 15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
