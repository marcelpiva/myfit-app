import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

/// A styled checkbox that follows the myfitplatform design system.
///
/// Features:
/// - Zero border radius (square design)
/// - Custom colors for checked/unchecked states
/// - Optional label widget
class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? label;
  final bool enabled;

  const AppCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value
                  ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                  : Colors.transparent,
              border: Border.all(
                color: value
                    ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                    : (isDark ? AppColors.borderDark : AppColors.border),
                width: 1.5,
              ),
            ),
            child: value
                ? Icon(
                    Icons.check,
                    size: 14,
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.background,
                  )
                : null,
          ),
          if (label != null) ...[
            const SizedBox(width: 12),
            Flexible(child: label!),
          ],
        ],
      ),
    );
  }
}
