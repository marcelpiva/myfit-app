import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/models/workout_program.dart';
import '../providers/program_wizard_provider.dart';

/// Step 2: Program information input
class StepProgramInfo extends ConsumerStatefulWidget {
  const StepProgramInfo({super.key});

  @override
  ConsumerState<StepProgramInfo> createState() => _StepProgramInfoState();
}

class _StepProgramInfoState extends ConsumerState<StepProgramInfo> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(programWizardProvider);
    _nameController.text = state.programName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe um nome para o programa';
    }
    if (value.trim().length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(programWizardProvider);
    final notifier = ref.read(programWizardProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final goals = [
      (WorkoutGoal.hypertrophy, 'Hipertrofia', LucideIcons.dumbbell),
      (WorkoutGoal.strength, 'Forca', LucideIcons.zap),
      (WorkoutGoal.fatLoss, 'Emagrecimento', LucideIcons.flame),
      (WorkoutGoal.endurance, 'Resistencia', LucideIcons.heart),
      (WorkoutGoal.functional, 'Funcional', LucideIcons.activity),
      (WorkoutGoal.generalFitness, 'Condicionamento', LucideIcons.target),
    ];

    final difficulties = [
      (ProgramDifficulty.beginner, 'Iniciante'),
      (ProgramDifficulty.intermediate, 'Intermediario'),
      (ProgramDifficulty.advanced, 'Avancado'),
    ];

    final durations = [
      (null, 'Indefinido'),
      (4, '4 semanas'),
      (8, '8 semanas'),
      (12, '12 semanas'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informacoes do Programa',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure os detalhes basicos do seu programa de treino',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Program Name
          _buildSection(
            theme,
            isDark,
            'Nome do Programa',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  onChanged: (value) {
                    notifier.setProgramName(value);
                  },
                  validator: _validateName,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: 'Ex: Hipertrofia ABC',
                    prefixIcon: const Icon(LucideIcons.fileText),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.colorScheme.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
                    ),
                  ),
                ),
                if (state.programName.isNotEmpty && state.programName.length >= 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.checkCircle,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Nome valido',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            isRequired: true,
          ),
          const SizedBox(height: 24),

          // Goal Selection
          _buildSection(
            theme,
            isDark,
            'Objetivo Principal',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: goals.map((item) {
                final isSelected = state.goal == item.$1;
                return GestureDetector(
                  onTap: () {
                    HapticUtils.selectionClick();
                    notifier.setGoal(item.$1);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha(30)
                          : (isDark
                              ? theme.colorScheme.surfaceContainerLow
                                  .withAlpha(150)
                              : theme.colorScheme.surfaceContainerLow
                                  .withAlpha(200)),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.$3,
                          size: 18,
                          color: isSelected
                              ? AppColors.primary
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.$2,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Difficulty Selection
          _buildSection(
            theme,
            isDark,
            'Nivel de Experiencia',
            Row(
              children: difficulties.map((item) {
                final isSelected = state.difficulty == item.$1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: item != difficulties.last ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.selectionClick();
                        notifier.setDifficulty(item.$1);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? theme.colorScheme.surfaceContainerLow
                                      .withAlpha(150)
                                  : theme.colorScheme.surfaceContainerLow
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
                            style: theme.textTheme.labelLarge?.copyWith(
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

          // Duration Selection
          _buildSection(
            theme,
            isDark,
            'Duracao do Programa (opcional)',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: durations.map((item) {
                final isSelected = state.durationWeeks == item.$1;
                return GestureDetector(
                  onTap: () {
                    HapticUtils.selectionClick();
                    notifier.setDurationWeeks(item.$1);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.secondary.withAlpha(30)
                          : (isDark
                              ? theme.colorScheme.surfaceContainerLow
                                  .withAlpha(150)
                              : theme.colorScheme.surfaceContainerLow
                                  .withAlpha(200)),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.secondary
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.$2,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? AppColors.secondary
                            : theme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    bool isDark,
    String title,
    Widget child, {
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  /// Trigger validation (called from parent when trying to proceed)
  bool validate() {
    return _nameController.text.trim().length >= 3;
  }
}
