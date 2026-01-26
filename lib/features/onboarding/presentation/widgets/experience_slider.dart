import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Custom slider for selecting years of experience
class ExperienceSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const ExperienceSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 30,
  });

  String get _experienceLabel {
    if (value <= 2) return 'Iniciante';
    if (value <= 5) return 'Intermediário';
    if (value <= 10) return 'Experiente';
    return 'Expert';
  }

  Color get _experienceColor {
    if (value <= 2) return AppColors.info;
    if (value <= 5) return AppColors.success;
    if (value <= 10) return AppColors.warning;
    return AppColors.primary;
  }

  IconData get _experienceIcon {
    if (value <= 2) return LucideIcons.sprout;
    if (value <= 5) return LucideIcons.leaf;
    if (value <= 10) return LucideIcons.treeDeciduous;
    return LucideIcons.crown;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Value display
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _experienceColor.withAlpha(isDark ? 30 : 20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _experienceColor.withAlpha(60),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _experienceIcon,
                  key: ValueKey(_experienceIcon),
                  size: 28,
                  color: _experienceColor,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value ${value == 1 ? 'ano' : 'anos'} de experiência',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _experienceLabel,
                      key: ValueKey(_experienceLabel),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _experienceColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Slider
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _experienceColor,
            inactiveTrackColor: isDark ? AppColors.mutedDark : AppColors.muted,
            thumbColor: _experienceColor,
            overlayColor: _experienceColor.withAlpha(30),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 14,
              elevation: 4,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2),
            activeTickMarkColor: Colors.white.withAlpha(100),
            inactiveTickMarkColor: isDark
                ? AppColors.mutedForegroundDark.withAlpha(50)
                : AppColors.mutedForeground.withAlpha(50),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (newValue) {
              if (newValue.toInt() != value) {
                HapticUtils.selectionClick();
              }
              onChanged(newValue.toInt());
            },
          ),
        ),
        // Labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$min ano',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
              Text(
                '$max+ anos',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Quick select buttons for common experience values
class ExperienceQuickSelect extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;

  const ExperienceQuickSelect({
    super.key,
    this.value,
    required this.onChanged,
  });

  static const _quickOptions = [1, 3, 5, 10, 15, 20];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _quickOptions.map((years) {
        final isSelected = value == years;
        return GestureDetector(
          onTap: () {
            HapticUtils.selectionClick();
            onChanged(years);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.cardDark : AppColors.card),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.borderDark : AppColors.border),
              ),
            ),
            child: Text(
              '$years ${years == 1 ? 'ano' : 'anos'}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
