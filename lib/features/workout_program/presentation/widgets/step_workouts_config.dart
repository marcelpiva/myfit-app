import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/workout_service.dart';
import '../../../workout_builder/domain/models/exercise.dart';
import '../../../workout_builder/presentation/providers/exercise_catalog_provider.dart';
import '../providers/program_wizard_provider.dart';

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
                : ReorderableListView.builder(
                    itemCount: workout.exercises.length,
                    onReorder: (oldIndex, newIndex) {
                      notifier.reorderExercises(workout.id, oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final exercise = workout.exercises[index];
                      return _ExerciseItem(
                        key: ValueKey(exercise.id),
                        exercise: exercise,
                        workoutId: workout.id,
                        index: index,
                        isDark: isDark,
                        theme: theme,
                      );
                    },
                  ),
          ),

          // Action buttons
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showExercisePicker(context, ref, workout.id, workout.muscleGroups);
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
                        // Open video URL
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Video: $videoUrl')),
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
    final repsController = TextEditingController(text: reps);

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
                const SizedBox(height: 16),

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(programWizardProvider);
    final notifier = ref.read(programWizardProvider.notifier);
    final otherWorkouts = state.workouts.where((w) => w.id != workoutId).toList();

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _showEditExerciseDialog(context, ref);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
              : theme.colorScheme.surfaceContainerLow.withAlpha(200),
          borderRadius: BorderRadius.circular(8),
        ),
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MiniChip(label: '${exercise.sets} series', isDark: isDark),
                      const SizedBox(width: 6),
                      _MiniChip(label: '${exercise.reps} reps', isDark: isDark),
                      const SizedBox(width: 6),
                      _MiniChip(label: '${exercise.restSeconds}s', isDark: isDark),
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
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _MiniChip({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.mutedDark.withAlpha(80)
            : AppColors.muted.withAlpha(150),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isDark
              ? AppColors.mutedForegroundDark
              : AppColors.mutedForeground,
        ),
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
                          // TODO: Open video player
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Video player em desenvolvimento')),
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
