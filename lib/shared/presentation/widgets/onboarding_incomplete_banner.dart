import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../config/routes/route_names.dart';
import '../../../config/theme/app_colors.dart';

/// A subtle banner shown when onboarding is incomplete
class OnboardingIncompleteBanner extends StatelessWidget {
  final bool isDark;
  final bool isTrainer;
  final VoidCallback? onDismiss;

  const OnboardingIncompleteBanner({
    super.key,
    required this.isDark,
    required this.isTrainer,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.warning.withAlpha(25)
            : AppColors.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withAlpha(60),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push(
              RouteNames.onboarding,
              extra: {
                'userType': isTrainer ? 'trainer' : 'student',
                'editMode': true,
              },
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.clipboardList,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTrainer
                            ? 'Complete seu perfil profissional'
                            : 'Complete seus objetivos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isTrainer
                            ? 'Adicione CREF e especialidades'
                            : 'Personalize seu treino',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withAlpha(180)
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: isDark
                      ? Colors.white.withAlpha(150)
                      : AppColors.mutedForeground,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
