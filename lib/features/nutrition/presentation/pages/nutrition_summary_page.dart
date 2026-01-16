import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';

/// Nutrition Summary Page - Weekly/Monthly overview
class NutritionSummaryPage extends ConsumerStatefulWidget {
  const NutritionSummaryPage({super.key});

  @override
  ConsumerState<NutritionSummaryPage> createState() => _NutritionSummaryPageState();
}

class _NutritionSummaryPageState extends ConsumerState<NutritionSummaryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  String _selectedPeriod = 'week';

  // Mock weekly data
  final _weeklyData = [
    {'day': 'Seg', 'date': '13', 'calories': 1850, 'target': 2000, 'protein': 145, 'carbs': 180, 'fat': 65, 'logged': true},
    {'day': 'Ter', 'date': '14', 'calories': 2100, 'target': 2000, 'protein': 160, 'carbs': 200, 'fat': 75, 'logged': true},
    {'day': 'Qua', 'date': '15', 'calories': 1750, 'target': 2000, 'protein': 130, 'carbs': 170, 'fat': 60, 'logged': true},
    {'day': 'Qui', 'date': '16', 'calories': 1950, 'target': 2000, 'protein': 150, 'carbs': 190, 'fat': 70, 'logged': true},
    {'day': 'Sex', 'date': '17', 'calories': 2200, 'target': 2000, 'protein': 165, 'carbs': 210, 'fat': 80, 'logged': true},
    {'day': 'Sab', 'date': '18', 'calories': 0, 'target': 2000, 'protein': 0, 'carbs': 0, 'fat': 0, 'logged': false},
    {'day': 'Dom', 'date': '19', 'calories': 0, 'target': 2000, 'protein': 0, 'carbs': 0, 'fat': 0, 'logged': false},
  ];

  final _targets = {
    'calories': 2000,
    'protein': 150,
    'carbs': 200,
    'fat': 70,
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

  Map<String, int> get _weeklyTotals {
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;
    int loggedDays = 0;

    for (final day in _weeklyData) {
      if (day['logged'] as bool) {
        totalCalories += day['calories'] as int;
        totalProtein += day['protein'] as int;
        totalCarbs += day['carbs'] as int;
        totalFat += day['fat'] as int;
        loggedDays++;
      }
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
      'loggedDays': loggedDays,
      'avgCalories': loggedDays > 0 ? totalCalories ~/ loggedDays : 0,
      'avgProtein': loggedDays > 0 ? totalProtein ~/ loggedDays : 0,
      'avgCarbs': loggedDays > 0 ? totalCarbs ~/ loggedDays : 0,
      'avgFat': loggedDays > 0 ? totalFat ~/ loggedDays : 0,
    };
  }

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
                _buildHeader(isDark, theme),

                // Period selector
                _buildPeriodSelector(isDark),

                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary card
                        _buildSummaryCard(isDark),

                        const SizedBox(height: 20),

                        // Daily breakdown
                        _buildDailyBreakdown(isDark),

                        const SizedBox(height: 20),

                        // Macro averages
                        _buildMacroAverages(isDark),

                        const SizedBox(height: 20),

                        // Insights
                        _buildInsights(isDark),

                        const SizedBox(height: 24),
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

  Widget _buildHeader(bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? AppColors.cardDark : AppColors.card,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Icon(
                LucideIcons.arrowLeft,
                size: 18,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Resumo Nutricional',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exportando relatorio...')),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? AppColors.cardDark : AppColors.card,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Icon(
                LucideIcons.download,
                size: 18,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildPeriodTab('week', 'Semana', isDark),
            _buildPeriodTab('month', 'Mes', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String value, String label, bool isDark) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedPeriod = value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.primaryDark : AppColors.primary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    final totals = _weeklyTotals;
    final targetCalories = _targets['calories']! * 7;
    final actualCalories = totals['calories']!;
    final percentage = targetCalories > 0
        ? ((actualCalories / targetCalories) * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withAlpha(isDark ? 40 : 25),
            AppColors.secondary.withAlpha(isDark ? 30 : 15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Semanal',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$actualCalories',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5, left: 4),
                          child: Text(
                            'kcal',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'de $targetCalories kcal planejados',
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
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: (percentage / 100).clamp(0.0, 1.0),
                      strokeWidth: 8,
                      backgroundColor: isDark
                          ? AppColors.mutedDark
                          : AppColors.muted,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage >= 90 && percentage <= 110
                            ? AppColors.success
                            : (percentage < 90
                                ? AppColors.warning
                                : AppColors.destructive),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      Text(
                        'da meta',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardDark.withAlpha(150)
                  : Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('${totals['loggedDays']}/7', 'Dias', LucideIcons.calendar, isDark),
                _buildMiniStat('${totals['avgCalories']}', 'Media/dia', LucideIcons.flame, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.primaryDark : AppColors.primary,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
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
        ),
      ],
    );
  }

  Widget _buildDailyBreakdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalhamento Diario',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardDark.withAlpha(150)
                : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Column(
            children: List.generate(_weeklyData.length, (index) {
              final day = _weeklyData[index];
              final isLast = index == _weeklyData.length - 1;
              return _buildDayRow(day, isDark, isLast);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDayRow(Map<String, dynamic> day, bool isDark, bool isLast) {
    final logged = day['logged'] as bool;
    final calories = day['calories'] as int;
    final target = day['target'] as int;
    final percentage = target > 0 ? (calories / target * 100).round() : 0;

    Color statusColor;
    if (!logged) {
      statusColor = isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground;
    } else if (percentage >= 90 && percentage <= 110) {
      statusColor = AppColors.success;
    } else if (percentage < 90) {
      statusColor = AppColors.warning;
    } else {
      statusColor = AppColors.destructive;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          SizedBox(
            width: 35,
            child: Column(
              children: [
                Text(
                  day['day'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Text(
                  day['date'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      logged ? '$calories kcal' : 'Nao registrado',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: logged
                            ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                            : (isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground),
                      ),
                    ),
                    if (logged) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (logged)
                  const SizedBox(height: 4),
                if (logged)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (percentage / 100).clamp(0.0, 1.5),
                      minHeight: 4,
                      backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
              ],
            ),
          ),
          if (logged)
            Row(
              children: [
                _buildMicroMacro('P', day['protein'] as int, isDark),
                _buildMicroMacro('C', day['carbs'] as int, isDark),
                _buildMicroMacro('G', day['fat'] as int, isDark),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMicroMacro(String label, int value, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroAverages(bool isDark) {
    final totals = _weeklyTotals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media de Macros',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMacroCard(
                'Proteina',
                totals['avgProtein']!,
                _targets['protein']!,
                'g',
                AppColors.destructive,
                isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMacroCard(
                'Carboidratos',
                totals['avgCarbs']!,
                _targets['carbs']!,
                'g',
                AppColors.info,
                isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMacroCard(
                'Gorduras',
                totals['avgFat']!,
                _targets['fat']!,
                'g',
                AppColors.warning,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroCard(String label, int value, int target, String unit, Color color, bool isDark) {
    final percentage = target > 0 ? (value / target * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            '$value$unit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            'de $target$unit',
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(bool isDark) {
    final totals = _weeklyTotals;
    final avgCalories = totals['avgCalories']!;
    final targetCalories = _targets['calories']!;

    final insights = <Map<String, dynamic>>[];

    if (avgCalories < targetCalories * 0.9) {
      insights.add({
        'icon': LucideIcons.alertTriangle,
        'color': AppColors.warning,
        'title': 'Consumo abaixo da meta',
        'text': 'Sua media de calorias esta ${((1 - avgCalories / targetCalories) * 100).round()}% abaixo do planejado.',
      });
    } else if (avgCalories > targetCalories * 1.1) {
      insights.add({
        'icon': LucideIcons.alertCircle,
        'color': AppColors.destructive,
        'title': 'Consumo acima da meta',
        'text': 'Sua media de calorias esta ${((avgCalories / targetCalories - 1) * 100).round()}% acima do planejado.',
      });
    } else {
      insights.add({
        'icon': LucideIcons.checkCircle2,
        'color': AppColors.success,
        'title': 'Otimo trabalho!',
        'text': 'Voce esta mantendo uma media de calorias dentro da meta.',
      });
    }

    if (totals['loggedDays']! < 5) {
      insights.add({
        'icon': LucideIcons.calendar,
        'color': AppColors.info,
        'title': 'Continue registrando',
        'text': 'Tente registrar suas refeicoes todos os dias para melhor acompanhamento.',
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (insight['color'] as Color).withAlpha(isDark ? 20 : 10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (insight['color'] as Color).withAlpha(40),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                insight['icon'] as IconData,
                size: 20,
                color: insight['color'] as Color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      insight['text'] as String,
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
            ],
          ),
        )),
      ],
    );
  }
}
