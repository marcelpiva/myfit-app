import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';

/// Page for tracking workout progression and applying suggested improvements
class WorkoutProgressionPage extends ConsumerStatefulWidget {
  final String? workoutId;

  const WorkoutProgressionPage({super.key, this.workoutId});

  @override
  ConsumerState<WorkoutProgressionPage> createState() => _WorkoutProgressionPageState();
}

class _WorkoutProgressionPageState extends ConsumerState<WorkoutProgressionPage> {
  // Mock current workout data
  final _CurrentWorkout _currentWorkout = _CurrentWorkout(
    name: 'Treino A - Peito e Triceps',
    lastPerformed: DateTime.now().subtract(const Duration(days: 2)),
    timesPerformed: 8,
    exercises: [
      _ProgressExercise(
        name: 'Supino Reto',
        currentSets: 4,
        currentReps: '10',
        currentWeight: 60,
        lastWeekWeight: 57.5,
        twoWeeksAgoWeight: 55,
      ),
      _ProgressExercise(
        name: 'Supino Inclinado',
        currentSets: 4,
        currentReps: '10-12',
        currentWeight: 50,
        lastWeekWeight: 50,
        twoWeeksAgoWeight: 47.5,
      ),
      _ProgressExercise(
        name: 'Crucifixo',
        currentSets: 3,
        currentReps: '12-15',
        currentWeight: 14,
        lastWeekWeight: 14,
        twoWeeksAgoWeight: 12,
      ),
      _ProgressExercise(
        name: 'Triceps Pulley',
        currentSets: 4,
        currentReps: '10-12',
        currentWeight: 30,
        lastWeekWeight: 27.5,
        twoWeeksAgoWeight: 25,
      ),
      _ProgressExercise(
        name: 'Triceps Frances',
        currentSets: 3,
        currentReps: '10-12',
        currentWeight: 20,
        lastWeekWeight: 20,
        twoWeeksAgoWeight: 17.5,
      ),
    ],
  );

  // Progression suggestions
  final List<_ProgressionSuggestion> _suggestions = [];
  final Set<String> _selectedSuggestions = {};

  @override
  void initState() {
    super.initState();
    _generateSuggestions();
  }

  void _generateSuggestions() {
    // Generate mock progression suggestions based on exercise performance
    for (final exercise in _currentWorkout.exercises) {
      // If weight hasn't increased in 2 weeks, suggest trying drop sets
      if (exercise.currentWeight == exercise.lastWeekWeight &&
          exercise.lastWeekWeight == exercise.twoWeeksAgoWeight) {
        _suggestions.add(_ProgressionSuggestion(
          id: 'technique_${exercise.name}',
          type: ProgressionType.technique,
          exerciseName: exercise.name,
          title: 'Adicionar tecnica avancada',
          description: 'Peso estagnado por 2 semanas. Tente adicionar drop sets ou rest-pause.',
          icon: LucideIcons.zap,
        ));
      }
      // If weight increased consistently, suggest increasing weight
      else if (exercise.currentWeight > exercise.lastWeekWeight) {
        _suggestions.add(_ProgressionSuggestion(
          id: 'weight_${exercise.name}',
          type: ProgressionType.increaseWeight,
          exerciseName: exercise.name,
          title: 'Aumentar carga',
          description: 'Bom progresso! Aumente 2.5kg na proxima sessao.',
          newValue: exercise.currentWeight + 2.5,
          icon: LucideIcons.trendingUp,
        ));
      }
    }

    // Generic suggestions
    _suggestions.add(_ProgressionSuggestion(
      id: 'add_sets',
      type: ProgressionType.addSets,
      exerciseName: 'Supino Reto',
      title: 'Adicionar serie',
      description: 'Adicione 1 serie ao supino para maior volume.',
      newValue: 5,
      icon: LucideIcons.plus,
    ));

    _suggestions.add(_ProgressionSuggestion(
      id: 'new_exercise',
      type: ProgressionType.newExercise,
      exerciseName: null,
      title: 'Novo exercicio',
      description: 'Considere adicionar Crossover para maior isolamento do peito.',
      icon: LucideIcons.sparkles,
    ));
  }

  void _toggleSuggestion(String suggestionId) {
    HapticUtils.selectionClick();
    setState(() {
      if (_selectedSuggestions.contains(suggestionId)) {
        _selectedSuggestions.remove(suggestionId);
      } else {
        _selectedSuggestions.add(suggestionId);
      }
    });
  }

  void _applyProgressions() {
    if (_selectedSuggestions.isEmpty) {
      HapticUtils.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos uma sugestao para aplicar', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    HapticUtils.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedSuggestions.length} progressoes aplicadas!', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(isDark ? 15 : 10),
              (isDark ? AppColors.secondaryDark : AppColors.secondary).withAlpha(isDark ? 12 : 8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              _buildAppBar(theme, isDark),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Workout Summary
                      FadeInUp(
                        child: _buildWorkoutSummary(theme, isDark),
                      ),

                      const SizedBox(height: 24),

                      // Weekly Comparison
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: _buildSectionTitle(theme, isDark, 'Comparativo Semanal', LucideIcons.barChart2),
                      ),
                      const SizedBox(height: 12),
                      FadeInUp(
                        delay: const Duration(milliseconds: 150),
                        child: _buildWeeklyComparison(theme, isDark),
                      ),

                      const SizedBox(height: 24),

                      // Exercise Progress
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildSectionTitle(theme, isDark, 'Progresso por Exercicio', LucideIcons.activity),
                      ),
                      const SizedBox(height: 12),
                      ..._currentWorkout.exercises.asMap().entries.map((entry) {
                        final index = entry.key;
                        final exercise = entry.value;
                        return FadeInUp(
                          delay: Duration(milliseconds: 250 + (index * 50)),
                          child: _buildExerciseProgressCard(theme, isDark, exercise),
                        );
                      }),

                      const SizedBox(height: 24),

                      // Progression Suggestions
                      FadeInUp(
                        delay: Duration(milliseconds: 250 + (_currentWorkout.exercises.length * 50)),
                        child: _buildSectionTitle(theme, isDark, 'Sugestoes de Progressao', LucideIcons.lightbulb),
                      ),
                      const SizedBox(height: 12),
                      ..._suggestions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final suggestion = entry.value;
                        return FadeInUp(
                          delay: Duration(milliseconds: 300 + (_currentWorkout.exercises.length * 50) + (index * 50)),
                          child: _buildSuggestionCard(theme, isDark, suggestion),
                        );
                      }),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(theme, isDark),
    );
  }

  Widget _buildAppBar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
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
                color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.arrowLeft, size: 20, color: isDark ? AppColors.foregroundDark : AppColors.foreground),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Icon(
                  LucideIcons.trendingUp,
                  size: 20,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Progressao',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, bool isDark, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.primaryDark : AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutSummary(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(26),
            (isDark ? AppColors.secondaryDark : AppColors.secondary).withAlpha(26),
          ],
        ),
        border: Border.all(
          color: (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(77),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.dumbbell,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentWorkout.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    Text(
                      'Realizado ${_currentWorkout.timesPerformed} vezes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
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
              _buildSummaryStat(
                theme,
                isDark,
                '${_currentWorkout.exercises.length}',
                'exercicios',
                LucideIcons.listOrdered,
              ),
              const SizedBox(width: 24),
              _buildSummaryStat(
                theme,
                isDark,
                '${_currentWorkout.exercises.fold(0, (sum, e) => sum + e.currentSets)}',
                'series',
                LucideIcons.repeat,
              ),
              const SizedBox(width: 24),
              _buildSummaryStat(
                theme,
                isDark,
                _formatDaysAgo(_currentWorkout.lastPerformed),
                'ultimo treino',
                LucideIcons.calendar,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDaysAgo(DateTime date) {
    final difference = DateTime.now().difference(date).inDays;
    if (difference == 0) return 'Hoje';
    if (difference == 1) return 'Ontem';
    return '$difference dias';
  }

  Widget _buildSummaryStat(
    ThemeData theme,
    bool isDark,
    String value,
    String label,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.primaryDark : AppColors.primary,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyComparison(ThemeData theme, bool isDark) {
    // Calculate totals
    final currentTotal = _currentWorkout.exercises.fold(0.0, (sum, e) => sum + e.currentWeight);
    final lastWeekTotal = _currentWorkout.exercises.fold(0.0, (sum, e) => sum + e.lastWeekWeight);
    final twoWeeksAgoTotal = _currentWorkout.exercises.fold(0.0, (sum, e) => sum + e.twoWeeksAgoWeight);

    final weekOverWeekChange = ((currentTotal - lastWeekTotal) / lastWeekTotal * 100);
    final twoWeekChange = ((currentTotal - twoWeeksAgoTotal) / twoWeeksAgoTotal * 100);

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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildComparisonCard(
                  theme,
                  isDark,
                  'Semana Atual',
                  '${currentTotal.toStringAsFixed(1)} kg',
                  null,
                  null,
                  true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildComparisonCard(
                  theme,
                  isDark,
                  'Semana Passada',
                  '${lastWeekTotal.toStringAsFixed(1)} kg',
                  weekOverWeekChange,
                  weekOverWeekChange >= 0,
                  false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildComparisonCard(
                  theme,
                  isDark,
                  '2 Semanas',
                  '${twoWeeksAgoTotal.toStringAsFixed(1)} kg',
                  twoWeekChange,
                  twoWeekChange >= 0,
                  false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    ThemeData theme,
    bool isDark,
    String title,
    String value,
    double? changePercent,
    bool? isPositive,
    bool isCurrent,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent
            ? (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(26)
            : isDark
                ? AppColors.mutedDark.withAlpha(100)
                : AppColors.muted.withAlpha(150),
        border: Border.all(
          color: isCurrent
              ? (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(77)
              : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isCurrent
                  ? (isDark ? AppColors.primaryDark : AppColors.primary)
                  : isDark
                      ? AppColors.foregroundDark
                      : AppColors.foreground,
            ),
          ),
          if (changePercent != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive! ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                  size: 12,
                  color: isPositive ? AppColors.success : AppColors.destructive,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isPositive ? AppColors.success : AppColors.destructive,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseProgressCard(ThemeData theme, bool isDark, _ProgressExercise exercise) {
    final weightChange = exercise.currentWeight - exercise.lastWeekWeight;
    final isImproving = weightChange > 0;
    final isStagnant = weightChange == 0 && exercise.lastWeekWeight == exercise.twoWeeksAgoWeight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    Text(
                      '${exercise.currentSets} series x ${exercise.currentReps} reps',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isStagnant
                      ? AppColors.warning.withAlpha(26)
                      : isImproving
                          ? AppColors.success.withAlpha(26)
                          : AppColors.destructive.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isStagnant
                          ? LucideIcons.minus
                          : isImproving
                              ? LucideIcons.trendingUp
                              : LucideIcons.trendingDown,
                      size: 14,
                      color: isStagnant
                          ? AppColors.warning
                          : isImproving
                              ? AppColors.success
                              : AppColors.destructive,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isStagnant
                          ? 'Estagnado'
                          : isImproving
                              ? '+${weightChange.toStringAsFixed(1)}kg'
                              : '${weightChange.toStringAsFixed(1)}kg',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isStagnant
                            ? AppColors.warning
                            : isImproving
                                ? AppColors.success
                                : AppColors.destructive,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildWeightColumn(theme, isDark, '2 sem', exercise.twoWeeksAgoWeight),
              const SizedBox(width: 8),
              Icon(
                LucideIcons.arrowRight,
                size: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              const SizedBox(width: 8),
              _buildWeightColumn(theme, isDark, '1 sem', exercise.lastWeekWeight),
              const SizedBox(width: 8),
              Icon(
                LucideIcons.arrowRight,
                size: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              const SizedBox(width: 8),
              _buildWeightColumn(theme, isDark, 'Atual', exercise.currentWeight, highlight: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightColumn(ThemeData theme, bool isDark, String label, double weight, {bool highlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: highlight
                ? (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(26)
                : isDark
                    ? AppColors.mutedDark.withAlpha(100)
                    : AppColors.muted.withAlpha(150),
            border: highlight
                ? Border.all(
                    color: (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(77),
                  )
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${weight.toStringAsFixed(1)}kg',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              color: highlight
                  ? (isDark ? AppColors.primaryDark : AppColors.primary)
                  : isDark
                      ? AppColors.foregroundDark
                      : AppColors.foreground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(ThemeData theme, bool isDark, _ProgressionSuggestion suggestion) {
    final isSelected = _selectedSuggestions.contains(suggestion.id);

    return GestureDetector(
      onTap: () => _toggleSuggestion(suggestion.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(26)
              : isDark
                  ? AppColors.cardDark.withAlpha(150)
                  : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.primaryDark : AppColors.primary)
                : isDark
                    ? AppColors.borderDark
                    : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getColorForType(suggestion.type, isDark).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                suggestion.icon,
                size: 22,
                color: _getColorForType(suggestion.type, isDark),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  if (suggestion.exerciseName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      suggestion.exerciseName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    suggestion.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                  if (suggestion.newValue != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getColorForType(suggestion.type, isDark).withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        suggestion.type == ProgressionType.increaseWeight
                            ? '${suggestion.newValue!.toStringAsFixed(1)}kg'
                            : '${suggestion.newValue!.toInt()} series',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getColorForType(suggestion.type, isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.primaryDark : AppColors.primary)
                    : isDark
                        ? AppColors.mutedDark
                        : AppColors.muted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? LucideIcons.check : LucideIcons.plus,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForType(ProgressionType type, bool isDark) {
    switch (type) {
      case ProgressionType.increaseWeight:
        return AppColors.success;
      case ProgressionType.addSets:
        return isDark ? AppColors.primaryDark : AppColors.primary;
      case ProgressionType.technique:
        return AppColors.warning;
      case ProgressionType.newExercise:
        return isDark ? AppColors.secondaryDark : AppColors.secondary;
    }
  }

  Widget _buildBottomBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withAlpha(240)
            : AppColors.background.withAlpha(240),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedSuggestions.length} selecionadas',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  Text(
                    'de ${_suggestions.length} sugestoes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _applyProgressions,
              icon: Icon(LucideIcons.check, size: 18),
              label: const Text('Aplicar Progressoes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedSuggestions.isNotEmpty
                    ? (isDark ? AppColors.primaryDark : AppColors.primary)
                    : isDark
                        ? AppColors.mutedDark
                        : AppColors.muted,
                foregroundColor: _selectedSuggestions.isNotEmpty
                    ? Colors.white
                    : isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Current workout model
class _CurrentWorkout {
  final String name;
  final DateTime lastPerformed;
  final int timesPerformed;
  final List<_ProgressExercise> exercises;

  _CurrentWorkout({
    required this.name,
    required this.lastPerformed,
    required this.timesPerformed,
    required this.exercises,
  });
}

/// Exercise with progress data
class _ProgressExercise {
  final String name;
  final int currentSets;
  final String currentReps;
  final double currentWeight;
  final double lastWeekWeight;
  final double twoWeeksAgoWeight;

  _ProgressExercise({
    required this.name,
    required this.currentSets,
    required this.currentReps,
    required this.currentWeight,
    required this.lastWeekWeight,
    required this.twoWeeksAgoWeight,
  });
}

/// Progression type enum
enum ProgressionType {
  increaseWeight,
  addSets,
  technique,
  newExercise,
}

/// Progression suggestion model
class _ProgressionSuggestion {
  final String id;
  final ProgressionType type;
  final String? exerciseName;
  final String title;
  final String description;
  final double? newValue;
  final IconData icon;

  _ProgressionSuggestion({
    required this.id,
    required this.type,
    required this.exerciseName,
    required this.title,
    required this.description,
    this.newValue,
    required this.icon,
  });
}
