import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/animated_progress_bar.dart';

/// Redesigned Experience step for student onboarding
class StudentExperienceStep extends StatefulWidget {
  final ExperienceLevel? initialLevel;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final Function(ExperienceLevel) onContinue;
  final double progress;

  const StudentExperienceStep({
    super.key,
    this.initialLevel,
    required this.onBack,
    required this.onSkip,
    required this.onContinue,
    this.progress = 0.33,
  });

  @override
  State<StudentExperienceStep> createState() => _StudentExperienceStepState();
}

class _StudentExperienceStepState extends State<StudentExperienceStep> {
  ExperienceLevel? _selectedLevel;

  final _levels = [
    (
      ExperienceLevel.beginner,
      'Iniciante',
      'Nunca treinei ou treino há menos de 6 meses',
      LucideIcons.sprout,
      AppColors.success,
    ),
    (
      ExperienceLevel.intermediate,
      'Intermediário',
      'Treino regularmente há mais de 6 meses',
      LucideIcons.trendingUp,
      AppColors.warning,
    ),
    (
      ExperienceLevel.advanced,
      'Avançado',
      'Treino há mais de 2 anos com consistência',
      LucideIcons.trophy,
      AppColors.primary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialLevel;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
                          color: AppColors.info.withAlpha(isDark ? 30 : 20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.barChart3,
                          size: 40,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Center(
                      child: Text(
                        'Qual é seu nível de experiência?',
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
                        'Ajuda a adequar a intensidade dos treinos',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Level options
                    ...List.generate(_levels.length, (index) {
                      final (level, title, description, icon, color) = _levels[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildLevelCard(
                          level: level,
                          title: title,
                          description: description,
                          icon: icon,
                          color: color,
                          isDark: isDark,
                        ),
                      );
                    }),
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

  Widget _buildLevelCard({
    required ExperienceLevel level,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = _selectedLevel == level;

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        setState(() => _selectedLevel = level);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withAlpha(isDark ? 50 : 30)
                    : color.withAlpha(isDark ? 20 : 15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? color : color.withAlpha(180),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
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
          onPressed: _selectedLevel != null
              ? () {
                  HapticUtils.mediumImpact();
                  widget.onContinue(_selectedLevel!);
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
