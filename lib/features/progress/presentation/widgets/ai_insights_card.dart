import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/milestone.dart';

/// Card displaying an AI-generated insight
class AIInsightCard extends StatelessWidget {
  final AIInsight insight;
  final bool isDark;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const AIInsightCard({
    super.key,
    required this.insight,
    required this.isDark,
    this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color, bgColor) = _getSentimentStyle();

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
            color: color.withAlpha(50),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: color,
                  ),
                ),

                const SizedBox(width: 12),

                // Title and category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.sparkles,
                                  size: 10,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'IA',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            insight.category,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Dismiss button
                if (onDismiss != null)
                  IconButton(
                    onPressed: () {
                      HapticUtils.lightImpact();
                      onDismiss?.call();
                    },
                    icon: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Content
            Text(
              insight.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // Recommendations
            if (insight.recommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildRecommendations(theme),
            ],

            // Footer with timestamp
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  LucideIcons.clock,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(insight.generatedAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color, Color) _getSentimentStyle() {
    switch (insight.sentiment) {
      case 'positive':
        return (
          LucideIcons.trendingUp,
          AppColors.success,
          AppColors.success.withAlpha(20),
        );
      case 'warning':
        return (
          LucideIcons.alertTriangle,
          AppColors.warning,
          AppColors.warning.withAlpha(20),
        );
      default:
        return (
          LucideIcons.lightbulb,
          AppColors.info,
          AppColors.info.withAlpha(20),
        );
    }
  }

  Widget _buildRecommendations(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recomendações:',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ...insight.recommendations.take(3).map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.chevronRight,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rec,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return 'Há ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Há ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'Há ${diff.inDays} dias';
    } else {
      return DateFormat('d MMM', 'pt_BR').format(date);
    }
  }
}

/// Compact AI insight card for lists
class AIInsightCardCompact extends StatelessWidget {
  final AIInsight insight;
  final bool isDark;
  final VoidCallback? onTap;

  const AIInsightCardCompact({
    super.key,
    required this.insight,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = insight.isPositive
        ? AppColors.success
        : insight.isWarning
            ? AppColors.warning
            : AppColors.info;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withAlpha(30),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.sparkles,
                size: 18,
                color: color,
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    insight.content,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state for when there are no insights
class AIInsightsEmptyState extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onGenerate;

  const AIInsightsEmptyState({
    super.key,
    required this.isDark,
    this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(50)
            : AppColors.muted.withAlpha(50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(20),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              LucideIcons.sparkles,
              size: 28,
              color: AppColors.accent.withAlpha(150),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Insights Personalizados',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Continue treinando para receber análises e recomendações personalizadas da IA.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (onGenerate != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                HapticUtils.mediumImpact();
                onGenerate?.call();
              },
              icon: const Icon(LucideIcons.sparkles, size: 16),
              label: const Text('Gerar Insights'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Header for AI insights section
class AIInsightsSectionHeader extends StatelessWidget {
  final int insightCount;
  final VoidCallback? onSeeAll;
  final VoidCallback? onGenerate;
  final bool isLoading;

  const AIInsightsSectionHeader({
    super.key,
    required this.insightCount,
    this.onSeeAll,
    this.onGenerate,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          LucideIcons.sparkles,
          size: 18,
          color: AppColors.accent,
        ),
        const SizedBox(width: 8),
        Text(
          'Insights da IA',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (insightCount > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              insightCount.toString(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        else if (onGenerate != null)
          IconButton(
            onPressed: onGenerate,
            icon: Icon(
              LucideIcons.refreshCw,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            visualDensity: VisualDensity.compact,
            tooltip: 'Gerar novos insights',
          ),
        if (onSeeAll != null && insightCount > 0)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Ver todos'),
          ),
      ],
    );
  }
}
