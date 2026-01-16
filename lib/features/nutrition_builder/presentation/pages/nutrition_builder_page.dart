import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';

/// Nutrition Plan Builder page for trainers and nutritionists
class NutritionBuilderPage extends ConsumerStatefulWidget {
  final String? planId; // null = new plan
  final String? studentId; // optional - assign to specific student

  const NutritionBuilderPage({super.key, this.planId, this.studentId});

  @override
  ConsumerState<NutritionBuilderPage> createState() =>
      _NutritionBuilderPageState();
}

class _NutritionBuilderPageState extends ConsumerState<NutritionBuilderPage> {
  final _nameController =
      TextEditingController(text: 'Plano de Emagrecimento');
  final _descriptionController = TextEditingController(
    text: 'Plano alimentar focado em deficit calorico com alta proteina.',
  );

  // Macro targets
  int _calorieTarget = 1800;
  int _proteinTarget = 150;
  int _carbsTarget = 180;
  int _fatTarget = 60;

  // Mock meals in plan
  final List<_MealPlan> _meals = [
    _MealPlan(
      id: '1',
      name: 'Cafe da Manha',
      time: '07:00',
      foods: [
        _FoodItem(name: '2 ovos mexidos', calories: 180, protein: 14, carbs: 2, fat: 12),
        _FoodItem(name: '2 fatias pao integral', calories: 140, protein: 6, carbs: 24, fat: 2),
        _FoodItem(name: '1 banana', calories: 90, protein: 1, carbs: 23, fat: 0),
      ],
    ),
    _MealPlan(
      id: '2',
      name: 'Lanche da Manha',
      time: '10:00',
      foods: [
        _FoodItem(name: 'Iogurte grego', calories: 100, protein: 17, carbs: 6, fat: 0),
        _FoodItem(name: '30g granola', calories: 80, protein: 2, carbs: 14, fat: 2),
      ],
    ),
    _MealPlan(
      id: '3',
      name: 'Almoco',
      time: '12:30',
      foods: [
        _FoodItem(name: '150g frango grelhado', calories: 240, protein: 45, carbs: 0, fat: 5),
        _FoodItem(name: '100g arroz integral', calories: 130, protein: 3, carbs: 28, fat: 1),
        _FoodItem(name: 'Salada verde', calories: 25, protein: 1, carbs: 5, fat: 0),
        _FoodItem(name: 'Brocolis', calories: 35, protein: 3, carbs: 7, fat: 0),
      ],
    ),
    _MealPlan(
      id: '4',
      name: 'Lanche da Tarde',
      time: '15:30',
      foods: [
        _FoodItem(name: '1 scoop whey', calories: 120, protein: 24, carbs: 3, fat: 2),
        _FoodItem(name: '1 banana', calories: 90, protein: 1, carbs: 23, fat: 0),
      ],
    ),
    _MealPlan(
      id: '5',
      name: 'Jantar',
      time: '19:00',
      foods: [
        _FoodItem(name: '150g salmao', calories: 280, protein: 30, carbs: 0, fat: 16),
        _FoodItem(name: 'Batata doce 150g', calories: 130, protein: 2, carbs: 30, fat: 0),
        _FoodItem(name: 'Legumes grelhados', calories: 60, protein: 2, carbs: 12, fat: 1),
      ],
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  int get _totalCalories =>
      _meals.fold(0, (sum, meal) => sum + meal.totalCalories);
  int get _totalProtein =>
      _meals.fold(0, (sum, meal) => sum + meal.totalProtein);
  int get _totalCarbs => _meals.fold(0, (sum, meal) => sum + meal.totalCarbs);
  int get _totalFat => _meals.fold(0, (sum, meal) => sum + meal.totalFat);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.planId != null;

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
        child: Column(
          children: [
            // Custom AppBar
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
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
                        child: Icon(
                          LucideIcons.arrowLeft,
                          size: 20,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        isEditing ? 'Editar Plano' : 'Novo Plano Alimentar',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showPreview(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            Icon(LucideIcons.eye, size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Preview',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan Info Section
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: _buildInfoSection(theme, isDark),
                    ),

                    const SizedBox(height: 24),

                    // Macro Targets
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: _buildMacroTargets(theme, isDark),
                    ),

                    const SizedBox(height: 24),

                    // Current Totals
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: _buildCurrentTotals(theme, isDark),
                    ),

                    const SizedBox(height: 24),

                    // Meals Section
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildMealsHeader(theme, isDark),
                    ),

                    const SizedBox(height: 12),

                    // Meals List
                    ...List.generate(_meals.length, (index) {
                      return FadeInUp(
                        key: ValueKey(_meals[index].id),
                        delay: Duration(milliseconds: 500 + (index * 50)),
                        child: _buildMealCard(theme, isDark, _meals[index], index),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Add Meal Button
                    FadeInUp(
                      delay: const Duration(milliseconds: 700),
                      child: _buildAddMealButton(theme, isDark),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardDark.withAlpha(150)
                : AppColors.card.withAlpha(200),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _savePlan();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.save, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          isEditing ? 'Salvar Alteracoes' : 'Criar Plano',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
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
              Icon(LucideIcons.utensils, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Informacoes do Plano',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome do Plano',
              hintText: 'Ex: Plano de Emagrecimento',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Descricao (opcional)',
              hintText: 'Descreva o objetivo do plano...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          if (widget.studentId != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.user, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Plano para: Maria Silva',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroTargets(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
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
              Icon(LucideIcons.target, size: 20, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                'Metas Diarias',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMacroInput(
                  theme,
                  isDark,
                  'Calorias',
                  _calorieTarget,
                  'kcal',
                  AppColors.primary,
                  (value) => setState(() => _calorieTarget = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroInput(
                  theme,
                  isDark,
                  'Proteina',
                  _proteinTarget,
                  'g',
                  AppColors.destructive,
                  (value) => setState(() => _proteinTarget = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMacroInput(
                  theme,
                  isDark,
                  'Carboidratos',
                  _carbsTarget,
                  'g',
                  AppColors.secondary,
                  (value) => setState(() => _carbsTarget = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroInput(
                  theme,
                  isDark,
                  'Gordura',
                  _fatTarget,
                  'g',
                  AppColors.accent,
                  (value) => setState(() => _fatTarget = value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInput(
    ThemeData theme,
    bool isDark,
    String label,
    int value,
    String unit,
    Color color,
    Function(int) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$value $unit',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onChanged(value + (label == 'Calorias' ? 50 : 5));
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(LucideIcons.plus, size: 14, color: color),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onChanged(value - (label == 'Calorias' ? 50 : 5));
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(LucideIcons.minus, size: 14, color: color),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTotals(ThemeData theme, bool isDark) {
    final caloriePercent = (_totalCalories / _calorieTarget * 100).clamp(0, 150).toDouble();
    final proteinPercent = (_totalProtein / _proteinTarget * 100).clamp(0, 150).toDouble();
    final carbsPercent = (_totalCarbs / _carbsTarget * 100).clamp(0, 150).toDouble();
    final fatPercent = (_totalFat / _fatTarget * 100).clamp(0, 150).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
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
              Icon(LucideIcons.pieChart, size: 20, color: AppColors.success),
              const SizedBox(width: 8),
              Text(
                'Totais Atuais',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTotalRow(
            theme,
            isDark,
            'Calorias',
            _totalCalories,
            _calorieTarget,
            'kcal',
            AppColors.primary,
            caloriePercent,
          ),
          const SizedBox(height: 12),
          _buildTotalRow(
            theme,
            isDark,
            'Proteina',
            _totalProtein,
            _proteinTarget,
            'g',
            AppColors.destructive,
            proteinPercent,
          ),
          const SizedBox(height: 12),
          _buildTotalRow(
            theme,
            isDark,
            'Carbs',
            _totalCarbs,
            _carbsTarget,
            'g',
            AppColors.secondary,
            carbsPercent,
          ),
          const SizedBox(height: 12),
          _buildTotalRow(
            theme,
            isDark,
            'Gordura',
            _totalFat,
            _fatTarget,
            'g',
            AppColors.accent,
            fatPercent,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    ThemeData theme,
    bool isDark,
    String label,
    int current,
    int target,
    String unit,
    Color color,
    double percent,
  ) {
    final isOver = current > target;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  '$current',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isOver ? AppColors.destructive : color,
                  ),
                ),
                Text(
                  ' / $target $unit',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isOver) ...[
                  const SizedBox(width: 4),
                  Icon(LucideIcons.alertTriangle,
                      size: 14, color: AppColors.destructive),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (percent / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: isOver ? AppColors.destructive : color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealsHeader(ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Refeicoes (${_meals.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showFoodLibrary(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                Icon(LucideIcons.library, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Biblioteca',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(ThemeData theme, bool isDark, _MealPlan meal, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getMealIcon(index),
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
                        meal.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        meal.time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${meal.totalCalories} kcal',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _editMeal(meal);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.mutedDark.withAlpha(100)
                          : AppColors.muted.withAlpha(150),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.pencil, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _removeMeal(meal);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.destructive.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.trash2,
                        size: 18, color: AppColors.destructive),
                  ),
                ),
              ],
            ),
          ),
          // Foods
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: meal.foods.map((food) {
                return Container(
                  margin: EdgeInsets.only(
                    bottom: meal.foods.indexOf(food) < meal.foods.length - 1
                        ? 8
                        : 0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          food.name,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '${food.calories} kcal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          // Add food button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _addFoodToMeal(meal);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.plus,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Adicionar alimento',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(int index) {
    final icons = [
      LucideIcons.coffee,
      LucideIcons.apple,
      LucideIcons.utensils,
      LucideIcons.cookie,
      LucideIcons.moon,
      LucideIcons.star,
    ];
    return icons[index % icons.length];
  }

  Widget _buildAddMealButton(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showAddMealSheet(context);
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.plus, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Adicionar Refeicao',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreview(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preview do plano alimentar')),
    );
  }

  void _showFoodLibrary(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FoodLibrarySheet(),
    );
  }

  void _editMeal(_MealPlan meal) {
    // Edit meal
  }

  void _removeMeal(_MealPlan meal) {
    HapticFeedback.mediumImpact();
    setState(() {
      _meals.removeWhere((m) => m.id == meal.id);
    });
  }

  void _addFoodToMeal(_MealPlan meal) {
    _showFoodLibrary(context);
  }

  void _showAddMealSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final nameController = TextEditingController();
    final timeController = TextEditingController(text: '12:00');

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Nova Refeicao',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nome da Refeicao',
                  hintText: 'Ex: Cafe da Manha',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Horario',
                  hintText: 'Ex: 07:00',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    if (nameController.text.isNotEmpty) {
                      setState(() {
                        _meals.add(_MealPlan(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          time: timeController.text,
                          foods: [],
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Adicionar Refeicao',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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

  void _savePlan() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plano alimentar salvo com sucesso!')),
    );
    Navigator.pop(context);
  }
}

class _MealPlan {
  final String id;
  final String name;
  final String time;
  final List<_FoodItem> foods;

  _MealPlan({
    required this.id,
    required this.name,
    required this.time,
    required this.foods,
  });

  int get totalCalories => foods.fold(0, (sum, food) => sum + food.calories);
  int get totalProtein => foods.fold(0, (sum, food) => sum + food.protein);
  int get totalCarbs => foods.fold(0, (sum, food) => sum + food.carbs);
  int get totalFat => foods.fold(0, (sum, food) => sum + food.fat);
}

class _FoodItem {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  _FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class _FoodLibrarySheet extends StatelessWidget {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Proteinas', 'icon': LucideIcons.beef, 'count': 48},
    {'name': 'Carboidratos', 'icon': LucideIcons.wheat, 'count': 35},
    {'name': 'Vegetais', 'icon': LucideIcons.leaf, 'count': 42},
    {'name': 'Frutas', 'icon': LucideIcons.apple, 'count': 38},
    {'name': 'Laticinios', 'icon': LucideIcons.milk, 'count': 22},
    {'name': 'Suplementos', 'icon': LucideIcons.pill, 'count': 15},
    {'name': 'Bebidas', 'icon': LucideIcons.glassWater, 'count': 28},
    {'name': 'Gorduras', 'icon': LucideIcons.droplets, 'count': 18},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Biblioteca de Alimentos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.mutedDark.withAlpha(100)
                          : AppColors.muted.withAlpha(150),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.x),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar alimento...',
                prefixIcon: Icon(LucideIcons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDark.withAlpha(150)
                          : AppColors.card.withAlpha(200),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          color: AppColors.primary,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['name'] as String,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${category['count']} alimentos',
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
            ),
          ),
        ],
      ),
    );
  }
}
