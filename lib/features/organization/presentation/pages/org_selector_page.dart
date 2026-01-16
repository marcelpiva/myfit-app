import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/domain/entities/entities.dart';
import '../../../../core/providers/context_provider.dart';

class OrgSelectorPage extends ConsumerStatefulWidget {
  const OrgSelectorPage({super.key});

  @override
  ConsumerState<OrgSelectorPage> createState() => _OrgSelectorPageState();
}

class _OrgSelectorPageState extends ConsumerState<OrgSelectorPage> {
  void _selectMembership(OrganizationMembership membership) {
    HapticFeedback.mediumImpact();
    final activeContext = ActiveContext(membership: membership);
    ref.read(activeContextProvider.notifier).state = activeContext;
    context.go(activeContext.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final groupedMemberships = ref.watch(groupedMembershipsProvider);
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: allMemberships.isEmpty
                  ? _buildEmptyState(context, isDark)
                  : _buildProfileList(context, isDark, allMemberships),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
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
                'JO',
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
                  'Ola, Joao!',
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
            onTap: () {
              HapticFeedback.lightImpact();
              context.go(RouteNames.welcome);
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
                HapticFeedback.lightImpact();
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
                HapticFeedback.lightImpact();
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
            HapticFeedback.mediumImpact();
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
            HapticFeedback.mediumImpact();
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
