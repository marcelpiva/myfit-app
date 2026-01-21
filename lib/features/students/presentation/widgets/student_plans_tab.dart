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
          // Current Plan Section
          _buildSectionHeader(theme, isDark, 'Plano Atual', LucideIcons.target),
          const SizedBox(height: 12),
          if (state.hasCurrentPlan)
            CurrentPlanCard(
              assignment: state.currentAssignment!,
              studentUserId: studentUserId,
              studentName: studentName,
              onViewDetails: () => _viewPlanDetails(context, state.currentPlanId!),
              onEditPrescription: () => _editPrescription(context, state.currentPlanId!),
              onEvolvePlan: () => _showEvolvePlanSheet(context, ref, state),
              onDeactivate: () => _confirmDeactivate(context, ref),
              onCancel: () => _confirmCancelAssignment(context, ref, state.currentAssignmentId!),
            )
          else
            _buildNoPlanCard(context, theme, isDark),

          const SizedBox(height: 24),

          // Quick Actions Section
          _buildSectionHeader(theme, isDark, 'Ações Rápidas', LucideIcons.zap),
          const SizedBox(height: 12),
          _buildQuickActions(context, theme, isDark, ref),

          const SizedBox(height: 24),

          // Plan History Section
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
          else
            _buildHistoryList(context, theme, isDark, state.historyAssignments),

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
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.muted.withAlpha(isDark ? 30 : 50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  LucideIcons.clipboardList,
                  size: 18,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
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
    context.push('/plan/$planId');
  }

  void _editPrescription(BuildContext context, String planId) {
    HapticUtils.lightImpact();
    context.push('/plan/edit/$planId');
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

  void _showEvolvePlanSheet(BuildContext context, WidgetRef ref, StudentPlansState state) {
    HapticUtils.lightImpact();

    if (state.currentAssignment == null) return;

    final endDateStr = state.currentAssignment!['end_date'] as String?;
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
        currentPlanId: state.currentPlanId!,
        currentPlanName: state.currentPlanName ?? 'Plano atual',
        currentAssignmentId: state.currentAssignmentId,
        currentEndDate: endDate,
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, WidgetRef ref) {
    HapticUtils.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encerrar plano?'),
        content: const Text(
          'O plano atual será movido para o histórico. '
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
                  .deactivateCurrentPlan();
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
