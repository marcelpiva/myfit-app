import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/domain/entities/entities.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../core/services/organization_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/student_home_provider.dart';
import '../../../trainer_workout/presentation/providers/trainer_students_provider.dart';
import '../../../workout/presentation/providers/workout_provider.dart';

class OrgSelectorPage extends ConsumerStatefulWidget {
  const OrgSelectorPage({super.key});

  @override
  ConsumerState<OrgSelectorPage> createState() => _OrgSelectorPageState();
}

class _OrgSelectorPageState extends ConsumerState<OrgSelectorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _tabIndexKey = 'org_selector_tab_index';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSavedTabIndex();
    _tabController.addListener(_saveTabIndex);
    // Clear active context when entering org selector
    // This ensures settings show correct options for this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeContextProvider.notifier).clearContext();
      ref.invalidate(pendingInvitesForUserProvider);
    });
  }

  Future<void> _loadSavedTabIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(_tabIndexKey) ?? 0;
    if (mounted && savedIndex != _tabController.index) {
      _tabController.animateTo(savedIndex);
    }
  }

  void _saveTabIndex() {
    if (!_tabController.indexIsChanging) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setInt(_tabIndexKey, _tabController.index);
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_saveTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _selectMembership(OrganizationMembership membership) {
    HapticUtils.mediumImpact();
    final activeContext = ActiveContext(membership: membership);
    ref.read(activeContextProvider.notifier).setContext(activeContext);

    // Invalidate providers to refresh data for the new organization context
    ref.invalidate(studentDashboardProvider);
    ref.invalidate(plansNotifierProvider);
    ref.invalidate(workoutsNotifierProvider);

    context.go(activeContext.homeRoute);
  }

  String? _acceptingInviteId;
  bool _isDeleting = false;
  bool _isReactivating = false;
  String? _reactivatingOrgId;

  Future<void> _deleteProfile(OrganizationMembership membership) async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    final isStudent = membership.role == UserRole.student;
    final actionText = isStudent ? 'saiu de' : 'arquivou';
    final errorText = isStudent ? 'sair do' : 'arquivar';

    try {
      final service = OrganizationService();

      if (isStudent) {
        // Student leaving - use specific endpoint that only removes student membership
        await service.leaveOrganization(membership.organization.id);
      } else {
        // Owner archiving - use removeMember which archives the org
        final user = ref.read(currentUserProvider);
        if (user == null) throw Exception('Usuário não encontrado');
        await service.removeMember(membership.organization.id, user.id);
      }

      // Refresh memberships
      ref.invalidate(membershipsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Você $actionText "${membership.organization.name}"'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao $errorText perfil: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _reactivateOrganization(OrganizationMembership membership) async {
    if (_isReactivating) return;
    setState(() {
      _isReactivating = true;
      _reactivatingOrgId = membership.organization.id;
    });

    try {
      final service = OrganizationService();
      await service.reactivateOrganization(membership.organization.id);

      // Refresh memberships
      ref.invalidate(membershipsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${membership.organization.name} foi reativado!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reativar: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReactivating = false;
          _reactivatingOrgId = null;
        });
      }
    }
  }

  void _showDeleteProfileDialog(OrganizationMembership membership) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isStudent = membership.role == UserRole.student;
    final isArchived = membership.organization.isArchived;

    // Different text and icon for students (leave) vs owners (archive)
    late String title;
    late IconData icon;
    late String confirmText;
    late String message;
    late Color iconColor;

    if (isStudent) {
      // Student leaving
      title = isArchived ? 'Sair' : 'Sair do Personal';
      icon = LucideIcons.logOut;
      confirmText = 'Sair';
      iconColor = AppColors.destructive;
      message = 'Tem certeza que deseja sair de "${membership.organization.name}"?\n\nVocê perderá acesso aos treinos e precisará de um novo convite para retornar.';
    } else {
      // Owner archiving
      title = 'Arquivar Perfil';
      icon = LucideIcons.archive;
      confirmText = 'Arquivar';
      iconColor = AppColors.warning;
      message = 'Seus alunos serão notificados que você pausou as atividades.\n\nVocê pode reativar a qualquer momento.';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withAlpha(20),
              ),
              child: Icon(
                icon,
                size: 28,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isDeleting
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            _deleteProfile(membership);
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: isStudent ? AppColors.destructive : AppColors.warning,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(confirmText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showReactivateProfileDialog(OrganizationMembership membership) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withAlpha(20),
              ),
              child: Icon(
                LucideIcons.archiveRestore,
                size: 28,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Reativar Perfil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Seus alunos serão notificados que você voltou às atividades.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isReactivating
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            _reactivateOrganization(membership);
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isReactivating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Reativar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptInvite(PendingInvite invite) async {
    if (_acceptingInviteId != null) return;
    setState(() => _acceptingInviteId = invite.id);

    try {
      final service = OrganizationService();
      await service.acceptInvite(invite.token ?? '');

      // Refresh memberships and invites (student view)
      ref.invalidate(membershipsProvider);
      ref.invalidate(pendingInvitesForUserProvider);

      // Also refresh trainer-side providers for this organization
      // This ensures the trainer view updates when an invite is accepted
      ref.invalidate(pendingInvitesNotifierProvider(invite.organizationId));
      ref.invalidate(trainerStudentsNotifierProvider(invite.organizationId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Convite aceito com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao aceitar convite: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _acceptingInviteId = null);
    }
  }

  /// Separate memberships by active/archived status
  Map<String, List<OrganizationMembership>> _separateByStatus(
    List<OrganizationMembership> memberships,
  ) {
    final active = memberships.where((m) => !m.organization.isArchived).toList();
    final archived = memberships.where((m) => m.organization.isArchived).toList();
    return {'active': active, 'archived': archived};
  }

  /// Group memberships by organization type
  Map<OrganizationType, List<OrganizationMembership>> _groupByType(
    List<OrganizationMembership> memberships,
  ) {
    final grouped = <OrganizationType, List<OrganizationMembership>>{};
    for (final m in memberships) {
      grouped.putIfAbsent(m.organization.type, () => []).add(m);
    }
    return grouped;
  }

  /// Get display order for organization types
  List<OrganizationType> get _typeOrder => [
    OrganizationType.personal,
    OrganizationType.gym,
    OrganizationType.nutritionist,
    OrganizationType.clinic,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final groupedMemberships = ref.watch(groupedMembershipsProvider);
    final pendingInvitesAsync = ref.watch(pendingInvitesForUserProvider);
    final autonomousMemberships = groupedMemberships['autonomous'] ?? [];
    final studentMemberships = groupedMemberships['student'] ?? [];
    final trainerMemberships = groupedMemberships['trainer'] ?? [];
    final nutritionistMemberships = groupedMemberships['nutritionist'] ?? [];
    final gymMemberships = groupedMemberships['gym'] ?? [];

    // Professional profiles (trainer, nutritionist, gym owner/admin)
    final professionalMemberships = [
      ...trainerMemberships,
      ...nutritionistMemberships,
      ...gymMemberships,
    ];

    final pendingInvites = pendingInvitesAsync.valueOrNull ?? [];

    // Counts for tab badges
    final professionalCount = professionalMemberships.length;
    final studentCount = studentMemberships.length + autonomousMemberships.length;

    final hasAnyContent = professionalMemberships.isNotEmpty ||
        studentMemberships.isNotEmpty ||
        autonomousMemberships.isNotEmpty ||
        pendingInvites.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            if (hasAnyContent) ...[
              const SizedBox(height: 16),
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.muted.withAlpha(80),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: isDark ? AppColors.backgroundDark : AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    unselectedLabelColor: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.dumbbell, size: 16),
                            const SizedBox(width: 6),
                            const Text('Personal'),
                            if (professionalCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$professionalCount',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.user, size: 16),
                            const SizedBox(width: 6),
                            const Text('Aluno'),
                            if (studentCount > 0 || pendingInvites.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: pendingInvites.isNotEmpty
                                      ? AppColors.warning.withAlpha(20)
                                      : AppColors.secondary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  pendingInvites.isNotEmpty
                                      ? '${studentCount + pendingInvites.length}'
                                      : '$studentCount',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: pendingInvites.isNotEmpty
                                        ? AppColors.warning
                                        : AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: hasAnyContent
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Professional (Personal/Trainer)
                        _buildProfessionalTab(
                          context,
                          isDark,
                          professionalMemberships,
                        ),
                        // Tab 2: Student
                        _buildStudentTab(
                          context,
                          isDark,
                          studentMemberships,
                          pendingInvites,
                          autonomousMemberships: autonomousMemberships,
                        ),
                      ],
                    )
                  : _buildEmptyState(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalTab(
    BuildContext context,
    bool isDark,
    List<OrganizationMembership> memberships,
  ) {
    // Separate by active/archived
    final statusGroups = _separateByStatus(memberships);
    final activeMemberships = statusGroups['active']!;
    final archivedMemberships = statusGroups['archived']!;
    final activeByType = _groupByType(activeMemberships);
    final archivedByType = _groupByType(archivedMemberships);

    if (memberships.isEmpty) {
      return _buildEmptyTabState(
        context,
        isDark,
        icon: LucideIcons.dumbbell,
        title: 'Nenhum perfil profissional',
        subtitle: 'Crie uma organização para\ngerenciar seus alunos',
        showCreateButton: true,
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              // ACTIVE PROFILES
              if (activeMemberships.isNotEmpty) ...[
                _buildSectionHeader(
                  isDark: isDark,
                  title: 'Ativos',
                  icon: LucideIcons.checkCircle,
                  color: AppColors.success,
                  count: activeMemberships.length,
                ),
                const SizedBox(height: 12),
                for (final type in _typeOrder)
                  if (activeByType.containsKey(type)) ...[
                    ...activeByType[type]!.map((membership) => _ProfileCard(
                          membership: membership,
                          isDark: isDark,
                          onTap: () => _selectMembership(membership),
                          onAction: () => _showDeleteProfileDialog(membership),
                          isReactivating:
                              _reactivatingOrgId == membership.organization.id,
                        )),
                  ],
              ],

              // ARCHIVED PROFILES
              if (archivedMemberships.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionHeader(
                  isDark: isDark,
                  title: 'Arquivados',
                  icon: LucideIcons.archive,
                  color: AppColors.warning,
                  count: archivedMemberships.length,
                ),
                const SizedBox(height: 12),
                for (final type in _typeOrder)
                  if (archivedByType.containsKey(type)) ...[
                    ...archivedByType[type]!.map((membership) => _ProfileCard(
                          membership: membership,
                          isDark: isDark,
                          isArchived: true,
                          onTap: () => _selectMembership(membership),
                          onAction: () =>
                              _showReactivateProfileDialog(membership),
                          isReactivating:
                              _reactivatingOrgId == membership.organization.id,
                        )),
                  ],
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
        _buildBottomActions(context, isDark, showJoinButton: false),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStudentTab(
    BuildContext context,
    bool isDark,
    List<OrganizationMembership> memberships,
    List<PendingInvite> pendingInvites, {
    List<OrganizationMembership> autonomousMemberships = const [],
  }) {
    // Separate by active/archived
    final statusGroups = _separateByStatus(memberships);
    final activeMemberships = statusGroups['active']!;
    final archivedMemberships = statusGroups['archived']!;

    final hasContent = memberships.isNotEmpty ||
        pendingInvites.isNotEmpty ||
        autonomousMemberships.isNotEmpty;

    if (!hasContent) {
      return _buildEmptyTabState(
        context,
        isDark,
        icon: LucideIcons.user,
        title: 'Nenhum perfil de aluno',
        subtitle: 'Entre com um código de convite\npara treinar com um personal',
        showJoinButton: true,
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              // Pending Invites
              if (pendingInvites.isNotEmpty) ...[
                _buildSectionHeader(
                  isDark: isDark,
                  title: 'Convites Pendentes',
                  icon: LucideIcons.mail,
                  color: AppColors.warning,
                  count: pendingInvites.length,
                ),
                const SizedBox(height: 12),
                ...pendingInvites.map((invite) => _PendingInviteCard(
                      invite: invite,
                      isDark: isDark,
                      isAccepting: _acceptingInviteId == invite.id,
                      onAccept: () => _acceptInvite(invite),
                    )),
                const SizedBox(height: 16),
              ],

              // AUTONOMOUS profiles section
              if (autonomousMemberships.isNotEmpty) ...[
                _buildSectionHeader(
                  isDark: isDark,
                  title: 'Treinos Autônomos',
                  icon: LucideIcons.target,
                  color: AppColors.secondary,
                  count: autonomousMemberships.length,
                ),
                const SizedBox(height: 12),
                ...autonomousMemberships.map((membership) => _ProfileCard(
                      membership: membership,
                      isDark: isDark,
                      onTap: () => _selectMembership(membership),
                      onAction: () => _showDeleteProfileDialog(membership),
                      isReactivating:
                          _reactivatingOrgId == membership.organization.id,
                    )),
                const SizedBox(height: 16),
              ],

              // ACTIVE student profiles (with trainer)
              if (activeMemberships.isNotEmpty) ...[
                _buildSectionHeader(
                  isDark: isDark,
                  title: 'Com Personal Trainer',
                  icon: LucideIcons.checkCircle,
                  color: AppColors.success,
                  count: activeMemberships.length,
                ),
                const SizedBox(height: 12),
                ...activeMemberships.map((membership) => _ProfileCard(
                      membership: membership,
                      isDark: isDark,
                      onTap: () => _selectMembership(membership),
                      onAction: () => _showDeleteProfileDialog(membership),
                      isReactivating:
                          _reactivatingOrgId == membership.organization.id,
                    )),
              ],

              // ARCHIVED student profiles (trainer paused)
              if (archivedMemberships.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionHeader(
                  isDark: isDark,
                  title: 'Personal Pausado',
                  icon: LucideIcons.archive,
                  color: AppColors.warning,
                  count: archivedMemberships.length,
                ),
                const SizedBox(height: 12),
                ...archivedMemberships.map((membership) => _ProfileCard(
                      membership: membership,
                      isDark: isDark,
                      isArchived: true,
                      onTap: () => _selectMembership(membership),
                      onAction: () => _showDeleteProfileDialog(membership),
                      isReactivating:
                          _reactivatingOrgId == membership.organization.id,
                    )),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
        _buildStudentBottomActions(
          context,
          isDark,
          hasAutonomousProfile: autonomousMemberships.isNotEmpty,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  bool _isCreatingAutonomous = false;

  Future<void> _createAutonomousProfile() async {
    if (_isCreatingAutonomous) return;
    setState(() => _isCreatingAutonomous = true);

    try {
      final orgService = OrganizationService();
      await orgService.createAutonomousOrganization();

      // Refresh memberships to show new profile and wait for data
      ref.invalidate(membershipsProvider);
      // Wait for the refresh to complete
      await ref.read(membershipsProvider.future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil autônomo criado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar perfil: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingAutonomous = false);
    }
  }

  Widget _buildStudentBottomActions(
    BuildContext context,
    bool isDark, {
    required bool hasAutonomousProfile,
  }) {
    // If user already has autonomous profile, only show "Entrar com código"
    if (hasAutonomousProfile) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: _ActionButton(
          icon: LucideIcons.qrCode,
          label: 'Entrar com código',
          isDark: isDark,
          isPrimary: true,
          onTap: () {
            HapticUtils.lightImpact();
            context.push(RouteNames.joinOrg);
          },
        ),
      );
    }

    // Show both buttons if no autonomous profile exists
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: LucideIcons.target,
              label: 'Treinar sozinho',
              isDark: isDark,
              isPrimary: false,
              isLoading: _isCreatingAutonomous,
              onTap: _createAutonomousProfile,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: LucideIcons.qrCode,
              label: 'Entrar com código',
              isDark: isDark,
              isPrimary: true,
              onTap: () {
                HapticUtils.lightImpact();
                context.push(RouteNames.joinOrg);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTabState(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool showCreateButton = false,
    bool showJoinButton = false,
  }) {
    return Column(
      children: [
        const Spacer(),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withAlpha(15),
          ),
          child: Icon(
            icon,
            size: 36,
            color: AppColors.primary.withAlpha(180),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        const Spacer(),
        if (showCreateButton || showJoinButton)
          _buildBottomActions(
            context,
            isDark,
            showCreateButton: showCreateButton,
            showJoinButton: showJoinButton,
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionHeader({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color color,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 25 : 15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: color.withAlpha(30),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final user = ref.watch(currentUserProvider);
    final userName = user?.name ?? 'Usuário';
    final initials = userName.isNotEmpty
        ? userName.split(' ').take(2).map((n) => n.isNotEmpty ? n[0].toUpperCase() : '').join()
        : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primary.withAlpha(20),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${userName.split(' ').first}!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Text(
                  'Selecione um perfil',
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
          // Settings button
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              context.push(RouteNames.settings);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDark ? AppColors.cardDark : AppColors.card,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Icon(
                LucideIcons.settings,
                size: 18,
                color: isDark
                    ? AppColors.foregroundDark
                    : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Logout button
          GestureDetector(
            onTap: () async {
              HapticUtils.lightImpact();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(RouteNames.welcome);
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDark ? AppColors.cardDark : AppColors.card,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Icon(
                LucideIcons.logOut,
                size: 18,
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

  Widget _buildBottomActions(
    BuildContext context,
    bool isDark, {
    bool showCreateButton = true,
    bool showJoinButton = true,
  }) {
    if (!showCreateButton && !showJoinButton) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          if (showCreateButton)
            Expanded(
              child: _ActionButton(
                icon: LucideIcons.plus,
                label: 'Criar Perfil',
                isDark: isDark,
                isPrimary: !showJoinButton,
                onTap: () {
                  HapticUtils.lightImpact();
                  context.push(RouteNames.createOrg);
                },
              ),
            ),
          if (showCreateButton && showJoinButton) const SizedBox(width: 12),
          if (showJoinButton)
            Expanded(
              child: _ActionButton(
                icon: LucideIcons.qrCode,
                label: 'Entrar com código',
                isDark: isDark,
                isPrimary: true,
                onTap: () {
                  HapticUtils.lightImpact();
                  context.push(RouteNames.joinOrg);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 80),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(15),
            ),
            child: Icon(
              LucideIcons.users,
              size: 44,
              color: AppColors.primary.withAlpha(180),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Nenhum perfil',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie uma organização ou entre\ncom um código de convite',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 36),
          _buildEmptyActionCards(context, isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyActionCards(BuildContext context, bool isDark) {
    return Column(
      children: [
        _EmptyActionCard(
          icon: LucideIcons.building2,
          title: 'Criar Organização',
          subtitle: 'Personal, academia ou studio',
          isDark: isDark,
          isPrimary: true,
          onTap: () {
            HapticUtils.mediumImpact();
            context.push(RouteNames.createOrg);
          },
        ),
        const SizedBox(height: 12),
        _EmptyActionCard(
          icon: LucideIcons.qrCode,
          title: 'Entrar com Código',
          subtitle: 'Já tem um convite?',
          isDark: isDark,
          isPrimary: false,
          onTap: () {
            HapticUtils.mediumImpact();
            context.push(RouteNames.joinOrg);
          },
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final OrganizationMembership membership;
  final bool isDark;
  final bool isArchived;
  final bool isReactivating;
  final VoidCallback onTap;
  final VoidCallback? onAction;

  const _ProfileCard({
    required this.membership,
    required this.isDark,
    required this.onTap,
    this.onAction,
    this.isArchived = false,
    this.isReactivating = false,
  });

  /// Get the title to display for this membership
  /// Removes redundant prefixes like "Personal " since context is clear
  String _getDisplayTitle() {
    final name = membership.organization.name;

    // Remove "Personal " prefix - context already makes it clear
    // For trainers: badge shows [Personal Trainer]
    // For students: subtitle shows "Treinos"
    if (name.toLowerCase().startsWith('personal ')) {
      return name.substring(9); // Remove "Personal "
    }

    return name;
  }

  /// Get the subtitle for context
  /// - For students: "Treinos"
  /// - For professionals: "Meus Alunos"
  String? _getDisplaySubtitle() {
    if (membership.role == UserRole.student) {
      return 'Treinos';
    }
    return 'Meus Alunos';
  }

  /// Get the label badge text
  /// - For students: "Aluno"
  /// - For professionals: their role (Personal Trainer, Coach, etc.)
  String _getDisplayLabel() {
    if (membership.role == UserRole.student) {
      return 'Aluno';
    }
    return membership.role.displayName;
  }

  /// Get the member count text
  /// - For students: null (not shown)
  /// - For professionals: "[N] alunos"
  String? _getMemberCountText() {
    if (membership.role == UserRole.student) {
      return null; // Not relevant for students
    }
    final count = membership.organization.memberCount - 1; // Exclude self
    return count == 1 ? '1 aluno' : '$count alunos';
  }

  /// Get action icon and color based on role and archived status
  (IconData, Color, String) _getActionInfo() {
    final isStudent = membership.role == UserRole.student;

    if (isArchived) {
      if (isStudent) {
        // Student can leave archived org
        return (LucideIcons.logOut, AppColors.destructive, 'Sair');
      } else {
        // Owner can reactivate
        return (LucideIcons.archiveRestore, AppColors.success, 'Reativar');
      }
    } else {
      if (isStudent) {
        // Student can leave
        return (LucideIcons.logOut, AppColors.destructive, 'Sair');
      } else {
        // Owner can archive
        return (LucideIcons.archive, AppColors.warning, 'Arquivar');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = membership.role;
    final color = _getRoleColor(role);
    final roleIcon = _getRoleIcon(role);
    final (actionIcon, actionColor, _) = _getActionInfo();
    final isStudent = role == UserRole.student;

    return Opacity(
      opacity: isArchived ? 0.75 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isArchived
                      ? AppColors.warning.withAlpha(50)
                      : (isDark ? AppColors.borderDark : AppColors.border),
                  width: isArchived ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Avatar with optional archive overlay
                  Stack(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: color.withAlpha(isArchived ? 12 : 20),
                        ),
                        child: membership.organization.logoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  membership.organization.logoUrl!,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    roleIcon,
                                    size: 24,
                                    color: isArchived ? color.withAlpha(150) : color,
                                  ),
                                ),
                              )
                            : Icon(
                                roleIcon,
                                size: 24,
                                color: isArchived ? color.withAlpha(150) : color,
                              ),
                      ),
                      if (isArchived)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDark ? AppColors.cardDark : AppColors.card,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              LucideIcons.archive,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtitle (context: "Treinos" for student, "Meus Alunos" for trainer)
                        if (_getDisplaySubtitle() != null)
                          Text(
                            _getDisplaySubtitle()!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                          ),
                        const SizedBox(height: 2),
                        // Main title (Organization name)
                        Text(
                          _getDisplayTitle(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: color.withAlpha(isArchived ? 10 : 15),
                              ),
                              child: Text(
                                _getDisplayLabel(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isArchived ? color.withAlpha(180) : color,
                                ),
                              ),
                            ),
                            if (_getMemberCountText() != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                LucideIcons.users,
                                size: 11,
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getMemberCountText()!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                              ),
                            ],
                            // Student sees "Personal pausou" message
                            if (isArchived && isStudent) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• Pausado',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onAction != null) ...[
                    GestureDetector(
                      onTap: isReactivating ? null : onAction,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: actionColor.withAlpha(15),
                        ),
                        child: isReactivating
                            ? Padding(
                                padding: const EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(actionColor),
                                ),
                              )
                            : Icon(
                                actionIcon,
                                size: 18,
                                color: actionColor.withAlpha(200),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return LucideIcons.user;
      case UserRole.trainer:
        return LucideIcons.dumbbell;
      case UserRole.coach:
        return LucideIcons.trophy;
      case UserRole.nutritionist:
        return LucideIcons.apple;
      case UserRole.gymOwner:
        return LucideIcons.building2;
      case UserRole.gymAdmin:
        return LucideIcons.settings;
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppColors.secondary;
      case UserRole.trainer:
        return AppColors.primary;
      case UserRole.coach:
        return AppColors.accent;
      case UserRole.nutritionist:
        return AppColors.success;
      case UserRole.gymOwner:
        return AppColors.warning;
      case UserRole.gymAdmin:
        return AppColors.info;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    this.isPrimary = false,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isPrimary
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : AppColors.card),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isPrimary
                      ? Colors.white
                      : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                ),
              )
            else
              Icon(
                icon,
                size: 18,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final bool isPrimary;
  final VoidCallback onTap;

  const _EmptyActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isPrimary
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : AppColors.card),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isPrimary
                    ? Colors.white.withAlpha(25)
                    : AppColors.primary.withAlpha(15),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isPrimary ? Colors.white : AppColors.primary,
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
                      color: isPrimary
                          ? Colors.white
                          : (isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isPrimary
                          ? Colors.white.withAlpha(180)
                          : (isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isPrimary
                  ? Colors.white.withAlpha(180)
                  : (isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingInviteCard extends StatelessWidget {
  final PendingInvite invite;
  final bool isDark;
  final bool isAccepting;
  final VoidCallback onAccept;

  const _PendingInviteCard({
    required this.invite,
    required this.isDark,
    required this.isAccepting,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppColors.cardDark : AppColors.card,
        border: Border.all(
          color: AppColors.warning.withAlpha(50),
          width: 2,
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
                  color: AppColors.warning.withAlpha(20),
                ),
                child: Icon(
                  LucideIcons.mail,
                  size: 22,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.organizationName ?? 'Organização',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Convite como ${invite.role}',
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
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isAccepting ? null : onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isAccepting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Aceitar Convite',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
