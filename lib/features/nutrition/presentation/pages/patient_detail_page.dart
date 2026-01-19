import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/providers/context_provider.dart';
import '../providers/patients_provider.dart';
import '../providers/patient_diet_plan_provider.dart';

/// Patient Detail Page for Nutritionists
/// Shows comprehensive patient info, diet plan, adherence, and notes
class PatientDetailPage extends ConsumerStatefulWidget {
  final String patientId;

  const PatientDetailPage({super.key, required this.patientId});

  @override
  ConsumerState<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends ConsumerState<PatientDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  int _selectedTab = 0;
  final _noteController = TextEditingController();

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
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    if (diff.inDays < 7) return '${diff.inDays} dias atrás';
    return _formatDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get org context for patients
    final activeContext = ref.watch(activeContextProvider);
    final orgId = activeContext?.organization.id;

    // Get patient from patients list
    final patients = orgId != null ? ref.watch(patientsProvider(orgId)) : <Patient>[];
    final patient = patients.cast<Patient?>().firstWhere(
      (p) => p?.id == widget.patientId,
      orElse: () => null,
    );

    // Get diet plan data
    final dietPlanState = ref.watch(patientDietPlanNotifierProvider(widget.patientId));

    return Scaffold(
      body: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                _buildHeader(isDark, theme),

                // Patient info card
                _buildPatientCard(isDark, patient),

                // Tabs
                _buildTabs(isDark),

                // Tab content
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      _buildOverviewTab(isDark, patient, dietPlanState),
                      _buildDietPlanTab(isDark, dietPlanState),
                      _buildNotesTab(isDark, dietPlanState),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? AppColors.cardDark : AppColors.card,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Icon(
                LucideIcons.arrowLeft,
                size: 18,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Paciente',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              _showActionsMenu(isDark);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? AppColors.cardDark : AppColors.card,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Icon(
                LucideIcons.moreVertical,
                size: 18,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(bool isDark, Patient? patient) {
    final patientName = patient?.name ?? 'Paciente';
    final initials = patientName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
    final adherence = patient?.adherence ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withAlpha(isDark ? 40 : 25),
            AppColors.secondary.withAlpha(isDark ? 30 : 15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initials.isNotEmpty ? initials : 'P',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
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
                  patientName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                if (patient?.goal != null) ...[
                  Row(
                    children: [
                      Icon(
                        LucideIcons.target,
                        size: 12,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          patient!.goal!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (adherence > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (adherence >= 80 ? AppColors.success : (adherence >= 50 ? AppColors.warning : AppColors.destructive)).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${adherence.toStringAsFixed(0)}% aderência',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: adherence >= 80 ? AppColors.success : (adherence >= 50 ? AppColors.warning : AppColors.destructive),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Quick actions
          Column(
            children: [
              _buildQuickAction(LucideIcons.messageCircle, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abrindo chat...')),
                );
              }, isDark),
              const SizedBox(height: 8),
              _buildQuickAction(LucideIcons.phone, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ligando...')),
                );
              }, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.primaryDark : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    final tabs = ['Visão Geral', 'Plano', 'Anotações'];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                setState(() => _selectedTab = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.primaryDark : AppColors.primary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOverviewTab(bool isDark, Patient? patient, PatientDietPlanState dietPlanState) {
    if (dietPlanState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adherence stats
          _buildAdherenceCard(isDark, patient, dietPlanState),
          const SizedBox(height: 16),

          // Weekly progress
          _buildWeeklyProgressCard(isDark),
          const SizedBox(height: 16),

          // Patient info
          _buildPatientInfoCard(isDark, patient, dietPlanState),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAdherenceCard(bool isDark, Patient? patient, PatientDietPlanState dietPlanState) {
    final adherence = (patient?.adherence ?? 0).toInt();
    final hasPlan = dietPlanState.hasPlan;

    if (!hasPlan && adherence == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark.withAlpha(150) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              LucideIcons.target,
              size: 32,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            const SizedBox(height: 12),
            Text(
              'Sem dados de aderência',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Atribua um plano alimentar para acompanhar',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.mutedForegroundDark.withAlpha(180) : AppColors.mutedForeground.withAlpha(180),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withAlpha(150) : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.target, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Aderencia ao Plano',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAdherenceStat(
                  'Geral',
                  '$adherence%',
                  adherence,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      hasPlan ? 'Ativo' : 'Inativo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: hasPlan ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    Text(
                      'Status do plano',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdherenceStat(String label, String value, int percent, bool isDark) {
    final color = percent >= 80
        ? AppColors.success
        : (percent >= 60 ? AppColors.warning : AppColors.destructive);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: percent / 100,
                strokeWidth: 5,
                backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
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

  Widget _buildWeeklyProgressCard(bool isDark) {
    // Weekly progress data not yet available from API
    final weeklyProgress = <Map<String, dynamic>>[];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withAlpha(150) : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progresso Semanal',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          if (weeklyProgress.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Dados de progresso semanal serão exibidos aqui',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weeklyProgress.map((day) {
                final adherence = day['adherence'] as int;
                final color = adherence >= 80
                    ? AppColors.success
                    : (adherence >= 50 ? AppColors.warning : AppColors.destructive);

                return Column(
                  children: [
                    Container(
                      width: 30,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mutedDark : AppColors.muted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 30,
                          height: 60 * (adherence / 100),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      day['day'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoCard(bool isDark, Patient? patient, PatientDietPlanState dietPlanState) {
    // Basic patient info - most fields not yet available from API
    final infoItems = <Map<String, dynamic>>[];

    if (patient?.goal != null) {
      infoItems.add({'label': 'Objetivo', 'value': patient!.goal!, 'icon': LucideIcons.target});
    }

    if (patient?.hasPlan == true) {
      infoItems.add({'label': 'Plano ativo', 'value': 'Sim', 'icon': LucideIcons.clipboardCheck});
    }

    if (dietPlanState.summary != null) {
      infoItems.add({'label': 'Plano', 'value': dietPlanState.summary!.planName, 'icon': LucideIcons.utensils});
    }

    if (dietPlanState.targets.calories > 0) {
      infoItems.add({'label': 'Calorias/dia', 'value': '${dietPlanState.targets.calories} kcal', 'icon': LucideIcons.flame});
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withAlpha(150) : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          if (infoItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Informações detalhadas serão exibidas aqui',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            )
          else
            ...infoItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 16,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      item['value'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildDietPlanTab(bool isDark, PatientDietPlanState dietPlanState) {
    if (dietPlanState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!dietPlanState.hasPlan) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.clipboardList,
                size: 48,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum plano atribuído',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Atribua um plano alimentar para este paciente',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abrindo seleção de planos...')),
                  );
                },
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Atribuir Plano'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final summary = dietPlanState.summary!;
    final targets = dietPlanState.targets;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current plan card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(isDark ? 30 : 15),
                  AppColors.secondary.withAlpha(isDark ? 20 : 10),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withAlpha(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.clipboardList, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        summary.planName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
                if (summary.startDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Início: ${summary.formattedStartDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMacroStat('${targets.calories}', 'kcal', AppColors.warning),
                    _buildMacroStat('${targets.protein}g', 'Prot', AppColors.destructive),
                    _buildMacroStat('${targets.carbs}g', 'Carb', AppColors.info),
                    _buildMacroStat('${targets.fat}g', 'Gord', AppColors.warning),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: _buildPlanAction('Editar Plano', LucideIcons.edit, () {}, isDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPlanAction('Trocar Plano', LucideIcons.refreshCw, () {}, isDark),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // View full plan button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abrindo plano detalhado...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ver Plano Completo'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMacroStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color.withAlpha(180),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanAction(String label, IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isDark ? AppColors.primaryDark : AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesTab(bool isDark, PatientDietPlanState dietPlanState) {
    final notes = dietPlanState.notes;

    return Column(
      children: [
        // Add note input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Adicionar anotação...',
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.cardDark : AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () async {
                  if (_noteController.text.isNotEmpty) {
                    HapticUtils.mediumImpact();
                    final notifier = ref.read(patientDietPlanNotifierProvider(widget.patientId).notifier);
                    final success = await notifier.addNote(_noteController.text, category: 'observação');
                    if (success && mounted) {
                      _noteController.clear();
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.send, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Notes list
        Expanded(
          child: notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.stickyNote,
                        size: 40,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma anotação',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Adicione uma anotação sobre este paciente',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.mutedForegroundDark.withAlpha(180) : AppColors.mutedForeground.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return _buildPatientNoteItem(note, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPatientNoteItem(PatientNote note, bool isDark) {
    final categoryColors = {
      'observação': AppColors.info,
      'consulta': AppColors.success,
      'ajuste': AppColors.warning,
    };

    final category = note.category ?? 'observação';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withAlpha(150) : AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (categoryColors[category] ?? AppColors.muted).withAlpha(20),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: categoryColors[category] ?? AppColors.mutedForeground,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                note.date,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.content,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  void _showActionsMenu(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuOption('Enviar mensagem', LucideIcons.messageCircle, () {
                Navigator.pop(ctx);
              }, isDark),
              _buildMenuOption('Agendar consulta', LucideIcons.calendar, () {
                Navigator.pop(ctx);
              }, isDark),
              _buildMenuOption('Ver histórico', LucideIcons.history, () {
                Navigator.pop(ctx);
              }, isDark),
              _buildMenuOption('Remover paciente', LucideIcons.userMinus, () {
                Navigator.pop(ctx);
              }, isDark, isDestructive: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(String label, IconData icon, VoidCallback onTap, bool isDark, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.mutedDark.withAlpha(100) : AppColors.muted.withAlpha(150),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? AppColors.destructive : (isDark ? AppColors.primaryDark : AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? AppColors.destructive
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
