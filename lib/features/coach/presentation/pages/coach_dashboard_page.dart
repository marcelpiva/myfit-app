import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../providers/coach_provider.dart';

class CoachDashboardPage extends ConsumerWidget {
  const CoachDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // Get org context and dashboard state
    final activeContext = ref.watch(activeContextProvider);
    final orgId = activeContext?.membership.organization.id;
    final dashboardState = orgId != null
        ? ref.watch(coachDashboardNotifierProvider(orgId))
        : const CoachDashboardState();

    // Convert programs to UI model
    final programs = _convertProgramsToUI(dashboardState.programs);
    final activities = _convertActivitiesToUI(dashboardState.recentActivities);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Coach Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/settings');
            },
            icon: const Icon(LucideIcons.settings),
            tooltip: 'Configuracoes',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withAlpha(isDark ? 15 : 10),
              AppColors.secondary.withAlpha(isDark ? 12 : 8),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Metrics header
              FadeInUp(
                child: _MetricsHeader(
                  isDark: isDark,
                  currencyFormat: currencyFormat,
                  totalPatients: dashboardState.totalPatients,
                  retentionRate: dashboardState.averageAdherence,
                  isLoading: dashboardState.isLoading,
                ),
              ),

              const SizedBox(height: 24),

              // Active programs
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: _SectionHeader(
                  title: 'Programas Ativos',
                  icon: LucideIcons.layoutGrid,
                  isDark: isDark,
                ),
              ),

              const SizedBox(height: 12),

              if (programs.isEmpty && !dashboardState.isLoading)
                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  child: _EmptyStateCard(
                    message: 'Nenhum programa ativo',
                    icon: LucideIcons.layoutGrid,
                    isDark: isDark,
                  ),
                )
              else
                ...programs.asMap().entries.map((entry) {
                  return FadeInUp(
                    delay: Duration(milliseconds: 150 + (entry.key * 50)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ProgramCard(
                        program: entry.value,
                        isDark: isDark,
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // Community section
              FadeInUp(
                delay: const Duration(milliseconds: 350),
                child: _SectionHeader(
                  title: 'Comunidade',
                  icon: LucideIcons.messageSquare,
                  isDark: isDark,
                  trailing: TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                    },
                    icon: const Icon(LucideIcons.externalLink, size: 14),
                    label: const Text('Abrir'),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _CommunityCard(isDark: isDark),
              ),

              const SizedBox(height: 24),

              // Quick actions
              FadeInUp(
                delay: const Duration(milliseconds: 450),
                child: _SectionHeader(
                  title: 'Acoes Rapidas',
                  icon: LucideIcons.zap,
                  isDark: isDark,
                ),
              ),

              const SizedBox(height: 12),

              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: _QuickActionsGrid(isDark: isDark),
              ),

              const SizedBox(height: 24),

              // Recent activity
              FadeInUp(
                delay: const Duration(milliseconds: 550),
                child: _SectionHeader(
                  title: 'Atividade Recente',
                  icon: LucideIcons.activity,
                  isDark: isDark,
                ),
              ),

              const SizedBox(height: 12),

              if (activities.isEmpty && !dashboardState.isLoading)
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: _EmptyStateCard(
                    message: 'Nenhuma atividade recente',
                    icon: LucideIcons.activity,
                    isDark: isDark,
                  ),
                )
              else
                ...activities.asMap().entries.map((entry) {
                  return FadeInUp(
                    delay: Duration(milliseconds: 600 + (entry.key * 50)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ActivityTile(
                        activity: entry.value,
                        isDark: isDark,
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricsHeader extends StatelessWidget {
  final bool isDark;
  final NumberFormat currencyFormat;
  final int totalPatients;
  final double retentionRate;
  final bool isLoading;

  const _MetricsHeader({
    required this.isDark,
    required this.currencyFormat,
    this.totalPatients = 0,
    this.retentionRate = 0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppColors.secondaryDark : AppColors.secondary,
            (isDark ? AppColors.secondaryDark : AppColors.secondary).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _MetricItem(
                    value: isLoading ? '-' : '$totalPatients',
                    label: 'Alunos',
                    icon: LucideIcons.users,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _MetricItem(
                    value: isLoading ? '-' : '${retentionRate.toStringAsFixed(0)}%',
                    label: 'Retencao',
                    icon: LucideIcons.userCheck,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _MetricItem(
                    value: currencyFormat.format(0),
                    label: 'Receita',
                    icon: LucideIcons.dollarSign,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.trendingUp,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  'Dados em tempo real',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
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

class _MetricItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _MetricItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.primaryDark : AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final _Program program;
  final bool isDark;

  const _ProgramCard({
    required this.program,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: program.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    program.icon,
                    size: 24,
                    color: program.color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.users,
                            size: 12,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${program.studentCount} alunos',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            LucideIcons.calendar,
                            size: 12,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${program.weeks} semanas',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                        ],
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
        ),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final bool isDark;

  const _CommunityCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.messageCircle,
                size: 24,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.destructive,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '12',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'mensagens nao lidas',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ultima atividade ha 15 minutos',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
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
}

class _QuickActionsGrid extends StatelessWidget {
  final bool isDark;

  const _QuickActionsGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: LucideIcons.plus,
            label: 'Novo Programa',
            color: isDark ? AppColors.primaryDark : AppColors.primary,
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionButton(
            icon: LucideIcons.video,
            label: 'Iniciar Live',
            color: AppColors.destructive,
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionButton(
            icon: LucideIcons.mail,
            label: 'Enviar Email',
            color: isDark ? AppColors.accentDark : AppColors.accent,
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final _Activity activity;
  final bool isDark;

  const _ActivityTile({
    required this.activity,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: activity.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(activity.icon, size: 18, color: activity.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activity.time,
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
    );
  }
}

// Empty State Card Widget
class _EmptyStateCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isDark;

  const _EmptyStateCard({
    required this.message,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground).withAlpha(150),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

// UI Model classes
class _Program {
  final String name;
  final int studentCount;
  final int weeks;
  final IconData icon;
  final Color color;

  const _Program({
    required this.name,
    required this.studentCount,
    required this.weeks,
    required this.icon,
    required this.color,
  });
}

class _Activity {
  final String message;
  final String time;
  final IconData icon;
  final Color color;

  const _Activity({
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
  });
}

// Helper functions to convert provider data to UI models
List<_Program> _convertProgramsToUI(List<CoachProgram> programs) {
  return programs.map((p) {
    final weeks = (p.daysRemaining / 7).ceil();
    return _Program(
      name: p.name,
      studentCount: 1, // Each program is per student
      weeks: weeks > 0 ? weeks : 1,
      icon: _getProgramIcon(p.name),
      color: _getProgramColor(p.status),
    );
  }).toList();
}

List<_Activity> _convertActivitiesToUI(List<CoachActivity> activities) {
  return activities.map((a) {
    return _Activity(
      message: '${a.studentName}: ${a.description}',
      time: _formatActivityTime(a.timestamp),
      icon: _getActivityIcon(a.type),
      color: _getActivityColor(a.type),
    );
  }).toList();
}

IconData _getProgramIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('emagrec') || lower.contains('perda')) return LucideIcons.scale;
  if (lower.contains('hipertrofia') || lower.contains('massa')) return LucideIcons.dumbbell;
  if (lower.contains('desafio')) return LucideIcons.flame;
  return LucideIcons.layoutGrid;
}

Color _getProgramColor(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return AppColors.success;
    case 'paused':
      return AppColors.warning;
    case 'completed':
      return AppColors.info;
    default:
      return AppColors.primary;
  }
}

IconData _getActivityIcon(String type) {
  switch (type.toLowerCase()) {
    case 'meal_logged':
      return LucideIcons.utensils;
    case 'plan_completed':
      return LucideIcons.checkCircle;
    case 'goal_reached':
      return LucideIcons.award;
    default:
      return LucideIcons.activity;
  }
}

Color _getActivityColor(String type) {
  switch (type.toLowerCase()) {
    case 'meal_logged':
      return AppColors.primary;
    case 'plan_completed':
      return AppColors.success;
    case 'goal_reached':
      return AppColors.warning;
    default:
      return AppColors.accent;
  }
}

String _formatActivityTime(DateTime timestamp) {
  final now = DateTime.now();
  final diff = now.difference(timestamp);

  if (diff.inMinutes < 60) {
    return 'Ha ${diff.inMinutes} minutos';
  } else if (diff.inHours < 24) {
    return 'Ha ${diff.inHours} horas';
  } else {
    return 'Ha ${diff.inDays} dias';
  }
}
