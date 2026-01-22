import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/personal_record.dart';
import '../providers/personal_record_provider.dart';

/// Bottom sheet showing detailed PR history for a specific exercise
class ExerciseHistorySheet extends ConsumerWidget {
  final String exerciseId;
  final String exerciseName;
  final bool isDark;

  const ExerciseHistorySheet({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.isDark,
  });

  static Future<void> show(
    BuildContext context, {
    required String exerciseId,
    required String exerciseName,
    required bool isDark,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => ExerciseHistorySheet(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          isDark: isDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(exercisePRDetailProvider(exerciseId));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.dumbbell,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Histórico de PRs',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticUtils.lightImpact();
                  ref.read(exercisePRDetailProvider(exerciseId).notifier).refresh();
                },
                icon: Icon(
                  LucideIcons.refreshCw,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Content
          if (state.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (state.error != null)
            Expanded(
              child: _ErrorView(
                error: state.error!,
                onRetry: () => ref
                    .read(exercisePRDetailProvider(exerciseId).notifier)
                    .refresh(),
                isDark: isDark,
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current PRs summary
                    if (state.summary != null) ...[
                      _CurrentPRsSection(
                        summary: state.summary!,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // PR History
                    if (state.history.isNotEmpty) ...[
                      Text(
                        'Histórico',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PRHistoryList(
                        records: state.history,
                        isDark: isDark,
                      ),
                    ] else
                      _EmptyHistoryView(isDark: isDark),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Current PRs section
class _CurrentPRsSection extends StatelessWidget {
  final ExercisePRSummary summary;
  final bool isDark;

  const _CurrentPRsSection({
    required this.summary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(isDark ? 30 : 20),
            AppColors.accent.withAlpha(isDark ? 25 : 15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withAlpha(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.trophy,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              Text(
                'PRs Atuais',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (summary.prMaxWeight != null)
                Expanded(
                  child: _PRStat(
                    label: 'Carga Máxima',
                    value: '${summary.prMaxWeight!.toStringAsFixed(1)} kg',
                    subValue: summary.prMaxWeightReps != null
                        ? '${summary.prMaxWeightReps} reps'
                        : null,
                    date: summary.prMaxWeightDate,
                    isDark: isDark,
                  ),
                ),
              if (summary.prMaxWeight != null && summary.prEstimated1RM != null)
                const SizedBox(width: 12),
              if (summary.prEstimated1RM != null)
                Expanded(
                  child: _PRStat(
                    label: '1RM Estimado',
                    value: '${summary.prEstimated1RM!.toStringAsFixed(1)} kg',
                    date: summary.prEstimated1RMDate,
                    isDark: isDark,
                  ),
                ),
            ],
          ),
          if (summary.prMaxReps != null || summary.prMaxVolume != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (summary.prMaxReps != null)
                  Expanded(
                    child: _PRStat(
                      label: 'Máx. Repetições',
                      value: '${summary.prMaxReps} reps',
                      subValue: summary.prMaxRepsWeight != null
                          ? '${summary.prMaxRepsWeight!.toStringAsFixed(1)} kg'
                          : null,
                      date: summary.prMaxRepsDate,
                      isDark: isDark,
                    ),
                  ),
                if (summary.prMaxReps != null && summary.prMaxVolume != null)
                  const SizedBox(width: 12),
                if (summary.prMaxVolume != null)
                  Expanded(
                    child: _PRStat(
                      label: 'Volume Máximo',
                      value: '${summary.prMaxVolume!.toStringAsFixed(0)} kg',
                      date: summary.prMaxVolumeDate,
                      isDark: isDark,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual PR stat
class _PRStat extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final DateTime? date;
  final bool isDark;

  const _PRStat({
    required this.label,
    required this.value,
    this.subValue,
    this.date,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withAlpha(80)
            : AppColors.background.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (date != null) ...[
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy').format(date!),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// PR history list
class _PRHistoryList extends StatelessWidget {
  final List<PersonalRecord> records;
  final bool isDark;

  const _PRHistoryList({
    required this.records,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final record = records[index];
        return _PRHistoryItem(
          record: record,
          isDark: isDark,
        );
      },
    );
  }
}

/// Individual PR history item
class _PRHistoryItem extends StatelessWidget {
  final PersonalRecord record;
  final bool isDark;

  const _PRHistoryItem({
    required this.record,
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
          // Date column
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd').format(record.achievedAt),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(record.achievedAt).toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Type and value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(record.type).withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    record.type.displayName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getTypeColor(record.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.formattedValue,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Improvement
          if (record.improvementPercent != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(20),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.trendingUp,
                    size: 12,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${record.improvementPercent!.toStringAsFixed(1)}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getTypeColor(PRType type) {
    switch (type) {
      case PRType.maxWeight:
        return AppColors.warning;
      case PRType.maxReps:
        return AppColors.success;
      case PRType.maxVolume:
        return AppColors.accent;
      case PRType.estimated1RM:
        return AppColors.primary;
    }
  }
}

/// Error view
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final bool isDark;

  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 48,
            color: AppColors.destructive,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

/// Empty history view
class _EmptyHistoryView extends StatelessWidget {
  final bool isDark;

  const _EmptyHistoryView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            LucideIcons.trophy,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum PR registrado',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Continue treinando para registrar seus primeiros PRs neste exercício!',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
