import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/workout_service.dart';
import '../../domain/models/exercise.dart';
import '../providers/exercise_catalog_provider.dart';

/// Page for creating a new exercise
class ExerciseFormPage extends ConsumerStatefulWidget {
  const ExerciseFormPage({super.key});

  @override
  ConsumerState<ExerciseFormPage> createState() => _ExerciseFormPageState();
}

class _ExerciseFormPageState extends ConsumerState<ExerciseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _videoUrlController = TextEditingController();

  MuscleGroup _selectedMuscleGroup = MuscleGroup.chest;
  EquipmentType? _selectedEquipment;
  String _selectedDifficulty = 'intermediate';
  bool _isSaving = false;

  final _muscleGroups = [
    (MuscleGroup.chest, 'Peito'),
    (MuscleGroup.back, 'Costas'),
    (MuscleGroup.shoulders, 'Ombros'),
    (MuscleGroup.biceps, 'Bíceps'),
    (MuscleGroup.triceps, 'Tríceps'),
    (MuscleGroup.legs, 'Pernas'),
    (MuscleGroup.glutes, 'Glúteos'),
    (MuscleGroup.abs, 'Abdômen'),
    (MuscleGroup.cardio, 'Cardio'),
    (MuscleGroup.fullBody, 'Corpo Inteiro'),
  ];

  final _equipments = [
    (null, 'Nenhum'),
    (EquipmentType.barbell, 'Barra'),
    (EquipmentType.dumbbell, 'Halteres'),
    (EquipmentType.cable, 'Cabo'),
    (EquipmentType.machine, 'Máquina'),
    (EquipmentType.bodyweight, 'Peso Corporal'),
    (EquipmentType.kettlebell, 'Kettlebell'),
    (EquipmentType.bands, 'Elásticos'),
    (EquipmentType.other, 'Outro'),
  ];

  final _difficulties = [
    ('beginner', 'Iniciante'),
    ('intermediate', 'Intermediário'),
    ('advanced', 'Avançado'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final workoutService = WorkoutService();
      await workoutService.createExercise(
        name: _nameController.text.trim(),
        muscleGroup: _selectedMuscleGroup.name,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        equipment: _selectedEquipment?.name,
        difficulty: _selectedDifficulty,
        videoUrl: _videoUrlController.text.trim().isEmpty
            ? null
            : _videoUrlController.text.trim(),
        instructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
      );

      // Invalidate the exercises cache to reload with the new exercise
      ref.invalidate(exerciseCatalogProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercício criado com sucesso!')),
        );
        context.pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar exercício: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                          color: (isDark ? AppColors.cardDark : AppColors.card)
                              .withAlpha(isDark ? 150 : 200),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.arrowLeft,
                          size: 20,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Novo Exercício',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      _buildSection(
                        theme,
                        isDark,
                        'Informações Básicas',
                        Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Nome do Exercício *',
                                hintText: 'Ex: Supino Reto',
                                prefixIcon: Icon(LucideIcons.dumbbell),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nome é obrigatório';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Descrição (opcional)',
                                hintText: 'Descreva o exercício...',
                                prefixIcon: Icon(LucideIcons.alignLeft),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Muscle Group Selection
                      _buildSection(
                        theme,
                        isDark,
                        'Grupo Muscular *',
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _muscleGroups.map((item) {
                            final isSelected =
                                _selectedMuscleGroup == item.$1;
                            return FilterChip(
                              label: Text(item.$2),
                              selected: isSelected,
                              onSelected: (_) {
                                HapticUtils.selectionClick();
                                setState(() => _selectedMuscleGroup = item.$1);
                              },
                              selectedColor: AppColors.primary.withAlpha(50),
                              checkmarkColor: AppColors.primary,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Equipment Selection
                      _buildSection(
                        theme,
                        isDark,
                        'Equipamento',
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _equipments.map((item) {
                            final isSelected = _selectedEquipment == item.$1;
                            return FilterChip(
                              label: Text(item.$2),
                              selected: isSelected,
                              onSelected: (_) {
                                HapticUtils.selectionClick();
                                setState(() => _selectedEquipment = item.$1);
                              },
                              selectedColor: AppColors.secondary.withAlpha(50),
                              checkmarkColor: AppColors.secondary,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Difficulty Selection
                      _buildSection(
                        theme,
                        isDark,
                        'Dificuldade',
                        Row(
                          children: _difficulties.map((item) {
                            final isSelected = _selectedDifficulty == item.$1;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: item != _difficulties.last ? 8 : 0,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    HapticUtils.selectionClick();
                                    setState(
                                        () => _selectedDifficulty = item.$1);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isDark
                                              ? theme.colorScheme
                                                  .surfaceContainerLow
                                                  .withAlpha(150)
                                              : theme.colorScheme
                                                  .surfaceContainerLow
                                                  .withAlpha(200)),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : theme.colorScheme.outline
                                                .withValues(alpha: 0.2),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.$2,
                                        style:
                                            theme.textTheme.labelLarge?.copyWith(
                                          color: isSelected
                                              ? Colors.white
                                              : theme.colorScheme.onSurface,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Instructions
                      _buildSection(
                        theme,
                        isDark,
                        'Instruções de Execução',
                        TextFormField(
                          controller: _instructionsController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                '1. Deite no banco...\n2. Segure a barra...\n3. Desça controladamente...',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(bottom: 72),
                              child: Icon(LucideIcons.listOrdered),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Video URL
                      _buildSection(
                        theme,
                        isDark,
                        'Vídeo Demonstrativo',
                        TextFormField(
                          controller: _videoUrlController,
                          decoration: InputDecoration(
                            labelText: 'URL do Vídeo (opcional)',
                            hintText: 'https://youtube.com/...',
                            prefixIcon: Icon(LucideIcons.video),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.url,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
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
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    context.pop();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveExercise,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(LucideIcons.save, size: 18),
                  label: const Text('Criar Exercício'),
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
    );
  }

  Widget _buildSection(
    ThemeData theme,
    bool isDark,
    String title,
    Widget child,
  ) {
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
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
