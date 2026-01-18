import 'package:flutter/material.dart';

/// A position indicator widget that shows the exercise position within a group.
///
/// Displays a colored circle with a number, optionally showing the total count.
///
/// Usage:
/// ```dart
/// PositionIndicator(
///   position: 1,
///   total: 3,
///   color: Colors.purple,
///   showFraction: true,
/// )
/// ```
class PositionIndicator extends StatelessWidget {
  final int position;
  final int? total;
  final Color color;
  final bool showFraction;
  final PositionIndicatorSize size;
  final bool showConnector;

  const PositionIndicator({
    super.key,
    required this.position,
    this.total,
    required this.color,
    this.showFraction = false,
    this.size = PositionIndicatorSize.medium,
    this.showConnector = false,
  });

  @override
  Widget build(BuildContext context) {
    final circleSize = switch (size) {
      PositionIndicatorSize.small => 18.0,
      PositionIndicatorSize.medium => 22.0,
      PositionIndicatorSize.large => 28.0,
    };

    final fontSize = switch (size) {
      PositionIndicatorSize.small => 10.0,
      PositionIndicatorSize.medium => 12.0,
      PositionIndicatorSize.large => 14.0,
    };

    final displayText = showFraction && total != null
        ? '$position/$total'
        : position.toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              displayText,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        if (showConnector && (total == null || position < total!))
          Container(
            width: 2,
            height: 12,
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }
}

/// Size variants for the position indicator.
enum PositionIndicatorSize { small, medium, large }
