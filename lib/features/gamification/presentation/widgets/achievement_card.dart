import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/models/achievement.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isLocked;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.isLocked = false,
  });

  Color _getRarityColor() {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return const Color(0xFF9CA3AF); // Gray
      case AchievementRarity.rare:
        return const Color(0xFF3B82F6); // Blue
      case AchievementRarity.epic:
        return const Color(0xFF8B5CF6); // Purple
      case AchievementRarity.legendary:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  String _getRarityLabel() {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return 'Comum';
      case AchievementRarity.rare:
        return 'Raro';
      case AchievementRarity.epic:
        return 'Épico';
      case AchievementRarity.legendary:
        return 'Lendário';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rarityColor = _getRarityColor();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        border: Border.all(
          color: isLocked
              ? (isDark ? AppColors.borderDark : AppColors.border)
              : rarityColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? (isDark ? AppColors.mutedDark : AppColors.muted)
                        : rarityColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: isLocked
                          ? (isDark ? AppColors.borderDark : AppColors.border)
                          : rarityColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: isLocked
                        ? Icon(
                            LucideIcons.lock,
                            size: 24,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          )
                        : Text(
                            achievement.icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isLocked
                                    ? (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground)
                                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: rarityColor.withValues(alpha: isLocked ? 0.1 : 0.2),
                            ),
                            child: Text(
                              _getRarityLabel(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isLocked
                                    ? (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground)
                                    : rarityColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.sparkles,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${achievement.pointsReward} pts',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                          if (!isLocked && achievement.unlockedAt != null) ...[
                            const Spacer(),
                            Icon(
                              LucideIcons.checkCircle,
                              size: 14,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yy').format(achievement.unlockedAt!),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Progress bar (for locked achievements with progress)
          if (isLocked && achievement.progress != null) ...[
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                      Text(
                        achievement.currentValue != null && achievement.targetValue != null
                            ? '${achievement.currentValue}/${achievement.targetValue}'
                            : '${(achievement.progress! * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    child: LinearProgressIndicator(
                      value: achievement.progress,
                      backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
                      valueColor: AlwaysStoppedAnimation<Color>(rarityColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
