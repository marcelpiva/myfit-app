import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../providers/student_plans_provider.dart';

/// Sheet for evolving/periodizing a student's current plan
class EvolvePlanSheet extends ConsumerStatefulWidget {
  final String studentUserId;
  final String studentName;
  final String currentPlanId;
  final String currentPlanName;
  final String? currentAssignmentId;
  final DateTime? currentEndDate;

  const EvolvePlanSheet({
    super.key,
    required this.studentUserId,
    required this.studentName,
    required this.currentPlanId,
    required this.currentPlanName,
    this.currentAssignmentId,
    this.currentEndDate,
  });

  @override
  ConsumerState<EvolvePlanSheet> createState() => _EvolvePlanSheetState();
}

class _EvolvePlanSheetState extends ConsumerState<EvolvePlanSheet> {
  DateTime? _newEndDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default to 4 weeks after current end date or from now
    final baseDate = widget.currentEndDate ?? DateTime.now();
    _newEndDate = baseDate.add(const Duration(days: 28));
  }

  Future<void> _extendPlan() async {
    if (widget.currentAssignmentId == null || _newEndDate == null) return;

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(studentPlansProvider(widget.studentUserId).notifier)
          .extendCurrentPlan(_newEndDate!);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Prescrição renovada até ${_formatDate(_newEndDate!)}'
                  : 'Erro ao renovar prescrição',
            ),
            backgroundColor: success ? AppColors.success : AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _createNewPhase(String phaseType) {
    HapticUtils.lightImpact();
    Navigator.pop(context);

    // Navigate to plan wizard with pre-selected student and periodization params
    context.push(
      '/plans/wizard?studentId=${widget.studentUserId}&basePlanId=${widget.currentPlanId}&phaseType=$phaseType',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
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
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(isDark ? 30 : 20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.trendingUp,
                      size: 28,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Evoluir Prescrição',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.currentPlanName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),

            // Options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Extend/Renew option
                  _EvolutionOption(
                    icon: LucideIcons.calendarPlus,
                    iconColor: AppColors.success,
                    title: 'Renovar Prescrição',
                    description: 'Estender a data de término da prescrição atual',
                    isDark: isDark,
                    expandable: true,
                    expandedContent: _buildExtendContent(theme, isDark),
                    onTap: null,
                  ),

                  const SizedBox(height: 12),

                  // Progress option
                  _EvolutionOption(
                    icon: LucideIcons.arrowUpCircle,
                    iconColor: AppColors.primary,
                    title: 'Progredir',
                    description: 'Nova fase com cargas/volume aumentados',
                    isDark: isDark,
                    onTap: () => _createNewPhase('progress'),
                  ),

                  const SizedBox(height: 12),

                  // Deload option
                  _EvolutionOption(
                    icon: LucideIcons.battery,
                    iconColor: AppColors.warning,
                    title: 'Semana Deload',
                    description: 'Período de recuperação com volume reduzido',
                    isDark: isDark,
                    onTap: () => _createNewPhase('deload'),
                  ),

                  const SizedBox(height: 12),

                  // New cycle option
                  _EvolutionOption(
                    icon: LucideIcons.refreshCcw,
                    iconColor: AppColors.info,
                    title: 'Novo Ciclo',
                    description: 'Iniciar novo ciclo baseado na prescrição atual',
                    isDark: isDark,
                    onTap: () => _createNewPhase('new_cycle'),
                  ),
                ],
              ),
            ),

            // Cancel button
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomPadding),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtendContent(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          // Current end date info
          if (widget.currentEndDate != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.mutedDark.withAlpha(50)
                    : AppColors.muted.withAlpha(80),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 16,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Término atual: ${_formatDate(widget.currentEndDate!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // New end date picker
          GestureDetector(
            onTap: () async {
              HapticUtils.selectionClick();
              final date = await showDatePicker(
                context: context,
                initialDate: _newEndDate ?? DateTime.now().add(const Duration(days: 28)),
                firstDate: widget.currentEndDate ?? DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _newEndDate = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.calendarDays,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nova data de término',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _newEndDate != null
                              ? _formatDate(_newEndDate!)
                              : 'Selecionar data',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
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

          const SizedBox(height: 12),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _extendPlan,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Renovar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EvolutionOption extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool isDark;
  final VoidCallback? onTap;
  final bool expandable;
  final Widget? expandedContent;

  const _EvolutionOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isDark,
    this.onTap,
    this.expandable = false,
    this.expandedContent,
  });

  @override
  State<_EvolutionOption> createState() => _EvolutionOptionState();
}

class _EvolutionOptionState extends State<_EvolutionOption> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        if (widget.expandable) {
          setState(() => _isExpanded = !_isExpanded);
        } else {
          widget.onTap?.call();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isExpanded
                ? widget.iconColor.withAlpha(100)
                : (widget.isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.iconColor.withAlpha(widget.isDark ? 30 : 20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 22,
                    color: widget.iconColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: widget.isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  widget.expandable
                      ? (_isExpanded
                          ? LucideIcons.chevronUp
                          : LucideIcons.chevronDown)
                      : LucideIcons.chevronRight,
                  size: 20,
                  color: widget.isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ],
            ),
            if (_isExpanded && widget.expandedContent != null)
              widget.expandedContent!,
          ],
        ),
      ),
    );
  }
}
