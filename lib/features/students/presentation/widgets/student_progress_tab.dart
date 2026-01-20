import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/trainer_service.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'progress_photo_gallery.dart';

/// Provider for student progress data
final studentProgressProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, studentUserId) async {
  final service = TrainerService();
  final progress = await service.getStudentProgress(studentUserId);
  return progress;
});

/// Provider for student stats
final studentStatsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, studentUserId) async {
  final service = TrainerService();
  final stats = await service.getStudentStats(studentUserId, days: 90);
  return stats;
});

/// Tab showing student's progress metrics and evolution
class StudentProgressTab extends ConsumerWidget {
  final String studentUserId;
  final String studentName;

  const StudentProgressTab({
    super.key,
    required this.studentUserId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progressAsync = ref.watch(studentProgressProvider(studentUserId));
    final statsAsync = ref.watch(studentStatsProvider(studentUserId));

    return progressAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, ref, theme, isDark),
      data: (progress) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats summary
              statsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
                data: (stats) => _buildStatsSummary(theme, isDark, stats),
              ),

              const SizedBox(height: 24),

              // Weight section
              _buildWeightSection(context, theme, isDark, progress),

              const SizedBox(height: 24),

              // Measurements section
              _buildMeasurementsSection(context, theme, isDark, progress),

              const SizedBox(height: 24),

              // Photos section
              _buildPhotosSection(context, theme, isDark, progress),

              const SizedBox(height: 24),

              // PRs section
              _buildPRsSection(context, theme, isDark, progress),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
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
              'Erro ao carregar progresso',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                ref.invalidate(studentProgressProvider(studentUserId));
                ref.invalidate(studentStatsProvider(studentUserId));
              },
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> stats,
  ) {
    final workoutsCompleted = stats['workouts_completed'] as int? ?? 0;
    final totalVolume = stats['total_volume'] as num? ?? 0;
    final avgDuration = stats['avg_duration_min'] as num? ?? 0;
    final consistency = stats['consistency_percentage'] as num? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo dos Últimos 90 Dias',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: LucideIcons.checkCircle,
                iconColor: AppColors.success,
                value: '$workoutsCompleted',
                label: 'Treinos',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: LucideIcons.gauge,
                iconColor: AppColors.primary,
                value: '${totalVolume.toStringAsFixed(0)}kg',
                label: 'Volume Total',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: LucideIcons.clock,
                iconColor: AppColors.info,
                value: '${avgDuration.toStringAsFixed(0)}min',
                label: 'Média/Treino',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: LucideIcons.flame,
                iconColor: AppColors.warning,
                value: '${consistency.toStringAsFixed(0)}%',
                label: 'Consistência',
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeightSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> progress,
  ) {
    final weightLogs =
        (progress['weight_logs'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final latestWeight = progress['latest_weight'] as Map<String, dynamic>?;
    final weightGoal = progress['weight_goal'] as Map<String, dynamic>?;

    final currentWeight = latestWeight?['weight_kg'] as num?;
    final targetWeight = weightGoal?['target_weight_kg'] as num?;

    // Calculate change
    num? weightChange;
    if (weightLogs.length >= 2) {
      final firstWeight = weightLogs.last['weight_kg'] as num?;
      final lastWeight = weightLogs.first['weight_kg'] as num?;
      if (firstWeight != null && lastWeight != null) {
        weightChange = lastWeight - firstWeight;
      }
    }

    return _ProgressSection(
      title: 'Peso',
      icon: LucideIcons.scale,
      iconColor: AppColors.primary,
      isDark: isDark,
      content: Column(
        children: [
          if (currentWeight != null || targetWeight != null)
            Row(
              children: [
                if (currentWeight != null)
                  Expanded(
                    child: _MetricCard(
                      label: 'Atual',
                      value: '${currentWeight.toStringAsFixed(1)} kg',
                      isDark: isDark,
                    ),
                  ),
                if (currentWeight != null && targetWeight != null)
                  const SizedBox(width: 12),
                if (targetWeight != null)
                  Expanded(
                    child: _MetricCard(
                      label: 'Meta',
                      value: '${targetWeight.toStringAsFixed(1)} kg',
                      isDark: isDark,
                    ),
                  ),
                if (weightChange != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Variação',
                      value:
                          '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg',
                      valueColor:
                          weightChange >= 0 ? AppColors.success : AppColors.info,
                      isDark: isDark,
                    ),
                  ),
                ],
              ],
            )
          else
            _buildNoDataMessage(theme, isDark, 'Nenhum registro de peso'),

          if (weightLogs.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSimpleChart(theme, isDark, weightLogs, 'weight_kg'),
          ],
        ],
      ),
    );
  }

  Widget _buildMeasurementsSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> progress,
  ) {
    final latestMeasurements =
        progress['latest_measurements'] as Map<String, dynamic>?;

    final measurements = <(String, num?)>[
      ('Peito', latestMeasurements?['chest_cm'] as num?),
      ('Cintura', latestMeasurements?['waist_cm'] as num?),
      ('Quadril', latestMeasurements?['hips_cm'] as num?),
      ('Bíceps', latestMeasurements?['biceps_cm'] as num?),
      ('Coxa', latestMeasurements?['thigh_cm'] as num?),
      ('Panturrilha', latestMeasurements?['calf_cm'] as num?),
    ];

    final hasData = measurements.any((m) => m.$2 != null);

    return _ProgressSection(
      title: 'Medidas Corporais',
      icon: LucideIcons.ruler,
      iconColor: AppColors.secondary,
      isDark: isDark,
      content: hasData
          ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children: measurements
                  .where((m) => m.$2 != null)
                  .map((m) => _MeasurementChip(
                        label: m.$1,
                        value: '${m.$2!.toStringAsFixed(1)} cm',
                        isDark: isDark,
                      ))
                  .toList(),
            )
          : _buildNoDataMessage(theme, isDark, 'Nenhuma medida registrada'),
    );
  }

  Widget _buildPhotosSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> progress,
  ) {
    final photos =
        (progress['photos'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return _ProgressSection(
      title: 'Fotos de Progresso',
      icon: LucideIcons.camera,
      iconColor: AppColors.info,
      isDark: isDark,
      trailing: photos.isNotEmpty
          ? TextButton(
              onPressed: () {
                HapticUtils.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProgressPhotoGallery(
                      photos: photos,
                      studentName: studentName,
                    ),
                  ),
                );
              },
              child: const Text('Ver todas'),
            )
          : null,
      content: photos.isNotEmpty
          ? SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length > 6 ? 6 : photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  final url = photo['photo_url'] as String?;
                  final angle = photo['angle'] as String?;
                  final dateStr = photo['logged_at'] as String?;
                  final date =
                      dateStr != null ? DateTime.tryParse(dateStr) : null;

                  return GestureDetector(
                    onTap: () {
                      HapticUtils.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProgressPhotoGallery(
                            photos: photos,
                            initialIndex: index,
                            studentName: studentName,
                          ),
                        ),
                      );
                    },
                    child: Container(
                    width: 100,
                    margin: EdgeInsets.only(right: index < photos.length - 1 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.mutedDark : AppColors.muted,
                      borderRadius: BorderRadius.circular(10),
                      image: url != null
                          ? DecorationImage(
                              image: NetworkImage(url),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: url == null
                        ? Center(
                            child: Icon(
                              LucideIcons.image,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                          )
                        : Stack(
                            children: [
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(150),
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (angle != null)
                                        Text(
                                          _translateAngle(angle),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      if (date != null)
                                        Text(
                                          _formatDate(date),
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Colors.white70,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ),
                  );
                },
              ),
            )
          : _buildNoDataMessage(theme, isDark, 'Nenhuma foto registrada'),
    );
  }

  Widget _buildPRsSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> progress,
  ) {
    final prs =
        (progress['personal_records'] as List?)?.cast<Map<String, dynamic>>() ??
            [];

    return _ProgressSection(
      title: 'Recordes Pessoais (PRs)',
      icon: LucideIcons.trophy,
      iconColor: AppColors.warning,
      isDark: isDark,
      content: prs.isNotEmpty
          ? Column(
              children: prs.take(5).map((pr) {
                final exerciseName =
                    pr['exercise_name'] as String? ?? 'Exercício';
                final weight = pr['weight_kg'] as num?;
                final reps = pr['reps'] as int?;
                final dateStr = pr['achieved_at'] as String?;
                final date =
                    dateStr != null ? DateTime.tryParse(dateStr) : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.mutedDark : AppColors.muted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withAlpha(isDark ? 30 : 20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.trophy,
                          size: 16,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exerciseName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (weight != null || reps != null)
                              Text(
                                [
                                  if (weight != null) '${weight.toStringAsFixed(1)}kg',
                                  if (reps != null) '$reps reps',
                                ].join(' x '),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (date != null)
                        Text(
                          _formatDate(date),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            )
          : _buildNoDataMessage(theme, isDark, 'Nenhum PR registrado'),
    );
  }

  Widget _buildSimpleChart(
    ThemeData theme,
    bool isDark,
    List<Map<String, dynamic>> data,
    String valueKey,
  ) {
    if (data.isEmpty) return const SizedBox.shrink();

    // Get min/max values for scaling
    final values = data
        .map((d) => d[valueKey] as num?)
        .where((v) => v != null)
        .cast<num>()
        .toList();
    if (values.isEmpty) return const SizedBox.shrink();

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    final chartHeight = 60.0;

    // Show only last 10 entries
    final displayData = data.take(10).toList().reversed.toList();

    return Container(
      height: chartHeight + 20,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: displayData.asMap().entries.map((entry) {
          final value = entry.value[valueKey] as num?;
          if (value == null) return const SizedBox(width: 8);

          final normalizedHeight =
              range > 0 ? ((value - minVal) / range) * chartHeight : chartHeight / 2;
          final barHeight = normalizedHeight.clamp(4.0, chartHeight);

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (entry.key == displayData.length - 1)
                    Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: entry.key == displayData.length - 1
                          ? AppColors.primary
                          : AppColors.primary.withAlpha(isDark ? 60 : 40),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNoDataMessage(ThemeData theme, bool isDark, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.mutedDark.withAlpha(50) : AppColors.muted.withAlpha(80),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.info,
            size: 16,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _translateAngle(String angle) {
    switch (angle.toLowerCase()) {
      case 'front':
        return 'Frente';
      case 'back':
        return 'Costas';
      case 'side':
        return 'Lateral';
      case 'left':
        return 'Esquerda';
      case 'right':
        return 'Direita';
      default:
        return angle;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDark;

  const _StatCard({
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              fontSize: 9,
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

class _ProgressSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final Widget content;
  final Widget? trailing;

  const _ProgressSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.content,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(isDark ? 30 : 20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;

  const _MetricCard({
    required this.label,
    required this.value,
    this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.mutedDark : AppColors.muted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _MeasurementChip({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.mutedDark : AppColors.muted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
