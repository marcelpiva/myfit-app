import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Widget that displays workout streak and calendar
class StreakCalendar extends StatefulWidget {
  final int currentStreak;
  final List<DateTime> completedDays;
  final bool isDark;
  final VoidCallback? onExpand;

  const StreakCalendar({
    super.key,
    required this.currentStreak,
    this.completedDays = const [],
    this.isDark = false,
    this.onExpand,
  });

  @override
  State<StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<StreakCalendar> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: widget.isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: widget.isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // Header with streak info
          GestureDetector(
            onTap: () {
              HapticUtils.selectionClick();
              setState(() => _isExpanded = !_isExpanded);
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Streak fire icon
                  _StreakBadge(
                    streak: widget.currentStreak,
                    isDark: widget.isDark,
                  ),

                  const SizedBox(width: 12),

                  // Streak info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStreakMessage(widget.currentStreak),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.currentStreak > 0
                              ? '${widget.currentStreak} dia${widget.currentStreak > 1 ? 's' : ''} consecutivo${widget.currentStreak > 1 ? 's' : ''}'
                              : 'Comece uma sequência treinando hoje!',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expand/collapse icon
                  Icon(
                    _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Expanded calendar view
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: widget.isDark ? AppColors.borderDark : AppColors.border,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _MiniCalendar(
                completedDays: widget.completedDays,
                isDark: widget.isDark,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStreakMessage(int streak) {
    if (streak == 0) return 'Inicie sua sequência!';
    if (streak == 1) return 'Ótimo começo!';
    if (streak < 7) return 'Continue assim!';
    if (streak < 14) return 'Uma semana incrível!';
    if (streak < 30) return 'Você está pegando fogo!';
    if (streak < 60) return 'Um mês de dedicação!';
    return 'Você é imparável!';
  }
}

/// Streak badge with fire icon and number
class _StreakBadge extends StatelessWidget {
  final int streak;
  final bool isDark;

  const _StreakBadge({
    required this.streak,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get color based on streak
    Color badgeColor;
    if (streak == 0) {
      badgeColor = isDark ? AppColors.mutedDark : AppColors.muted;
    } else if (streak < 7) {
      badgeColor = AppColors.warning;
    } else if (streak < 30) {
      badgeColor = AppColors.success;
    } else {
      badgeColor = AppColors.primary;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: badgeColor.withAlpha(25),
        border: Border.all(
          color: badgeColor.withAlpha(80),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            streak > 0 ? LucideIcons.flame : LucideIcons.minus,
            size: 20,
            color: badgeColor,
          ),
          Text(
            '$streak',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini calendar showing last 4 weeks
class _MiniCalendar extends StatelessWidget {
  final List<DateTime> completedDays;
  final bool isDark;

  const _MiniCalendar({
    required this.completedDays,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    // Generate 4 weeks of data (starting from 3 weeks ago)
    final weeksStart = startOfWeek.subtract(const Duration(days: 21));

    // Day labels
    const dayLabels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return Column(
      children: [
        // Day labels row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayLabels.map((label) {
            return SizedBox(
              width: 32,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 8),

        // Calendar grid (4 weeks)
        ...List.generate(4, (weekIndex) {
          final weekStart = weeksStart.add(Duration(days: weekIndex * 7));

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final date = weekStart.add(Duration(days: dayIndex));
                final isCompleted = _isDayCompleted(date);
                final isToday = _isSameDay(date, today);
                final isFuture = date.isAfter(today);

                return _CalendarDay(
                  day: date.day,
                  isCompleted: isCompleted,
                  isToday: isToday,
                  isFuture: isFuture,
                  isDark: isDark,
                );
              }),
            ),
          );
        }),

        const SizedBox(height: 12),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(
              color: AppColors.success,
              label: 'Treinou',
              isDark: isDark,
            ),
            const SizedBox(width: 16),
            _LegendItem(
              color: AppColors.primary,
              label: 'Hoje',
              isDark: isDark,
            ),
            const SizedBox(width: 16),
            _LegendItem(
              color: isDark ? AppColors.mutedDark : AppColors.muted,
              label: 'Não treinou',
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  bool _isDayCompleted(DateTime date) {
    return completedDays.any((d) => _isSameDay(d, date));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Individual day cell in the calendar
class _CalendarDay extends StatelessWidget {
  final int day;
  final bool isCompleted;
  final bool isToday;
  final bool isFuture;
  final bool isDark;

  const _CalendarDay({
    required this.day,
    required this.isCompleted,
    required this.isToday,
    required this.isFuture,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isFuture) {
      backgroundColor = Colors.transparent;
      textColor = theme.colorScheme.onSurfaceVariant.withAlpha(100);
      borderColor = Colors.transparent;
    } else if (isToday) {
      backgroundColor = AppColors.primary.withAlpha(25);
      textColor = AppColors.primary;
      borderColor = AppColors.primary;
    } else if (isCompleted) {
      backgroundColor = AppColors.success.withAlpha(25);
      textColor = AppColors.success;
      borderColor = AppColors.success.withAlpha(80);
    } else {
      backgroundColor = isDark
          ? AppColors.mutedDark.withAlpha(50)
          : AppColors.muted.withAlpha(100);
      textColor = theme.colorScheme.onSurfaceVariant.withAlpha(150);
      borderColor = Colors.transparent;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$day',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: isToday || isCompleted ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
          // Completed checkmark
          if (isCompleted && !isToday)
            Positioned(
              right: 2,
              bottom: 2,
              child: Icon(
                LucideIcons.check,
                size: 10,
                color: AppColors.success,
              ),
            ),
        ],
      ),
    );
  }
}

/// Legend item for the calendar
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withAlpha(50),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withAlpha(100)),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Compact streak indicator for use in other places
class StreakIndicator extends StatelessWidget {
  final int streak;
  final bool showLabel;
  final bool isDark;

  const StreakIndicator({
    super.key,
    required this.streak,
    this.showLabel = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get color based on streak
    Color streakColor;
    if (streak == 0) {
      streakColor = isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground;
    } else if (streak < 7) {
      streakColor = AppColors.warning;
    } else {
      streakColor = AppColors.success;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          streak > 0 ? LucideIcons.flame : LucideIcons.minus,
          size: 16,
          color: streakColor,
        ),
        const SizedBox(width: 4),
        Text(
          '$streak',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: streakColor,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            streak == 1 ? 'dia' : 'dias',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
