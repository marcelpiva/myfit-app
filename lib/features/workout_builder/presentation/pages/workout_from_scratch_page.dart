import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';

/// Page for creating a workout from scratch with manual exercise selection
class WorkoutFromScratchPage extends ConsumerStatefulWidget {
  const WorkoutFromScratchPage({super.key});

  @override
  ConsumerState<WorkoutFromScratchPage> createState() => _WorkoutFromScratchPageState();
}

class _WorkoutFromScratchPageState extends ConsumerState<WorkoutFromScratchPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<_Exercise> _exercises = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addExercise() {
    HapticUtils.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddExerciseSheet(
        onAdd: (exercise) {
          setState(() {
            _exercises.add(exercise);
          });
        },
      ),
    );
  }

  void _editExercise(int index) {
    HapticUtils.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditExerciseSheet(
        exercise: _exercises[index],
        onSave: (exercise) {
          setState(() {
            _exercises[index] = exercise;
          });
        },
      ),
    );
  }

  void _removeExercise(int index) {
    HapticUtils.lightImpact();
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _saveWorkout() {
    if (_nameController.text.isEmpty) {
      HapticUtils.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um nome para o treino', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    if (_exercises.isEmpty) {
      HapticUtils.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um exercicio ao treino', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    HapticUtils.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Treino salvo com sucesso!', style: const TextStyle(color: Colors.white)),
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
                      // Workout Name Input
                      FadeInUp(
                        child: _buildNameSection(theme, isDark),
                      ),

                      const SizedBox(height: 24),

                      // Description Input
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: _buildDescriptionSection(theme, isDark),
                      ),

                      const SizedBox(height: 24),

                      // Exercises Header
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Exercicios (${_exercises.length})',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              ),
                            ),
                            if (_exercises.isNotEmpty)
                              Text(
                                'Arraste para reordenar',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Exercise List (Draggable)
                      if (_exercises.isEmpty)
                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: _buildEmptyExerciseState(theme, isDark),
                        )
                      else
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _exercises.length,
                          onReorder: (oldIndex, newIndex) {
                            HapticUtils.selectionClick();
                            setState(() {
                              if (newIndex > oldIndex) newIndex--;
                              final item = _exercises.removeAt(oldIndex);
                              _exercises.insert(newIndex, item);
                            });
                          },
                          itemBuilder: (context, index) {
                            return FadeInUp(
                              key: ValueKey(_exercises[index].id),
                              delay: Duration(milliseconds: 300 + (index * 50)),
                              child: _buildExerciseCard(theme, isDark, _exercises[index], index),
                            );
                          },
                        ),

                      const SizedBox(height: 16),

                      // Add Exercise Button
                      FadeInUp(
                        delay: Duration(milliseconds: 350 + (_exercises.length * 50)),
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
            child: Text(
              'Criar Treino do Zero',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection(ThemeData theme, bool isDark) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.dumbbell,
                size: 18,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Nome do Treino',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            style: TextStyle(
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: Treino A - Peito e Triceps',
              hintStyle: TextStyle(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.mutedDark.withAlpha(100)
                  : AppColors.muted.withAlpha(150),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeData theme, bool isDark) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.fileText,
                size: 18,
                color: isDark ? AppColors.secondaryDark : AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Descricao (opcional)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            style: TextStyle(
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
            decoration: InputDecoration(
              hintText: 'Descreva o objetivo do treino...',
              hintStyle: TextStyle(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.mutedDark.withAlpha(100)
                  : AppColors.muted.withAlpha(150),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyExerciseState(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(100)
            : AppColors.card.withAlpha(150),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.listPlus,
            size: 48,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum exercicio adicionado',
            style: theme.textTheme.titleSmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione exercicios para montar seu treino',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ThemeData theme, bool isDark, _Exercise exercise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header with drag handle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.mutedDark.withAlpha(100)
                  : AppColors.muted.withAlpha(150),
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
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
                const SizedBox(width: 12),
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
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
                  child: Text(
                    exercise.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _editExercise(index),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      LucideIcons.pencil,
                      size: 18,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _removeExercise(index),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      LucideIcons.trash2,
                      size: 18,
                      color: AppColors.destructive,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Exercise details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildExerciseStat(
                  theme,
                  isDark,
                  'Series',
                  '${exercise.sets}',
                  LucideIcons.repeat,
                ),
                const SizedBox(width: 24),
                _buildExerciseStat(
                  theme,
                  isDark,
                  'Reps',
                  exercise.reps,
                  LucideIcons.hash,
                ),
                const SizedBox(width: 24),
                _buildExerciseStat(
                  theme,
                  isDark,
                  'Descanso',
                  '${exercise.restSeconds}s',
                  LucideIcons.timer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseStat(
    ThemeData theme,
    bool isDark,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildAddExerciseButton(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: _addExercise,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(26),
          border: Border.all(
            color: (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(128),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.plus,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Adicionar Exercicio',
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDark ? AppColors.primaryDark : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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
              child: OutlinedButton(
                onPressed: () {
                  HapticUtils.lightImpact();
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _saveWorkout,
                icon: Icon(LucideIcons.save, size: 18),
                label: const Text('Salvar Treino'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                  foregroundColor: Colors.white,
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
    );
  }
}

/// Exercise model for workout creation
class _Exercise {
  final String id;
  final String name;
  final int sets;
  final String reps;
  final int restSeconds;

  _Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
  });

  _Exercise copyWith({
    String? name,
    int? sets,
    String? reps,
    int? restSeconds,
  }) {
    return _Exercise(
      id: id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }
}

/// Bottom sheet for adding a new exercise
class _AddExerciseSheet extends StatefulWidget {
  final Function(_Exercise) onAdd;

  const _AddExerciseSheet({required this.onAdd});

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  final _nameController = TextEditingController();
  int _sets = 3;
  final _repsController = TextEditingController(text: '10-12');
  int _restSeconds = 60;

  final List<String> _suggestedExercises = [
    'Supino Reto',
    'Supino Inclinado',
    'Crucifixo',
    'Desenvolvimento',
    'Elevacao Lateral',
    'Triceps Pulley',
    'Triceps Frances',
    'Rosca Direta',
    'Rosca Martelo',
    'Puxada Frontal',
    'Remada Curvada',
    'Remada Baixa',
    'Agachamento',
    'Leg Press',
    'Cadeira Extensora',
    'Mesa Flexora',
    'Panturrilha',
    'Abdominal',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _addExercise() {
    if (_nameController.text.isEmpty) {
      HapticUtils.heavyImpact();
      return;
    }

    HapticUtils.mediumImpact();
    widget.onAdd(_Exercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      sets: _sets,
      reps: _repsController.text,
      restSeconds: _restSeconds,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
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
              color: isDark ? AppColors.borderDark : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adicionar Exercicio',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Icon(
                    LucideIcons.x,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise Name
                  Text(
                    'Nome do Exercicio',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Digite o nome do exercicio',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                      prefixIcon: Icon(
                        LucideIcons.search,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.mutedDark.withAlpha(100)
                          : AppColors.muted.withAlpha(150),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Suggested Exercises
                  Text(
                    'Sugestoes',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestedExercises.map((exercise) {
                      return GestureDetector(
                        onTap: () {
                          HapticUtils.selectionClick();
                          _nameController.text = exercise;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark.withAlpha(150)
                                : AppColors.card.withAlpha(200),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            exercise,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Sets
                  Text(
                    'Series',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticUtils.selectionClick();
                          if (_sets > 1) setState(() => _sets--);
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
                            LucideIcons.minus,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_sets',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          HapticUtils.selectionClick();
                          setState(() => _sets++);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.plus,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Reps
                  Text(
                    'Repeticoes',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _repsController,
                    style: TextStyle(
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ex: 10-12, 15, AMRAP',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.mutedDark.withAlpha(100)
                          : AppColors.muted.withAlpha(150),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Rest Time
                  Text(
                    'Tempo de Descanso',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _restSeconds.toDouble(),
                    min: 30,
                    max: 180,
                    divisions: 10,
                    activeColor: isDark ? AppColors.primaryDark : AppColors.primary,
                    inactiveColor: isDark ? AppColors.borderDark : AppColors.border,
                    label: '${_restSeconds}s',
                    onChanged: (value) {
                      HapticUtils.selectionClick();
                      setState(() => _restSeconds = value.toInt());
                    },
                  ),
                  Center(
                    child: Text(
                      '$_restSeconds segundos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addExercise,
                      icon: Icon(LucideIcons.plus, size: 18),
                      label: const Text('Adicionar Exercicio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                        foregroundColor: Colors.white,
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
}

/// Bottom sheet for editing an existing exercise
class _EditExerciseSheet extends StatefulWidget {
  final _Exercise exercise;
  final Function(_Exercise) onSave;

  const _EditExerciseSheet({
    required this.exercise,
    required this.onSave,
  });

  @override
  State<_EditExerciseSheet> createState() => _EditExerciseSheetState();
}

class _EditExerciseSheetState extends State<_EditExerciseSheet> {
  late TextEditingController _nameController;
  late int _sets;
  late TextEditingController _repsController;
  late int _restSeconds;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.name);
    _sets = widget.exercise.sets;
    _repsController = TextEditingController(text: widget.exercise.reps);
    _restSeconds = widget.exercise.restSeconds;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _saveExercise() {
    if (_nameController.text.isEmpty) {
      HapticUtils.heavyImpact();
      return;
    }

    HapticUtils.mediumImpact();
    widget.onSave(widget.exercise.copyWith(
      name: _nameController.text,
      sets: _sets,
      reps: _repsController.text,
      restSeconds: _restSeconds,
    ));
    Navigator.pop(context);
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
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            const SizedBox(height: 24),

            // Title
            Text(
              'Editar Exercicio',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 24),

            // Name
            Text(
              'Nome',
              style: theme.textTheme.labelLarge?.copyWith(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? AppColors.mutedDark.withAlpha(100)
                    : AppColors.muted.withAlpha(150),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Sets
            Text(
              'Series',
              style: theme.textTheme.labelLarge?.copyWith(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticUtils.selectionClick();
                    if (_sets > 1) setState(() => _sets--);
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
                      LucideIcons.minus,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$_sets',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    HapticUtils.selectionClick();
                    setState(() => _sets++);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.plus,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Reps
            Text(
              'Repeticoes',
              style: theme.textTheme.labelLarge?.copyWith(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _repsController,
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
              decoration: InputDecoration(
                hintText: 'Ex: 10-12, 15, AMRAP',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.mutedDark.withAlpha(100)
                    : AppColors.muted.withAlpha(150),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Rest Time
            Text(
              'Descanso (segundos)',
              style: theme.textTheme.labelLarge?.copyWith(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _restSeconds.toDouble(),
              min: 30,
              max: 180,
              divisions: 10,
              activeColor: isDark ? AppColors.primaryDark : AppColors.primary,
              inactiveColor: isDark ? AppColors.borderDark : AppColors.border,
              label: '${_restSeconds}s',
              onChanged: (value) {
                HapticUtils.selectionClick();
                setState(() => _restSeconds = value.toInt());
              },
            ),
            Center(
              child: Text(
                '$_restSeconds segundos',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Salvar Alteracoes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
