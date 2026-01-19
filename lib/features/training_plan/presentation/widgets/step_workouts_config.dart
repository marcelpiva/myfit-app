import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/exercise_theme.dart';
import '../../../../core/services/workout_service.dart';
import '../../../../core/widgets/video_player_page.dart';
import '../../../workout_builder/domain/models/exercise.dart';
import '../../../workout_builder/presentation/providers/exercise_catalog_provider.dart';
import '../../domain/models/training_plan.dart';
import '../providers/plan_wizard_provider.dart';
import 'multi_exercise_picker.dart';
import 'technique_config_modal.dart';
import 'technique_selection_modal.dart';

/// Step 4: Configure workouts and exercises
class StepWorkoutsConfig extends ConsumerStatefulWidget {
  const StepWorkoutsConfig({super.key});

  @override
  ConsumerState<StepWorkoutsConfig> createState() => _StepWorkoutsConfigState();
}

class _StepWorkoutsConfigState extends ConsumerState<StepWorkoutsConfig> {
  int _selectedWorkoutIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planWizardProvider);
    final notifier = ref.read(planWizardProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (state.workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.folderPlus,
              size: 64,
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum treino configurado',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                notifier.addWorkout();
              },
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Adicionar Treino'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Workout tabs
        Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.workouts.length + 1,
            itemBuilder: (context, index) {
              if (index == state.workouts.length) {
                // Add button
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticUtils.selectionClick();
                      notifier.addWorkout();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.plus,
                            size: 16,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Adicionar',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final workout = state.workouts[index];
              final isSelected = index == _selectedWorkoutIndex;

              return Padding(
                padding: EdgeInsets.only(right: index < state.workouts.length - 1 ? 8 : 0),
                child: GestureDetector(
                  onTap: () {
                    HapticUtils.selectionClick();
                    setState(() => _selectedWorkoutIndex = index);
                  },
                  onLongPress: () {
                          HapticUtils.mediumImpact();
                          _showWorkoutOptionsSheet(context, workout, notifier, index, state.workouts.length);
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? theme.colorScheme.surfaceContainerLow
                                  .withAlpha(150)
                              : theme.colorScheme.surfaceContainerLow
                                  .withAlpha(200)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          workout.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                        if (workout.exercises.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withAlpha(50)
                                  : AppColors.primary.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${workout.exercises.length}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Selected workout content
        Expanded(
          child: _WorkoutConfigCard(
            workout: state.workouts[_selectedWorkoutIndex],
            isDark: isDark,
            theme: theme,
          ),
        ),
      ],
    );
  }

  void _showWorkoutOptionsSheet(
    BuildContext context,
    WizardWorkout workout,
    PlanWizardNotifier notifier,
    int index,
    int totalWorkouts,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          workout.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        workout.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              // Options
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.settings2, color: AppColors.secondary, size: 20),
                ),
                title: const Text('Editar Treino'),
                subtitle: const Text('Alterar título, label e grupos musculares'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditWorkoutDialogState(context, workout, notifier);
                },
              ),
              if (totalWorkouts > 1)
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.trash2, color: Colors.red.shade400, size: 20),
                  ),
                  title: Text('Remover', style: TextStyle(color: Colors.red.shade400)),
                  subtitle: const Text('Excluir treino e exercícios'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmDialog(context, workout.id, workout.label, notifier, index);
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditWorkoutDialogState(
    BuildContext context,
    WizardWorkout workout,
    PlanWizardNotifier notifier,
  ) {
    final labelController = TextEditingController(text: workout.label);
    final nameController = TextEditingController(text: workout.name);
    final selectedMuscleGroups = List<String>.from(workout.muscleGroups);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(LucideIcons.settings2, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Editar Treino'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label field
                TextField(
                  controller: labelController,
                  autofocus: true,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: 'Label (ex: A, B, Push)',
                    hintText: 'A',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 16),
                // Name field
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Treino',
                    hintText: 'Ex: Peito e Tríceps',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Muscle groups
                Text(
                  'Grupos Musculares',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MuscleGroup.values.map((group) {
                    final isSelected = selectedMuscleGroups.contains(group.name);
                    return FilterChip(
                      label: Text(group.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedMuscleGroups.add(group.name);
                          } else {
                            selectedMuscleGroups.remove(group.name);
                          }
                        });
                      },
                      selectedColor: AppColors.primary.withAlpha(40),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final newLabel = labelController.text.trim();
                final newName = nameController.text.trim();
                if (newLabel.isNotEmpty && newName.isNotEmpty) {
                  // Check if any exercises will be removed
                  final exercisesToRemove = notifier.getExercisesToRemove(
                    workout.id,
                    selectedMuscleGroups,
                  );

                  if (exercisesToRemove.isNotEmpty) {
                    // Show confirmation dialog
                    Navigator.pop(context);
                    _showRemoveExercisesConfirmDialog(
                      context,
                      workout,
                      notifier,
                      newLabel,
                      newName,
                      selectedMuscleGroups,
                      exercisesToRemove,
                    );
                  } else {
                    // No exercises to remove, save directly
                    Navigator.pop(context);
                    notifier.updateWorkout(
                      workoutId: workout.id,
                      label: newLabel,
                      name: newName,
                      muscleGroups: selectedMuscleGroups,
                    );
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveExercisesConfirmDialog(
    BuildContext context,
    WizardWorkout workout,
    PlanWizardNotifier notifier,
    String newLabel,
    String newName,
    List<String> newMuscleGroups,
    List<WizardExercise> exercisesToRemove,
  ) {
    final theme = Theme.of(context);
    final exerciseNames = exercisesToRemove.map((e) => e.name).toList();
    final groupsRemoved = exercisesToRemove
        .map((e) => e.muscleGroup)
        .toSet()
        .join(', ');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(LucideIcons.alertTriangle, color: Colors.orange, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Exercícios serão removidos')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ao remover os grupos "$groupsRemoved", ${exercisesToRemove.length} exercício(s) serão excluídos:',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: exerciseNames
                      .map((name) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.minus,
                                  size: 14,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Deseja continuar?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Re-open edit dialog
              _showEditWorkoutDialogState(context, workout, notifier);
            },
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              notifier.updateWorkoutWithExerciseCleanup(
                workoutId: workout.id,
                label: newLabel,
                name: newName,
                muscleGroups: newMuscleGroups,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Remover e Salvar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    String workoutId,
    String label,
    PlanWizardNotifier notifier,
    int index,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover Treino $label?'),
        content: const Text(
          'O treino e todos os exercícios configurados serão removidos. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.removeWorkout(workoutId);
              // Adjust selected index if needed
              if (_selectedWorkoutIndex >= index && _selectedWorkoutIndex > 0) {
                setState(() => _selectedWorkoutIndex--);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

class _WorkoutConfigCard extends ConsumerStatefulWidget {
  final WizardWorkout workout;
  final bool isDark;
  final ThemeData theme;

  const _WorkoutConfigCard({
    required this.workout,
    required this.isDark,
    required this.theme,
  });

  @override
  ConsumerState<_WorkoutConfigCard> createState() => _WorkoutConfigCardState();
}

class _WorkoutConfigCardState extends ConsumerState<_WorkoutConfigCard> {
  bool _isSuggestingAI = false;
  bool _cancelRequested = false;
  List<WizardWorkout>? _workoutsBeforeAI;

  // Getters for easy access to widget properties in methods
  WizardWorkout get workout => widget.workout;
  bool get isDark => widget.isDark;
  ThemeData get theme => widget.theme;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planWizardProvider);
    final notifier = ref.read(planWizardProvider.notifier);

    // Calculate current workout duration in minutes
    final currentWorkoutMinutes = workout.exercises.fold<int>(
      0,
      (sum, e) => sum + e.estimatedSeconds,
    ) ~/ 60;
    final targetMinutes = state.estimatedWorkoutMinutes;
    final timePercentage = targetMinutes > 0
        ? (currentWorkoutMinutes / targetMinutes * 100).round()
        : 0;
    final isOverTime = timePercentage > 120;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
            : theme.colorScheme.surfaceContainerLowest.withAlpha(200),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout header - tappable to edit
          InkWell(
            onTap: () {
              HapticUtils.selectionClick();
              _showEditWorkoutDialog(context, ref);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        workout.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (workout.muscleGroups.isNotEmpty)
                          Text(
                            workout.muscleGroups
                                .map((g) => g.toMuscleGroup().displayName)
                                .join(', '),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          )
                        else
                          Text(
                            'Toque para configurar',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Time indicator
                  if (workout.exercises.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isOverTime
                            ? AppColors.warning.withAlpha(isDark ? 40 : 25)
                            : AppColors.success.withAlpha(isDark ? 40 : 25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isOverTime
                              ? AppColors.warning.withAlpha(isDark ? 80 : 50)
                              : AppColors.success.withAlpha(isDark ? 80 : 50),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOverTime ? LucideIcons.alertTriangle : LucideIcons.clock,
                            size: 12,
                            color: isOverTime ? AppColors.warning : AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$currentWorkoutMinutes/$targetMinutes min',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isOverTime ? AppColors.warning : AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Edit indicator icon
                  Icon(
                    LucideIcons.pencil,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Exercise list
          Expanded(
            child: workout.exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.dumbbell,
                          size: 48,
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhum exercício adicionado',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildExerciseList(context, ref, workout, isDark),
          ),

          // Action buttons
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showAddExerciseOptions(context, ref, workout.id, workout.muscleGroups);
                  },
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Adicionar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    if (_isSuggestingAI) {
                      // Cancel the request and restore previous state
                      HapticUtils.lightImpact();
                      setState(() {
                        _cancelRequested = true;
                        _isSuggestingAI = false;
                      });
                      // Restore workouts to before AI suggestion
                      if (_workoutsBeforeAI != null) {
                        notifier.restoreWorkouts(_workoutsBeforeAI!);
                        _workoutsBeforeAI = null;
                      } else {
                        notifier.cancelLoading();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(LucideIcons.xCircle, color: Colors.white, size: 20),
                              SizedBox(width: 12),
                              Expanded(child: Text('Geração cancelada')),
                            ],
                          ),
                          backgroundColor: AppColors.mutedForeground,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    HapticUtils.selectionClick();
                    _showAITechniqueSelectionModal(context, ref, notifier);
                  },
                  icon: _isSuggestingAI
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(LucideIcons.sparkles, size: 18),
                  label: Text(_isSuggestingAI ? 'Cancelar' : 'Sugerir IA'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: _isSuggestingAI ? AppColors.destructive.withAlpha(200) : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Show AI technique selection modal
  void _showAITechniqueSelectionModal(
    BuildContext context,
    WidgetRef ref,
    PlanWizardNotifier notifier,
  ) {
    final state = ref.read(planWizardProvider);
    final difficulty = state.difficulty;

    // Pre-select techniques based on difficulty level
    final Set<TechniqueType> initialTechniques = {TechniqueType.normal};
    if (difficulty == PlanDifficulty.intermediate) {
      initialTechniques.addAll([TechniqueType.biset, TechniqueType.superset]);
    } else if (difficulty == PlanDifficulty.advanced) {
      initialTechniques.addAll([
        TechniqueType.biset,
        TechniqueType.superset,
        TechniqueType.triset,
        TechniqueType.dropset,
        TechniqueType.restPause,
      ]);
    }

    // Get muscle groups from the workout
    final workoutMuscleGroups = workout.muscleGroups;

    // Calculate current workout time and target
    final currentWorkoutMinutes = workout.exercises.fold<int>(
      0,
      (sum, e) => sum + e.estimatedSeconds,
    ) ~/ 60;
    final targetMinutes = state.estimatedWorkoutMinutes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AITechniqueSelectionSheet(
        initialTechniques: initialTechniques,
        workoutMuscleGroups: workoutMuscleGroups,
        difficulty: difficulty,
        isDark: isDark,
        theme: theme,
        currentWorkoutMinutes: currentWorkoutMinutes,
        targetWorkoutMinutes: targetMinutes,
        onConfirm: (selectedTechniques, selectedMuscleGroups, count) async {
          Navigator.pop(ctx);

          // Save current workouts state before AI suggestion
          _workoutsBeforeAI = List.from(state.workouts);

          setState(() {
            _isSuggestingAI = true;
            _cancelRequested = false;
          });

          HapticUtils.mediumImpact();

          final result = await notifier.suggestExercisesForWorkout(
            workout.id,
            allowedTechniques: selectedTechniques.map((t) => t.toApiValue()).toList(),
            muscleGroups: selectedMuscleGroups,
            count: count,
          );

          if (!context.mounted) return;

          // Check if cancelled while waiting
          if (_cancelRequested) {
            setState(() {
              _cancelRequested = false;
            });
            _workoutsBeforeAI = null;
            return;
          }

          setState(() {
            _isSuggestingAI = false;
          });
          _workoutsBeforeAI = null;

          final success = result['success'] as bool? ?? false;
          final message = result['message'] as String? ?? '';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    success ? LucideIcons.checkCircle : LucideIcons.alertCircle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(message)),
                ],
              ),
              backgroundColor: success ? AppColors.success : AppColors.destructive,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: Duration(seconds: success ? 2 : 4),
            ),
          );
        },
      ),
    );
  }

  /// Show options for adding exercises: simple or with advanced technique
  void _showAddExerciseOptions(
      BuildContext context, WidgetRef ref, String workoutId, List<String> muscleGroups) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TechniqueSelectionModal(
        muscleGroups: muscleGroups,
        onTechniqueSelected: (technique) {
          _handleTechniqueSelected(context, ref, workoutId, muscleGroups, technique);
        },
        onSimpleExercise: () {
          _showExercisePicker(context, ref, workoutId, muscleGroups);
        },
      ),
    );
  }

  /// Handle technique selection and show appropriate flow
  void _handleTechniqueSelected(
    BuildContext context,
    WidgetRef ref,
    String workoutId,
    List<String> muscleGroups,
    TechniqueType technique,
  ) {
    // Determine required exercise count based on technique
    final (requiredCount, minCount, maxCount) = switch (technique) {
      TechniqueType.biset => (2, null, 2),    // Bi-Set: exactly 2 exercises
      TechniqueType.superset => (2, null, 2), // Super-Set: exactly 2 exercises
      TechniqueType.triset => (3, null, 3),   // Tri-Set: exactly 3 exercises
      TechniqueType.giantset => (4, 4, 8),    // Giant Set: 4-8 exercises
      _ => (1, null, 1), // dropset, restPause, cluster
    };

    // For single-exercise techniques, show config first, then exercise picker
    if (requiredCount == 1) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => TechniqueConfigModal(
          technique: technique,
          onConfirm: (config) {
            _showMultiExercisePicker(
              context,
              ref,
              workoutId,
              muscleGroups,
              technique,
              requiredCount,
              minCount,
              maxCount,
              config,
            );
          },
        ),
      );
    } else {
      // For multi-exercise techniques, go directly to exercise picker
      _showMultiExercisePicker(
        context,
        ref,
        workoutId,
        muscleGroups,
        technique,
        requiredCount,
        minCount,
        maxCount,
        null,
      );
    }
  }

  /// Show multi-exercise picker for technique
  void _showMultiExercisePicker(
    BuildContext context,
    WidgetRef ref,
    String workoutId,
    List<String> muscleGroups,
    TechniqueType technique,
    int requiredCount,
    int? minCount,
    int? maxCount,
    TechniqueConfigData? config,
  ) {
    final notifier = ref.read(planWizardProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiExercisePicker(
        technique: technique,
        requiredCount: requiredCount,
        minCount: minCount,
        maxCount: maxCount,
        allowedMuscleGroups: muscleGroups,
        techniqueConfig: config,
        onExercisesSelected: (exercises, techniqueConfig) {
          // Auto-detect technique type for 2-exercise groups based on muscle groups
          TechniqueType detectedTechnique = technique;
          String? detectionInfo;

          if (exercises.length == 2) {
            final group1 = exercises[0].muscleGroup;
            final group2 = exercises[1].muscleGroup;
            final isSuperSet = MuscleGroupTechniqueDetector.isSuperSet(group1, group2);

            if (isSuperSet) {
              detectedTechnique = TechniqueType.superset;
              detectionInfo = '${group1.displayName} + ${group2.displayName} = Super-Set (grupos opostos)';
            } else {
              detectedTechnique = TechniqueType.biset;
              if (group1 == group2) {
                detectionInfo = '${group1.displayName} + ${group2.displayName} = Bi-Set (mesmo grupo)';
              } else {
                detectionInfo = '${group1.displayName} + ${group2.displayName} = Bi-Set (mesma area)';
              }
            }
          }

          // Add exercises using the technique group method
          notifier.addTechniqueGroup(
            workoutId: workoutId,
            technique: detectedTechnique,
            exercises: exercises,
            dropCount: techniqueConfig?.dropCount,
            restBetweenDrops: techniqueConfig?.restBetweenDrops,
            pauseDuration: techniqueConfig?.pauseDuration,
            miniSetCount: techniqueConfig?.miniSetCount,
            executionInstructions: techniqueConfig?.executionInstructions,
          );

          // Show success message with detection info
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.checkCircle,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${detectedTechnique.displayName} adicionado com ${exercises.length} exercício${exercises.length > 1 ? 's' : ''}',
                          ),
                        ),
                      ],
                    ),
                    if (detectionInfo != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        detectionInfo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  void _showExercisePicker(
      BuildContext context, WidgetRef ref, String workoutId, List<String> muscleGroups) {
    final notifier = ref.read(planWizardProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return MultiExercisePicker(
            technique: TechniqueType.normal,
            requiredCount: 1,
            minCount: 1,
            maxCount: 20, // Allow selecting many exercises
            allowedMuscleGroups: muscleGroups,
            onExercisesSelected: (exercises, _) {
              for (final exercise in exercises) {
                notifier.addExerciseToWorkout(workoutId, exercise);
              }
              // MultiExercisePicker already pops itself
            },
          );
        },
      ),
    );
  }

  /// Show dialog to edit workout settings (label, name, muscle groups)
  void _showEditWorkoutDialog(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(planWizardProvider.notifier);
    final labelController = TextEditingController(text: workout.label);
    final nameController = TextEditingController(text: workout.name);
    final selectedMuscleGroups = List<String>.from(workout.muscleGroups);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.settings2, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Configurar Treino',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(LucideIcons.x),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Label field
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: labelController,
                        maxLength: 10,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Label',
                          hintText: 'A',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nome do Treino',
                          hintText: 'Ex: Peito e Tríceps',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Muscle groups
                Text(
                  'Grupos Musculares',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecione os grupos trabalhados neste treino',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MuscleGroup.values.map((group) {
                    final isSelected = selectedMuscleGroups.contains(group.name);
                    return FilterChip(
                      label: Text(group.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedMuscleGroups.add(group.name);
                          } else {
                            selectedMuscleGroups.remove(group.name);
                          }
                        });
                      },
                      selectedColor: AppColors.primary.withAlpha(40),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final newLabel = labelController.text.trim();
                      final newName = nameController.text.trim();
                      if (newLabel.isNotEmpty && newName.isNotEmpty) {
                        Navigator.pop(ctx);
                        notifier.updateWorkout(
                          workoutId: workout.id,
                          label: newLabel,
                          name: newName,
                          muscleGroups: selectedMuscleGroups,
                        );
                        HapticUtils.lightImpact();
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build exercise list with groups properly displayed
  Widget _buildExerciseList(BuildContext context, WidgetRef ref, WizardWorkout workout, bool isDark) {
    final notifier = ref.read(planWizardProvider.notifier);
    final exercises = workout.exercises;

    // Group exercises by exerciseGroupId
    final Map<String?, List<WizardExercise>> groupedExercises = {};
    final List<String?> groupOrder = []; // Track order of groups/ungrouped

    for (final exercise in exercises) {
      final groupId = exercise.exerciseGroupId;
      if (!groupedExercises.containsKey(groupId)) {
        groupedExercises[groupId] = [];
        groupOrder.add(groupId);
      }
      groupedExercises[groupId]!.add(exercise);
    }

    // Sort exercises within each group by exerciseGroupOrder
    for (final group in groupedExercises.values) {
      group.sort((a, b) => a.exerciseGroupOrder.compareTo(b.exerciseGroupOrder));
    }

    // Build list items
    final listItems = <Widget>[];
    int itemIndex = 0;

    for (final groupId in groupOrder) {
      final groupExercises = groupedExercises[groupId]!;

      if (groupId == null) {
        // Ungrouped exercises - render individually
        for (final exercise in groupExercises) {
          listItems.add(
            _ExerciseItem(
              key: ValueKey(exercise.id),
              exercise: exercise,
              workoutId: workout.id,
              index: itemIndex++,
              isDark: isDark,
              theme: theme,
            ),
          );
        }
      } else {
        // Grouped exercises - render as a group card
        listItems.add(
          _ExerciseGroupCard(
            key: ValueKey('group_$groupId'),
            groupId: groupId,
            exercises: groupExercises,
            workoutId: workout.id,
            isDark: isDark,
            theme: theme,
            muscleGroups: workout.muscleGroups,
          ),
        );
        itemIndex += groupExercises.length;
      }
    }

    return ReorderableListView(
      onReorder: (oldIndex, newIndex) {
        notifier.reorderExercises(workout.id, oldIndex, newIndex);
      },
      children: listItems,
    );
  }
}

/// Widget for displaying a group of exercises (Bi-Set, Tri-Set, etc.)
class _ExerciseGroupCard extends ConsumerWidget {
  final String groupId;
  final List<WizardExercise> exercises;
  final String workoutId;
  final bool isDark;
  final ThemeData theme;
  final List<String> muscleGroups;

  const _ExerciseGroupCard({
    super.key,
    required this.groupId,
    required this.exercises,
    required this.workoutId,
    required this.isDark,
    required this.theme,
    required this.muscleGroups,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (exercises.isEmpty) return const SizedBox.shrink();

    final notifier = ref.read(planWizardProvider.notifier);
    final leader = exercises.first;
    final techniqueType = leader.techniqueType;
    final techniqueColor = ExerciseTheme.getColor(techniqueType);
    final groupInstructions = leader.groupInstructions;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLow.withAlpha(100)
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: techniqueColor,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: techniqueColor.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                // Compact badge (icon + name + count)
                Icon(
                  ExerciseTheme.getIcon(techniqueType),
                  size: 14,
                  color: techniqueColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '${techniqueType.displayName} (${exercises.length})',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: techniqueColor,
                  ),
                ),
                const Spacer(),
                // Action icons
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showAddExerciseToGroup(context, ref, techniqueColor),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(LucideIcons.plus, size: 16, color: techniqueColor),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showEditGroupInstructions(context, ref, groupInstructions),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      LucideIcons.fileText,
                      size: 16,
                      color: groupInstructions.isNotEmpty
                          ? techniqueColor
                          : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticUtils.selectionClick();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Desfazer Grupo'),
                        content: Text(
                          'Deseja desfazer o grupo "${techniqueType.displayName}"? Os exercícios serão mantidos individualmente.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              HapticUtils.lightImpact();
                              notifier.disbandExerciseGroup(workoutId, groupId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Grupo desfeito'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text('Desfazer'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      LucideIcons.unlink,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showDeleteGroupConfirmation(context, ref, techniqueType),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      LucideIcons.trash2,
                      size: 16,
                      color: Colors.red.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Exercises in group (aligned, no indentation)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return _GroupedExerciseItem(
                  exercise: exercise,
                  workoutId: workoutId,
                  groupId: groupId,
                  orderInGroup: index,
                  totalInGroup: exercises.length,
                  techniqueColor: techniqueColor,
                  isDark: isDark,
                  theme: theme,
                  isLast: index == exercises.length - 1,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseToGroup(
      BuildContext context, WidgetRef ref, Color techniqueColor) {
    HapticUtils.selectionClick();

    // Get exercises already in this group
    final groupExerciseIds = exercises.map((e) => e.exerciseId).toSet();
    final currentGroupSize = exercises.length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddToGroupExercisePicker(
        techniqueColor: techniqueColor,
        excludedExerciseIds: groupExerciseIds,
        currentGroupSize: currentGroupSize,
        maxGroupSize: 8,
        allowedMuscleGroups: muscleGroups,
        onExercisesSelected: (exercisesList) {
          final notifier = ref.read(planWizardProvider.notifier);
          for (final exercise in exercisesList) {
            notifier.addExerciseToGroup(
              workoutId: workoutId,
              groupId: groupId,
              exercise: exercise,
            );
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                exercisesList.length == 1
                    ? '${exercisesList.first.name} adicionado ao grupo'
                    : '${exercisesList.length} exercícios adicionados ao grupo',
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showEditGroupInstructions(
      BuildContext context, WidgetRef ref, String currentInstructions) {
    HapticUtils.selectionClick();

    final controller = TextEditingController(text: currentInstructions);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.fileText, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Instruções do Grupo'),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estas instruções serão aplicadas a todos os exercícios do grupo.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ex: Execute sem descanso entre os exercícios...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(planWizardProvider.notifier).updateGroupInstructions(
                    workoutId: workoutId,
                    groupId: groupId,
                    instructions: controller.text.trim(),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Instruções atualizadas'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupConfirmation(
      BuildContext context, WidgetRef ref, TechniqueType techniqueType) {
    HapticUtils.mediumImpact();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: Colors.red, size: 22),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Excluir Grupo'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja excluir este ${techniqueType.displayName}?',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Todos os ${exercises.length} exercícios serão removidos do treino.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(planWizardProvider.notifier).deleteExerciseGroup(
                    workoutId,
                    groupId,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${techniqueType.displayName} excluído'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

/// Simplified exercise item for display within a group (no technique chip, aligned)
/// Now with full editing capabilities
class _GroupedExerciseItem extends ConsumerWidget {
  final WizardExercise exercise;
  final String workoutId;
  final String groupId;
  final int orderInGroup;
  final int totalInGroup;
  final Color techniqueColor;
  final bool isDark;
  final ThemeData theme;
  final bool isLast;

  const _GroupedExerciseItem({
    required this.exercise,
    required this.workoutId,
    required this.groupId,
    required this.orderInGroup,
    required this.totalInGroup,
    required this.techniqueColor,
    required this.isDark,
    required this.theme,
    required this.isLast,
  });

  void _showExerciseDetails(BuildContext context) async {
    final service = WorkoutService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => FutureBuilder<Map<String, dynamic>?>(
        future: service.getExercise(exercise.exerciseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final exerciseData = snapshot.data;
          if (exerciseData == null) {
            return const SizedBox(
              height: 200,
              child: Center(child: Text('Exercício não encontrado')),
            );
          }

          final name = exerciseData['name'] as String? ?? '';
          final description = exerciseData['description'] as String? ?? '';
          final instructions = exerciseData['instructions'] as String? ?? '';
          final imageUrl = exerciseData['image_url'] as String?;
          final videoUrl = exerciseData['video_url'] as String?;
          final muscleGroup = exerciseData['muscle_group'] as String? ?? '';

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (muscleGroup.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        muscleGroup,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Image
                  if (imageUrl != null && imageUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.mutedDark : AppColors.muted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(LucideIcons.image, size: 48),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Video button
                  if (videoUrl != null && videoUrl.isNotEmpty) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerPage(
                              videoUrl: videoUrl,
                              title: exercise.name,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.play),
                      label: const Text('Ver Vídeo'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (description.isNotEmpty) ...[
                    Text('Descrição', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(description, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 16),
                  ],

                  if (instructions.isNotEmpty) ...[
                    Text('Instruções', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(instructions, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Fechar'),
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

  void _showEditGroupedExerciseDialog(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(planWizardProvider.notifier);
    int sets = exercise.sets;
    String reps = exercise.reps;
    int restSeconds = exercise.restSeconds;
    String executionInstructions = exercise.executionInstructions;
    int? isometricSeconds = exercise.isometricSeconds;
    bool showAdvancedOptions = false;

    final repsController = TextEditingController(text: reps);
    final instructionsController = TextEditingController(text: executionInstructions);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with group indicator
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: techniqueColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${orderInGroup + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(LucideIcons.x),
                    ),
                  ],
                ),
                // Group indicator chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: techniqueColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${exercise.techniqueType.displayName} - Exercício ${orderInGroup + 1}/$totalInGroup',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: techniqueColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // View Details Button
                OutlinedButton.icon(
                  onPressed: () => _showExerciseDetails(context),
                  icon: const Icon(LucideIcons.info, size: 18),
                  label: const Text('Ver Detalhes do Exercício'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Sets
                Text('Séries', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton.filled(
                      onPressed: sets > 1 ? () => setState(() => sets--) : null,
                      icon: Icon(LucideIcons.minus, size: 18, color: isDark ? Colors.white : Colors.black87),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '$sets',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: sets < 10 ? () => setState(() => sets++) : null,
                      icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Reps
                Text('Repetições', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: repsController,
                  decoration: InputDecoration(
                    hintText: 'Ex: 10-12 ou 15',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => reps = value,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['8-10', '10-12', '12-15', '15', '20'].map((r) {
                    final isSelected = reps == r;
                    return ChoiceChip(
                      label: Text(
                        r,
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      onSelected: (_) {
                        setState(() {
                          reps = r;
                          repsController.text = r;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Rest (with note about group behavior)
                Text('Descanso (segundos)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                if (!isLast) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: techniqueColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.info, size: 12, color: techniqueColor),
                        const SizedBox(width: 4),
                        Text(
                          'Exercícios no meio do grupo têm descanso 0',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: techniqueColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton.filled(
                      onPressed: restSeconds > 0 && isLast ? () => setState(() => restSeconds -= 15) : null,
                      icon: Icon(LucideIcons.minus, size: 18, color: isDark ? Colors.white : Colors.black87),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          isLast ? '${restSeconds}s' : '0s (grupo)',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLast ? null : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: restSeconds < 300 && isLast ? () => setState(() => restSeconds += 15) : null,
                      icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: isLast ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
                if (isLast) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [30, 45, 60, 90, 120].map((sec) {
                      final isSelected = restSeconds == sec;
                      return ChoiceChip(
                        label: Text(
                          '${sec}s',
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        onSelected: (_) => setState(() => restSeconds = sec),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),

                // Advanced Options Toggle (same as simple exercise)
                InkWell(
                  onTap: () => setState(() => showAdvancedOptions = !showAdvancedOptions),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                          : theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: showAdvancedOptions
                            ? techniqueColor.withAlpha(50)
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.settings2,
                          size: 18,
                          color: showAdvancedOptions ? techniqueColor : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Técnicas Avançadas',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: showAdvancedOptions ? techniqueColor : null,
                            ),
                          ),
                        ),
                        Icon(
                          showAdvancedOptions ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                          size: 18,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),

                // Advanced Options Content
                if (showAdvancedOptions) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerLow.withAlpha(100)
                          : theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Isometric Hold - simplified to single row
                        Text('Isometria', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: [0, 15, 30, 45, 60].map((sec) {
                            final isSelected = (isometricSeconds ?? 0) == sec;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: sec < 60 ? 8 : 0),
                                child: ChoiceChip(
                                  label: Text(
                                    sec == 0 ? 'Nenhuma' : '${sec}s',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected ? Colors.white : null,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: techniqueColor,
                                  padding: EdgeInsets.zero,
                                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                                  onSelected: (_) => setState(() => isometricSeconds = sec == 0 ? null : sec),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Execution Instructions
                        Text('Instruções de Execução', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          'Orientações específicas para este exercício no treino',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: instructionsController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Ex: Manter cotovelos a 45 graus...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) => executionInstructions = value,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final updated = exercise.copyWith(
                        sets: sets,
                        reps: reps.isEmpty ? '10-12' : reps,
                        restSeconds: isLast ? restSeconds : 0, // Force 0 for non-last
                        executionInstructions: executionInstructions,
                        isometricSeconds: isometricSeconds,
                        // Keep existing group fields
                        techniqueType: exercise.techniqueType,
                        exerciseGroupId: exercise.exerciseGroupId,
                        exerciseGroupOrder: exercise.exerciseGroupOrder,
                      );
                      notifier.updateExercise(workoutId, exercise.id, updated);
                      Navigator.pop(ctx);
                      HapticUtils.lightImpact();
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(planWizardProvider.notifier);

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        _showEditGroupedExerciseDialog(context, ref);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerLow.withAlpha(80)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Order number with technique color
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: techniqueColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '${orderInGroup + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Exercise name (colored with technique color)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: techniqueColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _MiniChip(label: '${exercise.sets}x${exercise.reps}', isDark: isDark),
                      if (exercise.restSeconds > 0)
                        _MiniChip(label: '${exercise.restSeconds}s', isDark: isDark)
                      else
                        _MiniChip(
                          label: 'sem descanso',
                          isDark: isDark,
                          isHighlighted: true,
                          highlightColor: techniqueColor,
                        ),
                      // Time estimate
                      _MiniChip(
                        label: exercise.formattedTime,
                        icon: LucideIcons.clock,
                        isDark: isDark,
                      ),
                      // Compact isometric display
                      if (exercise.isometricSeconds != null && exercise.isometricSeconds! > 0)
                        _MiniChip(
                          label: '${exercise.isometricSeconds}s',
                          icon: LucideIcons.timer,
                          isDark: isDark,
                          isHighlighted: true,
                        ),
                      // Instructions indicator
                      if (exercise.executionInstructions.isNotEmpty)
                        _MiniChip(
                          label: '',
                          icon: LucideIcons.fileText,
                          isDark: isDark,
                          isHighlighted: true,
                          highlightColor: techniqueColor,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Reorder buttons (up/down)
            if (totalInGroup > 1) ...[
              IconButton(
                icon: Icon(
                  LucideIcons.chevronUp,
                  size: 16,
                  color: orderInGroup > 0
                      ? techniqueColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                onPressed: orderInGroup > 0
                    ? () {
                        HapticUtils.selectionClick();
                        notifier.reorderWithinGroup(
                          workoutId,
                          groupId,
                          orderInGroup,
                          orderInGroup - 1,
                        );
                      }
                    : null,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: 'Mover para cima',
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.chevronDown,
                  size: 16,
                  color: orderInGroup < totalInGroup - 1
                      ? techniqueColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                onPressed: orderInGroup < totalInGroup - 1
                    ? () {
                        HapticUtils.selectionClick();
                        notifier.reorderWithinGroup(
                          workoutId,
                          groupId,
                          orderInGroup,
                          orderInGroup + 1,
                        );
                      }
                    : null,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: 'Mover para baixo',
              ),
            ],
            // Info button
            IconButton(
              icon: Icon(
                LucideIcons.info,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              onPressed: () => _showExerciseDetails(context),
              visualDensity: VisualDensity.compact,
              tooltip: 'Ver detalhes',
            ),
            // Delete button
            IconButton(
              icon: Icon(
                LucideIcons.trash2,
                size: 16,
                color: Colors.red.withValues(alpha: 0.6),
              ),
              onPressed: () {
                HapticUtils.selectionClick();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Remover Exercício'),
                    content: Text('Deseja remover "${exercise.name}" do treino?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          HapticUtils.lightImpact();
                          notifier.removeExerciseFromWorkout(workoutId, exercise.id);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Remover'),
                      ),
                    ],
                  ),
                );
              },
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseItem extends ConsumerWidget {
  final WizardExercise exercise;
  final String workoutId;
  final int index;
  final bool isDark;
  final ThemeData theme;

  const _ExerciseItem({
    super.key,
    required this.exercise,
    required this.workoutId,
    required this.index,
    required this.isDark,
    required this.theme,
  });

  void _showExerciseDetails(BuildContext context, String exerciseId) async {
    final service = WorkoutService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => FutureBuilder<Map<String, dynamic>?>(
        future: service.getExercise(exerciseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final exerciseData = snapshot.data;
          if (exerciseData == null) {
            return const SizedBox(
              height: 200,
              child: Center(child: Text('Exercício não encontrado')),
            );
          }

          final name = exerciseData['name'] as String? ?? '';
          final description = exerciseData['description'] as String? ?? '';
          final instructions = exerciseData['instructions'] as String? ?? '';
          final imageUrl = exerciseData['image_url'] as String?;
          final videoUrl = exerciseData['video_url'] as String?;
          final muscleGroup = exerciseData['muscle_group'] as String? ?? '';

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (muscleGroup.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        muscleGroup,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Image
                  if (imageUrl != null && imageUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.mutedDark : AppColors.muted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(LucideIcons.image, size: 48),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Video button
                  if (videoUrl != null && videoUrl.isNotEmpty) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerPage(
                              videoUrl: videoUrl,
                              title: exercise.name,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.playCircle),
                      label: const Text('Assistir Vídeo'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Description
                  if (description.isNotEmpty) ...[
                    Text(
                      'Descrição',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Instructions
                  if (instructions.isNotEmpty) ...[
                    Text(
                      'Instruções',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      instructions,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Fechar'),
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

  void _showEditExerciseDialog(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(planWizardProvider.notifier);
    int sets = exercise.sets;
    String reps = exercise.reps;
    int restSeconds = exercise.restSeconds;
    String notes = exercise.notes;
    // Advanced technique fields
    String executionInstructions = exercise.executionInstructions;
    int? isometricSeconds = exercise.isometricSeconds;
    TechniqueType techniqueType = exercise.techniqueType;

    final repsController = TextEditingController(text: reps);
    final instructionsController = TextEditingController(text: executionInstructions);
    bool showAdvancedOptions = executionInstructions.isNotEmpty ||
        isometricSeconds != null ||
        techniqueType != TechniqueType.normal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (ctx) => SafeArea(
        child: StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(LucideIcons.x),
                      ),
                    ],
                  ),
                if (exercise.muscleGroup.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      exercise.muscleGroup,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // View Details Button
                OutlinedButton.icon(
                  onPressed: () => _showExerciseDetails(context, exercise.exerciseId),
                  icon: const Icon(LucideIcons.info, size: 18),
                  label: const Text('Ver Detalhes do Exercício'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Sets
                Text('Séries', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton.filled(
                      onPressed: sets > 1 ? () => setState(() => sets--) : null,
                      icon: Icon(LucideIcons.minus, size: 18, color: isDark ? Colors.white : Colors.black87),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '$sets',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: sets < 10 ? () => setState(() => sets++) : null,
                      icon: Icon(LucideIcons.plus, size: 18, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Reps
                Text('Repetições', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: repsController,
                  decoration: InputDecoration(
                    hintText: 'Ex: 10-12 ou 15',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => reps = value,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['8-10', '10-12', '12-15', '15', '20'].map((r) {
                    final isSelected = reps == r;
                    return ChoiceChip(
                      label: Text(
                        r,
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      onSelected: (_) {
                        setState(() {
                          reps = r;
                          repsController.text = r;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Rest
                Text('Descanso (segundos)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton.filled(
                      onPressed: restSeconds > 15 ? () => setState(() => restSeconds -= 15) : null,
                      icon: Icon(LucideIcons.minus, size: 18, color: isDark ? Colors.white : Colors.black87),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '${restSeconds}s',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: restSeconds < 300 ? () => setState(() => restSeconds += 15) : null,
                      icon: Icon(LucideIcons.plus, size: 18, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Quick rest presets
                Wrap(
                  spacing: 8,
                  children: [30, 45, 60, 90, 120].map((sec) {
                    final isSelected = restSeconds == sec;
                    return ChoiceChip(
                      label: Text(
                        '${sec}s',
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      onSelected: (_) => setState(() => restSeconds = sec),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Advanced Options Toggle
                InkWell(
                  onTap: () => setState(() => showAdvancedOptions = !showAdvancedOptions),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                          : theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: showAdvancedOptions
                            ? AppColors.primary.withAlpha(50)
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.settings2,
                          size: 18,
                          color: showAdvancedOptions ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Técnicas Avançadas',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: showAdvancedOptions ? AppColors.primary : null,
                            ),
                          ),
                        ),
                        Icon(
                          showAdvancedOptions ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                          size: 18,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),

                // Advanced Options Content
                if (showAdvancedOptions) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerLow.withAlpha(100)
                          : theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Isometric Hold - simplified to single row
                        Text('Isometria', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: [0, 15, 30, 45, 60].map((sec) {
                            final isSelected = (isometricSeconds ?? 0) == sec;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: sec < 60 ? 8 : 0),
                                child: ChoiceChip(
                                  label: Text(
                                    sec == 0 ? 'Nenhuma' : '${sec}s',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected ? Colors.white : null,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppColors.primary,
                                  padding: EdgeInsets.zero,
                                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                                  onSelected: (_) => setState(() => isometricSeconds = sec == 0 ? null : sec),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Execution Instructions
                        Text('Instruções de Execução', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          'Orientações específicas para este exercício no treino',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: instructionsController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Ex: Manter cotovelos a 45 graus...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) => executionInstructions = value,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final updated = exercise.copyWith(
                        sets: sets,
                        reps: reps.isEmpty ? '10-12' : reps,
                        restSeconds: restSeconds,
                        notes: notes,
                        // Advanced technique fields
                        executionInstructions: executionInstructions,
                        isometricSeconds: isometricSeconds,
                        techniqueType: techniqueType,
                      );
                      notifier.updateExercise(workoutId, exercise.id, updated);
                      Navigator.pop(ctx);
                      HapticUtils.lightImpact();
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  /// Show dialog to edit execution instructions (same style as group instructions)
  void _showInstructionsDialog(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(planWizardProvider.notifier);
    final controller = TextEditingController(text: exercise.executionInstructions);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.fileText, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Instruções do Exercício'),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Adicione instruções específicas para este exercício.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Ex: Manter cotovelos a 45 graus, pausar no topo...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              final updated = exercise.copyWith(
                executionInstructions: controller.text.trim(),
              );
              notifier.updateExercise(workoutId, exercise.id, updated);
              HapticUtils.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Instruções atualizadas'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  /// Show dialog to select technique category
  void _showTechniqueSelectionDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(planWizardProvider);
    final workout = state.workouts.firstWhere((w) => w.id == workoutId);

    // Check if there are other truly simple exercises available for grouping
    // (no technique and no group)
    final otherSimpleExercises = workout.exercises
        .where((e) =>
            e.id != exercise.id &&
            e.exerciseGroupId == null &&
            e.techniqueType == TechniqueType.normal)
        .toList();
    final hasOtherExercises = otherSimpleExercises.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aplicar Técnica',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Opção 1: Exercício Único
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.target, color: AppColors.primary, size: 20),
                ),
                title: const Text('Exercício Único'),
                subtitle: Text('Dropset, Rest-Pause, Cluster', style: theme.textTheme.bodySmall),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSingleExerciseTechniques(context, ref);
                },
              ),
              // Opção 2: Múltiplos Exercícios (only if there are other exercises)
              if (hasOtherExercises)
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ExerciseTheme.getColor(TechniqueType.superset).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.users, color: ExerciseTheme.getColor(TechniqueType.superset), size: 20),
                  ),
                  title: const Text('Múltiplos Exercícios'),
                  subtitle: Text('Bi-Set, Tri-Set, Giant Set', style: theme.textTheme.bodySmall),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showGroupTechniques(context, ref);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Show single exercise techniques (Dropset, Rest-Pause, Cluster)
  void _showSingleExerciseTechniques(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(planWizardProvider.notifier);
    final singleTechniques = [
      TechniqueType.dropset,
      TechniqueType.restPause,
      TechniqueType.cluster,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Técnica de Exercício Único',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...singleTechniques.map((technique) {
                final color = ExerciseTheme.getColor(technique);
                final icon = ExerciseTheme.getIcon(technique);
                final description = switch (technique) {
                  TechniqueType.dropset => 'Reduz peso sem descanso',
                  TechniqueType.restPause => 'Pausas curtas entre reps',
                  TechniqueType.cluster => 'Mini-sets com pausas',
                  _ => '',
                };

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  title: Text(technique.displayName),
                  subtitle: Text(description, style: theme.textTheme.bodySmall),
                  onTap: () {
                    Navigator.pop(ctx);
                    HapticUtils.lightImpact();
                    final updated = exercise.copyWith(techniqueType: technique);
                    notifier.updateExercise(workoutId, exercise.id, updated);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Show group techniques (Bi-Set/Tri-Set, Giant Set)
  void _showGroupTechniques(BuildContext context, WidgetRef ref) {
    final state = ref.read(planWizardProvider);
    final workout = state.workouts.firstWhere((w) => w.id == workoutId);

    // Count other truly simple exercises available for grouping
    // (no technique and no group)
    final otherSimpleExercises = workout.exercises
        .where((e) =>
            e.id != exercise.id &&
            e.exerciseGroupId == null &&
            e.techniqueType == TechniqueType.normal)
        .toList();
    final otherCount = otherSimpleExercises.length;

    // Need at least 3 other exercises for Giant Set (4+ total)
    final canShowGiantSet = otherCount >= 3;

    final supersetColor = ExerciseTheme.getColor(TechniqueType.superset);
    final giantsetColor = ExerciseTheme.getColor(TechniqueType.giantset);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agrupar com outros exercícios',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Bi-Set / Tri-Set (2-3 exercises)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: supersetColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(ExerciseTheme.getIcon(TechniqueType.superset), color: supersetColor, size: 20),
                ),
                title: const Text('Bi-Set / Tri-Set'),
                subtitle: Text('2-3 exercícios sem descanso', style: theme.textTheme.bodySmall),
                onTap: () {
                  Navigator.pop(ctx);
                  _showGroupingDialog(context, ref, TechniqueType.superset);
                },
              ),
              // Giant Set (4+ exercises) - only show if enough exercises available
              if (canShowGiantSet)
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: giantsetColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(ExerciseTheme.getIcon(TechniqueType.giantset), color: giantsetColor, size: 20),
                  ),
                  title: const Text('Giant Set'),
                  subtitle: Text('4+ exercícios sem descanso', style: theme.textTheme.bodySmall),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showGroupingDialog(context, ref, TechniqueType.giantset);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Show dialog to select exercises for grouping (superset, triset, etc.)
  Future<void> _showGroupingDialog(BuildContext context, WidgetRef ref, TechniqueType techniqueType) async {
    final state = ref.read(planWizardProvider);
    final notifier = ref.read(planWizardProvider.notifier);

    // Get the current workout
    final workout = state.workouts.firstWhere((w) => w.id == workoutId);

    // Get other truly simple exercises in the workout
    // (no technique and no group)
    final availableExercises = workout.exercises
        .where((e) =>
            e.id != exercise.id &&
            e.exerciseGroupId == null &&
            e.techniqueType == TechniqueType.normal)
        .toList();

    if (availableExercises.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adicione mais exercícios ao treino para criar um grupo'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Determine how many exercises can be selected based on technique
    // Bi-Set: exactly 1 additional = 2 total
    // Superset: 1-2 additional = 2-3 total
    // Triset: 2 additional = 3 total
    // Giant Set: 3-7 additional = 4-8 total
    final (minSelections, maxSelections) = switch (techniqueType) {
      TechniqueType.biset => (1, 1),    // Bi-Set: exactly 2 total
      TechniqueType.superset => (1, 2), // Superset: 2-3 total
      TechniqueType.triset => (2, 2),   // Tri-Set: exactly 3 total
      TechniqueType.giantset => (3, 7), // Giant Set: 4-8 total
      _ => (1, 1),
    };

    final selectedExercises = <WizardExercise>[];
    final techniqueColor = ExerciseTheme.getColor(techniqueType);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          // Calculate current group type based on selection
          final totalExercises = selectedExercises.length + 1;
          final currentGroupType = switch (totalExercises) {
            1 => 'Selecione exercícios',
            2 => techniqueType.displayName, // Show user's selection (Bi-Set or Super-Set)
            3 => 'Tri-Set',
            _ => 'Giant Set ($totalExercises)',
          };
          final canCreate = selectedExercises.length >= minSelections;

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: techniqueColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          ExerciseTheme.getIcon(techniqueType),
                          color: techniqueColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Criar Grupo',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              currentGroupType,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: techniqueColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(LucideIcons.x),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Selected exercises area (fixed height, scrollable if needed)
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 120),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: techniqueColor.withValues(alpha: 0.05),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Exercícios no grupo:',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: techniqueColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$totalExercises',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Leader exercise (current exercise - cannot be removed)
                              _GroupExerciseChip(
                                name: exercise.name,
                                number: 1,
                                color: techniqueColor,
                                canRemove: false,
                              ),
                              // Selected exercises (can be removed)
                              ...selectedExercises.asMap().entries.map((entry) {
                                final index = entry.key;
                                final ex = entry.value;
                                return _GroupExerciseChip(
                                  name: ex.name,
                                  number: index + 2,
                                  color: techniqueColor,
                                  canRemove: true,
                                  onRemove: () {
                                    setState(() => selectedExercises.remove(ex));
                                    HapticUtils.selectionClick();
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Available exercises list
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          'Toque para adicionar:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: availableExercises.length,
                          itemBuilder: (context, index) {
                            final ex = availableExercises[index];
                            final isSelected = selectedExercises.any((s) => s.id == ex.id);
                            final canAdd = !isSelected && selectedExercises.length < maxSelections;

                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? techniqueColor.withValues(alpha: 0.15)
                                      : theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isSelected ? LucideIcons.check : LucideIcons.dumbbell,
                                  color: isSelected
                                      ? techniqueColor
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                ex.name,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? techniqueColor : null,
                                ),
                              ),
                              subtitle: Text('${ex.sets} séries x ${ex.reps}'),
                              trailing: isSelected
                                  ? Icon(LucideIcons.checkCircle2, color: techniqueColor)
                                  : canAdd
                                      ? Icon(LucideIcons.plusCircle, color: theme.colorScheme.onSurface.withValues(alpha: 0.3))
                                      : null,
                              onTap: () {
                                HapticUtils.selectionClick();
                                setState(() {
                                  if (isSelected) {
                                    selectedExercises.removeWhere((s) => s.id == ex.id);
                                  } else if (canAdd) {
                                    selectedExercises.add(ex);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom action bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.card,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: canCreate
                            ? () {
                                // For 2 exercises, preserve user's choice (biset or superset)
                                // For 3+, auto-detect based on count
                                final actualTechniqueType = switch (totalExercises) {
                                  2 => techniqueType, // Keep user's choice (biset or superset)
                                  3 => TechniqueType.triset,
                                  _ => TechniqueType.giantset,
                                };
                                final groupLabel = actualTechniqueType.displayName;

                                // Create the group with current exercise + selected exercises
                                notifier.createExerciseGroup(
                                  workoutId: workoutId,
                                  exerciseIds: [exercise.id, ...selectedExercises.map((e) => e.id)],
                                  techniqueType: actualTechniqueType,
                                );
                                Navigator.pop(ctx);
                                HapticUtils.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$groupLabel criado com $totalExercises exercícios'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: techniqueColor,
                        ),
                        child: Text(
                          canCreate
                              ? 'Criar $currentGroupType'
                              : 'Selecione pelo menos $minSelections exercício${minSelections > 1 ? 's' : ''}',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(planWizardProvider);
    final notifier = ref.read(planWizardProvider.notifier);
    final otherWorkouts = state.workouts.where((w) => w.id != workoutId).toList();

    // Check if this is a single-exercise technique (dropset, rest-pause, etc.)
    final techniqueColor = ExerciseTheme.getColor(exercise.techniqueType);
    final hasTechnique = exercise.techniqueType != TechniqueType.normal;

    return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
              : theme.colorScheme.surfaceContainerLow.withAlpha(200),
          borderRadius: BorderRadius.circular(8),
          // Left border for all exercises (colored for techniques, neutral for simple)
          border: Border(
            left: BorderSide(
              color: hasTechnique
                  ? techniqueColor
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header for all exercises
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: hasTechnique
                    ? techniqueColor.withValues(alpha: 0.15)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasTechnique
                        ? ExerciseTheme.getIcon(exercise.techniqueType)
                        : LucideIcons.dumbbell,
                    size: 14,
                    color: hasTechnique
                        ? techniqueColor
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hasTechnique ? exercise.techniqueType.displayName : 'Exercício',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: hasTechnique
                          ? techniqueColor
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Link button (only for simple exercises - no technique and no group)
                  if (exercise.exerciseGroupId == null && !hasTechnique)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticUtils.selectionClick();
                        _showTechniqueSelectionDialog(context, ref);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          LucideIcons.link2,
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  // Unlink button (only for technique exercises)
                  if (hasTechnique)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticUtils.selectionClick();
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Remover Técnica'),
                            content: Text(
                              'Deseja remover a técnica "${exercise.techniqueType.displayName}" deste exercício?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  HapticUtils.lightImpact();
                                  final updated = exercise.copyWith(techniqueType: TechniqueType.normal);
                                  notifier.updateExercise(workoutId, exercise.id, updated);
                                },
                                child: const Text('Remover'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          LucideIcons.unlink,
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  // Info button - show exercise details
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticUtils.selectionClick();
                      _showExerciseDetails(context, exercise.exerciseId);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        LucideIcons.info,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  // Instructions button - edit execution instructions
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticUtils.selectionClick();
                      _showInstructionsDialog(context, ref);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        LucideIcons.fileText,
                        size: 16,
                        color: exercise.executionInstructions.isNotEmpty
                            ? (hasTechnique ? techniqueColor : AppColors.primary)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  // Delete button (for all exercises)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticUtils.selectionClick();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Remover Exercício'),
                          content: Text('Deseja remover "${exercise.name}" do treino?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                HapticUtils.lightImpact();
                                notifier.removeExerciseFromWorkout(workoutId, exercise.id);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Remover'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        LucideIcons.trash2,
                        size: 16,
                        color: Colors.red.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content - tappable to edit exercise
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticUtils.selectionClick();
                _showEditExerciseDialog(context, ref);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.gripVertical,
                      size: 20,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: hasTechnique ? techniqueColor : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _MiniChip(label: '${exercise.sets} series', isDark: isDark),
                              _MiniChip(label: '${exercise.reps} reps', isDark: isDark),
                              _MiniChip(
                                label: exercise.restSeconds == 0 ? 'Sem descanso' : '${exercise.restSeconds}s',
                                isDark: isDark,
                                isHighlighted: exercise.restSeconds == 0,
                              ),
                              // Time estimate
                              _MiniChip(
                                label: exercise.formattedTime,
                                icon: LucideIcons.clock,
                                isDark: isDark,
                              ),
                              // Compact isometric display
                              if (exercise.isometricSeconds != null && exercise.isometricSeconds! > 0)
                                _MiniChip(
                                  label: '${exercise.isometricSeconds}s',
                                  icon: LucideIcons.timer,
                                  isDark: isDark,
                                  isHighlighted: true,
                                ),
                              if (exercise.executionInstructions.isNotEmpty)
                                _MiniChip(
                                  label: 'Instruções',
                                  isDark: isDark,
                                  icon: LucideIcons.fileText,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  // Copy to another workout
                  if (otherWorkouts.isNotEmpty)
                    PopupMenuButton<String>(
                      icon: Icon(
                        LucideIcons.copy,
                        size: 18,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      tooltip: 'Copiar para outro treino',
                      onSelected: (targetWorkoutId) {
                        HapticUtils.selectionClick();
                        notifier.copyExerciseToWorkout(workoutId, exercise.id, targetWorkoutId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Exercício copiado para Treino ${otherWorkouts.firstWhere((w) => w.id == targetWorkoutId).label}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      itemBuilder: (context) => otherWorkouts.map((w) {
                        return PopupMenuItem<String>(
                          value: w.id,
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    w.label,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  w.name,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final bool isHighlighted;
  final IconData? icon;
  final Color? highlightColor;

  const _MiniChip({
    required this.label,
    required this.isDark,
    this.isHighlighted = false,
    this.icon,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHighlightColor = highlightColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isHighlighted
            ? effectiveHighlightColor.withAlpha(isDark ? 40 : 25)
            : (isDark
                ? AppColors.mutedDark.withAlpha(80)
                : AppColors.muted.withAlpha(150)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 10,
              color: isHighlighted
                  ? effectiveHighlightColor
                  : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
            ),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isHighlighted
                  ? effectiveHighlightColor
                  : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
              fontWeight: isHighlighted ? FontWeight.w500 : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact chip for displaying exercises in group selection
class _GroupExerciseChip extends StatelessWidget {
  final String name;
  final int number;
  final Color color;
  final bool canRemove;
  final VoidCallback? onRemove;

  const _GroupExerciseChip({
    required this.name,
    required this.number,
    required this.color,
    required this.canRemove,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (canRemove) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(LucideIcons.x, size: 14, color: color),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExercisePickerSheet extends ConsumerStatefulWidget {
  final String workoutId;
  final ScrollController scrollController;
  final List<String> allowedMuscleGroups;

  const _ExercisePickerSheet({
    required this.workoutId,
    required this.scrollController,
    required this.allowedMuscleGroups,
  });

  /// Check if filtering is enabled (workout has muscle groups defined)
  bool get hasRestriction => allowedMuscleGroups.isNotEmpty;

  /// Get allowed muscle groups as enum list
  List<MuscleGroup> get allowedGroups =>
      allowedMuscleGroups.map((g) => g.toMuscleGroup()).toList();

  @override
  ConsumerState<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<_ExercisePickerSheet> {
  final _searchController = TextEditingController();
  MuscleGroup? _selectedMuscleGroup;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesByMuscleGroupProvider);
    final notifier = ref.read(planWizardProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecionar Exercício',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.hasRestriction)
                        Text(
                          'Filtrado por: ${widget.allowedGroups.map((g) => g.displayName).join(', ')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar exercício...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                filled: true,
                fillColor: isDark
                    ? theme.colorScheme.surfaceContainerLow
                    : theme.colorScheme.surfaceContainerLowest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          // Muscle group filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // "Todos" chip - only show if no restriction or multiple allowed groups
                if (!widget.hasRestriction || widget.allowedGroups.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Todos'),
                      selected: _selectedMuscleGroup == null,
                      onSelected: (_) => setState(() => _selectedMuscleGroup = null),
                      selectedColor: AppColors.primary.withAlpha(40),
                      checkmarkColor: AppColors.primary,
                    ),
                  ),
                // Filter chips - only show allowed groups if restriction is active
                ...(widget.hasRestriction ? widget.allowedGroups : MuscleGroup.values)
                    .map((group) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(group.displayName),
                            selected: _selectedMuscleGroup == group,
                            onSelected: (_) => setState(() {
                              _selectedMuscleGroup = _selectedMuscleGroup == group ? null : group;
                            }),
                            selectedColor: AppColors.primary.withAlpha(40),
                            checkmarkColor: AppColors.primary,
                          ),
                        )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // Exercise list
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.alertCircle,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar exercícios',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              data: (grouped) {
                // Filter and flatten exercises
                final allExercises = <Exercise>[];
                for (final entry in grouped.entries) {
                  // Check if this muscle group is allowed
                  final isGroupAllowed = !widget.hasRestriction ||
                      widget.allowedGroups.contains(entry.key);

                  // Apply muscle group filter (both restriction and user selection)
                  final matchesMuscleFilter = isGroupAllowed &&
                      (_selectedMuscleGroup == null || entry.key == _selectedMuscleGroup);

                  if (matchesMuscleFilter) {
                    for (final ex in entry.value) {
                      if (_searchQuery.isEmpty ||
                          ex.name.toLowerCase().contains(_searchQuery) ||
                          ex.muscleGroupName.toLowerCase().contains(_searchQuery)) {
                        allExercises.add(ex);
                      }
                    }
                  }
                }

                // Empty state
                if (allExercises.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.searchX,
                            size: 64,
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty || _selectedMuscleGroup != null
                                ? 'Nenhum exercício encontrado'
                                : 'Nenhum exercício disponível',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty || _selectedMuscleGroup != null
                                ? 'Tente ajustar os filtros ou a busca'
                                : 'O catálogo de exercícios está vazio.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: allExercises.length,
                  itemBuilder: (context, index) {
                    final ex = allExercises[index];
                    return _ExerciseCard(
                      exercise: ex,
                      isDark: isDark,
                      theme: theme,
                      onAdd: () {
                        HapticUtils.selectionClick();
                        notifier.addExerciseToWorkout(widget.workoutId, ex);
                        Navigator.pop(context);
                      },
                      onPreview: () => _showExercisePreview(context, ex, theme, isDark),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showExercisePreview(BuildContext context, Exercise exercise, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image/Video area
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surfaceContainerLow
                            : theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                exercise.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                              ),
                            )
                          : _buildPlaceholder(theme),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      exercise.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTag(exercise.muscleGroupName, AppColors.primary, theme),
                        if (exercise.equipmentName != null)
                          _buildTag(exercise.equipmentName!, AppColors.secondary, theme),
                        if (exercise.isCompound)
                          _buildTag('Composto', Colors.orange, theme),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description
                    if (exercise.description != null && exercise.description!.isNotEmpty) ...[
                      Text(
                        'Descrição',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exercise.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Instructions
                    if (exercise.instructions != null && exercise.instructions!.isNotEmpty) ...[
                      Text(
                        'Instruções',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exercise.instructions!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],

                    // Video button
                    if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () {
                          HapticUtils.lightImpact();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => VideoPlayerPage(
                                videoUrl: exercise.videoUrl!,
                                title: exercise.name,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(LucideIcons.play, size: 18),
                        label: const Text('Assistir Vídeo'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Add button
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () {
                  final notifier = ref.read(planWizardProvider.notifier);
                  notifier.addExerciseToWorkout(widget.workoutId, exercise);
                  Navigator.pop(context); // Close preview
                  Navigator.pop(context); // Close picker
                },
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Adicionar ao Treino'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.image,
            size: 48,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'Sem imagem',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onAdd;
  final VoidCallback onPreview;

  const _ExerciseCard({
    required this.exercise,
    required this.isDark,
    required this.theme,
    required this.onAdd,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPreview,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image thumbnail
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            exercise.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              LucideIcons.dumbbell,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                        )
                      : const Icon(
                          LucideIcons.dumbbell,
                          color: AppColors.primary,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              exercise.muscleGroupName,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (exercise.equipmentName != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                exercise.equipmentName!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onPreview,
                      icon: Icon(
                        LucideIcons.eye,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      tooltip: 'Ver detalhes',
                    ),
                    IconButton(
                      onPressed: onAdd,
                      icon: const Icon(
                        LucideIcons.plus,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Adicionar',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Exercise picker for adding exercises to an existing group
class _AddToGroupExercisePicker extends ConsumerStatefulWidget {
  final Color techniqueColor;
  final Set<String> excludedExerciseIds;
  final Function(List<Exercise>) onExercisesSelected;
  final int currentGroupSize;
  final int maxGroupSize;
  final List<String> allowedMuscleGroups;

  const _AddToGroupExercisePicker({
    required this.techniqueColor,
    required this.excludedExerciseIds,
    required this.onExercisesSelected,
    this.currentGroupSize = 0,
    this.maxGroupSize = 8,
    this.allowedMuscleGroups = const [],
  });

  @override
  ConsumerState<_AddToGroupExercisePicker> createState() => _AddToGroupExercisePickerState();
}

class _AddToGroupExercisePickerState extends ConsumerState<_AddToGroupExercisePicker> {
  final _searchController = TextEditingController();
  MuscleGroup? _selectedMuscleGroup;
  String _searchQuery = '';
  final Set<Exercise> _selectedExercises = {};

  int get _remainingSlots => widget.maxGroupSize - widget.currentGroupSize - _selectedExercises.length;
  bool get _canSelectMore => _remainingSlots > 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesByMuscleGroupProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.techniqueColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.plus,
                    color: widget.techniqueColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adicionar ao Grupo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _selectedExercises.isEmpty
                            ? 'Selecione até $_remainingSlots exercício${_remainingSlots != 1 ? 's' : ''}'
                            : '${_selectedExercises.length} selecionado${_selectedExercises.length != 1 ? 's' : ''} ($_remainingSlots restante${_remainingSlots != 1 ? 's' : ''})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: widget.techniqueColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar exercício...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                filled: true,
                fillColor: isDark
                    ? theme.colorScheme.surfaceContainerLow
                    : theme.colorScheme.surfaceContainerLowest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          // Muscle group filter chips - only show allowed groups
          if (widget.allowedMuscleGroups.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Todos'),
                      selected: _selectedMuscleGroup == null,
                      onSelected: (_) => setState(() => _selectedMuscleGroup = null),
                      selectedColor: widget.techniqueColor.withAlpha(40),
                      checkmarkColor: widget.techniqueColor,
                    ),
                  ),
                  ...widget.allowedMuscleGroups.map((groupStr) {
                    final group = groupStr.toMuscleGroup();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(group.displayName),
                        selected: _selectedMuscleGroup == group,
                        onSelected: (_) => setState(() {
                          _selectedMuscleGroup = _selectedMuscleGroup == group ? null : group;
                        }),
                        selectedColor: widget.techniqueColor.withAlpha(40),
                        checkmarkColor: widget.techniqueColor,
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // Exercise list
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.alertCircle,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar exercícios',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              data: (grouped) {
                // Convert allowed muscle groups to MuscleGroup enum
                final allowedGroups = widget.allowedMuscleGroups.isEmpty
                    ? MuscleGroup.values.toSet()
                    : widget.allowedMuscleGroups.map((g) => g.toMuscleGroup()).toSet();

                final allExercises = <Exercise>[];
                for (final entry in grouped.entries) {
                  // Filter by allowed muscle groups first
                  final isAllowedGroup = allowedGroups.contains(entry.key);
                  final matchesMuscleFilter =
                      _selectedMuscleGroup == null || _selectedMuscleGroup == entry.key;

                  if (isAllowedGroup && matchesMuscleFilter) {
                    for (final exercise in entry.value) {
                      // Filter out excluded exercises and apply search
                      final isExcluded = widget.excludedExerciseIds.contains(exercise.id);
                      final matchesSearch = _searchQuery.isEmpty ||
                          exercise.name.toLowerCase().contains(_searchQuery);
                      if (!isExcluded && matchesSearch) {
                        allExercises.add(exercise);
                      }
                    }
                  }
                }

                if (allExercises.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.searchX,
                            size: 48,
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum exercício encontrado',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: allExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = allExercises[index];
                    final isSelected = _selectedExercises.contains(exercise);
                    final canSelect = isSelected || _canSelectMore;

                    return InkWell(
                      onTap: canSelect
                          ? () {
                              HapticUtils.selectionClick();
                              setState(() {
                                if (isSelected) {
                                  _selectedExercises.remove(exercise);
                                } else {
                                  _selectedExercises.add(exercise);
                                }
                              });
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? widget.techniqueColor.withValues(alpha: 0.1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Image
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? theme.colorScheme.surfaceContainerHigh
                                    : theme.colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? Border.all(
                                        color: widget.techniqueColor,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: exercise.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(isSelected ? 8 : 10),
                                      child: Image.network(
                                        exercise.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          LucideIcons.dumbbell,
                                          color: theme.colorScheme.outline,
                                          size: 24,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      LucideIcons.dumbbell,
                                      color: theme.colorScheme.outline,
                                      size: 24,
                                    ),
                            ),
                            const SizedBox(width: 14),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: !canSelect
                                          ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    exercise.muscleGroupName,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: canSelect ? 0.6 : 0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Selection indicator
                            if (isSelected)
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: widget.techniqueColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                            else if (canSelect)
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              )
                            else
                              Icon(
                                LucideIcons.ban,
                                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Confirm button
          if (_selectedExercises.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: SafeArea(
                child: FilledButton(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    Navigator.pop(context);
                    widget.onExercisesSelected(_selectedExercises.toList());
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.techniqueColor,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(
                    'Adicionar ${_selectedExercises.length} Exercício${_selectedExercises.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Sheet for selecting which techniques and muscle groups AI should consider
class _AITechniqueSelectionSheet extends StatefulWidget {
  final Set<TechniqueType> initialTechniques;
  final List<String> workoutMuscleGroups;
  final PlanDifficulty difficulty;
  final bool isDark;
  final ThemeData theme;
  final int currentWorkoutMinutes;
  final int targetWorkoutMinutes;
  final void Function(Set<TechniqueType> selectedTechniques, List<String> selectedMuscleGroups, int count) onConfirm;

  const _AITechniqueSelectionSheet({
    required this.initialTechniques,
    required this.workoutMuscleGroups,
    required this.difficulty,
    required this.isDark,
    required this.theme,
    required this.currentWorkoutMinutes,
    required this.targetWorkoutMinutes,
    required this.onConfirm,
  });

  @override
  State<_AITechniqueSelectionSheet> createState() => _AITechniqueSelectionSheetState();
}

class _AITechniqueSelectionSheetState extends State<_AITechniqueSelectionSheet> {
  late Set<TechniqueType> _selectedTechniques;
  late Set<String> _selectedMuscleGroups;
  late int _selectedCount;

  // Average minutes per exercise (including rest)
  static const _avgMinutesPerExercise = 5;

  // Group techniques by category
  static const _simpleCategory = [TechniqueType.normal];
  static const _multiExerciseCategory = [
    TechniqueType.biset,
    TechniqueType.superset,
    TechniqueType.triset,
    TechniqueType.giantset,
  ];
  static const _singleExerciseCategory = [
    TechniqueType.dropset,
    TechniqueType.restPause,
    TechniqueType.cluster,
  ];

  bool get _hasMuscleGroupsFromWorkout => widget.workoutMuscleGroups.isNotEmpty;
  bool get _canConfirm => _selectedTechniques.isNotEmpty && _selectedMuscleGroups.isNotEmpty;

  // Time-based calculations
  int get _remainingMinutes => (widget.targetWorkoutMinutes - widget.currentWorkoutMinutes).clamp(0, widget.targetWorkoutMinutes);
  int get _suggestedCount => (_remainingMinutes / _avgMinutesPerExercise).floor().clamp(1, 10);
  bool get _wouldExceedTime => _selectedCount > _suggestedCount;

  @override
  void initState() {
    super.initState();
    _selectedTechniques = Set.from(widget.initialTechniques);
    // Pre-select muscle groups from the workout, or empty if none
    _selectedMuscleGroups = Set.from(widget.workoutMuscleGroups);
    // Set initial count based on remaining time
    _selectedCount = _suggestedCount.clamp(4, 10);
  }

  String _getDifficultyLabel() {
    switch (widget.difficulty) {
      case PlanDifficulty.beginner:
        return 'Iniciante';
      case PlanDifficulty.intermediate:
        return 'Intermediário';
      case PlanDifficulty.advanced:
        return 'Avançado';
    }
  }

  Widget _buildTimeInfoBanner() {
    final hasExercises = widget.currentWorkoutMinutes > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(widget.isDark ? 30 : 20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.info.withAlpha(widget.isDark ? 60 : 40),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.clock,
                size: 18,
                color: AppColors.info,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasExercises
                          ? 'Tempo atual: ${widget.currentWorkoutMinutes} min de ${widget.targetWorkoutMinutes} min'
                          : 'Tempo alvo: ${widget.targetWorkoutMinutes} min',
                      style: widget.theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Restam $_remainingMinutes min (~$_suggestedCount exercícios)',
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                        color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Check if selected muscle groups contain antagonist pairs (for Superset validation)
  bool _hasAntagonistPairs() {
    return MuscleGroupTechniqueDetector.hasAntagonistPairsFromStrings(
      _selectedMuscleGroups.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withAlpha(180),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configurar Sugestão IA',
                          style: widget.theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.user,
                              size: 12,
                              color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Nível: ${_getDifficultyLabel()}',
                              style: widget.theme.textTheme.bodySmall?.copyWith(
                                color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Time info banner
              _buildTimeInfoBanner(),

              const SizedBox(height: 16),

              // Muscle Groups Section
              _buildMuscleGroupsSection(),

              const SizedBox(height: 16),

              // Simple exercises
              _buildCategorySection(
                'Simples',
                _simpleCategory,
                LucideIcons.dumbbell,
              ),

              const SizedBox(height: 12),

              // Multi-exercise techniques
              _buildCategorySection(
                'Multi-Exercícios',
                _multiExerciseCategory,
                LucideIcons.link,
              ),

              const SizedBox(height: 12),

              // Single-exercise techniques
              _buildCategorySection(
                'Intensidade',
                _singleExerciseCategory,
                LucideIcons.zap,
              ),

              const SizedBox(height: 16),

              // Count selection with slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.hash,
                        size: 16,
                        color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Quantidade:',
                        style: widget.theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _wouldExceedTime
                              ? AppColors.warning.withAlpha(widget.isDark ? 40 : 25)
                              : AppColors.primary.withAlpha(widget.isDark ? 40 : 25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$_selectedCount exercícios',
                          style: widget.theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _wouldExceedTime ? AppColors.warning : AppColors.primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (_suggestedCount < 10)
                        Text(
                          'Sugerido: $_suggestedCount',
                          style: widget.theme.textTheme.labelSmall?.copyWith(
                            color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _wouldExceedTime ? AppColors.warning : AppColors.primary,
                      inactiveTrackColor: widget.theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      thumbColor: _wouldExceedTime ? AppColors.warning : AppColors.primary,
                      overlayColor: (_wouldExceedTime ? AppColors.warning : AppColors.primary).withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: _selectedCount.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (value) {
                        HapticUtils.selectionClick();
                        setState(() => _selectedCount = value.round());
                      },
                    ),
                  ),
                  // Warning if exceeds time
                  if (_wouldExceedTime)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withAlpha(widget.isDark ? 30 : 20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withAlpha(widget.isDark ? 60 : 40),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.alertTriangle,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pode ultrapassar ${widget.targetWorkoutMinutes} min de treino',
                              style: widget.theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _canConfirm
                      ? () => widget.onConfirm(_selectedTechniques, _selectedMuscleGroups.toList(), _selectedCount)
                      : null,
                  icon: const Icon(LucideIcons.sparkles, size: 18),
                  label: Text(_selectedMuscleGroups.isEmpty
                      ? 'Selecione ao menos 1 grupo muscular'
                      : 'Gerar $_selectedCount Exercícios'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleGroupsSection() {
    final showAllGroups = !_hasMuscleGroupsFromWorkout;
    final groups = showAllGroups
        ? MuscleGroup.values
        : widget.workoutMuscleGroups.map((g) => g.toMuscleGroup()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.target,
              size: 16,
              color: _selectedMuscleGroups.isEmpty
                  ? AppColors.destructive
                  : widget.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              'Grupos Musculares',
              style: widget.theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: _selectedMuscleGroups.isEmpty ? AppColors.destructive : null,
              ),
            ),
            if (_selectedMuscleGroups.isEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.destructive.withAlpha(20),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Obrigatório',
                  style: widget.theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.destructive,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          showAllGroups
              ? 'Selecione os grupos para sugerir exercícios'
              : 'Grupos do treino (desmarque se necessário)',
          style: widget.theme.textTheme.bodySmall?.copyWith(
            color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: groups.map((group) {
            final isSelected = _selectedMuscleGroups.contains(group.name);

            return FilterChip(
              label: Text(group.displayName),
              selected: isSelected,
              onSelected: (selected) {
                HapticUtils.selectionClick();
                setState(() {
                  if (selected) {
                    _selectedMuscleGroups.add(group.name);
                  } else {
                    // Always allow at least deselecting (validation happens on confirm)
                    _selectedMuscleGroups.remove(group.name);
                  }
                  // Auto-deselect Superset if no more antagonist pairs
                  if (!_hasAntagonistPairs() && _selectedTechniques.contains(TechniqueType.superset)) {
                    _selectedTechniques.remove(TechniqueType.superset);
                    // Ensure at least one technique is selected
                    if (_selectedTechniques.isEmpty) {
                      _selectedTechniques.add(TechniqueType.normal);
                    }
                  }
                });
              },
              selectedColor: AppColors.secondary.withAlpha(40),
              checkmarkColor: AppColors.secondary,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.secondary
                    : widget.theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySection(
    String title,
    List<TechniqueType> techniques,
    IconData icon,
  ) {
    final hasAntagonist = _hasAntagonistPairs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Text(
              title,
              style: widget.theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: techniques.map((technique) {
            final isSelected = _selectedTechniques.contains(technique);
            final techniqueColor = ExerciseTheme.getColor(technique);

            // Disable Superset if no antagonist pairs available
            final isSuperset = technique == TechniqueType.superset;
            final isDisabled = isSuperset && !hasAntagonist;

            return FilterChip(
              label: Text(technique.displayName),
              selected: isSelected && !isDisabled,
              onSelected: isDisabled
                  ? null
                  : (selected) {
                      HapticUtils.selectionClick();
                      setState(() {
                        if (selected) {
                          _selectedTechniques.add(technique);
                        } else {
                          // Don't allow deselecting all techniques
                          if (_selectedTechniques.length > 1) {
                            _selectedTechniques.remove(technique);
                          }
                        }
                      });
                    },
              selectedColor: techniqueColor.withAlpha(40),
              checkmarkColor: techniqueColor,
              avatar: isSelected && !isDisabled
                  ? null
                  : Icon(
                      ExerciseTheme.getIcon(technique),
                      size: 16,
                      color: isDisabled
                          ? widget.theme.colorScheme.onSurface.withValues(alpha: 0.3)
                          : widget.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
              labelStyle: TextStyle(
                color: isDisabled
                    ? widget.theme.colorScheme.onSurface.withValues(alpha: 0.4)
                    : isSelected
                        ? techniqueColor
                        : widget.theme.colorScheme.onSurface,
                fontWeight: isSelected && !isDisabled ? FontWeight.w600 : FontWeight.normal,
              ),
              tooltip: isDisabled ? 'Requer grupos musculares antagonistas' : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}
