import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/models/check_in.dart';

class CheckinHistoryTile extends StatelessWidget {
  final CheckIn checkIn;

  const CheckinHistoryTile({
    super.key,
    required this.checkIn,
  });

  IconData _getSourceIcon() {
    switch (checkIn.source) {
      case CheckInSource.appStudent:
        return LucideIcons.smartphone;
      case CheckInSource.appTrainer:
        return LucideIcons.userCheck;
      case CheckInSource.totem:
        return LucideIcons.tablet;
      case CheckInSource.qrCode:
        return LucideIcons.scanLine;
    }
  }

  String _getSourceLabel() {
    switch (checkIn.source) {
      case CheckInSource.appStudent:
        return 'App';
      case CheckInSource.appTrainer:
        return 'Personal';
      case CheckInSource.totem:
        return 'Totem';
      case CheckInSource.qrCode:
        return 'QR Code';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkInDate = DateTime(date.year, date.month, date.day);

    if (checkInDate == today) {
      return 'Hoje, ${DateFormat.Hm().format(date)}';
    } else if (checkInDate == yesterday) {
      return 'Ontem, ${DateFormat.Hm().format(date)}';
    } else {
      return DateFormat('dd/MM, HH:mm').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    LucideIcons.mapPin,
                    size: 20,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                ),

                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              checkIn.organizationName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (checkIn.pointsEarned != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.sparkles,
                                    size: 12,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${checkIn.pointsEarned}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getSourceIcon(),
                            size: 12,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getSourceLabel(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(checkIn.timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                          if (checkIn.durationMinutes != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${checkIn.durationMinutes}min',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (checkIn.workoutName != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.dumbbell,
                              size: 12,
                              color: isDark ? AppColors.primaryDark : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                checkIn.workoutName!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      LucideIcons.mapPin,
                      size: 24,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalhes do Check-in',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        Text(
                          _formatDate(checkIn.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(
                icon: LucideIcons.building2,
                label: 'Academia',
                value: checkIn.organizationName,
                isDark: isDark,
              ),
              if (checkIn.workoutName != null)
                _DetailRow(
                  icon: LucideIcons.dumbbell,
                  label: 'Treino',
                  value: checkIn.workoutName!,
                  isDark: isDark,
                ),
              _DetailRow(
                icon: _getSourceIcon(),
                label: 'Check-in via',
                value: _getSourceLabel(),
                isDark: isDark,
              ),
              if (checkIn.trainerName != null)
                _DetailRow(
                  icon: LucideIcons.userCheck,
                  label: 'Confirmado por',
                  value: checkIn.trainerName!,
                  isDark: isDark,
                ),
              if (checkIn.durationMinutes != null)
                _DetailRow(
                  icon: LucideIcons.clock,
                  label: 'Duração',
                  value: '${checkIn.durationMinutes} minutos',
                  isDark: isDark,
                ),
              if (checkIn.pointsEarned != null)
                _DetailRow(
                  icon: LucideIcons.sparkles,
                  label: 'Pontos ganhos',
                  value: '+${checkIn.pointsEarned} pts',
                  isDark: isDark,
                  valueColor: AppColors.warning,
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? (isDark ? AppColors.foregroundDark : AppColors.foreground),
            ),
          ),
        ],
      ),
    );
  }
}
