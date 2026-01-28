import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../config/theme/app_colors.dart';

/// Banner informing student that their organization/trainer is no longer available
class ArchivedOrganizationBanner extends StatelessWidget {
  final String? organizationName;
  final bool isDark;

  const ArchivedOrganizationBanner({
    super.key,
    this.organizationName,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(isDark ? 30 : 20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withAlpha(isDark ? 60 : 50),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              LucideIcons.archive,
              size: 22,
              color: AppColors.warning,
            ),
          ),

          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Indisponível',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  organizationName != null
                      ? '$organizationName encerrou as atividades. Você ainda pode ver seu histórico de treinos.'
                      : 'Seu personal encerrou as atividades. Você ainda pode ver seu histórico de treinos.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact version of the banner for smaller spaces
class ArchivedOrganizationBannerCompact extends StatelessWidget {
  final bool isDark;

  const ArchivedOrganizationBannerCompact({
    super.key,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(isDark ? 30 : 20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.warning.withAlpha(isDark ? 60 : 50),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.archive,
            size: 14,
            color: AppColors.warning,
          ),
          const SizedBox(width: 6),
          Text(
            'Personal Indisponível',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
