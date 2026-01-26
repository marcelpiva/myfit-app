import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../providers/student_home_provider.dart';

/// Sheet for reviewing and accepting/declining a prescribed plan
class PlanReviewSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> assignment;

  const PlanReviewSheet({
    super.key,
    required this.assignment,
  });

  @override
  ConsumerState<PlanReviewSheet> createState() => _PlanReviewSheetState();
}

class _PlanReviewSheetState extends ConsumerState<PlanReviewSheet> {
  final _declineReasonController = TextEditingController();
  bool _showDeclineForm = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _declineReasonController.dispose();
    super.dispose();
  }

  String get planName => widget.assignment['plan_name'] as String? ?? 'Novo plano';
  String? get trainerName => widget.assignment['trainer_name'] as String?;
  String? get notes => widget.assignment['notes'] as String?;
  String? get startDateStr => widget.assignment['start_date'] as String?;
  String? get endDateStr => widget.assignment['end_date'] as String?;
  int? get workoutCount => widget.assignment['workout_count'] as int?;
  String? get goal => widget.assignment['goal'] as String?;
  String? get difficulty => widget.assignment['difficulty'] as String?;

  Future<void> _acceptPlan() async {
    HapticUtils.mediumImpact();
    setState(() => _isSubmitting = true);

    final assignmentId = widget.assignment['id'] as String;
    final success = await ref.read(studentNewPlansProvider.notifier).respondToPlan(
      assignmentId,
      accept: true,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Plano aceito com sucesso!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao aceitar plano'),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _declinePlan() async {
    HapticUtils.heavyImpact();
    setState(() => _isSubmitting = true);

    final assignmentId = widget.assignment['id'] as String;
    final reason = _declineReasonController.text.trim();
    final success = await ref.read(studentNewPlansProvider.notifier).respondToPlan(
      assignmentId,
      accept: false,
      declinedReason: reason.isNotEmpty ? reason : null,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Plano recusado'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao recusar plano'),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final newPlansState = ref.watch(studentNewPlansProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.clipboardList,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nova Prescrição',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (trainerName != null)
                        Text(
                          'De: $trainerName',
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
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Plan Details
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan name card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(60),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (notes != null && notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.info.withAlpha(isDark ? 20 : 15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  LucideIcons.messageCircle,
                                  size: 16,
                                  color: AppColors.info,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    notes!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.info,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Plan info grid
                  Row(
                    children: [
                      if (startDateStr != null)
                        Expanded(
                          child: _InfoCard(
                            icon: LucideIcons.calendarCheck,
                            label: 'Início',
                            value: _formatDate(startDateStr!),
                            isDark: isDark,
                          ),
                        ),
                      if (startDateStr != null && endDateStr != null)
                        const SizedBox(width: 12),
                      if (endDateStr != null)
                        Expanded(
                          child: _InfoCard(
                            icon: LucideIcons.calendarX,
                            label: 'Término',
                            value: _formatDate(endDateStr!),
                            isDark: isDark,
                          ),
                        ),
                    ],
                  ),

                  if (workoutCount != null || goal != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (workoutCount != null)
                          Expanded(
                            child: _InfoCard(
                              icon: LucideIcons.dumbbell,
                              label: 'Treinos',
                              value: '$workoutCount',
                              isDark: isDark,
                            ),
                          ),
                        if (workoutCount != null && goal != null)
                          const SizedBox(width: 12),
                        if (goal != null)
                          Expanded(
                            child: _InfoCard(
                              icon: LucideIcons.target,
                              label: 'Objetivo',
                              value: _translateGoal(goal!),
                              isDark: isDark,
                            ),
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // View plan button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              HapticUtils.lightImpact();
                              final planId = widget.assignment['plan_id'] as String?;
                              if (planId != null) {
                                context.push('/plans/$planId');
                              }
                            },
                      icon: const Icon(LucideIcons.eye, size: 18),
                      label: const Text('Ver detalhes do plano'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Decline form (if showing)
                  if (_showDeclineForm) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.destructive.withAlpha(isDark ? 20 : 10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.destructive.withAlpha(60),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.messageSquare,
                                size: 18,
                                color: AppColors.destructive,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Motivo da recusa (opcional)',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.destructive,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _declineReasonController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Descreva o motivo...',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground,
                              ),
                              filled: true,
                              fillColor: isDark ? AppColors.cardDark : AppColors.card,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : () {
                                          setState(() => _showDeclineForm = false);
                                        },
                                  child: const Text('Voltar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _isSubmitting ? null : _declinePlan,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.destructive,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: _isSubmitting && newPlansState.isResponding
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Confirmar Recusa'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () {
                                    HapticUtils.lightImpact();
                                    setState(() => _showDeclineForm = true);
                                  },
                            icon: Icon(
                              LucideIcons.xCircle,
                              size: 18,
                              color: AppColors.destructive,
                            ),
                            label: Text(
                              'Recusar',
                              style: TextStyle(color: AppColors.destructive),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(color: AppColors.destructive.withAlpha(100)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: _isSubmitting ? null : _acceptPlan,
                            icon: _isSubmitting && newPlansState.isResponding
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(LucideIcons.checkCircle, size: 18),
                            label: const Text('Aceitar Plano'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
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

  String _translateGoal(String goal) {
    switch (goal.toLowerCase()) {
      case 'hypertrophy':
        return 'Hipertrofia';
      case 'strength':
        return 'Força';
      case 'fat_loss':
        return 'Emagrecimento';
      case 'endurance':
        return 'Resistência';
      case 'functional':
        return 'Funcional';
      case 'general_fitness':
        return 'Condicionamento';
      default:
        return goal;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
          Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show the plan review sheet
void showPlanReviewSheet(BuildContext context, Map<String, dynamic> assignment) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => PlanReviewSheet(assignment: assignment),
  );
}
