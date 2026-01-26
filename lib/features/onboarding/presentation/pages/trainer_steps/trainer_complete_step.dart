import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/celebration_animation.dart';

/// Completion step with celebration animation and summary
class TrainerCompleteStep extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final bool isLoading;

  const TrainerCompleteStep({
    super.key,
    required this.onComplete,
    this.isLoading = false,
  });

  @override
  ConsumerState<TrainerCompleteStep> createState() => _TrainerCompleteStepState();
}

class _TrainerCompleteStepState extends ConsumerState<TrainerCompleteStep> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    // Show content after celebration animation
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _showContent = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(trainerOnboardingProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.backgroundDark,
                    AppColors.backgroundDark,
                  ]
                : [
                    AppColors.success.withAlpha(10),
                    AppColors.background,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Spacer for top
              const SizedBox(height: 40),
              // Celebration animation
              const CelebrationAnimation(autoPlay: true),
              const SizedBox(height: 24),
              // Content - appears after animation
              AnimatedOpacity(
                opacity: _showContent ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: AnimatedSlide(
                  offset: _showContent ? Offset.zero : const Offset(0, 0.2),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Title
                          Text(
                            'Tudo pronto!',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sua conta de Personal Trainer está configurada',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          // Summary card
                          CompletionSummaryCard(
                            specialties: state.specialties,
                            experienceYears: state.yearsOfExperience ?? 0,
                            cref: state.formattedCref,
                          ),
                          const SizedBox(height: 24),
                          // Next steps
                          NextStepsChecklist(
                            hasInvitedStudent: state.hasInvitedStudent,
                            hasCreatedPlan: state.hasCreatedPlan,
                            hasExploredTemplates: state.hasExploredTemplates,
                            onInviteStudentTap: () {
                              // Will be handled after dashboard loads
                            },
                            onCreatePlanTap: () {
                              // Will be handled after dashboard loads
                            },
                            onExploreTemplatesTap: () {
                              // Will be handled after dashboard loads
                            },
                          ),
                          const SizedBox(height: 24),
                          // Share profile option
                          _buildShareProfileCard(isDark),
                          const SizedBox(height: 100), // Space for bottom action
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom action
              _buildBottomAction(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareProfileCard(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        // TODO: Share profile
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.share2,
                size: 22,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compartilhar perfil',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Mostre seu perfil profissional',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: widget.isLoading
              ? null
              : () {
                  HapticUtils.mediumImpact();
                  widget.onComplete();
                },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ir para Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      LucideIcons.arrowRight,
                      size: 20,
                      color: Colors.white.withAlpha(200),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
