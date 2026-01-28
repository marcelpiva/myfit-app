import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../shared/presentation/components/components.dart';
import '../../../../shared/presentation/widgets/verified_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

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
    final currentUser = ref.watch(currentUserProvider);
    final activeContext = ref.watch(activeContextProvider);
    final userName = currentUser?.name ?? 'Usuario';
    final userEmail = currentUser?.email ?? '';
    final isTrainer = activeContext?.isTrainer ?? false;
    final hasCref = currentUser?.cref != null && currentUser!.cref!.isNotEmpty;
    final crefVerified = currentUser?.crefVerified ?? false;

    return Scaffold(
      body: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
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
                        const Spacer(),
                        Text(
                          'Perfil',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            HapticUtils.lightImpact();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isDark ? AppColors.cardDark : AppColors.card,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.border,
                              ),
                            ),
                            child: Icon(
                              LucideIcons.pencil,
                              size: 18,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: isDark ? AppColors.mutedDark : AppColors.muted,
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

                        const SizedBox(height: 16),

                        // Name
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Email
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),

                        // CREF Badge for trainers
                        if (isTrainer && hasCref) ...[
                          const SizedBox(height: 12),
                          VerifiedBadge(
                            crefNumber: currentUser!.cref,
                            isVerified: crefVerified,
                            size: 'medium',
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Organization badge
                        if (activeContext != null)
                          _buildOrganizationBadge(
                            activeContext.organization.name,
                            activeContext.isArchived,
                            isDark,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDark
                            ? AppColors.cardDark.withAlpha(150)
                            : AppColors.card.withAlpha(200),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(context, isDark, '32', 'Treinos', LucideIcons.dumbbell),
                          Container(
                            width: 1,
                            height: 40,
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          _buildStat(context, isDark, '12', 'Semanas', LucideIcons.calendar),
                          Container(
                            width: 1,
                            height: 40,
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          _buildStat(context, isDark, '4.5', 'kg perdidos', LucideIcons.trendingDown),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Menu sections
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, isDark, 'Conta'),
                        const SizedBox(height: 12),
                        _buildMenuCard(context, isDark, [
                          _MenuItem(LucideIcons.user, 'Informações Pessoais', () {
                            HapticUtils.lightImpact();
                          }),
                          _MenuItem(LucideIcons.lock, 'Alterar Senha', () {
                            HapticUtils.lightImpact();
                          }),
                          _MenuItem(LucideIcons.bell, 'Notificações', () {
                            HapticUtils.lightImpact();
                          }),
                        ]),

                        const SizedBox(height: 24),

                        _buildSectionTitle(context, isDark, 'Preferências'),
                        const SizedBox(height: 12),
                        _buildMenuCard(context, isDark, [
                          _MenuItem(LucideIcons.globe, 'Idioma', () {
                            HapticUtils.lightImpact();
                          }, trailing: 'Português'),
                          _MenuItem(LucideIcons.moon, 'Tema', () {
                            HapticUtils.lightImpact();
                          }, trailing: 'Sistema'),
                          _MenuItem(LucideIcons.ruler, 'Unidades', () {
                            HapticUtils.lightImpact();
                          }, trailing: 'Métrico'),
                        ]),

                        const SizedBox(height: 24),

                        _buildSectionTitle(context, isDark, 'Suporte'),
                        const SizedBox(height: 12),
                        _buildMenuCard(context, isDark, [
                          _MenuItem(LucideIcons.helpCircle, 'Central de Ajuda', () {
                            HapticUtils.lightImpact();
                            context.push(RouteNames.help);
                          }),
                          _MenuItem(LucideIcons.messageSquare, 'Contato', () {
                            HapticUtils.lightImpact();
                            context.push(RouteNames.help);
                          }),
                          _MenuItem(LucideIcons.fileText, 'Termos de Uso', () {
                            HapticUtils.lightImpact();
                            context.push(RouteNames.terms);
                          }),
                          _MenuItem(LucideIcons.shield, 'Privacidade', () {
                            HapticUtils.lightImpact();
                            context.push(RouteNames.privacy);
                          }),
                        ]),

                        const SizedBox(height: 32),

                        // Logout button
                        SecondaryButton(
                          label: 'Sair da conta',
                          icon: LucideIcons.logOut,
                          fullWidth: true,
                          onPressed: () {
                            HapticUtils.mediumImpact();
                            context.go(RouteNames.welcome);
                          },
                        ),

                        const SizedBox(height: 16),

                        // Version
                        Center(
                          child: Text(
                            'Versão 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
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

  Widget _buildStat(
    BuildContext context,
    bool isDark,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.primaryDark : AppColors.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
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

  Widget _buildOrganizationBadge(String organizationName, bool isArchived, bool isDark) {
    final color = isArchived ? AppColors.warning : AppColors.primary;
    final darkColor = isArchived ? AppColors.warning : AppColors.primaryDark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withAlpha(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isArchived ? LucideIcons.archive : LucideIcons.building2,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            organizationName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? darkColor : color,
            ),
          ),
          if (isArchived) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.warning.withAlpha(40),
              ),
              child: Text(
                'Indisponível',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, bool isDark, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, bool isDark, List<_MenuItem> items) {
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
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == items.length - 1;

          return GestureDetector(
            onTap: item.onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 20,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                  ),
                  if (item.trailing != null)
                    Text(
                      item.trailing!,
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
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;

  _MenuItem(this.icon, this.label, this.onTap, {this.trailing});
}
