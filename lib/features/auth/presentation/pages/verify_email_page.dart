import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../providers/auth_provider.dart';

/// Page for email verification with 6-digit code input
class VerifyEmailPage extends ConsumerStatefulWidget {
  final String email;
  final String? redirectTo;
  final String? userType;

  const VerifyEmailPage({
    super.key,
    required this.email,
    this.redirectTo,
    this.userType,
  });

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  bool _resending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

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
    _animController.forward();

    // Start cooldown timer (assume code was just sent)
    _startCooldown();

    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _cooldownTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _resendCooldown = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onCodeChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // Check if all fields are filled
    if (_code.length == 6) {
      _verifyCode();
    }
  }

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyCode() async {
    if (_code.length != 6) return;

    HapticUtils.mediumImpact();
    setState(() => _loading = true);

    final success = await ref.read(authProvider.notifier).verifyEmail(
      email: widget.email,
      code: _code,
    );

    if (mounted) {
      setState(() => _loading = false);

      if (success) {
        HapticUtils.mediumImpact();
        _showSuccess('Email verificado com sucesso!');

        // Navigate to next screen
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          final redirectTo = widget.redirectTo ?? RouteNames.orgSelector;
          if (redirectTo == RouteNames.onboarding && widget.userType != null) {
            context.go(redirectTo, extra: {'userType': widget.userType});
          } else {
            context.go(redirectTo);
          }
        }
      } else {
        HapticUtils.heavyImpact();
        _showError('Código inválido ou expirado');
        _clearCode();
      }
    }
  }

  Future<void> _resendCode() async {
    if (_resendCooldown > 0 || _resending) return;

    HapticUtils.lightImpact();
    setState(() => _resending = true);

    final success = await ref.read(authProvider.notifier).sendVerificationCode(
      email: widget.email,
    );

    if (mounted) {
      setState(() => _resending = false);

      if (success) {
        _showSuccess('Código reenviado!');
        _startCooldown();
      } else {
        _showError('Erro ao reenviar código');
      }
    }
  }

  void _clearCode() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.destructive,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [
                    AppColors.backgroundDark,
                    AppColors.secondary.withAlpha(15),
                    AppColors.backgroundDark,
                  ]
                : [
                    AppColors.background,
                    AppColors.secondary.withAlpha(8),
                    AppColors.background,
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Back button
                  GestureDetector(
                    onTap: () {
                      HapticUtils.lightImpact();
                      context.pop();
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDark ? AppColors.cardDark : AppColors.card,
                        border: Border.all(
                          color:
                              isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.arrowLeft,
                        size: 20,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Email icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.primary.withAlpha(20),
                    ),
                    child: Icon(
                      LucideIcons.mail,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Header
                  Text(
                    'Verifique seu\ne-mail',
                    style: theme.textTheme.displayLarge?.copyWith(
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Enviamos um código de 6 dígitos para',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                  Text(
                    widget.email,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Code input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        height: 56,
                        child: KeyboardListener(
                          focusNode: FocusNode(),
                          onKeyEvent: (event) => _onKeyPressed(index, event),
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor:
                                  isDark ? AppColors.cardDark : AppColors.card,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) => _onCodeChanged(index, value),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading || _code.length != 6
                          ? null
                          : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primary.withAlpha(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Verificar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Resend code
                  Center(
                    child: GestureDetector(
                      onTap: _resendCooldown > 0 ? null : _resendCode,
                      child: _resending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text.rich(
                              TextSpan(
                                text: 'Não recebeu? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                                children: [
                                  TextSpan(
                                    text: _resendCooldown > 0
                                        ? 'Aguarde ${_resendCooldown}s'
                                        : 'Reenviar código',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _resendCooldown > 0
                                          ? (isDark
                                              ? AppColors.mutedForegroundDark
                                              : AppColors.mutedForeground)
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),

                  const Spacer(),

                  // Skip for now (optional)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        final redirectTo = widget.redirectTo ?? RouteNames.orgSelector;
                        if (redirectTo == RouteNames.onboarding && widget.userType != null) {
                          context.go(redirectTo, extra: {'userType': widget.userType});
                        } else {
                          context.go(redirectTo);
                        }
                      },
                      child: Text(
                        'Verificar depois',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
