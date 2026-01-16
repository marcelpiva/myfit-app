import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.entrance,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withAlpha(isDark ? 15 : 10),
              AppColors.secondary.withAlpha(isDark ? 12 : 8),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.pop();
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark.withAlpha(150)
                                  : AppColors.card.withAlpha(200),
                              borderRadius: BorderRadius.circular(8),
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
                        const Spacer(),
                        Text(
                          'Sobre',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 44),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Logo
                    Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      height: 120,
                    ),

                    const SizedBox(height: 24),

                    // App Name
                    Text(
                      'My Fit',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Version
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mutedDark : AppColors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Versão 1.0.0',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Description
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark.withAlpha(150)
                            : AppColors.card.withAlpha(200),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Plataforma completa para gestão de academias, personal trainers e alunos.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Gerencie treinos, acompanhe progresso, controle cobranças e muito mais em um só lugar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Features
                    _buildFeatureItem(
                      isDark,
                      LucideIcons.dumbbell,
                      'Treinos Personalizados',
                      'Crie e gerencie treinos com IA',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      isDark,
                      LucideIcons.users,
                      'Gestão de Alunos',
                      'Acompanhe o progresso de cada aluno',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      isDark,
                      LucideIcons.creditCard,
                      'Controle Financeiro',
                      'Gerencie cobranças e pagamentos',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      isDark,
                      LucideIcons.trophy,
                      'Gamificação',
                      'Motive alunos com rankings e conquistas',
                    ),

                    const SizedBox(height: 32),

                    // Social Links
                    Text(
                      'Siga-nos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(isDark, LucideIcons.instagram, () {}),
                        const SizedBox(width: 16),
                        _buildSocialButton(isDark, LucideIcons.facebook, () {}),
                        const SizedBox(width: 16),
                        _buildSocialButton(isDark, LucideIcons.twitter, () {}),
                        const SizedBox(width: 16),
                        _buildSocialButton(isDark, LucideIcons.globe, () {}),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Copyright
                    Text(
                      '© 2026 My Fit. Todos os direitos reservados.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
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
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(bool isDark, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
        ),
      ),
    );
  }
}
