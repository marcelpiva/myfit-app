import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../providers/patient_diet_plan_provider.dart';

/// Patient Diet Plan Page for Nutritionists
/// Allows viewing and managing a specific patient's diet plan
class PatientDietPlanPage extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;

  const PatientDietPlanPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  ConsumerState<PatientDietPlanPage> createState() =>
      _PatientDietPlanPageState();
}

class _PatientDietPlanPageState extends ConsumerState<PatientDietPlanPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _selectedTab = 0;

  final _tabs = ['Plano Atual', 'Histórico', 'Notas'];

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

    // Load patient diet plan data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(patientDietPlanNotifierProvider(widget.patientId).notifier).loadAll();
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
    final dietPlanState = ref.watch(patientDietPlanNotifierProvider(widget.patientId));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? AppColors.primaryDark : AppColors.primary)
                  .withAlpha(isDark ? 15 : 10),
              (isDark ? AppColors.secondaryDark : AppColors.secondary)
                  .withAlpha(isDark ? 12 : 8),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button
                  _buildHeader(context, isDark),

                  // Patient summary card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _PatientSummaryCard(
                      isDark: isDark,
                      patientName: widget.patientName,
                      summary: dietPlanState.summary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildTabs(isDark),
                  ),

                  const SizedBox(height: 24),

                  // Content based on selected tab
                  if (_selectedTab == 0) ...[
                    _CurrentPlanTab(
                      isDark: isDark,
                      targets: dietPlanState.targets,
                      meals: dietPlanState.meals,
                      isLoading: dietPlanState.isLoading,
                    ),
                  ] else if (_selectedTab == 1) ...[
                    _HistoryTab(
                      isDark: isDark,
                      previousPlans: dietPlanState.previousPlans,
                    ),
                  ] else ...[
                    _NotesTab(
                      isDark: isDark,
                      patientId: widget.patientId,
                      notes: dietPlanState.notes,
                      onAddNote: (content, category) async {
                        return ref
                            .read(patientDietPlanNotifierProvider(widget.patientId).notifier)
                            .addNote(content, category: category);
                      },
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              context.pop();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plano Alimentar',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Text(
                  widget.patientName,
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
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              _showActionsMenu(context, isDark);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Icon(
                LucideIcons.moreVertical,
                size: 20,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    return Container(
      height: 44,
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
        children: _tabs.asMap().entries.map((entry) {
          final isSelected = entry.key == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticUtils.selectionClick();
                setState(() => _selectedTab = entry.key);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? (isDark
                              ? AppColors.backgroundDark
                              : AppColors.background)
                          : (isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showActionsMenu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Row(
                children: [
                  Icon(
                    LucideIcons.settings2,
                    size: 24,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Opções do Plano',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Actions
              _buildActionItem(
                ctx,
                isDark,
                icon: LucideIcons.pencil,
                title: 'Editar Plano',
                subtitle: 'Modificar refeições e metas',
                color: AppColors.primary,
                onTap: () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  context.push('/nutrition/builder?planId=1&studentId=${widget.patientId}');
                },
              ),
              const SizedBox(height: 12),
              _buildActionItem(
                ctx,
                isDark,
                icon: LucideIcons.copy,
                title: 'Copiar Plano',
                subtitle: 'Criar cópia como template',
                color: AppColors.secondary,
                onTap: () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Plano copiado como template!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildActionItem(
                ctx,
                isDark,
                icon: LucideIcons.send,
                title: 'Enviar para Paciente',
                subtitle: 'Notificar paciente sobre o plano',
                color: AppColors.info,
                onTap: () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  _showSendConfirmationDialog(context, isDark);
                },
              ),
              const SizedBox(height: 12),
              _buildActionItem(
                ctx,
                isDark,
                icon: LucideIcons.fileDown,
                title: 'Exportar PDF',
                subtitle: 'Gerar documento para impressao',
                color: AppColors.accent,
                onTap: () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  _showExportingDialog(context, isDark);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext ctx,
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: color),
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

  void _showExportingDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gerando PDF...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aguarde um momento',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
    // Simulate PDF generation
    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF gerado com sucesso!'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'Abrir',
            textColor: Colors.white,
            onPressed: () {
              // Simulate opening PDF - in production would use url_launcher or open_file
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Abrindo PDF...'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  void _showSendConfirmationDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(LucideIcons.send, size: 24, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              'Enviar Plano',
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
        content: Text(
          'Deseja enviar uma notificação para ${widget.patientName} sobre o plano alimentar atualizado?',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticUtils.mediumImpact();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Plano enviado para o paciente!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PATIENT SUMMARY CARD
// =============================================================================

class _PatientSummaryCard extends StatelessWidget {
  final bool isDark;
  final String patientName;
  final PatientPlanSummary? summary;

  const _PatientSummaryCard({
    required this.isDark,
    required this.patientName,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                patientName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildMiniStat(
                      isDark,
                      'Início',
                      summary?.formattedStartDate ?? '-',
                    ),
                    const SizedBox(width: 16),
                    _buildMiniStat(
                      isDark,
                      'Duração',
                      summary?.formattedDuration ?? '-',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Adherence indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getAdherenceColor(summary?.adherence ?? 0).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  '${(summary?.adherence ?? 0).toInt()}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _getAdherenceColor(summary?.adherence ?? 0),
                  ),
                ),
                Text(
                  'Aderência',
                  style: TextStyle(
                    fontSize: 10,
                    color: _getAdherenceColor(summary?.adherence ?? 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(bool isDark, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
      ],
    );
  }

  Color _getAdherenceColor(double adherence) {
    if (adherence >= 80) return AppColors.success;
    if (adherence >= 60) return AppColors.primary;
    if (adherence >= 40) return AppColors.warning;
    return AppColors.destructive;
  }
}

// =============================================================================
// CURRENT PLAN TAB
// =============================================================================

class _CurrentPlanTab extends StatelessWidget {
  final bool isDark;
  final DailyTargets targets;
  final List<PlanMeal> meals;
  final bool isLoading;

  const _CurrentPlanTab({
    required this.isDark,
    required this.targets,
    required this.meals,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily targets
          _buildDailyTargets(isDark),
          const SizedBox(height: 20),
          // Meals list
          Text(
            'Refeições do Dia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (meals.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Nenhuma refeição cadastrada',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            ...meals.map((meal) => _buildMealCard(isDark, meal)),
        ],
      ),
    );
  }

  Widget _buildDailyTargets(bool isDark) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metas Diarias',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.flame,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${targets.calories} kcal',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Macros row
          Row(
            children: [
              Expanded(
                child: _buildMacroTarget(
                  isDark,
                  'Proteínas',
                  '${targets.protein}g',
                  AppColors.success,
                  LucideIcons.drumstick,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroTarget(
                  isDark,
                  'Carboidratos',
                  '${targets.carbs}g',
                  AppColors.primary,
                  LucideIcons.wheat,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroTarget(
                  isDark,
                  'Gorduras',
                  '${targets.fat}g',
                  AppColors.warning,
                  LucideIcons.droplet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroTarget(
    bool isDark,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(bool isDark, PlanMeal meal) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: meal.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(meal.icon, size: 20, color: meal.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    Text(
                      meal.time,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: meal.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${meal.calories} kcal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: meal.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Divider
          Container(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          const SizedBox(height: 12),
          // Foods list
          ...meal.foods.map((food) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: meal.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        food.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                    Text(
                      food.portion,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${food.calories} kcal',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// =============================================================================
// HISTORY TAB
// =============================================================================

class _HistoryTab extends StatelessWidget {
  final bool isDark;
  final List<PreviousPlan> previousPlans;

  const _HistoryTab({
    required this.isDark,
    required this.previousPlans,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Container(
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
                Icon(LucideIcons.history, size: 24, color: AppColors.secondary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Histórico de Planos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      Text(
                        '${previousPlans.length} planos anteriores',
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
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Previous plans list
          Text(
            'Planos Anteriores',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          if (previousPlans.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Nenhum plano anterior',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            ...previousPlans.map((plan) => _buildPreviousPlanCard(isDark, plan)),
        ],
      ),
    );
  }

  Widget _buildPreviousPlanCard(bool isDark, PreviousPlan plan) {
    return GestureDetector(
      onTap: () => HapticUtils.selectionClick(),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.clipboardList,
                size: 20,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 12,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        plan.period,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        LucideIcons.flame,
                        size: 12,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${plan.calories} kcal',
                        style: TextStyle(
                          fontSize: 12,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getAdherenceColor(plan.adherence).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${plan.adherence}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _getAdherenceColor(plan.adherence),
                ),
              ),
            ),
            const SizedBox(width: 8),
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
  }

  Color _getAdherenceColor(int adherence) {
    if (adherence >= 80) return AppColors.success;
    if (adherence >= 60) return AppColors.primary;
    if (adherence >= 40) return AppColors.warning;
    return AppColors.destructive;
  }
}

// =============================================================================
// NOTES TAB
// =============================================================================

class _NotesTab extends StatelessWidget {
  final bool isDark;
  final String patientId;
  final List<PatientNote> notes;
  final Future<bool> Function(String content, String? category)? onAddNote;

  const _NotesTab({
    required this.isDark,
    required this.patientId,
    required this.notes,
    this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minhas Notas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  _showAddNoteDialog(context, isDark);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Adicionar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Notes list
          if (notes.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Nenhuma nota adicionada',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            ...notes.map((note) => _buildNoteCard(isDark, note)),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, bool isDark) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(LucideIcons.fileText, size: 24, color: AppColors.secondary),
            const SizedBox(width: 12),
            Text(
              'Adicionar Nota',
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: textController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Observação',
            hintText: 'Adicione uma nota sobre o plano do paciente...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticUtils.mediumImpact();
              if (textController.text.isEmpty) return;

              Navigator.pop(ctx);
              final success = await onAddNote?.call(textController.text, null);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success == true
                      ? 'Nota adicionada!'
                      : 'Erro ao adicionar nota'),
                  backgroundColor:
                      success == true ? AppColors.success : AppColors.destructive,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(bool isDark, PatientNote note) {
    final categoryColor = _getCategoryColor(note.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.stickyNote,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                note.date,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
              if (note.category != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    note.category!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: categoryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Ajuste':
        return AppColors.primary;
      case 'Alerta':
        return AppColors.warning;
      case 'Feedback':
        return AppColors.success;
      case 'Restrição':
        return AppColors.destructive;
      default:
        return AppColors.secondary;
    }
  }
}
