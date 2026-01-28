import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../providers/auth_provider.dart';

/// Page for selecting user type after registration
/// Routes to appropriate onboarding flow based on selection
class UserTypeSelectionPage extends ConsumerStatefulWidget {
  final String? name;
  final String? email;
  final String? password;
  final bool isAlreadyAuthenticated;

  const UserTypeSelectionPage({
    super.key,
    this.name,
    this.email,
    this.password,
    this.isAlreadyAuthenticated = false,
  });

  @override
  ConsumerState<UserTypeSelectionPage> createState() => _UserTypeSelectionPageState();
}

class _UserTypeSelectionPageState extends ConsumerState<UserTypeSelectionPage>
    with SingleTickerProviderStateMixin {
  String? _selectedType;
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
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectType(String type) {
    HapticUtils.selectionClick();
    setState(() => _selectedType = type);
  }

  Future<void> _continue() async {
    if (_selectedType == null) return;
    HapticUtils.mediumImpact();

    if (widget.isAlreadyAuthenticated) {
      // Already logged in via social auth - update local state for UI
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        ref.read(currentUserProvider.notifier).state = currentUser.copyWith(
          userType: _selectedType!,
        );
      }

      // Go to onboarding - it will save user_type to API
      if (mounted) {
        context.go(
          RouteNames.onboarding,
          extra: {'userType': _selectedType},
        );
      }
    } else {
      // Navigate to register with user type
      context.go(
        RouteNames.register,
        extra: {
          'userType': _selectedType,
          'name': widget.name,
          'email': widget.email,
          'password': widget.password,
        },
      );
    }
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
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Header
                  Text(
                    'Você é...',
                    style: theme.textTheme.displayLarge?.copyWith(
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Selecione seu perfil para personalizarmos\nsua experiência',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // User type cards
                  Expanded(
                    child: Column(
                      children: [
                        // Personal Trainer card
                        _UserTypeCard(
                          type: 'personal',
                          title: 'Personal Trainer',
                          subtitle: 'Crio treinos e acompanho alunos',
                          icon: LucideIcons.dumbbell,
                          isSelected: _selectedType == 'personal',
                          onTap: () => _selectType('personal'),
                          features: const [
                            'Criar planos de treino',
                            'Gerenciar alunos',
                            'Acompanhar progresso',
                            'Receber pagamentos',
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Student card
                        _UserTypeCard(
                          type: 'student',
                          title: 'Aluno',
                          subtitle: 'Quero treinar e evoluir',
                          icon: LucideIcons.user,
                          isSelected: _selectedType == 'student',
                          onTap: () => _selectType('student'),
                          features: const [
                            'Receber treinos personalizados',
                            'Acompanhar evolução',
                            'Comunicar com personal',
                            'Treino livre (freemium)',
                          ],
                        ),

                        const Spacer(),

                        // Continue button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _selectedType != null ? _continue : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  AppColors.primary.withAlpha(50),
                              disabledForegroundColor: Colors.white54,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final String type;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final List<String> features;

  const _UserTypeCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? AppColors.primary.withAlpha(isDark ? 30 : 15)
              : isDark
                  ? AppColors.cardDark
                  : AppColors.card,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDark
                    ? AppColors.borderDark
                    : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? AppColors.primary
                        : isDark
                            ? AppColors.mutedDark
                            : AppColors.muted,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isSelected
                        ? Colors.white
                        : isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : null,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(
                      LucideIcons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: features
                  .map((f) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: isDark
                              ? AppColors.mutedDark
                              : AppColors.muted,
                        ),
                        child: Text(
                          f,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
