import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/trainer_service.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Provider for student workout sessions
final studentSessionsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, studentUserId) async {
  final service = TrainerService();
  // Get student's workouts which include session info
  final workouts = await service.getStudentWorkouts(studentUserId);
  return workouts;
});

/// Filter period options
enum SessionFilterPeriod {
  all('Todos', null),
  week('7 dias', 7),
  month('30 dias', 30),
  quarter('90 dias', 90);

  final String label;
  final int? days;
  const SessionFilterPeriod(this.label, this.days);
}

/// Tab showing student's workout session history
class StudentSessionsTab extends ConsumerStatefulWidget {
  final String studentUserId;
  final String studentName;

  const StudentSessionsTab({
    super.key,
    required this.studentUserId,
    required this.studentName,
  });

  @override
  ConsumerState<StudentSessionsTab> createState() => _StudentSessionsTabState();
}

class _StudentSessionsTabState extends ConsumerState<StudentSessionsTab> {
  SessionFilterPeriod _selectedPeriod = SessionFilterPeriod.all;
  String? _selectedStatus;

  List<Map<String, dynamic>> _filterSessions(List<Map<String, dynamic>> sessions) {
    var filtered = sessions;

    // Filter by period
    if (_selectedPeriod.days != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: _selectedPeriod.days!));
      filtered = filtered.where((s) {
        final dateStr = s['completed_at'] as String? ??
            s['started_at'] as String? ??
            s['created_at'] as String?;
        if (dateStr == null) return false;
        final date = DateTime.tryParse(dateStr);
        return date != null && date.isAfter(cutoffDate);
      }).toList();
    }

    // Filter by status
    if (_selectedStatus != null) {
      filtered = filtered.where((s) => s['status'] == _selectedStatus).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sessionsAsync = ref.watch(studentSessionsProvider(widget.studentUserId));

    return sessionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, theme, isDark),
      data: (sessions) {
        if (sessions.isEmpty) {
          return _buildEmptyState(theme, isDark);
        }
        final filteredSessions = _filterSessions(sessions);
        return _buildSessionsList(context, theme, isDark, sessions, filteredSessions);
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    bool isDark,
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
              'Erro ao carregar sessões',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => ref.invalidate(studentSessionsProvider(widget.studentUserId)),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.dumbbell,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum treino realizado',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.studentName} ainda não realizou nenhuma sessão de treino',
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
    );
  }

  Widget _buildSessionsList(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    List<Map<String, dynamic>> allSessions,
    List<Map<String, dynamic>> filteredSessions,
  ) {
    // Group filtered sessions by month
    final groupedSessions = <String, List<Map<String, dynamic>>>{};
    for (final session in filteredSessions) {
      final dateStr = session['completed_at'] as String? ??
          session['started_at'] as String? ??
          session['created_at'] as String?;
      if (dateStr != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          final monthKey = _formatMonthYear(date);
          groupedSessions.putIfAbsent(monthKey, () => []).add(session);
        }
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        HapticUtils.lightImpact();
        ref.invalidate(studentSessionsProvider(widget.studentUserId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards (use all sessions for stats)
            _buildSummaryCards(theme, isDark, allSessions),
            const SizedBox(height: 16),

            // Filter chips
            _buildFilterChips(theme, isDark),
            const SizedBox(height: 16),

            // Sessions list header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Histórico de Sessões',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${filteredSessions.length} sessões',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Empty filtered state
            if (filteredSessions.isEmpty)
              _buildNoResultsState(theme, isDark)
            else if (groupedSessions.isEmpty)
              ...filteredSessions.map((s) => _buildSessionCard(theme, isDark, s))
            else
              ...groupedSessions.entries.map((entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          entry.key,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...entry.value.map((s) => _buildSessionCard(theme, isDark, s)),
                      const SizedBox(height: 16),
                    ],
                  )),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: SessionFilterPeriod.values.map((period) {
              final isSelected = _selectedPeriod == period;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(period.label),
                  selected: isSelected,
                  onSelected: (selected) {
                    HapticUtils.selectionClick();
                    setState(() => _selectedPeriod = period);
                  },
                  selectedColor: AppColors.primary.withAlpha(isDark ? 50 : 40),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.border),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Status filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatusChip(theme, isDark, null, 'Todos os status'),
              _buildStatusChip(theme, isDark, 'completed', 'Concluídos'),
              _buildStatusChip(theme, isDark, 'in_progress', 'Em andamento'),
              _buildStatusChip(theme, isDark, 'pending', 'Pendentes'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(
    ThemeData theme,
    bool isDark,
    String? status,
    String label,
  ) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          HapticUtils.selectionClick();
          setState(() => _selectedStatus = selected ? status : null);
        },
        selectedColor: AppColors.secondary.withAlpha(isDark ? 50 : 40),
        checkmarkColor: AppColors.secondary,
        labelStyle: TextStyle(
          color: isSelected
              ? AppColors.secondary
              : (isDark ? AppColors.foregroundDark : AppColors.foreground),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
        side: BorderSide(
          color: isSelected
              ? AppColors.secondary
              : (isDark ? AppColors.borderDark : AppColors.border),
        ),
      ),
    );
  }

  Widget _buildNoResultsState(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.searchX,
              size: 48,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma sessão encontrada',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                HapticUtils.lightImpact();
                setState(() {
                  _selectedPeriod = SessionFilterPeriod.all;
                  _selectedStatus = null;
                });
              },
              child: const Text('Limpar filtros'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    ThemeData theme,
    bool isDark,
    List<Map<String, dynamic>> sessions,
  ) {
    // Calculate stats
    final totalSessions = sessions.length;
    final completedSessions =
        sessions.where((s) => s['status'] == 'completed').length;

    // Calculate this week's sessions
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekSessions = sessions.where((s) {
      final dateStr = s['completed_at'] as String? ?? s['created_at'] as String?;
      if (dateStr == null) return false;
      final date = DateTime.tryParse(dateStr);
      return date != null && date.isAfter(weekStart);
    }).length;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: LucideIcons.activity,
            iconColor: AppColors.primary,
            value: '$totalSessions',
            label: 'Total de Sessões',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: LucideIcons.checkCircle,
            iconColor: AppColors.success,
            value: '$completedSessions',
            label: 'Concluídas',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: LucideIcons.calendar,
            iconColor: AppColors.info,
            value: '$thisWeekSessions',
            label: 'Esta Semana',
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> session,
  ) {
    final workoutName = session['workout_name'] as String? ??
        session['name'] as String? ??
        'Treino';
    final status = session['status'] as String? ?? 'pending';
    final durationMin = session['duration_min'] as int?;
    final dateStr = session['completed_at'] as String? ??
        session['started_at'] as String? ??
        session['created_at'] as String?;
    final rating = session['rating'] as int?;
    final perceivedExertion = session['perceived_exertion'] as int?;

    final statusConfig = _getStatusConfig(status);
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusConfig.color.withAlpha(isDark ? 30 : 20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              statusConfig.icon,
              size: 20,
              color: statusConfig.color,
            ),
          ),
          const SizedBox(width: 12),

          // Workout info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workoutName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusConfig.color.withAlpha(isDark ? 30 : 20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusConfig.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: statusConfig.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (durationMin != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.clock,
                        size: 12,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${durationMin}min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                    if (rating != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.star,
                        size: 12,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$rating',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                    if (perceivedExertion != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.gauge,
                        size: 12,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'RPE $perceivedExertion',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Date
          if (date != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
                Text(
                  _formatTime(date),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  ({IconData icon, Color color, String label}) _getStatusConfig(String status) {
    switch (status) {
      case 'completed':
        return (
          icon: LucideIcons.checkCircle,
          color: AppColors.success,
          label: 'Concluído',
        );
      case 'in_progress':
        return (
          icon: LucideIcons.playCircle,
          color: AppColors.warning,
          label: 'Em andamento',
        );
      case 'skipped':
        return (
          icon: LucideIcons.skipForward,
          color: AppColors.mutedForeground,
          label: 'Pulado',
        );
      default:
        return (
          icon: LucideIcons.circle,
          color: AppColors.info,
          label: 'Pendente',
        );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril',
      'Maio', 'Junho', 'Julho', 'Agosto',
      'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDark;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
