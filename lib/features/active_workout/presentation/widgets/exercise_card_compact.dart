import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/exercise_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/workout_translations.dart';
import '../../../../core/widgets/video_player_page.dart';
import '../../../training_plan/domain/models/training_plan.dart';

/// Compact exercise card for active workout - 120px image height instead of 200px
class ExerciseCardCompact extends StatelessWidget {
  final Map<String, dynamic>? exercise;
  final int currentSet;
  final int totalSets;
  final bool isDark;

  const ExerciseCardCompact({
    super.key,
    required this.exercise,
    required this.currentSet,
    required this.totalSets,
    required this.isDark,
  });

  String get _name {
    // Try multiple paths to get the exercise name
    final directName = exercise?['name'] as String?;
    if (directName != null && directName.isNotEmpty) return directName;

    final exerciseName = exercise?['exercise_name'] as String?;
    if (exerciseName != null && exerciseName.isNotEmpty) return exerciseName;

    // Try nested exercise object
    final nestedExercise = exercise?['exercise'] as Map<String, dynamic>?;
    final nestedName = nestedExercise?['name'] as String?;
    if (nestedName != null && nestedName.isNotEmpty) return nestedName;

    return 'Exercício';
  }

  String get _muscleGroup {
    final direct = exercise?['muscle_group'] as String? ?? exercise?['muscle'] as String?;
    if (direct != null && direct.isNotEmpty) return direct;

    // Try nested exercise object
    final nestedExercise = exercise?['exercise'] as Map<String, dynamic>?;
    return nestedExercise?['muscle_group'] as String? ?? '';
  }

  String? get _techniqueType => exercise?['technique_type'] as String?;

  /// Converts technique string to TechniqueType enum for consistent theming
  TechniqueType get _technique {
    switch (_techniqueType?.toLowerCase()) {
      case 'bi_set':
      case 'bi-set':
      case 'biset':
        return TechniqueType.biset;
      case 'tri_set':
      case 'tri-set':
      case 'triset':
        return TechniqueType.triset;
      case 'superset':
      case 'super_set':
        return TechniqueType.superset;
      case 'giant_set':
      case 'giant-set':
      case 'giantset':
        return TechniqueType.giantset;
      case 'dropset':
      case 'drop_set':
        return TechniqueType.dropset;
      case 'rest_pause':
      case 'rest-pause':
      case 'restpause':
        return TechniqueType.restPause;
      case 'cluster':
      case 'cluster_set':
        return TechniqueType.cluster;
      default:
        return TechniqueType.normal;
    }
  }

  /// Check if this exercise is part of a grouped technique
  bool get _hasGroupTechnique => ExerciseTheme.isGroupTechnique(_technique);

  String? get _groupInstructions => exercise?['group_instructions'] as String?;

  int? get _exerciseGroupOrder => exercise?['exercise_group_order'] as int?;

  String get _notes => exercise?['notes'] ?? '';

  int get _sets => (exercise?['sets'] ?? 3) as int;

  String get _reps {
    final reps = exercise?['reps'];
    if (reps == null) return '10';
    if (reps is int) return reps.toString();
    return reps.toString();
  }

  double get _weight {
    final weight = exercise?['weight'];
    if (weight == null) return 0;
    if (weight is int) return weight.toDouble();
    if (weight is double) return weight;
    return double.tryParse(weight.toString()) ?? 0;
  }

  int get _rest => (exercise?['rest_seconds'] ?? exercise?['rest'] ?? 60) as int;

  String? get _exerciseModeStr => exercise?['exercise_mode'] as String?;

  /// Converts exercise_mode string to ExerciseMode enum
  ExerciseMode get _exerciseMode {
    switch (_exerciseModeStr?.toLowerCase()) {
      case 'duration':
        return ExerciseMode.duration;
      case 'interval':
        return ExerciseMode.interval;
      case 'distance':
        return ExerciseMode.distance;
      case 'stretching':
        return ExerciseMode.stretching;
      default:
        return ExerciseMode.strength;
    }
  }

  int? get _isometricSeconds => exercise?['isometric_seconds'] as int?;

  bool get _isStretching => _exerciseMode == ExerciseMode.stretching;

  String? get _videoUrl {
    final exerciseData = exercise?['exercise'] as Map<String, dynamic>?;
    return exercise?['video_url'] as String? ?? exerciseData?['video_url'] as String?;
  }

  String? get _imageUrl {
    final exerciseData = exercise?['exercise'] as Map<String, dynamic>?;
    return exercise?['image_url'] as String? ?? exerciseData?['image_url'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final techniqueColor = ExerciseTheme.getColor(_technique);
    final isGrouped = _hasGroupTechnique;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Subtle gradient background for grouped techniques
        gradient: isGrouped
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  techniqueColor.withAlpha(isDark ? 15 : 10),
                  (isDark
                          ? theme.colorScheme.surfaceContainerLowest
                          : theme.colorScheme.surfaceContainerLowest)
                      .withAlpha(isDark ? 150 : 200),
                ],
              )
            : null,
        color: isGrouped
            ? null
            : (isDark
                ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
                : theme.colorScheme.surfaceContainerLowest.withAlpha(200)),
        // Colored border for grouped techniques
        border: Border.all(
          color: isGrouped
              ? techniqueColor.withAlpha(isDark ? 150 : 180)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: isGrouped ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Compact image/video area - 120px instead of 200px
          _buildMediaSection(context, theme),

          // Exercise info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stretching mode badge
                if (_isStretching) ...[
                  _buildStretchingBadge(theme),
                  const SizedBox(height: 8),
                ]
                // Technique type badge (bi-set, tri-set, superset, etc.)
                else if (_techniqueType != null && _techniqueType!.isNotEmpty) ...[
                  _buildTechniqueBadge(theme),
                  const SizedBox(height: 8),
                ],

                // Muscle group badge and set indicator
                Row(
                  children: [
                    if (_muscleGroup.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          translateMuscleGroup(_muscleGroup),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Current set indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Série $currentSet/$totalSets',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Exercise name
                Text(
                  _name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Group instructions (if in a grouped set)
                if (_groupInstructions != null && _groupInstructions!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTechniqueColor().withAlpha(15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _getTechniqueColor().withAlpha(40)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.lightbulb,
                          size: 14,
                          color: _getTechniqueColor(),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _groupInstructions!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getTechniqueColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Notes if present
                if (_notes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.info,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _notes,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 14),

                // Target stats row - more compact
                _buildStatsRow(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context, ThemeData theme) {
    final hasVideo = _videoUrl != null && _videoUrl!.isNotEmpty;
    final hasImage = _imageUrl != null && _imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: hasVideo
          ? () {
              HapticUtils.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VideoPlayerPage(
                    videoUrl: _videoUrl!,
                    title: _name,
                  ),
                ),
              );
            }
          : null,
      child: Container(
        height: 120, // Compact height
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
              : theme.colorScheme.surfaceContainerLow.withAlpha(200),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: _imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: theme.colorScheme.surfaceContainerLow,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceContainerLow,
                        child: Icon(
                          LucideIcons.image,
                          size: 32,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  if (hasVideo)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(150),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.play,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasVideo ? LucideIcons.playCircle : LucideIcons.dumbbell,
                      size: 32,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasVideo ? 'Ver vídeo' : '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    final stretchingColor = const Color(0xFF8B5CF6); // Violet for stretching

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _isStretching
            ? stretchingColor.withAlpha(isDark ? 30 : 20)
            : (isDark
                ? AppColors.mutedDark.withAlpha(80)
                : AppColors.muted.withAlpha(120)),
        borderRadius: BorderRadius.circular(10),
        border: _isStretching
            ? Border.all(color: stretchingColor.withAlpha(60))
            : null,
      ),
      child: _isStretching
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(theme, LucideIcons.repeat, '$_sets', 'Séries',
                    color: stretchingColor),
                _buildDivider(theme),
                _buildStatItem(theme, LucideIcons.timer,
                    '${_isometricSeconds ?? 30}s', 'Manter',
                    color: stretchingColor),
                _buildDivider(theme),
                _buildStatItem(theme, LucideIcons.pause, '${_rest}s', 'Descanso',
                    color: stretchingColor),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(theme, LucideIcons.repeat, '$_sets', 'Séries'),
                _buildDivider(theme),
                _buildStatItem(theme, LucideIcons.hash, _reps, 'Reps'),
                _buildDivider(theme),
                _buildStatItem(
                  theme,
                  LucideIcons.dumbbell,
                  _weight > 0
                      ? '${_weight.toStringAsFixed(_weight.truncateToDouble() == _weight ? 0 : 1)}kg'
                      : '--',
                  'Peso',
                ),
                _buildDivider(theme),
                _buildStatItem(
                    theme, LucideIcons.timer, '${_rest}s', 'Descanso'),
              ],
            ),
    );
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String value, String label,
      {Color? color}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color ?? theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color ?? theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      height: 24,
      width: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.2),
    );
  }

  Widget _buildStretchingBadge(ThemeData theme) {
    const color = Color(0xFF8B5CF6); // Violet

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withAlpha(180)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.move, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            'ALONGAMENTO',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechniqueBadge(ThemeData theme) {
    final color = _getTechniqueColor();
    final label = _getTechniqueLabel();
    final icon = _getTechniqueIcon();
    final orderLabel = _exerciseGroupOrder != null ? ' (${_exerciseGroupOrder! + 1}º)' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withAlpha(180)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '$label$orderLabel',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Uses centralized ExerciseTheme for consistent colors across the app
  Color _getTechniqueColor() => ExerciseTheme.getColor(_technique);

  /// Uses centralized ExerciseTheme for consistent labels
  String _getTechniqueLabel() => ExerciseTheme.getDisplayName(_technique).toUpperCase();

  /// Uses centralized ExerciseTheme for consistent icons
  IconData _getTechniqueIcon() => ExerciseTheme.getIcon(_technique);
}
