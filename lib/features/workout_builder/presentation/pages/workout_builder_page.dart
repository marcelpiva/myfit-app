import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../domain/models/exercise.dart';
import '../providers/exercise_catalog_provider.dart';
import '../providers/workout_builder_provider.dart';

/// Workout Builder page for trainers to create and edit workout plans
class WorkoutBuilderPage extends ConsumerStatefulWidget {
  final String? workoutId;

  const WorkoutBuilderPage({super.key, this.workoutId});

  @override
  ConsumerState<WorkoutBuilderPage> createState() => _WorkoutBuilderPageState();
}

class _WorkoutBuilderPageState extends ConsumerState<WorkoutBuilderPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.workoutId != null) {
        ref.read(workoutBuilderProvider.notifier).loadWorkout(widget.workoutId!);
      } else {
        ref.read(workoutBuilderProvider.notifier).reset();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _syncControllers(WorkoutBuilderState state) {
    if (_nameController.text != state.name) {
      _nameController.text = state.name;
    }
    if (_descriptionController.text != state.description) {
      _descriptionController.text = state.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.workoutId != null;
    final state = ref.watch(workoutBuilderProvider);

    // Sync controllers when state changes (for loading)
    _syncControllers(state);

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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                      child: Text(
                        isEditing ? 'Editar Treino' : 'Novo Treino',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        _showAIWizardModal(context);
                      },
                      icon: Icon(LucideIcons.sparkles, size: 18, color: AppColors.primary),
                      label: Text('AI Wizard', style: TextStyle(color: AppColors.primary)),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        _showPreview(context);
                      },
                      icon: Icon(LucideIcons.eye, size: 18),
                      label: const Text('Preview'),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            // Loading state
            if (state.isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error message
                      if (state.errorMessage != null)
                        FadeInUp(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.destructive.withAlpha(20),
                              border: Border.all(color: AppColors.destructive.withAlpha(50)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.alertCircle, size: 18, color: AppColors.destructive),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.errorMessage!,
                                    style: TextStyle(color: AppColors.destructive),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Workout Info Section
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: _buildInfoSection(theme, isDark),
                      ),

                      const SizedBox(height: 24),

                      // Settings Row
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildSettingsRow(theme, isDark, state),
                      ),

                      const SizedBox(height: 24),

                      // Exercises Section
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: _buildExercisesHeader(theme, state),
                      ),

                      const SizedBox(height: 12),

                      // Exercise List
                      if (state.exercises.isEmpty)
                        FadeInUp(
                          delay: const Duration(milliseconds: 350),
                          child: _buildEmptyExercises(theme, isDark),
                        )
                      else
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.exercises.length,
                          onReorder: (oldIndex, newIndex) {
                            HapticUtils.selectionClick();
                            ref.read(workoutBuilderProvider.notifier)
                                .reorderExercises(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final exercise = state.exercises[index];
                            return FadeInUp(
                              key: ValueKey(exercise.id),
                              delay: Duration(milliseconds: 400 + (index * 50)),
                              child: _buildExerciseCard(theme, isDark, exercise, index),
                            );
                          },
                        ),

                      const SizedBox(height: 16),

                      // Add Exercise Button
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: _buildAddExerciseButton(theme, isDark),
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
                ? theme.colorScheme.surface.withAlpha(150)
                : theme.colorScheme.surface.withAlpha(200),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: state.isSaving || !state.isValid
                      ? null
                      : () => _saveWorkout(),
                  icon: state.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(LucideIcons.save, size: 18),
                  label: Text(isEditing ? 'Salvar Alterações' : 'Criar Treino'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
            : theme.colorScheme.surfaceContainerLowest.withAlpha(200),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações do Treino',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            onChanged: (value) {
              ref.read(workoutBuilderProvider.notifier).setName(value);
            },
            decoration: InputDecoration(
              labelText: 'Nome do Treino *',
              hintText: 'Ex: Treino A - Peito e Tríceps',
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
            maxLines: 3,
            onChanged: (value) {
              ref.read(workoutBuilderProvider.notifier).setDescription(value);
            },
            decoration: InputDecoration(
              labelText: 'Descrição (opcional)',
              hintText: 'Descreva o objetivo do treino...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(ThemeData theme, bool isDark, WorkoutBuilderState state) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
                  : theme.colorScheme.surfaceContainerLowest.withAlpha(200),
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
                    Icon(LucideIcons.gauge, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Dificuldade',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: state.difficulty,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: 'beginner', child: Text('Iniciante')),
                    const DropdownMenuItem(value: 'intermediate', child: Text('Intermediário')),
                    const DropdownMenuItem(value: 'advanced', child: Text('Avançado')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      HapticUtils.selectionClick();
                      ref.read(workoutBuilderProvider.notifier).setDifficulty(value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
                  : theme.colorScheme.surfaceContainerLowest.withAlpha(200),
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
                    Icon(LucideIcons.clock, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'Duração',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${state.estimatedDuration}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'min',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesHeader(ThemeData theme, WorkoutBuilderState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Exercícios (${state.exercises.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            HapticUtils.lightImpact();
            _showExerciseLibrary(context);
          },
          icon: Icon(LucideIcons.library, size: 16),
          label: const Text('Biblioteca'),
        ),
      ],
    );
  }

  Widget _buildEmptyExercises(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLowest.withAlpha(100)
            : theme.colorScheme.surfaceContainerLowest.withAlpha(150),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.dumbbell,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum exercício adicionado',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em "Adicionar Exercício" para começar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    ThemeData theme,
    bool isDark,
    WorkoutBuilderExercise exercise,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
            : theme.colorScheme.surfaceContainerLowest.withAlpha(200),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                  : theme.colorScheme.surfaceContainerLow.withAlpha(200),
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
                Icon(
                  LucideIcons.gripVertical,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                      Text(
                        exercise.muscleGroup.toMuscleGroup().displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    _editExercise(exercise);
                  },
                  icon: Icon(LucideIcons.pencil, size: 18),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    ref.read(workoutBuilderProvider.notifier).removeExercise(exercise.id);
                  },
                  icon: Icon(LucideIcons.trash2, size: 18, color: AppColors.destructive),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildExerciseStat(theme, 'Séries', '${exercise.sets}', LucideIcons.repeat),
                const SizedBox(width: 24),
                _buildExerciseStat(theme, 'Reps', exercise.reps, LucideIcons.hash),
                const SizedBox(width: 24),
                _buildExerciseStat(theme, 'Descanso', '${exercise.restSeconds}s', LucideIcons.timer),
                if (exercise.notes.isNotEmpty) ...[
                  const Spacer(),
                  Icon(
                    LucideIcons.messageSquare,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseStat(ThemeData theme, String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAddExerciseButton(ThemeData theme, bool isDark) {
    return InkWell(
      onTap: () {
        HapticUtils.lightImpact();
        _showExerciseLibrary(context);
      },
      borderRadius: BorderRadius.circular(8),
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
              'Adicionar Exercício',
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
    HapticUtils.lightImpact();
    final state = ref.read(workoutBuilderProvider);

    if (state.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione exercícios para ver o preview')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WorkoutPreviewSheet(
        name: state.name.isEmpty ? 'Novo Treino' : state.name,
        description: state.description,
        difficulty: state.difficulty,
        estimatedDuration: state.estimatedDuration,
        exercises: state.exercises,
        onSave: state.isValid ? () {
          Navigator.pop(ctx);
          _saveWorkout();
        } : null,
      ),
    );
  }

  void _showAIWizardModal(BuildContext context) {
    HapticUtils.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AIWizardSheet(
        onExercisesSelected: (exercises) {
          for (final exercise in exercises) {
            ref.read(workoutBuilderProvider.notifier).addExercise(exercise);
          }
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${exercises.length} exercícios adicionados')),
          );
        },
      ),
    );
  }

  void _showExerciseLibrary(BuildContext context) {
    HapticUtils.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExerciseLibrarySheet(
        onExerciseSelected: (exercise) {
          ref.read(workoutBuilderProvider.notifier).addExercise(exercise);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${exercise.name} adicionado')),
          );
        },
      ),
    );
  }

  void _editExercise(WorkoutBuilderExercise exercise) {
    HapticUtils.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExerciseEditSheet(
        exercise: exercise,
        onSave: (updated) {
          ref.read(workoutBuilderProvider.notifier).updateExercise(updated);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _saveWorkout() async {
    HapticUtils.mediumImpact();
    final workoutId = await ref.read(workoutBuilderProvider.notifier).saveWorkout();
    if (workoutId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treino salvo com sucesso!')),
      );
      Navigator.pop(context, workoutId);
    }
  }
}

/// Exercise Library Sheet - loads from API
class _ExerciseLibrarySheet extends ConsumerStatefulWidget {
  final void Function(Exercise) onExerciseSelected;

  const _ExerciseLibrarySheet({required this.onExerciseSelected});

  @override
  ConsumerState<_ExerciseLibrarySheet> createState() => _ExerciseLibrarySheetState();
}

class _ExerciseLibrarySheetState extends ConsumerState<_ExerciseLibrarySheet> {
  final _searchController = TextEditingController();
  MuscleGroup? _selectedMuscleGroup;

  final List<_MuscleGroupItem> _categories = [
    _MuscleGroupItem(MuscleGroup.chest, 'Peito', LucideIcons.heart),
    _MuscleGroupItem(MuscleGroup.back, 'Costas', LucideIcons.arrowUpDown),
    _MuscleGroupItem(MuscleGroup.shoulders, 'Ombros', LucideIcons.mountain),
    _MuscleGroupItem(MuscleGroup.biceps, 'Bíceps', LucideIcons.dumbbell),
    _MuscleGroupItem(MuscleGroup.triceps, 'Tríceps', LucideIcons.dumbbell),
    _MuscleGroupItem(MuscleGroup.legs, 'Pernas', LucideIcons.footprints),
    _MuscleGroupItem(MuscleGroup.abs, 'Abdômen', LucideIcons.alignCenter),
    _MuscleGroupItem(MuscleGroup.cardio, 'Cardio', LucideIcons.activity),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final exercisesAsync = ref.watch(filteredExercisesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Biblioteca de Exercícios',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        HapticUtils.lightImpact();
                        final result = await context.push('/workouts/exercises/new');
                        if (result == true) {
                          // Exercise was created, list will auto-refresh
                        }
                      },
                      icon: Icon(LucideIcons.plus, color: AppColors.primary),
                      tooltip: 'Criar exercício',
                    ),
                    IconButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(context);
                      },
                      icon: Icon(LucideIcons.x),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(exerciseSearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Buscar exercício...',
                prefixIcon: Icon(LucideIcons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Muscle group chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return FilterChip(
                    label: const Text('Todos'),
                    selected: _selectedMuscleGroup == null,
                    onSelected: (_) {
                      setState(() => _selectedMuscleGroup = null);
                      ref.read(exerciseMuscleGroupFilterProvider.notifier).state = null;
                    },
                  );
                }
                final category = _categories[index - 1];
                return FilterChip(
                  label: Text(category.name),
                  selected: _selectedMuscleGroup == category.muscleGroup,
                  onSelected: (_) {
                    setState(() => _selectedMuscleGroup = category.muscleGroup);
                    ref.read(exerciseMuscleGroupFilterProvider.notifier).state = category.muscleGroup;
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Exercise list
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.alertCircle, size: 48, color: AppColors.destructive),
                    const SizedBox(height: 16),
                    Text('Erro ao carregar exercícios'),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        error.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.destructive),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(filteredExercisesProvider),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.dumbbell,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum exercício encontrado',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(LucideIcons.dumbbell, color: AppColors.primary, size: 20),
                      ),
                      title: Text(
                        exercise.name,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(exercise.muscleGroupName),
                      trailing: Icon(LucideIcons.plus, color: AppColors.primary),
                      onTap: () {
                        HapticUtils.lightImpact();
                        widget.onExerciseSelected(exercise);
                      },
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
}

class _MuscleGroupItem {
  final MuscleGroup muscleGroup;
  final String name;
  final IconData icon;

  _MuscleGroupItem(this.muscleGroup, this.name, this.icon);
}

/// Exercise Edit Sheet
class _ExerciseEditSheet extends StatefulWidget {
  final WorkoutBuilderExercise exercise;
  final void Function(WorkoutBuilderExercise) onSave;

  const _ExerciseEditSheet({required this.exercise, required this.onSave});

  @override
  State<_ExerciseEditSheet> createState() => _ExerciseEditSheetState();
}

class _ExerciseEditSheetState extends State<_ExerciseEditSheet> {
  late int _sets;
  late String _reps;
  late int _rest;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _sets = widget.exercise.sets;
    _reps = widget.exercise.reps;
    _rest = widget.exercise.restSeconds;
    _notesController = TextEditingController(text: widget.exercise.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
              widget.exercise.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.exercise.muscleGroup.toMuscleGroup().displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text('Séries', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    HapticUtils.selectionClick();
                    if (_sets > 1) setState(() => _sets--);
                  },
                  icon: Icon(LucideIcons.minus),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                        : theme.colorScheme.surfaceContainerLow.withAlpha(200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$_sets',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    HapticUtils.selectionClick();
                    setState(() => _sets++);
                  },
                  icon: Icon(LucideIcons.plus),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Repetições', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: _reps),
              decoration: InputDecoration(
                hintText: 'Ex: 8-12, 15, AMRAP',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) => _reps = value,
            ),
            const SizedBox(height: 20),
            Text('Descanso (segundos)', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Slider(
              value: _rest.toDouble(),
              min: 30,
              max: 180,
              divisions: 10,
              label: '${_rest}s',
              onChanged: (value) {
                HapticUtils.selectionClick();
                setState(() => _rest = value.toInt());
              },
            ),
            Center(
              child: Text(
                '$_rest segundos',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Notas', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Instruções específicas...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  HapticUtils.mediumImpact();
                  widget.onSave(widget.exercise.copyWith(
                    sets: _sets,
                    reps: _reps,
                    restSeconds: _rest,
                    notes: _notesController.text,
                  ));
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Salvar Alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Workout Preview Sheet
class _WorkoutPreviewSheet extends StatelessWidget {
  final String name;
  final String description;
  final String difficulty;
  final int estimatedDuration;
  final List<WorkoutBuilderExercise> exercises;
  final VoidCallback? onSave;

  const _WorkoutPreviewSheet({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.estimatedDuration,
    required this.exercises,
    this.onSave,
  });

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Intermediário';
      case 'advanced':
        return 'Avançado';
      default:
        return difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate total sets and reps
    final totalSets = exercises.fold<int>(0, (sum, e) => sum + e.sets);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.eye, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Preview do Treino',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: Icon(LucideIcons.x),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workout Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withAlpha(isDark ? 40 : 30),
                          AppColors.secondary.withAlpha(isDark ? 30 : 20),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(50),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildStatChip(
                              theme,
                              isDark,
                              LucideIcons.gauge,
                              _getDifficultyLabel(difficulty),
                            ),
                            _buildStatChip(
                              theme,
                              isDark,
                              LucideIcons.clock,
                              '$estimatedDuration min',
                            ),
                            _buildStatChip(
                              theme,
                              isDark,
                              LucideIcons.dumbbell,
                              '${exercises.length} exerc.',
                            ),
                            _buildStatChip(
                              theme,
                              isDark,
                              LucideIcons.repeat,
                              '$totalSets séries',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Exercises List
                  Text(
                    'Exercícios',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...exercises.asMap().entries.map((entry) {
                    final index = entry.key;
                    final exercise = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                Text(
                                  '${exercise.sets} series x ${exercise.reps} reps • ${exercise.restSeconds}s descanso',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (exercise.notes.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        LucideIcons.messageSquare,
                                        size: 12,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          exercise.notes,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: AppColors.primary,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // Bottom Action
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(context);
                      },
                      icon: Icon(LucideIcons.pencil, size: 16),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: onSave,
                      icon: Icon(LucideIcons.save, size: 18),
                      label: const Text('Salvar Treino'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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

  Widget _buildStatChip(ThemeData theme, bool isDark, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
            : theme.colorScheme.surfaceContainerLow.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// AI Wizard Sheet - Suggests exercises based on workout goal
class _AIWizardSheet extends ConsumerStatefulWidget {
  final void Function(List<Exercise>) onExercisesSelected;

  const _AIWizardSheet({required this.onExercisesSelected});

  @override
  ConsumerState<_AIWizardSheet> createState() => _AIWizardSheetState();
}

class _AIWizardSheetState extends ConsumerState<_AIWizardSheet> {
  String? _selectedGoal;
  MuscleGroup? _selectedMuscleGroup;
  final Set<Exercise> _selectedExercises = {};
  bool _isLoading = false;
  List<Exercise> _suggestedExercises = [];

  final _goals = [
    ('hipertrofia', 'Hipertrofia', 'Ganhar massa muscular'),
    ('forca', 'Força', 'Aumentar força máxima'),
    ('resistencia', 'Resistência', 'Melhorar condicionamento'),
    ('emagrecimento', 'Emagrecimento', 'Perder gordura'),
  ];

  final _muscleGroups = [
    (MuscleGroup.chest, 'Peito'),
    (MuscleGroup.back, 'Costas'),
    (MuscleGroup.shoulders, 'Ombros'),
    (MuscleGroup.biceps, 'Bíceps'),
    (MuscleGroup.triceps, 'Tríceps'),
    (MuscleGroup.legs, 'Pernas'),
    (MuscleGroup.abs, 'Abdômen'),
  ];

  void _generateSuggestions() {
    setState(() => _isLoading = true);

    // Get exercises from the catalog based on muscle group
    final exercisesAsync = ref.read(filteredExercisesProvider);

    exercisesAsync.when(
      data: (exercises) {
        // Filter by muscle group if selected
        var filtered = exercises;
        if (_selectedMuscleGroup != null) {
          filtered = exercises.where((e) => e.muscleGroup == _selectedMuscleGroup).toList();
        }

        // Limit to 6-8 exercises
        final suggested = filtered.take(8).toList();

        setState(() {
          _suggestedExercises = suggested;
          _isLoading = false;
        });
      },
      loading: () {},
      error: (_, __) {
        setState(() => _isLoading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.sparkles, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'AI Wizard',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: Icon(LucideIcons.x),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Goal Selection
                  Text(
                    'Qual seu objetivo?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _goals.map((goal) {
                      final isSelected = _selectedGoal == goal.$1;
                      return GestureDetector(
                        onTap: () {
                          HapticUtils.selectionClick();
                          setState(() => _selectedGoal = goal.$1);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.$2,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isSelected ? Colors.white : null,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                goal.$3,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isSelected
                                      ? Colors.white.withAlpha(200)
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Muscle Group Selection
                  Text(
                    'Foco muscular',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _muscleGroups.map((group) {
                      final isSelected = _selectedMuscleGroup == group.$1;
                      return FilterChip(
                        label: Text(group.$2),
                        selected: isSelected,
                        onSelected: (_) {
                          HapticUtils.selectionClick();
                          setState(() {
                            _selectedMuscleGroup = isSelected ? null : group.$1;
                          });
                        },
                        selectedColor: AppColors.primary.withAlpha(50),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _selectedGoal == null ? null : _generateSuggestions,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(LucideIcons.sparkles, size: 18),
                      label: Text(_isLoading ? 'Gerando...' : 'Gerar Sugestões'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // Suggested Exercises
                  if (_suggestedExercises.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exercícios Sugeridos',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            HapticUtils.lightImpact();
                            setState(() {
                              if (_selectedExercises.length == _suggestedExercises.length) {
                                _selectedExercises.clear();
                              } else {
                                _selectedExercises.addAll(_suggestedExercises);
                              }
                            });
                          },
                          child: Text(
                            _selectedExercises.length == _suggestedExercises.length
                                ? 'Desmarcar Todos'
                                : 'Selecionar Todos',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(_suggestedExercises.map((exercise) {
                      final isSelected = _selectedExercises.contains(exercise);
                      return GestureDetector(
                        onTap: () {
                          HapticUtils.selectionClick();
                          setState(() {
                            if (isSelected) {
                              _selectedExercises.remove(exercise);
                            } else {
                              _selectedExercises.add(exercise);
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withAlpha(20)
                                : (isDark
                                    ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
                                    : theme.colorScheme.surfaceContainerLowest.withAlpha(200)),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : theme.colorScheme.outline.withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : theme.colorScheme.outline.withValues(alpha: 0.5),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: isSelected
                                    ? Icon(LucideIcons.check, size: 14, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
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
                                    Text(
                                      exercise.muscleGroupName,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    })),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // Bottom Action
          if (_selectedExercises.isNotEmpty)
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: FilledButton.icon(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    widget.onExercisesSelected(_selectedExercises.toList());
                  },
                  icon: Icon(LucideIcons.plus, size: 18),
                  label: Text('Adicionar ${_selectedExercises.length} Exercícios'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
