import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/models/training_plan.dart';
import '../providers/plan_wizard_provider.dart';

/// Step 2: Plan information input - Redesigned with modern UX/UI
class StepPlanInfo extends ConsumerStatefulWidget {
  const StepPlanInfo({super.key});

  @override
  ConsumerState<StepPlanInfo> createState() => _StepPlanInfoState();
}

class _StepPlanInfoState extends ConsumerState<StepPlanInfo>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  late AnimationController _animationController;

  String? _lastPlanName;

  @override
  void initState() {
    super.initState();
    final state = ref.read(planWizardProvider);
    _nameController.text = state.planName;
    _lastPlanName = state.planName;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _syncControllerWithState(String statePlanName) {
    // Only update controller if state changed externally (e.g., loading from edit)
    // and controller doesn't already have the same value (avoid loop)
    if (_lastPlanName != statePlanName && _nameController.text != statePlanName) {
      _nameController.text = statePlanName;
    }
    _lastPlanName = statePlanName;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planWizardProvider);
    final notifier = ref.read(planWizardProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Sync controller with state when editing an existing plan
    _syncControllerWithState(state.planName);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: FadeTransition(
          opacity: _animationController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(theme, isDark),
              const SizedBox(height: 28),

              // Plan Name Input
              _buildNameInput(theme, isDark, state, notifier),
              const SizedBox(height: 32),

              // Goal Selection
              _buildGoalSection(theme, isDark, state, notifier),
              const SizedBox(height: 32),

              // Difficulty Selection
              _buildDifficultySection(theme, isDark, state, notifier),
              const SizedBox(height: 32),

              // Duration Selection
              _buildDurationSection(theme, isDark, state, notifier),
              const SizedBox(height: 32),

              // Workout Duration Selection
              _buildWorkoutDurationSection(theme, isDark, state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withAlpha(180),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                LucideIcons.clipboardList,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações do Plano',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personalize seu plano de treino',
                    style: theme.textTheme.bodyMedium?.copyWith(
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
      ],
    );
  }

  Widget _buildNameInput(
    ThemeData theme,
    bool isDark,
    PlanWizardState state,
    PlanWizardNotifier notifier,
  ) {
    final isValid = state.planName.trim().length >= 3;
    final hasText = state.planName.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(theme, isDark, 'Nome do Plano', isRequired: true),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.primary).withAlpha(isDark ? 40 : 15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            onChanged: (value) => notifier.setPlanName(value),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: Hipertrofia ABC, Força 5x5...',
              hintStyle: TextStyle(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  LucideIcons.pencil,
                  size: 20,
                  color: _nameFocusNode.hasFocus
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground),
                ),
              ),
              suffixIcon: hasText
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isValid ? LucideIcons.checkCircle2 : LucideIcons.alertCircle,
                          key: ValueKey(isValid),
                          size: 20,
                          color: isValid ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: isDark ? AppColors.cardDark : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        if (hasText && !isValid) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                LucideIcons.info,
                size: 14,
                color: AppColors.warning,
              ),
              const SizedBox(width: 6),
              Text(
                'Mínimo de 3 caracteres',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildGoalSection(
    ThemeData theme,
    bool isDark,
    PlanWizardState state,
    PlanWizardNotifier notifier,
  ) {
    final goals = [
      _GoalOption(
        goal: WorkoutGoal.hypertrophy,
        label: 'Hipertrofia',
        description: 'Ganho de massa muscular',
        icon: LucideIcons.dumbbell,
        color: AppColors.primary,
      ),
      _GoalOption(
        goal: WorkoutGoal.strength,
        label: 'Força',
        description: 'Aumento de força máxima',
        icon: LucideIcons.zap,
        color: AppColors.warning,
      ),
      _GoalOption(
        goal: WorkoutGoal.fatLoss,
        label: 'Emagrecimento',
        description: 'Perda de gordura corporal',
        icon: LucideIcons.flame,
        color: AppColors.destructive,
      ),
      _GoalOption(
        goal: WorkoutGoal.endurance,
        label: 'Resistência',
        description: 'Condicionamento cardio',
        icon: LucideIcons.heartPulse,
        color: AppColors.success,
      ),
      _GoalOption(
        goal: WorkoutGoal.functional,
        label: 'Funcional',
        description: 'Movimentos do dia a dia',
        icon: LucideIcons.activity,
        color: AppColors.accent,
      ),
      _GoalOption(
        goal: WorkoutGoal.generalFitness,
        label: 'Geral',
        description: 'Saúde e bem-estar',
        icon: LucideIcons.sparkles,
        color: AppColors.secondary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(theme, isDark, 'Objetivo Principal'),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final item = goals[index];
            final isSelected = state.goal == item.goal;

            return _GoalCard(
              option: item,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () {
                HapticUtils.selectionClick();
                notifier.setGoal(item.goal);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDifficultySection(
    ThemeData theme,
    bool isDark,
    PlanWizardState state,
    PlanWizardNotifier notifier,
  ) {
    final difficulties = [
      _DifficultyOption(
        difficulty: PlanDifficulty.beginner,
        label: 'Iniciante',
        icon: LucideIcons.sprout,
        description: 'Começando agora',
      ),
      _DifficultyOption(
        difficulty: PlanDifficulty.intermediate,
        label: 'Intermediário',
        icon: LucideIcons.trendingUp,
        description: '6+ meses de treino',
      ),
      _DifficultyOption(
        difficulty: PlanDifficulty.advanced,
        label: 'Avançado',
        icon: LucideIcons.crown,
        description: '2+ anos de treino',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(theme, isDark, 'Nível de Experiência'),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Column(
            children: difficulties.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = state.difficulty == item.difficulty;
              final isLast = index == difficulties.length - 1;

              return _DifficultyTile(
                option: item,
                isSelected: isSelected,
                isDark: isDark,
                showDivider: !isLast,
                onTap: () {
                  HapticUtils.selectionClick();
                  notifier.setDifficulty(item.difficulty);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection(
    ThemeData theme,
    bool isDark,
    PlanWizardState state,
    PlanWizardNotifier notifier,
  ) {
    final durations = [
      (null, 'Contínuo', LucideIcons.infinity),
      (4, '4 sem', LucideIcons.calendar),
      (8, '8 sem', LucideIcons.calendarDays),
      (12, '12 sem', LucideIcons.calendarRange),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionLabel(theme, isDark, 'Semanas'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.mutedForegroundDark.withAlpha(30)
                    : AppColors.mutedForeground.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Opcional',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: durations.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = state.durationWeeks == item.$1;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < durations.length - 1 ? 10 : 0,
                ),
                child: _DurationChip(
                  label: item.$2,
                  icon: item.$3,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () {
                    HapticUtils.selectionClick();
                    notifier.setDurationWeeks(item.$1);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWorkoutDurationSection(
    ThemeData theme,
    bool isDark,
    PlanWizardState state,
    PlanWizardNotifier notifier,
  ) {
    // (minutes, label) - predefined duration options
    final durations = [
      (30, '30m'),
      (45, '45m'),
      (60, '1h'),
      (90, '1h30'),
    ];

    // Check if current value is a custom value (not in predefined list)
    final predefinedValues = durations.map((d) => d.$1).toSet();
    final isCustomValue = state.targetWorkoutMinutes != null &&
        !predefinedValues.contains(state.targetWorkoutMinutes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(theme, isDark, 'Tempo Total'),
        const SizedBox(height: 4),
        Text(
          'Tempo estimado para completar o plano de treino',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ...durations.asMap().entries.map((entry) {
              final item = entry.value;
              final isSelected = state.targetWorkoutMinutes == item.$1;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _WorkoutDurationChip(
                    label: item.$2,
                    isSelected: isSelected,
                    isDark: isDark,
                    onTap: () {
                      HapticUtils.selectionClick();
                      notifier.setTargetWorkoutMinutes(item.$1);
                    },
                  ),
                ),
              );
            }),
            // Custom duration input
            Expanded(
              child: _CustomDurationChip(
                value: isCustomValue ? state.targetWorkoutMinutes : null,
                isSelected: isCustomValue,
                isDark: isDark,
                onValueChanged: (minutes) {
                  HapticUtils.selectionClick();
                  notifier.setTargetWorkoutMinutes(minutes);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionLabel(
    ThemeData theme,
    bool isDark,
    String title, {
    bool isRequired = false,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            letterSpacing: 0.2,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(
              color: AppColors.destructive,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
  }

  bool validate() {
    return _nameController.text.trim().length >= 3;
  }
}

// Data classes for options
class _GoalOption {
  final WorkoutGoal goal;
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const _GoalOption({
    required this.goal,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _DifficultyOption {
  final PlanDifficulty difficulty;
  final String label;
  final IconData icon;
  final String description;

  const _DifficultyOption({
    required this.difficulty,
    required this.label,
    required this.icon,
    required this.description,
  });
}

// Goal Card Widget
class _GoalCard extends StatelessWidget {
  final _GoalOption option;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _GoalCard({
    required this.option,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? option.color.withAlpha(isDark ? 40 : 25)
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? option.color
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.color.withAlpha(isDark ? 40 : 30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? option.color.withAlpha(isDark ? 60 : 40)
                          : option.color.withAlpha(isDark ? 30 : 20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      option.icon,
                      size: 18,
                      color: isSelected
                          ? option.color
                          : option.color.withAlpha(isDark ? 200 : 180),
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Icon(
                      LucideIcons.checkCircle2,
                      size: 20,
                      color: option.color,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                option.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? option.color
                      : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                option.description,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Difficulty Tile Widget
class _DifficultyTile extends StatelessWidget {
  final _DifficultyOption option;
  final bool isSelected;
  final bool isDark;
  final bool showDivider;
  final VoidCallback onTap;

  const _DifficultyTile({
    required this.option,
    required this.isSelected,
    required this.isDark,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(showDivider ? 0 : 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(isDark ? 30 : 20)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha(isDark ? 50 : 30)
                          : (isDark
                              ? AppColors.mutedForegroundDark.withAlpha(20)
                              : AppColors.mutedForeground.withAlpha(15)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      option.icon,
                      size: 20,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option.description,
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.border),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            LucideIcons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? AppColors.borderDark : AppColors.border,
            indent: 70,
          ),
      ],
    );
  }
}

// Duration Chip Widget
class _DurationChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withAlpha(isDark ? 50 : 40),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Workout Duration Chip Widget
class _WorkoutDurationChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _WorkoutDurationChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(isDark ? 50 : 40),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.foregroundDark : AppColors.foreground),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomDurationChip extends StatelessWidget {
  final int? value;
  final bool isSelected;
  final bool isDark;
  final ValueChanged<int> onValueChanged;

  const _CustomDurationChip({
    required this.value,
    required this.isSelected,
    required this.isDark,
    required this.onValueChanged,
  });

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) return '${hours}h';
      return '${hours}h${mins}m';
    }
    return '${minutes}m';
  }

  Future<void> _showDurationPicker(BuildContext context) async {
    final theme = Theme.of(context);
    final sheetIsDark = theme.brightness == Brightness.dark;

    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DurationPickerBottomSheet(
          initialValue: value ?? 60,
          isDark: sheetIsDark,
          formatDuration: _formatDuration,
        );
      },
    );

    if (result != null) {
      onValueChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = isSelected && value != null ? _formatDuration(value!) : 'Outro';

    return GestureDetector(
      onTap: () => _showDurationPicker(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(isDark ? 50 : 40),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.foregroundDark : AppColors.foreground),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet for selecting custom duration with chips + slider
class _DurationPickerBottomSheet extends StatefulWidget {
  final int initialValue;
  final bool isDark;
  final String Function(int) formatDuration;

  const _DurationPickerBottomSheet({
    required this.initialValue,
    required this.isDark,
    required this.formatDuration,
  });

  @override
  State<_DurationPickerBottomSheet> createState() => _DurationPickerBottomSheetState();
}

class _DurationPickerBottomSheetState extends State<_DurationPickerBottomSheet> {
  late int selectedMinutes;

  // Predefined duration options in minutes
  static const List<int> presetDurations = [15, 20, 30, 45, 60, 75, 90, 120, 150, 180];

  @override
  void initState() {
    super.initState();
    selectedMinutes = widget.initialValue.clamp(15, 180);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? AppColors.mutedForegroundDark.withAlpha(100)
                        : AppColors.mutedForeground.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Tempo Personalizado',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Chips grid
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: presetDurations.map((minutes) {
                  final isSelected = selectedMinutes == minutes;
                  return ChoiceChip(
                    label: Text(widget.formatDuration(minutes)),
                    selected: isSelected,
                    onSelected: (_) {
                      HapticUtils.selectionClick();
                      setState(() => selectedMinutes = minutes);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: widget.isDark
                        ? AppColors.mutedForegroundDark.withAlpha(30)
                        : AppColors.mutedForeground.withAlpha(20),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (widget.isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : (widget.isDark
                                ? AppColors.borderDark
                                : AppColors.border),
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Slider with label
              Text(
                'Ajuste fino',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: widget.isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: widget.isDark
                      ? AppColors.mutedForegroundDark.withAlpha(50)
                      : AppColors.mutedForeground.withAlpha(40),
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withAlpha(30),
                  valueIndicatorColor: AppColors.primary,
                  valueIndicatorTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Slider(
                  min: 15,
                  max: 180,
                  divisions: 33, // Increments of 5 minutes
                  value: selectedMinutes.toDouble(),
                  label: widget.formatDuration(selectedMinutes),
                  onChanged: (value) {
                    setState(() => selectedMinutes = value.round());
                  },
                ),
              ),

              // Current value display
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(widget.isDark ? 30 : 20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.formatDuration(selectedMinutes),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      ' ($selectedMinutes min)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: widget.isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Confirm button
              FilledButton(
                onPressed: () {
                  HapticUtils.selectionClick();
                  Navigator.of(context).pop(selectedMinutes);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
