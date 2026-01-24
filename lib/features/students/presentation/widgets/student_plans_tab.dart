import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../providers/student_plans_provider.dart';
import 'assign_existing_plan_sheet.dart';
import 'current_plan_card.dart';
import 'evolve_plan_sheet.dart';
import 'prescribe_plan_sheet.dart';

/// Tab content showing student's training plans
class StudentPlansTab extends ConsumerWidget {
  final String studentUserId;
  final String studentName;

  const StudentPlansTab({
    super.key,
    required this.studentUserId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(studentPlansProvider(studentUserId));

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return _buildErrorState(context, theme, isDark, state.error!, ref);
    }

    return RefreshIndicator(
      onRefresh: () async {
        HapticUtils.lightImpact();
        ref.read(studentPlansProvider(studentUserId).notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // New Plans Section (not yet seen by student)
          if (state.newPlans.isNotEmpty) ...[
            _buildSectionHeader(
              theme,
              isDark,
              'Novos Planos',
              LucideIcons.sparkles,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${state.newPlans.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildNewPlansList(context, theme, isDark, state.newPlans, ref),
            const SizedBox(height: 24),
          ],

          // Active Plans Section
          _buildSectionHeader(
            theme,
            isDark,
            'Planos Ativos',
            LucideIcons.target,
            trailing: state.activePlans.length > 1
                ? Text(
                    '${state.activePlans.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          if (state.activePlans.isEmpty)
            _buildNoPlanCard(context, theme, isDark)
          else
            ...state.activePlans.map((assignment) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CurrentPlanCard(
                    assignment: assignment,
                    studentUserId: studentUserId,
                    studentName: studentName,
                    onViewDetails: () => _viewPlanDetails(
                        context, assignment['plan_id'] as String),
                    onEditPrescription: () => _editPrescription(
                        context, assignment['plan_id'] as String),
                    onEvolvePlan: () =>
                        _showEvolvePlanSheetForAssignment(context, ref, assignment),
                    onDeactivate: () =>
                        _confirmDeactivateAssignment(context, ref, assignment['id'] as String),
                    onCancel: () => _confirmCancelAssignment(
                        context, ref, assignment['id'] as String),
                  ),
                )),

          const SizedBox(height: 24),

          // Scheduled Plans Section (only show if there are scheduled plans)
          if (state.scheduledPlans.isNotEmpty) ...[
            _buildSectionHeader(
              theme,
              isDark,
              'Planos Agendados',
              LucideIcons.calendarClock,
              trailing: Text(
                '${state.scheduledPlans.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildScheduledList(context, theme, isDark, state.scheduledPlans, ref),
            const SizedBox(height: 24),
          ],

          // Quick Actions Section
          _buildSectionHeader(theme, isDark, 'Ações Rápidas', LucideIcons.zap),
          const SizedBox(height: 12),
          _buildQuickActions(context, theme, isDark, ref),

          const SizedBox(height: 24),

          // Plan History Section (limited to 5 items)
          _buildSectionHeader(
            theme,
            isDark,
            'Histórico de Planos',
            LucideIcons.history,
            trailing: state.historyAssignments.isNotEmpty
                ? Text(
                    '${state.historyAssignments.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          if (state.historyAssignments.isEmpty)
            _buildEmptyHistory(theme, isDark)
          else ...[
            _buildHistoryList(
              context,
              theme,
              isDark,
              state.historyAssignments.take(5).toList(),
            ),
            if (state.historyAssignments.length > 5) ...[
              const SizedBox(height: 12),
              _buildViewMoreButton(context, theme, isDark, state.historyAssignments.length),
            ],
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    bool isDark,
    String title,
    IconData icon, {
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
      ],
    );
  }

  Widget _buildNoPlanCard(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.muted.withAlpha(isDark ? 30 : 50),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.clipboardX,
              size: 32,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum plano ativo',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este aluno não possui um plano de treino atribuído',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _showPrescribeSheet(context),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Prescrever Plano'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    WidgetRef ref,
  ) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: LucideIcons.filePlus,
            label: 'Prescrever Novo',
            description: 'Criar plano personalizado',
            isDark: isDark,
            onTap: () => _showPrescribeSheet(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: LucideIcons.fileSymlink,
            label: 'Atribuir Existente',
            description: 'Usar plano já criado',
            isDark: isDark,
            onTap: () => _showAssignExistingSheet(context, ref),
          ),
        ),
      ],
    );
  }

  /// Builds the new plans list for trainer view (plans not yet seen by student)
  Widget _buildNewPlansList(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    List<Map<String, dynamic>> newPlans,
    WidgetRef ref,
  ) {
    return Column(
      children: newPlans.map((assignment) {
        final planName = assignment['plan_name'] as String? ?? 'Plano sem nome';
        final startDateStr = assignment['start_date'] as String?;
        final notes = assignment['notes'] as String?;

        String dateInfo = '';
        if (startDateStr != null) {
          dateInfo = 'Início: ${_formatDate(startDateStr)}';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withAlpha(80),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.sparkles,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            planName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Novo',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (dateInfo.isNotEmpty)
                      Text(
                        dateInfo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    if (notes != null && notes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          notes.length > 50 ? '${notes.substring(0, 50)}...' : notes,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.info,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Aluno ainda não visualizou',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary.withAlpha(180),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              // Menu with view, edit options
              PopupMenuButton<String>(
                icon: Icon(
                  LucideIcons.moreVertical,
                  size: 18,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
                onSelected: (value) {
                  final planId = assignment['plan_id'] as String;
                  switch (value) {
                    case 'view':
                      _viewPlanDetails(context, planId);
                    case 'edit':
                      _editPrescription(context, planId);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(LucideIcons.eye, size: 16),
                        SizedBox(width: 8),
                        Text('Ver plano'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(LucideIcons.pencil, size: 16),
                        SizedBox(width: 8),
                        Text('Editar plano'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScheduledList(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    List<Map<String, dynamic>> scheduled,
    WidgetRef ref,
  ) {
    return Column(
      children: scheduled.map((assignment) {
        final planName = assignment['plan_name'] as String? ?? 'Plano sem nome';
        final startDateStr = assignment['start_date'] as String?;
        final endDateStr = assignment['end_date'] as String?;
        final status = assignment['status'] as String?;

        String dateInfo = '';
        if (startDateStr != null) {
          dateInfo = 'Inicia em ${_formatDate(startDateStr)}';
          if (endDateStr != null) {
            dateInfo += ' - Até ${_formatDate(endDateStr)}';
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.warning.withAlpha(60),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(isDark ? 30 : 20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  LucideIcons.calendarClock,
                  size: 18,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            planName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (status == 'pending')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Pendente',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (dateInfo.isNotEmpty)
                      Text(
                        dateInfo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  LucideIcons.moreVertical,
                  size: 18,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
                onSelected: (value) {
                  final assignmentId = assignment['id'] as String;
                  final planId = assignment['plan_id'] as String;
                  switch (value) {
                    case 'view':
                      _viewPlanDetails(context, planId);
                    case 'cancel':
                      _confirmCancelAssignment(context, ref, assignmentId);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(LucideIcons.eye, size: 16),
                        SizedBox(width: 8),
                        Text('Ver plano'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(LucideIcons.trash2, size: 16, color: AppColors.destructive),
                        const SizedBox(width: 8),
                        Text('Cancelar', style: TextStyle(color: AppColors.destructive)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyHistory(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.inbox,
            size: 24,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nenhum plano anterior',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    List<Map<String, dynamic>> history,
  ) {
    return Column(
      children: history.map((assignment) {
        final planName = assignment['plan_name'] as String? ?? 'Plano sem nome';
        final endDateStr = assignment['end_date'] as String?;
        final startDateStr = assignment['start_date'] as String?;
        final status = assignment['status'] as String?;
        final declinedReason = assignment['declined_reason'] as String?;
        final isDeclined = status == 'declined';

        String dateRange = '';
        if (startDateStr != null || endDateStr != null) {
          final start = startDateStr != null ? _formatDate(startDateStr) : '?';
          final end = endDateStr != null ? _formatDate(endDateStr) : '?';
          dateRange = '$start - $end';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDeclined
                  ? AppColors.destructive.withAlpha(60)
                  : (isDark ? AppColors.borderDark : AppColors.border),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDeclined
                      ? AppColors.destructive.withAlpha(isDark ? 30 : 20)
                      : AppColors.muted.withAlpha(isDark ? 30 : 50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDeclined ? LucideIcons.xCircle : LucideIcons.clipboardList,
                  size: 18,
                  color: isDeclined
                      ? AppColors.destructive
                      : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            planName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isDeclined)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.destructive.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Recusado',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.destructive,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (dateRange.isNotEmpty)
                      Text(
                        dateRange,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    if (isDeclined && declinedReason != null && declinedReason.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              LucideIcons.messageCircle,
                              size: 12,
                              color: AppColors.destructive.withAlpha(150),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                declinedReason.length > 60
                                    ? '${declinedReason.substring(0, 60)}...'
                                    : declinedReason,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.destructive.withAlpha(180),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticUtils.lightImpact();
                  final planId = assignment['plan_id'] as String?;
                  if (planId != null) {
                    _viewPlanDetails(context, planId);
                  }
                },
                icon: Icon(
                  LucideIcons.eye,
                  size: 18,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
                tooltip: 'Ver detalhes',
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String error,
    WidgetRef ref,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar planos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                HapticUtils.lightImpact();
                ref.read(studentPlansProvider(studentUserId).notifier).refresh();
              },
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  void _viewPlanDetails(BuildContext context, String planId) {
    HapticUtils.lightImpact();
    context.push('/plans/$planId');
  }

  void _editPrescription(BuildContext context, String planId) {
    HapticUtils.lightImpact();
    context.push('/plans/wizard?edit=$planId');
  }

  void _showPrescribeSheet(BuildContext context) {
    HapticUtils.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PrescribePlanSheet(
        studentUserId: studentUserId,
        studentName: studentName,
      ),
    );
  }

  void _showAssignExistingSheet(BuildContext context, WidgetRef ref) {
    HapticUtils.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignExistingPlanSheet(
        studentUserId: studentUserId,
        studentName: studentName,
      ),
    );
  }

  void _showEvolvePlanSheetForAssignment(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> assignment,
  ) {
    HapticUtils.lightImpact();

    final endDateStr = assignment['end_date'] as String?;
    DateTime? endDate;
    if (endDateStr != null) {
      try {
        endDate = DateTime.parse(endDateStr);
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EvolvePlanSheet(
        studentUserId: studentUserId,
        studentName: studentName,
        currentPlanId: assignment['plan_id'] as String,
        currentPlanName: assignment['plan_name'] as String? ?? 'Plano atual',
        currentAssignmentId: assignment['id'] as String?,
        currentEndDate: endDate,
      ),
    );
  }

  void _confirmDeactivateAssignment(BuildContext context, WidgetRef ref, String assignmentId) {
    HapticUtils.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encerrar plano?'),
        content: const Text(
          'O plano será movido para o histórico. '
          'O aluno não terá mais acesso a este plano.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(studentPlansProvider(studentUserId).notifier)
                  .deactivateAssignment(assignmentId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Plano encerrado com sucesso'
                          : 'Erro ao encerrar plano',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.destructive,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
            ),
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
  }

  void _confirmCancelAssignment(BuildContext context, WidgetRef ref, String assignmentId) {
    HapticUtils.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar atribuição?'),
        content: const Text(
          'A atribuição pendente será cancelada e o aluno não receberá este plano.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(studentPlansProvider(studentUserId).notifier)
                  .cancelAssignment(assignmentId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Atribuição cancelada com sucesso'
                          : 'Erro ao cancelar atribuição',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.destructive,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
            ),
            child: const Text('Cancelar atribuição'),
          ),
        ],
      ),
    );
  }

  Widget _buildViewMoreButton(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    int totalCount,
  ) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        context.push('/students/$studentUserId/plan-history');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.history,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Ver todo o histórico ($totalCount planos)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick action card widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
