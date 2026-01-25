import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/exercise_theme.dart';
import '../../../workout_builder/domain/models/exercise.dart';
import '../../domain/models/training_plan.dart';

/// Modal for selecting a training technique before adding exercises.
/// Uses internal state to switch between views instead of multiple modals.
class TechniqueSelectionModal extends StatefulWidget {
  final Function(TechniqueType) onTechniqueSelected;
  final VoidCallback onSimpleExercise;
  final VoidCallback? onAerobicExercise;
  final VoidCallback? onStretchingExercise;
  final List<String> muscleGroups;

  const TechniqueSelectionModal({
    super.key,
    required this.onTechniqueSelected,
    required this.onSimpleExercise,
    this.onAerobicExercise,
    this.onStretchingExercise,
    this.muscleGroups = const [],
  });

  @override
  State<TechniqueSelectionModal> createState() => _TechniqueSelectionModalState();
}

class _TechniqueSelectionModalState extends State<TechniqueSelectionModal> {
  bool _showTechniqueTypes = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _showTechniqueTypes
              ? _buildTechniqueTypesView(theme)
              : _buildInitialOptionsView(theme),
        ),
      ),
    );
  }

  Widget _buildInitialOptionsView(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle
        _buildHandle(theme),

        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adicionar Exercício',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Escolha como deseja adicionar',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

        const Divider(height: 1),

        // Option 1: Aerobic Exercise
        if (widget.onAerobicExercise != null)
          _OptionTile(
            icon: LucideIcons.heartPulse,
            iconColor: const Color(0xFFEF4444), // Red (cardio color)
            title: 'Aeróbico',
            subtitle: 'Exercícios cardiovasculares como corrida, bike e HIIT',
            onTap: () {
              HapticUtils.selectionClick();
              Navigator.pop(context);
              widget.onAerobicExercise!();
            },
            isDark: isDark,
          ),

        if (widget.onAerobicExercise != null)
          const Divider(height: 1, indent: 72),

        // Option 2: Stretching Exercise
        if (widget.onStretchingExercise != null)
          _OptionTile(
            icon: LucideIcons.move,
            iconColor: const Color(0xFF8B5CF6), // Violet
            title: 'Alongamento',
            subtitle: 'Exercícios de flexibilidade com tempo de manutenção',
            onTap: () {
              HapticUtils.selectionClick();
              Navigator.pop(context);
              widget.onStretchingExercise!();
            },
            isDark: isDark,
          ),

        if (widget.onStretchingExercise != null)
          const Divider(height: 1, indent: 72),

        // Option 2: Simple Exercise (renamed to "Exercício")
        _OptionTile(
          icon: LucideIcons.dumbbell,
          iconColor: AppColors.primary,
          title: 'Exercício',
          subtitle: 'Adicionar um exercício individual com séries e repetições',
          onTap: () {
            HapticUtils.selectionClick();
            Navigator.pop(context);
            widget.onSimpleExercise();
          },
          isDark: isDark,
        ),

        const Divider(height: 1, indent: 72),

        // Option 3: Advanced Technique
        _OptionTile(
          icon: LucideIcons.layers,
          iconColor: AppColors.warning,
          title: 'Técnica Avançada',
          subtitle: 'Bi-Set, Tri-Set, Drop Set, Rest Pause...',
          onTap: () {
            HapticUtils.selectionClick();
            setState(() {
              _showTechniqueTypes = true;
            });
          },
          isDark: isDark,
          showArrow: true,
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTechniqueTypesView(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    // Check if Super-Set is available (workout has antagonist muscle pairs)
    // Only show Super-Set if workout has defined muscle groups with antagonist pairs
    final hasAntagonists = widget.muscleGroups.isNotEmpty &&
        MuscleGroupTechniqueDetector.hasAntagonistPairsFromStrings(widget.muscleGroups);

    // Group techniques: Multi-exercise vs Single-exercise
    // Filter out Super-Set if no antagonist pairs are available
    final multiExerciseTechniques = [
      if (hasAntagonists) TechniqueType.superset, // 2 exercises, opposite groups
      TechniqueType.biset,    // 2 exercises, same area
      TechniqueType.triset,   // 3 exercises
      TechniqueType.giantset, // 4+ exercises
    ];

    final singleExerciseTechniques = [
      TechniqueType.dropset,
      TechniqueType.restPause,
      TechniqueType.cluster,
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          _buildHandle(theme),

          // Header with back button
          Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  HapticUtils.selectionClick();
                  setState(() {
                    _showTechniqueTypes = false;
                  });
                },
                icon: const Icon(LucideIcons.arrowLeft),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Selecionar Técnica',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.x),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Multi-exercise techniques section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'MÚLTIPLOS EXERCÍCIOS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),

        ...multiExerciseTechniques.map((technique) => _TechniqueCard(
              technique: technique,
              onTap: () {
                HapticUtils.selectionClick();
                Navigator.pop(context);
                widget.onTechniqueSelected(technique);
              },
              isDark: isDark,
            )),

        // Single-exercise techniques section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'EXERCÍCIO ÚNICO',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),

        ...singleExerciseTechniques.map((technique) => _TechniqueCard(
              technique: technique,
              onTap: () {
                HapticUtils.selectionClick();
                Navigator.pop(context);
                widget.onTechniqueSelected(technique);
              },
              isDark: isDark,
            )),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final bool showArrow;

  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                LucideIcons.chevronRight,
                color: theme.colorScheme.outline,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  final TechniqueType technique;
  final VoidCallback onTap;
  final bool isDark;

  const _TechniqueCard({
    required this.technique,
    required this.onTap,
    required this.isDark,
  });

  Color get _techniqueColor => ExerciseTheme.getColor(technique);

  IconData get _techniqueIcon => ExerciseTheme.getIcon(technique);

  String get _displayName => technique.displayName;

  String get _description => technique.description;

  String get _exerciseCountHint {
    return switch (technique) {
      TechniqueType.biset => '2 exercícios',
      TechniqueType.superset => '2 exercícios',
      TechniqueType.triset => '3 exercícios',
      TechniqueType.giantset => '4+ exercícios',
      _ => '1 exercício',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _techniqueColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_techniqueIcon, color: _techniqueColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _techniqueColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _exerciseCountHint,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _techniqueColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: theme.colorScheme.outline,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
