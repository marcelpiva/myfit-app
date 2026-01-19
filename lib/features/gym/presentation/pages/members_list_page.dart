import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/domain/entities/user_role.dart';
import '../../../../shared/presentation/components/role_bottom_navigation.dart';
import '../providers/organization_provider.dart';

/// Members List page for Gym owners and admins
class MembersListPage extends ConsumerStatefulWidget {
  const MembersListPage({super.key});

  @override
  ConsumerState<MembersListPage> createState() => _MembersListPageState();
}

class _MembersListPageState extends ConsumerState<MembersListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _selectedFilter = 0;
  final _searchController = TextEditingController();

  final _filters = ['Todos', 'Ativos', 'Inadimplentes', 'Novos'];

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Temporary orgId - in a real app this would come from the auth provider
  static const String _orgId = 'default';

  List<Map<String, dynamic>> _getFilteredMembers(List<Map<String, dynamic>> members) {
    final searchQuery = _searchController.text.toLowerCase();
    final now = DateTime.now();

    return members.where((member) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final name = (member['user_name'] as String? ?? member['name'] as String? ?? '').toLowerCase();
        final plan = (member['plan'] as String? ?? '').toLowerCase();
        if (!name.contains(searchQuery) && !plan.contains(searchQuery)) {
          return false;
        }
      }

      // Category filter
      switch (_selectedFilter) {
        case 1: // Ativos
          return member['status'] == 'active';
        case 2: // Inadimplentes
          return member['status'] == 'overdue' ||
              member['status'] == 'expiring';
        case 3: // Novos (joined in last 30 days)
          final joinedAt = member['joined_at'] as String?;
          if (joinedAt == null) return false;
          final memberSince = DateTime.tryParse(joinedAt);
          if (memberSince == null) return false;
          return now.difference(memberSince).inDays <= 30;
        default: // Todos
          return true;
      }
    }).toList();
  }

  int _getTotalMembers(List<Map<String, dynamic>> members) => members.length;

  int _getActiveMembers(List<Map<String, dynamic>> members) =>
      members.where((m) => m['status'] == 'active').length;

  int _getOverdueMembers(List<Map<String, dynamic>> members) => members
      .where((m) =>
          m['status'] == 'overdue' || m['status'] == 'expiring')
      .length;

  Future<void> _onRefresh() async {
    HapticUtils.lightImpact();
    await ref.read(membersNotifierProvider(_orgId).notifier).loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final membersState = ref.watch(membersNotifierProvider(_orgId));
    final filteredMembers = _getFilteredMembers(membersState.members);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      bottomNavigationBar: const RoleBottomNavigation(
        role: UserRole.gymOwner,
        currentIndex: 2, // Alunos tab
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticUtils.lightImpact();
          _showAddMemberSheet(context, isDark);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.userPlus, color: Colors.white),
        label: const Text(
          'Novo Membro',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
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
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Membros',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    HapticUtils.lightImpact();
                                    _showFilterSheet(context, isDark);
                                  },
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.cardDark
                                          : AppColors.card,
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.borderDark
                                            : AppColors.border,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      LucideIcons.filter,
                                      size: 20,
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Search bar
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.cardDark : AppColors.card)
                                .withAlpha(isDark ? 150 : 200),
                            border: Border.all(
                              color:
                                  isDark ? AppColors.borderDark : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              Icon(
                                LucideIcons.search,
                                size: 18,
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: 'Buscar membros...',
                                    hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: isDark
                                          ? AppColors.mutedForegroundDark
                                          : AppColors.mutedForeground,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark
                                        ? AppColors.foregroundDark
                                        : AppColors.foreground,
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 14),
                                    child: Icon(
                                      LucideIcons.x,
                                      size: 18,
                                      color: isDark
                                          ? AppColors.mutedForegroundDark
                                          : AppColors.mutedForeground,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _filters.asMap().entries.map((entry) {
                              final isSelected = entry.key == _selectedFilter;
                              return GestureDetector(
                                onTap: () {
                                  HapticUtils.lightImpact();
                                  setState(() => _selectedFilter = entry.key);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark
                                            ? AppColors.foregroundDark
                                            : AppColors.foreground)
                                        : (isDark
                                                ? AppColors.cardDark
                                                : AppColors.card)
                                            .withAlpha(isDark ? 150 : 200),
                                    border: Border.all(
                                      color: isSelected
                                          ? (isDark
                                              ? AppColors.foregroundDark
                                              : AppColors.foreground)
                                          : (isDark
                                              ? AppColors.borderDark
                                              : AppColors.border),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? (isDark
                                              ? AppColors.backgroundDark
                                              : AppColors.background)
                                          : (isDark
                                              ? AppColors.foregroundDark
                                              : AppColors.foreground),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats summary
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.cardDark : AppColors.card)
                            .withAlpha(isDark ? 150 : 200),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniStat(isDark, '${_getTotalMembers(membersState.members)}', 'Total'),
                          Container(
                            width: 1,
                            height: 30,
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          _buildMiniStat(
                            isDark,
                            '${_getActiveMembers(membersState.members)}',
                            'Ativos',
                            color: AppColors.success,
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          _buildMiniStat(
                            isDark,
                            '${_getOverdueMembers(membersState.members)}',
                            'Inadimplentes',
                            color: AppColors.destructive,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Members list
                  Expanded(
                    child: membersState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : membersState.error != null
                            ? _buildErrorState(isDark, membersState.error!)
                            : filteredMembers.isEmpty
                                ? _buildEmptyState(isDark)
                                : RefreshIndicator(
                            onRefresh: _onRefresh,
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: filteredMembers.length,
                              itemBuilder: (context, index) {
                                final member = filteredMembers[index];
                                return TweenAnimationBuilder<double>(
                                  duration: Duration(
                                      milliseconds: 300 + (index * 50)),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: Opacity(
                                        opacity: value,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _MemberCard(
                                    member: member,
                                    isDark: isDark,
                                    onTap: () {
                                      HapticUtils.lightImpact();
                                      _showMemberDetail(context, isDark, member);
                                    },
                                    onMessage: () {
                                      HapticUtils.lightImpact();
                                      _showMessageSheet(context, isDark, member);
                                    },
                                  ),
                                );
                              },
                            ),
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

  Widget _buildErrorState(bool isDark, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _onRefresh,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tentar novamente',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              LucideIcons.users,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum membro encontrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros ou adicione um novo membro',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(bool isDark, String value, String label,
      {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color ??
                (isDark ? AppColors.foregroundDark : AppColors.foreground),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  void _showAddMemberSheet(BuildContext context, bool isDark) {
    HapticUtils.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
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
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Novo Membro',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Adicione um novo membro a sua academia',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),

              const SizedBox(height: 24),

              // Name input
              Text(
                'Nome Completo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Digite o nome',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Email input
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'email@exemplo.com',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Plan selector
              Text(
                'Plano',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _PlanOption(
                      label: 'Mensal',
                      price: 'R\$ 120',
                      isSelected: true,
                      isDark: isDark,
                      onTap: () {
                        HapticUtils.lightImpact();
                        _showPlanConfirmationModal(
                          context: context,
                          isDark: isDark,
                          planName: 'Plano Mensal',
                          price: 'R\$ 99,90/mês',
                          pricePerMonth: null,
                          savings: null,
                          benefits: [
                            'Acesso ilimitado à academia',
                            'Aulas em grupo incluídas',
                            'Avaliação física mensal',
                            'Acesso ao app MyFit',
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PlanOption(
                      label: 'Trimestral',
                      price: 'R\$ 300',
                      isSelected: false,
                      isDark: isDark,
                      onTap: () {
                        HapticUtils.lightImpact();
                        _showPlanConfirmationModal(
                          context: context,
                          isDark: isDark,
                          planName: 'Plano Trimestral',
                          price: 'R\$ 249,90',
                          pricePerMonth: 'R\$ 83,30/mês',
                          savings: 'Economia de 16%',
                          benefits: [
                            'Acesso ilimitado à academia',
                            'Aulas em grupo incluídas',
                            'Avaliação física mensal',
                            'Acesso ao app MyFit',
                            'Personal trainer 1x por mês',
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PlanOption(
                      label: 'Anual',
                      price: 'R\$ 1000',
                      isSelected: false,
                      isDark: isDark,
                      onTap: () {
                        HapticUtils.lightImpact();
                        _showPlanConfirmationModal(
                          context: context,
                          isDark: isDark,
                          planName: 'Plano Anual',
                          price: 'R\$ 899,90',
                          pricePerMonth: 'R\$ 74,99/mês',
                          savings: 'Economia de 25%',
                          benefits: [
                            'Acesso ilimitado à academia',
                            'Aulas em grupo incluídas',
                            'Avaliação física mensal',
                            'Acesso ao app MyFit',
                            'Personal trainer 2x por mês',
                            'Nutrição esportiva inclusa',
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.x,
                              size: 18,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Membro adicionado com sucesso!', style: const TextStyle(color: Colors.white)),
                          ),
                        );
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.userPlus,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Adicionar',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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

  void _showMemberDetail(
      BuildContext context, bool isDark, Map<String, dynamic> member) {
    HapticUtils.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Profile header
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(member['name'] as String),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member['name'] as String,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Plano ${member['plan']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildPaymentStatusBadge(
                              member['paymentStatus'] as String),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Member Info
                Text(
                  'Informações do Membro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.mutedDark.withAlpha(100)
                        : AppColors.muted.withAlpha(100),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        isDark,
                        LucideIcons.calendar,
                        'Membro desde',
                        _formatDate(member['memberSince'] as DateTime),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        isDark,
                        LucideIcons.logIn,
                        'Último check-in',
                        _formatLastCheckin(member['lastCheckin'] as DateTime),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        isDark,
                        LucideIcons.creditCard,
                        'Plano',
                        member['plan'] as String,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Recent Check-ins
                Text(
                  'Check-ins Recentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),

                const SizedBox(height: 12),

                ...List.generate(3, (index) {
                  final checkins = [
                    ('Hoje', '07:30', 'Musculação'),
                    ('Ontem', '08:15', 'Funcional'),
                    ('Ter, 10 Jan', '06:45', 'Musculação'),
                  ];
                  final (date, time, activity) = checkins[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.cardDark : AppColors.card)
                          .withAlpha(isDark ? 150 : 200),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LucideIcons.logIn,
                            size: 18,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foreground,
                                ),
                              ),
                              Text(
                                activity,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          Navigator.pop(context);
                          _showMessageSheet(context, isDark, member);
                        },
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.mutedDark : AppColors.muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.messageCircle,
                                size: 18,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Mensagem',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          Navigator.pop(context);
                          _showEditMemberSheet(context, isDark, member);
                        },
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.pencil,
                                size: 18,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Editar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'paid':
        color = AppColors.success;
        label = 'Em dia';
        break;
      case 'expiring':
        color = AppColors.warning;
        label = 'Vencendo';
        break;
      case 'overdue':
        color = AppColors.destructive;
        label = 'Atrasado';
        break;
      default:
        color = AppColors.mutedForeground;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        border: Border.all(color: color.withAlpha(50)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      bool isDark, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatLastCheckin(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return 'Ha ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Ha ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else if (diff.inDays < 7) {
      return 'Ha ${diff.inDays} dias';
    } else {
      return _formatDate(date);
    }
  }

  void _showFilterSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Filtrar Membros',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Selecione os filtros para refinar a busca',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),

              const SizedBox(height: 24),

              // Filter options
              Text(
                'Status de Pagamento',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: 'Todos',
                    isSelected: _selectedFilter == 0,
                    isDark: isDark,
                    onTap: () {
                      setState(() => _selectedFilter = 0);
                      Navigator.pop(context);
                    },
                  ),
                  _FilterChip(
                    label: 'Em dia',
                    isSelected: _selectedFilter == 1,
                    isDark: isDark,
                    color: AppColors.success,
                    onTap: () {
                      setState(() => _selectedFilter = 1);
                      Navigator.pop(context);
                    },
                  ),
                  _FilterChip(
                    label: 'Inadimplentes',
                    isSelected: _selectedFilter == 2,
                    isDark: isDark,
                    color: AppColors.destructive,
                    onTap: () {
                      setState(() => _selectedFilter = 2);
                      Navigator.pop(context);
                    },
                  ),
                  _FilterChip(
                    label: 'Novos (30 dias)',
                    isSelected: _selectedFilter == 3,
                    isDark: isDark,
                    color: AppColors.secondary,
                    onTap: () {
                      setState(() => _selectedFilter = 3);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Clear filters button
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  setState(() {
                    _selectedFilter = 0;
                    _searchController.clear();
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.x,
                        size: 18,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Limpar Filtros',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
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

  void _showMessageSheet(
      BuildContext context, bool isDark, Map<String, dynamic> member) {
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
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
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(member['name'] as String),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
                          'Enviar Mensagem',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                        Text(
                          'para ${member['name']}',
                          style: TextStyle(
                            fontSize: 14,
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

              const SizedBox(height: 24),

              // Message input
              Text(
                'Mensagem',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Digite sua mensagem...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick message templates
              Text(
                'Mensagens Rapidas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickMessageChip(
                    label: 'Lembrete de pagamento',
                    isDark: isDark,
                    onTap: () {
                      messageController.text =
                          'Olá ${member['name'].toString().split(' ').first}! Passando para lembrar sobre o vencimento do seu plano. Qualquer dúvida, estamos à disposição!';
                    },
                  ),
                  _QuickMessageChip(
                    label: 'Boas-vindas',
                    isDark: isDark,
                    onTap: () {
                      messageController.text =
                          'Olá ${member['name'].toString().split(' ').first}! Seja muito bem-vindo(a) à nossa academia! Estamos felizes em ter você conosco.';
                    },
                  ),
                  _QuickMessageChip(
                    label: 'Sentimos sua falta',
                    isDark: isDark,
                    onTap: () {
                      messageController.text =
                          'Olá ${member['name'].toString().split(' ').first}! Sentimos sua falta por aqui! Que tal voltar aos treinos? Estamos te esperando!';
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.x,
                              size: 18,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        if (messageController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Digite uma mensagem'),
                              backgroundColor: AppColors.destructive,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Mensagem enviada para ${member['name']}!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.send,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Enviar',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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

  void _showEditMemberSheet(
      BuildContext context, bool isDark, Map<String, dynamic> member) {
    final nameController = TextEditingController(text: member['name'] as String);
    final emailController = TextEditingController(
        text: '${member['name'].toString().toLowerCase().replaceAll(' ', '.')}@email.com');
    String selectedPlan = member['plan'] as String;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
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
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          LucideIcons.userCog,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Editar Membro',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Name input
                Text(
                  'Nome Completo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Digite o nome',
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Email input
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'email@exemplo.com',
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Plan selector
                Text(
                  'Plano',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _PlanOption(
                        label: 'Mensal',
                        price: 'R\$ 120',
                        isSelected: selectedPlan == 'Mensal',
                        isDark: isDark,
                        onTap: () {
                          HapticUtils.lightImpact();
                          setModalState(() => selectedPlan = 'Mensal');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PlanOption(
                        label: 'Trimestral',
                        price: 'R\$ 300',
                        isSelected: selectedPlan == 'Trimestral',
                        isDark: isDark,
                        onTap: () {
                          HapticUtils.lightImpact();
                          setModalState(() => selectedPlan = 'Trimestral');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PlanOption(
                        label: 'Anual',
                        price: 'R\$ 1000',
                        isSelected: selectedPlan == 'Anual',
                        isDark: isDark,
                        onTap: () {
                          HapticUtils.lightImpact();
                          setModalState(() => selectedPlan = 'Anual');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  isDark ? AppColors.borderDark : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.x,
                                size: 18,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Digite o nome do membro'),
                                backgroundColor: AppColors.destructive,
                              ),
                            );
                            return;
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('${nameController.text} atualizado com sucesso!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.check,
                                size: 18,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Salvar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPlanConfirmationModal({
    required BuildContext context,
    required bool isDark,
    required String planName,
    required String price,
    required String? pricePerMonth,
    required String? savings,
    required List<String> benefits,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (modalContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Plan icon and title
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.creditCard,
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
                          planName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confirmar seleção de plano',
                          style: TextStyle(
                            fontSize: 14,
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

              const SizedBox(height: 24),

              // Price section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.mutedDark.withAlpha(100)
                      : AppColors.muted.withAlpha(100),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    if (pricePerMonth != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        pricePerMonth,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                    if (savings != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          savings,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Benefits section
              Text(
                'Beneficios inclusos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 12),
              ...benefits.map(
                (benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          LucideIcons.check,
                          size: 14,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          benefit,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(modalContext);
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.x,
                              size: 18,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.mediumImpact();
                        Navigator.pop(modalContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$planName selecionado com sucesso!',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.check,
                              size: 18,
                              color: AppColors.primaryForeground,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Confirmar',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryForeground,
                              ),
                            ),
                          ],
                        ),
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
}

class _MemberCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onMessage;

  const _MemberCard({
    required this.member,
    required this.isDark,
    required this.onTap,
    required this.onMessage,
  });

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  String _formatLastCheckin(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return 'Ha ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Ha ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else if (diff.inDays < 7) {
      return 'Ha ${diff.inDays} dias';
    } else {
      return 'Ha ${diff.inDays ~/ 7} sem';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = member['paymentStatus'] as String;
    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'paid':
        statusColor = AppColors.success;
        statusLabel = 'Em dia';
        break;
      case 'expiring':
        statusColor = AppColors.warning;
        statusLabel = 'Vencendo';
        break;
      case 'overdue':
        statusColor = AppColors.destructive;
        statusLabel = 'Atrasado';
        break;
      default:
        statusColor = AppColors.mutedForeground;
        statusLabel = status;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card)
              .withAlpha(isDark ? 150 : 200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar with status indicator
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: member['avatarUrl'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            member['avatarUrl'] as String,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            _getInitials(member['name'] as String),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                ),
                // Payment status indicator
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: statusColor,
                      border: Border.all(
                        color: isDark ? AppColors.cardDark : AppColors.card,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          member['name'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Plano ${member['plan']}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Last check-in
                      Icon(
                        LucideIcons.logIn,
                        size: 12,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatLastCheckin(member['lastCheckin'] as DateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Quick actions
            Column(
              children: [
                GestureDetector(
                  onTap: onMessage,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.mutedDark : AppColors.muted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.messageCircle,
                      size: 16,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanOption extends StatelessWidget {
  final String label;
  final String price;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _PlanOption({
    required this.label,
    required this.price,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(20)
              : (isDark ? AppColors.cardDark : AppColors.card)
                  .withAlpha(isDark ? 150 : 200),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withAlpha(20)
              : (isDark ? AppColors.cardDark : AppColors.card)
                  .withAlpha(isDark ? 150 : 200),
          border: Border.all(
            color: isSelected
                ? chipColor
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                LucideIcons.check,
                size: 14,
                color: chipColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? chipColor
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickMessageChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickMessageChip({
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondary.withAlpha(15),
          border: Border.all(
            color: AppColors.secondary.withAlpha(50),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}

