import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../providers/organization_provider.dart';

/// Dashboard page for Gym/Academy owners and admins
class GymDashboardPage extends ConsumerWidget {
  const GymDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get org context
    final activeContext = ref.watch(activeContextProvider);
    final orgId = activeContext?.organization.id;
    final orgName = activeContext?.organization.name ?? 'Academia';

    // Get real stats
    final memberCounts = orgId != null ? ref.watch(memberCountsProvider(orgId)) : <String, int>{};
    final trainers = orgId != null ? ref.watch(trainersProvider(orgId)) : <Map<String, dynamic>>[];
    final statsState = orgId != null ? ref.watch(organizationStatsNotifierProvider(orgId)) : null;

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
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orgName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Painel Administrativo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      HapticUtils.lightImpact();
                    },
                    icon: Badge(
                      label: const Text('3'),
                      child: Icon(LucideIcons.bell),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      HapticUtils.lightImpact();
                    },
                    icon: Icon(LucideIcons.settings),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Period Selector
                    FadeInUp(
                      child: _PeriodSelector(isDark: isDark),
                    ),

                    const SizedBox(height: 20),

                    // Main Stats Grid
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: _buildMainStats(theme, isDark, memberCounts, trainers.length, statsState?.stats),
                    ),

                    const SizedBox(height: 20),

                    // Revenue Chart Placeholder
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: _buildRevenueCard(theme, isDark),
                    ),

                    const SizedBox(height: 20),

                    // Quick Actions
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'Ações Rápidas',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeInUp(
                      delay: const Duration(milliseconds: 350),
                      child: _buildQuickActions(theme, isDark),
                    ),

                    const SizedBox(height: 24),

                    // Trainers Section
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildSectionHeader(theme, 'Professores', 'Ver todos', () {
                        HapticUtils.lightImpact();
                      }),
                    ),
                    const SizedBox(height: 12),
                    FadeInUp(
                      delay: const Duration(milliseconds: 450),
                      child: _buildTrainersGrid(theme, isDark, trainers),
                    ),

                    const SizedBox(height: 24),

                    // Recent Activities
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: _buildSectionHeader(theme, 'Atividade Recente', 'Ver mais', () {
                        HapticUtils.lightImpact();
                      }),
                    ),
                    const SizedBox(height: 12),
                    FadeInUp(
                      delay: const Duration(milliseconds: 550),
                      child: _buildRecentActivities(theme, isDark),
                    ),

                    const SizedBox(height: 24),

                    // Pending Approvals
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      child: _buildPendingApprovals(theme, isDark),
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

  Widget _buildMainStats(ThemeData theme, bool isDark, Map<String, int> memberCounts, int trainerCount, Map<String, dynamic>? orgStats) {
    final studentCount = memberCounts['students'] ?? 0;
    final checkinsToday = (orgStats?['checkins_today'] as num?)?.toInt() ?? 0;
    final retentionRate = (orgStats?['retention_rate'] as num?)?.toDouble() ?? 0;

    final stats = [
      {'label': 'Alunos Ativos', 'value': '$studentCount', 'change': '', 'icon': LucideIcons.users, 'positive': true},
      {'label': 'Professores', 'value': '$trainerCount', 'change': '', 'icon': LucideIcons.userCheck, 'positive': true},
      {'label': 'Check-ins Hoje', 'value': '$checkinsToday', 'change': '', 'icon': LucideIcons.logIn, 'positive': true},
      {'label': 'Taxa de Retenção', 'value': '${retentionRate.toStringAsFixed(0)}%', 'change': '', 'icon': LucideIcons.trendingUp, 'positive': true},
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
              color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
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
                    if ((stat['change'] as String).isNotEmpty)
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

  Widget _buildRevenueCard(ThemeData theme, bool isDark) {
    // Revenue data not yet available from API
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
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
                      'Receita Mensal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dados financeiros',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Placeholder for chart
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.barChart3,
                      size: 32,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dados financeiros serão exibidos aqui',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, bool isDark) {
    final actions = [
      {'label': 'Novo Aluno', 'icon': LucideIcons.userPlus, 'color': AppColors.primary},
      {'label': 'Novo Professor', 'icon': LucideIcons.userCheck, 'color': AppColors.secondary},
      {'label': 'Financeiro', 'icon': LucideIcons.dollarSign, 'color': AppColors.success},
      {'label': 'Relatórios', 'icon': LucideIcons.fileText, 'color': AppColors.accent},
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: actions.indexOf(action) < actions.length - 1 ? 8 : 0,
            ),
            child: InkWell(
              onTap: () {
                HapticUtils.lightImpact();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withValues(alpha: 0.1),
                  border: Border.all(
                    color: (action['color'] as Color).withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['label'] as String,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(action),
        ),
      ],
    );
  }

  Widget _buildTrainersGrid(ThemeData theme, bool isDark, List<Map<String, dynamic>> trainers) {
    if (trainers.isEmpty) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.userX,
                size: 24,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'Nenhum professor cadastrado',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: trainers.length,
        itemBuilder: (context, index) {
          final trainer = trainers[index];
          final trainerName = trainer['name'] ?? trainer['user_name'] ?? 'Professor';
          final specialty = trainer['specialty'] ?? '';
          final studentCount = (trainer['student_count'] as num?)?.toInt() ?? 0;

          return GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
            },
            child: Container(
              width: 160,
              margin: EdgeInsets.only(right: index < trainers.length - 1 ? 12 : 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
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
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          trainerName.isNotEmpty ? trainerName.substring(0, 1) : 'P',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    trainerName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (specialty.isNotEmpty)
                    Text(
                      specialty,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '$studentCount alunos',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentActivities(ThemeData theme, bool isDark) {
    // Activity feed not yet available from API
    final activities = <Map<String, dynamic>>[];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: activities.isEmpty
          ? Center(
              child: Column(
                children: [
                  Icon(
                    LucideIcons.activity,
                    size: 32,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Atividades recentes serão exibidas aqui',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: activities.map((activity) {
                final isLast = activities.indexOf(activity) == activities.length - 1;
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
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            activity['icon'] as IconData,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['user'] as String,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _getActivityDescription(activity['type'] as String),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          activity['time'] as String,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  String _getActivityDescription(String type) {
    switch (type) {
      case 'check_in':
        return 'Check-in realizado';
      case 'check_out':
        return 'Check-out realizado';
      case 'payment':
        return 'Pagamento confirmado';
      case 'new_student':
        return 'Novo aluno cadastrado';
      default:
        return '';
    }
  }

  Widget _buildPendingApprovals(ThemeData theme, bool isDark) {
    // Pending approvals not yet available from API
    final pendingApprovals = <Map<String, dynamic>>[];

    if (pendingApprovals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.checkCircle, color: AppColors.success, size: 24),
            const SizedBox(width: 12),
            Text(
              'Nenhuma aprovação pendente',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.alertCircle, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Aprovações Pendentes',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${pendingApprovals.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...pendingApprovals.map((approval) => _buildPendingItem(
            theme,
            approval['name'] as String? ?? '',
            approval['request'] as String? ?? '',
          )),
        ],
      ),
    );
  }

  Widget _buildPendingItem(ThemeData theme, String name, String request) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  request,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Aprovar'),
          ),
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.destructive,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Recusar'),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatefulWidget {
  final bool isDark;

  const _PeriodSelector({required this.isDark});

  @override
  State<_PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<_PeriodSelector> {
  String _selected = 'month';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: (widget.isDark ? AppColors.cardDark : AppColors.card).withAlpha(widget.isDark ? 150 : 200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildOption('Hoje', 'today'),
          _buildOption('Semana', 'week'),
          _buildOption('Mes', 'month'),
          _buildOption('Ano', 'year'),
        ],
      ),
    );
  }

  Widget _buildOption(String label, String value) {
    final theme = Theme.of(context);
    final isSelected = _selected == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticUtils.lightImpact();
          setState(() => _selected = value);
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
              color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
