import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/exercise_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/video_player_page.dart';
import '../../../training_plan/domain/models/training_plan.dart';

/// Groups exercises by their technique and displays them accordingly
class ExerciseListWithTechniques extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  final bool isDark;

  const ExerciseListWithTechniques({
    super.key,
    required this.exercises,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final groups = _groupExercises(exercises);

    return Column(
      children: groups.map((group) {
        if (group.length == 1) {
          final exercise = group.first;
          final techniqueType = _getTechniqueType(exercise);

          if (ExerciseTheme.isSingleExerciseTechnique(techniqueType)) {
            return _SingleTechniqueCard(
              exercise: exercise,
              techniqueType: techniqueType,
              isDark: isDark,
            );
          }

          return _SimpleExerciseCard(
            exercise: exercise,
            index: exercises.indexOf(exercise) + 1,
            isDark: isDark,
          );
        }

        // Multi-exercise group (superset, biset, triset, giantset)
        final techniqueType = _getGroupTechniqueType(group);
        return _GroupedExerciseCard(
          exercises: group,
          techniqueType: techniqueType,
          isDark: isDark,
        );
      }).toList(),
    );
  }

  /// Group exercises by their exercise_group_id (or group_id for backwards compatibility)
  List<List<Map<String, dynamic>>> _groupExercises(
      List<Map<String, dynamic>> exercises) {
    final groups = <List<Map<String, dynamic>>>[];
    final Map<String, List<Map<String, dynamic>>> groupMap = {};

    for (final exercise in exercises) {
      // Support both 'exercise_group_id' (new) and 'group_id' (legacy)
      final groupId = exercise['exercise_group_id'] as String? ??
                      exercise['group_id'] as String?;

      if (groupId != null && groupId.isNotEmpty) {
        groupMap.putIfAbsent(groupId, () => []);
        groupMap[groupId]!.add(exercise);
      } else {
        groups.add([exercise]);
      }
    }

    // Add grouped exercises
    for (final group in groupMap.values) {
      if (group.isNotEmpty) {
        groups.add(group);
      }
    }

    // Sort by order if available
    groups.sort((a, b) {
      final orderA = a.first['order'] as int? ?? 0;
      final orderB = b.first['order'] as int? ?? 0;
      return orderA.compareTo(orderB);
    });

    return groups;
  }

  TechniqueType _getTechniqueType(Map<String, dynamic> exercise) {
    final techniqueStr = exercise['technique_type'] as String? ??
        (exercise['exercise'] as Map<String, dynamic>?)?['technique_type']
            as String? ??
        'normal';
    return techniqueStr.toTechniqueType();
  }

  TechniqueType _getGroupTechniqueType(List<Map<String, dynamic>> group) {
    if (group.isEmpty) return TechniqueType.normal;

    final firstTechnique = _getTechniqueType(group.first);
    if (ExerciseTheme.isGroupTechnique(firstTechnique)) {
      return firstTechnique;
    }

    // Determine by count
    return ExerciseTheme.getTechniqueForGroupSize(group.length);
  }
}

/// Card for grouped exercises (superset, biset, triset, giantset)
class _GroupedExerciseCard extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  final TechniqueType techniqueType;
  final bool isDark;

  const _GroupedExerciseCard({
    required this.exercises,
    required this.techniqueType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = ExerciseTheme.getColor(techniqueType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withAlpha(100),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header with technique badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  ExerciseTheme.getIcon(techniqueType),
                  size: 20,
                  color: color,
                ),
                const SizedBox(width: 10),
                Text(
                  techniqueType.displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${exercises.length} exercícios',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Vertical connector line indicator
          Container(
            margin: const EdgeInsets.only(left: 28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vertical connecting line
                Container(
                  width: 3,
                  height: exercises.length * 80.0,
                  decoration: BoxDecoration(
                    color: color.withAlpha(60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),

                // Exercise items
                Expanded(
                  child: Column(
                    children: exercises.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exercise = entry.value;
                      final isLast = index == exercises.length - 1;

                      return _GroupedExerciseItem(
                        exercise: exercise,
                        index: index + 1,
                        isLast: isLast,
                        color: color,
                        isDark: isDark,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Rest info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.mutedDark.withAlpha(30)
                  : AppColors.muted.withAlpha(50),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.timer,
                  size: 14,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 6),
                Text(
                  'Descanso entre séries: ${_getRestTime(exercises.first)}s',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getRestTime(Map<String, dynamic> exercise) {
    return exercise['rest'] as int? ??
        exercise['rest_seconds'] as int? ??
        60;
  }
}

/// Single exercise item within a grouped card
class _GroupedExerciseItem extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final int index;
  final bool isLast;
  final Color color;
  final bool isDark;

  const _GroupedExerciseItem({
    required this.exercise,
    required this.index,
    required this.isLast,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = exercise['name'] as String? ??
        (exercise['exercise'] as Map<String, dynamic>?)?['name'] as String? ??
        'Exercício';
    final sets = exercise['sets'] ?? exercise['target_sets'] ?? '-';
    final reps = exercise['reps'] ?? exercise['target_reps'] ?? '-';

    return GestureDetector(
      onTap: () => _showExerciseDetail(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
        ),
        child: Row(
          children: [
            // Index circle with connector dot
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(40),
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),

            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$sets séries × $reps reps',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color:
                  isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  void _showExerciseDetail(BuildContext context) {
    HapticUtils.lightImpact();
    _showExerciseDetailSheet(context, exercise, isDark);
  }
}

/// Card for single exercises with techniques (dropset, rest-pause, cluster)
class _SingleTechniqueCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final TechniqueType techniqueType;
  final bool isDark;

  const _SingleTechniqueCard({
    required this.exercise,
    required this.techniqueType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = ExerciseTheme.getColor(techniqueType);
    final name = exercise['name'] as String? ??
        (exercise['exercise'] as Map<String, dynamic>?)?['name'] as String? ??
        'Exercício';

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        _showExerciseDetailSheet(context, exercise, isDark);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withAlpha(80),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Technique header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    ExerciseTheme.getIcon(techniqueType),
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    techniqueType.displayName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  // Technique config
                  Text(
                    _getTechniqueConfig(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),

            // Exercise content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSetRepsText(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTechniqueConfig() {
    switch (techniqueType) {
      case TechniqueType.dropset:
        final drops = exercise['number_of_drops'] as int? ?? 3;
        return '$drops drops';
      case TechniqueType.restPause:
        final pause = exercise['rest_pause_duration'] as int? ?? 15;
        return 'Pausa ${pause}s';
      case TechniqueType.cluster:
        final miniSets = exercise['cluster_mini_sets'] as int? ?? 5;
        return '$miniSets mini-sets';
      default:
        return '';
    }
  }

  String _getSetRepsText() {
    final sets = exercise['sets'] ?? exercise['target_sets'] ?? '-';
    final reps = exercise['reps'] ?? exercise['target_reps'] ?? '-';
    final rest = exercise['rest'] ?? exercise['rest_seconds'] ?? 60;
    return '$sets séries × $reps reps • ${rest}s descanso';
  }
}

/// Simple exercise card for normal exercises
class _SimpleExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final int index;
  final bool isDark;

  const _SimpleExerciseCard({
    required this.exercise,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = exercise['name'] as String? ??
        (exercise['exercise'] as Map<String, dynamic>?)?['name'] as String? ??
        'Exercício';
    final sets = exercise['sets'] ?? exercise['target_sets'] ?? '-';
    final reps = exercise['reps'] ?? exercise['target_reps'] ?? '-';
    final rest = exercise['rest'] ?? exercise['rest_seconds'] ?? 60;

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        _showExerciseDetailSheet(context, exercise, isDark);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Index
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Exercise info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$sets séries × $reps reps',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),

              // Rest time
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.mutedDark.withAlpha(150)
                      : AppColors.muted.withAlpha(200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.timer,
                      size: 12,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${rest}s',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows exercise detail bottom sheet
void _showExerciseDetailSheet(
  BuildContext context,
  Map<String, dynamic> exercise,
  bool isDark,
) {
  final theme = Theme.of(context);
  final name = exercise['name'] as String? ??
      (exercise['exercise'] as Map<String, dynamic>?)?['name'] as String? ??
      'Exercício';
  final muscle = exercise['muscle'] as String? ??
      (exercise['exercise'] as Map<String, dynamic>?)?['muscle_group']
          as String? ??
      'Músculo';
  final sets = exercise['sets'] ?? exercise['target_sets'] ?? '-';
  final reps = exercise['reps'] ?? exercise['target_reps'] ?? '-';
  final rest = exercise['rest'] ?? exercise['rest_seconds'] ?? 60;
  final notes = exercise['notes'] as String?;
  final videoUrl = exercise['video_url'] as String? ??
      (exercise['exercise'] as Map<String, dynamic>?)?['video_url'] as String?;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.dumbbell,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        muscle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _DetailStat(
                    icon: LucideIcons.repeat,
                    label: 'Séries',
                    value: '$sets',
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _DetailStat(
                    icon: LucideIcons.hash,
                    label: 'Reps',
                    value: '$reps',
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _DetailStat(
                    icon: LucideIcons.timer,
                    label: 'Descanso',
                    value: '${rest}s',
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            // Notes
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Observações',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.mutedDark.withAlpha(100)
                      : AppColors.muted.withAlpha(150),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  notes,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            ],

            // Video button
            if (videoUrl != null && videoUrl.isNotEmpty) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerPage(
                        videoUrl: videoUrl,
                        title: name,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isDark
                        ? AppColors.primaryDark.withAlpha(30)
                        : AppColors.primary.withAlpha(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.playCircle,
                        size: 18,
                        color:
                            isDark ? AppColors.primaryDark : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ver Vídeo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.primaryDark
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _DetailStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.mutedDark.withAlpha(150)
                : AppColors.muted.withAlpha(200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.primaryDark : AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
