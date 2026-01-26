import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/celebration_animation.dart';

/// Redesigned Complete step for student onboarding
class StudentCompleteStep extends StatefulWidget {
  final StudentOnboardingState state;
  final VoidCallback onComplete;
  final bool isLoading;

  const StudentCompleteStep({
    super.key,
    required this.state,
    required this.onComplete,
    this.isLoading = false,
  });

  @override
  State<StudentCompleteStep> createState() => _StudentCompleteStepState();
}

class _StudentCompleteStepState extends State<StudentCompleteStep> {
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

  String _getGoalLabel(FitnessGoal? goal) {
    switch (goal) {
      case FitnessGoal.loseWeight:
        return 'Perder peso';
      case FitnessGoal.gainMuscle:
        return 'Ganhar massa';
      case FitnessGoal.improveEndurance:
        return 'Condicionamento';
      case FitnessGoal.maintainHealth:
        return 'Saúde';
      case FitnessGoal.flexibility:
        return 'Flexibilidade';
      case FitnessGoal.other:
        return 'Personalizado';
      default:
        return 'Não definido';
    }
  }

  String _getExperienceLabel(ExperienceLevel? level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return 'Iniciante';
      case ExperienceLevel.intermediate:
        return 'Intermediário';
      case ExperienceLevel.advanced:
        return 'Avançado';
      default:
        return 'Não definido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
            Expanded(
              child: AnimatedOpacity(
                opacity: _showContent ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Title
                      Text(
                        'Perfil configurado!',
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
                        'Agora você está pronto para começar seus treinos',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Summary card
                      _buildSummaryCard(isDark),
                      const SizedBox(height: 24),
                      // What's next
                      _buildWhatsNextCard(isDark),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom action
            _buildBottomAction(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.user,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Seu perfil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            icon: LucideIcons.target,
            label: 'Objetivo',
            value: _getGoalLabel(widget.state.fitnessGoal),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            icon: LucideIcons.barChart3,
            label: 'Nível',
            value: _getExperienceLabel(widget.state.experienceLevel),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            icon: LucideIcons.calendarDays,
            label: 'Frequência',
            value: widget.state.weeklyFrequency != null
                ? '${widget.state.weeklyFrequency}x por semana'
                : 'Não definido',
            isDark: isDark,
          ),
          if (widget.state.injuries.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              icon: LucideIcons.alertCircle,
              label: 'Atenção',
              value: '${widget.state.injuries.length} área(s)',
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(isDark ? 20 : 15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildWhatsNextCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(isDark ? 20 : 15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withAlpha(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.sparkles,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Próximos passos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNextStep(
            number: '1',
            text: 'Conecte-se com seu Personal Trainer',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildNextStep(
            number: '2',
            text: 'Receba seu primeiro plano de treino',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildNextStep(
            number: '3',
            text: 'Comece a treinar e acompanhe seu progresso',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildNextStep({
    required String number,
    required String text,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ),
      ],
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
                      'Começar a treinar',
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
