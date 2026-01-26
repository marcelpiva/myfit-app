import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/l10n/generated/app_localizations.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/providers/biometric_provider.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../core/services/social_auth_service.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../shared/presentation/components/components.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _loading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Por favor, preencha todos os campos.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('Por favor, insira um email válido.');
      return;
    }

    HapticUtils.mediumImpact();
    setState(() => _loading = true);

    final success = await ref.read(authProvider.notifier).login(
      email: email,
      password: password,
    );

    if (mounted) {
      setState(() => _loading = false);

      if (success) {
        // Invalidate providers to fetch fresh data after login
        ref.invalidate(membershipsProvider);
        ref.invalidate(pendingInvitesForUserProvider);

        await _checkBiometricSetup(email, password);
        if (mounted) {
          context.go(RouteNames.orgSelector);
        }
      } else {
        final authState = ref.read(authProvider);
        _showError(authState.errorMessage ?? 'Erro ao fazer login');
      }
    }
  }

  Future<void> _checkBiometricSetup(String email, String password) async {
    try {
      final biometricAvailable = await ref.read(biometricAvailableProvider.future);
      final biometricEnabled = await ref.read(biometricEnabledProvider.future);

      if (biometricAvailable && !biometricEnabled && mounted) {
        final biometricLabel = await ref.read(biometricLabelProvider.future);

        final shouldEnable = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login mais rápido'),
            content: Text(
              'Deseja usar $biometricLabel para entrar no app? '
              'Você poderá entrar sem digitar sua senha.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Agora não'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Ativar'),
              ),
            ],
          ),
        );

        if (shouldEnable == true) {
          final service = ref.read(biometricServiceProvider);
          await service.saveCredentials(email, password);
          ref.invalidate(biometricEnabledProvider);
        }
      }
    } catch (e) {
      // Ignore errors - biometric setup is optional
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showError(String message) {
    HapticUtils.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.destructive,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    HapticUtils.lightImpact();
    setState(() => _loading = true);

    final idToken = await SocialAuthService.instance.signInWithGoogle();

    if (idToken == null) {
      if (mounted) {
        setState(() => _loading = false);
        _showError('Login com Google cancelado');
      }
      return;
    }

    final success = await ref.read(authProvider.notifier).loginWithGoogle(
      idToken: idToken,
    );

    if (mounted) {
      setState(() => _loading = false);

      if (success) {
        final authState = ref.read(authProvider);
        ref.invalidate(membershipsProvider);
        // New users from social login go to user type selection, then onboarding
        if (authState.isNewUser == true) {
          context.go(
            RouteNames.userTypeSelection,
            extra: {'isAlreadyAuthenticated': true},
          );
        } else {
          context.go(RouteNames.orgSelector);
        }
      } else {
        final authState = ref.read(authProvider);
        _showError(authState.errorMessage ?? 'Erro ao fazer login com Google');
      }
    }
  }

  Future<void> _signInWithApple() async {
    HapticUtils.lightImpact();
    setState(() => _loading = true);

    final result = await SocialAuthService.instance.signInWithApple();

    if (result == null) {
      if (mounted) {
        setState(() => _loading = false);
        _showError('Login com Apple cancelado');
      }
      return;
    }

    final success = await ref.read(authProvider.notifier).loginWithApple(
      idToken: result.idToken,
      userName: result.userName,
    );

    if (mounted) {
      setState(() => _loading = false);

      if (success) {
        final authState = ref.read(authProvider);
        ref.invalidate(membershipsProvider);
        // New users from social login go to user type selection, then onboarding
        if (authState.isNewUser == true) {
          context.go(
            RouteNames.userTypeSelection,
            extra: {'isAlreadyAuthenticated': true},
          );
        } else {
          context.go(RouteNames.orgSelector);
        }
      } else {
        final authState = ref.read(authProvider);
        _showError(authState.errorMessage ?? 'Erro ao fazer login com Apple');
      }
    }
  }

  Future<void> _loginWithBiometric() async {
    final service = ref.read(biometricServiceProvider);

    HapticUtils.mediumImpact();

    final authenticated = await service.authenticate(
      reason: 'Autentique para entrar no MyFit',
    );

    if (!authenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Autenticação cancelada'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final credentials = await service.getCredentials();
    if (credentials.email == null || credentials.password == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Credenciais não encontradas. Faça login com email e senha.'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);

    final success = await ref.read(authProvider.notifier).login(
      email: credentials.email!,
      password: credentials.password!,
    );

    if (mounted) {
      setState(() => _loading = false);

      if (success) {
        context.go(RouteNames.orgSelector);
      } else {
        final authState = ref.read(authProvider);
        _showError(authState.errorMessage ?? 'Erro ao fazer login');
      }
    }
  }

  /// Get dynamic welcome title based on biometric status
  String _getWelcomeTitle(bool hasBiometricCredentials) {
    if (hasBiometricCredentials) {
      return 'Bem-vindo\nde volta';
    }
    return 'Entrar';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [
                    AppColors.backgroundDark,
                    AppColors.primary.withAlpha(15),
                    AppColors.backgroundDark,
                  ]
                : [
                    AppColors.background,
                    AppColors.primary.withAlpha(8),
                    AppColors.background,
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                  children: [
                    // Top section with back button
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticUtils.lightImpact();
                            context.go(RouteNames.welcome);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isDark ? AppColors.cardDark : AppColors.card,
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
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Header - dynamic based on biometric
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Consumer(
                        builder: (context, ref, _) {
                          final biometricEnabled = ref.watch(biometricEnabledProvider);
                          final hasBiometric = biometricEnabled.valueOrNull ?? false;

                          return Text(
                            _getWelcomeTitle(hasBiometric),
                            style: theme.textTheme.headlineLarge?.copyWith(
                              height: 1.1,
                              letterSpacing: -0.5,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.loginSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Form card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDark
                            ? AppColors.cardDark.withAlpha(150)
                            : AppColors.card.withAlpha(200),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            label: l10n.email,
                            hint: l10n.emailHint,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _passwordFocus.requestFocus(),
                            semanticsLabel: 'email-input',
                          ),
                          const SizedBox(height: 16),
                          AppPasswordField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            label: l10n.password,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _login(),
                            semanticsLabel: 'password-input',
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                HapticUtils.lightImpact();
                                context.push(RouteNames.forgotPassword);
                              },
                              child: Text(
                                l10n.forgotPassword,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login button
                    PrimaryButton(
                      label: l10n.signIn,
                      loading: _loading,
                      onPressed: _login,
                      semanticsLabel: 'login-button',
                    ),

                    // Biometric login button
                    Consumer(
                      builder: (context, ref, _) {
                        final biometricAvailable = ref.watch(biometricAvailableProvider);
                        final biometricEnabled = ref.watch(biometricEnabledProvider);

                        return biometricAvailable.when(
                          data: (available) {
                            if (!available) return const SizedBox.shrink();

                            return biometricEnabled.when(
                              data: (enabled) {
                                if (!enabled) return const SizedBox.shrink();

                                final biometricLabel = ref.watch(biometricLabelProvider);

                                return Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: OutlinedButton.icon(
                                    onPressed: _loading ? null : _loginWithBiometric,
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 48),
                                      side: BorderSide(color: AppColors.primary, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: Icon(
                                      PlatformUtils.isIOS ? LucideIcons.scanFace : LucideIcons.fingerprint,
                                      color: AppColors.primary,
                                    ),
                                    label: Text(
                                      biometricLabel.when(
                                        data: (label) => 'Entrar com $label',
                                        loading: () => 'Entrar com biometria',
                                        error: (_, __) => 'Entrar com biometria',
                                      ),
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),

                    const Spacer(),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            l10n.or,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Social buttons
                    SocialButton.google(
                      label: l10n.continueWithGoogle,
                      onTap: _loading ? null : _signInWithGoogle,
                    ),

                    const SizedBox(height: 8),

                    SocialButton.apple(
                      label: l10n.continueWithApple,
                      onTap: _loading ? null : _signInWithApple,
                    ),

                    const SizedBox(height: 20),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.dontHaveAccount,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            HapticUtils.lightImpact();
                            context.go(RouteNames.register);
                          },
                          child: Text(
                            l10n.createAccount,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                      const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
