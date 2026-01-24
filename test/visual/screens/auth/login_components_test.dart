/// Visual tests for auth screen components.
///
/// Tests login-related UI components across different states.
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../config/device_profiles.dart';
import '../../config/visual_test_helpers.dart';

// Simplified wrapper for component testing (no Scaffold)
class _ComponentTestWrapper extends StatelessWidget {
  const _ComponentTestWrapper({required this.child, this.isDark = false});
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      home: Material(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

// Wrapper for full screen mockups (widgets with their own Scaffold)
class _ScreenTestWrapper extends StatelessWidget {
  const _ScreenTestWrapper({required this.child, this.isDark = false});
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      home: child,
    );
  }
}

void main() {
  group('Auth Components', () {
    // Login Form Card
    goldenTest(
      'Login form card',
      fileName: 'login_form_card',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          GoldenTestScenario(
            name: 'Empty',
            child: _ComponentTestWrapper(
              child: _LoginFormCard(
                email: '',
                password: '',
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Filled',
            child: _ComponentTestWrapper(
              child: _LoginFormCard(
                email: 'user@example.com',
                password: 'password123',
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Dark Mode',
            child: _ComponentTestWrapper(
              isDark: true,
              child: _LoginFormCard(
                email: 'user@example.com',
                password: '',
              ),
            ),
          ),
        ],
      ),
    );

    // Login Buttons
    goldenTest(
      'Login buttons',
      fileName: 'login_buttons',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 350),
        children: [
          GoldenTestScenario(
            name: 'Primary Login',
            child: _ComponentTestWrapper(
              child: _PrimaryLoginButton(label: 'Entrar', loading: false),
            ),
          ),
          GoldenTestScenario(
            name: 'Loading',
            child: _ComponentTestWrapper(
              child: _PrimaryLoginButton(label: 'Entrar', loading: true),
            ),
          ),
          GoldenTestScenario(
            name: 'Social Buttons',
            child: _ComponentTestWrapper(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SocialButton(label: 'Continuar com Google', isGoogle: true),
                  const SizedBox(height: 8),
                  _SocialButton(label: 'Continuar com Apple', isGoogle: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // Auth Header
    goldenTest(
      'Auth header variants',
      fileName: 'auth_headers',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 350),
        children: [
          GoldenTestScenario(
            name: 'Login',
            child: _ComponentTestWrapper(
              child: _AuthHeader(
                title: 'Entrar',
                subtitle: 'Entre com sua conta para continuar',
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Welcome Back',
            child: _ComponentTestWrapper(
              child: _AuthHeader(
                title: 'Bem-vindo\nde volta',
                subtitle: 'Use biometria para entrar rapidamente',
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Register',
            child: _ComponentTestWrapper(
              child: _AuthHeader(
                title: 'Criar conta',
                subtitle: 'Preencha os dados para começar',
              ),
            ),
          ),
        ],
      ),
    );

    // Multi-device login screen mockup
    for (final device in DeviceProfiles.critical) {
      goldenTest(
        'Login screen mockup on ${device.name}',
        fileName: 'login_screen_mockup_${device.safeFileName}',
        constraints: BoxConstraints.tight(device.size),
        builder: () => _ScreenTestWrapper(
          child: _LoginScreenMockup(),
        ),
      );
    }
  });
}

// ===========================================================================
// Test Components (simplified versions of real components)
// ===========================================================================

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({required this.email, required this.password});
  final String email;
  final String password;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDark ? Colors.grey[850] : Colors.white,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: TextEditingController(text: email),
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'seu@email.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: password),
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Senha',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: const Icon(Icons.visibility_off),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Esqueci minha senha',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryLoginButton extends StatelessWidget {
  const _PrimaryLoginButton({required this.label, required this.loading});
  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.onSurface,
          foregroundColor: theme.colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: loading
            ? Icon(
                Icons.hourglass_empty,
                size: 20,
                color: theme.colorScheme.surface,
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.isGoogle});
  final String label;
  final bool isGoogle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(
          isGoogle ? Icons.g_mobiledata : Icons.apple,
          size: 24,
        ),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : Colors.black87,
          side: BorderSide(
            color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(150),
          ),
        ),
      ],
    );
  }
}

class _LoginScreenMockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
              const SizedBox(height: 24),

              // Header
              Text(
                'Entrar',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Entre com sua conta para continuar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Form
              _LoginFormCard(email: '', password: ''),
              const SizedBox(height: 20),

              // Login button
              _PrimaryLoginButton(label: 'Entrar', loading: false),

              const Spacer(),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'ou',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 16),

              // Social buttons
              _SocialButton(label: 'Continuar com Google', isGoogle: true),
              const SizedBox(height: 8),
              _SocialButton(label: 'Continuar com Apple', isGoogle: false),
              const SizedBox(height: 20),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Não tem conta? ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  Text(
                    'Criar conta',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
