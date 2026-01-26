import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../providers/student_plans_provider.dart';

/// Page showing full plan history for a student with pagination
class StudentPlanHistoryPage extends ConsumerWidget {
  final String studentId;
  final String? studentName;

  const StudentPlanHistoryPage({
    super.key,
    required this.studentId,
    this.studentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(studentPlansProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          studentName != null
              ? 'Histórico - $studentName'
              : 'Histórico de Prescrições',
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            HapticUtils.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildError(context, theme, state.error!, ref)
              : state.historyAssignments.isEmpty
                  ? _buildEmpty(theme, isDark)
                  : _buildHistoryList(context, theme, isDark, state.historyAssignments),
    );
  }

  Widget _buildError(BuildContext context, ThemeData theme, String error, WidgetRef ref) {
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
              'Erro ao carregar histórico',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                HapticUtils.lightImpact();
                ref.read(studentPlansProvider(studentId).notifier).refresh();
              },
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.history,
              size: 48,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma prescrição no histórico',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prescrições encerradas aparecerão aqui',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    List<Map<String, dynamic>> history,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final assignment = history[index];
        final isFirst = index == 0;
        final isLast = index == history.length - 1;
        final versionNumber = history.length - index;

        return _buildTimelineItem(
          context,
          theme,
          isDark,
          assignment,
          isFirst: isFirst,
          isLast: isLast,
          versionNumber: versionNumber,
        );
      },
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> assignment, {
    required bool isFirst,
    required bool isLast,
    required int versionNumber,
  }) {
    final planName = assignment['plan_name'] as String? ?? 'Prescricao';
    final startDate = assignment['start_date'] as String?;
    final endDate = assignment['end_date'] as String?;
    final planId = assignment['plan_id'] as String?;
    final status = assignment['status'] as String? ?? 'completed';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          SizedBox(
            width: 60,
            child: Column(
              children: [
                // Top connector line
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 16,
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                // Version circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isFirst
                        ? AppColors.primary.withAlpha(20)
                        : (isDark ? AppColors.mutedDark : AppColors.muted),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFirst
                          ? AppColors.primary
                          : (isDark ? AppColors.borderDark : AppColors.border),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'v$versionNumber',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isFirst
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground),
                      ),
                    ),
                  ),
                ),
                // Bottom connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),

          // Content card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isFirst
                      ? AppColors.primary.withAlpha(100)
                      : (isDark ? AppColors.borderDark : AppColors.border),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(status),
                                size: 12,
                                color: _getStatusColor(status),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getStatusLabel(status),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(status),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // View button
                        IconButton(
                          onPressed: () {
                            HapticUtils.lightImpact();
                            if (planId != null) {
                              context.push('/plans/$planId');
                            }
                          },
                          icon: Icon(
                            LucideIcons.eye,
                            size: 18,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                          tooltip: 'Ver detalhes',
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Plan name
                    Text(
                      planName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Date range
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 14,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDateRange(startDate, endDate),
                          style: theme.textTheme.bodySmall?.copyWith(
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
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
        return AppColors.destructive;
      default:
        return AppColors.mutedForeground;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return LucideIcons.play;
      case 'completed':
        return LucideIcons.checkCircle;
      case 'cancelled':
        return LucideIcons.xCircle;
      default:
        return LucideIcons.circle;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Ativo';
      case 'completed':
        return 'Concluido';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String _formatDateRange(String? startDate, String? endDate) {
    final start = _formatDate(startDate);
    final end = _formatDate(endDate);
    if (start != null && end != null) {
      return '$start - $end';
    } else if (start != null) {
      return 'Início: $start';
    } else if (end != null) {
      return 'Fim: $end';
    }
    return 'Datas não informadas';
  }

  String? _formatDate(String? isoDate) {
    if (isoDate == null) return null;
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return null;
    }
  }
}
