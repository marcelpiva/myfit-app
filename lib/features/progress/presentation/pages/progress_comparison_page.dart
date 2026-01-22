import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../providers/progress_provider.dart';

/// Page for comparing progress between two time periods
class ProgressComparisonPage extends ConsumerStatefulWidget {
  const ProgressComparisonPage({super.key});

  @override
  ConsumerState<ProgressComparisonPage> createState() =>
      _ProgressComparisonPageState();
}

class _ProgressComparisonPageState
    extends ConsumerState<ProgressComparisonPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 90));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.entrance,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progressState = ref.watch(progressProvider);

    // Calculate comparison data
    final weightLogs = progressState.weightLogs;
    final measurementLogs = progressState.measurementLogs;

    // Get weight at start and end of period
    final startWeight = _getWeightAtDate(weightLogs, _startDate);
    final endWeight = _getWeightAtDate(weightLogs, _endDate);
    final weightChange = endWeight != null && startWeight != null
        ? endWeight - startWeight
        : null;

    // Get measurements at start and end
    final startMeasurements = _getMeasurementsAtDate(measurementLogs, _startDate);
    final endMeasurements = _getMeasurementsAtDate(measurementLogs, _endDate);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? AppColors.primaryDark : AppColors.primary)
                  .withAlpha(isDark ? 15 : 10),
              (isDark ? AppColors.secondaryDark : AppColors.secondary)
                  .withAlpha(isDark ? 12 : 8),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticUtils.lightImpact();
                            context.pop();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : AppColors.card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.border,
                              ),
                            ),
                            child: Icon(
                              LucideIcons.arrowLeft,
                              size: 20,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Comparar Progresso',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Date range selector
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _DateRangeSelector(
                      startDate: _startDate,
                      endDate: _endDate,
                      isDark: isDark,
                      onStartDateChanged: (date) {
                        HapticUtils.selectionClick();
                        setState(() => _startDate = date);
                      },
                      onEndDateChanged: (date) {
                        HapticUtils.selectionClick();
                        setState(() => _endDate = date);
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Weight comparison
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _ComparisonCard(
                      title: 'Peso',
                      icon: LucideIcons.scale,
                      iconColor: AppColors.primary,
                      isDark: isDark,
                      startValue: startWeight,
                      endValue: endWeight,
                      change: weightChange,
                      unit: 'kg',
                      startDate: _startDate,
                      endDate: _endDate,
                      isPositiveGood: false, // Weight loss is usually good
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Measurements comparison
                if (endMeasurements.isNotEmpty || startMeasurements.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _MeasurementsComparisonCard(
                        startMeasurements: startMeasurements,
                        endMeasurements: endMeasurements,
                        startDate: _startDate,
                        endDate: _endDate,
                        isDark: isDark,
                      ),
                    ),
                  ),

                // Summary section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _SummaryCard(
                      weightChange: weightChange,
                      startMeasurements: startMeasurements,
                      endMeasurements: endMeasurements,
                      periodDays: _endDate.difference(_startDate).inDays,
                      isDark: isDark,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double? _getWeightAtDate(List<dynamic> logs, DateTime targetDate) {
    if (logs.isEmpty) return null;

    // Find the log closest to the target date
    dynamic closest;
    int minDiff = 999999;

    for (final log in logs) {
      final logDate = log.date as DateTime?;
      if (logDate == null) continue;

      final diff = (logDate.difference(targetDate).inDays).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = log;
      }
    }

    if (closest != null && minDiff <= 7) {
      // Allow up to 7 days difference
      return closest.weight as double?;
    }
    return null;
  }

  Map<String, double> _getMeasurementsAtDate(
      List<dynamic> logs, DateTime targetDate) {
    if (logs.isEmpty) return {};

    // Find the log closest to the target date
    dynamic closest;
    int minDiff = 999999;

    for (final log in logs) {
      final logDate = log.date as DateTime?;
      if (logDate == null) continue;

      final diff = (logDate.difference(targetDate).inDays).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = log;
      }
    }

    if (closest != null && minDiff <= 14) {
      // Allow up to 14 days difference for measurements
      return {
        if (closest.chest != null) 'Peito': closest.chest as double,
        if (closest.waist != null) 'Cintura': closest.waist as double,
        if (closest.hips != null) 'Quadril': closest.hips as double,
        if (closest.leftArm != null) 'Braço E': closest.leftArm as double,
        if (closest.rightArm != null) 'Braço D': closest.rightArm as double,
        if (closest.leftThigh != null) 'Coxa E': closest.leftThigh as double,
        if (closest.rightThigh != null) 'Coxa D': closest.rightThigh as double,
      };
    }
    return {};
  }
}

class _DateRangeSelector extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final bool isDark;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  const _DateRangeSelector({
    required this.startDate,
    required this.endDate,
    required this.isDark,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Período de Comparação',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Início',
                  date: startDate,
                  isDark: isDark,
                  onTap: () => _selectDate(context, startDate, onStartDateChanged),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  LucideIcons.arrowRight,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: _DateButton(
                  label: 'Fim',
                  date: endDate,
                  isDark: isDark,
                  onTap: () => _selectDate(context, endDate, onEndDateChanged),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick range selectors
          Wrap(
            spacing: 8,
            children: [
              _QuickRangeChip(
                label: '30 dias',
                isSelected: endDate.difference(startDate).inDays == 30,
                onTap: () {
                  onStartDateChanged(DateTime.now().subtract(const Duration(days: 30)));
                  onEndDateChanged(DateTime.now());
                },
              ),
              _QuickRangeChip(
                label: '90 dias',
                isSelected: endDate.difference(startDate).inDays == 90,
                onTap: () {
                  onStartDateChanged(DateTime.now().subtract(const Duration(days: 90)));
                  onEndDateChanged(DateTime.now());
                },
              ),
              _QuickRangeChip(
                label: '6 meses',
                isSelected: endDate.difference(startDate).inDays >= 180 &&
                    endDate.difference(startDate).inDays <= 186,
                onTap: () {
                  onStartDateChanged(DateTime.now().subtract(const Duration(days: 183)));
                  onEndDateChanged(DateTime.now());
                },
              ),
              _QuickRangeChip(
                label: '1 ano',
                isSelected: endDate.difference(startDate).inDays >= 360,
                onTap: () {
                  onStartDateChanged(DateTime.now().subtract(const Duration(days: 365)));
                  onEndDateChanged(DateTime.now());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    ValueChanged<DateTime> onChanged,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      onChanged(date);
    }
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isDark;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
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
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('d MMM yyyy', 'pt_BR').format(date),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickRangeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickRangeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : null,
          ),
        ),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final double? startValue;
  final double? endValue;
  final double? change;
  final String unit;
  final DateTime startDate;
  final DateTime endDate;
  final bool isPositiveGood;

  const _ComparisonCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.startValue,
    required this.endValue,
    required this.change,
    required this.unit,
    required this.startDate,
    required this.endDate,
    this.isPositiveGood = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = startValue != null && endValue != null;
    final changeColor = change == null
        ? theme.colorScheme.onSurfaceVariant
        : (isPositiveGood
            ? (change! > 0 ? AppColors.success : AppColors.destructive)
            : (change! < 0 ? AppColors.success : AppColors.destructive));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (!hasData)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Sem dados suficientes para comparação',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else ...[
            // Values row
            Row(
              children: [
                Expanded(
                  child: _ValueColumn(
                    label: DateFormat('d MMM', 'pt_BR').format(startDate),
                    value: '${startValue!.toStringAsFixed(1)} $unit',
                    isDark: isDark,
                  ),
                ),
                // Arrow with change
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Icon(
                        change! > 0 ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                        size: 20,
                        color: changeColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${change! > 0 ? '+' : ''}${change!.toStringAsFixed(1)} $unit',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: changeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _ValueColumn(
                    label: DateFormat('d MMM', 'pt_BR').format(endDate),
                    value: '${endValue!.toStringAsFixed(1)} $unit',
                    isDark: isDark,
                    isEnd: true,
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

class _ValueColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isEnd;

  const _ValueColumn({
    required this.label,
    required this.value,
    required this.isDark,
    this.isEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
      ],
    );
  }
}

class _MeasurementsComparisonCard extends StatelessWidget {
  final Map<String, double> startMeasurements;
  final Map<String, double> endMeasurements;
  final DateTime startDate;
  final DateTime endDate;
  final bool isDark;

  const _MeasurementsComparisonCard({
    required this.startMeasurements,
    required this.endMeasurements,
    required this.startDate,
    required this.endDate,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allKeys = {...startMeasurements.keys, ...endMeasurements.keys};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(LucideIcons.ruler, size: 20, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Text(
                'Medidas',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Table header
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Medida',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  DateFormat('d/M', 'pt_BR').format(startDate),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  DateFormat('d/M', 'pt_BR').format(endDate),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Dif.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          // Rows
          ...allKeys.map((key) {
            final startVal = startMeasurements[key];
            final endVal = endMeasurements[key];
            final diff = startVal != null && endVal != null
                ? endVal - startVal
                : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      key,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      startVal != null ? '${startVal.toStringAsFixed(1)}' : '-',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      endVal != null ? '${endVal.toStringAsFixed(1)}' : '-',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      diff != null
                          ? '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}'
                          : '-',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: diff == null
                            ? theme.colorScheme.onSurfaceVariant
                            : (diff < 0 ? AppColors.success : AppColors.warning),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double? weightChange;
  final Map<String, double> startMeasurements;
  final Map<String, double> endMeasurements;
  final int periodDays;
  final bool isDark;

  const _SummaryCard({
    required this.weightChange,
    required this.startMeasurements,
    required this.endMeasurements,
    required this.periodDays,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate total cm change
    double totalCmChange = 0;
    int measurementCount = 0;
    for (final key in startMeasurements.keys) {
      if (endMeasurements.containsKey(key)) {
        totalCmChange += endMeasurements[key]! - startMeasurements[key]!;
        measurementCount++;
      }
    }

    final hasProgress = weightChange != null || measurementCount > 0;
    final isGoodProgress = (weightChange != null && weightChange! < 0) ||
        (totalCmChange < 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isGoodProgress ? AppColors.success : AppColors.primary)
                .withAlpha(30),
            (isGoodProgress ? AppColors.success : AppColors.primary)
                .withAlpha(10),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isGoodProgress ? AppColors.success : AppColors.primary)
              .withAlpha(50),
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: (isGoodProgress ? AppColors.success : AppColors.primary)
                  .withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isGoodProgress ? LucideIcons.trendingDown : LucideIcons.activity,
              size: 28,
              color: isGoodProgress ? AppColors.success : AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            'Resumo do Período',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '$periodDays dias',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 20),

          if (!hasProgress)
            Text(
              'Adicione mais registros de peso e medidas para ver seu progresso.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            )
          else ...[
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (weightChange != null)
                  _SummaryStat(
                    label: 'Peso',
                    value:
                        '${weightChange! > 0 ? '+' : ''}${weightChange!.toStringAsFixed(1)} kg',
                    isPositive: weightChange! < 0,
                    isDark: isDark,
                  ),
                if (measurementCount > 0)
                  _SummaryStat(
                    label: 'Medidas',
                    value:
                        '${totalCmChange > 0 ? '+' : ''}${totalCmChange.toStringAsFixed(1)} cm',
                    isPositive: totalCmChange < 0,
                    isDark: isDark,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Motivational message
            Text(
              _getMotivationalMessage(weightChange, totalCmChange),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  String _getMotivationalMessage(double? weightChange, double totalCmChange) {
    if (weightChange != null && weightChange < 0) {
      return 'Excelente progresso! Você perdeu peso de forma consistente.';
    } else if (totalCmChange < 0) {
      return 'Suas medidas estão diminuindo. Continue assim!';
    } else if (weightChange != null && weightChange > 0 && totalCmChange < 0) {
      return 'Possivelmente ganhando massa muscular - peso subiu mas medidas diminuíram!';
    } else {
      return 'Continue registrando seu progresso para acompanhar sua evolução.';
    }
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;
  final bool isDark;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.isPositive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
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
            color: isPositive ? AppColors.success : AppColors.warning,
          ),
        ),
      ],
    );
  }
}
