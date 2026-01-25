import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Card displaying the current active plan for a student
class CurrentPlanCard extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final String studentUserId;
  final String studentName;
  final VoidCallback onViewDetails;
  final VoidCallback onEditPrescription;
  final VoidCallback onEvolvePlan;
  final VoidCallback onDeactivate;
  final VoidCallback? onCancel;

  const CurrentPlanCard({
    super.key,
    required this.assignment,
    required this.studentUserId,
    required this.studentName,
    required this.onViewDetails,
    required this.onEditPrescription,
    required this.onEvolvePlan,
    required this.onDeactivate,
    this.onCancel,
  });

  /// Get status info (color, label, icon)
  ({Color color, String label, IconData icon}) _getStatusInfo(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return (color: AppColors.warning, label: 'Pendente', icon: LucideIcons.clock);
      case 'accepted':
        return (color: AppColors.success, label: 'Aceito', icon: LucideIcons.checkCircle);
      case 'declined':
        return (color: AppColors.destructive, label: 'Recusado', icon: LucideIcons.xCircle);
      default:
        return (color: AppColors.success, label: 'Ativo', icon: LucideIcons.checkCircle);
    }
  }

  bool get _isPending => assignment['status']?.toString().toLowerCase() == 'pending';
  bool get _isDeclined => assignment['status']?.toString().toLowerCase() == 'declined';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final planName = assignment['plan_name'] as String? ?? 'Prescrição de Treino';
    final objective = assignment['plan_objective'] as String?;
    final startDateStr = assignment['start_date'] as String?;
    final endDateStr = assignment['end_date'] as String?;
    final notes = assignment['notes'] as String?;

    // Calculate progress if dates are available
    double? progress;
    String? progressText;
    if (startDateStr != null && endDateStr != null) {
      try {
        final startDate = DateTime.parse(startDateStr);
        final endDate = DateTime.parse(endDateStr);
        final now = DateTime.now();
        final totalDays = endDate.difference(startDate).inDays;
        final elapsedDays = now.difference(startDate).inDays;

        if (totalDays > 0) {
          progress = (elapsedDays / totalDays).clamp(0.0, 1.0);
          final remainingDays = endDate.difference(now).inDays;
          if (remainingDays > 0) {
            progressText = '$remainingDays dias restantes';
          } else if (remainingDays == 0) {
            progressText = 'Último dia';
          } else {
            progressText = 'Expirado há ${-remainingDays} dias';
          }
        }
      } catch (_) {}
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withAlpha(isDark ? 30 : 25),
            AppColors.secondary.withAlpha(isDark ? 20 : 15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withAlpha(isDark ? 60 : 40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(isDark ? 40 : 30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.clipboardCheck,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (objective != null)
                        Text(
                          objective,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Status badge
                Builder(
                  builder: (context) {
                    final statusInfo = _getStatusInfo(assignment['status'] as String?);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusInfo.color.withAlpha(isDark ? 40 : 30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusInfo.icon,
                            size: 12,
                            color: statusInfo.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusInfo.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusInfo.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Progress bar
          if (progress != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark
                          ? AppColors.mutedDark.withAlpha(100)
                          : AppColors.muted,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                  if (progressText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      progressText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: progress >= 1.0
                            ? AppColors.warning
                            : (isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Notes if present
          if (notes != null && notes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.mutedDark.withAlpha(50)
                      : AppColors.muted.withAlpha(100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.stickyNote,
                      size: 14,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notes,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Dates
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (startDateStr != null)
                  _DateChip(
                    icon: LucideIcons.calendarCheck,
                    label: 'Início',
                    date: _formatDate(startDateStr),
                    isDark: isDark,
                  ),
                if (startDateStr != null && endDateStr != null)
                  const SizedBox(width: 12),
                if (endDateStr != null)
                  _DateChip(
                    icon: LucideIcons.calendarX,
                    label: 'Fim',
                    date: _formatDate(endDateStr),
                    isDark: isDark,
                  ),
              ],
            ),
          ),

          // Divider
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),

          // Declined reason if present
          if (_isDeclined && assignment['declined_reason'] != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.destructive.withAlpha(isDark ? 30 : 20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.messageCircle,
                      size: 14,
                      color: AppColors.destructive,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Motivo: ${assignment['declined_reason']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.destructive,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Actions
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _ActionButton(
                  icon: LucideIcons.eye,
                  label: 'Ver',
                  onTap: onViewDetails,
                ),
                if (!_isDeclined) ...[
                  _ActionButton(
                    icon: LucideIcons.pencil,
                    label: 'Editar',
                    onTap: onEditPrescription,
                  ),
                  if (!_isPending)
                    _ActionButton(
                      icon: LucideIcons.trendingUp,
                      label: 'Evoluir',
                      onTap: onEvolvePlan,
                    ),
                ],
                const Spacer(),
                PopupMenuButton<String>(
                  icon: Icon(
                    LucideIcons.moreHorizontal,
                    size: 20,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'deactivate':
                        onDeactivate();
                      case 'cancel':
                        onCancel?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    if (_isPending && onCancel != null)
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Cancelar atribuição', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    if (!_isPending && !_isDeclined)
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: Row(
                          children: [
                            Icon(LucideIcons.xCircle, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Encerrar prescrição', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }
}

class _DateChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String date;
  final bool isDark;

  const _DateChip({
    required this.icon,
    required this.label,
    required this.date,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.mutedDark.withAlpha(50) : AppColors.muted.withAlpha(80),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $date',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton.icon(
      onPressed: () {
        HapticUtils.lightImpact();
        onTap();
      },
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
