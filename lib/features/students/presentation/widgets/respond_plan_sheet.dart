import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../providers/student_plans_provider.dart';

/// Sheet for responding to a pending plan assignment (accept/decline)
class RespondPlanSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> assignment;
  final String studentUserId;

  const RespondPlanSheet({
    super.key,
    required this.assignment,
    required this.studentUserId,
  });

  @override
  ConsumerState<RespondPlanSheet> createState() => _RespondPlanSheetState();
}

class _RespondPlanSheetState extends ConsumerState<RespondPlanSheet> {
  final _reasonController = TextEditingController();
  bool _showDeclineReason = false;

  String get _planName => widget.assignment['plan_name'] as String? ?? 'Plano de Treino';
  String get _assignmentId => widget.assignment['id'] as String;
  String? get _trainerName => widget.assignment['trainer_name'] as String?;
  String? get _notes => widget.assignment['notes'] as String?;
  String? get _startDateStr => widget.assignment['start_date'] as String?;
  String? get _endDateStr => widget.assignment['end_date'] as String?;
  int? get _durationWeeks => widget.assignment['plan']?['duration_weeks'] as int?;
  String? get _goal => widget.assignment['plan']?['goal'] as String?;
  String? get _difficulty => widget.assignment['plan']?['difficulty'] as String?;
  int? get _workoutCount => widget.assignment['plan']?['workout_count'] as int?;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '--';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _translateGoal(String? goal) {
    if (goal == null) return '--';
    switch (goal.toLowerCase()) {
      case 'hypertrophy':
        return 'Hipertrofia';
      case 'strength':
        return 'Forca';
      case 'fat_loss':
        return 'Emagrecimento';
      case 'endurance':
        return 'Resistencia';
      case 'functional':
        return 'Funcional';
      case 'general_fitness':
        return 'Condicionamento';
      default:
        return goal;
    }
  }

  String _translateDifficulty(String? difficulty) {
    if (difficulty == null) return '--';
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Intermediario';
      case 'advanced':
        return 'Avancado';
      default:
        return difficulty;
    }
  }

  Future<void> _acceptPlan() async {
    HapticUtils.mediumImpact();

    final notifier = ref.read(studentPlansProvider(widget.studentUserId).notifier);
    final success = await notifier.acceptAssignment(_assignmentId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Plano aceito com sucesso!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao aceitar plano. Tente novamente.'),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _declinePlan() async {
    if (!_showDeclineReason) {
      setState(() => _showDeclineReason = true);
      return;
    }

    HapticUtils.mediumImpact();

    final reason = _reasonController.text.trim().isNotEmpty
        ? _reasonController.text.trim()
        : null;

    final notifier = ref.read(studentPlansProvider(widget.studentUserId).notifier);
    final success = await notifier.declineAssignment(_assignmentId, reason: reason);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(LucideIcons.info, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Plano recusado'),
              ],
            ),
            backgroundColor: AppColors.mutedForeground,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao recusar plano. Tente novamente.'),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final plansState = ref.watch(studentPlansProvider(widget.studentUserId));
    final isResponding = plansState.isResponding;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
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
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              children: [
                // Pending badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.warning.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.clock, size: 14, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text(
                        'Aguardando sua resposta',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Plan name
                Text(
                  _planName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (_trainerName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.user,
                        size: 14,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Prescrito por $_trainerName',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Plan details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                children: [
                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          context,
                          isDark,
                          LucideIcons.calendar,
                          'Inicio',
                          _formatDate(_startDateStr),
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          context,
                          isDark,
                          LucideIcons.calendarCheck,
                          'Termino',
                          _endDateStr != null ? _formatDate(_endDateStr) : 'Continuo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_goal != null)
                        Expanded(
                          child: _buildDetailItem(
                            context,
                            isDark,
                            LucideIcons.target,
                            'Objetivo',
                            _translateGoal(_goal),
                          ),
                        ),
                      if (_difficulty != null)
                        Expanded(
                          child: _buildDetailItem(
                            context,
                            isDark,
                            LucideIcons.gauge,
                            'Nivel',
                            _translateDifficulty(_difficulty),
                          ),
                        ),
                    ],
                  ),
                  if (_durationWeeks != null || _workoutCount != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (_durationWeeks != null)
                          Expanded(
                            child: _buildDetailItem(
                              context,
                              isDark,
                              LucideIcons.clock,
                              'Duracao',
                              '$_durationWeeks semanas',
                            ),
                          ),
                        if (_workoutCount != null)
                          Expanded(
                            child: _buildDetailItem(
                              context,
                              isDark,
                              LucideIcons.dumbbell,
                              'Treinos',
                              '$_workoutCount treinos',
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Trainer notes
          if (_notes != null && _notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withAlpha(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.messageSquare, size: 16, color: AppColors.info),
                        const SizedBox(width: 8),
                        Text(
                          'Nota do Personal',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _notes!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Decline reason input
          if (_showDeclineReason) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _reasonController,
                maxLines: 2,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: 'Motivo da recusa (opcional)',
                  hintText: 'Ex: Prefiro outro tipo de treino, horarios incompativeis...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(LucideIcons.messageCircle),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              children: [
                // Decline button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isResponding ? null : _declinePlan,
                    icon: Icon(
                      _showDeclineReason ? LucideIcons.send : LucideIcons.x,
                      size: 18,
                    ),
                    label: Text(_showDeclineReason ? 'Confirmar Recusa' : 'Recusar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.destructive,
                      side: const BorderSide(color: AppColors.destructive),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Accept button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isResponding ? null : _acceptPlan,
                    icon: isResponding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(LucideIcons.check, size: 18),
                    label: Text(isResponding ? 'Processando...' : 'Aceitar Plano'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    bool isDark,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 12,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Shows the respond plan sheet as a modal bottom sheet
Future<bool?> showRespondPlanSheet(
  BuildContext context, {
  required Map<String, dynamic> assignment,
  required String studentUserId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => RespondPlanSheet(
      assignment: assignment,
      studentUserId: studentUserId,
    ),
  );
}
