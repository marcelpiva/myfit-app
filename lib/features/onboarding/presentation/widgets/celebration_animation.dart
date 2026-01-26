import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Celebration animation widget for onboarding completion
class CelebrationAnimation extends StatefulWidget {
  final bool autoPlay;
  final VoidCallback? onAnimationComplete;

  const CelebrationAnimation({
    super.key,
    this.autoPlay = true,
    this.onAnimationComplete,
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for checkmark
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.bounceOut,
      ),
    );

    // Confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    if (widget.autoPlay) {
      _playAnimation();
    }
  }

  void _playAnimation() async {
    HapticUtils.mediumImpact();
    await _scaleController.forward();
    _confettiController.forward();

    await Future.delayed(const Duration(milliseconds: 1500));
    widget.onAnimationComplete?.call();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti particles
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(300, 200),
                painter: ConfettiPainter(
                  progress: _confettiController.value,
                  isDark: isDark,
                ),
              );
            },
          ),
          // Glow effect
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withAlpha(
                          (50 * _scaleAnimation.value).toInt(),
                        ),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Circle background
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withAlpha(200),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withAlpha(60),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Checkmark icon
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: const Icon(
                  LucideIcons.check,
                  size: 56,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Custom painter for confetti particles
class ConfettiPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final List<_ConfettiParticle> _particles;

  ConfettiPainter({
    required this.progress,
    required this.isDark,
  }) : _particles = _generateParticles();

  static List<_ConfettiParticle> _generateParticles() {
    final random = math.Random(42); // Fixed seed for consistent look
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
    ];

    return List.generate(30, (index) {
      return _ConfettiParticle(
        startX: random.nextDouble(),
        startY: 0.5,
        velocityX: (random.nextDouble() - 0.5) * 2,
        velocityY: -random.nextDouble() * 2 - 0.5,
        rotation: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 10,
        color: colors[random.nextInt(colors.length)],
        size: random.nextDouble() * 8 + 4,
        shape: random.nextInt(3),
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    for (final particle in _particles) {
      final gravity = 2.0;
      final t = progress;

      final x = size.width *
          (particle.startX + particle.velocityX * t * 0.3);
      final y = size.height *
          (particle.startY +
              particle.velocityY * t +
              gravity * t * t * 0.5);

      if (y > size.height) continue;

      final opacity = (1 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = particle.color.withAlpha((255 * opacity).toInt())
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + particle.rotationSpeed * progress);

      switch (particle.shape) {
        case 0: // Circle
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case 1: // Square
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case 2: // Rectangle
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size * 1.5,
              height: particle.size * 0.5,
            ),
            paint,
          );
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ConfettiParticle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double rotation;
  final double rotationSpeed;
  final Color color;
  final double size;
  final int shape;

  _ConfettiParticle({
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
    required this.shape,
  });
}

/// Summary card for completion step
class CompletionSummaryCard extends StatelessWidget {
  final String? userName;
  final List<String> specialties;
  final int experienceYears;
  final String? cref;

  const CompletionSummaryCard({
    super.key,
    this.userName,
    this.specialties = const [],
    this.experienceYears = 0,
    this.cref,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Seu perfil está pronto!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (specialties.isNotEmpty) ...[
                _SummaryItem(
                  icon: LucideIcons.award,
                  label: '${specialties.length} especialidades',
                ),
                const SizedBox(width: 16),
              ],
              if (experienceYears > 0) ...[
                _SummaryItem(
                  icon: LucideIcons.clock,
                  label: '$experienceYears anos de exp.',
                ),
              ],
              if (cref != null) ...[
                const SizedBox(width: 16),
                _SummaryItem(
                  icon: LucideIcons.badgeCheck,
                  label: 'CREF Verificado',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

/// Next steps checklist for completion
class NextStepsChecklist extends StatelessWidget {
  final bool hasInvitedStudent;
  final bool hasCreatedPlan;
  final bool hasExploredTemplates;
  final VoidCallback? onInviteStudentTap;
  final VoidCallback? onCreatePlanTap;
  final VoidCallback? onExploreTemplatesTap;

  const NextStepsChecklist({
    super.key,
    this.hasInvitedStudent = false,
    this.hasCreatedPlan = false,
    this.hasExploredTemplates = false,
    this.onInviteStudentTap,
    this.onCreatePlanTap,
    this.onExploreTemplatesTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximos passos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        _ChecklistItem(
          label: 'Convidar primeiro aluno',
          isCompleted: hasInvitedStudent,
          onTap: hasInvitedStudent ? null : onInviteStudentTap,
        ),
        const SizedBox(height: 8),
        _ChecklistItem(
          label: 'Criar primeiro plano',
          isCompleted: hasCreatedPlan,
          onTap: hasCreatedPlan ? null : onCreatePlanTap,
        ),
        const SizedBox(height: 8),
        _ChecklistItem(
          label: 'Explorar templates',
          isCompleted: hasExploredTemplates,
          onTap: hasExploredTemplates ? null : onExploreTemplatesTap,
        ),
      ],
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _ChecklistItem({
    required this.label,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.success.withAlpha(isDark ? 20 : 15)
              : (isDark ? AppColors.cardDark : AppColors.card),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? AppColors.success.withAlpha(50)
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.success
                    : (isDark ? AppColors.mutedDark : AppColors.muted),
                border: isCompleted
                    ? null
                    : Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.border,
                      ),
              ),
              child: isCompleted
                  ? const Icon(
                      LucideIcons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCompleted ? FontWeight.w500 : FontWeight.w600,
                  color: isCompleted
                      ? (isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground)
                      : (isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground),
                  decoration:
                      isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (!isCompleted && onTap != null)
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
}
