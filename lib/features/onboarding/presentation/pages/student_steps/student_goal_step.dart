import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/animated_progress_bar.dart';

/// Redesigned Goal step for student onboarding
class StudentGoalStep extends StatefulWidget {
  final FitnessGoal? initialGoal;
  final String? initialOtherGoal;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final Function(FitnessGoal, String?) onContinue;
  final double progress;

  const StudentGoalStep({
    super.key,
    this.initialGoal,
    this.initialOtherGoal,
    required this.onBack,
    required this.onSkip,
    required this.onContinue,
    this.progress = 0.17,
  });

  @override
  State<StudentGoalStep> createState() => _StudentGoalStepState();
}

class _StudentGoalStepState extends State<StudentGoalStep> {
  FitnessGoal? _selectedGoal;
  final _otherController = TextEditingController();

  final _goals = [
    (FitnessGoal.loseWeight, 'Perder peso', LucideIcons.flame, AppColors.warning),
    (FitnessGoal.gainMuscle, 'Ganhar massa muscular', LucideIcons.dumbbell, AppColors.primary),
    (FitnessGoal.improveEndurance, 'Melhorar condicionamento', LucideIcons.activity, AppColors.info),
    (FitnessGoal.maintainHealth, 'Manter a saúde', LucideIcons.heart, AppColors.success),
    (FitnessGoal.flexibility, 'Flexibilidade', LucideIcons.move, AppColors.secondary),
    (FitnessGoal.other, 'Outro objetivo', LucideIcons.target, AppColors.mutedForeground),
  ];

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.initialGoal;
    _otherController.text = widget.initialOtherGoal ?? '';
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, isDark),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Icon
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.target,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      Center(
                        child: Text(
                          'Qual é seu principal objetivo?',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Isso nos ajuda a personalizar sua experiência',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Goal options
                      ...List.generate(_goals.length, (index) {
                        final (goal, label, icon, color) = _goals[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildGoalCard(
                            goal: goal,
                            label: label,
                            icon: icon,
                            color: color,
                            isDark: isDark,
                          ),
                        );
                      }),
                      // Other goal text field
                      if (_selectedGoal == FitnessGoal.other) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: _otherController,
                          decoration: InputDecoration(
                            hintText: 'Descreva seu objetivo...',
                            filled: true,
                            fillColor: isDark ? AppColors.cardDark : AppColors.card,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          maxLines: 2,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              // Bottom action
              _buildBottomActions(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              widget.onBack();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SimpleProgressIndicator(progress: widget.progress),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              widget.onSkip();
            },
            child: Text(
              'Pular',
              style: TextStyle(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required FitnessGoal goal,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = _selectedGoal == goal;

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        setState(() => _selectedGoal = goal);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(isDark ? 30 : 20)
              : (isDark ? AppColors.cardDark : AppColors.card),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withAlpha(isDark ? 50 : 30)
                    : color.withAlpha(isDark ? 20 : 15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? color : color.withAlpha(180),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                LucideIcons.checkCircle2,
                size: 24,
                color: color,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isDark) {
    final canContinue = _selectedGoal != null &&
        (_selectedGoal != FitnessGoal.other || _otherController.text.trim().isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(20),
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
        height: 52,
        child: FilledButton(
          onPressed: canContinue
              ? () {
                  HapticUtils.mediumImpact();
                  widget.onContinue(
                    _selectedGoal!,
                    _selectedGoal == FitnessGoal.other
                        ? _otherController.text.trim()
                        : null,
                  );
                }
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: isDark
                ? AppColors.mutedDark
                : AppColors.muted,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Continuar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
