import 'package:flutter/material.dart';

import '../../../../config/theme/tokens/exercise_theme.dart';
import '../../../../features/training_plan/domain/models/training_plan.dart';

/// A badge widget that displays the technique type with icon and color.
///
/// Usage:
/// ```dart
/// TechniqueBadge(
///   techniqueType: TechniqueType.superset,
///   size: TechniqueBadgeSize.medium,
/// )
/// ```
class TechniqueBadge extends StatelessWidget {
  final TechniqueType techniqueType;
  final TechniqueBadgeSize size;
  final bool showLabel;
  final bool compact;

  const TechniqueBadge({
    super.key,
    required this.techniqueType,
    this.size = TechniqueBadgeSize.medium,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = ExerciseTheme.getColor(techniqueType);
    final icon = ExerciseTheme.getIcon(techniqueType);
    final label = ExerciseTheme.getDisplayName(techniqueType);

    final iconSize = switch (size) {
      TechniqueBadgeSize.small => 12.0,
      TechniqueBadgeSize.medium => 16.0,
      TechniqueBadgeSize.large => 20.0,
    };

    final fontSize = switch (size) {
      TechniqueBadgeSize.small => 10.0,
      TechniqueBadgeSize.medium => 12.0,
      TechniqueBadgeSize.large => 14.0,
    };

    final padding = switch (size) {
      TechniqueBadgeSize.small => const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      TechniqueBadgeSize.medium => const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      TechniqueBadgeSize.large => const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    };

    if (compact) {
      return Icon(icon, size: iconSize, color: color);
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ExerciseTheme.badgeBorderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          if (showLabel) ...[
            SizedBox(width: size == TechniqueBadgeSize.small ? 4 : 6),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Size variants for the technique badge.
enum TechniqueBadgeSize { small, medium, large }
