import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../config/theme/app_colors.dart';
import '../../../core/utils/haptic_utils.dart';

/// Banner prompting the trainer to reactivate their archived organization
class ReactivateOrganizationBanner extends StatelessWidget {
  final String? organizationName;
  final VoidCallback onReactivate;
  final bool isLoading;
  final bool isDark;

  const ReactivateOrganizationBanner({
    super.key,
    this.organizationName,
    required this.onReactivate,
    this.isLoading = false,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  LucideIcons.archive,
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
                      'Organização Arquivada',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      organizationName != null
                          ? '$organizationName está inativa. Deseja retomar as atividades?'
                          : 'Sua organização está inativa. Deseja retomar as atividades?',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reactivate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : () {
                HapticUtils.mediumImpact();
                onReactivate();
              },
              icon: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(LucideIcons.refreshCw, size: 18),
              label: Text(isLoading ? 'Reativando...' : 'Reativar Organização'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
