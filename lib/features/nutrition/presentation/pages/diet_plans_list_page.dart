import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/domain/entities/user_role.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../../../shared/presentation/components/role_bottom_navigation.dart';
import '../providers/diet_plans_provider.dart';

/// Diet Plans List Page for Nutritionists
/// Displays a searchable, filterable list of diet plans with management actions
class DietPlansListPage extends ConsumerStatefulWidget {
  const DietPlansListPage({super.key});

  @override
  ConsumerState<DietPlansListPage> createState() => _DietPlansListPageState();
}

class _DietPlansListPageState extends ConsumerState<DietPlansListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedFilter = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isRefreshing = false;

  final _filters = ['Meus Planos', 'Templates', 'Compartilhados'];

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

    _searchController.addListener(_onSearchChanged);

    // Load plans from API
    Future.microtask(() {
      ref.read(dietPlansProvider.notifier).loadPlans();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<DietPlan> _getFilteredPlans(List<DietPlan> allPlans) {
    return allPlans.where((plan) {
      // Filter by search query
      final matchesSearch = _searchQuery.isEmpty ||
          plan.name.toLowerCase().contains(_searchQuery) ||
          plan.description.toLowerCase().contains(_searchQuery);

      // Filter by tab selection
      final matchesFilter = _selectedFilter == 0 && !plan.isTemplate && !plan.isShared ||
          (_selectedFilter == 1 && plan.isTemplate) ||
          (_selectedFilter == 2 && plan.isShared);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    HapticUtils.mediumImpact();

    await ref.read(dietPlansProvider.notifier).loadPlans();

    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'low carb':
        return AppColors.secondary;
      case 'alto proteina':
      case 'alta proteina':
        return AppColors.success;
      case 'vegetariano':
        return AppColors.accent;
      case 'vegano':
        return AppColors.primary;
      case 'pre-treino':
      case 'pos-treino':
        return AppColors.warning;
      case 'cetogenica':
        return AppColors.destructive;
      case 'mediterranea':
        return AppColors.info;
      default:
        return AppColors.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final plansState = ref.watch(dietPlansProvider);
    final filteredPlans = _getFilteredPlans(plansState.plans);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      bottomNavigationBar: const RoleBottomNavigation(
        role: UserRole.nutritionist,
        currentIndex: 2, // Planos tab
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? AppColors.primaryDark : AppColors.primary)
                  .withAlpha(isDark ? 15 : 10),
              (isDark ? AppColors.secondaryDark : AppColors.secondary)
                  .withAlpha(isDark ? 12 : 8),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and add button
                        FadeInUp(
                          child: Row(
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
                                    'Planos Alimentares',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  HapticUtils.lightImpact();
                                  // Navigate to create plan
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withAlpha(isDark ? 40 : 60),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    LucideIcons.filePlus,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Search bar
                        FadeInUp(
                          delay: const Duration(milliseconds: 100),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark.withAlpha(150)
                                  : AppColors.card.withAlpha(200),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.border,
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
                                    decoration: InputDecoration(
                                      hintText: 'Buscar planos...',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: isDark
                                            ? AppColors.mutedForegroundDark
                                            : AppColors.mutedForeground,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      HapticUtils.selectionClick();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Icon(
                                        LucideIcons.x,
                                        size: 16,
                                        color: isDark
                                            ? AppColors.mutedForegroundDark
                                            : AppColors.mutedForeground,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Filter tabs
                        FadeInUp(
                          delay: const Duration(milliseconds: 150),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _filters.asMap().entries.map((entry) {
                                final isSelected = entry.key == _selectedFilter;
                                return GestureDetector(
                                  onTap: () {
                                    HapticUtils.selectionClick();
                                    setState(
                                        () => _selectedFilter = entry.key);
                                  },
                                  child: AnimatedContainer(
                                    duration: AppAnimations.fast,
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDark
                                              ? AppColors.foregroundDark
                                              : AppColors.foreground)
                                          : (isDark
                                              ? AppColors.cardDark
                                                  .withAlpha(150)
                                              : AppColors.card.withAlpha(200)),
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
                        ),
                      ],
                    ),
                  ),

                  // Stats summary
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _StatsSummary(
                        isDark: isDark,
                        totalPlans: plansState.myPlansCount,
                        templates: plansState.templatesCount,
                        shared: plansState.sharedCount,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Plans list
                  Expanded(
                    child: plansState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : plansState.error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.alertCircle,
                                      size: 48,
                                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Erro ao carregar planos',
                                      style: TextStyle(
                                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _onRefresh,
                                      child: const Text('Tentar novamente'),
                                    ),
                                  ],
                                ),
                              )
                            : filteredPlans.isEmpty
                                ? _EmptyState(isDark: isDark, searchQuery: _searchQuery)
                                : RefreshIndicator(
                                    onRefresh: _onRefresh,
                                    color: isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary,
                                    backgroundColor:
                                        isDark ? AppColors.cardDark : AppColors.card,
                                    child: ListView.builder(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 20),
                                      itemCount: filteredPlans.length,
                                      itemBuilder: (context, index) {
                                        final plan = filteredPlans[index];
                                        final planMap = plan.toMap();
                                        return FadeInUp(
                                          delay:
                                              Duration(milliseconds: 250 + (index * 50)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _DietPlanCard(
                                              plan: planMap,
                                              isDark: isDark,
                                              getTagColor: _getTagColor,
                                              onTap: () {
                                                HapticUtils.selectionClick();
                                                _showPlanDetail(context, isDark, planMap);
                                              },
                                              onEdit: () {
                                                HapticUtils.lightImpact();
                                                context.push('/nutrition/builder?planId=${plan.id}');
                                              },
                                              onDuplicate: () {
                                                HapticUtils.lightImpact();
                                                _showDuplicateConfirmation(context, isDark, planMap);
                                              },
                                              onDelete: () {
                                                HapticUtils.lightImpact();
                                                _showDeleteConfirmation(context, isDark, planMap);
                                              },
                                            ),
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
      floatingActionButton: FadeInUp(
        delay: const Duration(milliseconds: 500),
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticUtils.lightImpact();
            // Navigate to create new plan
          },
          backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
          icon: const Icon(LucideIcons.filePlus, color: Colors.white),
          label: const Text(
            'Novo Plano',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showPlanDetail(
      BuildContext context, bool isDark, Map<String, dynamic> plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
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

                // Plan header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.clipboardList,
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
                            plan['name'] as String,
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
                            plan['description'] as String,
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

                const SizedBox(height: 20),

                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (plan['tags'] as List<String>).map((tag) {
                    final tagColor = _getTagColor(tag);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: tagColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Stats
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailStat(
                        '${plan['calories']}',
                        'kcal/dia',
                        isDark,
                      ),
                      _buildDetailStat(
                        '${plan['assignedCount']}',
                        'Pacientes',
                        isDark,
                      ),
                      _buildDetailStat(
                        (plan['isTemplate'] as bool) ? 'Sim' : 'Não',
                        'Template',
                        isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Macros breakdown
                Text(
                  'Distribuição de Macros',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),

                const SizedBox(height: 12),

                _MacrosBar(isDark: isDark),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          Navigator.pop(context);
                          context.push('/nutrition/builder?planId=${plan['id']}');
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
                              Icon(LucideIcons.pencil,
                                  size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Editar Plano',
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          Navigator.pop(context);
                          _showDuplicateConfirmation(context, isDark, plan);
                        },
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.copy,
                                size: 18,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Duplicar',
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
                  ],
                ),

                const SizedBox(height: 12),

                // Assign to patient button
                GestureDetector(
                  onTap: () {
                    HapticUtils.lightImpact();
                    // Show patient selector
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      border: Border.all(
                        color: AppColors.success.withAlpha(100),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.userPlus, size: 18, color: AppColors.success),
                        SizedBox(width: 8),
                        Text(
                          'Atribuir a Paciente',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.success,
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
      ),
    );
  }

  void _showDuplicateConfirmation(
      BuildContext context, bool isDark, Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Duplicar Plano',
          style: TextStyle(
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        content: Text(
          'Deseja criar uma copia de "${plan['name']}"?',
          style: TextStyle(
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(context);
              // Duplicate plan
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Plano duplicado com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text(
              'Duplicar',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, bool isDark, Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Excluir Plano',
          style: TextStyle(
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir "${plan['name']}"? Esta ação não pode ser desfeita.',
          style: TextStyle(
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(context);
              // Delete plan
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Plano excluído com sucesso!'),
                  backgroundColor: AppColors.destructive,
                ),
              );
            },
            child: const Text(
              'Excluir',
              style: TextStyle(
                color: AppColors.destructive,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStat(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
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
}

// Stats Summary Widget
class _StatsSummary extends StatelessWidget {
  final bool isDark;
  final int totalPlans;
  final int templates;
  final int shared;

  const _StatsSummary({
    required this.isDark,
    required this.totalPlans,
    required this.templates,
    required this.shared,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniStat('$totalPlans', 'Meus Planos', null),
          Container(
            width: 1,
            height: 30,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          _buildMiniStat('$templates', 'Templates', AppColors.secondary),
          Container(
            width: 1,
            height: 30,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          _buildMiniStat('$shared', 'Compartilhados', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color? color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color:
                color ?? (isDark ? AppColors.foregroundDark : AppColors.foreground),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color:
                isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

// Diet Plan Card Widget
class _DietPlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isDark;
  final Color Function(String) getTagColor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _DietPlanCard({
    required this.plan,
    required this.isDark,
    required this.getTagColor,
    required this.onTap,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = plan['name'] as String;
    final description = plan['description'] as String;
    final calories = plan['calories'] as int;
    final assignedCount = plan['assignedCount'] as int;
    final tags = plan['tags'] as List<String>;
    final isTemplate = plan['isTemplate'] as bool;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isTemplate
                        ? AppColors.secondary.withAlpha(25)
                        : AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isTemplate ? LucideIcons.layoutTemplate : LucideIcons.clipboardList,
                    size: 20,
                    color: isTemplate ? AppColors.secondary : AppColors.primary,
                  ),
                ),

                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Actions menu
                PopupMenuButton<String>(
                  icon: Icon(
                    LucideIcons.moreVertical,
                    size: 18,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                  color: isDark ? AppColors.cardDark : AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'duplicate':
                        onDuplicate();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.pencil,
                            size: 16,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Editar',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.copy,
                            size: 16,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Duplicar',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.trash2,
                            size: 16,
                            color: AppColors.destructive,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Excluir',
                            style: TextStyle(
                              color: AppColors.destructive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.take(3).map((tag) {
                final tagColor = getTagColor(tag);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: tagColor,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                Icon(
                  LucideIcons.flame,
                  size: 14,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 4),
                Text(
                  '$calories kcal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  LucideIcons.users,
                  size: 14,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 4),
                Text(
                  '$assignedCount paciente${assignedCount != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
                const Spacer(),
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

// Macros Bar Widget
class _MacrosBar extends StatelessWidget {
  final bool isDark;

  const _MacrosBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Visual bar
        Container(
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Expanded(
                flex: 50,
                child: Container(
                  color: AppColors.primary,
                  child: const Center(
                    child: Text(
                      '50%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 25,
                child: Container(
                  color: AppColors.success,
                  child: const Center(
                    child: Text(
                      '25%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 25,
                child: Container(
                  color: AppColors.warning,
                  child: const Center(
                    child: Text(
                      '25%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMacroLegend('Carboidratos', '50%', AppColors.primary, isDark),
            _buildMacroLegend('Proteínas', '25%', AppColors.success, isDark),
            _buildMacroLegend('Gorduras', '25%', AppColors.warning, isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroLegend(String label, String value, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Empty State Widget
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final String searchQuery;

  const _EmptyState({
    required this.isDark,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final isSearching = searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryDark : AppColors.primary)
                    .withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSearching ? LucideIcons.searchX : LucideIcons.clipboardList,
                size: 36,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching ? 'Nenhum plano encontrado' : 'Nenhum plano ainda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Tente buscar por outro nome'
                  : 'Crie seu primeiro plano alimentar para começar',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isSearching) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  // Navigate to create plan
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.filePlus, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Criar Plano',
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
            ],
          ],
        ),
      ),
    );
  }
}
