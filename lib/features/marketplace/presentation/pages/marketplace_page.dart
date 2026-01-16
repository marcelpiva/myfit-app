import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/template_card.dart';
import 'my_purchases_page.dart';
import 'template_detail_page.dart';

class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({super.key});

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  final _typeFilters = [
    ('Todos', null, LucideIcons.layoutGrid),
    ('Treinos', 'workout', LucideIcons.dumbbell),
    ('Dietas', 'diet_plan', LucideIcons.utensils),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final type = _typeFilters[_tabController.index].$2;
      ref.read(marketplaceNotifierProvider.notifier).setFilter(type: type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(marketplaceNotifierProvider);
    final categories = ref.watch(marketplaceCategoriesProvider);

    return Scaffold(
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
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Templates',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Treinos e dietas prontos para usar',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildIconButton(
                                icon: LucideIcons.shoppingBag,
                                onTap: () => _navigateToMyPurchases(context),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Search Bar
                      _buildSearchBar(isDark),

                      const SizedBox(height: 16),

                      // Type Tabs
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDark.withAlpha(150)
                              : AppColors.card.withAlpha(200),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                          labelStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          tabs: _typeFilters.map((filter) {
                            return Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(filter.$3, size: 16),
                                  const SizedBox(width: 6),
                                  Text(filter.$1),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Featured Section
              if (state.featuredTemplates.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.sparkles,
                              size: 18,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Destaques',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: state.featuredTemplates.length,
                          itemBuilder: (context, index) {
                            final template = state.featuredTemplates[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < state.featuredTemplates.length - 1 ? 12 : 0,
                              ),
                              child: SizedBox(
                                width: 180,
                                child: TemplateCard(
                                  template: template,
                                  onTap: () => _navigateToDetail(context, template),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

              // Categories
              if (categories.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Categorias',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: categories.length + 1,
                          itemBuilder: (context, index) {
                            final isAll = index == 0;
                            final isSelected = isAll
                                ? _selectedCategoryIndex == 0
                                : _selectedCategoryIndex == index;
                            final category = isAll ? null : categories[index - 1];

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedCategoryIndex = index);
                                  ref
                                      .read(marketplaceNotifierProvider.notifier)
                                      .setFilter(category: category?.category);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.cardDark.withAlpha(150)
                                            : AppColors.card.withAlpha(200)),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isDark
                                              ? AppColors.borderDark
                                              : AppColors.border),
                                    ),
                                  ),
                                  child: Text(
                                    isAll ? 'Todos' : category!.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? AppColors.foregroundDark
                                              : AppColors.foreground),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

              // Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Explorar',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${state.templates.length} templates',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? _buildErrorState(state.error!, isDark)
                    : state.templates.isEmpty
                        ? _buildEmptyState(isDark)
                        : RefreshIndicator(
                            onRefresh: () async {
                              ref.read(marketplaceNotifierProvider.notifier).refresh();
                            },
                            child: GridView.builder(
                              padding: const EdgeInsets.all(24),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: state.templates.length,
                              itemBuilder: (context, index) {
                                final template = state.templates[index];
                                return TemplateCard(
                                  template: template,
                                  onTap: () => _navigateToDetail(context, template),
                                );
                              },
                            ),
                          ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                size: 20,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            if (badgeCount != null && badgeCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.destructive,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 9 ? '9+' : badgeCount.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 48,
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
        children: [
          const SizedBox(width: 14),
          Icon(
            LucideIcons.search,
            size: 18,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar templates...',
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
              onSubmitted: (value) {
                ref.read(marketplaceNotifierProvider.notifier).search(value);
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                ref.read(marketplaceNotifierProvider.notifier).search('');
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
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
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.packageSearch,
              size: 64,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum template encontrado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros ou buscar por outro termo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(marketplaceNotifierProvider.notifier).refresh();
              },
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, MarketplaceTemplate template) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TemplateDetailPage(template: template),
      ),
    );
  }

  void _navigateToMyPurchases(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MyPurchasesPage(),
      ),
    );
  }
}
