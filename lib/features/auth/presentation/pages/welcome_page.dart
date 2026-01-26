import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/app.dart';
import '../../../../config/l10n/generated/app_localizations.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../shared/presentation/components/components.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showLanguageSelector() {
    HapticUtils.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Idioma',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ),
              const Divider(height: 1),
              _LanguageOption(
                label: 'Português',
                flag: '🇧🇷',
                isSelected: ref.watch(localeProvider).languageCode == 'pt',
                onTap: () {
                  ref.read(localeProvider.notifier).state = const Locale('pt', 'BR');
                  Navigator.pop(context);
                },
              ),
              _LanguageOption(
                label: 'English',
                flag: '🇺🇸',
                isSelected: ref.watch(localeProvider).languageCode == 'en',
                onTap: () {
                  ref.read(localeProvider.notifier).state = const Locale('en', 'US');
                  Navigator.pop(context);
                },
              ),
              _LanguageOption(
                label: 'Español',
                flag: '🇪🇸',
                isSelected: ref.watch(localeProvider).languageCode == 'es',
                onTap: () {
                  ref.read(localeProvider.notifier).state = const Locale('es');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrentLanguageCode() {
    final locale = ref.watch(localeProvider);
    switch (locale.languageCode) {
      case 'en':
        return 'EN';
      case 'es':
        return 'ES';
      default:
        return 'PT';
    }
  }

  String _getCurrentFlag() {
    final locale = ref.watch(localeProvider);
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      default:
        return '🇧🇷';
    }
  }

  void _showThemeSelector() {
    HapticUtils.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentThemeMode = ref.read(themeModeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Tema',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ),
              const Divider(height: 1),
              _ThemeOption(
                label: 'Sistema',
                icon: LucideIcons.smartphone,
                isSelected: currentThemeMode == ThemeMode.system,
                onTap: () {
                  ref.read(themeModeProvider.notifier).state = ThemeMode.system;
                  Navigator.pop(context);
                },
              ),
              _ThemeOption(
                label: 'Claro',
                icon: LucideIcons.sun,
                isSelected: currentThemeMode == ThemeMode.light,
                onTap: () {
                  ref.read(themeModeProvider.notifier).state = ThemeMode.light;
                  Navigator.pop(context);
                },
              ),
              _ThemeOption(
                label: 'Escuro',
                icon: LucideIcons.moon,
                isSelected: currentThemeMode == ThemeMode.dark,
                onTap: () {
                  ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCurrentThemeIcon() {
    final themeMode = ref.watch(themeModeProvider);
    switch (themeMode) {
      case ThemeMode.light:
        return LucideIcons.sun;
      case ThemeMode.dark:
        return LucideIcons.moon;
      case ThemeMode.system:
        return LucideIcons.smartphone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with theme and language selectors
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Theme selector
                    GestureDetector(
                      onTap: _showThemeSelector,
                      child: Container(
                        padding: const EdgeInsets.all(10),
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
                          _getCurrentThemeIcon(),
                          size: 18,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Language selector
                    GestureDetector(
                      onTap: _showLanguageSelector,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_getCurrentFlag(), style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              _getCurrentLanguageCode(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              LucideIcons.chevronDown,
                              size: 16,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                        // Logo with animation
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 200,
                            height: 200,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Brand name
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: theme.textTheme.headlineLarge?.copyWith(
                                letterSpacing: -0.5,
                              ),
                              children: [
                                TextSpan(
                                  text: 'myfit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                  ),
                                ),
                                TextSpan(
                                  text: 'platform',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tagline
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            l10n.welcomeSubheadline,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.06),

                        // Stats row
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark.withAlpha(150)
                                  : AppColors.card.withAlpha(200),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _StatItem(
                                      value: '2k+',
                                      label: l10n.professionals,
                                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    color: isDark ? AppColors.borderDark : AppColors.border,
                                  ),
                                  Expanded(
                                    child: _StatItem(
                                      value: '50k+',
                                      label: l10n.students,
                                      color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    color: isDark ? AppColors.borderDark : AppColors.border,
                                  ),
                                  Expanded(
                                    child: _StatItem(
                                      value: '4.9',
                                      label: l10n.rating,
                                      color: isDark ? AppColors.accentDark : AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                    ],
                  ),
                ),
              ),

              // Bottom CTAs
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Primary CTA
                    PrimaryButton(
                      label: l10n.getStartedFree,
                      onPressed: () {
                        HapticUtils.lightImpact();
                        context.go(RouteNames.userTypeSelection);
                      },
                    ),

                    const SizedBox(height: 12),

                    // Secondary CTA
                    GhostButton(
                      label: l10n.alreadyHaveAccount,
                      fullWidth: true,
                      onPressed: () {
                        HapticUtils.lightImpact();
                        context.go(RouteNames.login);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Terms
                    Text(
                      l10n.termsAgreement,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: isSelected
            ? (isDark ? AppColors.mutedDark : AppColors.muted)
            : Colors.transparent,
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                LucideIcons.check,
                size: 20,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: isSelected
            ? (isDark ? AppColors.mutedDark : AppColors.muted)
            : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected
                    ? (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(20)
                    : (isDark ? AppColors.mutedDark : AppColors.muted),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? (isDark ? AppColors.primaryDark : AppColors.primary)
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                LucideIcons.check,
                size: 20,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
