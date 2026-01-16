import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../domain/models/achievement.dart';
import '../../domain/models/leaderboard.dart';
import '../providers/gamification_provider.dart';
import '../widgets/achievement_card.dart';
import '../widgets/leaderboard_tile.dart';
import '../widgets/points_summary_card.dart';

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final period = ref.watch(leaderboardPeriodProvider);
    final leaderboard = ref.watch(leaderboardProvider);
    final userLevel = ref.watch(userLevelProvider);
    final unlockedAchievements = ref.watch(unlockedAchievementsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.arrowLeft, size: 20, color: isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ),
          title: const Text('Ranking'),
          bottom: TabBar(
            indicatorColor: isDark ? AppColors.primaryDark : AppColors.primary,
            labelColor: isDark ? AppColors.primaryDark : AppColors.primary,
            unselectedLabelColor: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            onTap: (_) => HapticFeedback.selectionClick(),
            tabs: const [
              Tab(text: 'Ranking'),
              Tab(text: 'Conquistas'),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(isDark ? 15 : 10),
                (isDark ? AppColors.secondaryDark : AppColors.secondary).withAlpha(isDark ? 12 : 8),
              ],
            ),
          ),
          child: TabBarView(
            children: [
              // Ranking Tab
              _RankingTab(
                leaderboard: leaderboard,
                period: period,
                userLevel: userLevel,
                isDark: isDark,
              ),

              // Achievements Tab
              _AchievementsTab(
                unlockedAchievements: unlockedAchievements,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankingTab extends ConsumerWidget {
  final Leaderboard leaderboard;
  final LeaderboardPeriod period;
  final UserLevel userLevel;
  final bool isDark;

  const _RankingTab({
    required this.leaderboard,
    required this.period,
    required this.userLevel,
    required this.isDark,
  });

  void _showAchievementDetailsModal(BuildContext context, int rank) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine next achievement based on rank
    final String achievementName;
    final IconData achievementIcon;
    final String achievementDescription;
    final double progress;
    final int pointsReward;

    if (rank > 10) {
      achievementName = 'Top 10';
      achievementIcon = LucideIcons.medal;
      achievementDescription = 'Entre no Top 10 do ranking para desbloquear esta conquista';
      progress = (11 - rank.clamp(1, 11)) / 10;
      pointsReward = 100;
    } else if (rank > 3) {
      achievementName = 'Podio';
      achievementIcon = LucideIcons.trophy;
      achievementDescription = 'Alcance o podio (Top 3) para desbloquear esta conquista';
      progress = (4 - rank.clamp(1, 4)) / 3;
      pointsReward = 250;
    } else if (rank > 1) {
      achievementName = 'Campeao';
      achievementIcon = LucideIcons.crown;
      achievementDescription = 'Seja o primeiro lugar do ranking para desbloquear esta conquista';
      progress = (2 - rank.clamp(1, 2)) / 1;
      pointsReward = 500;
    } else {
      achievementName = 'Lider Absoluto';
      achievementIcon = LucideIcons.star;
      achievementDescription = 'Mantenha a lideranca por 4 semanas consecutivas';
      progress = 0.25;
      pointsReward = 1000;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Achievement icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      achievementIcon,
                      size: 40,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Achievement name
                  Text(
                    achievementName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    achievementDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progresso',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.primaryDark : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Points reward
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.coins,
                          size: 20,
                          color: isDark ? AppColors.primaryDark : AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+$pointsReward pontos ao completar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User summary
          FadeInUp(
            child: PointsSummaryCard(userLevel: userLevel),
          ),

          const SizedBox(height: 24),

          // Period selector
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _PeriodButton(
                    label: 'Semanal',
                    isSelected: period == LeaderboardPeriod.weekly,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(leaderboardPeriodProvider.notifier).state = LeaderboardPeriod.weekly;
                    },
                    isDark: isDark,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  _PeriodButton(
                    label: 'Mensal',
                    isSelected: period == LeaderboardPeriod.monthly,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(leaderboardPeriodProvider.notifier).state = LeaderboardPeriod.monthly;
                    },
                    isDark: isDark,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  _PeriodButton(
                    label: 'Geral',
                    isSelected: period == LeaderboardPeriod.allTime,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(leaderboardPeriodProvider.notifier).state = LeaderboardPeriod.allTime;
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Top 3 podium
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _TopThreePodium(
              entries: leaderboard.entries.take(3).toList(),
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 24),

          // Rest of leaderboard
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Ranking Completo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),

          const SizedBox(height: 12),

          ...leaderboard.entries.skip(3).toList().asMap().entries.map((entry) {
            return FadeInUp(
              delay: Duration(milliseconds: 350 + (entry.key * 50)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LeaderboardTile(entry: entry.value),
              ),
            );
          }),

          // Current user position if not in top 10
          if (leaderboard.currentUserEntry != null && leaderboard.currentUserEntry!.rank > 10) ...[
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: isDark ? AppColors.borderDark : AppColors.border),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '...',
                          style: TextStyle(
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: isDark ? AppColors.borderDark : AppColors.border),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LeaderboardTile(
                    entry: leaderboard.currentUserEntry!,
                    isCurrentUser: true,
                  ),
                ],
              ),
            ),
          ],

          // Goal message
          if (leaderboard.currentUserEntry != null) ...[
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 650),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _showAchievementDetailsModal(context, leaderboard.currentUserEntry!.rank);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.1),
                    border: Border.all(
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.target,
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Proxima meta',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getGoalMessage(leaderboard.currentUserEntry!.rank),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  String _getGoalMessage(int rank) {
    if (rank > 10) {
      return 'Faltam ${rank - 10} posicoes para o Top 10!';
    } else if (rank > 3) {
      return 'Faltam ${rank - 3} posicoes para o podio!';
    } else if (rank > 1) {
      return 'Voce esta quase no topo!';
    }
    return 'Voce e o lider! Continue assim!';
  }
}

class _AchievementsTab extends ConsumerWidget {
  final List<Achievement> unlockedAchievements;
  final bool isDark;

  const _AchievementsTab({
    required this.unlockedAchievements,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allAchievements = ref.watch(achievementsProvider);
    final lockedAchievements = ref.watch(lockedAchievementsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          FadeInUp(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${unlockedAchievements.length}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                        ),
                        Text(
                          'Desbloqueadas',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${allAchievements.length}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Unlocked achievements
          if (unlockedAchievements.isNotEmpty) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Text(
                'Desbloqueadas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...unlockedAchievements.asMap().entries.map((entry) {
              return FadeInUp(
                delay: Duration(milliseconds: 150 + (entry.key * 50)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AchievementCard(achievement: entry.value),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          // Locked achievements (in progress)
          if (lockedAchievements.isNotEmpty) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Text(
                'Em Progresso',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...lockedAchievements.asMap().entries.map((entry) {
              return FadeInUp(
                delay: Duration(milliseconds: 350 + (entry.key * 50)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AchievementCard(
                    achievement: entry.value,
                    isLocked: true,
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isSelected
            ? (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? (isDark ? AppColors.primaryDark : AppColors.primary)
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopThreePodium extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final bool isDark;

  const _TopThreePodium({
    required this.entries,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.length < 3) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.1),
            (isDark ? AppColors.secondaryDark : AppColors.secondary).withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          Expanded(
            child: _PodiumPlace(
              entry: entries[1],
              height: 80,
              color: const Color(0xFFC0C0C0), // Silver
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),
          // 1st place
          Expanded(
            child: _PodiumPlace(
              entry: entries[0],
              height: 100,
              color: const Color(0xFFFFD700), // Gold
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),
          // 3rd place
          Expanded(
            child: _PodiumPlace(
              entry: entries[2],
              height: 60,
              color: const Color(0xFFCD7F32), // Bronze
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  final LeaderboardEntry entry;
  final double height;
  final Color color;
  final bool isDark;

  const _PodiumPlace({
    required this.entry,
    required this.height,
    required this.color,
    required this.isDark,
  });

  void _showPlayerProfileModal(BuildContext context, LeaderboardEntry entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // User avatar and name
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mutedDark : AppColors.muted,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.primaryDark : AppColors.primary,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          entry.memberName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      entry.memberName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    if (entry.levelName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (entry.levelIcon != null)
                            Text(
                              entry.levelIcon!,
                              style: const TextStyle(fontSize: 16),
                            ),
                          const SizedBox(width: 4),
                          Text(
                            entry.levelName!,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Current rank and points
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Icon(
                                  LucideIcons.trophy,
                                  size: 24,
                                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '#${entry.rank}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                  ),
                                ),
                                Text(
                                  'Posicao',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.3),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Icon(
                                  LucideIcons.coins,
                                  size: 24,
                                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${entry.points}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                  ),
                                ),
                                Text(
                                  'Pontos',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Stats section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Estatisticas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.mutedDark.withValues(alpha: 0.5)
                            : AppColors.muted.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildStatRow(
                            context,
                            icon: LucideIcons.dumbbell,
                            label: 'Treinos completados',
                            value: '${entry.workoutsCompleted}',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            context,
                            icon: LucideIcons.calendarCheck,
                            label: 'Check-ins',
                            value: '${entry.checkIns}',
                            isDark: isDark,
                          ),
                          if (entry.rankChange != null) ...[
                            const SizedBox(height: 12),
                            _buildStatRow(
                              context,
                              icon: entry.rankChange! > 0
                                  ? LucideIcons.trendingUp
                                  : entry.rankChange! < 0
                                      ? LucideIcons.trendingDown
                                      : LucideIcons.minus,
                              label: 'Variacao no ranking',
                              value: entry.rankChange! > 0
                                  ? '+${entry.rankChange}'
                                  : '${entry.rankChange}',
                              isDark: isDark,
                              valueColor: entry.rankChange! > 0
                                  ? Colors.green
                                  : entry.rankChange! < 0
                                      ? Colors.red
                                      : null,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Recent achievements placeholder
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Conquistas recentes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.mutedDark.withValues(alpha: 0.5)
                            : AppColors.muted.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildAchievementBadge(context, LucideIcons.flame, 'Streak', isDark),
                          _buildAchievementBadge(context, LucideIcons.medal, 'Top 10', isDark),
                          _buildAchievementBadge(context, LucideIcons.dumbbell, 'Dedicado', isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).pop();
                              // TODO: Navigate to full profile
                            },
                            icon: const Icon(LucideIcons.user, size: 18),
                            label: const Text('Ver perfil'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              side: BorderSide(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).pop();
                              // TODO: Open message composer
                            },
                            icon: const Icon(LucideIcons.messageCircle, size: 18),
                            label: const Text('Mensagem'),
                            style: FilledButton.styleFrom(
                              backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? (isDark ? AppColors.foregroundDark : AppColors.foreground),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(BuildContext context, IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: isDark ? AppColors.primaryDark : AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _showPlayerProfileModal(context, entry);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.mutedDark : AppColors.muted),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
            ),
            child: Center(
              child: Text(
                entry.memberName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Name
          Text(
            entry.memberName.split(' ').first,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Points
          Text(
            '${entry.points} pts',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          // Podium bar
          Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color,
                  color.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${entry.rank}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
