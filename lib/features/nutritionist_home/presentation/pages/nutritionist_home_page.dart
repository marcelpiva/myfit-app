import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/domain/entities/user_role.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../../../shared/presentation/components/role_bottom_navigation.dart';

/// Nutritionist Dashboard - shows patients, consultations, meal plans, and alerts
class NutritionistHomePage extends ConsumerStatefulWidget {
  const NutritionistHomePage({super.key});

  @override
  ConsumerState<NutritionistHomePage> createState() =>
      _NutritionistHomePageState();
}

class _NutritionistHomePageState extends ConsumerState<NutritionistHomePage>
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

    return Scaffold(
      bottomNavigationBar: const RoleBottomNavigation(
        role: UserRole.nutritionist,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Header with greeting and profile
                    FadeInUp(
                      child: _buildHeader(context, isDark),
                    ),

                    const SizedBox(height: 24),

                    // Stats cards
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: _buildStatsGrid(context, isDark),
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions
                    FadeInUp(
                      delay: const Duration(milliseconds: 150),
                      child: _buildSectionHeader(
                        context,
                        isDark,
                        'Acoes Rapidas',
                        icon: LucideIcons.zap,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: _buildQuickActions(context, isDark),
                    ),

                    const SizedBox(height: 32),

                    // Today's Appointments
                    FadeInUp(
                      delay: const Duration(milliseconds: 250),
                      child: _buildSectionHeader(
                        context,
                        isDark,
                        'Consultas de Hoje',
                        icon: LucideIcons.calendar,
                        badge: '4',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: _buildTodayAppointments(context, isDark),
                    ),

                    const SizedBox(height: 32),

                    // Recent Activity
                    FadeInUp(
                      delay: const Duration(milliseconds: 350),
                      child: _buildSectionHeader(
                        context,
                        isDark,
                        'Atividade Recente',
                        icon: LucideIcons.activity,
                        onSeeAll: () {
                          HapticFeedback.lightImpact();
                          _showAllActivitiesModal(context, isDark);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildRecentActivity(context, isDark),
                    ),

                    const SizedBox(height: 32),

                    // Alerts
                    FadeInUp(
                      delay: const Duration(milliseconds: 450),
                      child: _buildSectionHeader(
                        context,
                        isDark,
                        'Alertas',
                        icon: LucideIcons.alertTriangle,
                        badge: '3',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: _buildAlerts(context, isDark),
                    ),

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

  void _showAllActivitiesModal(BuildContext context, bool isDark) {
    final allActivities = [
      _ActivityItem(
        icon: LucideIcons.utensils,
        message: 'Maria Santos registrou refeicao do almoco',
        time: 'Ha 15 minutos',
        color: AppColors.success,
      ),
      _ActivityItem(
        icon: LucideIcons.scale,
        message: 'Joao Oliveira atualizou peso: 78.5 kg',
        time: 'Ha 1 hora',
        color: AppColors.primary,
      ),
      _ActivityItem(
        icon: LucideIcons.apple,
        message: 'Ana Costa completou diario alimentar',
        time: 'Ha 2 horas',
        color: AppColors.secondary,
      ),
      _ActivityItem(
        icon: LucideIcons.ruler,
        message: 'Carlos Lima registrou medidas corporais',
        time: 'Ha 3 horas',
        color: AppColors.accent,
      ),
      _ActivityItem(
        icon: LucideIcons.utensils,
        message: 'Pedro Silva registrou cafe da manha',
        time: 'Ha 4 horas',
        color: AppColors.success,
      ),
      _ActivityItem(
        icon: LucideIcons.droplet,
        message: 'Maria Santos atualizou consumo de agua',
        time: 'Ha 5 horas',
        color: AppColors.info,
      ),
      _ActivityItem(
        icon: LucideIcons.scale,
        message: 'Ana Costa atualizou peso: 62.3 kg',
        time: 'Ha 6 horas',
        color: AppColors.primary,
      ),
      _ActivityItem(
        icon: LucideIcons.clipboardCheck,
        message: 'Joao Oliveira completou meta semanal',
        time: 'Ontem',
        color: AppColors.warning,
      ),
      _ActivityItem(
        icon: LucideIcons.utensils,
        message: 'Carlos Lima registrou jantar',
        time: 'Ontem',
        color: AppColors.success,
      ),
      _ActivityItem(
        icon: LucideIcons.heartPulse,
        message: 'Pedro Silva registrou atividade fisica',
        time: 'Ontem',
        color: AppColors.destructive,
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.activity,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Historico de Atividades',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.backgroundDark : AppColors.card).withAlpha(150),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: allActivities.length,
                itemBuilder: (context, index) {
                  final activity = allActivities[index];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                      _showActivityDetailsModal(context, isDark, activity);
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: index == allActivities.length - 1 ? 24 : 8,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.cardDark : AppColors.card)
                            .withAlpha(isDark ? 150 : 200),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: activity.color.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              activity.icon,
                              size: 18,
                              color: activity.color,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.message,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.foregroundDark
                                        : AppColors.foreground,
                                  ),
                                ),
                                const SizedBox(height: 4),
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
                          ),
                          Icon(
                            LucideIcons.chevronRight,
                            size: 16,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuickAction(BuildContext context, bool isDark, int index) {
    switch (index) {
      case 0: // Nova Consulta
        _showScheduleConsultationModal(context, isDark);
        break;
      case 1: // Criar Plano
        context.push(RouteNames.dietPlans);
        break;
      case 2: // Enviar Lembrete
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lembrete enviado!'),
            backgroundColor: AppColors.success,
          ),
        );
        break;
    }
  }

  void _showScheduleConsultationModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      isScrollControlled: true,
      builder: (ctx) => _ScheduleConsultationForm(isDark: isDark),
    );
  }

  void _showAppointmentDetailsModal(
    BuildContext context,
    bool isDark,
    _Appointment appointment,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: appointment.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      appointment.patientInitials,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: appointment.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.type,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              context,
              isDark,
              LucideIcons.clock,
              'Horario',
              appointment.time,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              isDark,
              LucideIcons.clipboardList,
              'Tipo',
              appointment.type,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              isDark,
              LucideIcons.fileText,
              'Observacoes',
              'Nenhuma observacao registrada',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Fechar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                      context.push('/patients/${appointment.patientId}/diet-plan?name=${Uri.encodeComponent(appointment.patientName)}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Ver Perfil'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetailsModal(
    BuildContext context,
    bool isDark,
    _ActivityItem activity,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: activity.color.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    activity.icon,
                    size: 24,
                    color: activity.color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalhes da Atividade',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.time,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
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
                color: (isDark ? AppColors.backgroundDark : AppColors.card).withAlpha(150),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Text(
                activity.message,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Fechar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlertDetailsModal(
    BuildContext context,
    bool isDark,
    _AlertItem alert,
    Color alertColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: alertColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    alert.icon,
                    size: 24,
                    color: alertColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: alertColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          alert.severity == _AlertSeverity.high
                              ? 'Alta prioridade'
                              : alert.severity == _AlertSeverity.medium
                                  ? 'Media prioridade'
                                  : 'Baixa prioridade',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: alertColor,
                          ),
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
                color: (isDark ? AppColors.backgroundDark : AppColors.card).withAlpha(150),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Text(
                alert.message,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Fechar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                      _handleAlertAction(context, isDark, alert);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: alertColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(alert.actionLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleAlertAction(BuildContext context, bool isDark, _AlertItem alert) {
    switch (alert.actionLabel) {
      case 'Enviar lembrete':
        _showSendReminderModal(context, isDark, alert);
        break;
      case 'Ver historico':
        _showWeightHistoryModal(context, isDark, alert);
        break;
      case 'Agendar consulta':
        _showScheduleConsultationModal(context, isDark);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Acao: ${alert.actionLabel}', style: const TextStyle(color: Colors.white)),
            backgroundColor: AppColors.success,
          ),
        );
    }
  }

  void _showSendReminderModal(BuildContext context, bool isDark, _AlertItem alert) {
    final messageController = TextEditingController(
      text: 'Ola! Notamos que voce nao registra suas refeicoes ha alguns dias. Lembre-se que acompanhar sua alimentacao e muito importante para alcancar seus objetivos. Estamos aqui para ajudar!',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
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
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.bell,
                    size: 20,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Enviar Lembrete',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.backgroundDark : AppColors.card).withAlpha(150),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    child: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.user, size: 18, color: AppColors.info),
                  const SizedBox(width: 10),
                  Text(
                    'Paciente: Pedro Silva',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mensagem',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: (isDark ? AppColors.backgroundDark : AppColors.card).withAlpha(150),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: TextField(
                controller: messageController,
                maxLines: 4,
                style: TextStyle(
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
                decoration: InputDecoration(
                  hintText: 'Digite sua mensagem...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Lembrete enviado para Pedro Silva!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Enviar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWeightHistoryModal(BuildContext context, bool isDark, _AlertItem alert) {
    final weightHistory = [
      ('14/01', 62.3),
      ('07/01', 63.5),
      ('31/12', 64.8),
      ('24/12', 65.2),
      ('17/12', 66.1),
      ('10/12', 66.3),
    ];

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
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.trendingDown,
                          size: 20,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Historico de Peso',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ana Costa',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.backgroundDark : AppColors.card).withAlpha(150),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Summary Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withAlpha(50)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '-4.0 kg',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ultimas 2 semanas',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    Column(
                      children: [
                        Text(
                          '62.3 kg',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Peso atual',
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
            ),
            const SizedBox(height: 16),
            // Weight list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: weightHistory.length,
                itemBuilder: (context, index) {
                  final (date, weight) = weightHistory[index];
                  final prevWeight = index < weightHistory.length - 1
                      ? weightHistory[index + 1].$2
                      : weight;
                  final diff = weight - prevWeight;
                  final isGain = diff > 0;

                  return Container(
                    margin: EdgeInsets.only(
                      bottom: index == weightHistory.length - 1 ? 24 : 8,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.cardDark : AppColors.card)
                          .withAlpha(isDark ? 150 : 200),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 18,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${weight.toStringAsFixed(1)} kg',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              ),
                            ),
                            if (index < weightHistory.length - 1) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isGain ? AppColors.destructive : AppColors.success).withAlpha(25),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isGain ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                                      size: 12,
                                      color: isGain ? AppColors.destructive : AppColors.success,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      diff.abs().toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isGain ? AppColors.destructive : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    bool isDark,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Profile avatar
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'NC',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bom dia, Dra. Camila',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Nutricionista',
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

        // Switch Profile
        _buildIconButton(
          context,
          isDark,
          LucideIcons.repeat,
          onTap: () => context.go(RouteNames.orgSelector),
        ),
        const SizedBox(width: 8),

        // Notifications
        _buildIconButton(
          context,
          isDark,
          LucideIcons.bell,
          badge: 5,
          onTap: () => context.push(RouteNames.notifications),
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          context,
          isDark,
          LucideIcons.settings,
          onTap: () => context.push(RouteNames.settings),
        ),
      ],
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    bool isDark,
    IconData icon, {
    int? badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
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
                value: '48',
                label: 'Total Pacientes',
                color: AppColors.primary,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/patients');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: LucideIcons.calendar,
                value: '8',
                label: 'Consultas Hoje',
                color: AppColors.secondary,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Show today's schedule - already on this page, scroll or show modal
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Consultas de hoje estao listadas abaixo')),
                  );
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
                icon: LucideIcons.clipboardList,
                value: '35',
                label: 'Planos Ativos',
                color: AppColors.success,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/diet-plans');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: LucideIcons.clipboardCheck,
                value: '12',
                label: 'Avaliacoes Pendentes',
                color: AppColors.warning,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/patients');
                },
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
    IconData? icon,
    String? badge,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
              const SizedBox(width: 8),
            ],
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
      (LucideIcons.calendarPlus, 'Nova\nConsulta', AppColors.primary),
      (LucideIcons.filePlus, 'Criar\nPlano', AppColors.success),
      (LucideIcons.bell, 'Enviar\nLembrete', AppColors.warning),
    ];

    return Row(
      children: actions.asMap().entries.map((entry) {
        final (icon, label, color) = entry.value;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _handleQuickAction(context, isDark, entry.key);
            },
            child: Container(
              margin: EdgeInsets.only(
                right: entry.key < actions.length - 1 ? 12 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.cardDark : AppColors.card)
                    .withAlpha(isDark ? 150 : 200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 22, color: color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
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

  Widget _buildTodayAppointments(BuildContext context, bool isDark) {
    // TODO: Integrate with schedule/appointments API when available
    final appointments = <_Appointment>[];

    if (appointments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
          borderRadius: BorderRadius.circular(12),
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
                'Nenhuma consulta agendada para hoje',
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
      children: appointments.asMap().entries.map((entry) {
        final appointment = entry.value;
        final isLast = entry.key == appointments.length - 1;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showAppointmentDetailsModal(context, isDark, appointment);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
            child: Row(
              children: [
                // Time
                SizedBox(
                  width: 50,
                  child: Text(
                    appointment.time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                ),

                // Indicator
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: appointment.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 60,
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
                      color: (isDark ? AppColors.cardDark : AppColors.card)
                          .withAlpha(isDark ? 150 : 200),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: appointment.color.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              appointment.patientInitials,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: appointment.color,
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
                                appointment.patientName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foreground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                appointment.type,
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
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
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

  Widget _buildRecentActivity(BuildContext context, bool isDark) {
    final activities = [
      _ActivityItem(
        icon: LucideIcons.utensils,
        message: 'Maria Santos registrou refeicao do almoco',
        time: 'Ha 15 minutos',
        color: AppColors.success,
      ),
      _ActivityItem(
        icon: LucideIcons.scale,
        message: 'Joao Oliveira atualizou peso: 78.5 kg',
        time: 'Ha 1 hora',
        color: AppColors.primary,
      ),
      _ActivityItem(
        icon: LucideIcons.apple,
        message: 'Ana Costa completou diario alimentar',
        time: 'Ha 2 horas',
        color: AppColors.secondary,
      ),
      _ActivityItem(
        icon: LucideIcons.ruler,
        message: 'Carlos Lima registrou medidas corporais',
        time: 'Ha 3 horas',
        color: AppColors.accent,
      ),
    ];

    return Column(
      children: activities.asMap().entries.map((entry) {
        final activity = entry.value;
        final isLast = entry.key == activities.length - 1;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showActivityDetailsModal(context, isDark, activity);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.cardDark : AppColors.card)
                  .withAlpha(isDark ? 150 : 200),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: activity.color.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    activity.icon,
                    size: 18,
                    color: activity.color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAlerts(BuildContext context, bool isDark) {
    final alerts = [
      _AlertItem(
        icon: LucideIcons.alertCircle,
        title: 'Refeicoes nao registradas',
        message: 'Pedro Silva nao registra refeicoes ha 3 dias',
        severity: _AlertSeverity.high,
        actionLabel: 'Enviar lembrete',
      ),
      _AlertItem(
        icon: LucideIcons.trendingDown,
        title: 'Perda de peso significativa',
        message: 'Ana Costa perdeu 4kg nas ultimas 2 semanas',
        severity: _AlertSeverity.medium,
        actionLabel: 'Ver historico',
      ),
      _AlertItem(
        icon: LucideIcons.calendar,
        title: 'Consulta de retorno pendente',
        message: 'Marcos Alves esta ha 45 dias sem retorno',
        severity: _AlertSeverity.low,
        actionLabel: 'Agendar consulta',
      ),
    ];

    return Column(
      children: alerts.asMap().entries.map((entry) {
        final alert = entry.value;
        final isLast = entry.key == alerts.length - 1;

        Color alertColor;
        switch (alert.severity) {
          case _AlertSeverity.high:
            alertColor = AppColors.destructive;
            break;
          case _AlertSeverity.medium:
            alertColor = AppColors.warning;
            break;
          case _AlertSeverity.low:
            alertColor = AppColors.info;
            break;
        }

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showAlertDetailsModal(context, isDark, alert, alertColor);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.cardDark : AppColors.card)
                  .withAlpha(isDark ? 150 : 200),
              border: Border.all(
                color: alertColor.withAlpha(100),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: alertColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    alert.icon,
                    size: 20,
                    color: alertColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.message,
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
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Stat card widget
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
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
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

// Data models
class _Appointment {
  final String patientId;
  final String time;
  final String patientName;
  final String patientInitials;
  final String type;
  final Color color;

  const _Appointment({
    required this.patientId,
    required this.time,
    required this.patientName,
    required this.patientInitials,
    required this.type,
    required this.color,
  });
}

class _ActivityItem {
  final IconData icon;
  final String message;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.message,
    required this.time,
    required this.color,
  });
}

enum _AlertSeverity { high, medium, low }

class _AlertItem {
  final IconData icon;
  final String title;
  final String message;
  final _AlertSeverity severity;
  final String actionLabel;

  const _AlertItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.severity,
    required this.actionLabel,
  });
}

// Schedule Consultation Form Widget
class _ScheduleConsultationForm extends StatefulWidget {
  final bool isDark;

  const _ScheduleConsultationForm({required this.isDark});

  @override
  State<_ScheduleConsultationForm> createState() => _ScheduleConsultationFormState();
}

class _ScheduleConsultationFormState extends State<_ScheduleConsultationForm> {
  String? _selectedPatient;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _observationsController = TextEditingController();
  String _selectedType = 'Consulta de Rotina';

  // TODO: Integrate with patients API when available
  final _patients = <(String, String)>[];

  final _consultationTypes = [
    'Consulta de Rotina',
    'Primeira Consulta',
    'Retorno',
    'Avaliacao Nutricional',
    'Acompanhamento Mensal',
    'Reeducacao Alimentar',
  ];

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _confirmSchedule() {
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione um paciente'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final patientName = _patients.firstWhere((p) => p.$1 == _selectedPatient).$2;
    final formattedDate = '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
    final formattedTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Consulta agendada: $patientName em $formattedDate as $formattedTime', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.calendarPlus,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Nova Consulta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.backgroundDark : AppColors.card).withAlpha(150),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    child: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Patient Selector
            _buildLabel('Paciente', isDark),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.backgroundDark : AppColors.card).withAlpha(150),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPatient,
                  hint: Text(
                    'Selecione um paciente',
                    style: TextStyle(
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                  isExpanded: true,
                  dropdownColor: isDark ? AppColors.cardDark : AppColors.card,
                  items: _patients.map((patient) {
                    return DropdownMenuItem<String>(
                      value: patient.$1,
                      child: Text(
                        patient.$2,
                        style: TextStyle(
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedPatient = value),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Consultation Type
            _buildLabel('Tipo de Consulta', isDark),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.backgroundDark : AppColors.card).withAlpha(150),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  dropdownColor: isDark ? AppColors.cardDark : AppColors.card,
                  items: _consultationTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedType = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date and Time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Data', isDark),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.backgroundDark : AppColors.card).withAlpha(150),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 18,
                                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                                style: TextStyle(
                                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Horario', isDark),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.backgroundDark : AppColors.card).withAlpha(150),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.clock,
                                size: 18,
                                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Observations
            _buildLabel('Observacoes (opcional)', isDark),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: (isDark ? AppColors.backgroundDark : AppColors.card).withAlpha(150),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: TextField(
                controller: _observationsController,
                maxLines: 3,
                style: TextStyle(
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
                decoration: InputDecoration(
                  hintText: 'Adicione observacoes sobre a consulta...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _confirmSchedule();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Agendar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
      ),
    );
  }
}
