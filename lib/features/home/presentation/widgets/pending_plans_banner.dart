import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../providers/student_home_provider.dart';
import 'plan_review_sheet.dart';

/// Banner showing pending plans that need student's attention
class PendingPlansBanner extends ConsumerWidget {
  const PendingPlansBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(studentNewPlansProvider);

    // Don't show if no pending plans
    if (!state.hasPendingPlans) {
      return const SizedBox.shrink();
    }

    final pendingCount = state.pendingCount;
    final firstPlan = state.pendingPlans.first;
    final planName = firstPlan['plan_name'] as String? ?? 'Novo plano';
    final trainerName = firstPlan['trainer_name'] as String?;

    return GestureDetector(
      onTap: () {
        HapticUtils.mediumImpact();
        showPlanReviewSheet(context, firstPlan);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withAlpha(200),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(40),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.clipboardCheck,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (pendingCount > 1)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$pendingCount',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pendingCount == 1
                        ? 'Nova prescrição pendente'
                        : '$pendingCount prescrições pendentes',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trainerName != null
                        ? '$planName • De $trainerName'
                        : planName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withAlpha(200),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Arrow
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.chevronRight,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card showing new/unseen plans (already accepted, but not acknowledged)
class NewPlansBadge extends ConsumerWidget {
  const NewPlansBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(studentNewPlansProvider);

    // Don't show if no new plans
    if (!state.hasNewPlans) {
      return const SizedBox.shrink();
    }

    final newCount = state.newCount;
    final firstPlan = state.newPlans.first;
    final planName = firstPlan['plan_name'] as String? ?? 'Novo plano';

    return GestureDetector(
      onTap: () async {
        HapticUtils.lightImpact();
        // Acknowledge the plan when viewed
        final assignmentId = firstPlan['id'] as String;
        await ref.read(studentNewPlansProvider.notifier).acknowledgePlan(assignmentId);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.info.withAlpha(isDark ? 30 : 20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.info.withAlpha(60),
          ),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.sparkles,
              size: 18,
              color: AppColors.info,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                newCount == 1
                    ? 'Novo plano: $planName'
                    : '$newCount novos planos atribuídos',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              LucideIcons.x,
              size: 16,
              color: AppColors.info,
            ),
          ],
        ),
      ),
    );
  }
}
