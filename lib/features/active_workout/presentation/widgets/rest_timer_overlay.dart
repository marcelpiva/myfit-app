import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Rest timer overlay with blur background
class RestTimerOverlay extends StatelessWidget {
  final int timeRemaining;
  final int totalTime;
  final int currentSet;
  final int totalSets;
  final String? nextExerciseName;
  final VoidCallback onSkip;
  final VoidCallback onAddTime;
  final bool isDark;

  const RestTimerOverlay({
    super.key,
    required this.timeRemaining,
    required this.totalTime,
    required this.currentSet,
    required this.totalSets,
    required this.onSkip,
    required this.onAddTime,
    this.nextExerciseName,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalTime > 0 ? timeRemaining / totalTime : 0.0;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: (isDark ? Colors.black : Colors.white).withAlpha(isDark ? 180 : 200),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rest label
              Text(
                'DESCANSE',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 32),

              // Circular timer
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withAlpha(40),
                          width: 10,
                        ),
                      ),
                    ),

                    // Progress indicator
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(progress),
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),

                    // Timer text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(timeRemaining),
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getProgressColor(progress),
                            fontSize: 56,
                          ),
                        ),
                        Text(
                          'segundos',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Next set info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDark.withAlpha(150)
                      : AppColors.card.withAlpha(200),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.arrowRight,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Série $currentSet de $totalSets',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              if (nextExerciseName != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Próximo: $nextExerciseName',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],

              const SizedBox(height: 48),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Add time button
                  _ActionButton(
                    icon: LucideIcons.plus,
                    label: '+30s',
                    onTap: () {
                      HapticUtils.lightImpact();
                      onAddTime();
                    },
                    isDark: isDark,
                    isPrimary: false,
                  ),

                  const SizedBox(width: 20),

                  // Skip button
                  _ActionButton(
                    icon: LucideIcons.skipForward,
                    label: 'Pular',
                    onTap: () {
                      HapticUtils.mediumImpact();
                      onSkip();
                    },
                    isDark: isDark,
                    isPrimary: true,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Motivational tip (optional)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  _getRestTip(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress > 0.5) return AppColors.primary;
    if (progress > 0.2) return AppColors.warning;
    return AppColors.success;
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '$seconds';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getRestTip() {
    final tips = [
      'Respire fundo e relaxe os músculos',
      'Hidrate-se durante o descanso',
      'Mantenha o foco no próximo set',
      'Visualize a execução perfeita',
      'Alongue levemente se necessário',
    ];
    return tips[timeRemaining % tips.length];
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : (isDark
                  ? theme.colorScheme.surfaceContainerLow.withAlpha(200)
                  : theme.colorScheme.surfaceContainerLow),
          borderRadius: BorderRadius.circular(14),
          border: isPrimary
              ? null
              : Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.white : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
