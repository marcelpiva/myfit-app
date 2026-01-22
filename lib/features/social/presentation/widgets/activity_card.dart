import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/activity_item.dart';

/// Card for displaying an activity in the feed
class ActivityCard extends StatelessWidget {
  final ActivityItem activity;
  final VoidCallback? onReact;
  final VoidCallback? onShare;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onReact,
    this.onShare,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  _buildAvatar(isDark),
                  const SizedBox(width: 12),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.userName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          timeago.format(activity.timestamp, locale: 'pt_BR'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Activity type badge
                  _buildTypeBadge(isDark),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with emoji
                  Row(
                    children: [
                      Text(
                        activity.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        activity.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    activity.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),

                  // Extra data display based on type
                  if (activity.type == ActivityType.workoutCompleted) ...[
                    const SizedBox(height: 12),
                    _buildWorkoutStats(isDark, theme),
                  ],
                ],
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // React button
                  _ActionButton(
                    icon: activity.hasReacted
                        ? LucideIcons.heartHandshake
                        : LucideIcons.heart,
                    label: activity.reactions > 0
                        ? '${activity.reactions}'
                        : 'Curtir',
                    isActive: activity.hasReacted,
                    onTap: onReact,
                    isDark: isDark,
                  ),

                  const SizedBox(width: 16),

                  // Share button
                  _ActionButton(
                    icon: LucideIcons.share2,
                    label: 'Compartilhar',
                    onTap: onShare,
                    isDark: isDark,
                  ),

                  const Spacer(),

                  // Celebrate button for certain types
                  if (_shouldShowCelebrate())
                    _ActionButton(
                      icon: LucideIcons.partyPopper,
                      label: 'Celebrar',
                      onTap: () {
                        HapticUtils.heavyImpact();
                        // TODO: Show celebration animation
                      },
                      isDark: isDark,
                      color: AppColors.warning,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    if (activity.userAvatarUrl != null && activity.userAvatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(activity.userAvatarUrl!),
      );
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: _getTypeColor().withAlpha(30),
      child: Text(
        activity.userName.isNotEmpty ? activity.userName[0].toUpperCase() : '?',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _getTypeColor(),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(bool isDark) {
    final color = _getTypeColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTypeIcon(), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _getTypeLabel(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStats(bool isDark, ThemeData theme) {
    final duration = activity.data['duration_minutes'] as int? ?? 0;
    final exerciseCount = activity.data['exercise_count'] as int? ?? 0;

    return Row(
      children: [
        _StatChip(
          icon: LucideIcons.clock,
          label: '${duration}min',
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: LucideIcons.dumbbell,
          label: '$exerciseCount ex.',
          isDark: isDark,
        ),
      ],
    );
  }

  Color _getTypeColor() {
    switch (activity.type) {
      case ActivityType.workoutCompleted:
        return AppColors.success;
      case ActivityType.personalRecord:
        return AppColors.warning;
      case ActivityType.achievementUnlocked:
        return AppColors.primary;
      case ActivityType.milestoneReached:
        return AppColors.info;
      case ActivityType.streakMilestone:
        return const Color(0xFFFF6B35);
      case ActivityType.gymCheckin:
        return AppColors.secondary;
      case ActivityType.firstWorkout:
        return AppColors.accent;
      case ActivityType.levelUp:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon() {
    switch (activity.type) {
      case ActivityType.workoutCompleted:
        return LucideIcons.checkCircle;
      case ActivityType.personalRecord:
        return LucideIcons.trophy;
      case ActivityType.achievementUnlocked:
        return LucideIcons.medal;
      case ActivityType.milestoneReached:
        return LucideIcons.target;
      case ActivityType.streakMilestone:
        return LucideIcons.flame;
      case ActivityType.gymCheckin:
        return LucideIcons.mapPin;
      case ActivityType.firstWorkout:
        return LucideIcons.star;
      case ActivityType.levelUp:
        return LucideIcons.arrowUpCircle;
    }
  }

  String _getTypeLabel() {
    switch (activity.type) {
      case ActivityType.workoutCompleted:
        return 'Treino';
      case ActivityType.personalRecord:
        return 'PR';
      case ActivityType.achievementUnlocked:
        return 'Conquista';
      case ActivityType.milestoneReached:
        return 'Marco';
      case ActivityType.streakMilestone:
        return 'Sequência';
      case ActivityType.gymCheckin:
        return 'Check-in';
      case ActivityType.firstWorkout:
        return 'Primeiro';
      case ActivityType.levelUp:
        return 'Nível';
    }
  }

  bool _shouldShowCelebrate() {
    return activity.type == ActivityType.personalRecord ||
        activity.type == ActivityType.achievementUnlocked ||
        activity.type == ActivityType.milestoneReached ||
        activity.type == ActivityType.firstWorkout;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDark;
  final bool isActive;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    required this.isDark,
    this.isActive = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    final inactiveColor =
        isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground;

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap?.call();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? activeColor : inactiveColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withAlpha(150)
            : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color:
                isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color:
                  isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
