import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../trainer_home/presentation/providers/trainer_home_provider.dart';
import '../../../trainer_workout/presentation/providers/trainer_students_provider.dart';

/// Dashboard for Personal Trainers - shows students, pending tasks, quick actions
class TrainerDashboardPage extends ConsumerStatefulWidget {
  const TrainerDashboardPage({super.key});

  @override
  ConsumerState<TrainerDashboardPage> createState() => _TrainerDashboardPageState();
}

class _TrainerDashboardPageState extends ConsumerState<TrainerDashboardPage>
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

    // Get org context and watch providers
    final activeContext = ref.watch(activeContextProvider);
    final orgId = activeContext?.organization.id;
    final dashboardState = ref.watch(trainerDashboardNotifierProvider(orgId));
    final studentsState = ref.watch(trainerStudentsNotifierProvider(orgId));

    return Scaffold(
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
                    _buildHeader(context, isDark),

                    const SizedBox(height: 24),

                    // Stats cards
                    _buildStatsGrid(context, isDark),

                    const SizedBox(height: 32),

                    // Quick Actions
                    _buildSectionHeader(context, isDark, 'Acoes Rapidas'),
                    const SizedBox(height: 16),
                    _buildQuickActions(context, isDark),

                    const SizedBox(height: 32),

                    // Pending Tasks / Alerts
                    _buildSectionHeader(
                      context,
                      isDark,
                      'Tarefas Pendentes',
                      badge: dashboardState.alerts.isNotEmpty
                          ? '${dashboardState.alerts.length}'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildPendingTasks(context, isDark, dashboardState.alerts),

                    const SizedBox(height: 32),

                    // Recent Students
                    _buildSectionHeader(
                      context,
                      isDark,
                      'Alunos Recentes',
                      onSeeAll: () {
                        HapticUtils.lightImpact();
                        context.push(RouteNames.students);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildRecentStudents(context, isDark, studentsState.students),

                    const SizedBox(height: 32),

                    // Today's Schedule
                    _buildSectionHeader(context, isDark, 'Agenda de Hoje'),
                    const SizedBox(height: 16),
                    _buildTodaySchedule(context, isDark, dashboardState.todaySchedule),

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

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Logo/Brand
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'M',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meus Alunos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              Text(
                'Personal Trainer',
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

        // Notifications
        _buildIconButton(context, isDark, LucideIcons.bell, badge: 3),
        const SizedBox(width: 8),
        _buildIconButton(context, isDark, LucideIcons.settings),
      ],
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    bool isDark,
    IconData icon, {
    int? badge,
  }) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                size: 20,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.destructive,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: LucideIcons.users,
                value: '25',
                label: 'Alunos Ativos',
                color: AppColors.primary,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: LucideIcons.dollarSign,
                value: 'R\$ 4.850',
                label: 'Receita Mensal',
                color: AppColors.success,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: LucideIcons.dumbbell,
                value: '48',
                label: 'Treinos Criados',
                color: AppColors.secondary,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: LucideIcons.trendingUp,
                value: '92%',
                label: 'Taxa de Retencao',
                color: AppColors.accent,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    bool isDark,
    String title, {
    String? badge,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.destructive,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
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

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final actions = [
      (LucideIcons.userPlus, 'Convidar\nAluno', AppColors.primary),
      (LucideIcons.dumbbell, 'Criar\nTreino', AppColors.secondary),
      (LucideIcons.utensils, 'Criar\nDieta', AppColors.accent),
      (LucideIcons.messageCircle, 'Enviar\nMensagem', AppColors.success),
    ];

    return Row(
      children: actions.asMap().entries.map((entry) {
        final (icon, label, color) = entry.value;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
            },
            child: Container(
              margin: EdgeInsets.only(
                right: entry.key < actions.length - 1 ? 12 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 20, color: color),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
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

  Widget _buildPendingTasks(BuildContext context, bool isDark, List<Map<String, dynamic>> alerts) {
    // If no alerts, show empty state
    if (alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                LucideIcons.checkCircle,
                size: 32,
                color: AppColors.success,
              ),
              const SizedBox(height: 12),
              Text(
                'Nenhuma tarefa pendente',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: alerts.asMap().entries.map((entry) {
        final index = entry.key;
        final alert = entry.value;
        final type = alert['type'] as String? ?? 'info';
        final title = alert['title'] as String? ?? 'Tarefa';
        final subtitle = alert['subtitle'] as String? ?? '';

        // Map alert type to icon and color
        IconData icon;
        Color color;
        switch (type) {
          case 'warning':
            icon = LucideIcons.alertTriangle;
            color = AppColors.warning;
            break;
          case 'error':
            icon = LucideIcons.alertCircle;
            color = AppColors.destructive;
            break;
          default:
            icon = LucideIcons.info;
            color = AppColors.primary;
        }

        return GestureDetector(
          onTap: () {
            HapticUtils.lightImpact();
            // Navigate based on action
            final action = alert['action'] as String?;
            if (action == 'view_students') {
              context.push(RouteNames.students);
            } else if (action == 'view_workouts') {
              context.push(RouteNames.workouts);
            }
          },
          child: Container(
            margin: EdgeInsets.only(bottom: index < alerts.length - 1 ? 8 : 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
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
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentStudents(BuildContext context, bool isDark, List<TrainerStudent> students) {
    // If no students, show empty state
    if (students.isEmpty) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Nenhum aluno cadastrado',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ),
      );
    }

    // Take only the first 5 students for preview
    final displayStudents = students.take(5).toList();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayStudents.length,
        itemBuilder: (context, index) {
          final student = displayStudents[index];
          final name = student.name;
          final initials = _getInitials(name);
          final isActive = student.isActive;

          return GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              // Navigate to student detail
              context.push('${RouteNames.students}/${student.id}');
            },
            child: Container(
              width: 90,
              margin: EdgeInsets.only(right: index < displayStudents.length - 1 ? 12 : 0),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.mutedDark : AppColors.muted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                        ),
                      ),
                      if (isActive)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              border: Border.all(
                                color: isDark ? AppColors.cardDark : AppColors.card,
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name.split(' ')[0],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Widget _buildTodaySchedule(BuildContext context, bool isDark, List<Map<String, dynamic>> schedule) {
    // If no schedule, show empty state
    if (schedule.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                LucideIcons.calendarOff,
                size: 32,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              const SizedBox(height: 12),
              Text(
                'Nenhum agendamento para hoje',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: schedule.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        // Parse appointment data
        final startTime = item['start_time'] as String? ?? item['time'] as String? ?? '';
        final title = item['title'] as String? ?? item['type'] as String? ?? 'Agendamento';
        final clientName = item['client_name'] as String? ?? item['student_name'] as String? ?? '';
        final type = item['type'] as String? ?? 'default';

        // Format time
        String formattedTime = startTime;
        if (startTime.contains('T')) {
          final dateTime = DateTime.tryParse(startTime);
          if (dateTime != null) {
            formattedTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
          }
        }

        // Map type to color
        Color color;
        switch (type.toLowerCase()) {
          case 'training':
          case 'treino':
            color = AppColors.primary;
            break;
          case 'evaluation':
          case 'avaliacao':
            color = AppColors.secondary;
            break;
          case 'consultation':
          case 'consulta':
            color = AppColors.accent;
            break;
          default:
            color = AppColors.primary;
        }

        return GestureDetector(
          onTap: () {
            HapticUtils.lightImpact();
          },
          child: Container(
            margin: EdgeInsets.only(bottom: index < schedule.length - 1 ? 8 : 0),
            child: Row(
              children: [
                // Time
                SizedBox(
                  width: 50,
                  child: Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ),

                // Indicator
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    if (index < schedule.length - 1)
                      Container(
                        width: 2,
                        height: 50,
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                  ],
                ),

                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        if (clientName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            clientName,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                Icon(
                  LucideIcons.trendingUp,
                  size: 16,
                  color: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
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
        ),
      ),
    );
  }
}
