import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../config/theme/app_colors.dart';

/// A badge widget that displays CREF verification status for trainers.
///
/// Shows a verified checkmark icon with "Verificado" text when the trainer
/// has a verified CREF credential.
class VerifiedBadge extends StatelessWidget {
  /// The CREF number to display (e.g., "CREF 012345-G/SP")
  final String? crefNumber;

  /// Whether the CREF is verified
  final bool isVerified;

  /// Size variant: 'small', 'medium', or 'large'
  final String size;

  /// Whether to show the full CREF number or just the badge
  final bool showCrefNumber;

  const VerifiedBadge({
    super.key,
    this.crefNumber,
    this.isVerified = false,
    this.size = 'medium',
    this.showCrefNumber = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Size configurations
    final (iconSize, fontSize, padding) = switch (size) {
      'small' => (12.0, 11.0, const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
      'large' => (18.0, 14.0, const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
      _ => (14.0, 12.0, const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
    };

    // Colors based on verification status
    final Color badgeColor;
    final Color textColor;
    final Color bgColor;

    if (isVerified) {
      badgeColor = AppColors.success;
      textColor = AppColors.success;
      bgColor = AppColors.success.withAlpha(20);
    } else {
      badgeColor = isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground;
      textColor = isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground;
      bgColor = isDark ? AppColors.mutedDark : AppColors.muted;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: isVerified
            ? Border.all(color: badgeColor.withAlpha(50), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? LucideIcons.badgeCheck : LucideIcons.badge,
            size: iconSize,
            color: badgeColor,
          ),
          const SizedBox(width: 6),
          if (showCrefNumber && crefNumber != null && crefNumber!.isNotEmpty) ...[
            Text(
              crefNumber!,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            if (isVerified) ...[
              const SizedBox(width: 6),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor.withAlpha(100),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ],
          Text(
            isVerified ? 'Verificado' : 'Pendente',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact verified badge that only shows the checkmark icon
class VerifiedIcon extends StatelessWidget {
  final bool isVerified;
  final double size;

  const VerifiedIcon({
    super.key,
    this.isVerified = false,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    return Container(
      width: size + 4,
      height: size + 4,
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(20),
        shape: BoxShape.circle,
      ),
      child: Icon(
        LucideIcons.badgeCheck,
        size: size,
        color: AppColors.success,
      ),
    );
  }
}
