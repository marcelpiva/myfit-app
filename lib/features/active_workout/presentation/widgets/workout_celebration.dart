import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

/// Confetti particle for celebration animation
class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double rotation;
  double rotationSpeed;
  Color color;
  double size;
  double opacity;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
    this.opacity = 1.0,
  });
}

/// Celebration animation with confetti effect
class WorkoutCelebration extends StatefulWidget {
  final Widget child;
  final bool isPlaying;
  final VoidCallback? onComplete;

  const WorkoutCelebration({
    super.key,
    required this.child,
    this.isPlaying = false,
    this.onComplete,
  });

  @override
  State<WorkoutCelebration> createState() => _WorkoutCelebrationState();
}

class _WorkoutCelebrationState extends State<WorkoutCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final _random = Random();

  final _colors = [
    AppColors.primary,
    AppColors.success,
    AppColors.warning,
    AppColors.secondary,
    AppColors.accent,
    Colors.pink,
    Colors.orange,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _controller.addListener(_updateParticles);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.isPlaying) {
      _startCelebration();
    }
  }

  @override
  void didUpdateWidget(WorkoutCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startCelebration();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateParticles);
    _controller.dispose();
    super.dispose();
  }

  void _startCelebration() {
    _generateParticles();
    _controller.forward(from: 0);
  }

  void _generateParticles() {
    _particles.clear();

    // Generate particles from center-top
    for (int i = 0; i < 80; i++) {
      final angle = _random.nextDouble() * pi - pi / 2; // -90 to 90 degrees
      final speed = _random.nextDouble() * 400 + 200;

      _particles.add(_ConfettiParticle(
        x: 0.5, // Center horizontally (relative)
        y: 0.3, // Start from upper area
        vx: cos(angle) * speed * (_random.nextBool() ? 1 : -1),
        vy: -sin(angle).abs() * speed * 0.5 - 100, // Always go up initially
        rotation: _random.nextDouble() * pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        color: _colors[_random.nextInt(_colors.length)],
        size: _random.nextDouble() * 10 + 6,
      ));
    }
  }

  void _updateParticles() {
    if (!mounted) return;

    final progress = _controller.value;
    const gravity = 800.0;
    const dt = 0.016; // ~60fps

    for (final particle in _particles) {
      // Update position
      particle.x += particle.vx * dt / 400;
      particle.y += particle.vy * dt / 400;

      // Apply gravity
      particle.vy += gravity * dt;

      // Apply drag
      particle.vx *= 0.99;
      particle.vy *= 0.99;

      // Update rotation
      particle.rotation += particle.rotationSpeed * dt;

      // Fade out towards the end
      if (progress > 0.7) {
        particle.opacity = (1 - progress) / 0.3;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isPlaying)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Custom painter for confetti particles
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      if (particle.opacity <= 0) continue;

      final paint = Paint()
        ..color = particle.color.withAlpha((particle.opacity * 255).toInt())
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation);

      // Draw rectangle confetti
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

/// Animated trophy icon for workout completion
class AnimatedTrophy extends StatefulWidget {
  final double size;
  final Color color;
  final bool animate;

  const AnimatedTrophy({
    super.key,
    this.size = 80,
    this.color = AppColors.success,
    this.animate = true,
  });

  @override
  State<AnimatedTrophy> createState() => _AnimatedTrophyState();
}

class _AnimatedTrophyState extends State<AnimatedTrophy>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 0.9).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -0.1, end: 0.1).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.1, end: 0.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animate ? _scaleAnimation.value : 1.0,
          child: Transform.rotate(
            angle: widget.animate ? _rotateAnimation.value : 0.0,
            child: Container(
              width: widget.size + 40,
              height: widget.size + 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: widget.animate
                    ? [
                        BoxShadow(
                          color: widget.color.withAlpha(
                            (80 * _glowAnimation.value).toInt(),
                          ),
                          blurRadius: 30 * _glowAnimation.value,
                          spreadRadius: 10 * _glowAnimation.value,
                        ),
                      ]
                    : null,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: widget.size,
                  color: widget.color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated stat counter for workout summary
class AnimatedStatCounter extends StatefulWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Duration delay;

  const AnimatedStatCounter({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color = AppColors.primary,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedStatCounter> createState() => _AnimatedStatCounterState();
}

class _AnimatedStatCounterState extends State<AnimatedStatCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                Icon(widget.icon, size: 24, color: widget.color),
                const SizedBox(height: 8),
                Text(
                  widget.value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
