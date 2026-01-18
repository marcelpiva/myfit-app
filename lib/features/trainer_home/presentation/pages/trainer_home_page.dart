import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/domain/entities/user_role.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../core/services/trainer_service.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../../../shared/presentation/components/role_bottom_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../trainer_workout/presentation/widgets/invite_student_sheet.dart' show showInviteStudentSheet;
import '../providers/trainer_home_provider.dart';
import '../widgets/students_now_section.dart';

/// Trainer/Coach Dashboard Home Page
/// Shows overview of students, workouts, revenue, and alerts
class TrainerHomePage extends ConsumerStatefulWidget {
  const TrainerHomePage({super.key});

  @override
  ConsumerState<TrainerHomePage> createState() => _TrainerHomePageState();
}

class _TrainerHomePageState extends ConsumerState<TrainerHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    // Load dashboard data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orgId = ref.read(activeContextProvider)?.membership.organization.id;
      if (orgId != null) {
        ref.read(trainerDashboardNotifierProvider(orgId).notifier).loadDashboard();
      }
    });
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
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // Get org context and dashboard state
    final activeContext = ref.watch(activeContextProvider);
    final currentUser = ref.watch(currentUserProvider);
    final orgId = activeContext?.membership.organization.id;
    final dashboardState = orgId != null
        ? ref.watch(trainerDashboardNotifierProvider(orgId))
        : const TrainerDashboardState();

    // Build schedule, activities, and alerts from provider data
    final schedule = _buildScheduleFromData(dashboardState.todaySchedule);
    final activities = _buildActivitiesFromData(dashboardState.recentActivities);
    final alerts = _buildAlertsFromData(dashboardState.alerts);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      bottomNavigationBar: const RoleBottomNavigation(
        role: UserRole.trainer,
        currentIndex: 0,
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header with greeting and profile avatar
                  FadeInUp(
                    child: _HeaderSection(
                      isDark: isDark,
                      userName: currentUser?.name ?? 'Trainer',
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Stats Cards
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _StatsSection(
                      isDark: isDark,
                      currencyFormat: currencyFormat,
                      totalStudents: dashboardState.totalStudents,
                      activeWorkouts: dashboardState.pendingWorkouts,
                      todayCheckins: dashboardState.todaySessions,
                      isLoading: dashboardState.isLoading,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2.5. Students Now (Co-training)
                  FadeInUp(
                    delay: const Duration(milliseconds: 150),
                    child: _SectionHeader(
                      title: 'Alunos Agora',
                      icon: LucideIcons.radio,
                      isDark: isDark,
                      badge: null,
                    ),
                  ),

                  const SizedBox(height: 12),

                  FadeInUp(
                    delay: const Duration(milliseconds: 175),
                    child: StudentsNowSection(
                      isDark: isDark,
                      organizationId: orgId,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Quick Actions
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _SectionHeader(
                      title: 'Acoes Rapidas',
                      icon: LucideIcons.zap,
                      isDark: isDark,
                    ),
                  ),

                  const SizedBox(height: 12),

                  FadeInUp(
                    delay: const Duration(milliseconds: 250),
                    child: _QuickActionsSection(
                      isDark: isDark,
                      onConvidarAluno: () {
                        debugPrint('🟢 onConvidarAluno callback triggered!');
                        HapticUtils.lightImpact();
                        showInviteStudentSheet(
                          context,
                          ref: ref,
                          isDark: isDark,
                        );
                      },
                      onNovoProgramy: () {
                        HapticUtils.lightImpact();
                        context.push(RouteNames.programWizard);
                      },
                      onVerCatalogo: () {
                        HapticUtils.lightImpact();
                        context.push(RouteNames.marketplace);
                      },
                      onAgendarSessao: () {
                        HapticUtils.lightImpact();
                        _showScheduleSessionSheet(context, isDark);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. Today's Schedule
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _SectionHeader(
                      title: 'Agenda de Hoje',
                      icon: LucideIcons.calendar,
                      isDark: isDark,
                      trailing: TextButton(
                        onPressed: () {
                          HapticUtils.lightImpact();
                          context.push(RouteNames.schedule);
                        },
                        child: Text(
                          'Ver Completa',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (schedule.isEmpty && !dashboardState.isLoading)
                    FadeInUp(
                      delay: const Duration(milliseconds: 350),
                      child: _EmptyStateCard(
                        message: 'Nenhuma sessao agendada para hoje',
                        icon: LucideIcons.calendar,
                        isDark: isDark,
                      ),
                    )
                  else
                    ...schedule.asMap().entries.map((entry) {
                      return FadeInUp(
                        delay: Duration(milliseconds: 350 + (entry.key * 50)),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ScheduleCard(
                            session: entry.value,
                            isDark: isDark,
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 24),

                  // 5. Recent Activity
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: _SectionHeader(
                      title: 'Atividade Recente',
                      icon: LucideIcons.activity,
                      isDark: isDark,
                      trailing: TextButton(
                        onPressed: () {
                          HapticUtils.lightImpact();
                          _showAllActivitiesModal(context, isDark, activities);
                        },
                        child: Text(
                          'Ver Todas',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (activities.isEmpty && !dashboardState.isLoading)
                    FadeInUp(
                      delay: const Duration(milliseconds: 550),
                      child: _EmptyStateCard(
                        message: 'Nenhuma atividade recente',
                        icon: LucideIcons.activity,
                        isDark: isDark,
                      ),
                    )
                  else
                    ...activities.asMap().entries.map((entry) {
                      return FadeInUp(
                        delay: Duration(milliseconds: 550 + (entry.key * 50)),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ActivityTile(
                            activity: entry.value,
                            isDark: isDark,
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 24),

                  // 6. Alerts
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: _SectionHeader(
                      title: 'Alertas',
                      icon: LucideIcons.alertTriangle,
                      isDark: isDark,
                      badge: alerts.isNotEmpty ? '${alerts.length}' : null,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (alerts.isEmpty && !dashboardState.isLoading)
                    FadeInUp(
                      delay: const Duration(milliseconds: 750),
                      child: _EmptyStateCard(
                        message: 'Nenhum alerta no momento',
                        icon: LucideIcons.checkCircle,
                        isDark: isDark,
                        color: AppColors.success,
                      ),
                    )
                  else
                    ...alerts.asMap().entries.map((entry) {
                      return FadeInUp(
                        delay: Duration(milliseconds: 750 + (entry.key * 50)),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _AlertCard(
                            alert: entry.value,
                            isDark: isDark,
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showScheduleSessionSheet(BuildContext context, bool isDark) {
    Map<String, dynamic>? selectedStudent;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    List<Map<String, dynamic>> students = [];
    bool isLoading = true;
    String? error;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          // Load students on first build
          if (isLoading && students.isEmpty && error == null) {
            TrainerService().getStudents(status: 'active').then((result) {
              setModalState(() {
                students = result;
                isLoading = false;
              });
            }).catchError((e) {
              setModalState(() {
                error = e.toString();
                isLoading = false;
              });
            });
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Agendar Sessao',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 16),

                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (error != null)
                  Center(
                    child: Text(
                      'Erro ao carregar alunos: $error',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                else if (students.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Voce ainda nao tem alunos. Convide alunos primeiro.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  )
                else ...[
                  // Student selector
                  Text(
                    'Aluno',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.mutedDark.withAlpha(100) : AppColors.muted.withAlpha(100),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, dynamic>>(
                        value: selectedStudent,
                        hint: const Text('Selecione um aluno'),
                        isExpanded: true,
                        items: students.map<DropdownMenuItem<Map<String, dynamic>>>((student) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: student,
                            child: Text(student['name'] as String? ?? 'Aluno'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() => selectedStudent = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date picker
                  Text(
                    'Data',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setModalState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mutedDark.withAlpha(100) : AppColors.muted.withAlpha(100),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            size: 18,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd/MM/yyyy').format(selectedDate),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time picker
                  Text(
                    'Horario',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setModalState(() => selectedTime = time);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mutedDark.withAlpha(100) : AppColors.muted.withAlpha(100),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 18,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            selectedTime.format(context),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Schedule button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: selectedStudent == null
                          ? null
                          : () {
                              // TODO: Integrate with schedule service to create the session
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Sessao agendada com ${selectedStudent!['name']} para ${DateFormat('dd/MM').format(selectedDate)} as ${selectedTime.format(context)}',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                      icon: const Icon(LucideIcons.calendarPlus, size: 18),
                      label: const Text('Agendar Sessao'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// Header Section Widget
class _HeaderSection extends StatelessWidget {
  final bool isDark;
  final String userName;

  const _HeaderSection({required this.isDark, required this.userName});

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Bom dia';
    } else if (hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }

    return Row(
      children: [
        // Profile Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? AppColors.primaryDark : AppColors.primary,
                isDark ? AppColors.secondaryDark : AppColors.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(isDark ? 40 : 60),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _getInitials(userName),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
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
                '$greeting,',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ],
          ),
        ),

        // Switch Profile Button
        GestureDetector(
          onTap: () {
            HapticUtils.lightImpact();
            context.go(RouteNames.orgSelector);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.cardDark : AppColors.card)
                  .withAlpha(isDark ? 150 : 200),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.repeat,
              size: 20,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Notification Bell
        GestureDetector(
          onTap: () {
            HapticUtils.lightImpact();
            context.push(RouteNames.notifications);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.cardDark : AppColors.card)
                  .withAlpha(isDark ? 150 : 200),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(8),
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
      ],
    );
  }
}

// Stats Section Widget
class _StatsSection extends StatelessWidget {
  final bool isDark;
  final NumberFormat currencyFormat;
  final int totalStudents;
  final int activeWorkouts;
  final int todayCheckins;
  final bool isLoading;

  const _StatsSection({
    required this.isDark,
    required this.currencyFormat,
    this.totalStudents = 0,
    this.activeWorkouts = 0,
    this.todayCheckins = 0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: LucideIcons.users,
                value: isLoading ? '-' : '$totalStudents',
                label: 'Total Alunos',
                color: AppColors.primary,
                isDark: isDark,
                onTap: () {
                  HapticUtils.lightImpact();
                  context.push('/students');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: LucideIcons.dumbbell,
                value: isLoading ? '-' : '$activeWorkouts',
                label: 'Treinos Ativos',
                color: AppColors.secondary,
                isDark: isDark,
                onTap: () {
                  HapticUtils.lightImpact();
                  context.push(RouteNames.programWizard);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: LucideIcons.checkCircle,
                value: isLoading ? '-' : '$todayCheckins',
                label: 'Check-ins Hoje',
                color: AppColors.success,
                isDark: isDark,
                onTap: () {
                  HapticUtils.lightImpact();
                  context.push('/checkin/history');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: LucideIcons.dollarSign,
                value: currencyFormat.format(0),
                label: 'Receita Mes',
                color: AppColors.accent,
                isDark: isDark,
                onTap: () {
                  HapticUtils.lightImpact();
                  context.push('/billing');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        HapticUtils.lightImpact();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card)
              .withAlpha(isDark ? 150 : 200),
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
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

// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final Widget? trailing;
  final String? badge;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isDark,
    this.trailing,
    this.badge,
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
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
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
                    badge!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// Quick Actions Section Widget
class _QuickActionsSection extends StatelessWidget {
  final bool isDark;
  final VoidCallback onConvidarAluno;
  final VoidCallback onNovoProgramy;
  final VoidCallback onVerCatalogo;
  final VoidCallback onAgendarSessao;

  const _QuickActionsSection({
    required this.isDark,
    required this.onConvidarAluno,
    required this.onNovoProgramy,
    required this.onVerCatalogo,
    required this.onAgendarSessao,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: LucideIcons.userPlus,
            label: 'Convidar',
            color: isDark ? AppColors.primaryDark : AppColors.primary,
            isDark: isDark,
            onTap: onConvidarAluno,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionButton(
            icon: LucideIcons.filePlus,
            label: 'Programa',
            color: isDark ? AppColors.secondaryDark : AppColors.secondary,
            isDark: isDark,
            onTap: onNovoProgramy,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionButton(
            icon: LucideIcons.layoutTemplate,
            label: 'Catálogo',
            color: AppColors.success,
            isDark: isDark,
            onTap: onVerCatalogo,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionButton(
            icon: LucideIcons.calendarPlus,
            label: 'Agendar',
            color: isDark ? AppColors.accentDark : AppColors.accent,
            isDark: isDark,
            onTap: onAgendarSessao,
          ),
        ),
      ],
    );
  }
}

// Quick Action Button Widget
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
        color: (isDark ? AppColors.cardDark : AppColors.card)
            .withAlpha(isDark ? 150 : 200),
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
                    color: color.withAlpha(25),
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

// Schedule Card Widget
class _ScheduleCard extends StatelessWidget {
  final _ScheduleSession session;
  final bool isDark;

  const _ScheduleCard({
    required this.session,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        _showSessionDetailsModal(context, session, isDark);
      },
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card)
              .withAlpha(isDark ? 150 : 200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Time badge
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: session.color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    session.time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: session.color,
                    ),
                  ),
                  Text(
                    session.duration,
                    style: TextStyle(
                      fontSize: 10,
                      color: session.color.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Session info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.studentName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        session.typeIcon,
                        size: 12,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        session.type,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: session.isConfirmed
                    ? AppColors.success.withAlpha(25)
                    : AppColors.warning.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    session.isConfirmed ? LucideIcons.check : LucideIcons.clock,
                    size: 12,
                    color: session.isConfirmed ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    session.isConfirmed ? 'Confirmado' : 'Pendente',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: session.isConfirmed ? AppColors.success : AppColors.warning,
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

// Activity Tile Widget
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
        HapticUtils.lightImpact();
        _showActivityDetailsModal(context, activity, isDark);
      },
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card)
              .withAlpha(isDark ? 150 : 200),
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
                color: activity.color.withAlpha(25),
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
                    activity.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activity.subtitle,
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
            Text(
              activity.time,
              style: TextStyle(
                fontSize: 11,
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

// Alert Card Widget
class _AlertCard extends StatelessWidget {
  final _Alert alert;
  final bool isDark;

  const _AlertCard({
    required this.alert,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        _showAlertDetailsModal(context, alert, isDark);
      },
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card)
              .withAlpha(isDark ? 150 : 200),
          border: Border.all(
            color: alert.severity == _AlertSeverity.high
                ? AppColors.destructive.withAlpha(100)
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: alert.color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(alert.icon, size: 20, color: alert.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (alert.severity == _AlertSeverity.high) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.destructive,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'URGENTE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          alert.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.description,
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
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
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
  final Color? color;

  const _EmptyStateCard({
    required this.message,
    required this.icon,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.mutedForeground;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card)
            .withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: cardColor.withAlpha(150)),
          const SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

// Data conversion helper functions

/// Converts provider schedule data to UI model
List<_ScheduleSession> _buildScheduleFromData(List<Map<String, dynamic>> data) {
  return data.map((item) {
    final type = item['type'] as String? ?? 'Treino';
    return _ScheduleSession(
      time: item['time'] as String? ?? '--:--',
      duration: item['duration'] as String? ?? '1h',
      studentName: item['student_name'] as String? ?? 'Aluno',
      type: type,
      typeIcon: _getTypeIcon(type),
      color: _getTypeColor(type),
      isConfirmed: item['is_confirmed'] as bool? ?? false,
    );
  }).toList();
}

/// Converts provider activities data to UI model
List<_Activity> _buildActivitiesFromData(List<Map<String, dynamic>> data) {
  return data.map((item) {
    final type = item['type'] as String? ?? 'checkin';
    return _Activity(
      title: item['title'] as String? ?? '',
      subtitle: item['subtitle'] as String? ?? '',
      time: item['time'] as String? ?? '',
      icon: _getActivityIcon(type),
      color: _getActivityColor(type),
    );
  }).toList();
}

/// Converts provider alerts data to UI model
List<_Alert> _buildAlertsFromData(List<Map<String, dynamic>> data) {
  return data.map((item) {
    final type = item['type'] as String? ?? 'info';
    return _Alert(
      title: item['title'] as String? ?? '',
      description: item['subtitle'] as String? ?? '',
      icon: _getAlertIcon(type),
      color: _getAlertColor(type),
      severity: _getAlertSeverity(type),
    );
  }).toList();
}

IconData _getTypeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'avaliacao':
    case 'avaliacao fisica':
      return LucideIcons.clipboardList;
    case 'consulta online':
    case 'online':
      return LucideIcons.video;
    default:
      return LucideIcons.dumbbell;
  }
}

Color _getTypeColor(String type) {
  switch (type.toLowerCase()) {
    case 'avaliacao':
    case 'avaliacao fisica':
      return AppColors.secondary;
    case 'consulta online':
    case 'online':
      return AppColors.accent;
    default:
      return AppColors.primary;
  }
}

IconData _getActivityIcon(String type) {
  switch (type.toLowerCase()) {
    case 'checkin':
      return LucideIcons.checkCircle;
    case 'workout':
      return LucideIcons.dumbbell;
    case 'measurement':
      return LucideIcons.trendingDown;
    case 'new_student':
      return LucideIcons.userPlus;
    default:
      return LucideIcons.activity;
  }
}

Color _getActivityColor(String type) {
  switch (type.toLowerCase()) {
    case 'checkin':
      return AppColors.success;
    case 'workout':
      return AppColors.primary;
    case 'measurement':
      return AppColors.info;
    case 'new_student':
      return AppColors.accent;
    default:
      return AppColors.secondary;
  }
}

IconData _getAlertIcon(String type) {
  switch (type.toLowerCase()) {
    case 'warning':
      return LucideIcons.userX;
    case 'error':
      return LucideIcons.alertCircle;
    case 'payment':
      return LucideIcons.creditCard;
    default:
      return LucideIcons.info;
  }
}

Color _getAlertColor(String type) {
  switch (type.toLowerCase()) {
    case 'warning':
      return AppColors.destructive;
    case 'error':
      return AppColors.destructive;
    case 'payment':
      return AppColors.warning;
    default:
      return AppColors.info;
  }
}

_AlertSeverity _getAlertSeverity(String type) {
  switch (type.toLowerCase()) {
    case 'warning':
    case 'error':
      return _AlertSeverity.high;
    case 'payment':
      return _AlertSeverity.medium;
    default:
      return _AlertSeverity.low;
  }
}

// Modal Helper Functions

/// Shows a modal with all activities
void _showAllActivitiesModal(BuildContext context, bool isDark, List<_Activity> activities) {
  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  LucideIcons.activity,
                  size: 20,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Todas as Atividades',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: activities.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma atividade registrada',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ActivityTile(activity: activity, isDark: isDark),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Shows session details in a modal bottom sheet
void _showSessionDetailsModal(
  BuildContext context,
  _ScheduleSession session,
  bool isDark,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: session.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(session.typeIcon, color: session.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.studentName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    Text(
                      session.type,
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
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow(
            icon: LucideIcons.clock,
            label: 'Horario',
            value: '${session.time} (${session.duration})',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: LucideIcons.checkCircle,
            label: 'Status',
            value: session.isConfirmed ? 'Confirmado' : 'Pendente',
            isDark: isDark,
            valueColor: session.isConfirmed ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(LucideIcons.messageCircle),
                  label: const Text('Mensagem'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(LucideIcons.play),
                  label: const Text('Iniciar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Shows activity details in a modal bottom sheet
void _showActivityDetailsModal(
  BuildContext context,
  _Activity activity,
  bool isDark,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: activity.color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(activity.icon, color: activity.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    Text(
                      activity.time,
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
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.backgroundDark : AppColors.card)
                  .withAlpha(isDark ? 100 : 150),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Text(
              activity.subtitle,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                HapticUtils.lightImpact();
                Navigator.pop(ctx);
              },
              icon: const Icon(LucideIcons.externalLink),
              label: const Text('Ver Detalhes'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Shows alert details in a modal bottom sheet with action button
void _showAlertDetailsModal(
  BuildContext context,
  _Alert alert,
  bool isDark,
) {
  String actionLabel;
  IconData actionIcon;

  switch (alert.severity) {
    case _AlertSeverity.high:
      actionLabel = 'Resolver Agora';
      actionIcon = LucideIcons.alertCircle;
      break;
    case _AlertSeverity.medium:
      actionLabel = 'Ver Detalhes';
      actionIcon = LucideIcons.eye;
      break;
    case _AlertSeverity.low:
      actionLabel = 'Tomar Acao';
      actionIcon = LucideIcons.arrowRight;
      break;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: alert.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(alert.icon, color: alert.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (alert.severity == _AlertSeverity.high) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.destructive,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'URGENTE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            alert.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: alert.color.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: alert.color.withAlpha(50),
              ),
            ),
            child: Text(
              alert.description,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(LucideIcons.x),
                  label: const Text('Dispensar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(ctx);
                  },
                  icon: Icon(actionIcon),
                  label: Text(actionLabel),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Helper widget for detail rows in modals
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
        const Spacer(),
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
}

// Mock Data Classes
class _ScheduleSession {
  final String time;
  final String duration;
  final String studentName;
  final String type;
  final IconData typeIcon;
  final Color color;
  final bool isConfirmed;

  const _ScheduleSession({
    required this.time,
    required this.duration,
    required this.studentName,
    required this.type,
    required this.typeIcon,
    required this.color,
    required this.isConfirmed,
  });
}

class _Activity {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  const _Activity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });
}

enum _AlertSeverity { low, medium, high }

class _Alert {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final _AlertSeverity severity;

  const _Alert({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.severity,
  });
}

