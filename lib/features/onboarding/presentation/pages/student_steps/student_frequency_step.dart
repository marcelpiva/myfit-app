import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../widgets/animated_progress_bar.dart';

/// Redesigned Frequency step for student onboarding
class StudentFrequencyStep extends StatefulWidget {
  final int? initialFrequency;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final Function(int) onContinue;
  final double progress;

  const StudentFrequencyStep({
    super.key,
    this.initialFrequency,
    required this.onBack,
    required this.onSkip,
    required this.onContinue,
    this.progress = 0.67,
  });

  @override
  State<StudentFrequencyStep> createState() => _StudentFrequencyStepState();
}

class _StudentFrequencyStepState extends State<StudentFrequencyStep> {
  int? _selectedFrequency;

  final _frequencies = [
    (1, '1x por semana', 'Treino leve', LucideIcons.battery),
    (2, '2x por semana', 'Manutenção', LucideIcons.batteryLow),
    (3, '3x por semana', 'Recomendado', LucideIcons.batteryMedium),
    (4, '4x por semana', 'Intenso', LucideIcons.batteryFull),
    (5, '5x ou mais', 'Alto rendimento', LucideIcons.zap),
  ];

  @override
  void initState() {
    super.initState();
    _selectedFrequency = widget.initialFrequency;
  }

  Color _getFrequencyColor(int frequency) {
    switch (frequency) {
      case 1:
        return AppColors.mutedForeground;
      case 2:
        return AppColors.info;
      case 3:
        return AppColors.success;
      case 4:
        return AppColors.warning;
      case 5:
        return AppColors.primary;
      default:
        return AppColors.info;
    }
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
                          color: AppColors.success.withAlpha(isDark ? 30 : 20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.calendarDays,
                          size: 40,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Center(
                      child: Text(
                        'Quantas vezes por semana\nvocê pode treinar?',
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
                        'Ajuda a planejar a distribuição dos treinos',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Frequency options
                    ...List.generate(_frequencies.length, (index) {
                      final (freq, title, subtitle, icon) = _frequencies[index];
                      final color = _getFrequencyColor(freq);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildFrequencyCard(
                          frequency: freq,
                          title: title,
                          subtitle: subtitle,
                          icon: icon,
                          color: color,
                          isRecommended: freq == 3,
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

  Widget _buildFrequencyCard({
    required int frequency,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isRecommended,
    required bool isDark,
  }) {
    final isSelected = _selectedFrequency == frequency;

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        setState(() => _selectedFrequency = frequency);
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Ideal',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
          onPressed: _selectedFrequency != null
              ? () {
                  HapticUtils.mediumImpact();
                  widget.onContinue(_selectedFrequency!);
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
