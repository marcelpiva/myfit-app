import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/tokens/exercise_theme.dart';
import '../../../../features/workout_program/domain/models/workout_program.dart';

/// A widget that displays the configuration of single-exercise techniques
/// (dropset, rest-pause, cluster).
///
/// Usage:
/// ```dart
/// TechniqueConfigDisplay(
///   techniqueType: TechniqueType.dropset,
///   numberOfDrops: 3,
///   restBetweenDrops: 0,
/// )
/// ```
class TechniqueConfigDisplay extends StatelessWidget {
  final TechniqueType techniqueType;
  final int? numberOfDrops;
  final int? restBetweenDrops;
  final int? restPauseDuration;
  final int? clusterMiniSets;
  final int? restBetweenClusters;
  final TechniqueConfigSize size;

  const TechniqueConfigDisplay({
    super.key,
    required this.techniqueType,
    this.numberOfDrops,
    this.restBetweenDrops,
    this.restPauseDuration,
    this.clusterMiniSets,
    this.restBetweenClusters,
    this.size = TechniqueConfigSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configText = ExerciseTheme.getTechniqueConfigDisplay(
      techniqueType: techniqueType,
      numberOfDrops: numberOfDrops,
      restBetweenDrops: restBetweenDrops,
      restPauseDuration: restPauseDuration,
      clusterMiniSets: clusterMiniSets,
      restBetweenClusters: restBetweenClusters,
    );

    if (configText == null) return const SizedBox.shrink();

    final color = ExerciseTheme.getColor(techniqueType);
    final icon = _getConfigIcon();

    final iconSize = switch (size) {
      TechniqueConfigSize.small => 12.0,
      TechniqueConfigSize.medium => 14.0,
      TechniqueConfigSize.large => 16.0,
    };

    final fontSize = switch (size) {
      TechniqueConfigSize.small => 10.0,
      TechniqueConfigSize.medium => 11.0,
      TechniqueConfigSize.large => 12.0,
    };

    final padding = switch (size) {
      TechniqueConfigSize.small => const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      TechniqueConfigSize.medium => const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      TechniqueConfigSize.large => const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    };

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color.withValues(alpha: 0.7)),
          const SizedBox(width: 4),
          Text(
            configText,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: fontSize,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getConfigIcon() {
    return switch (techniqueType) {
      TechniqueType.dropset => LucideIcons.arrowDown,
      TechniqueType.restPause => LucideIcons.pause,
      TechniqueType.cluster => LucideIcons.boxes,
      _ => LucideIcons.settings,
    };
  }
}

/// Size variants for the technique config display.
enum TechniqueConfigSize { small, medium, large }
