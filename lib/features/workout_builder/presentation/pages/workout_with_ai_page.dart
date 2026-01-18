import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../../workout/presentation/providers/workout_provider.dart';

/// Page for creating a workout with AI assistance
class WorkoutWithAIPage extends ConsumerStatefulWidget {
  const WorkoutWithAIPage({super.key});

  @override
  ConsumerState<WorkoutWithAIPage> createState() => _WorkoutWithAIPageState();
}

class _WorkoutWithAIPageState extends ConsumerState<WorkoutWithAIPage> {
  // Goal selection
  String? _selectedGoal;
  final List<_GoalOption> _goals = [
    _GoalOption(
      id: 'hipertrofia',
      title: 'Hipertrofia',
      subtitle: 'Ganho de massa muscular',
      icon: LucideIcons.dumbbell,
    ),
    _GoalOption(
      id: 'emagrecimento',
      title: 'Emagrecimento',
      subtitle: 'Perda de gordura',
      icon: LucideIcons.flame,
    ),
    _GoalOption(
      id: 'forca',
      title: 'Forca',
      subtitle: 'Aumento de carga',
      icon: LucideIcons.zap,
    ),
    _GoalOption(
      id: 'resistencia',
      title: 'Resistencia',
      subtitle: 'Condicionamento fisico',
      icon: LucideIcons.heart,
    ),
  ];

  // Muscle groups selection
  final Set<String> _selectedMuscleGroups = {};
  final List<_MuscleGroupOption> _muscleGroups = [
    _MuscleGroupOption(id: 'peito', name: 'Peito', icon: LucideIcons.heart),
    _MuscleGroupOption(id: 'costas', name: 'Costas', icon: LucideIcons.arrowUpDown),
    _MuscleGroupOption(id: 'ombros', name: 'Ombros', icon: LucideIcons.mountain),
    _MuscleGroupOption(id: 'biceps', name: 'Biceps', icon: LucideIcons.armchair),
    _MuscleGroupOption(id: 'triceps', name: 'Triceps', icon: LucideIcons.armchair),
    _MuscleGroupOption(id: 'pernas', name: 'Pernas', icon: LucideIcons.footprints),
    _MuscleGroupOption(id: 'gluteos', name: 'Gluteos', icon: LucideIcons.circle),
    _MuscleGroupOption(id: 'abdomen', name: 'Abdomen', icon: LucideIcons.alignCenter),
  ];

  // Duration preference
  int _selectedDuration = 45;
  final List<int> _durations = [30, 45, 60];

  // Equipment available
  String? _selectedEquipment;
  final List<_EquipmentOption> _equipments = [
    _EquipmentOption(
      id: 'academia_completa',
      title: 'Academia Completa',
      subtitle: 'Todos os equipamentos',
      icon: LucideIcons.building,
    ),
    _EquipmentOption(
      id: 'casa',
      title: 'Treino em Casa',
      subtitle: 'Halteres e elasticos',
      icon: LucideIcons.home,
    ),
    _EquipmentOption(
      id: 'peso_corporal',
      title: 'Peso Corporal',
      subtitle: 'Sem equipamentos',
      icon: LucideIcons.user,
    ),
  ];

  // Generated workout state
  bool _isGenerating = false;
  _GeneratedWorkout? _generatedWorkout;

  bool get _canGenerate =>
      _selectedGoal != null &&
      _selectedMuscleGroups.isNotEmpty &&
      _selectedEquipment != null;

  void _generateWorkout() async {
    if (!_canGenerate) {
      HapticUtils.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todas as opcoes para gerar o treino', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    HapticUtils.mediumImpact();
    setState(() {
      _isGenerating = true;
    });

    // Simulate AI generation delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isGenerating = false;
      _generatedWorkout = _generateMockWorkout();
    });
  }

  _GeneratedWorkout _generateMockWorkout() {
    // Generate mock workout based on selections
    final exercises = <_GeneratedExercise>[];
    final muscleList = _selectedMuscleGroups.toList();

    for (final muscle in muscleList) {
      exercises.addAll(_getExercisesForMuscle(muscle));
    }

    return _GeneratedWorkout(
      name: 'Treino ${_getGoalName()} - ${_selectedDuration}min',
      description: 'Treino gerado por IA focado em ${_getGoalName().toLowerCase()} para ${muscleList.join(", ")}.',
      duration: _selectedDuration,
      exercises: exercises,
    );
  }

  String _getGoalName() {
    switch (_selectedGoal) {
      case 'hipertrofia':
        return 'Hipertrofia';
      case 'emagrecimento':
        return 'Emagrecimento';
      case 'forca':
        return 'Forca';
      case 'resistencia':
        return 'Resistencia';
      default:
        return '';
    }
  }

  List<_GeneratedExercise> _getExercisesForMuscle(String muscle) {
    final isStrength = _selectedGoal == 'forca';
    final isEndurance = _selectedGoal == 'resistencia';
    final sets = isStrength ? 5 : (isEndurance ? 3 : 4);
    final reps = isStrength ? '5' : (isEndurance ? '15-20' : '10-12');
    final rest = isStrength ? 120 : (isEndurance ? 45 : 60);

    switch (muscle) {
      case 'peito':
        return [
          _GeneratedExercise(name: 'Supino Reto', sets: sets, reps: reps, rest: rest),
          _GeneratedExercise(name: 'Supino Inclinado', sets: sets, reps: reps, rest: rest),
        ];
      case 'costas':
        return [
          _GeneratedExercise(name: 'Puxada Frontal', sets: sets, reps: reps, rest: rest),
          _GeneratedExercise(name: 'Remada Curvada', sets: sets, reps: reps, rest: rest),
        ];
      case 'ombros':
        return [
          _GeneratedExercise(name: 'Desenvolvimento', sets: sets, reps: reps, rest: rest),
          _GeneratedExercise(name: 'Elevacao Lateral', sets: sets, reps: reps, rest: rest),
        ];
      case 'biceps':
        return [
          _GeneratedExercise(name: 'Rosca Direta', sets: sets, reps: reps, rest: rest),
        ];
      case 'triceps':
        return [
          _GeneratedExercise(name: 'Triceps Pulley', sets: sets, reps: reps, rest: rest),
        ];
      case 'pernas':
        return [
          _GeneratedExercise(name: 'Agachamento', sets: sets, reps: reps, rest: rest),
          _GeneratedExercise(name: 'Leg Press', sets: sets, reps: reps, rest: rest),
        ];
      case 'gluteos':
        return [
          _GeneratedExercise(name: 'Hip Thrust', sets: sets, reps: reps, rest: rest),
        ];
      case 'abdomen':
        return [
          _GeneratedExercise(name: 'Abdominal', sets: 3, reps: '15-20', rest: 30),
        ];
      default:
        return [];
    }
  }

  bool _isSaving = false;

  Future<void> _saveWorkout() async {
    if (_generatedWorkout == null || _isSaving) return;

    HapticUtils.mediumImpact();
    setState(() {
      _isSaving = true;
    });

    try {
      final workout = _generatedWorkout!;

      // Create workout via API
      await ref.read(workoutsNotifierProvider.notifier).createWorkout(
        name: workout.name,
        description: workout.description,
        difficulty: _selectedGoal == 'forca' ? 'advanced' : (_selectedGoal == 'hipertrofia' ? 'intermediate' : 'beginner'),
        estimatedDuration: workout.duration,
        muscleGroups: _selectedMuscleGroups.toList(),
      );

      // Get the created workout
      final workouts = ref.read(workoutsProvider);
      if (workouts.isNotEmpty) {
        final createdWorkout = workouts.first;
        final workoutId = createdWorkout['id']?.toString();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Treino criado com sucesso!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
            ),
          );

          // Navigate to the created workout detail page
          if (workoutId != null && workoutId.isNotEmpty) {
            context.go('/workouts/$workoutId');
          } else {
            context.pop();
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Treino criado! Volte para a lista de treinos para visualizar.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao criar treino: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _resetGeneration() {
    HapticUtils.lightImpact();
    setState(() {
      _generatedWorkout = null;
    });
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
                child: _generatedWorkout != null
                    ? _buildGeneratedWorkoutView(theme, isDark)
                    : _buildConfigurationView(theme, isDark),
              ),
            ],
          ),
        ),
      ),
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
                  LucideIcons.sparkles,
                  size: 20,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Treino com IA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
          if (_generatedWorkout != null)
            GestureDetector(
              onTap: _resetGeneration,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDark.withAlpha(150)
                      : AppColors.card.withAlpha(200),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.refreshCw,
                      size: 14,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Refazer',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
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

  Widget _buildConfigurationView(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal Selection
          FadeInUp(
            child: _buildSectionTitle(theme, isDark, 'Qual seu objetivo?', LucideIcons.target),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 50),
            child: _buildGoalSelection(theme, isDark),
          ),

          const SizedBox(height: 24),

          // Muscle Groups Selection
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: _buildSectionTitle(theme, isDark, 'Grupos musculares', LucideIcons.activity),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            child: _buildMuscleGroupsSelection(theme, isDark),
          ),

          const SizedBox(height: 24),

          // Duration Selection
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildSectionTitle(theme, isDark, 'Duracao do treino', LucideIcons.clock),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 250),
            child: _buildDurationSelection(theme, isDark),
          ),

          const SizedBox(height: 24),

          // Equipment Selection
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildSectionTitle(theme, isDark, 'Equipamentos disponiveis', LucideIcons.wrench),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 350),
            child: _buildEquipmentSelection(theme, isDark),
          ),

          const SizedBox(height: 32),

          // Generate Button
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildGenerateButton(theme, isDark),
          ),

          const SizedBox(height: 100),
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

  Widget _buildGoalSelection(ThemeData theme, bool isDark) {
    return Column(
      children: _goals.map((goal) {
        final isSelected = _selectedGoal == goal.id;
        return GestureDetector(
          onTap: () {
            HapticUtils.selectionClick();
            setState(() {
              _selectedGoal = goal.id;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
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
                    color: isSelected
                        ? (isDark ? AppColors.primaryDark : AppColors.primary)
                        : isDark
                            ? AppColors.mutedDark
                            : AppColors.muted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    goal.icon,
                    size: 20,
                    color: isSelected
                        ? Colors.white
                        : isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      Text(
                        goal.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    LucideIcons.checkCircle,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMuscleGroupsSelection(ThemeData theme, bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _muscleGroups.map((muscle) {
        final isSelected = _selectedMuscleGroups.contains(muscle.id);
        return GestureDetector(
          onTap: () {
            HapticUtils.selectionClick();
            setState(() {
              if (isSelected) {
                _selectedMuscleGroups.remove(muscle.id);
              } else {
                _selectedMuscleGroups.add(muscle.id);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  muscle.icon,
                  size: 16,
                  color: isSelected
                      ? (isDark ? AppColors.primaryDark : AppColors.primary)
                      : isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                ),
                const SizedBox(width: 8),
                Text(
                  muscle.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? (isDark ? AppColors.primaryDark : AppColors.primary)
                        : isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationSelection(ThemeData theme, bool isDark) {
    return Row(
      children: _durations.map((duration) {
        final isSelected = _selectedDuration == duration;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticUtils.selectionClick();
              setState(() {
                _selectedDuration = duration;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: duration != _durations.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.primaryDark : AppColors.primary)
                    : isDark
                        ? AppColors.cardDark.withAlpha(150)
                        : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.primaryDark : AppColors.primary)
                      : isDark
                          ? AppColors.borderDark
                          : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '$duration',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                    ),
                  ),
                  Text(
                    'min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? Colors.white.withAlpha(204)
                          : isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEquipmentSelection(ThemeData theme, bool isDark) {
    return Column(
      children: _equipments.map((equipment) {
        final isSelected = _selectedEquipment == equipment.id;
        return GestureDetector(
          onTap: () {
            HapticUtils.selectionClick();
            setState(() {
              _selectedEquipment = equipment.id;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
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
                    color: isSelected
                        ? (isDark ? AppColors.primaryDark : AppColors.primary)
                        : isDark
                            ? AppColors.mutedDark
                            : AppColors.muted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    equipment.icon,
                    size: 20,
                    color: isSelected
                        ? Colors.white
                        : isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      Text(
                        equipment.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    LucideIcons.checkCircle,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenerateButton(ThemeData theme, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isGenerating ? null : _generateWorkout,
        icon: _isGenerating
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(LucideIcons.sparkles, size: 18),
        label: Text(_isGenerating ? 'Gerando treino...' : 'Gerar Treino com IA'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _canGenerate
              ? (isDark ? AppColors.primaryDark : AppColors.primary)
              : isDark
                  ? AppColors.mutedDark
                  : AppColors.muted,
          foregroundColor: _canGenerate
              ? Colors.white
              : isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratedWorkoutView(ThemeData theme, bool isDark) {
    final workout = _generatedWorkout!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success Header
                FadeInUp(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(26),
                          (isDark ? AppColors.secondaryDark : AppColors.secondary).withAlpha(26),
                        ],
                      ),
                      border: Border.all(
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.sparkles,
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
                                'Treino Gerado!',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                ),
                              ),
                              Text(
                                'Revise e edite antes de salvar',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Workout Info
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
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
                        Text(
                          workout.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          workout.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildWorkoutStat(
                              theme,
                              isDark,
                              '${workout.exercises.length}',
                              'exercicios',
                              LucideIcons.dumbbell,
                            ),
                            const SizedBox(width: 24),
                            _buildWorkoutStat(
                              theme,
                              isDark,
                              '${workout.duration}',
                              'minutos',
                              LucideIcons.clock,
                            ),
                            const SizedBox(width: 24),
                            _buildWorkoutStat(
                              theme,
                              isDark,
                              '${workout.exercises.fold(0, (sum, e) => sum + e.sets)}',
                              'series',
                              LucideIcons.repeat,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Exercises
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Exercicios',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ...workout.exercises.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exercise = entry.value;
                  return FadeInUp(
                    delay: Duration(milliseconds: 250 + (index * 50)),
                    child: _buildExercisePreviewCard(theme, isDark, exercise, index),
                  );
                }),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // Bottom Actions
        Container(
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
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticUtils.lightImpact();
                      final workout = _generatedWorkout!;
                      context.push(
                        '/workouts/from-scratch',
                        extra: {
                          'name': workout.name,
                          'description': workout.description,
                          'duration': workout.duration,
                          'exercises': workout.exercises.map((e) => {
                            'name': e.name,
                            'sets': e.sets,
                            'reps': e.reps,
                            'rest': e.rest,
                          }).toList(),
                        },
                      );
                    },
                    icon: Icon(LucideIcons.pencil, size: 18),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveWorkout,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(LucideIcons.save, size: 18),
                    label: Text(_isSaving ? 'Salvando...' : 'Salvar Treino'),
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
    );
  }

  Widget _buildWorkoutStat(
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

  Widget _buildExercisePreviewCard(
    ThemeData theme,
    bool isDark,
    _GeneratedExercise exercise,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
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
          Text(
            '${exercise.sets}x${exercise.reps}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${exercise.rest}s',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Goal option model
class _GoalOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  _GoalOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// Muscle group option model
class _MuscleGroupOption {
  final String id;
  final String name;
  final IconData icon;

  _MuscleGroupOption({
    required this.id,
    required this.name,
    required this.icon,
  });
}

/// Equipment option model
class _EquipmentOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  _EquipmentOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// Generated workout model
class _GeneratedWorkout {
  final String name;
  final String description;
  final int duration;
  final List<_GeneratedExercise> exercises;

  _GeneratedWorkout({
    required this.name,
    required this.description,
    required this.duration,
    required this.exercises,
  });
}

/// Generated exercise model
class _GeneratedExercise {
  final String name;
  final int sets;
  final String reps;
  final int rest;

  _GeneratedExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
  });
}
