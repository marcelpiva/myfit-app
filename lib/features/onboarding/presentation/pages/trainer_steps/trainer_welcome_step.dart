import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../widgets/animated_progress_bar.dart';

/// Redesigned Welcome step with modern animations and personalization
class TrainerWelcomeStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final double progress;

  const TrainerWelcomeStep({
    super.key,
    required this.onNext,
    required this.onSkip,
    this.progress = 0.0,
  });

  @override
  ConsumerState<TrainerWelcomeStep> createState() => _TrainerWelcomeStepState();
}

class _TrainerWelcomeStepState extends ConsumerState<TrainerWelcomeStep>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _featuresController;
  late Animation<double> _iconScale;
  late Animation<double> _iconRotation;
  late List<Animation<Offset>> _featureSlides;

  @override
  void initState() {
    super.initState();

    // Icon animation
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.elasticOut,
      ),
    );

    _iconRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.easeOut,
      ),
    );

    // Features staggered animation
    _featuresController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _featureSlides = List.generate(3, (index) {
      final start = index * 0.2;
      final end = start + 0.4;
      return Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _featuresController,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    // Start animations
    _iconController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _featuresController.forward();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final firstName = user?.name.split(' ').first ?? 'Personal';

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
                    AppColors.primary.withAlpha(15),
                    AppColors.background,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with progress
              _buildHeader(context, isDark),
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      // Animated icon
                      _buildAnimatedIcon(isDark),
                      const SizedBox(height: 32),
                      // Welcome text with user's name
                      Text(
                        'Olá, $firstName!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Vamos configurar seu perfil de Personal Trainer\ne começar a transformar vidas!',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      // Feature highlights
                      _buildFeatureHighlights(context, isDark),
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
          const SizedBox(width: 40), // Spacer for balance
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

  Widget _buildAnimatedIcon(bool isDark) {
    return AnimatedBuilder(
      animation: _iconController,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconScale.value,
          child: Transform.rotate(
            angle: _iconRotation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(40),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Main circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withAlpha(200),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(60),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.dumbbell,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureHighlights(BuildContext context, bool isDark) {
    final features = [
      _FeatureData(
        icon: LucideIcons.users,
        title: 'Gerencie seus alunos',
        subtitle: 'Acompanhe o progresso de cada um',
        color: AppColors.info,
      ),
      _FeatureData(
        icon: LucideIcons.clipboardList,
        title: 'Crie planos personalizados',
        subtitle: 'Prescreva treinos sob medida',
        color: AppColors.success,
      ),
      _FeatureData(
        icon: LucideIcons.lineChart,
        title: 'Acompanhe resultados',
        subtitle: 'Métricas e evolução em tempo real',
        color: AppColors.warning,
      ),
    ];

    return Column(
      children: List.generate(features.length, (index) {
        return SlideTransition(
          position: _featureSlides[index],
          child: FadeTransition(
            opacity: _featuresController,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _FeatureCard(
                feature: features[index],
                isDark: isDark,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isDark) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () {
                HapticUtils.mediumImpact();
                widget.onNext();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Começar Configuração',
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
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              widget.onSkip();
            },
            child: Text(
              'Pular configuração',
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

class _FeatureData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData feature;
  final bool isDark;

  const _FeatureCard({
    required this.feature,
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
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : feature.color).withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: feature.color.withAlpha(isDark ? 30 : 20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              feature.icon,
              color: feature.color,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.subtitle,
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
