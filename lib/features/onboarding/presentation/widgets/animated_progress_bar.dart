import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

/// Animated progress bar for onboarding steps
class AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;
  final Duration animationDuration;
  final double height;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
    this.animationDuration = const Duration(milliseconds: 300),
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Step indicators
        if (stepLabels != null && stepLabels!.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;
              return _StepIndicator(
                index: index + 1,
                label: index < stepLabels!.length ? stepLabels![index] : '',
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isDark: isDark,
              );
            }),
          ),
          const SizedBox(height: 12),
        ],
        // Progress bar
        Container(
          height: height,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.mutedDark
                : AppColors.muted,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: animationDuration,
                    curve: Curves.easeInOut,
                    width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withAlpha(200),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(height / 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(40),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // Progress text
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Passo ${currentStep + 1} de $totalSteps',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int index;
  final String label;
  final bool isCompleted;
  final bool isCurrent;
  final bool isDark;

  const _StepIndicator({
    required this.index,
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppColors.success
                  : isCurrent
                      ? AppColors.primary
                      : (isDark ? AppColors.mutedDark : AppColors.muted),
              border: isCurrent
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : Text(
                      '$index',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCurrent
                            ? Colors.white
                            : (isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground),
                      ),
                    ),
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isCurrent || isCompleted
                    ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                    : (isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground),
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple linear progress indicator for compact displays
class SimpleProgressIndicator extends StatelessWidget {
  final double progress;
  final double height;

  const SimpleProgressIndicator({
    super.key,
    required this.progress,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.mutedDark : AppColors.muted,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: constraints.maxWidth * progress.clamp(0.0, 1.0),
            height: height,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          );
        },
      ),
    );
  }
}
