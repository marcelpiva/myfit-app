import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// A widget that displays exercise stats (sets, reps, rest) in various formats.
///
/// Usage:
/// ```dart
/// ExerciseStatsRow(
///   sets: 3,
///   reps: '10-12',
///   restSeconds: 60,
///   mode: StatsDisplayMode.compact,
/// )
/// ```
class ExerciseStatsRow extends StatelessWidget {
  final int? sets;
  final String? reps;
  final int? restSeconds;
  final int? isometricHold;
  final StatsDisplayMode mode;
  final Color? accentColor;

  const ExerciseStatsRow({
    super.key,
    this.sets,
    this.reps,
    this.restSeconds,
    this.isometricHold,
    this.mode = StatsDisplayMode.compact,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = accentColor ?? theme.colorScheme.primary;

    return switch (mode) {
      StatsDisplayMode.compact => _buildCompact(context, isDark, color),
      StatsDisplayMode.detailed => _buildDetailed(context, isDark, color),
      StatsDisplayMode.inline => _buildInline(context, isDark, color),
    };
  }

  Widget _buildCompact(BuildContext context, bool isDark, Color color) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (sets != null)
          _StatChip(
            icon: LucideIcons.layers,
            value: '$sets',
            label: 'sets',
            color: color,
            isDark: isDark,
          ),
        if (reps != null && reps!.isNotEmpty)
          _StatChip(
            icon: LucideIcons.repeat,
            value: reps!,
            label: 'reps',
            color: color,
            isDark: isDark,
          ),
        if (restSeconds != null)
          _StatChip(
            icon: LucideIcons.timer,
            value: _formatRest(restSeconds!),
            label: restSeconds == 0 ? 'sem descanso' : '',
            color: restSeconds == 0 ? Colors.orange : color,
            isDark: isDark,
          ),
        if (isometricHold != null && isometricHold! > 0)
          _StatChip(
            icon: LucideIcons.pause,
            value: '${isometricHold}s',
            label: 'hold',
            color: Colors.teal,
            isDark: isDark,
          ),
      ],
    );
  }

  Widget _buildDetailed(BuildContext context, bool isDark, Color color) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (sets != null)
          _DetailedStat(
            icon: LucideIcons.layers,
            value: '$sets',
            label: 'Series',
            color: color,
            theme: theme,
          ),
        if (reps != null && reps!.isNotEmpty)
          _DetailedStat(
            icon: LucideIcons.repeat,
            value: reps!,
            label: 'Reps',
            color: color,
            theme: theme,
          ),
        if (restSeconds != null)
          _DetailedStat(
            icon: LucideIcons.timer,
            value: _formatRest(restSeconds!),
            label: 'Descanso',
            color: restSeconds == 0 ? Colors.orange : color,
            theme: theme,
          ),
        if (isometricHold != null && isometricHold! > 0)
          _DetailedStat(
            icon: LucideIcons.pause,
            value: '${isometricHold}s',
            label: 'Hold',
            color: Colors.teal,
            theme: theme,
          ),
      ],
    );
  }

  Widget _buildInline(BuildContext context, bool isDark, Color color) {
    final theme = Theme.of(context);
    final parts = <String>[];

    if (sets != null) parts.add('$sets sets');
    if (reps != null && reps!.isNotEmpty) parts.add('$reps reps');
    if (restSeconds != null) {
      parts.add(restSeconds == 0 ? 'sem descanso' : '${_formatRest(restSeconds!)} descanso');
    }
    if (isometricHold != null && isometricHold! > 0) {
      parts.add('${isometricHold}s hold');
    }

    return Text(
      parts.join(' • '),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  String _formatRest(int seconds) {
    if (seconds == 0) return '0s';
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) return '${minutes}m';
    return '${minutes}m${remainingSeconds}s';
  }
}

/// Display mode for exercise stats.
enum StatsDisplayMode {
  /// Compact chips in a row (wizard style)
  compact,

  /// Detailed columns (active workout style)
  detailed,

  /// Simple inline text (workout detail style)
  inline,
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.withValues(alpha: 0.8)),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailedStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final ThemeData theme;

  const _DetailedStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
