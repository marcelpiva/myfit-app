import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

/// A reusable card container for onboarding steps
class OnboardingStepCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? maxWidth;
  final bool showShadow;

  const OnboardingStepCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth = 500,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        constraints: maxWidth != null ? BoxConstraints(maxWidth: maxWidth!) : null,
        margin: margin ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppColors.primary).withAlpha(15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Header widget for onboarding steps with icon and title
class OnboardingStepHeader extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const OnboardingStepHeader({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = iconColor ?? AppColors.primary;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withAlpha(isDark ? 30 : 20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Section title within onboarding steps
class OnboardingSectionTitle extends StatelessWidget {
  final String title;
  final String? badge;
  final Color? badgeColor;

  const OnboardingSectionTitle({
    super.key,
    required this.title,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppColors.info).withAlpha(isDark ? 30 : 20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: badgeColor ?? AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Action buttons for onboarding steps
class OnboardingStepActions extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final String? backLabel;
  final bool isLoading;
  final bool showBack;

  const OnboardingStepActions({
    super.key,
    this.onBack,
    this.onNext,
    this.nextLabel = 'Continuar',
    this.backLabel = 'Voltar',
    this.isLoading = false,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          if (showBack && onBack != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(backLabel ?? 'Voltar'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: showBack ? 2 : 1,
            child: FilledButton(
              onPressed: isLoading ? null : onNext,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(nextLabel),
            ),
          ),
        ],
      ),
    );
  }
}
