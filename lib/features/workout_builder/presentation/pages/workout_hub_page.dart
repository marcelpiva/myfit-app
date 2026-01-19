import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';

/// Hub page for workout management and creation options
class WorkoutHubPage extends ConsumerWidget {
  const WorkoutHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final options = [
      _HubOption(
        icon: LucideIcons.list,
        title: 'Meus Treinos',
        description: 'Veja e gerencie seus treinos criados',
        color: AppColors.primary,
        route: RouteNames.workouts,
      ),
      _HubOption(
        icon: LucideIcons.clipboard,
        title: 'Criar Plano',
        description: 'Monte um plano completo de treinos',
        color: isDark ? AppColors.secondaryDark : AppColors.secondary,
        route: RouteNames.planWizard,
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
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
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              _buildAppBar(context, theme, isDark),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      FadeInUp(
                        child: _buildHeader(theme, isDark),
                      ),

                      const SizedBox(height: 24),

                      // Options
                      ...options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        return FadeInUp(
                          delay: Duration(milliseconds: 100 + (index * 50)),
                          child: _buildOptionCard(context, theme, isDark, option),
                        );
                      }),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
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
              child: Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Icon(
                  LucideIcons.dumbbell,
                  size: 20,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Treinos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(26),
            (isDark ? AppColors.secondaryDark : AppColors.secondary).withAlpha(26),
          ],
        ),
        border: Border.all(
          color: (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(77),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryDark : AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.dumbbell,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Central de Treinos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Text(
                  'Gerencie, crie e personalize treinos para seus alunos',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    _HubOption option,
  ) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        context.push(option.route);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: option.color.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                option.icon,
                size: 24,
                color: option.color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: theme.textTheme.bodySmall?.copyWith(
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

class _HubOption {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String route;

  _HubOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.route,
  });
}
