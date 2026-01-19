import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../providers/organization_provider.dart';

/// Financial Reports and Analytics page for Gym owners/admins
class GymReportsPage extends ConsumerStatefulWidget {
  const GymReportsPage({super.key});

  @override
  ConsumerState<GymReportsPage> createState() => _GymReportsPageState();
}

class _GymReportsPageState extends ConsumerState<GymReportsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _selectedPeriod = 0;

  final _periods = ['Este Mês', 'Últimos 3 Meses', 'Este Ano'];
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

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

    // Load report data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReportData();
    });
  }

  void _loadReportData() {
    final orgId = ref.read(activeContextProvider)?.membership.organization.id;
    if (orgId != null) {
      ref.read(organizationStatsNotifierProvider(orgId).notifier).loadStats(
        days: _getPeriodDays(),
      );
    }
  }

  int _getPeriodDays() {
    switch (_selectedPeriod) {
      case 0:
        return 30; // Este Mes
      case 1:
        return 90; // Ultimos 3 Meses
      case 2:
        return 365; // Este Ano
      default:
        return 30;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper methods to convert API data to UI format
  Map<String, Map<String, dynamic>> _buildSummaryFromStats(Map<String, dynamic> stats) {
    final revenue = stats['total_revenue'] ?? 0;
    final revenueChange = stats['revenue_change'] ?? 0;
    final newMembers = stats['new_members'] ?? 0;
    final newMembersChange = stats['new_members_change'] ?? 0;
    final cancellations = stats['cancellations'] ?? 0;
    final cancellationsChange = stats['cancellations_change'] ?? 0;
    final retention = stats['retention_rate'] ?? 0;
    final retentionChange = stats['retention_change'] ?? 0;

    return {
      'revenue': {
        'value': _currencyFormat.format(revenue),
        'change': '${revenueChange >= 0 ? '+' : ''}${revenueChange.toStringAsFixed(1)}%',
        'positive': revenueChange >= 0,
      },
      'newMembers': {
        'value': '$newMembers',
        'change': '${newMembersChange >= 0 ? '+' : ''}$newMembersChange',
        'positive': newMembersChange >= 0,
      },
      'cancellations': {
        'value': '$cancellations',
        'change': '${cancellationsChange >= 0 ? '+' : ''}$cancellationsChange',
        'positive': cancellationsChange <= 0, // Less cancellations is positive
      },
      'retention': {
        'value': '${retention.toStringAsFixed(0)}%',
        'change': '${retentionChange >= 0 ? '+' : ''}${retentionChange.toStringAsFixed(1)}%',
        'positive': retentionChange >= 0,
      },
    };
  }

  List<Map<String, dynamic>> _buildPlanBreakdownFromStats(Map<String, dynamic> stats) {
    final breakdown = stats['plan_breakdown'] as List<dynamic>? ?? [];
    return breakdown.map((item) {
      final map = item as Map<String, dynamic>;
      return {
        'name': map['name'] ?? '',
        'value': _currencyFormat.format(map['value'] ?? 0),
        'percentage': (map['percentage'] ?? 0).round(),
        'count': map['count'] ?? 0,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _buildCategoryBreakdownFromStats(Map<String, dynamic> stats) {
    final breakdown = stats['category_breakdown'] as List<dynamic>? ?? [];
    final colors = [AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.success];

    return breakdown.asMap().entries.map((entry) {
      final map = entry.value as Map<String, dynamic>;
      return {
        'name': map['name'] ?? '',
        'value': _currencyFormat.format(map['value'] ?? 0),
        'percentage': (map['percentage'] ?? 0).round(),
        'color': colors[entry.key % colors.length],
      };
    }).toList();
  }

  List<Map<String, dynamic>> _buildTransactionsFromStats(Map<String, dynamic> stats) {
    final transactions = stats['recent_transactions'] as List<dynamic>? ?? [];
    return transactions.map((item) {
      final map = item as Map<String, dynamic>;
      return {
        'name': map['member_name'] ?? '',
        'type': map['plan_type'] ?? '',
        'value': _currencyFormat.format(map['amount'] ?? 0),
        'date': _formatTransactionDate(map['date'] as String?),
        'status': map['status'] ?? 'success',
      };
    }).toList();
  }

  String _formatTransactionDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return 'Hoje, ${DateFormat('HH:mm').format(date)}';
      } else if (diff.inDays == 1) {
        return 'Ontem, ${DateFormat('HH:mm').format(date)}';
      } else {
        return DateFormat('dd MMM, HH:mm').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get org context and stats
    final activeContext = ref.watch(activeContextProvider);
    final orgId = activeContext?.membership.organization.id;
    final statsState = orgId != null
        ? ref.watch(organizationStatsNotifierProvider(orgId))
        : const OrganizationStatsState();

    // Build data from stats
    final summary = _buildSummaryFromStats(statsState.stats);
    final planBreakdown = _buildPlanBreakdownFromStats(statsState.stats);
    final categoryBreakdown = _buildCategoryBreakdownFromStats(statsState.stats);
    final transactions = _buildTransactionsFromStats(statsState.stats);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
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
                                    width: 44,
                                    height: 44,
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
                                const SizedBox(width: 16),
                                Text(
                                  'Relatórios',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticUtils.lightImpact();
                                _showExportOptions(context, isDark);
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  LucideIcons.download,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Period Selector
                        _PeriodSelector(
                          isDark: isDark,
                          periods: _periods,
                          selectedIndex: _selectedPeriod,
                          onChanged: (index) {
                            setState(() => _selectedPeriod = index);
                            _loadReportData();
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Summary Cards
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: _buildSummaryCards(theme, isDark, summary, statsState.isLoading),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: const SizedBox(height: 20)),

                // Revenue Chart
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: _buildRevenueChart(theme, isDark),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: const SizedBox(height: 20)),

                // Breakdown Section
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'Detalhamento',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: const SizedBox(height: 12)),

                // Plan Breakdown
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 350),
                      child: _buildBreakdownCard(
                        theme,
                        isDark,
                        'Por Tipo de Plano',
                        LucideIcons.creditCard,
                        planBreakdown,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: const SizedBox(height: 12)),

                // Category Breakdown
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildCategoryBreakdownCard(theme, isDark, categoryBreakdown),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: const SizedBox(height: 20)),

                // Recent Transactions
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 450),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transações Recentes',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              HapticUtils.lightImpact();
                            },
                            child: const Text('Ver todas'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: const SizedBox(height: 12)),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: _buildTransactionsList(theme, isDark, transactions),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: const SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    ThemeData theme,
    bool isDark,
    Map<String, Map<String, dynamic>> summary,
    bool isLoading,
  ) {
    final stats = [
      {
        'label': 'Receita Total',
        'value': isLoading ? '-' : (summary['revenue']?['value'] ?? '-'),
        'change': summary['revenue']?['change'] ?? '-',
        'icon': LucideIcons.dollarSign,
        'positive': summary['revenue']?['positive'] ?? true,
      },
      {
        'label': 'Novos Membros',
        'value': isLoading ? '-' : (summary['newMembers']?['value'] ?? '0'),
        'change': summary['newMembers']?['change'] ?? '-',
        'icon': LucideIcons.userPlus,
        'positive': summary['newMembers']?['positive'] ?? true,
      },
      {
        'label': 'Cancelamentos',
        'value': isLoading ? '-' : (summary['cancellations']?['value'] ?? '0'),
        'change': summary['cancellations']?['change'] ?? '-',
        'icon': LucideIcons.userMinus,
        'positive': summary['cancellations']?['positive'] ?? true,
      },
      {
        'label': 'Taxa de Retenção',
        'value': isLoading ? '-' : (summary['retention']?['value'] ?? '-'),
        'change': summary['retention']?['change'] ?? '-',
        'icon': LucideIcons.trendingUp,
        'positive': summary['retention']?['positive'] ?? true,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return GestureDetector(
          onTap: () {
            HapticUtils.lightImpact();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.cardDark : AppColors.card)
                  .withAlpha(isDark ? 150 : 200),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      stat['icon'] as IconData,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (stat['positive'] as bool)
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.destructive.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        stat['change'] as String,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: (stat['positive'] as bool)
                              ? AppColors.success
                              : AppColors.destructive,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat['value'] as String,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      stat['label'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevenueChart(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card)
            .withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Evolução da Receita',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _periods[_selectedPeriod],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.trendingUp, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      '+12.5%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bar Chart Placeholder
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(isDark, 'Jan', 0.6),
                  _buildBar(isDark, 'Fev', 0.75),
                  _buildBar(isDark, 'Mar', 0.65),
                  _buildBar(isDark, 'Abr', 0.8),
                  _buildBar(isDark, 'Mai', 0.7),
                  _buildBar(isDark, 'Jun', 0.85),
                  _buildBar(isDark, 'Jul', 0.9),
                  _buildBar(isDark, 'Ago', 0.78),
                  _buildBar(isDark, 'Set', 0.88),
                  _buildBar(isDark, 'Out', 0.82),
                  _buildBar(isDark, 'Nov', 0.95),
                  _buildBar(isDark, 'Dez', 1.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(bool isDark, String label, double heightPercentage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 16,
          height: 100 * heightPercentage,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownCard(
    ThemeData theme,
    bool isDark,
    String title,
    IconData icon,
    List<Map<String, dynamic>> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card)
            .withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _buildBreakdownItem(
                theme,
                isDark,
                item['name'] as String,
                item['value'] as String,
                item['percentage'] as int,
                item['count'] as int,
              )),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
    ThemeData theme,
    bool isDark,
    String name,
    String value,
    int percentage,
    int count,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '($count)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.mutedDark : AppColors.muted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(
    ThemeData theme,
    bool isDark,
    List<Map<String, dynamic>> categoryBreakdown,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card)
            .withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.pieChart, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Por Categoria',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (categoryBreakdown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Nenhum dado disponível',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            ...categoryBreakdown.map((item) => _buildCategoryItem(
                  theme,
                  isDark,
                  item['name'] as String,
                  item['value'] as String,
                  item['percentage'] as int,
                  item['color'] as Color,
                )),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    ThemeData theme,
    bool isDark,
    String name,
    String value,
    int percentage,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$percentage%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    ThemeData theme,
    bool isDark,
    List<Map<String, dynamic>> transactions,
  ) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card)
              .withAlpha(isDark ? 150 : 200),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Nenhuma transação recente',
            style: TextStyle(
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card)
            .withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: transactions.asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;
          final isLast = index == transactions.length - 1;

          return GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: transaction['status'] == 'success'
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      transaction['status'] == 'success'
                          ? LucideIcons.checkCircle
                          : LucideIcons.clock,
                      size: 18,
                      color: transaction['status'] == 'success'
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction['name'] as String,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          transaction['type'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        transaction['value'] as String,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        transaction['date'] as String,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showExportOptions(BuildContext context, bool isDark) {
    HapticUtils.lightImpact();
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
                'Exportar Relatório',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Escolha o formato para exportar',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),

              const SizedBox(height: 24),

              // Export options
              _buildExportOption(
                context,
                isDark,
                'PDF',
                'Documento formatado para impressao',
                LucideIcons.fileText,
                AppColors.destructive,
              ),

              const SizedBox(height: 12),

              _buildExportOption(
                context,
                isDark,
                'Excel',
                'Planilha com dados detalhados',
                LucideIcons.table,
                AppColors.success,
              ),

              const SizedBox(height: 24),

              // Cancel button
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
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
                  child: Center(
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
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

  Widget _buildExportOption(
    BuildContext context,
    bool isDark,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exportando relatório em $title...'),
          ),
        );
      },
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
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                  Text(
                    description,
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
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final bool isDark;
  final List<String> periods;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _PeriodSelector({
    required this.isDark,
    required this.periods,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card)
            .withAlpha(isDark ? 150 : 200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: periods.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                onChanged(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
