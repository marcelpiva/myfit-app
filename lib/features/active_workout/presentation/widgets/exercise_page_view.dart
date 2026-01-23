import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Page indicator dots for exercise navigation
class ExercisePageIndicator extends StatelessWidget {
  final int totalExercises;
  final int currentIndex;
  final List<int> completedExerciseIndices;
  final bool isDark;

  const ExercisePageIndicator({
    super.key,
    required this.totalExercises,
    required this.currentIndex,
    this.completedExerciseIndices = const [],
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If too many exercises, don't show dots (ExerciseNavigationArrows already shows the count)
    if (totalExercises > 10) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalExercises, (index) {
        final isCompleted = completedExerciseIndices.contains(index);
        final isCurrent = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isCurrent ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success
                : isCurrent
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.mutedDark.withAlpha(150)
                        : AppColors.muted),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildCompactIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${currentIndex + 1} / $totalExercises',
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Swipe navigation wrapper for exercises with page view
class ExercisePageViewWrapper extends StatefulWidget {
  final int totalExercises;
  final int initialIndex;
  final ValueChanged<int> onPageChanged;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final bool isDark;

  const ExercisePageViewWrapper({
    super.key,
    required this.totalExercises,
    required this.initialIndex,
    required this.onPageChanged,
    required this.itemBuilder,
    this.isDark = false,
  });

  @override
  State<ExercisePageViewWrapper> createState() => _ExercisePageViewWrapperState();
}

class _ExercisePageViewWrapperState extends State<ExercisePageViewWrapper> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 1.0,
    );
  }

  @override
  void didUpdateWidget(ExercisePageViewWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _pageController.animateToPage(
        widget.initialIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.totalExercises,
      onPageChanged: (index) {
        HapticUtils.selectionClick();
        widget.onPageChanged(index);
      },
      itemBuilder: widget.itemBuilder,
    );
  }
}

/// Navigation arrows for exercise navigation (alternative to swipe)
class ExerciseNavigationArrows extends StatelessWidget {
  final int currentIndex;
  final int totalExercises;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool isDark;

  const ExerciseNavigationArrows({
    super.key,
    required this.currentIndex,
    required this.totalExercises,
    this.onPrevious,
    this.onNext,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canGoPrevious = currentIndex > 0;
    final canGoNext = currentIndex < totalExercises - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous button
        _NavigationButton(
          icon: Icons.chevron_left_rounded,
          label: 'Anterior',
          onTap: canGoPrevious ? onPrevious : null,
          isDark: isDark,
          isLeading: true,
        ),

        // Current position
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardDark.withAlpha(150)
                : AppColors.card.withAlpha(200),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Text(
            '${currentIndex + 1} de $totalExercises',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Next button
        _NavigationButton(
          icon: Icons.chevron_right_rounded,
          label: 'Próximo',
          onTap: canGoNext ? onNext : null,
          isDark: isDark,
          isLeading: false,
        ),
      ],
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDark;
  final bool isLeading;

  const _NavigationButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.isLeading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticUtils.lightImpact();
          onTap!();
        }
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isEnabled
                ? (isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLeading) Icon(icon, size: 20),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isEnabled
                      ? (isDark ? AppColors.primaryDark : AppColors.primary)
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (!isLeading) Icon(icon, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mini exercise preview strip (shows nearby exercises)
class ExercisePreviewStrip extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const ExercisePreviewStrip({
    super.key,
    required this.exercises,
    required this.currentIndex,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show 3 exercises: previous, current, next (if available)
    final startIndex = (currentIndex - 1).clamp(0, exercises.length - 1);
    final endIndex = (currentIndex + 2).clamp(0, exercises.length);

    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: endIndex - startIndex,
        itemBuilder: (context, index) {
          final actualIndex = startIndex + index;
          final exercise = exercises[actualIndex];
          final isCurrent = actualIndex == currentIndex;
          final name = exercise['name'] ?? exercise['exercise_name'] ?? 'Exercício';

          return GestureDetector(
            onTap: () {
              HapticUtils.selectionClick();
              onTap(actualIndex);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primary.withAlpha(30)
                    : (isDark
                        ? AppColors.cardDark.withAlpha(100)
                        : AppColors.card.withAlpha(150)),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.primary
                      : (isDark ? AppColors.borderDark : AppColors.border),
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.mutedDark
                              : AppColors.muted),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${actualIndex + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCurrent
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: Text(
                      name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                        color: isCurrent
                            ? (isDark ? AppColors.primaryDark : AppColors.primary)
                            : theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
