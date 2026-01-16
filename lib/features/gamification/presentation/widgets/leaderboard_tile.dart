import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/models/leaderboard.dart';

class LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardTile({
    super.key,
    required this.entry,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser
            ? (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.1)
            : (isDark ? AppColors.cardDark : AppColors.card),
        border: Border.all(
          color: isCurrentUser
              ? (isDark ? AppColors.primaryDark : AppColors.primary)
              : (isDark ? AppColors.borderDark : AppColors.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 36,
              child: Text(
                '#${entry.rank}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _getRankColor(entry.rank, isDark),
                ),
              ),
            ),

            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.mutedDark : AppColors.muted,
                shape: BoxShape.circle,
              ),
              child: entry.memberAvatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        entry.memberAvatarUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        entry.memberName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
            ),

            const SizedBox(width: 12),

            // Name and level
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.memberName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w500,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                          child: const Text(
                            'VOCÊ',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (entry.levelIcon != null) ...[
                        Text(entry.levelIcon!, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '${entry.checkIns} check-ins • ${entry.workoutsCompleted} treinos',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Points and change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.points}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                if (entry.rankChange != null && entry.rankChange != 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        entry.rankChange! > 0 ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                        size: 12,
                        color: entry.rankChange! > 0 ? AppColors.success : AppColors.destructive,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${entry.rankChange!.abs()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: entry.rankChange! > 0 ? AppColors.success : AppColors.destructive,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank, bool isDark) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground;
    }
  }
}
