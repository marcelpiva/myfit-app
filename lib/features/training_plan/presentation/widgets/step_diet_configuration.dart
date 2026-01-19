import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/haptic_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../providers/plan_wizard_provider.dart';

/// Step 5: Diet configuration (optional)
class StepDietConfiguration extends ConsumerStatefulWidget {
  const StepDietConfiguration({super.key});

  @override
  ConsumerState<StepDietConfiguration> createState() => _StepDietConfigurationState();
}

class _StepDietConfigurationState extends ConsumerState<StepDietConfiguration> {
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(planWizardProvider);
    _caloriesController.text = state.dailyCalories?.toString() ?? '';
    _proteinController.text = state.proteinGrams?.toString() ?? '';
    _carbsController.text = state.carbsGrams?.toString() ?? '';
    _fatController.text = state.fatGrams?.toString() ?? '';
    _notesController.text = state.dietNotes ?? '';
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planWizardProvider);
    final notifier = ref.read(planWizardProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dieta do Plano',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Configure um plano alimentar para complementar o treino (opcional)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Toggle to include diet
          _buildIncludeDietToggle(theme, isDark, state, notifier),
          const SizedBox(height: 24),

          // Diet form (only shown if includeDiet is true)
          if (state.includeDiet) ...[
            // Diet Type Selection
            _buildSection(
              theme,
              isDark,
              'Tipo de Dieta',
              _buildDietTypeSelection(theme, isDark, state, notifier),
            ),
            const SizedBox(height: 24),

            // Daily Calories
            _buildSection(
              theme,
              isDark,
              'Calorias Diárias',
              _buildCaloriesField(theme, notifier),
            ),
            const SizedBox(height: 24),

            // Macros
            _buildSection(
              theme,
              isDark,
              'Distribuição de Macros',
              _buildMacrosRow(theme, notifier),
            ),
            const SizedBox(height: 16),
            _buildMacrosSummary(theme, isDark, state),
            const SizedBox(height: 24),

            // Meals per day
            _buildSection(
              theme,
              isDark,
              'Refeições por Dia',
              _buildMealsPerDaySelection(theme, isDark, state, notifier),
            ),
            const SizedBox(height: 24),

            // Diet Notes
            _buildSection(
              theme,
              isDark,
              'Observações da Dieta (opcional)',
              _buildNotesField(theme, notifier),
            ),
          ],

          const SizedBox(height: 100),
        ],
        ),
      ),
    );
  }

  Widget _buildIncludeDietToggle(
    ThemeData theme,
    bool isDark,
    PlanWizardState state,
    PlanWizardNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: state.includeDiet
            ? AppColors.primary.withAlpha(20)
            : (isDark
                ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                : theme.colorScheme.surfaceContainerLow.withAlpha(200)),
        border: Border.all(
          color: state.includeDiet
              ? AppColors.primary
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            state.includeDiet ? LucideIcons.checkCircle : LucideIcons.utensils,
            color: state.includeDiet
                ? AppColors.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Incluir plano alimentar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: state.includeDiet ? AppColors.primary : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.includeDiet
                      ? 'Você pode configurar a dieta abaixo'
                      : 'Ative para adicionar orientações nutricionais',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: state.includeDiet,
            onChanged: (value) {
              HapticUtils.selectionClick();
              notifier.setIncludeDiet(value);
            },
            activeTrackColor: AppColors.primary.withAlpha(150),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDietTypeSelection(
    ThemeData theme,
    bool isDark,
    PlanWizardState state,
    PlanWizardNotifier notifier,
  ) {
    final dietTypes = DietType.values;

    return Column(
      children: dietTypes.map((type) {
        final isSelected = state.dietType == type;
        return Padding(
          padding: EdgeInsets.only(bottom: type != dietTypes.last ? 8 : 0),
          child: GestureDetector(
            onTap: () {
              HapticUtils.selectionClick();
              notifier.setDietType(type);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(20)
                    : (isDark
                        ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                        : theme.colorScheme.surfaceContainerLow.withAlpha(200)),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getDietTypeIcon(type),
                    color: isSelected
                        ? AppColors.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.primary : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          type.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      LucideIcons.checkCircle2,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getDietTypeIcon(DietType type) {
    switch (type) {
      case DietType.cutting:
        return LucideIcons.trendingDown;
      case DietType.bulking:
        return LucideIcons.trendingUp;
      case DietType.maintenance:
        return LucideIcons.minus;
    }
  }

  Widget _buildCaloriesField(ThemeData theme, PlanWizardNotifier notifier) {
    return TextFormField(
      controller: _caloriesController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        final calories = int.tryParse(value);
        notifier.setDailyCalories(calories);
      },
      decoration: InputDecoration(
        hintText: 'Ex: 2500',
        suffixText: 'kcal',
        prefixIcon: const Icon(LucideIcons.flame),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildMacrosRow(ThemeData theme, PlanWizardNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Proteína (g)',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _proteinController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  notifier.setProteinGrams(int.tryParse(value));
                },
                decoration: InputDecoration(
                  hintText: '150',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              Text(
                'Carboidratos (g)',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _carbsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  notifier.setCarbsGrams(int.tryParse(value));
                },
                decoration: InputDecoration(
                  hintText: '300',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              Text(
                'Gordura (g)',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fatController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  notifier.setFatGrams(int.tryParse(value));
                },
                decoration: InputDecoration(
                  hintText: '80',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacrosSummary(ThemeData theme, bool isDark, PlanWizardState state) {
    final protein = state.proteinGrams ?? 0;
    final carbs = state.carbsGrams ?? 0;
    final fat = state.fatGrams ?? 0;
    final calculatedCalories = state.calculatedCalories;
    final targetCalories = state.dailyCalories;
    final isValid = state.isCalorieMatchValid;

    if (protein == 0 && carbs == 0 && fat == 0) return const SizedBox.shrink();

    return Column(
      children: [
        // Calculated calories summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                : theme.colorScheme.surfaceContainerLow.withAlpha(200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.calculator,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total calculado:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Text(
                '$calculatedCalories kcal',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isValid ? AppColors.primary : AppColors.destructive,
                ),
              ),
            ],
          ),
        ),
        // Warning when calories don't match
        if (targetCalories != null && !isValid) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.destructive.withAlpha(isDark ? 30 : 20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.destructive.withAlpha(isDark ? 80 : 50),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.alertTriangle,
                  size: 20,
                  color: AppColors.destructive,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calorias não conferem',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.destructive,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Esperado: ~$targetCalories kcal\nCalculado: $calculatedCalories kcal (diferença: ${(calculatedCalories - targetCalories).abs()} kcal)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.foregroundDark.withAlpha(200)
                              : AppColors.foreground.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        // Success message when calories match
        if (targetCalories != null && isValid && calculatedCalories > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(isDark ? 30 : 20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.success.withAlpha(isDark ? 80 : 50),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.checkCircle2,
                  size: 20,
                  color: AppColors.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Calorias conferem com os macros',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMealsPerDaySelection(
    ThemeData theme,
    bool isDark,
    PlanWizardState state,
    PlanWizardNotifier notifier,
  ) {
    final mealOptions = [3, 4, 5, 6];

    return Row(
      children: mealOptions.map((meals) {
        final isSelected = state.mealsPerDay == meals;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: meals != mealOptions.last ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                HapticUtils.selectionClick();
                notifier.setMealsPerDay(meals);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                          : theme.colorScheme.surfaceContainerLow.withAlpha(200)),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      meals.toString(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'refeições',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
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

  Widget _buildNotesField(ThemeData theme, PlanWizardNotifier notifier) {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      onChanged: (value) {
        notifier.setDietNotes(value.isEmpty ? null : value);
      },
      decoration: InputDecoration(
        hintText: 'Ex: Evitar açúcar refinado, priorizar proteínas magras...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    bool isDark,
    String title,
    Widget child,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
