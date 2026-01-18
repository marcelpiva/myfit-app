import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../shared/presentation/components/components.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../trainer_home/presentation/pages/trainer_home_page.dart';
import '../../../nutritionist_home/presentation/pages/nutritionist_home_page.dart';
import '../../../gym_home/presentation/pages/gym_home_page.dart';

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

    return Scaffold(
      body: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Header
                    _buildHeader(context, isDark, userName, userInitials),

                    const SizedBox(height: 32),

                    // Stats Row
                    _buildStatsRow(context, isDark),

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

                    _buildTodayWorkout(context, isDark),

                    const SizedBox(height: 32),

                    // Quick Actions
                    _buildSectionHeader(context, isDark, 'Ações Rápidas'),

                    const SizedBox(height: 16),

                    _buildQuickActions(context, isDark),

                    const SizedBox(height: 32),

                    // Explorar Treinos
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

                    // Recent Activity
                    _buildSectionHeader(context, isDark, 'Atividade Recente'),

                    const SizedBox(height: 16),

                    _buildRecentActivity(context, isDark),

                    const SizedBox(height: 100),
                  ],
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
                'Ola, ${userName.split(' ').first}',
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

  Widget _buildStatsRow(BuildContext context, bool isDark) {
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
            '12',
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
            '85%',
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
            '4.5kg',
            'Perdidos',
            LucideIcons.trendingDown,
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

  Widget _buildTodayWorkout(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticUtils.mediumImpact();
        context.push('/workouts/1');
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
                  child: const Text(
                    'TREINO A',
                    style: TextStyle(
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

            const Text(
              'Peito e Tríceps',
              style: TextStyle(
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
                const Text(
                  '45-60 min',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(width: 16),
                const Icon(LucideIcons.flame, size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                const Text(
                  '8 exercícios',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
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
                    const Text(
                      '3/5 dias',
                      style: TextStyle(
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
                    widthFactor: 0.6,
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

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final actionsRow1 = [
      (LucideIcons.play, 'Iniciar\nTreino', AppColors.primary, () {
        HapticUtils.mediumImpact();
        _showStartWorkoutOptions(context, isDark);
      }),
      (LucideIcons.mapPin, 'Check-in', AppColors.secondary, () {
        HapticUtils.lightImpact();
        context.push(RouteNames.checkin);
      }),
      (LucideIcons.trophy, 'Ranking', AppColors.accent, () {
        HapticUtils.lightImpact();
        context.push(RouteNames.leaderboard);
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
      (LucideIcons.sparkles, 'AI\nWizard', AppColors.accent, () {
        HapticUtils.lightImpact();
        context.push(RouteNames.programWizard);
      }),
      (LucideIcons.creditCard, 'Cobranças', AppColors.success, () {
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
      ('forca', 'Forca', 'Forca maxima', LucideIcons.gauge, AppColors.secondary),
      ('emagrecimento', 'Emagrecimento', 'Perda de gordura', LucideIcons.flame, AppColors.destructive),
      ('resistencia', 'Resistencia', 'Condicionamento', LucideIcons.heart, AppColors.success),
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

  Widget _buildRecentActivity(BuildContext context, bool isDark) {
    final activities = [
      ('Treino Completado', 'Peito e Tríceps', '2h atrás', LucideIcons.checkCircle, AppColors.success),
      ('Nova Dieta', 'Cutting - 1800 kcal', 'Ontem', LucideIcons.utensils, AppColors.secondary),
      ('Medição Atualizada', 'Peso: 75.2kg', '2 dias atrás', LucideIcons.ruler, AppColors.accent),
    ];

    return Column(
      children: activities.map((activity) {
        final (title, subtitle, time, icon, color) = activity;
        return Container(
          margin: EdgeInsets.only(
            bottom: activities.indexOf(activity) < activities.length - 1 ? 12 : 0,
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
                      title,
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
                      subtitle,
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
                time,
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

  void _showStartWorkoutOptions(BuildContext context, bool isDark) {
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
              GestureDetector(
                onTap: () {
                  HapticUtils.mediumImpact();
                  Navigator.pop(ctx);
                  context.push('/workouts'); // Navigate to workouts list
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
                            const Text(
                              'Treino A - Peito e Tríceps',
                              style: TextStyle(
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
                                const Text(
                                  '~60 min',
                                  style: TextStyle(
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

              const SizedBox(height: 16),

              // Outros treinos
              _buildStartOption(
                ctx,
                isDark,
                LucideIcons.list,
                'Escolher Treino',
                'Selecione um dos seus treinos',
                AppColors.secondary,
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
                LucideIcons.dumbbell,
                'Treino Livre',
                'Comece sem um plano definido',
                AppColors.accent,
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  context.push('/workouts'); // Navigate to workouts list
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
                  context.push(RouteNames.programWizard);
                },
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
