import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../app/app.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/providers/biometric_provider.dart';
import '../../../../core/domain/entities/user_role.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/platform_utils.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _workoutReminders = true;
  bool _nutritionReminders = false;
  bool _gamificationNotifications = true;
  bool _communicationNotifications = true;
  TimeOfDay _workoutReminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _dndEnabled = false;
  TimeOfDay _dndStartTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _dndEndTime = const TimeOfDay(hour: 7, minute: 0);
  String _cacheSize = '45.2 MB';
  bool _isClearing = false;

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      body: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(
                          'Configurações',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile section
                  _buildProfileSection(context, isDark),

                  const SizedBox(height: 24),

                  // Appearance
                  _buildSectionTitle(context, isDark, 'Aparência'),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
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
                          _buildThemeSelector(context, isDark),
                          _buildDivider(isDark),
                          _buildLanguageSelector(context, isDark, locale),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Notifications
                  _buildSectionTitle(context, isDark, 'Notificações'),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
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
                          _buildToggleTile(
                            context,
                            isDark,
                            LucideIcons.bell,
                            'Notificações Push',
                            'Receba notificações no seu dispositivo',
                            _pushNotifications,
                            (val) {
                              HapticUtils.selectionClick();
                              setState(() => _pushNotifications = val);
                            },
                          ),
                          _buildDivider(isDark),
                          _buildToggleTile(
                            context,
                            isDark,
                            LucideIcons.mail,
                            'Notificações por E-mail',
                            'Receba atualizações por e-mail',
                            _emailNotifications,
                            (val) {
                              HapticUtils.selectionClick();
                              setState(() => _emailNotifications = val);
                            },
                          ),
                          _buildDivider(isDark),
                          _buildToggleTile(
                            context,
                            isDark,
                            LucideIcons.dumbbell,
                            'Lembretes de Treino',
                            'Lembrar de fazer os treinos',
                            _workoutReminders,
                            (val) {
                              HapticUtils.selectionClick();
                              setState(() => _workoutReminders = val);
                            },
                          ),
                          _buildDivider(isDark),
                          _buildToggleTile(
                            context,
                            isDark,
                            LucideIcons.utensils,
                            'Lembretes de Refeicao',
                            'Lembrar das refeicoes do dia',
                            _nutritionReminders,
                            (val) {
                              HapticUtils.selectionClick();
                              setState(() => _nutritionReminders = val);
                            },
                          ),
                          _buildDivider(isDark),
                          _buildToggleTile(
                            context,
                            isDark,
                            LucideIcons.trophy,
                            'Conquistas e Gamificacao',
                            'Notificar sobre conquistas e streaks',
                            _gamificationNotifications,
                            (val) {
                              HapticUtils.selectionClick();
                              setState(() => _gamificationNotifications = val);
                            },
                          ),
                          _buildDivider(isDark),
                          _buildToggleTile(
                            context,
                            isDark,
                            LucideIcons.messageSquare,
                            'Mensagens e Convites',
                            'Notificar sobre novas mensagens',
                            _communicationNotifications,
                            (val) {
                              HapticUtils.selectionClick();
                              setState(() => _communicationNotifications = val);
                            },
                          ),
                          if (_workoutReminders) ...[
                            _buildDivider(isDark),
                            _buildTimeTile(
                              context,
                              isDark,
                              LucideIcons.alarmClock,
                              'Horario do Lembrete',
                              _formatTimeOfDay(_workoutReminderTime),
                              () => _selectWorkoutReminderTime(context, isDark),
                            ),
                          ],
                          _buildDivider(isDark),
                          _buildToggleTile(
                            context,
                            isDark,
                            LucideIcons.moonStar,
                            'Modo Nao Perturbe',
                            'Silenciar notificações em horários específicos',
                            _dndEnabled,
                            (val) {
                              HapticUtils.selectionClick();
                              setState(() => _dndEnabled = val);
                            },
                          ),
                          if (_dndEnabled) ...[
                            _buildDivider(isDark),
                            _buildTimeTile(
                              context,
                              isDark,
                              LucideIcons.clock,
                              'Início',
                              _formatTimeOfDay(_dndStartTime),
                              () => _selectDndTime(context, isDark, true),
                            ),
                            _buildDivider(isDark),
                            _buildTimeTile(
                              context,
                              isDark,
                              LucideIcons.alarmClockOff,
                              'Fim',
                              _formatTimeOfDay(_dndEndTime),
                              () => _selectDndTime(context, isDark, false),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Security
                  _buildSectionTitle(context, isDark, 'Seguranca'),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
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
                          // Biometric authentication toggle
                          Consumer(
                            builder: (context, ref, _) {
                              final biometricAvailable = ref.watch(biometricAvailableProvider);
                              final biometricEnabled = ref.watch(biometricEnabledProvider);

                              return biometricAvailable.when(
                                data: (available) {
                                  if (!available) {
                                    return _buildDisabledTile(
                                      context,
                                      isDark,
                                      LucideIcons.fingerprint,
                                      'Autenticação Biométrica',
                                      'Não disponível neste dispositivo',
                                    );
                                  }

                                  return biometricEnabled.when(
                                    data: (enabled) {
                                      final biometricLabel = ref.watch(biometricLabelProvider);
                                      final labelText = biometricLabel.when(
                                        data: (label) => 'Use $label para entrar',
                                        loading: () => 'Use biometria para entrar',
                                        error: (_, __) => 'Use biometria para entrar',
                                      );

                                      return _buildToggleTile(
                                        context,
                                        isDark,
                                        PlatformUtils.isIOS ? LucideIcons.scanFace : LucideIcons.fingerprint,
                                        'Autenticação Biométrica',
                                        labelText,
                                        enabled,
                                        (val) => _toggleBiometric(context, ref, val),
                                      );
                                    },
                                    loading: () => _buildLoadingTile(isDark),
                                    error: (_, __) => _buildDisabledTile(
                                      context,
                                      isDark,
                                      LucideIcons.fingerprint,
                                      'Autenticação Biométrica',
                                      'Erro ao verificar status',
                                    ),
                                  );
                                },
                                loading: () => _buildLoadingTile(isDark),
                                error: (_, __) => _buildDisabledTile(
                                  context,
                                  isDark,
                                  LucideIcons.fingerprint,
                                  'Autenticação Biométrica',
                                  'Não disponível neste dispositivo',
                                ),
                              );
                            },
                          ),
                          _buildDivider(isDark),
                          _buildNavTile(
                            context,
                            isDark,
                            LucideIcons.lock,
                            'Alterar Senha',
                            null,
                            () {
                              HapticUtils.lightImpact();
                              _showChangePasswordDialog(context, isDark);
                            },
                          ),
                          _buildDivider(isDark),
                          _buildNavTile(
                            context,
                            isDark,
                            LucideIcons.smartphone,
                            'Sessões Ativas',
                            '2 dispositivos',
                            () {
                              HapticUtils.lightImpact();
                              _showActiveSessionsDialog(context, isDark);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Data
                  _buildSectionTitle(context, isDark, 'Dados'),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
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
                          _buildNavTile(
                            context,
                            isDark,
                            LucideIcons.download,
                            'Exportar Dados',
                            null,
                            () {
                              HapticUtils.lightImpact();
                              _showExportDataDialog(context, isDark);
                            },
                          ),
                          _buildDivider(isDark),
                          _buildNavTile(
                            context,
                            isDark,
                            LucideIcons.trash2,
                            'Limpar Cache',
                            _isClearing ? 'Limpando...' : _cacheSize,
                            () {
                              if (!_isClearing) {
                                HapticUtils.lightImpact();
                                _clearCache(context, isDark);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Information section
                  _buildSectionTitle(context, isDark, 'Informações'),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
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
                          _buildNavTile(
                            context,
                            isDark,
                            LucideIcons.info,
                            'Sobre o App',
                            null,
                            () {
                              HapticUtils.lightImpact();
                              context.push(RouteNames.about);
                            },
                          ),
                          _buildDivider(isDark),
                          _buildNavTile(
                            context,
                            isDark,
                            LucideIcons.fileText,
                            'Termos de Uso',
                            null,
                            () {
                              HapticUtils.lightImpact();
                              context.push(RouteNames.terms);
                            },
                          ),
                          _buildDivider(isDark),
                          _buildNavTile(
                            context,
                            isDark,
                            LucideIcons.shield,
                            'Politica de Privacidade',
                            null,
                            () {
                              HapticUtils.lightImpact();
                              context.push(RouteNames.privacy);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account section
                  _buildSectionTitle(context, isDark, 'Conta'),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDark
                            ? AppColors.cardDark.withAlpha(150)
                            : AppColors.card.withAlpha(200),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      child: _buildNavTile(
                        context,
                        isDark,
                        LucideIcons.logOut,
                        'Sair',
                        null,
                        () {
                          HapticUtils.mediumImpact();
                          _showLogoutDialog(context, isDark);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Danger zone
                  _buildSectionTitle(context, isDark, 'Zona de Perigo'),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDark
                            ? AppColors.cardDark.withAlpha(150)
                            : AppColors.card.withAlpha(200),
                        border: Border.all(color: AppColors.destructive.withAlpha(50)),
                      ),
                      child: _buildNavTile(
                        context,
                        isDark,
                        LucideIcons.userX,
                        'Excluir Conta',
                        null,
                        () {
                          HapticUtils.mediumImpact();
                          _showDeleteAccountDialog(context, isDark);
                        },
                        isDestructive: true,
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

  Widget _buildSectionTitle(BuildContext context, bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: isDark
              ? AppColors.mutedForegroundDark
              : AppColors.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, bool isDark) {
    final user = ref.watch(currentUserProvider);
    final activeContext = ref.watch(activeContextProvider);
    final memberships = ref.watch(membershipsProvider).valueOrNull ?? [];

    // Check context: null = org selector, otherwise check role
    final isFromOrgSelector = activeContext == null;
    final isTrainerContext = !isFromOrgSelector && (activeContext?.isTrainer ?? false);
    final isStudentContext = !isFromOrgSelector && (activeContext?.membership.role == UserRole.student);

    // Check if user has student profile (for showing "add student" option on org selector)
    final hasStudentProfile = memberships.any((m) => m.role == UserRole.student);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withAlpha(isDark ? 30 : 15),
              (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
            ],
          ),
          border: Border.all(
            color: AppColors.primary.withAlpha(50),
          ),
        ),
        child: Column(
          children: [
            // User info header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withAlpha(25),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: user?.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user!.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(user.name),
                            ),
                          )
                        : _buildAvatarPlaceholder(user?.name ?? 'U'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Usuário',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                        if (!isFromOrgSelector) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: isTrainerContext
                                  ? AppColors.primary.withAlpha(25)
                                  : AppColors.secondary.withAlpha(25),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isTrainerContext ? LucideIcons.dumbbell : LucideIcons.user,
                                  size: 12,
                                  color: isTrainerContext ? AppColors.primary : AppColors.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isTrainerContext ? 'Personal Trainer' : 'Aluno',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isTrainerContext ? AppColors.primary : AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            // Always show: Edit Profile (account data)
            _buildProfileTile(
              context,
              isDark,
              LucideIcons.userCog,
              'Editar Perfil',
              'Nome, foto e dados pessoais',
              () {
                HapticUtils.lightImpact();
                _showEditProfileSheet(context, isDark);
              },
            ),
            // From Org Selector: Show "Adicionar perfil Aluno" if no student profile
            if (isFromOrgSelector && !hasStudentProfile) ...[
              Container(
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              _buildProfileTile(
                context,
                isDark,
                LucideIcons.userPlus,
                'Adicionar perfil Aluno',
                'Treinar e receber planos personalizados',
                () {
                  HapticUtils.lightImpact();
                  context.push(RouteNames.joinOrg);
                },
              ),
            ],
            // From Student context: Show "Meus Objetivos"
            if (isStudentContext) ...[
              Container(
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              _buildProfileTile(
                context,
                isDark,
                LucideIcons.target,
                'Meus Objetivos',
                'Objetivo, experiência, dados físicos',
                () {
                  HapticUtils.lightImpact();
                  context.push(
                    RouteNames.onboarding,
                    extra: {
                      'userType': 'student',
                      'editMode': true,
                      'skipOrgCreation': true,
                    },
                  );
                },
              ),
            ],
            // From Trainer context: Show "Dados Profissionais"
            if (isTrainerContext) ...[
              Container(
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              _buildProfileTile(
                context,
                isDark,
                LucideIcons.clipboardList,
                'Dados Profissionais',
                'CREF, especialidades',
                () {
                  HapticUtils.lightImpact();
                  context.push(
                    RouteNames.onboarding,
                    extra: {
                      'userType': 'personal',
                      'editMode': true,
                      'skipOrgCreation': true,
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.primary.withAlpha(15),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    final initials = name.isNotEmpty
        ? name.split(' ').take(2).map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join()
        : 'U';
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, bool isDark) {
    final user = ref.read(currentUserProvider);
    final nameController = TextEditingController(text: user?.name ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Editar Perfil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 24),
            // Avatar edit
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withAlpha(25),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: _buildAvatarPlaceholder(user?.name ?? 'U'),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        // TODO: Implement photo picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Funcionalidade em breve'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(LucideIcons.camera, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Name field
            Text(
              'Nome',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Seu nome completo',
                filled: true,
                fillColor: isDark ? AppColors.mutedDark : AppColors.muted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticUtils.lightImpact();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticUtils.mediumImpact();
                      // TODO: Save profile changes to API
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Perfil atualizado!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProfileDialog(BuildContext context, bool isDark, bool isCurrentlyTrainer) {
    final newProfileType = isCurrentlyTrainer ? 'Aluno' : 'Personal Trainer';
    final newUserType = isCurrentlyTrainer ? 'student' : 'personal';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primary.withAlpha(25),
                    ),
                    child: Icon(
                      isCurrentlyTrainer ? LucideIcons.user : LucideIcons.dumbbell,
                      size: 24,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adicionar Perfil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        Text(
                          newProfileType,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                isCurrentlyTrainer
                    ? 'Você poderá treinar como aluno e receber treinos de outros personais.'
                    : 'Você poderá criar treinos e acompanhar alunos como Personal Trainer.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticUtils.mediumImpact();
                        Navigator.pop(context);
                        // Navigate to onboarding for the new profile type
                        context.push(
                          RouteNames.onboarding,
                          extra: {
                            'userType': newUserType,
                            'addingProfile': true,
                            'skipOrgCreation': !isCurrentlyTrainer, // Only create org if becoming trainer
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Continuar'),
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

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 1,
      color: isDark ? AppColors.borderDark : AppColors.border,
    );
  }

  Widget _buildThemeSelector(BuildContext context, bool isDark) {
    final themeMode = ref.watch(themeModeProvider);

    String themeName;
    IconData themeIcon;
    switch (themeMode) {
      case ThemeMode.light:
        themeName = 'Claro';
        themeIcon = LucideIcons.sun;
        break;
      case ThemeMode.dark:
        themeName = 'Escuro';
        themeIcon = LucideIcons.moon;
        break;
      case ThemeMode.system:
        themeName = 'Sistema';
        themeIcon = LucideIcons.smartphone;
        break;
    }

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        _showThemeSelector(context, isDark, themeMode);
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              themeIcon,
              size: 20,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tema',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Escolha entre claro, escuro ou sistema',
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? AppColors.mutedDark : AppColors.muted,
              ),
              child: Row(
                children: [
                  Text(
                    themeName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.chevronDown,
                    size: 14,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context, bool isDark, ThemeMode currentTheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecionar Tema',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 20),
              _buildThemeOption(
                context,
                isDark,
                LucideIcons.sun,
                'Claro',
                'Tema claro para ambientes iluminados',
                ThemeMode.light,
                currentTheme == ThemeMode.light,
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context,
                isDark,
                LucideIcons.moon,
                'Escuro',
                'Tema escuro para economizar bateria',
                ThemeMode.dark,
                currentTheme == ThemeMode.dark,
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context,
                isDark,
                LucideIcons.smartphone,
                'Sistema',
                'Seguir configuração do dispositivo',
                ThemeMode.system,
                currentTheme == ThemeMode.system,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    ThemeMode mode,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        HapticUtils.mediumImpact();
        ref.read(themeModeProvider.notifier).state = mode;
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppColors.primary.withAlpha(25)
              : (isDark ? AppColors.cardDark : AppColors.card),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.foregroundDark : AppColors.foreground),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                    ),
                  ),
                  Text(
                    subtitle,
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
            if (isSelected)
              Icon(
                LucideIcons.check,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, bool isDark, Locale locale) {
    String languageName;
    String languageCode;

    switch (locale.languageCode) {
      case 'en':
        languageName = 'English';
        languageCode = 'EN';
        break;
      case 'es':
        languageName = 'Espanol';
        languageCode = 'ES';
        break;
      default:
        languageName = 'Portugues';
        languageCode = 'PT';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            LucideIcons.globe,
            size: 20,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Idioma',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Idioma do aplicativo',
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
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              _showLanguageSelector(context, isDark);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? AppColors.mutedDark : AppColors.muted,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primary.withAlpha(25),
                    ),
                    child: Text(
                      languageCode,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    languageName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.chevronDown,
                    size: 14,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => SafeArea(
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
            _buildLanguageOption(context, isDark, 'Portugues', 'PT', 'pt'),
            _buildLanguageOption(context, isDark, 'English', 'EN', 'en'),
            _buildLanguageOption(context, isDark, 'Espanol', 'ES', 'es'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    bool isDark,
    String label,
    String badge,
    String code,
  ) {
    final locale = ref.watch(localeProvider);
    final isSelected = locale.languageCode == code;

    return InkWell(
      onTap: () {
        HapticUtils.selectionClick();
        ref.read(localeProvider.notifier).state = Locale(code);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: isSelected
            ? (isDark ? AppColors.mutedDark : AppColors.muted)
            : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected
                    ? AppColors.primary.withAlpha(25)
                    : (isDark ? AppColors.mutedDark : AppColors.muted),
              ),
              child: Center(
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                  ),
                ),
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
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  // ============ DIALOG METHODS ============

  Future<void> _clearCache(BuildContext context, bool isDark) async {
    setState(() => _isClearing = true);

    try {
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
      }

      if (mounted) {
        setState(() {
          _cacheSize = '0 MB';
          _isClearing = false;
        });

        HapticUtils.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cache limpo com sucesso'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isClearing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao limpar cache'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  void _showChangePasswordDialog(BuildContext context, bool isDark) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.lock, size: 24, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Alterar Senha',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildPasswordField(currentPasswordController, 'Senha Atual', isDark),
              const SizedBox(height: 16),
              _buildPasswordField(newPasswordController, 'Nova Senha', isDark),
              const SizedBox(height: 16),
              _buildPasswordField(confirmPasswordController, 'Confirmar Nova Senha', isDark),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticUtils.mediumImpact();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Senha alterada com sucesso'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Salvar'),
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

  Widget _buildPasswordField(TextEditingController controller, String label, bool isDark) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? AppColors.mutedDark : AppColors.muted,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  void _showActiveSessionsDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sessões Ativas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dispositivos conectados a sua conta',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),
              _buildSessionItem(isDark, 'iPhone 15 Pro', 'Este dispositivo', true),
              const SizedBox(height: 12),
              _buildSessionItem(isDark, 'MacBook Pro', 'Último acesso: há 2 horas', false),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Outras sessões encerradas'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.logOut, size: 18),
                  label: const Text('Encerrar outras sessões'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    foregroundColor: AppColors.destructive,
                    side: BorderSide(color: AppColors.destructive.withAlpha(100)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionItem(bool isDark, String device, String status, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDark ? AppColors.mutedDark : AppColors.muted,
        border: isCurrent ? Border.all(color: AppColors.primary.withAlpha(50)) : null,
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.smartphone,
            size: 24,
            color: isCurrent ? AppColors.primary : (isDark ? AppColors.foregroundDark : AppColors.foreground),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    color: isCurrent ? AppColors.primary : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary.withAlpha(25),
              ),
              child: Text(
                'Atual',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  void _showExportDataDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.download, size: 24, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Exportar Dados',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Você receberá um arquivo com todos os seus dados:',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 16),
              _buildExportItem(isDark, LucideIcons.user, 'Perfil e informações pessoais'),
              _buildExportItem(isDark, LucideIcons.dumbbell, 'Histórico de treinos'),
              _buildExportItem(isDark, LucideIcons.utensils, 'Planos nutricionais'),
              _buildExportItem(isDark, LucideIcons.trendingUp, 'Dados de progresso'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticUtils.mediumImpact();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Exportação iniciada. Você receberá um email.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.mail, size: 18),
                      label: const Text('Enviar por Email'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
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

  Widget _buildExportItem(bool isDark, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, bool isDark) {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.destructive.withAlpha(25),
                    ),
                    child: Icon(LucideIcons.alertTriangle, size: 20, color: AppColors.destructive),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Excluir Conta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.destructive,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Esta ação é irreversível. Todos os seus dados serão permanentemente excluídos:',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 12),
              _buildDeleteItem(isDark, 'Perfil e informações pessoais'),
              _buildDeleteItem(isDark, 'Histórico de treinos e progresso'),
              _buildDeleteItem(isDark, 'Assinaturas e pagamentos'),
              _buildDeleteItem(isDark, 'Vínculos com organizações'),
              const SizedBox(height: 20),
              Text(
                'Digite EXCLUIR para confirmar:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'EXCLUIR',
                  filled: true,
                  fillColor: isDark ? AppColors.mutedDark : AppColors.muted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.destructive.withAlpha(50)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.destructive.withAlpha(50)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.destructive),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (confirmController.text.toUpperCase() == 'EXCLUIR') {
                          HapticUtils.heavyImpact();
                          Navigator.pop(context);
                          context.go(RouteNames.welcome);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Conta excluída'),
                              backgroundColor: AppColors.destructive,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.destructive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Excluir Conta'),
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

  Widget _buildDeleteItem(bool isDark, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(LucideIcons.x, size: 14, color: AppColors.destructive),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primary.withAlpha(25),
                    ),
                    child: Icon(LucideIcons.logOut, size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sair da conta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Tem certeza que deseja sair? Você precisará fazer login novamente para acessar sua conta.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticUtils.mediumImpact();
                        Navigator.pop(context);

                        await ref.read(authProvider.notifier).logout();

                        if (mounted) {
                          context.go(RouteNames.welcome);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Sair'),
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

  Widget _buildToggleTile(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String? trailing,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive
                  ? AppColors.destructive
                  : (isDark ? AppColors.foregroundDark : AppColors.foreground),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: isDestructive
                      ? AppColors.destructive
                      : (isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground),
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: isDestructive
                  ? AppColors.destructive.withAlpha(150)
                  : (isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledTile(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.mutedForegroundDark.withAlpha(150) : AppColors.mutedForeground.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: false,
            onChanged: null,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingTile(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            LucideIcons.fingerprint,
            size: 20,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Autenticação Biométrica',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Verificando...',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String time,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? AppColors.mutedDark : AppColors.muted,
              ),
              child: Row(
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 14,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectWorkoutReminderTime(BuildContext context, bool isDark) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _workoutReminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(primary: AppColors.primary)
                : const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        _workoutReminderTime = selectedTime;
      });
    }
  }

  Future<void> _selectDndTime(BuildContext context, bool isDark, bool isStart) async {
    final initialTime = isStart ? _dndStartTime : _dndEndTime;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      HapticUtils.selectionClick();
      setState(() {
        if (isStart) {
          _dndStartTime = selectedTime;
        } else {
          _dndEndTime = selectedTime;
        }
      });
    }
  }

  Future<void> _toggleBiometric(BuildContext context, WidgetRef ref, bool enable) async {
    final service = ref.read(biometricServiceProvider);
    HapticUtils.selectionClick();

    if (enable) {
      // Show dialog to enter credentials
      final result = await showDialog<({String email, String password})?>(
        context: context,
        builder: (context) => _BiometricSetupDialog(),
      );

      if (result != null) {
        await service.saveCredentials(result.email, result.password);
        ref.invalidate(biometricEnabledProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Autenticação biométrica ativada'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      await service.clearCredentials();
      ref.invalidate(biometricEnabledProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Autenticação biométrica desativada'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _BiometricSetupDialog extends StatefulWidget {
  @override
  State<_BiometricSetupDialog> createState() => _BiometricSetupDialogState();
}

class _BiometricSetupDialogState extends State<_BiometricSetupDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PlatformUtils.isIOS ? LucideIcons.scanFace : LucideIcons.fingerprint,
                  size: 24,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Configurar Biometria',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Digite suas credenciais para ativar o login com biometria:',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: isDark ? AppColors.mutedDark : AppColors.muted,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Senha',
                filled: true,
                fillColor: isDark ? AppColors.mutedDark : AppColors.muted,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticUtils.lightImpact();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text;

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Preencha todos os campos'),
                            backgroundColor: AppColors.destructive,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      HapticUtils.mediumImpact();
                      Navigator.pop(context, (email: email, password: password));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Ativar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
