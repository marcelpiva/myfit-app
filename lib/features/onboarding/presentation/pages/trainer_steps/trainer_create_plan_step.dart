import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../widgets/animated_progress_bar.dart';

/// Interactive Create Plan step with animated walkthrough
class TrainerCreatePlanStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final double progress;

  const TrainerCreatePlanStep({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    this.progress = 0.6,
  });

  @override
  ConsumerState<TrainerCreatePlanStep> createState() =>
      _TrainerCreatePlanStepState();
}

class _TrainerCreatePlanStepState extends ConsumerState<TrainerCreatePlanStep>
    with TickerProviderStateMixin {
  late AnimationController _stepsController;
  late List<Animation<double>> _stepAnimations;

  final _planSteps = [
    _PlanStepData(
      icon: LucideIcons.target,
      title: 'Defina o Objetivo',
      description: 'Escolha a meta do plano: hipertrofia, emagrecimento, etc.',
      color: AppColors.info,
    ),
    _PlanStepData(
      icon: LucideIcons.calendar,
      title: 'Crie os Treinos',
      description: 'Organize os dias de treino da semana',
      color: AppColors.primary,
    ),
    _PlanStepData(
      icon: LucideIcons.dumbbell,
      title: 'Adicione Exercícios',
      description: 'Selecione exercícios e defina séries, repetições e carga',
      color: AppColors.warning,
    ),
    _PlanStepData(
      icon: LucideIcons.send,
      title: 'Prescreva ao Aluno',
      description: 'Envie o plano para seu aluno começar a treinar',
      color: AppColors.success,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _stepsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Create staggered animations for each step
    _stepAnimations = List.generate(_planSteps.length, (index) {
      final start = index * 0.15;
      final end = start + 0.25;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _stepsController,
          curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
              curve: Curves.easeOut),
        ),
      );
    });

    // Start animation once
    _stepsController.forward();
  }

  @override
  void dispose() {
    _stepsController.dispose();
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
              // Header with progress
              _buildHeader(context, isDark),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Header icon
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.clipboardList,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      Center(
                        child: Text(
                          'Como criar um plano',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Aprenda os passos para prescrever treinos personalizados',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Steps list
                      _buildAnimatedSteps(isDark),
                      const SizedBox(height: 100), // Space for bottom actions
                    ],
                  ),
                ),
              ),
              // Bottom actions
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

  Widget _buildAnimatedSteps(bool isDark) {
    return Column(
      children: List.generate(_planSteps.length, (index) {
        final step = _planSteps[index];
        final isLast = index == _planSteps.length - 1;

        return AnimatedBuilder(
          animation: _stepAnimations[index],
          builder: (context, child) {
            return Opacity(
              opacity: _stepAnimations[index].value,
              child: Transform.translate(
                offset: Offset(
                  (1 - _stepAnimations[index].value) * 20,
                  0,
                ),
                child: Column(
                  children: [
                    _PlanStepCard(
                      step: step,
                      stepNumber: index + 1,
                      isDark: isDark,
                    ),
                    if (!isLast)
                      _ConnectionLine(
                        color: step.color,
                        isDark: isDark,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                HapticUtils.mediumImpact();
                widget.onNext();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
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
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              widget.onNext();
            },
            child: Text(
              'Fazer depois',
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
}

class _PlanStepData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _PlanStepData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _PlanStepCard extends StatelessWidget {
  final _PlanStepData step;
  final int stepNumber;
  final bool isDark;

  const _PlanStepCard({
    required this.step,
    required this.stepNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Step number badge with icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: step.color.withAlpha(isDark ? 30 : 20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              step.icon,
              size: 24,
              color: step.color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
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
        ],
      ),
    );
  }
}

class _ConnectionLine extends StatelessWidget {
  final Color color;
  final bool isDark;

  const _ConnectionLine({
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 39),
      width: 2,
      height: 16,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withAlpha(60),
            color.withAlpha(30),
          ],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
