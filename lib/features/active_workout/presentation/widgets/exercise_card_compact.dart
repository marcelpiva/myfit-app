import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/video_player_page.dart';

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

  String get _name =>
      exercise?['name'] ?? exercise?['exercise_name'] ?? 'Exercício';

  String get _muscleGroup => exercise?['muscle_group'] ?? exercise?['muscle'] ?? '';

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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
            : theme.colorScheme.surfaceContainerLowest.withAlpha(200),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
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
                          _muscleGroup,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.mutedDark.withAlpha(80)
            : AppColors.muted.withAlpha(120),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
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
          _buildStatItem(theme, LucideIcons.timer, '${_rest}s', 'Descanso'),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
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
}
