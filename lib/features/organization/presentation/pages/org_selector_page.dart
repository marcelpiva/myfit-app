import 'package:flutter/material.dart';
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
import '../../../trainer_workout/presentation/providers/trainer_students_provider.dart';

class OrgSelectorPage extends ConsumerStatefulWidget {
  const OrgSelectorPage({super.key});

  @override
  ConsumerState<OrgSelectorPage> createState() => _OrgSelectorPageState();
}

class _OrgSelectorPageState extends ConsumerState<OrgSelectorPage> {
  void _selectMembership(OrganizationMembership membership) {
    HapticUtils.mediumImpact();
    final activeContext = ActiveContext(membership: membership);
    ref.read(activeContextProvider.notifier).state = activeContext;
    context.go(activeContext.homeRoute);
  }

  bool _isAccepting = false;

  Future<void> _acceptInvite(PendingInvite invite) async {
    if (_isAccepting) return;
    setState(() => _isAccepting = true);

    try {
      final service = OrganizationService();
      await service.acceptInvite(invite.token ?? '');

      // Refresh memberships and invites
      ref.invalidate(membershipsProvider);
      ref.invalidate(pendingInvitesForUserProvider);

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
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final groupedMemberships = ref.watch(groupedMembershipsProvider);
    final pendingInvitesAsync = ref.watch(pendingInvitesForUserProvider);
    final studentMemberships = groupedMemberships['student'] ?? [];
    final trainerMemberships = groupedMemberships['trainer'] ?? [];
    final nutritionistMemberships = groupedMemberships['nutritionist'] ?? [];
    final gymMemberships = groupedMemberships['gym'] ?? [];
    final allMemberships = [
      ...gymMemberships,
      ...nutritionistMemberships,
      ...trainerMemberships,
      ...studentMemberships,
    ];

    final pendingInvites = pendingInvitesAsync.valueOrNull ?? [];
    final hasContent = allMemberships.isNotEmpty || pendingInvites.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: hasContent
                  ? _buildContentList(context, isDark, allMemberships, pendingInvites)
                  : _buildEmptyState(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentList(
    BuildContext context,
    bool isDark,
    List<OrganizationMembership> memberships,
    List<PendingInvite> pendingInvites,
  ) {
    return Column(
      children: [
        const SizedBox(height: 24),
        // Pending Invites Section
        if (pendingInvites.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  LucideIcons.mail,
                  size: 18,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  'Convites Pendentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.warning.withAlpha(20),
                  ),
                  child: Text(
                    '${pendingInvites.length}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...pendingInvites.map((invite) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _PendingInviteCard(
              invite: invite,
              isDark: isDark,
              isAccepting: _isAccepting,
              onAccept: () => _acceptInvite(invite),
            ),
          )),
          const SizedBox(height: 20),
        ],
        // Memberships Section
        if (memberships.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Seus Perfis',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.primary.withAlpha(20),
                  ),
                  child: Text(
                    '${memberships.length}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: memberships.length,
              itemBuilder: (context, index) {
                final membership = memberships[index];
                return _ProfileCard(
                  membership: membership,
                  isDark: isDark,
                  onTap: () => _selectMembership(membership),
                );
              },
            ),
          ),
        ] else ...[
          const Spacer(),
        ],
        _buildBottomActions(context, isDark),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final user = ref.watch(currentUserProvider);
    final userName = user?.name ?? 'Usuario';
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
                  'Ola, ${userName.split(' ').first}!',
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

  Widget _buildProfileList(
    BuildContext context,
    bool isDark,
    List<OrganizationMembership> memberships,
  ) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Seus Perfis',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primary.withAlpha(20),
                ),
                child: Text(
                  '${memberships.length}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: memberships.length,
            itemBuilder: (context, index) {
              final membership = memberships[index];
              return _ProfileCard(
                membership: membership,
                isDark: isDark,
                onTap: () => _selectMembership(membership),
              );
            },
          ),
        ),
        _buildBottomActions(context, isDark),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: LucideIcons.plus,
              label: 'Criar',
              isDark: isDark,
              onTap: () {
                HapticUtils.lightImpact();
                context.push(RouteNames.createOrg);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: LucideIcons.qrCode,
              label: 'Entrar com codigo',
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
            'Crie uma organizacao ou entre\ncom um codigo de convite',
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
          title: 'Criar Organizacao',
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
          title: 'Entrar com Codigo',
          subtitle: 'Ja tem um convite?',
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

class _ProfileCard extends StatelessWidget {
  final OrganizationMembership membership;
  final bool isDark;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.membership,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final org = membership.organization;
    final role = membership.role;
    final color = _getRoleColor(role);
    final roleIcon = _getRoleIcon(role);

    return Container(
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
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: color.withAlpha(20),
                  ),
                  child: Icon(
                    roleIcon,
                    size: 24,
                    color: color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        org.name,
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: color.withAlpha(15),
                            ),
                            child: Text(
                              role.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            LucideIcons.users,
                            size: 12,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${org.memberCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                      invite.organizationName ?? 'Organizacao',
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
