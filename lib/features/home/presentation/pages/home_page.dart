import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/dev_screen_label.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../trainer_home/presentation/pages/trainer_home_page.dart';
import '../../../nutritionist_home/presentation/pages/nutritionist_home_page.dart';
import '../../../gym_home/presentation/pages/gym_home_page.dart';
import '../../data/models/student_dashboard.dart';
import '../providers/student_home_provider.dart';
import '../widgets/streak_calendar.dart';

/// Role-aware home page that renders different content based on active context
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeContext = ref.watch(activeContextProvider);

    // If no active context, show student home (default)
    if (activeContext == null) {
      return const _StudentHomePage();
    }

    // Render appropriate home based on role
    if (activeContext.isTrainer) {
      return const TrainerHomePage();
    }
    if (activeContext.isNutritionist) {
      return const NutritionistHomePage();
    }
    if (activeContext.isGymRole) {
      return const GymHomePage();
    }

    // Default to student home
    return const _StudentHomePage();
  }
}

/// Student home page content (original HomePage implementation)
class _StudentHomePage extends ConsumerStatefulWidget {
  const _StudentHomePage();

  @override
  ConsumerState<_StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends ConsumerState<_StudentHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.entrance,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);
    final userName = currentUser?.name ?? 'Aluno';
    final userInitials = _getInitials(userName);

    // Watch dashboard state
    final dashboardState = ref.watch(studentDashboardProvider);
    // Watch pending plans (only if student has a trainer)
    final pendingPlansState = dashboardState.hasTrainer
        ? ref.watch(studentPendingPlansProvider)
        : null;

    return DevScreenLabel(
      screenName: 'StudentHomePage',
      child: Scaffold(
        body: Container(
          color: isDark ? AppColors.backgroundDark : AppColors.background,
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: dashboardState.isLoading && dashboardState.dashboard == null
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                    onRefresh: () async {
                      ref.read(studentDashboardProvider.notifier).refresh();
                      if (dashboardState.hasTrainer) {
                        ref.read(studentPendingPlansProvider.notifier).refresh();
                      }
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),

                            // Header
                            _buildHeader(context, isDark, userName, userInitials),

                            const SizedBox(height: 32),

                            // Trainer Info Card (if has trainer)
                            if (dashboardState.hasTrainer) ...[
                              _buildTrainerCard(context, isDark, dashboardState.trainer!),
                              const SizedBox(height: 24),
                            ],

                            // Pending Plans Notification (if has pending plans)
                            if (pendingPlansState != null && pendingPlansState.hasPendingPlans) ...[
                              _buildPendingPlansCard(context, isDark, pendingPlansState),
                              const SizedBox(height: 24),
                            ],

                            // Stats Row
                            _buildStatsRow(context, isDark, dashboardState.stats),

                            const SizedBox(height: 24),

                            // Streak Calendar
                            StreakCalendar(
                              currentStreak: dashboardState.stats.currentStreak,
                              completedDays: _getCompletedDaysFromActivity(dashboardState.recentActivity),
                              isDark: isDark,
                            ),

                            const SizedBox(height: 32),

                            // Today's Workout
                            _buildSectionHeader(
                              context,
                              isDark,
                              'Treino de Hoje',
                              onSeeAll: () {
                                HapticUtils.lightImpact();
                                context.go(RouteNames.workouts);
                              },
                            ),

                            const SizedBox(height: 16),

                            _buildTodayWorkout(
                              context,
                              isDark,
                              dashboardState.todayWorkout,
                              dashboardState.weeklyProgress,
                            ),

                            const SizedBox(height: 32),

                            // Quick Actions
                            _buildSectionHeader(context, isDark, 'Ações Rápidas'),

                            const SizedBox(height: 16),

                            _buildQuickActions(context, isDark, dashboardState),

                            const SizedBox(height: 32),

                            // Explorar Treinos - Only show when student has NO trainer
                            if (!dashboardState.hasTrainer) ...[
                              _buildSectionHeader(
                                context,
                                isDark,
                                'Explorar Treinos',
                                onSeeAll: () {
                                  HapticUtils.lightImpact();
                                  context.push('/workouts/templates');
                                },
                              ),

                              const SizedBox(height: 16),

                              _buildWorkoutCatalogPreview(context, isDark),

                              const SizedBox(height: 32),
                            ],

                            // Recent Activity
                            _buildSectionHeader(context, isDark, 'Atividade Recente'),

                            const SizedBox(height: 16),

                            _buildRecentActivity(context, isDark, dashboardState.recentActivity),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  List<DateTime> _getCompletedDaysFromActivity(List<RecentActivity> activities) {
    // Extract completed workout days from recent activity
    // This is a simplified version - in production, you'd get this from a dedicated API
    final completedDays = <DateTime>[];
    final now = DateTime.now();

    for (final activity in activities) {
      if (activity.type == 'workout') {
        // Parse time string to approximate date
        // Time formats: "Hoje", "Ontem", "Há 2 dias", etc.
        final time = activity.time.toLowerCase();
        DateTime? date;

        if (time.contains('hoje')) {
          date = DateTime(now.year, now.month, now.day);
        } else if (time.contains('ontem')) {
          date = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
        } else if (time.contains('há')) {
          final match = RegExp(r'há (\d+) dia').firstMatch(time);
          if (match != null) {
            final daysAgo = int.tryParse(match.group(1) ?? '0') ?? 0;
            date = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysAgo));
          }
        }

        if (date != null && !completedDays.any((d) =>
            d.year == date!.year && d.month == date.month && d.day == date.day)) {
          completedDays.add(date);
        }
      }
    }

    return completedDays;
  }

  Widget _buildHeader(BuildContext context, bool isDark, String userName, String userInitials) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isDark ? AppColors.mutedDark : AppColors.muted,
          ),
          child: Center(
            child: Text(
              userInitials,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, ${userName.split(' ').first}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Vamos treinar hoje?',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),

        // Switch Profile
        GestureDetector(
          onTap: () {
            HapticUtils.lightImpact();
            context.go(RouteNames.orgSelector);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDark ? AppColors.cardDark : AppColors.card,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Icon(
              LucideIcons.repeat,
              size: 20,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Notifications
        GestureDetector(
          onTap: () {
            HapticUtils.lightImpact();
            context.push(RouteNames.notifications);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDark ? AppColors.cardDark : AppColors.card,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    LucideIcons.bell,
                    size: 20,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.destructive,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Settings
        GestureDetector(
          onTap: () {
            HapticUtils.lightImpact();
            context.push(RouteNames.settings);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDark ? AppColors.cardDark : AppColors.card,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Icon(
              LucideIcons.settings,
              size: 20,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, bool isDark, StudentStats stats) {
    // Format weight change
    String weightText;
    IconData weightIcon;
    if (stats.weightChangeKg == null) {
      weightText = '--';
      weightIcon = LucideIcons.minus;
    } else if (stats.weightChangeKg! < 0) {
      weightText = '${stats.weightChangeKg!.abs()}kg';
      weightIcon = LucideIcons.trendingDown;
    } else if (stats.weightChangeKg! > 0) {
      weightText = '+${stats.weightChangeKg}kg';
      weightIcon = LucideIcons.trendingUp;
    } else {
      weightText = '0kg';
      weightIcon = LucideIcons.minus;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            isDark,
            '${stats.totalWorkouts}',
            'Treinos',
            LucideIcons.dumbbell,
            AppColors.primary,
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          _buildStatItem(
            context,
            isDark,
            '${stats.adherencePercent}%',
            'Aderência',
            LucideIcons.target,
            AppColors.success,
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          _buildStatItem(
            context,
            isDark,
            weightText,
            stats.weightChangeKg != null && stats.weightChangeKg! < 0 ? 'Perdidos' : 'Variação',
            weightIcon,
            AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    bool isDark,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildTrainerCard(BuildContext context, bool isDark, TrainerInfo trainer) {
    final unreadNotesCount = ref.watch(unreadNotesCountProvider);

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        context.go(RouteNames.chat);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary.withAlpha(25),
              ),
              child: trainer.avatarUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        trainer.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            trainer.name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        trainer.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
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
                        'Seu Personal',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                      // Unread notes badge
                      if (unreadNotesCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.stickyNote,
                                size: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$unreadNotesCount nova${unreadNotesCount > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        trainer.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (trainer.isOnline)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.messageCircle,
              size: 20,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPlansCard(
    BuildContext context,
    bool isDark,
    StudentPendingPlansState pendingState,
  ) {
    final count = pendingState.pendingCount;
    final firstPlan = pendingState.pendingPlans.first;
    final planName = firstPlan['plan_name'] as String? ?? 'Novo Plano';
    final trainerName = firstPlan['trainer_name'] as String?;

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        _showRespondPlanSheet(context, firstPlan);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.warning.withAlpha(isDark ? 40 : 30),
              AppColors.warning.withAlpha(isDark ? 20 : 15),
            ],
          ),
          border: Border.all(
            color: AppColors.warning.withAlpha(100),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.bellRing,
                  size: 24,
                  color: AppColors.warning,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count > 1 ? '$count PENDENTES' : 'NOVO PLANO',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    count > 1
                        ? 'Voce tem $count planos aguardando resposta'
                        : planName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (count == 1 && trainerName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Prescrito por $trainerName',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Action indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Responder',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRespondPlanSheet(BuildContext context, Map<String, dynamic> assignment) {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StudentRespondPlanSheet(
        assignment: assignment,
        onAccept: () async {
          HapticUtils.mediumImpact();
          final success = await ref
              .read(studentPendingPlansProvider.notifier)
              .acceptPlan(assignment['id'] as String);
          if (ctx.mounted) {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      success ? LucideIcons.checkCircle : LucideIcons.alertCircle,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(success ? 'Plano aceito com sucesso!' : 'Erro ao aceitar plano'),
                  ],
                ),
                backgroundColor: success ? AppColors.success : AppColors.destructive,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Refresh dashboard to update UI
            ref.read(studentDashboardProvider.notifier).refresh();
          }
        },
        onDecline: (reason) async {
          HapticUtils.mediumImpact();
          final success = await ref
              .read(studentPendingPlansProvider.notifier)
              .declinePlan(assignment['id'] as String, reason: reason);
          if (ctx.mounted) {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      success ? LucideIcons.info : LucideIcons.alertCircle,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(success ? 'Plano recusado' : 'Erro ao recusar plano'),
                  ],
                ),
                backgroundColor: success ? AppColors.mutedForeground : AppColors.destructive,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    bool isDark,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'Ver todos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTodayWorkout(
    BuildContext context,
    bool isDark,
    TodayWorkout? todayWorkout,
    WeeklyProgress weeklyProgress,
  ) {
    // Calculate progress fraction
    final progressFraction = weeklyProgress.target > 0
        ? weeklyProgress.completed / weeklyProgress.target
        : 0.0;

    // If no workout today, show empty state
    if (todayWorkout == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              LucideIcons.calendarOff,
              size: 48,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum treino programado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha um treino ou crie um novo',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticUtils.lightImpact();
                  context.go(RouteNames.workouts);
                },
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Escolher Treino'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        HapticUtils.mediumImpact();
        context.push('/workouts/${todayWorkout.workoutId}');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withAlpha(200),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withAlpha(30),
                  ),
                  child: Text(
                    todayWorkout.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withAlpha(30),
                  ),
                  child: const Icon(
                    LucideIcons.play,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              todayWorkout.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(LucideIcons.clock, size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  '~${todayWorkout.durationMinutes} min',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(width: 16),
                const Icon(LucideIcons.flame, size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  '${todayWorkout.exercisesCount} exercícios',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progresso da Semana',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    Text(
                      '${weeklyProgress.completed}/${weeklyProgress.target} dias',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withAlpha(50),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressFraction.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark, StudentDashboardState dashboardState) {
    final actionsRow1 = [
      (LucideIcons.play, 'Iniciar\nTreino', AppColors.primary, () {
        HapticUtils.mediumImpact();
        _showStartWorkoutOptions(context, isDark, dashboardState);
      }),
      (LucideIcons.mapPin, 'Check-in', AppColors.secondary, () {
        HapticUtils.lightImpact();
        context.push(RouteNames.checkin);
      }),
      (LucideIcons.users, 'Feed', AppColors.accent, () {
        HapticUtils.lightImpact();
        context.push(RouteNames.activityFeed);
      }),
      (LucideIcons.messageCircle, 'Chat', AppColors.success, () {
        HapticUtils.lightImpact();
        context.go(RouteNames.chat);
      }),
    ];
    final actionsRow2 = [
      (LucideIcons.utensils, 'Ver\nDieta', AppColors.primary, () {
        HapticUtils.lightImpact();
        context.go(RouteNames.nutrition);
      }),
      (LucideIcons.camera, 'Foto\nProgresso', AppColors.secondary, () {
        HapticUtils.lightImpact();
        context.push(RouteNames.progress);
      }),
      // Show "Meus Treinos" when student has trainer, "AI Wizard" otherwise
      dashboardState.hasTrainer
          ? (LucideIcons.clipboard, 'Meus\nTreinos', AppColors.accent, () {
              HapticUtils.lightImpact();
              context.go(RouteNames.workouts);
            })
          : (LucideIcons.sparkles, 'AI\nWizard', AppColors.accent, () {
              HapticUtils.lightImpact();
              context.push(RouteNames.planWizard);
            }),
      // Show "Agenda" when student has trainer, "Cobranças" otherwise
      dashboardState.hasTrainer
          ? (LucideIcons.calendar, 'Agenda', AppColors.success, () {
              HapticUtils.lightImpact();
              context.push(RouteNames.mySchedule);
            })
          : (LucideIcons.creditCard, 'Cobranças', AppColors.success, () {
              HapticUtils.lightImpact();
              context.push(RouteNames.billing);
            }),
    ];
    Widget buildRow(List<(IconData, String, Color, VoidCallback)> actions) {
      return Row(
        children: actions.map((action) {
          final (icon, label, color, onTap) = action;
          return Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 100,
                margin: EdgeInsets.only(
                  right: actions.indexOf(action) < actions.length - 1 ? 12 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDark
                      ? AppColors.cardDark.withAlpha(150)
                      : AppColors.card.withAlpha(200),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: color.withAlpha(25),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        buildRow(actionsRow1),
        const SizedBox(height: 12),
        buildRow(actionsRow2),
      ],
    );
  }

  Widget _buildWorkoutCatalogPreview(BuildContext context, bool isDark) {
    final categories = [
      ('hipertrofia', 'Hipertrofia', 'Ganho de massa', LucideIcons.dumbbell, AppColors.primary),
      ('forca', 'Força', 'Força máxima', LucideIcons.gauge, AppColors.secondary),
      ('emagrecimento', 'Emagrecimento', 'Perda de gordura', LucideIcons.flame, AppColors.destructive),
      ('resistencia', 'Resistência', 'Condicionamento', LucideIcons.heart, AppColors.success),
      ('funcional', 'Funcional', 'Dia a dia', LucideIcons.activity, AppColors.accent),
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final (id, name, description, icon, color) = categories[index];
          return GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              context.push('/workouts/templates?category=$id');
            },
            child: Container(
              width: 140,
              margin: EdgeInsets.only(
                right: index < categories.length - 1 ? 12 : 0,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: color.withAlpha(25),
                    ),
                    child: Icon(icon, size: 20, color: color),
                  ),
                  const Spacer(),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, bool isDark, List<RecentActivity> activities) {
    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              LucideIcons.history,
              size: 40,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma atividade recente',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      );
    }

    // Map activity type to icon and color
    IconData getActivityIcon(String type) {
      switch (type) {
        case 'workout':
          return LucideIcons.checkCircle;
        case 'diet':
          return LucideIcons.utensils;
        case 'measurement':
          return LucideIcons.ruler;
        case 'achievement':
          return LucideIcons.trophy;
        default:
          return LucideIcons.activity;
      }
    }

    Color getActivityColor(String type) {
      switch (type) {
        case 'workout':
          return AppColors.success;
        case 'diet':
          return AppColors.secondary;
        case 'measurement':
          return AppColors.accent;
        case 'achievement':
          return AppColors.primary;
        default:
          return AppColors.info;
      }
    }

    return Column(
      children: activities.asMap().entries.map((entry) {
        final index = entry.key;
        final activity = entry.value;
        final icon = getActivityIcon(activity.type);
        final color = getActivityColor(activity.type);

        return Container(
          margin: EdgeInsets.only(
            bottom: index < activities.length - 1 ? 12 : 0,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isDark
                ? AppColors.cardDark.withAlpha(150)
                : AppColors.card.withAlpha(200),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: color.withAlpha(25),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                activity.time,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showStartWorkoutOptions(BuildContext context, bool isDark, StudentDashboardState dashboardState) {
    final todayWorkout = dashboardState.todayWorkout;
    final canTrainWithPersonal = dashboardState.canTrainWithPersonal && dashboardState.hasTrainer;
    final trainingMode = dashboardState.trainingMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Iniciar Treino',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 20),

              // Treino do dia (se houver)
              if (todayWorkout != null)
                GestureDetector(
                  onTap: () {
                    HapticUtils.mediumImpact();
                    Navigator.pop(ctx);
                    context.push('/workouts/${todayWorkout.workoutId}');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withAlpha(200)],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withAlpha(50),
                          ),
                          child: const Icon(LucideIcons.calendar, size: 28, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${todayWorkout.label} - ${todayWorkout.name}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(50),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'TREINO DO DIA',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '~${todayWorkout.durationMinutes} min',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(LucideIcons.play, size: 24, color: Colors.white),
                      ],
                    ),
                  ),
                ),

              if (todayWorkout != null) const SizedBox(height: 16),

              // Opção: Treinar com Personal (se modo presencial ou híbrido)
              if (canTrainWithPersonal) ...[
                _buildStartOption(
                  ctx,
                  isDark,
                  LucideIcons.users,
                  'Treinar com Personal',
                  'Inicie uma sessão acompanhada',
                  AppColors.success,
                  () {
                    HapticUtils.mediumImpact();
                    Navigator.pop(ctx);
                    // TODO: Implement co-training session creation
                    // For now, navigate to workouts
                    if (todayWorkout != null) {
                      context.push('/workouts/${todayWorkout.workoutId}?withTrainer=true');
                    } else {
                      context.go(RouteNames.workouts);
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],

              // Treinar Sozinho
              _buildStartOption(
                ctx,
                isDark,
                LucideIcons.user,
                canTrainWithPersonal ? 'Treinar Sozinho' : 'Iniciar Treino',
                canTrainWithPersonal
                    ? 'Execute o treino por conta própria'
                    : 'Selecione um dos seus treinos',
                canTrainWithPersonal ? AppColors.secondary : AppColors.primary,
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  if (todayWorkout != null) {
                    context.push('/workouts/${todayWorkout.workoutId}');
                  } else {
                    context.go(RouteNames.workouts);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Options only available when student has NO trainer
              if (!dashboardState.hasTrainer) ...[
                // Outros treinos
                _buildStartOption(
                  ctx,
                  isDark,
                  LucideIcons.list,
                  'Escolher Outro Treino',
                  'Selecione um treino diferente',
                  AppColors.accent,
                  () {
                    HapticUtils.lightImpact();
                    Navigator.pop(ctx);
                    context.go(RouteNames.workouts);
                  },
                ),
                const SizedBox(height: 12),
                _buildStartOption(
                  ctx,
                  isDark,
                  LucideIcons.sparkles,
                  'Gerar com IA',
                  'Deixe a IA criar um treino rápido',
                  AppColors.info,
                  () {
                    HapticUtils.lightImpact();
                    Navigator.pop(ctx);
                    context.push(RouteNames.planWizard);
                  },
                ),
                const SizedBox(height: 12),
              ],

              // Mostrar modo de treinamento atual
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDark
                      ? AppColors.mutedDark.withAlpha(100)
                      : AppColors.muted.withAlpha(100),
                ),
                child: Row(
                  children: [
                    Icon(
                      trainingMode == TrainingMode.presencial
                          ? LucideIcons.users
                          : trainingMode == TrainingMode.online
                              ? LucideIcons.wifi
                              : LucideIcons.refreshCw,
                      size: 16,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Modo: ${trainingMode == TrainingMode.presencial ? 'Presencial' : trainingMode == TrainingMode.online ? 'Online' : 'Híbrido'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartOption(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDark
              ? AppColors.mutedDark.withAlpha(150)
              : AppColors.muted.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color.withAlpha(25),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for student to respond to a pending plan assignment
class _StudentRespondPlanSheet extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final VoidCallback onAccept;
  final void Function(String? reason) onDecline;

  const _StudentRespondPlanSheet({
    required this.assignment,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<_StudentRespondPlanSheet> createState() => _StudentRespondPlanSheetState();
}

class _StudentRespondPlanSheetState extends State<_StudentRespondPlanSheet> {
  final _reasonController = TextEditingController();
  bool _showDeclineReason = false;
  bool _isProcessing = false;

  String get _planName => widget.assignment['plan_name'] as String? ?? 'Plano de Treino';
  String? get _trainerName => widget.assignment['trainer_name'] as String?;
  String? get _notes => widget.assignment['notes'] as String?;
  String? get _startDateStr => widget.assignment['start_date'] as String?;
  String? get _endDateStr => widget.assignment['end_date'] as String?;
  String? get _goal => widget.assignment['plan']?['goal'] as String?;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '--';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _translateGoal(String? goal) {
    if (goal == null) return '--';
    switch (goal.toLowerCase()) {
      case 'hypertrophy':
        return 'Hipertrofia';
      case 'strength':
        return 'Forca';
      case 'fat_loss':
        return 'Emagrecimento';
      case 'endurance':
        return 'Resistencia';
      case 'functional':
        return 'Funcional';
      default:
        return goal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              children: [
                // Pending badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.warning.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.clock, size: 14, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text(
                        'Aguardando sua resposta',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Plan name
                Text(
                  _planName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (_trainerName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.user,
                        size: 14,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Prescrito por $_trainerName',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Plan details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      isDark,
                      LucideIcons.calendar,
                      'Inicio',
                      _formatDate(_startDateStr),
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      isDark,
                      LucideIcons.calendarCheck,
                      'Termino',
                      _endDateStr != null ? _formatDate(_endDateStr) : 'Continuo',
                    ),
                  ),
                  if (_goal != null)
                    Expanded(
                      child: _buildDetailItem(
                        context,
                        isDark,
                        LucideIcons.target,
                        'Objetivo',
                        _translateGoal(_goal),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Trainer notes
          if (_notes != null && _notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withAlpha(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.messageSquare, size: 16, color: AppColors.info),
                        const SizedBox(width: 8),
                        Text(
                          'Nota do Personal',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _notes!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Decline reason input
          if (_showDeclineReason) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _reasonController,
                maxLines: 2,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: 'Motivo da recusa (opcional)',
                  hintText: 'Ex: Prefiro outro tipo de treino...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(LucideIcons.messageCircle),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              children: [
                // Decline button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () {
                            if (!_showDeclineReason) {
                              setState(() => _showDeclineReason = true);
                            } else {
                              setState(() => _isProcessing = true);
                              widget.onDecline(_reasonController.text.trim().isNotEmpty
                                  ? _reasonController.text.trim()
                                  : null);
                            }
                          },
                    icon: Icon(
                      _showDeclineReason ? LucideIcons.send : LucideIcons.x,
                      size: 18,
                    ),
                    label: Text(_showDeclineReason ? 'Confirmar' : 'Recusar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.destructive,
                      side: const BorderSide(color: AppColors.destructive),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Accept button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () {
                            setState(() => _isProcessing = true);
                            widget.onAccept();
                          },
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(LucideIcons.check, size: 18),
                    label: Text(_isProcessing ? 'Processando...' : 'Aceitar Plano'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    bool isDark,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 12,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
