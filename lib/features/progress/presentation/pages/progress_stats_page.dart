import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';

class ProgressStatsPage extends ConsumerStatefulWidget {
  const ProgressStatsPage({super.key});

  @override
  ConsumerState<ProgressStatsPage> createState() => _ProgressStatsPageState();
}

class _ProgressStatsPageState extends ConsumerState<ProgressStatsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  String _selectedPeriod = '30';

  // Mock stats data
  final Map<String, Map<String, dynamic>> _statsData = {
    '7': {
      'weight_logs': 5,
      'measurement_logs': 1,
      'photos': 2,
      'weight_change': -0.4,
      'avg_weight': 77.8,
      'goal_progress': 45,
      'streak': 5,
      'best_day': 'Segunda',
    },
    '30': {
      'weight_logs': 18,
      'measurement_logs': 4,
      'photos': 6,
      'weight_change': -2.1,
      'avg_weight': 77.2,
      'goal_progress': 58,
      'streak': 12,
      'best_day': 'Quarta',
    },
    '90': {
      'weight_logs': 52,
      'measurement_logs': 12,
      'photos': 15,
      'weight_change': -5.8,
      'avg_weight': 76.5,
      'goal_progress': 72,
      'streak': 28,
      'best_day': 'Segunda',
    },
  };

  // Mock measurement changes
  final Map<String, double> _measurementChanges = {
    'chest': -1.5,
    'waist': -4.2,
    'hips': -2.8,
    'biceps': 0.8,
    'thigh': -1.9,
    'calf': 0.2,
  };

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

  Map<String, dynamic> get _currentStats => _statsData[_selectedPeriod]!;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
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
                          Navigator.pop(context);
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
                            LucideIcons.arrowLeft,
                            size: 18,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Estatisticas',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // Period selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildPeriodSelector(isDark),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main stats grid
                        _buildMainStatsGrid(isDark),

                        const SizedBox(height: 24),

                        // Weight progress section
                        _buildWeightProgressSection(isDark),

                        const SizedBox(height: 24),

                        // Measurement changes
                        _buildMeasurementChangesSection(isDark),

                        const SizedBox(height: 24),

                        // Activity overview
                        _buildActivityOverview(isDark),

                        const SizedBox(height: 32),
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

  Widget _buildPeriodSelector(bool isDark) {
    final periods = [
      {'value': '7', 'label': '7 dias'},
      {'value': '30', 'label': '30 dias'},
      {'value': '90', 'label': '90 dias'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                setState(() {
                  _selectedPeriod = period['value']!;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.primaryDark : AppColors.primary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period['label']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainStatsGrid(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: LucideIcons.scale,
          label: 'Registros de Peso',
          value: '${_currentStats['weight_logs']}',
          color: AppColors.primary,
          isDark: isDark,
        ),
        _buildStatCard(
          icon: LucideIcons.ruler,
          label: 'Medidas',
          value: '${_currentStats['measurement_logs']}',
          color: AppColors.secondary,
          isDark: isDark,
        ),
        _buildStatCard(
          icon: LucideIcons.camera,
          label: 'Fotos',
          value: '${_currentStats['photos']}',
          color: AppColors.accent,
          isDark: isDark,
        ),
        _buildStatCard(
          icon: LucideIcons.flame,
          label: 'Maior Sequencia',
          value: '${_currentStats['streak']} dias',
          color: AppColors.warning,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.foregroundDark
                      : AppColors.foreground,
                ),
              ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildWeightProgressSection(bool isDark) {
    final weightChange = _currentStats['weight_change'] as double;
    final isLoss = weightChange < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isLoss ? AppColors.success : AppColors.destructive).withAlpha(isDark ? 40 : 25),
            (isLoss ? AppColors.success : AppColors.destructive).withAlpha(isDark ? 20 : 10),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isLoss ? AppColors.success : AppColors.destructive).withAlpha(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isLoss ? AppColors.success : AppColors.destructive).withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isLoss ? LucideIcons.trendingDown : LucideIcons.trendingUp,
                  size: 24,
                  color: isLoss ? AppColors.success : AppColors.destructive,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Variacao de Peso',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                    Text(
                      '${weightChange > 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isLoss ? AppColors.success : AppColors.destructive,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildWeightStatItem(
                  'Peso Medio',
                  '${_currentStats['avg_weight']} kg',
                  isDark,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              Expanded(
                child: _buildWeightStatItem(
                  'Progresso Meta',
                  '${_currentStats['goal_progress']}%',
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
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

  Widget _buildMeasurementChangesSection(bool isDark) {
    final measurementLabels = {
      'chest': 'Peito',
      'waist': 'Cintura',
      'hips': 'Quadril',
      'biceps': 'Biceps',
      'thigh': 'Coxa',
      'calf': 'Panturrilha',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variacao de Medidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardDark.withAlpha(150)
                : AppColors.card.withAlpha(200),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Column(
            children: _measurementChanges.entries.map((entry) {
              final change = entry.value;
              final isLoss = change < 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        measurementLabels[entry.key]!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (change.abs() / 5).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: isDark
                              ? AppColors.mutedDark
                              : AppColors.muted,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isLoss ? AppColors.success : AppColors.info,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (isLoss ? AppColors.success : AppColors.info)
                            .withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} cm',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isLoss ? AppColors.success : AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityOverview(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo de Atividade',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardDark.withAlpha(150)
                : AppColors.card.withAlpha(200),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              _buildActivityRow(
                LucideIcons.calendar,
                'Melhor dia',
                _currentStats['best_day'] as String,
                isDark,
              ),
              const Divider(height: 24),
              _buildActivityRow(
                LucideIcons.target,
                'Taxa de registro',
                '${((_currentStats['weight_logs'] as int) / int.parse(_selectedPeriod) * 100).toInt()}%',
                isDark,
              ),
              const Divider(height: 24),
              _buildActivityRow(
                LucideIcons.trophy,
                'Consistencia',
                _currentStats['streak'] as int > 7
                    ? 'Excelente'
                    : (_currentStats['streak'] as int > 3 ? 'Boa' : 'Precisa melhorar'),
                isDark,
                badge: _currentStats['streak'] as int > 7,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityRow(
    IconData icon,
    String label,
    String value,
    bool isDark, {
    bool badge = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.primaryDark : AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        const Spacer(),
        if (badge)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              LucideIcons.star,
              size: 14,
              color: AppColors.warning,
            ),
          ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
      ],
    );
  }
}
