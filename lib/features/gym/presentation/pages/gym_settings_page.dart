import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/domain/entities/user_role.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../../../shared/presentation/components/role_bottom_navigation.dart';

/// Settings page for Gym/Academy owners and admins
class GymSettingsPage extends ConsumerStatefulWidget {
  const GymSettingsPage({super.key});

  @override
  ConsumerState<GymSettingsPage> createState() => _GymSettingsPageState();
}

class _GymSettingsPageState extends ConsumerState<GymSettingsPage> {
  // Track expanded sections
  final Set<String> _expandedSections = {};

  // Mock data
  final _gymProfile = {
    'name': 'Academia FitPro',
    'description': 'A melhor academia da regiao',
    'address': 'Rua das Flores, 123 - Centro',
    'hours': 'Seg-Sex: 6h-22h | Sab: 8h-18h',
    'logoUrl': null,
  };

  final _checkInSettings = {
    'qrCodeEnabled': true,
    'timeLimit': 120, // minutes
    'notifyOnCheckIn': true,
    'notifyOnCheckOut': false,
  };

  void _toggleSection(String section) {
    HapticUtils.lightImpact();
    setState(() {
      if (_expandedSections.contains(section)) {
        _expandedSections.remove(section);
      } else {
        _expandedSections.add(section);
      }
    });
  }

  bool _isSectionExpanded(String section) {
    return _expandedSections.contains(section);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      bottomNavigationBar: const RoleBottomNavigation(
        role: UserRole.gymOwner,
        currentIndex: 4, // Config tab
      ),
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
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: FadeInUp(
                  child: Padding(
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
                              color: (isDark ? AppColors.cardDark : AppColors.card)
                                  .withAlpha(isDark ? 150 : 200),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              LucideIcons.arrowLeft,
                              size: 20,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
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
                ),
              ),

              // Settings Sections
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Perfil da Academia
                    FadeInUp(
                      delay: const Duration(milliseconds: 50),
                      child: _buildExpandableSection(
                        context,
                        theme,
                        isDark,
                        sectionKey: 'profile',
                        title: 'Perfil da Academia',
                        icon: LucideIcons.building2,
                        color: AppColors.primary,
                        children: [
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.type,
                            title: 'Nome',
                            subtitle: _gymProfile['name'] as String,
                            onTap: () => _showEditDialog(context, isDark, 'Nome', _gymProfile['name'] as String),
                          ),
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.image,
                            title: 'Logo',
                            subtitle: 'Toque para alterar',
                            onTap: () => _showImagePickerDialog(context, isDark),
                          ),
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.fileText,
                            title: 'Descrição',
                            subtitle: _gymProfile['description'] as String,
                            onTap: () => _showEditDialog(context, isDark, 'Descrição', _gymProfile['description'] as String),
                          ),
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.mapPin,
                            title: 'Endereço',
                            subtitle: _gymProfile['address'] as String,
                            onTap: () => _showEditDialog(context, isDark, 'Endereço', _gymProfile['address'] as String),
                          ),
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.clock,
                            title: 'Horário de Funcionamento',
                            subtitle: _gymProfile['hours'] as String,
                            onTap: () => _showHoursDialog(context, isDark),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Planos e Precos
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: _buildExpandableSection(
                        context,
                        theme,
                        isDark,
                        sectionKey: 'plans',
                        title: 'Planos e Preços',
                        icon: LucideIcons.creditCard,
                        color: AppColors.success,
                        children: [
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.list,
                            title: 'Gerenciar Planos',
                            subtitle: '4 planos ativos',
                            onTap: () => _navigateToPlans(context),
                          ),
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.dollarSign,
                            title: 'Tabela de Preços',
                            subtitle: 'Configurar valores',
                            onTap: () => _navigateToPricing(context),
                          ),
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.percent,
                            title: 'Promoções',
                            subtitle: '2 promoções ativas',
                            onTap: () => _navigateToPromotions(context),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Check-in
                    FadeInUp(
                      delay: const Duration(milliseconds: 150),
                      child: _buildExpandableSection(
                        context,
                        theme,
                        isDark,
                        sectionKey: 'checkin',
                        title: 'Check-in',
                        icon: LucideIcons.qrCode,
                        color: AppColors.secondary,
                        children: [
                          _buildToggleTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.qrCode,
                            title: 'QR Code',
                            subtitle: 'Permitir check-in via QR Code',
                            value: _checkInSettings['qrCodeEnabled'] as bool,
                            onChanged: (val) {
                              HapticUtils.selectionClick();
                              setState(() => _checkInSettings['qrCodeEnabled'] = val);
                            },
                          ),
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.timer,
                            title: 'Tempo Limite',
                            subtitle: '${_checkInSettings['timeLimit']} minutos',
                            onTap: () => _showTimeLimitDialog(context, isDark),
                          ),
                          _buildToggleTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.bellRing,
                            title: 'Notificar Check-in',
                            subtitle: 'Receber alerta quando aluno entrar',
                            value: _checkInSettings['notifyOnCheckIn'] as bool,
                            onChanged: (val) {
                              HapticUtils.selectionClick();
                              setState(() => _checkInSettings['notifyOnCheckIn'] = val);
                            },
                          ),
                          _buildToggleTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.bellOff,
                            title: 'Notificar Check-out',
                            subtitle: 'Receber alerta quando aluno sair',
                            value: _checkInSettings['notifyOnCheckOut'] as bool,
                            onChanged: (val) {
                              HapticUtils.selectionClick();
                              setState(() => _checkInSettings['notifyOnCheckOut'] = val);
                            },
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Equipe
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: _buildExpandableSection(
                        context,
                        theme,
                        isDark,
                        sectionKey: 'team',
                        title: 'Equipe',
                        icon: LucideIcons.users,
                        color: AppColors.accent,
                        children: [
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.shield,
                            title: 'Permissões',
                            subtitle: 'Gerenciar acessos da equipe',
                            onTap: () => _navigateToPermissions(context),
                          ),
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.userPlus,
                            title: 'Convidar Membro',
                            subtitle: 'Enviar convite por email',
                            onTap: () => _showInviteDialog(context, isDark),
                          ),
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.userCheck,
                            title: 'Funcionarios',
                            subtitle: '8 membros ativos',
                            onTap: () => _navigateToStaff(context),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Notificacoes
                    FadeInUp(
                      delay: const Duration(milliseconds: 250),
                      child: _buildExpandableSection(
                        context,
                        theme,
                        isDark,
                        sectionKey: 'notifications',
                        title: 'Notificações',
                        icon: LucideIcons.bell,
                        color: AppColors.warning,
                        children: [
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.messageSquare,
                            title: 'Alertas',
                            subtitle: 'Configurar tipos de alertas',
                            onTap: () => _navigateToAlerts(context),
                          ),
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.calendar,
                            title: 'Lembretes Automaticos',
                            subtitle: 'Mensagens programadas',
                            onTap: () => _navigateToReminders(context),
                          ),
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.mail,
                            title: 'Templates de Email',
                            subtitle: 'Personalizar mensagens',
                            onTap: () => _navigateToEmailTemplates(context),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Integracoes
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: _buildExpandableSection(
                        context,
                        theme,
                        isDark,
                        sectionKey: 'integrations',
                        title: 'Integrações',
                        icon: LucideIcons.plug,
                        color: AppColors.info,
                        children: [
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.link,
                            title: 'Apps Conectados',
                            subtitle: '2 integracoes ativas',
                            onTap: () => _navigateToConnectedApps(context),
                          ),
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.download,
                            title: 'Exportar Dados',
                            subtitle: 'CSV, Excel, PDF',
                            onTap: () => _showExportDialog(context, isDark),
                          ),
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.upload,
                            title: 'Importar Dados',
                            subtitle: 'Migrar de outro sistema',
                            onTap: () => _showImportDialog(context, isDark),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Avançado
                    FadeInUp(
                      delay: const Duration(milliseconds: 350),
                      child: _buildExpandableSection(
                        context,
                        theme,
                        isDark,
                        sectionKey: 'advanced',
                        title: 'Avançado',
                        icon: LucideIcons.settings2,
                        color: AppColors.destructive,
                        children: [
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.hardDrive,
                            title: 'Backup',
                            subtitle: 'Último: 13/01/2026',
                            onTap: () => _showBackupDialog(context, isDark),
                          ),
                          _buildSettingsTile(
                            context,
                            theme,
                            isDark,
                            icon: LucideIcons.trash2,
                            title: 'Excluir Academia',
                            subtitle: 'Ação irreversível',
                            onTap: () => _showDeleteGymDialog(context, isDark),
                            isDestructive: true,
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection(
    BuildContext context,
    ThemeData theme,
    bool isDark, {
    required String sectionKey,
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    final isExpanded = _isSectionExpanded(sectionKey);

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Section Header
          InkWell(
            onTap: () => _toggleSection(sectionKey),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 20, color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      LucideIcons.chevronDown,
                      size: 20,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Container(
                  height: 1,
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                ...children,
              ],
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            HapticUtils.lightImpact();
            onTap();
          },
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDestructive
                              ? AppColors.destructive
                              : (isDark ? AppColors.foregroundDark : AppColors.foreground),
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
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: isDestructive
                      ? AppColors.destructive.withAlpha(150)
                      : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 50),
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
      ],
    );
  }

  Widget _buildToggleTile(
    BuildContext context,
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
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
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
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
                activeTrackColor: AppColors.primary.withAlpha(150),
                activeThumbColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 50),
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
      ],
    );
  }

  // ============ DIALOG METHODS ============

  void _showEditDialog(BuildContext context, bool isDark, String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);

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
              Text(
                'Editar $field',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: field,
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
                        _showSuccessSnackBar(context, '$field atualizado com sucesso');
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

  void _showImagePickerDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Alterar Logo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 20),
              _buildBottomSheetOption(
                context,
                isDark,
                LucideIcons.camera,
                'Tirar Foto',
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(context);
                  _showSuccessSnackBar(context, 'Funcionalidade em desenvolvimento');
                },
              ),
              _buildBottomSheetOption(
                context,
                isDark,
                LucideIcons.image,
                'Escolher da Galeria',
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(context);
                  _showSuccessSnackBar(context, 'Funcionalidade em desenvolvimento');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHoursDialog(BuildContext context, bool isDark) {
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
                  Icon(LucideIcons.clock, size: 24, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Horário de Funcionamento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildHoursRow(context, isDark, 'Segunda a Sexta', '06:00', '22:00'),
              const SizedBox(height: 12),
              _buildHoursRow(context, isDark, 'Sábado', '08:00', '18:00'),
              const SizedBox(height: 12),
              _buildHoursRow(context, isDark, 'Domingo', 'Fechado', ''),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    Navigator.pop(context);
                    _showSuccessSnackBar(context, 'Horários atualizados');
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
        ),
      ),
    );
  }

  Widget _buildHoursRow(BuildContext context, bool isDark, String day, String open, String close) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.mutedDark : AppColors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              open,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ),
          if (close.isNotEmpty) ...[
            Text(
              '-',
              style: TextStyle(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            Expanded(
              child: Text(
                close,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showTimeLimitDialog(BuildContext context, bool isDark) {
    final options = [30, 60, 90, 120, 180, 240];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tempo Limite de Check-in',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tempo máximo que um aluno pode permanecer na academia',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 20),
              ...options.map((minutes) {
                final isSelected = _checkInSettings['timeLimit'] == minutes;
                return InkWell(
                  onTap: () {
                    HapticUtils.selectionClick();
                    setState(() => _checkInSettings['timeLimit'] = minutes);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha(25)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.borderDark : AppColors.border),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$minutes minutos',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(LucideIcons.check, size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context, bool isDark) {
    final emailController = TextEditingController();

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
                  Icon(LucideIcons.userPlus, size: 24, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Convidar Membro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'email@exemplo.com',
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
                        _showSuccessSnackBar(context, 'Convite enviado');
                      },
                      icon: const Icon(LucideIcons.send, size: 18),
                      label: const Text('Enviar'),
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

  void _showExportDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exportar Dados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha o formato de exportação',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 20),
              _buildExportOption(context, isDark, 'CSV', LucideIcons.fileSpreadsheet),
              _buildExportOption(context, isDark, 'Excel', LucideIcons.table),
              _buildExportOption(context, isDark, 'PDF', LucideIcons.fileText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportOption(BuildContext context, bool isDark, String format, IconData icon) {
    return InkWell(
      onTap: () {
        HapticUtils.lightImpact();
        Navigator.pop(context);
        _showSuccessSnackBar(context, 'Exportando dados em $format...');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.mutedDark : AppColors.muted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(width: 16),
            Text(
              format,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const Spacer(),
            Icon(
              LucideIcons.download,
              size: 18,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.upload, size: 32, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Importar Dados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Arraste um arquivo CSV ou clique para selecionar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(context);
                    _showSuccessSnackBar(context, 'Funcionalidade em desenvolvimento');
                  },
                  icon: const Icon(LucideIcons.file, size: 18),
                  label: const Text('Selecionar Arquivo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBackupDialog(BuildContext context, bool isDark) {
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
                  Icon(LucideIcons.hardDrive, size: 24, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Backup',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.mutedDark : AppColors.muted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.checkCircle, size: 20, color: AppColors.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Último backup',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                          Text(
                            '13/01/2026 às 10:30',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    Navigator.pop(context);
                    _showSuccessSnackBar(context, 'Backup iniciado');
                  },
                  icon: const Icon(LucideIcons.hardDrive, size: 18),
                  label: const Text('Fazer Backup Agora'),
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
        ),
      ),
    );
  }

  void _showDeleteGymDialog(BuildContext context, bool isDark) {
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
                    'Excluir Academia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.destructive,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Esta ação é irreversível. Todos os dados serão permanentemente excluídos:',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 12),
              _buildDeleteItem(isDark, 'Dados de alunos e funcionários'),
              _buildDeleteItem(isDark, 'Histórico de check-ins'),
              _buildDeleteItem(isDark, 'Registros financeiros'),
              _buildDeleteItem(isDark, 'Configurações e integrações'),
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
                          context.go('/');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.destructive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Excluir'),
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

  Widget _buildBottomSheetOption(
    BuildContext context,
    bool isDark,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // ============ NAVIGATION METHODS ============

  // 1. Navigate to Staff Page (rota existente)
  void _navigateToStaff(BuildContext context) {
    HapticUtils.lightImpact();
    context.push('/staff');
  }

  // 2. Navigate to Plans - Modal com lista de planos
  void _navigateToPlans(BuildContext context) {
    HapticUtils.lightImpact();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock data para planos
    final plans = [
      {'id': '1', 'name': 'Plano Básico', 'price': 89.90, 'duration': '1 mês', 'active': true, 'subscribers': 45},
      {'id': '2', 'name': 'Plano Trimestral', 'price': 239.90, 'duration': '3 meses', 'active': true, 'subscribers': 32},
      {'id': '3', 'name': 'Plano Semestral', 'price': 449.90, 'duration': '6 meses', 'active': true, 'subscribers': 28},
      {'id': '4', 'name': 'Plano Anual', 'price': 799.90, 'duration': '12 meses', 'active': true, 'subscribers': 56},
      {'id': '5', 'name': 'Plano Dia', 'price': 25.00, 'duration': '1 dia', 'active': false, 'subscribers': 0},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.list, size: 22, color: AppColors.success),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gerenciar Planos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        Text(
                          '${plans.where((p) => p['active'] == true).length} planos ativos',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      LucideIcons.x,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
            // Plans List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final isActive = plan['active'] as bool;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.mutedDark : AppColors.muted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? AppColors.success.withAlpha(50) : (isDark ? AppColors.borderDark : AppColors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    plan['name'] as String,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isActive ? AppColors.success.withAlpha(25) : AppColors.destructive.withAlpha(25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isActive ? 'Ativo' : 'Inativo',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isActive ? AppColors.success : AppColors.destructive,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(LucideIcons.clock, size: 14, color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                                  const SizedBox(width: 4),
                                  Text(
                                    plan['duration'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(LucideIcons.users, size: 14, color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${plan['subscribers']} assinantes',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'R\$ ${(plan['price'] as double).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                HapticUtils.lightImpact();
                                Navigator.pop(context);
                                _showSuccessSnackBar(context, 'Editando ${plan['name']}...');
                              },
                              icon: Icon(LucideIcons.edit, size: 18, color: AppColors.primary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Add Plan Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    Navigator.pop(context);
                    _showSuccessSnackBar(context, 'Criar novo plano...');
                  },
                  icon: const Icon(LucideIcons.plus, size: 20),
                  label: const Text('Adicionar Plano'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Navigate to Pricing - Modal de configuracao de precos
  void _navigateToPricing(BuildContext context) {
    HapticUtils.lightImpact();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock data para precos
    final priceCategories = [
      {'category': 'Musculação', 'items': [
        {'name': 'Acesso mensal', 'price': 89.90},
        {'name': 'Acesso trimestral', 'price': 239.90},
        {'name': 'Acesso anual', 'price': 799.90},
      ]},
      {'category': 'Aulas em Grupo', 'items': [
        {'name': 'Pacote 8 aulas', 'price': 120.00},
        {'name': 'Pacote 16 aulas', 'price': 200.00},
        {'name': 'Aula avulsa', 'price': 25.00},
      ]},
      {'category': 'Personal Trainer', 'items': [
        {'name': 'Sessão avulsa', 'price': 80.00},
        {'name': 'Pacote 10 sessões', 'price': 700.00},
        {'name': 'Mensal (12 sessões)', 'price': 850.00},
      ]},
      {'category': 'Serviços Extras', 'items': [
        {'name': 'Avaliação física', 'price': 50.00},
        {'name': 'Armário mensal', 'price': 30.00},
        {'name': 'Toalha', 'price': 5.00},
      ]},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.dollarSign, size: 22, color: AppColors.success),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tabela de Preços',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        Text(
                          'Configure os valores dos serviços',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      LucideIcons.x,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
            // Price Categories
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: priceCategories.length,
                itemBuilder: (context, categoryIndex) {
                  final category = priceCategories[categoryIndex];
                  final items = category['items'] as List<Map<String, dynamic>>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.mutedDark : AppColors.muted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            category['category'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                        ),
                        Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
                        ...items.map((item) => InkWell(
                          onTap: () {
                            HapticUtils.lightImpact();
                            // Aqui poderia abrir um dialog para editar o preco
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'R\$ ${(item['price'] as double).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(LucideIcons.edit, size: 16, color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Save Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    Navigator.pop(context);
                    _showSuccessSnackBar(context, 'Preços atualizados com sucesso');
                  },
                  icon: const Icon(LucideIcons.save, size: 20),
                  label: const Text('Salvar Alterações'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Navigate to Promotions - Modal de promoções ativas
  void _navigateToPromotions(BuildContext context) {
    HapticUtils.lightImpact();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock data para promocoes
    final promotions = [
      {
        'id': '1',
        'name': 'Verao Fitness',
        'discount': 20,
        'type': 'percentage',
        'validUntil': '28/02/2026',
        'code': 'VERAO20',
        'active': true,
        'uses': 45,
      },
      {
        'id': '2',
        'name': 'Primeira Matrícula',
        'discount': 50,
        'type': 'fixed',
        'validUntil': '31/12/2026',
        'code': 'BEMVINDO',
        'active': true,
        'uses': 128,
      },
      {
        'id': '3',
        'name': 'Indique um Amigo',
        'discount': 15,
        'type': 'percentage',
        'validUntil': '30/06/2026',
        'code': 'AMIGO15',
        'active': false,
        'uses': 23,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.percent, size: 22, color: AppColors.warning),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Promoções',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        Text(
                          '${promotions.where((p) => p['active'] == true).length} promoções ativas',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      LucideIcons.x,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
            // Promotions List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: promotions.length,
                itemBuilder: (context, index) {
                  final promo = promotions[index];
                  final isActive = promo['active'] as bool;
                  final isPercentage = promo['type'] == 'percentage';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.mutedDark : AppColors.muted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? AppColors.warning.withAlpha(50) : (isDark ? AppColors.borderDark : AppColors.border),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  promo['name'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isActive ? AppColors.success.withAlpha(25) : AppColors.destructive.withAlpha(25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isActive ? 'Ativa' : 'Inativa',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isActive ? AppColors.success : AppColors.destructive,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isPercentage ? '${promo['discount']}% OFF' : 'R\$ ${promo['discount']} OFF',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildPromoInfo(isDark, LucideIcons.tag, 'Código: ${promo['code']}'),
                            const SizedBox(width: 20),
                            _buildPromoInfo(isDark, LucideIcons.calendar, 'Ate ${promo['validUntil']}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPromoInfo(isDark, LucideIcons.trendingUp, '${promo['uses']} usos'),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    HapticUtils.lightImpact();
                                  },
                                  icon: Icon(LucideIcons.edit, size: 18, color: AppColors.primary),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: () {
                                    HapticUtils.lightImpact();
                                  },
                                  icon: Icon(LucideIcons.trash2, size: 18, color: AppColors.destructive),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Add Promotion Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    Navigator.pop(context);
                    _showSuccessSnackBar(context, 'Criar nova promoção...');
                  },
                  icon: const Icon(LucideIcons.plus, size: 20),
                  label: const Text('Nova Promoção'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoInfo(bool isDark, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  // 5. Navigate to Permissions - Modal de permissoes de funcionarios
  void _navigateToPermissions(BuildContext context) {
    HapticUtils.lightImpact();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock data para cargos e permissoes
    final roles = [
      {
        'name': 'Administrador',
        'icon': LucideIcons.crown,
        'color': AppColors.warning,
        'permissions': {
          'gerenciar_planos': true,
          'gerenciar_funcionarios': true,
          'gerenciar_financeiro': true,
          'gerenciar_alunos': true,
          'visualizar_relatorios': true,
          'configuracoes_avancadas': true,
        },
      },
      {
        'name': 'Recepcionista',
        'icon': LucideIcons.userCheck,
        'color': AppColors.info,
        'permissions': {
          'gerenciar_planos': false,
          'gerenciar_funcionarios': false,
          'gerenciar_financeiro': false,
          'gerenciar_alunos': true,
          'visualizar_relatorios': false,
          'configuracoes_avancadas': false,
        },
      },
      {
        'name': 'Personal Trainer',
        'icon': LucideIcons.dumbbell,
        'color': AppColors.success,
        'permissions': {
          'gerenciar_planos': false,
          'gerenciar_funcionarios': false,
          'gerenciar_financeiro': false,
          'gerenciar_alunos': true,
          'visualizar_relatorios': false,
          'configuracoes_avancadas': false,
        },
      },
      {
        'name': 'Instrutor',
        'icon': LucideIcons.graduationCap,
        'color': AppColors.secondary,
        'permissions': {
          'gerenciar_planos': false,
          'gerenciar_funcionarios': false,
          'gerenciar_financeiro': false,
          'gerenciar_alunos': false,
          'visualizar_relatorios': false,
          'configuracoes_avancadas': false,
        },
      },
    ];

    final permissionLabels = {
      'gerenciar_planos': 'Gerenciar Planos',
      'gerenciar_funcionarios': 'Gerenciar Funcionários',
      'gerenciar_financeiro': 'Gerenciar Financeiro',
      'gerenciar_alunos': 'Gerenciar Alunos',
      'visualizar_relatorios': 'Visualizar Relatórios',
      'configuracoes_avancadas': 'Configurações Avançadas',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.shield, size: 22, color: AppColors.accent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permissões',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                          Text(
                            'Configure acessos por cargo',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        LucideIcons.x,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
              // Roles List with Permissions
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final role = roles[index];
                    final permissions = role['permissions'] as Map<String, bool>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mutedDark : AppColors.muted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (role['color'] as Color).withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(role['icon'] as IconData, size: 20, color: role['color'] as Color),
                          ),
                          title: Text(
                            role['name'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                          subtitle: Text(
                            '${permissions.values.where((v) => v).length} permissoes ativas',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                          children: permissionLabels.entries.map((entry) {
                            final isEnabled = permissions[entry.key] ?? false;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                    ),
                                  ),
                                  Switch(
                                    value: isEnabled,
                                    onChanged: (val) {
                                      HapticUtils.selectionClick();
                                      setModalState(() {
                                        permissions[entry.key] = val;
                                      });
                                    },
                                    activeTrackColor: AppColors.primary.withAlpha(150),
                                    activeThumbColor: AppColors.primary,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Save Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticUtils.mediumImpact();
                      Navigator.pop(context);
                      _showSuccessSnackBar(context, 'Permissões salvas com sucesso');
                    },
                    icon: const Icon(LucideIcons.save, size: 20),
                    label: const Text('Salvar Permissões'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 6. Navigate to Alerts - Modal de configuracao de alertas
  void _navigateToAlerts(BuildContext context) {
    HapticUtils.lightImpact();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock data para alertas
    final alertSettings = {
      'novoAluno': true,
      'checkIn': false,
      'checkOut': false,
      'pagamentoPendente': true,
      'planoVencendo': true,
      'avaliacaoAgendada': true,
      'metaBatida': true,
      'novaAvaliacao': false,
    };

    final alertLabels = {
      'novoAluno': {'title': 'Novo Aluno', 'subtitle': 'Quando um novo aluno se cadastrar', 'icon': LucideIcons.userPlus},
      'checkIn': {'title': 'Check-in', 'subtitle': 'Quando um aluno entrar na academia', 'icon': LucideIcons.logIn},
      'checkOut': {'title': 'Check-out', 'subtitle': 'Quando um aluno sair da academia', 'icon': LucideIcons.logOut},
      'pagamentoPendente': {'title': 'Pagamento Pendente', 'subtitle': 'Quando houver pagamentos em atraso', 'icon': LucideIcons.alertCircle},
      'planoVencendo': {'title': 'Plano Vencendo', 'subtitle': 'Quando um plano estiver próximo do vencimento', 'icon': LucideIcons.calendarClock},
      'avaliacaoAgendada': {'title': 'Avaliação Agendada', 'subtitle': 'Quando uma avaliação for agendada', 'icon': LucideIcons.clipboardCheck},
      'metaBatida': {'title': 'Meta Batida', 'subtitle': 'Quando um aluno atingir uma meta', 'icon': LucideIcons.trophy},
      'novaAvaliacao': {'title': 'Nova Avaliação', 'subtitle': 'Quando uma avaliação for concluída', 'icon': LucideIcons.star},
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.bell, size: 22, color: AppColors.warning),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configurar Alertas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                          Text(
                            'Escolha quais notificações receber',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        LucideIcons.x,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
              // Alerts List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: alertLabels.length,
                  itemBuilder: (context, index) {
                    final key = alertLabels.keys.elementAt(index);
                    final alert = alertLabels[key]!;
                    final isEnabled = alertSettings[key] ?? false;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mutedDark : AppColors.muted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isEnabled ? AppColors.warning.withAlpha(50) : (isDark ? AppColors.borderDark : AppColors.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            alert['icon'] as IconData,
                            size: 22,
                            color: isEnabled ? AppColors.warning : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert['title'] as String,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  alert['subtitle'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isEnabled,
                            onChanged: (val) {
                              HapticUtils.selectionClick();
                              setModalState(() {
                                alertSettings[key] = val;
                              });
                            },
                            activeTrackColor: AppColors.warning.withAlpha(150),
                            activeThumbColor: AppColors.warning,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Save Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticUtils.mediumImpact();
                      Navigator.pop(context);
                      _showSuccessSnackBar(context, 'Alertas configurados com sucesso');
                    },
                    icon: const Icon(LucideIcons.save, size: 20),
                    label: const Text('Salvar Configurações'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 7. Navigate to Reminders - Modal de lembretes automaticos
  void _navigateToReminders(BuildContext context) {
    HapticUtils.lightImpact();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock data para lembretes
    final reminders = [
      {
        'id': '1',
        'title': 'Lembrete de Pagamento',
        'message': 'Olá! Seu plano vence em 3 dias. Renovar agora!',
        'trigger': '3 dias antes do vencimento',
        'channel': 'push',
        'active': true,
      },
      {
        'id': '2',
        'title': 'Boas-vindas',
        'message': 'Bem-vindo à Academia FitPro! Estamos felizes em tê-lo conosco.',
        'trigger': 'Ao se cadastrar',
        'channel': 'email',
        'active': true,
      },
      {
        'id': '3',
        'title': 'Inatividade',
        'message': 'Sentimos sua falta! Volte a treinar e mantenha seu foco.',
        'trigger': '7 dias sem check-in',
        'channel': 'push',
        'active': true,
      },
      {
        'id': '4',
        'title': 'Aniversário',
        'message': 'Feliz aniversário! Presenteamos você com 10% de desconto.',
        'trigger': 'No dia do aniversário',
        'channel': 'push',
        'active': false,
      },
      {
        'id': '5',
        'title': 'Avaliação Física',
        'message': 'Hora de fazer sua avaliação física! Agende agora.',
        'trigger': '30 dias após última avaliação',
        'channel': 'email',
        'active': true,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.info.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.calendar, size: 22, color: AppColors.info),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lembretes Automaticos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        Text(
                          '${reminders.where((r) => r['active'] == true).length} lembretes ativos',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      LucideIcons.x,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
            // Reminders List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  final isActive = reminder['active'] as bool;
                  final isPush = reminder['channel'] == 'push';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.mutedDark : AppColors.muted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? AppColors.info.withAlpha(50) : (isDark ? AppColors.borderDark : AppColors.border),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    reminder['title'] as String,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (isPush ? AppColors.primary : AppColors.info).withAlpha(25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isPush ? LucideIcons.bell : LucideIcons.mail,
                                          size: 12,
                                          color: isPush ? AppColors.primary : AppColors.info,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isPush ? 'Push' : 'Email',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isPush ? AppColors.primary : AppColors.info,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.success.withAlpha(25) : AppColors.destructive.withAlpha(25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isActive ? 'Ativo' : 'Inativo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? AppColors.success : AppColors.destructive,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reminder['message'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.clock, size: 14, color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                                const SizedBox(width: 4),
                                Text(
                                  reminder['trigger'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    HapticUtils.lightImpact();
                                  },
                                  icon: Icon(LucideIcons.edit, size: 18, color: AppColors.primary),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: () {
                                    HapticUtils.lightImpact();
                                  },
                                  icon: Icon(LucideIcons.trash2, size: 18, color: AppColors.destructive),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Add Reminder Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    Navigator.pop(context);
                    _showSuccessSnackBar(context, 'Criar novo lembrete...');
                  },
                  icon: const Icon(LucideIcons.plus, size: 20),
                  label: const Text('Novo Lembrete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 8. Navigate to Email Templates - Modal de templates de email
  void _navigateToEmailTemplates(BuildContext context) {
    HapticUtils.lightImpact();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock data para templates de email
    final templates = [
      {
        'id': '1',
        'name': 'Boas-vindas',
        'subject': 'Bem-vindo à Academia FitPro!',
        'preview': 'Olá {nome}! Estamos muito felizes em tê-lo conosco...',
        'category': 'Cadastro',
        'lastEdited': '10/01/2026',
      },
      {
        'id': '2',
        'name': 'Confirmação de Pagamento',
        'subject': 'Pagamento Confirmado - Academia FitPro',
        'preview': 'Olá {nome}! Confirmamos o recebimento do seu pagamento...',
        'category': 'Financeiro',
        'lastEdited': '08/01/2026',
      },
      {
        'id': '3',
        'name': 'Lembrete de Vencimento',
        'subject': 'Seu plano está vencendo!',
        'preview': 'Olá {nome}! Seu plano vence em {dias} dias...',
        'category': 'Financeiro',
        'lastEdited': '05/01/2026',
      },
      {
        'id': '4',
        'name': 'Recuperação de Senha',
        'subject': 'Recuperar sua senha - Academia FitPro',
        'preview': 'Olá {nome}! Clique no link abaixo para redefinir...',
        'category': 'Sistema',
        'lastEdited': '01/01/2026',
      },
      {
        'id': '5',
        'name': 'Avaliação Agendada',
        'subject': 'Sua avaliação física foi agendada!',
        'preview': 'Olá {nome}! Sua avaliação foi agendada para {data}...',
        'category': 'Agenda',
        'lastEdited': '12/01/2026',
      },
      {
        'id': '6',
        'name': 'Aniversário',
        'subject': 'Feliz Aniversário! Um presente especial para você',
        'preview': 'Olá {nome}! A Academia FitPro deseja um feliz aniversário...',
        'category': 'Marketing',
        'lastEdited': '03/01/2026',
      },
    ];

    final categoryColors = {
      'Cadastro': AppColors.success,
      'Financeiro': AppColors.warning,
      'Sistema': AppColors.info,
      'Agenda': AppColors.secondary,
      'Marketing': AppColors.accent,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.mail, size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Templates de Email',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        Text(
                          '${templates.length} templates disponíveis',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      LucideIcons.x,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
            // Templates List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  final categoryColor = categoryColors[template['category']] ?? AppColors.primary;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.mutedDark : AppColors.muted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                    ),
                    child: InkWell(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(context);
                        _showSuccessSnackBar(context, 'Editando template ${template['name']}...');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.fileText, size: 18, color: categoryColor),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          template['name'] as String,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withAlpha(25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    template['category'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: categoryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              template['subject'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              template['preview'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(LucideIcons.clock, size: 12, color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Editado em ${template['lastEdited']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(LucideIcons.chevronRight, size: 16, color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Add Template Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    Navigator.pop(context);
                    _showSuccessSnackBar(context, 'Criar novo template...');
                  },
                  icon: const Icon(LucideIcons.plus, size: 20),
                  label: const Text('Novo Template'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 9. Navigate to Connected Apps - Modal de integracoes
  void _navigateToConnectedApps(BuildContext context) {
    HapticUtils.lightImpact();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock data para apps conectados
    final connectedApps = [
      {
        'id': '1',
        'name': 'Google Calendar',
        'description': 'Sincronizar agendamentos e aulas',
        'icon': LucideIcons.calendar,
        'color': const Color(0xFF4285F4),
        'connected': true,
        'lastSync': '14/01/2026 10:30',
      },
      {
        'id': '2',
        'name': 'WhatsApp Business',
        'description': 'Enviar mensagens automaticas',
        'icon': LucideIcons.messageCircle,
        'color': const Color(0xFF25D366),
        'connected': true,
        'lastSync': '14/01/2026 09:15',
      },
      {
        'id': '3',
        'name': 'Stripe',
        'description': 'Processar pagamentos online',
        'icon': LucideIcons.creditCard,
        'color': const Color(0xFF635BFF),
        'connected': false,
        'lastSync': null,
      },
      {
        'id': '4',
        'name': 'Instagram',
        'description': 'Compartilhar conquistas e fotos',
        'icon': LucideIcons.instagram,
        'color': const Color(0xFFE4405F),
        'connected': false,
        'lastSync': null,
      },
      {
        'id': '5',
        'name': 'Mailchimp',
        'description': 'Gerenciar campanhas de email',
        'icon': LucideIcons.mail,
        'color': const Color(0xFFFFE01B),
        'connected': false,
        'lastSync': null,
      },
      {
        'id': '6',
        'name': 'Zapier',
        'description': 'Automatizar fluxos de trabalho',
        'icon': LucideIcons.zap,
        'color': const Color(0xFFFF4A00),
        'connected': false,
        'lastSync': null,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.info.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.plug, size: 22, color: AppColors.info),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apps Conectados',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                          Text(
                            '${connectedApps.where((a) => a['connected'] == true).length} integracoes ativas',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        LucideIcons.x,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
              // Apps List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: connectedApps.length,
                  itemBuilder: (context, index) {
                    final app = connectedApps[index];
                    final isConnected = app['connected'] as bool;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mutedDark : AppColors.muted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isConnected ? (app['color'] as Color).withAlpha(100) : (isDark ? AppColors.borderDark : AppColors.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: (app['color'] as Color).withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(app['icon'] as IconData, size: 24, color: app['color'] as Color),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      app['name'] as String,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                      ),
                                    ),
                                    if (isConnected) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withAlpha(25),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(LucideIcons.check, size: 10, color: AppColors.success),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Conectado',
                                              style: TextStyle(
                                                fontSize: 10,
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
                                const SizedBox(height: 4),
                                Text(
                                  app['description'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                  ),
                                ),
                                if (isConnected && app['lastSync'] != null) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(LucideIcons.refreshCw, size: 12, color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Sincronizado em ${app['lastSync']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (isConnected)
                            OutlinedButton(
                              onPressed: () {
                                HapticUtils.lightImpact();
                                setModalState(() {
                                  connectedApps[index]['connected'] = false;
                                });
                                _showSuccessSnackBar(context, '${app['name']} desconectado');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.destructive,
                                side: BorderSide(color: AppColors.destructive.withAlpha(100)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Desconectar', style: TextStyle(fontSize: 12)),
                            )
                          else
                            ElevatedButton(
                              onPressed: () {
                                HapticUtils.mediumImpact();
                                setModalState(() {
                                  connectedApps[index]['connected'] = true;
                                  connectedApps[index]['lastSync'] = '14/01/2026 ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
                                });
                                _showSuccessSnackBar(context, '${app['name']} conectado com sucesso');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: app['color'] as Color,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Conectar', style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Info Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.info.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.info, size: 20, color: AppColors.info),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'As integracoes permitem automatizar tarefas e sincronizar dados com outros aplicativos.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
