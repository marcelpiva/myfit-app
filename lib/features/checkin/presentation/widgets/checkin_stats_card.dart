import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/models/check_in.dart';

class CheckinStatsCard extends StatelessWidget {
  final CheckInStats stats;

  const CheckinStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  LucideIcons.barChart3,
                  size: 20,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Suas estatísticas',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: LucideIcons.flame,
                    value: '${stats.currentStreak}',
                    label: 'Sequência',
                    color: AppColors.warning,
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                Expanded(
                  child: _StatItem(
                    icon: LucideIcons.calendar,
                    value: '${stats.thisWeek}',
                    label: 'Esta semana',
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                Expanded(
                  child: _StatItem(
                    icon: LucideIcons.calendarDays,
                    value: '${stats.thisMonth}',
                    label: 'Este mês',
                    color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: LucideIcons.clock,
                    value: '${stats.averageDuration.round()}m',
                    label: 'Média treino',
                    color: isDark ? AppColors.accentDark : AppColors.accent,
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                Expanded(
                  child: _StatItem(
                    icon: LucideIcons.trophy,
                    value: '${stats.longestStreak}',
                    label: 'Maior seq.',
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                Expanded(
                  child: _StatItem(
                    icon: LucideIcons.sparkles,
                    value: '${stats.totalPoints}',
                    label: 'Pontos',
                    color: AppColors.warning,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
