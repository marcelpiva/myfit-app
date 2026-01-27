import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _bioController;
  late final TextEditingController _crefController;

  String _selectedGoal = 'hipertrofia';

  final List<Map<String, String>> _goals = [
    {'value': 'hipertrofia', 'label': 'Ganho de massa'},
    {'value': 'emagrecimento', 'label': 'Emagrecimento'},
    {'value': 'condicionamento', 'label': 'Condicionamento'},
    {'value': 'manutencao', 'label': 'Manutenção'},
    {'value': 'saude', 'label': 'Saúde e qualidade de vida'},
  ];

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

    // Initialize controllers with current user data
    final currentUser = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: currentUser?.name ?? '');
    _phoneController = TextEditingController(text: currentUser?.phone ?? '');
    _birthDateController = TextEditingController(text: currentUser?.birthDate ?? '');
    _bioController = TextEditingController(text: currentUser?.bio ?? '');
    _crefController = TextEditingController(text: currentUser?.cref ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _bioController.dispose();
    _crefController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    HapticUtils.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Perfil atualizado com sucesso!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          context.pop();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(LucideIcons.arrowLeft, size: 20, color: isDark ? AppColors.foregroundDark : AppColors.foreground),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Editar Perfil',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _saveProfile,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isDark
                                ? AppColors.primaryDark
                                : AppColors.primary,
                          ),
                          child: const Icon(
                            LucideIcons.check,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar section
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: isDark
                                      ? AppColors.mutedDark
                                      : AppColors.muted,
                                ),
                                child: Center(
                                  child: Text(
                                    'JP',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    HapticUtils.lightImpact();
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: AppColors.primary,
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.backgroundDark
                                            : AppColors.background,
                                        width: 3,
                                      ),
                                    ),
                                    child: const Icon(
                                      LucideIcons.camera,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        Center(
                          child: Text(
                            'Toque para alterar foto',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Name field
                        _buildSectionTitle(isDark, 'Nome completo'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          isDark,
                          _nameController,
                          'Seu nome',
                          LucideIcons.user,
                        ),

                        const SizedBox(height: 20),

                        // Email (readonly)
                        _buildSectionTitle(isDark, 'Email'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isDark
                                ? AppColors.cardDark.withAlpha(100)
                                : AppColors.card.withAlpha(150),
                            border: Border.all(
                              color:
                                  isDark ? AppColors.borderDark : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.mail,
                                size: 20,
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'joao.silva@email.com',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark
                                        ? AppColors.mutedForegroundDark
                                        : AppColors.mutedForeground,
                                  ),
                                ),
                              ),
                              Icon(
                                LucideIcons.lock,
                                size: 16,
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                        .withAlpha(100)
                                    : AppColors.mutedForeground.withAlpha(100),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Phone field
                        _buildSectionTitle(isDark, 'Telefone'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          isDark,
                          _phoneController,
                          '(00) 00000-0000',
                          LucideIcons.phone,
                        ),

                        const SizedBox(height: 20),

                        // Birth date field
                        _buildSectionTitle(isDark, 'Data de nascimento'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          isDark,
                          _birthDateController,
                          'DD/MM/AAAA',
                          LucideIcons.calendar,
                        ),

                        // CREF field (only for Personal Trainers)
                        if (ref.watch(activeContextProvider)?.isTrainer ?? false) ...[
                          const SizedBox(height: 20),
                          _buildCrefField(isDark),
                        ],

                        const SizedBox(height: 20),

                        // Goal selector
                        _buildSectionTitle(isDark, 'Objetivo fitness'),
                        const SizedBox(height: 8),
                        _buildGoalSelector(isDark),

                        const SizedBox(height: 20),

                        // Bio field
                        _buildSectionTitle(isDark, 'Bio'),
                        const SizedBox(height: 8),
                        _buildTextArea(
                          isDark,
                          _bioController,
                          'Conte um pouco sobre você...',
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(bool isDark, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
      ),
    );
  }

  Widget _buildTextField(
    bool isDark,
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTextArea(
    bool isDark,
    TextEditingController controller,
    String hint,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildCrefField(bool isDark) {
    final currentUser = ref.watch(currentUserProvider);
    final isVerified = currentUser?.crefVerified ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle(isDark, 'CREF (Registro Profissional)'),
            if (isVerified) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.success.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.badgeCheck,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verificado',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isDark
                ? AppColors.cardDark.withAlpha(150)
                : AppColors.card.withAlpha(200),
            border: Border.all(
              color: isVerified
                  ? AppColors.success.withAlpha(100)
                  : (isDark ? AppColors.borderDark : AppColors.border),
            ),
          ),
          child: TextField(
            controller: _crefController,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: 012345-G/SP',
              hintStyle: TextStyle(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
              prefixIcon: Icon(
                LucideIcons.award,
                size: 20,
                color: isVerified
                    ? AppColors.success
                    : (isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Informe seu registro no Conselho Regional de Educação Física',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSelector(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _goals.map((goal) {
        final isSelected = _selectedGoal == goal['value'];
        return GestureDetector(
          onTap: () {
            HapticUtils.lightImpact();
            setState(() {
              _selectedGoal = goal['value']!;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? (isDark ? AppColors.primaryDark : AppColors.primary)
                  : (isDark
                      ? AppColors.cardDark.withAlpha(150)
                      : AppColors.card.withAlpha(200)),
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppColors.primaryDark : AppColors.primary)
                    : (isDark ? AppColors.borderDark : AppColors.border),
              ),
            ),
            child: Text(
              goal['label']!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
