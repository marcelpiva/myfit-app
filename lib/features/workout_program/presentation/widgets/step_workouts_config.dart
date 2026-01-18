import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/workout_service.dart';
import '../../../../core/widgets/video_player_page.dart';
import '../../../workout_builder/domain/models/exercise.dart';
import '../../../workout_builder/presentation/providers/exercise_catalog_provider.dart';
import '../../domain/models/workout_program.dart';
import '../providers/program_wizard_provider.dart';
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
    final state = ref.watch(programWizardProvider);
    final notifier = ref.read(programWizardProvider.notifier);
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
                      HapticFeedback.selectionClick();
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
                    HapticFeedback.selectionClick();
                    setState(() => _selectedWorkoutIndex = index);
                  },
                  onLongPress: () {
                          HapticFeedback.mediumImpact();
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
    ProgramWizardNotifier notifier,
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
                      width: 36,
                      height: 36,
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
                subtitle: const Text('Alterar titulo, label e grupos musculares'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditWorkoutDialog(context, workout, notifier);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.pencil, color: AppColors.primary, size: 20),
                ),
                title: const Text('Renomear'),
                subtitle: const Text('Alterar apenas o nome'),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(context, workout, notifier);
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
                  subtitle: const Text('Excluir treino e exercicios'),
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

  void _showEditWorkoutDialog(
    BuildContext context,
    WizardWorkout workout,
    ProgramWizardNotifier notifier,
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
                    hintText: 'Ex: Peito e Triceps',
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
    ProgramWizardNotifier notifier,
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
            const Expanded(child: Text('Exercicios serao removidos')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ao remover os grupos "$groupsRemoved", ${exercisesToRemove.length} exercicio(s) serao excluidos:',
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
              _showEditWorkoutDialog(context, workout, notifier);
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

  void _showRenameDialog(
    BuildContext context,
    WizardWorkout workout,
    ProgramWizardNotifier notifier,
  ) {
    final controller = TextEditingController(text: workout.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Renomear Treino ${workout.label}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Nome do treino',
            hintText: 'Ex: Peito e Triceps',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(context);
              notifier.renameWorkout(workout.id, value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(context);
                notifier.renameWorkout(workout.id, newName);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    String workoutId,
    String label,
    ProgramWizardNotifier notifier,
    int index,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover Treino $label?'),
        content: const Text(
          'O treino e todos os exercicios configurados serao removidos. Deseja continuar?',
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

class _WorkoutConfigCard extends ConsumerWidget {
  final WizardWorkout workout;
  final bool isDark;
  final ThemeData theme;

  const _WorkoutConfigCard({
    required this.workout,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(programWizardProvider.notifier);

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
          // Workout header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
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
                      ),
                  ],
                ),
              ),
            ],
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
                          'Nenhum exercicio adicionado',
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
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    final result = await notifier.suggestExercisesForWorkout(workout.id);
                    if (!context.mounted) return;

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
                  icon: const Icon(LucideIcons.sparkles, size: 18),
                  label: const Text('Sugerir IA'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Show options for adding exercises: simple or with advanced technique
  void _showAddExerciseOptions(
      BuildContext context, WidgetRef ref, String workoutId, List<String> muscleGroups) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => TechniqueSelectionModal(
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
    // superset is used for Bi-Set/Tri-Set combined (2-3 exercises)
    final (requiredCount, minCount, maxCount) = switch (technique) {
      TechniqueType.superset => (2, 2, 3), // Bi-Set or Tri-Set: 2-3 exercises
      TechniqueType.triset => (3, null, 3),
      TechniqueType.giantset => (4, 4, 8),
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
    final notifier = ref.read(programWizardProvider.notifier);

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
          // Add exercises using the technique group method
          notifier.addTechniqueGroup(
            workoutId: workoutId,
            technique: technique,
            exercises: exercises,
            dropCount: techniqueConfig?.dropCount,
            restBetweenDrops: techniqueConfig?.restBetweenDrops,
            pauseDuration: techniqueConfig?.pauseDuration,
            miniSetCount: techniqueConfig?.miniSetCount,
            executionInstructions: techniqueConfig?.executionInstructions,
          );

          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      LucideIcons.checkCircle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${technique.displayName} adicionado com ${exercises.length} exercicio${exercises.length > 1 ? 's' : ''}',
                      ),
                    ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return _ExercisePickerSheet(
            workoutId: workoutId,
            scrollController: scrollController,
            allowedMuscleGroups: muscleGroups,
          );
        },
      ),
    );
  }

  /// Build exercise list with groups properly displayed
  Widget _buildExerciseList(BuildContext context, WidgetRef ref, WizardWorkout workout, bool isDark) {
    final notifier = ref.read(programWizardProvider.notifier);
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

  const _ExerciseGroupCard({
    super.key,
    required this.groupId,
    required this.exercises,
    required this.workoutId,
    required this.isDark,
    required this.theme,
  });

  Color _getTechniqueColor(TechniqueType type) {
    return switch (type) {
      TechniqueType.superset => Colors.purple,
      TechniqueType.triset => Colors.orange,
      TechniqueType.giantset => Colors.red,
      TechniqueType.dropset => Colors.blue,
      TechniqueType.restPause => Colors.teal,
      TechniqueType.cluster => Colors.indigo,
      TechniqueType.normal => Colors.grey,
    };
  }

  IconData _getTechniqueIcon(TechniqueType type) {
    return switch (type) {
      TechniqueType.superset => LucideIcons.arrowRightLeft,
      TechniqueType.triset => LucideIcons.triangle,
      TechniqueType.giantset => LucideIcons.crown,
      TechniqueType.dropset => LucideIcons.arrowDown,
      TechniqueType.restPause => LucideIcons.pause,
      TechniqueType.cluster => LucideIcons.boxes,
      TechniqueType.normal => LucideIcons.dumbbell,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (exercises.isEmpty) return const SizedBox.shrink();

    final notifier = ref.read(programWizardProvider.notifier);
    final leader = exercises.first;
    final techniqueType = leader.techniqueType;
    final techniqueColor = _getTechniqueColor(techniqueType);
    final groupInstructions = leader.executionInstructions;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLow.withAlpha(100)
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: techniqueColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: techniqueColor.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getTechniqueIcon(techniqueType),
                  size: 18,
                  color: techniqueColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        techniqueType.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: techniqueColor,
                        ),
                      ),
                      Text(
                        '${exercises.length} exercicios',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Instructions button if group has instructions
                if (groupInstructions.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      LucideIcons.fileText,
                      size: 18,
                      color: techniqueColor,
                    ),
                    tooltip: 'Ver instrucoes',
                    onPressed: () => _showGroupInstructions(context, groupInstructions),
                    visualDensity: VisualDensity.compact,
                  ),
                // Disband group button
                IconButton(
                  icon: Icon(
                    LucideIcons.unlink,
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  tooltip: 'Desfazer grupo',
                  onPressed: () {
                    HapticFeedback.lightImpact();
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
                  visualDensity: VisualDensity.compact,
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
                  orderInGroup: index,
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

  void _showGroupInstructions(BuildContext context, String instructions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.fileText, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text('Instrucoes do Grupo'),
          ],
        ),
        content: Text(instructions),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

/// Simplified exercise item for display within a group (no technique chip, aligned)
class _GroupedExerciseItem extends ConsumerWidget {
  final WizardExercise exercise;
  final String workoutId;
  final int orderInGroup;
  final Color techniqueColor;
  final bool isDark;
  final ThemeData theme;
  final bool isLast;

  const _GroupedExerciseItem({
    required this.exercise,
    required this.workoutId,
    required this.orderInGroup,
    required this.techniqueColor,
    required this.isDark,
    required this.theme,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(programWizardProvider.notifier);

    return Container(
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
          // Exercise name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _MiniChip(label: '${exercise.sets}x${exercise.reps}', isDark: isDark),
                    if (exercise.restSeconds > 0)
                      _MiniChip(label: '${exercise.restSeconds}s', isDark: isDark),
                    // Compact isometric display
                    if (exercise.isometricSeconds != null && exercise.isometricSeconds! > 0)
                      _MiniChip(
                        label: '${exercise.isometricSeconds}s',
                        icon: LucideIcons.timer,
                        isDark: isDark,
                        isHighlighted: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Delete button
          IconButton(
            icon: Icon(
              LucideIcons.trash2,
              size: 16,
              color: Colors.red.withValues(alpha: 0.6),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              notifier.removeExerciseFromWorkout(workoutId, exercise.id);
            },
            visualDensity: VisualDensity.compact,
          ),
        ],
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
              child: Center(child: Text('Exercicio nao encontrado')),
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
                        HapticFeedback.lightImpact();
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
                      label: const Text('Assistir Video'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Description
                  if (description.isNotEmpty) ...[
                    Text(
                      'Descricao',
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
                      'Instrucoes',
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
    final notifier = ref.read(programWizardProvider.notifier);
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
                  label: const Text('Ver Detalhes do Exercicio'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Sets
                Text('Series', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
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
                Text('Repeticoes', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
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
                            'Tecnicas Avancadas',
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
                        // Technique Type
                        Text('Tecnica', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<TechniqueType>(
                              value: techniqueType,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(8),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              items: TechniqueType.values.map((type) {
                                return DropdownMenuItem<TechniqueType>(
                                  value: type,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(type.displayName),
                                      if (type != TechniqueType.normal)
                                        Text(
                                          type.description,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) async {
                                if (value != null) {
                                  setState(() => techniqueType = value);
                                  // Show grouping dialog for group-based techniques
                                  if (ProgramWizardNotifier.techniqueRequiresGrouping(value)) {
                                    await _showGroupingDialog(context, ref, value);
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Isometric Hold
                        Text('Isometria (hold)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          'Tempo de pausa estatica durante o movimento',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton.filled(
                              onPressed: isometricSeconds != null && isometricSeconds! > 0
                                  ? () => setState(() {
                                        isometricSeconds = isometricSeconds! - 1;
                                        if (isometricSeconds == 0) isometricSeconds = null;
                                      })
                                  : null,
                              icon: Icon(LucideIcons.minus, size: 18, color: isDark ? Colors.white : Colors.black87),
                              style: IconButton.styleFrom(
                                backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  isometricSeconds != null ? '${isometricSeconds}s' : 'Nenhuma',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isometricSeconds != null ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                            ),
                            IconButton.filled(
                              onPressed: (isometricSeconds ?? 0) < 60
                                  ? () => setState(() => isometricSeconds = (isometricSeconds ?? 0) + 1)
                                  : null,
                              icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [0, 5, 10, 15, 30, 45, 60].map((sec) {
                            final isSelected = (isometricSeconds ?? 0) == sec;
                            return ChoiceChip(
                              label: Text(
                                sec == 0 ? 'Nenhuma' : '${sec}s',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : null,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              onSelected: (_) => setState(() => isometricSeconds = sec == 0 ? null : sec),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Execution Instructions
                        Text('Instrucoes de Execucao', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          'Orientacoes especificas para este exercicio no treino',
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
                      HapticFeedback.lightImpact();
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

  /// Show dialog to select exercises for grouping (superset, triset, etc.)
  Future<void> _showGroupingDialog(BuildContext context, WidgetRef ref, TechniqueType techniqueType) async {
    final state = ref.read(programWizardProvider);
    final notifier = ref.read(programWizardProvider.notifier);

    // Get the current workout
    final workout = state.workouts.firstWhere((w) => w.id == workoutId);

    // Get other exercises in the workout (excluding current exercise and already grouped ones)
    final availableExercises = workout.exercises
        .where((e) => e.id != exercise.id && e.exerciseGroupId == null)
        .toList();

    if (availableExercises.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adicione mais exercicios ao treino para criar um grupo'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Determine how many exercises can be selected based on technique
    final maxSelections = switch (techniqueType) {
      TechniqueType.superset => 1, // 2 total (current + 1)
      TechniqueType.triset => 2,   // 3 total (current + 2)
      TechniqueType.giantset => 4, // 5 total (current + 4)
      _ => 0,
    };

    final selectedIds = <String>{};

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Criar ${techniqueType.displayName}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecione ${maxSelections == 1 ? "1 exercicio" : "ate $maxSelections exercicios"} para agrupar com "${exercise.name}"',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableExercises.length,
                    itemBuilder: (context, index) {
                      final ex = availableExercises[index];
                      final isSelected = selectedIds.contains(ex.id);
                      return CheckboxListTile(
                        title: Text(ex.name),
                        subtitle: Text('${ex.sets} series x ${ex.reps}'),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true && selectedIds.length < maxSelections) {
                              selectedIds.add(ex.id);
                            } else {
                              selectedIds.remove(ex.id);
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: selectedIds.isEmpty
                  ? null
                  : () {
                      // Create the group with current exercise + selected exercises
                      notifier.createExerciseGroup(
                        workoutId: workoutId,
                        exerciseIds: [exercise.id, ...selectedIds],
                        techniqueType: techniqueType,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${techniqueType.displayName} criado com ${selectedIds.length + 1} exercicios'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
              child: const Text('Criar Grupo'),
            ),
          ],
        ),
      ),
    );
  }

  /// Get the color for a technique type
  Color _getTechniqueColor(TechniqueType type) {
    return switch (type) {
      TechniqueType.superset => Colors.purple,
      TechniqueType.triset => Colors.orange,
      TechniqueType.giantset => Colors.red,
      TechniqueType.dropset => Colors.blue,
      TechniqueType.restPause => Colors.teal,
      TechniqueType.cluster => Colors.indigo,
      TechniqueType.normal => Colors.grey,
    };
  }

  /// Get the icon for a technique type
  IconData _getTechniqueIcon(TechniqueType type) {
    return switch (type) {
      TechniqueType.superset => LucideIcons.arrowRightLeft,
      TechniqueType.triset => LucideIcons.triangle,
      TechniqueType.giantset => LucideIcons.crown,
      TechniqueType.dropset => LucideIcons.arrowDown,
      TechniqueType.restPause => LucideIcons.pause,
      TechniqueType.cluster => LucideIcons.boxes,
      TechniqueType.normal => LucideIcons.dumbbell,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(programWizardProvider);
    final notifier = ref.read(programWizardProvider.notifier);
    final otherWorkouts = state.workouts.where((w) => w.id != workoutId).toList();

    // Check if this is a single-exercise technique (dropset, rest-pause, etc.)
    final techniqueColor = _getTechniqueColor(exercise.techniqueType);
    final hasTechnique = exercise.techniqueType != TechniqueType.normal;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _showEditExerciseDialog(context, ref);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
              : theme.colorScheme.surfaceContainerLow.withAlpha(200),
          borderRadius: BorderRadius.circular(8),
          // Add colored left border for technique exercises
          border: hasTechnique
              ? Border(
                  left: BorderSide(
                    color: techniqueColor,
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Technique badge for single-exercise techniques (dropset, rest-pause, etc.)
            if (hasTechnique)
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTechniqueIcon(exercise.techniqueType),
                      size: 14,
                      color: techniqueColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      exercise.techniqueType.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: techniqueColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            // Main content
            Padding(
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
                                label: 'Instrucoes',
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
                        HapticFeedback.selectionClick();
                        notifier.copyExerciseToWorkout(workoutId, exercise.id, targetWorkoutId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Exercicio copiado para Treino ${otherWorkouts.firstWhere((w) => w.id == targetWorkoutId).label}'),
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
                  IconButton(
                    icon: Icon(
                      LucideIcons.trash2,
                      size: 18,
                      color: Colors.red.withValues(alpha: 0.7),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      notifier.removeExerciseFromWorkout(workoutId, exercise.id);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
    final notifier = ref.read(programWizardProvider.notifier);
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
                        'Selecionar Exercicio',
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
                hintText: 'Buscar exercicio...',
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
                        'Erro ao carregar exercicios',
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
                                ? 'Nenhum exercicio encontrado'
                                : 'Nenhum exercicio disponivel',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty || _selectedMuscleGroup != null
                                ? 'Tente ajustar os filtros ou a busca'
                                : 'O catalogo de exercicios esta vazio.',
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
                        HapticFeedback.selectionClick();
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
                        'Descricao',
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
                        'Instrucoes',
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
                          HapticFeedback.lightImpact();
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
                        label: const Text('Assistir Video'),
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
                  final notifier = ref.read(programWizardProvider.notifier);
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
