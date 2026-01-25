import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/exercise_theme.dart';
import '../../../workout_builder/domain/models/exercise.dart';
import '../../../workout_builder/presentation/providers/exercise_catalog_provider.dart';
import '../../domain/models/training_plan.dart';
import 'technique_config_modal.dart';

/// Exercise picker that supports selecting multiple exercises for techniques
class MultiExercisePicker extends ConsumerStatefulWidget {
  final TechniqueType technique;
  final int requiredCount; // Exact count required (for superset/triset)
  final int? minCount; // Minimum count (for giant set)
  final int? maxCount; // Maximum count
  final List<String> allowedMuscleGroups;
  final TechniqueConfigData? techniqueConfig;
  final Function(List<Exercise>, TechniqueConfigData?) onExercisesSelected;

  const MultiExercisePicker({
    super.key,
    required this.technique,
    required this.requiredCount,
    this.minCount,
    this.maxCount,
    required this.allowedMuscleGroups,
    this.techniqueConfig,
    required this.onExercisesSelected,
  });

  /// Check if filtering is enabled
  bool get hasRestriction => allowedMuscleGroups.isNotEmpty;

  /// Get allowed muscle groups as enum list
  List<MuscleGroup> get allowedGroups =>
      allowedMuscleGroups.map((g) => g.toMuscleGroup()).toList();

  @override
  ConsumerState<MultiExercisePicker> createState() => _MultiExercisePickerState();
}

class _MultiExercisePickerState extends ConsumerState<MultiExercisePicker> {
  final _searchController = TextEditingController();
  MuscleGroup? _selectedMuscleGroup;
  String _searchQuery = '';
  final List<Exercise> _selectedExercises = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color get _techniqueColor => ExerciseTheme.getColor(widget.technique);

  bool get _canConfirm {
    final count = _selectedExercises.length;
    if (widget.minCount != null && widget.maxCount != null) {
      // Range selection (e.g., 2-3 for Bi-Set/Tri-Set)
      return count >= widget.minCount! && count <= widget.maxCount!;
    }
    if (widget.minCount != null) {
      return count >= widget.minCount!;
    }
    return count == widget.requiredCount;
  }

  String get _displayName => widget.technique.displayName;

  /// Check if a muscle group is blocked based on technique type
  /// - Normal: no restrictions, all muscle groups allowed
  /// - Super-Set: blocks SAME group, only allows antagonist
  /// - Bi-Set/Tri-Set/Giant Set: blocks ANTAGONIST groups, only allows same area
  bool _isBlockedMuscleGroup(MuscleGroup group) {
    // If no exercises selected yet, nothing is blocked
    if (_selectedExercises.isEmpty) return false;

    // Normal technique: no muscle group restrictions
    if (widget.technique == TechniqueType.normal) return false;

    final firstSelected = _selectedExercises.first;

    if (widget.technique == TechniqueType.superset) {
      // Super-Set: ONLY allow antagonist muscle group
      // Block everything that is NOT the antagonist
      final antagonist = firstSelected.muscleGroup.antagonist;
      if (antagonist == null) {
        // First exercise has no antagonist, block all others
        return true;
      }
      // Only allow the antagonist group
      return group != antagonist;
    }

    // Bi-Set, Tri-Set, Giant Set: block antagonist muscles, allow same area
    for (final selected in _selectedExercises) {
      if (MuscleGroupTechniqueDetector.isSuperSet(selected.muscleGroup, group)) {
        return true;
      }
    }
    return false;
  }

  /// Get list of blocked muscle groups for validation display
  Set<MuscleGroup> get _blockedMuscleGroups {
    if (_selectedExercises.isEmpty) return {};

    // Normal technique: no blocked groups
    if (widget.technique == TechniqueType.normal) return {};

    final blocked = <MuscleGroup>{};

    if (widget.technique == TechniqueType.superset) {
      // For Super-Set: show which groups are allowed (the antagonist)
      // We don't show blocked, we show what's required
      return {};
    }

    // For Bi-Set/Tri-Set/Giant Set: show blocked antagonist groups
    for (final selected in _selectedExercises) {
      final antagonist = selected.muscleGroup.antagonist;
      if (antagonist != null) {
        blocked.add(antagonist);
      }
    }
    return blocked;
  }

  /// Get the required muscle group for Super-Set (the antagonist)
  MuscleGroup? get _requiredMuscleGroupForSuperset {
    if (widget.technique != TechniqueType.superset) return null;
    if (_selectedExercises.isEmpty) return null;
    return _selectedExercises.first.muscleGroup.antagonist;
  }

  String get _selectionHint {
    if (widget.minCount != null && widget.maxCount != null && widget.minCount != widget.maxCount) {
      // Range display (e.g., "Selecione 2-3 exercícios")
      return 'Selecione ${widget.minCount}-${widget.maxCount} exercícios';
    }
    if (widget.minCount != null) {
      return 'Selecione ${widget.minCount}+ exercícios';
    }
    return 'Selecione ${widget.requiredCount} exercícios';
  }

  String get _selectionStatus {
    final count = _selectedExercises.length;
    if (widget.minCount != null && widget.maxCount != null && widget.minCount != widget.maxCount) {
      // Range status
      if (count < widget.minCount!) {
        return '$count de ${widget.minCount}-${widget.maxCount} selecionados';
      }
      return '$count selecionados (${widget.minCount}-${widget.maxCount})';
    }
    if (widget.minCount != null) {
      if (count < widget.minCount!) {
        return '$count de ${widget.minCount}+ selecionados';
      }
      return '$count selecionados';
    }
    return '$count de ${widget.requiredCount} selecionados';
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

          // Header with technique info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _techniqueColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTechniqueIcon(),
                    color: _techniqueColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _selectionHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _techniqueColor,
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

          // Selected exercises preview - horizontal scrollable strip
          if (_selectedExercises.isNotEmpty) ...[
            Container(
              height: 56,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  // Selection count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _techniqueColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectionStatus,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _techniqueColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Horizontal list of selected exercises
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedExercises.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final exercise = _selectedExercises[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: _techniqueColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _techniqueColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _techniqueColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 100),
                                child: Text(
                                  exercise.name,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  HapticUtils.selectionClick();
                                  setState(() {
                                    _selectedExercises.remove(exercise);
                                  });
                                },
                                child: Icon(
                                  LucideIcons.x,
                                  size: 14,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

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
                if (!widget.hasRestriction || widget.allowedGroups.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Todos'),
                      selected: _selectedMuscleGroup == null,
                      onSelected: (_) => setState(() => _selectedMuscleGroup = null),
                      selectedColor: _techniqueColor.withAlpha(40),
                      checkmarkColor: _techniqueColor,
                    ),
                  ),
                // Filter out cardio for advanced techniques
                ...(widget.hasRestriction ? widget.allowedGroups : MuscleGroup.values)
                    .where((group) => widget.technique == TechniqueType.normal || group != MuscleGroup.cardio)
                    .map((group) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(group.displayName),
                            selected: _selectedMuscleGroup == group,
                            onSelected: (_) => setState(() {
                              _selectedMuscleGroup = _selectedMuscleGroup == group ? null : group;
                            }),
                            selectedColor: _techniqueColor.withAlpha(40),
                            checkmarkColor: _techniqueColor,
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
                    ],
                  ),
                ),
              ),
              data: (grouped) {
                final allExercises = <Exercise>[];
                // Cardio exercises should not be available for advanced techniques
                final excludeCardio = widget.technique != TechniqueType.normal;

                for (final entry in grouped.entries) {
                  // Skip cardio muscle group for advanced techniques
                  if (excludeCardio && entry.key == MuscleGroup.cardio) {
                    continue;
                  }

                  final isGroupAllowed =
                      !widget.hasRestriction || widget.allowedGroups.contains(entry.key);
                  final matchesMuscleFilter =
                      isGroupAllowed && (_selectedMuscleGroup == null || _selectedMuscleGroup == entry.key);

                  if (matchesMuscleFilter) {
                    for (final exercise in entry.value) {
                      if (_searchQuery.isEmpty ||
                          exercise.name.toLowerCase().contains(_searchQuery)) {
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
                    final selectionIndex = _selectedExercises.indexOf(exercise);
                    final isBlocked = _isBlockedMuscleGroup(exercise.muscleGroup);
                    final canSelect = !isSelected && !isBlocked &&
                        (widget.maxCount == null ||
                            _selectedExercises.length < widget.maxCount!);

                    return _ExerciseListTile(
                      exercise: exercise,
                      isSelected: isSelected,
                      selectionIndex: selectionIndex,
                      canSelect: canSelect,
                      isBlocked: isBlocked,
                      techniqueColor: _techniqueColor,
                      onTap: () {
                        if (isBlocked) {
                          // Show validation message for blocked muscle group
                          HapticUtils.vibrate();
                          final message = widget.technique == TechniqueType.superset
                              ? 'Para Super-Set, selecione um exercício de ${_requiredMuscleGroupForSuperset?.displayName ?? "grupo oposto"}.'
                              : '${exercise.muscleGroup.displayName} é grupo antagônico.\nUse Super-Set para combinar grupos opostos.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          return;
                        }
                        HapticUtils.selectionClick();
                        setState(() {
                          if (isSelected) {
                            _selectedExercises.remove(exercise);
                          } else if (canSelect) {
                            _selectedExercises.add(exercise);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Info banner for Super-Set (required muscle group)
          if (_requiredMuscleGroupForSuperset != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.arrowRightLeft,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Selecione um exercício de ${_requiredMuscleGroupForSuperset!.displayName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Info banner when muscle groups are blocked (Bi-Set/Tri-Set/Giant Set)
          if (_blockedMuscleGroups.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.info,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Grupos antagônicos bloqueados: ${_blockedMuscleGroups.map((g) => g.displayName).join(", ")}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Confirm button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
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
                child: FilledButton.icon(
                  onPressed: _canConfirm
                      ? () {
                          HapticUtils.mediumImpact();
                          Navigator.pop(context);
                          widget.onExercisesSelected(
                            _selectedExercises,
                            widget.techniqueConfig,
                          );
                        }
                      : null,
                  icon: const Icon(LucideIcons.check, size: 18),
                  label: Text(_canConfirm
                      ? 'Confirmar ${_selectedExercises.length} Exercícios'
                      : _selectionStatus),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: _techniqueColor,
                    disabledBackgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTechniqueIcon() => ExerciseTheme.getIcon(widget.technique);
}

class _ExerciseListTile extends StatelessWidget {
  final Exercise exercise;
  final bool isSelected;
  final int selectionIndex;
  final bool canSelect;
  final bool isBlocked;
  final Color techniqueColor;
  final VoidCallback onTap;

  const _ExerciseListTile({
    required this.exercise,
    required this.isSelected,
    required this.selectionIndex,
    required this.canSelect,
    this.isBlocked = false,
    required this.techniqueColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: isBlocked ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? techniqueColor.withValues(alpha: 0.08)
                : (isBlocked ? Colors.orange.withValues(alpha: 0.05) : null),
            border: Border(
              left: BorderSide(
                color: isSelected
                    ? techniqueColor
                    : (isBlocked ? Colors.orange : Colors.transparent),
                width: 3,
              ),
            ),
          ),
        child: Row(
          children: [
            // Selection indicator or image
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? techniqueColor
                    : (isDark
                        ? theme.colorScheme.surfaceContainerHigh
                        : theme.colorScheme.surfaceContainerLow),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isSelected
                  ? Center(
                      child: Text(
                        '${selectionIndex + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : exercise.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? techniqueColor : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    exercise.muscleGroupName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.checkCircle2, color: techniqueColor, size: 22)
            else if (isBlocked)
              const Icon(LucideIcons.ban, color: Colors.orange, size: 22)
            else if (canSelect)
              Icon(
                LucideIcons.circle,
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                size: 22,
              )
            else
              Icon(
                LucideIcons.minusCircle,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                size: 22,
              ),
          ],
        ),
        ),
      ),
    );
  }
}
