import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../providers/nutrition_provider.dart';

class NutritionPage extends ConsumerStatefulWidget {
  const NutritionPage({super.key});

  @override
  ConsumerState<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends ConsumerState<NutritionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _selectedDay = 3; // Thursday (0=Monday)

  final _weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];

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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nutricao',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _showDatePicker(context, isDark);
                              },
                              child: Container(
                                width: 44,
                                height: 44,
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
                                child: Icon(
                                  LucideIcons.calendar,
                                  size: 20,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foreground,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _showAddMealOptions(context, isDark);
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  LucideIcons.plus,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Day selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _weekDays.asMap().entries.map((entry) {
                        final isSelected = entry.key == _selectedDay;
                        final isToday = entry.key == 3;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedDay = entry.key);
                          },
                          child: Container(
                            width: 44,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                                    : (isDark ? AppColors.borderDark : AppColors.border),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? (isDark ? AppColors.backgroundDark : AppColors.background)
                                        : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${10 + entry.key}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? (isDark ? AppColors.backgroundDark : AppColors.background)
                                        : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                                  ),
                                ),
                                if (isToday) ...[
                                  const SizedBox(height: 2),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDark ? AppColors.backgroundDark : AppColors.background)
                                          : AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Macros summary
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _MacrosSummary(isDark: isDark),
                  ),

                  const SizedBox(height: 24),

                  // Meals
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Refeicoes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Meals list from API
                  _MealsList(isDark: isDark),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context, bool isDark) async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDark ? AppColors.cardDark : AppColors.background,
              onSurface: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data selecionada: ${picked.day}/${picked.month}/${picked.year}'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _showAddMealOptions(BuildContext context, bool isDark) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar Refeicao',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 20),
              _buildMealOption(
                ctx,
                isDark,
                LucideIcons.search,
                'Buscar Alimento',
                'Pesquise na base de dados',
                AppColors.primary,
                () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                  context.push('/nutrition/search');
                },
              ),
              const SizedBox(height: 12),
              _buildMealOption(
                ctx,
                isDark,
                LucideIcons.scanLine,
                'Escanear Codigo de Barras',
                'Adicione produto rapidamente',
                AppColors.secondary,
                () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                  context.push('/nutrition/barcode');
                },
              ),
              const SizedBox(height: 12),
              _buildMealOption(
                ctx,
                isDark,
                LucideIcons.clock,
                'Refeicoes Recentes',
                'Repita uma refeicao anterior',
                AppColors.accent,
                () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                  context.push('/nutrition/recent');
                },
              ),
              const SizedBox(height: 12),
              _buildMealOption(
                ctx,
                isDark,
                LucideIcons.sparkles,
                'Sugestao com IA',
                'Deixe a IA sugerir uma refeicao',
                AppColors.info,
                () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                  context.push('/nutrition/ai-suggestion');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealOption(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.mutedDark.withAlpha(150)
              : AppColors.muted.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: color),
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
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacrosSummary extends StatelessWidget {
  final bool isDark;

  const _MacrosSummary({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          // Calories progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calorias',
                      style: TextStyle(
                        fontSize: 13,
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
                          '1,420',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '/ 1,800 kcal',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Circular progress
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: 0.79,
                        strokeWidth: 6,
                        backgroundColor: isDark
                            ? AppColors.borderDark
                            : AppColors.border,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    Center(
                      child: Text(
                        '79%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Macros row
          Row(
            children: [
              _MacroProgress(
                label: 'Proteina',
                current: 98,
                target: 150,
                color: AppColors.primary,
                isDark: isDark,
              ),
              const SizedBox(width: 16),
              _MacroProgress(
                label: 'Carbs',
                current: 145,
                target: 180,
                color: AppColors.secondary,
                isDark: isDark,
              ),
              const SizedBox(width: 16),
              _MacroProgress(
                label: 'Gordura',
                current: 42,
                target: 60,
                color: AppColors.accent,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroProgress extends StatelessWidget {
  final String label;
  final int current;
  final int target;
  final Color color;
  final bool isDark;

  const _MacroProgress({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = current / target;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
              Text(
                '${current}g',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final bool isDark;

  const _MealCard({required this.meal, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
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
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (meal['color'] as Color).withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      meal['icon'] as IconData,
                      size: 20,
                      color: meal['color'] as Color,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal['name'],
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
                          meal['time'],
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

                  // Calories
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${meal['calories']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      Text(
                        'kcal',
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

            // Foods list
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.mutedDark.withAlpha(50)
                    : AppColors.muted.withAlpha(100),
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                children: (meal['foods'] as List<String>).map((food) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: (meal['foods'] as List<String>).indexOf(food) <
                              (meal['foods'] as List<String>).length - 1
                          ? 8
                          : 0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          food,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Meals List Widget (uses API)
class _MealsList extends ConsumerWidget {
  final bool isDark;

  const _MealsList({required this.isDark});

  IconData _getMealIcon(String? mealType) {
    switch (mealType?.toLowerCase()) {
      case 'breakfast':
      case 'cafe_da_manha':
        return LucideIcons.coffee;
      case 'morning_snack':
      case 'lanche_da_manha':
        return LucideIcons.apple;
      case 'lunch':
      case 'almoco':
        return LucideIcons.utensils;
      case 'afternoon_snack':
      case 'lanche_da_tarde':
        return LucideIcons.cookie;
      case 'dinner':
      case 'jantar':
        return LucideIcons.moon;
      default:
        return LucideIcons.utensils;
    }
  }

  Color _getMealColor(String? mealType) {
    switch (mealType?.toLowerCase()) {
      case 'breakfast':
      case 'cafe_da_manha':
        return AppColors.warning;
      case 'morning_snack':
      case 'lanche_da_manha':
        return AppColors.success;
      case 'lunch':
      case 'almoco':
        return AppColors.primary;
      case 'afternoon_snack':
      case 'lanche_da_tarde':
        return AppColors.accent;
      case 'dinner':
      case 'jantar':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  String _getMealName(String? mealType) {
    switch (mealType?.toLowerCase()) {
      case 'breakfast':
      case 'cafe_da_manha':
        return 'Café da Manhã';
      case 'morning_snack':
      case 'lanche_da_manha':
        return 'Lanche da Manhã';
      case 'lunch':
      case 'almoco':
        return 'Almoço';
      case 'afternoon_snack':
      case 'lanche_da_tarde':
        return 'Lanche da Tarde';
      case 'dinner':
      case 'jantar':
        return 'Jantar';
      default:
        return mealType ?? 'Refeição';
    }
  }

  String _formatTime(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('HH:mm').format(date);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsState = ref.watch(mealLogsNotifierProvider);

    if (mealsState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (mealsState.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.destructive.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.alertCircle, color: AppColors.destructive),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mealsState.error!,
                  style: TextStyle(color: AppColors.destructive),
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(mealLogsNotifierProvider.notifier).refresh(),
                child: Icon(LucideIcons.refreshCw, color: AppColors.destructive),
              ),
            ],
          ),
        ),
      );
    }

    if (mealsState.logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
            children: [
              Icon(
                LucideIcons.utensils,
                size: 48,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma refeição registrada',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Adicione sua primeira refeição',
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

    // Group meals by type
    final mealsByType = <String, List<Map<String, dynamic>>>{};
    for (final log in mealsState.logs) {
      final type = log['meal_type'] as String? ?? 'other';
      mealsByType.putIfAbsent(type, () => []).add(log);
    }

    // Sort meal types by time of day
    final mealOrder = ['breakfast', 'cafe_da_manha', 'morning_snack', 'lanche_da_manha',
                       'lunch', 'almoco', 'afternoon_snack', 'lanche_da_tarde',
                       'dinner', 'jantar'];

    final sortedTypes = mealsByType.keys.toList()
      ..sort((a, b) {
        final aIndex = mealOrder.indexOf(a.toLowerCase());
        final bIndex = mealOrder.indexOf(b.toLowerCase());
        if (aIndex == -1 && bIndex == -1) return a.compareTo(b);
        if (aIndex == -1) return 1;
        if (bIndex == -1) return -1;
        return aIndex.compareTo(bIndex);
      });

    return Column(
      children: sortedTypes.map((mealType) {
        final logs = mealsByType[mealType]!;
        final totalCalories = logs.fold<int>(0, (sum, log) =>
          sum + ((log['calories'] as num?)?.toInt() ?? 0));
        final foods = logs.map((log) =>
          log['food_name'] as String? ?? 'Alimento').toList();
        final latestTime = logs.isNotEmpty
          ? _formatTime(logs.first['logged_at'] as String?)
          : '';

        final meal = {
          'name': _getMealName(mealType),
          'time': latestTime,
          'calories': totalCalories,
          'icon': _getMealIcon(mealType),
          'color': _getMealColor(mealType),
          'foods': foods,
        };
        return _MealCard(meal: meal, isDark: isDark);
      }).toList(),
    );
  }
}
