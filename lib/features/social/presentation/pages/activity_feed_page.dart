import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/activity_item.dart';
import '../providers/activity_feed_provider.dart';
import '../widgets/activity_card.dart';

/// Activity Feed Page - Social feed showing activities from friends and gym members
class ActivityFeedPage extends ConsumerStatefulWidget {
  const ActivityFeedPage({super.key});

  @override
  ConsumerState<ActivityFeedPage> createState() => _ActivityFeedPageState();
}

class _ActivityFeedPageState extends ConsumerState<ActivityFeedPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(activityFeedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final feedState = ref.watch(activityFeedProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Atividades'),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {
              // TODO: Navigate to notifications
              HapticUtils.lightImpact();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticUtils.lightImpact();
          await ref.read(activityFeedProvider.notifier).refresh();
        },
        child: feedState.isLoading
            ? _buildLoadingState(isDark)
            : feedState.error != null
                ? _buildErrorState(isDark, feedState.error!)
                : feedState.activities.isEmpty
                    ? _buildEmptyState(isDark)
                    : _buildFeedList(isDark, feedState),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonCard(isDark),
    );
  }

  Widget _buildSkeletonCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.mutedForegroundDark.withAlpha(30)
                      : AppColors.mutedForeground.withAlpha(30),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.mutedForegroundDark.withAlpha(30)
                            : AppColors.mutedForeground.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.mutedForegroundDark.withAlpha(20)
                            : AppColors.mutedForeground.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.mutedForegroundDark.withAlpha(30)
                  : AppColors.mutedForeground.withAlpha(30),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: 200,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.mutedForegroundDark.withAlpha(20)
                  : AppColors.mutedForeground.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.destructive.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                LucideIcons.alertCircle,
                size: 40,
                color: AppColors.destructive,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erro ao carregar atividades',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                HapticUtils.lightImpact();
                ref.read(activityFeedProvider.notifier).refresh();
              },
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                LucideIcons.users,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma atividade ainda',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete treinos, bata recordes e acompanhe o progresso dos seus amigos aqui!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                HapticUtils.mediumImpact();
                context.pop();
              },
              icon: const Icon(LucideIcons.dumbbell, size: 18),
              label: const Text('Iniciar Treino'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedList(bool isDark, ActivityFeedState feedState) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      itemCount: feedState.activities.length + (feedState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == feedState.activities.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final activity = feedState.activities[index];

        return ActivityCard(
          activity: activity,
          onReact: () {
            ref.read(activityFeedProvider.notifier).toggleReaction(activity.id);
          },
          onShare: () => _shareActivity(activity),
          onTap: () => _onActivityTap(activity),
        );
      },
    );
  }

  void _shareActivity(ActivityItem activity) {
    HapticUtils.lightImpact();
    final text = '${activity.userName} - ${activity.title}\n${activity.description}';
    Share.share(text);
  }

  void _onActivityTap(ActivityItem activity) {
    HapticUtils.lightImpact();
    // TODO: Navigate to activity details based on type
  }
}
