import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../config/routes/route_names.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/haptic_utils.dart';

/// Banner informing student that their workouts are managed by their Personal trainer
class TrainerManagedBanner extends StatelessWidget {
  final String? trainerName;
  final bool showChatButton;
  final bool isDark;

  const TrainerManagedBanner({
    super.key,
    this.trainerName,
    this.showChatButton = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(isDark ? 30 : 20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withAlpha(isDark ? 60 : 50),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              LucideIcons.userCheck,
              size: 22,
              color: AppColors.info,
            ),
          ),

          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Treinos Gerenciados',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trainerName != null
                      ? '$trainerName prescreve seus treinos. Entre em contato para ajustes.'
                      : 'Seu Personal prescreve seus treinos. Entre em contato para ajustes.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Chat button
          if (showChatButton) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                context.go(RouteNames.chat);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.messageCircle,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Chat',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact version of the banner for smaller spaces
class TrainerManagedBannerCompact extends StatelessWidget {
  final bool isDark;

  const TrainerManagedBannerCompact({
    super.key,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(isDark ? 30 : 20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withAlpha(isDark ? 60 : 50),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.userCheck,
            size: 14,
            color: AppColors.info,
          ),
          const SizedBox(width: 6),
          Text(
            'Gerenciado pelo Personal',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.info,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
