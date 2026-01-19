import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../features/workout_program/domain/models/workout_program.dart';

/// Centralized theme for exercise display across the application.
/// Single source of truth for technique colors, icons, and visual properties.
abstract class ExerciseTheme {
  // ============================================
  // TECHNIQUE COLORS
  // ============================================

  /// Standard colors for each technique type.
  /// Use these consistently across all exercise displays.
  static const Map<TechniqueType, Color> techniqueColors = {
    TechniqueType.normal: Color(0xFF6B7280), // Gray
    TechniqueType.superset: Color(0xFF9333EA), // Purple
    TechniqueType.biset: Color(0xFFEC4899), // Pink
    TechniqueType.triset: Color(0xFFF97316), // Orange
    TechniqueType.giantset: Color(0xFFDC2626), // Red
    TechniqueType.dropset: Color(0xFF2563EB), // Blue
    TechniqueType.restPause: Color(0xFF14B8A6), // Teal
    TechniqueType.cluster: Color(0xFF4F46E5), // Indigo
  };

  /// Get the color for a specific technique type.
  static Color getColor(TechniqueType type) =>
      techniqueColors[type] ?? techniqueColors[TechniqueType.normal]!;

  /// Get a lighter version of the technique color for backgrounds.
  static Color getBackgroundColor(TechniqueType type, {double alpha = 0.12}) =>
      getColor(type).withValues(alpha: alpha);

  /// Get a border color for the technique.
  static Color getBorderColor(TechniqueType type, {double alpha = 0.4}) =>
      getColor(type).withValues(alpha: alpha);

  // ============================================
  // TECHNIQUE ICONS
  // ============================================

  /// Get the icon for a specific technique type.
  static IconData getIcon(TechniqueType type) {
    return switch (type) {
      TechniqueType.normal => LucideIcons.dumbbell,
      TechniqueType.superset => LucideIcons.arrowRightLeft,
      TechniqueType.biset => LucideIcons.link,
      TechniqueType.triset => LucideIcons.triangle,
      TechniqueType.giantset => LucideIcons.crown,
      TechniqueType.dropset => LucideIcons.arrowDown,
      TechniqueType.restPause => LucideIcons.pause,
      TechniqueType.cluster => LucideIcons.boxes,
    };
  }

  // ============================================
  // TECHNIQUE LABELS
  // ============================================

  /// Get the display name for a technique type in Portuguese.
  static String getDisplayName(TechniqueType type) => type.displayName;

  /// Get the short description of what the technique does.
  static String getDescription(TechniqueType type) {
    return switch (type) {
      TechniqueType.normal => 'Execucao padrao do exercicio',
      TechniqueType.superset =>
        'Dois exercicios de grupos opostos sem descanso',
      TechniqueType.biset =>
        'Dois exercicios da mesma area sem descanso',
      TechniqueType.triset =>
        'Tres exercicios do mesmo grupo muscular sem descanso',
      TechniqueType.giantset =>
        'Quatro ou mais exercicios do mesmo grupo sem descanso',
      TechniqueType.dropset =>
        'Reducao progressiva de carga sem descanso entre as reducoes',
      TechniqueType.restPause =>
        'Pequenas pausas durante a serie para prolongar o esforco',
      TechniqueType.cluster =>
        'Serie dividida em mini-series com pausas curtas',
    };
  }

  // ============================================
  // TECHNIQUE IDENTIFICATION
  // ============================================

  /// Check if a technique is a multi-exercise group (superset, biset, triset, giantset).
  static bool isGroupTechnique(TechniqueType type) {
    return type == TechniqueType.superset ||
        type == TechniqueType.biset ||
        type == TechniqueType.triset ||
        type == TechniqueType.giantset;
  }

  /// Check if a technique is a single-exercise technique (dropset, rest-pause, cluster).
  static bool isSingleExerciseTechnique(TechniqueType type) {
    return type == TechniqueType.dropset ||
        type == TechniqueType.restPause ||
        type == TechniqueType.cluster;
  }

  /// Check if a technique is normal (no special technique).
  static bool isNormalTechnique(TechniqueType type) {
    return type == TechniqueType.normal;
  }

  /// Determine the technique type based on group size.
  static TechniqueType getTechniqueForGroupSize(int count) {
    return switch (count) {
      <= 1 => TechniqueType.normal,
      2 => TechniqueType.superset,
      3 => TechniqueType.triset,
      _ => TechniqueType.giantset,
    };
  }

  // ============================================
  // VISUAL STYLING HELPERS
  // ============================================

  /// Standard border radius for exercise cards.
  static const double cardBorderRadius = 12.0;

  /// Standard border radius for technique badges.
  static const double badgeBorderRadius = 6.0;

  /// Standard padding for exercise cards.
  static const EdgeInsets cardPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 10);

  /// Standard margin between exercise cards.
  static const EdgeInsets cardMargin = EdgeInsets.only(bottom: 12);

  /// Get a decorated box for the technique header.
  static BoxDecoration getHeaderDecoration(TechniqueType type) {
    return BoxDecoration(
      color: getBackgroundColor(type),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    );
  }

  /// Get a border decoration for technique cards.
  static BoxDecoration getCardDecoration(
    TechniqueType type, {
    required bool isDark,
    required Color surfaceColor,
  }) {
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(cardBorderRadius),
      border: Border.all(
        color: getBorderColor(type),
        width: 1.5,
      ),
    );
  }

  // ============================================
  // TECHNIQUE CONFIG DISPLAY
  // ============================================

  /// Get display text for dropset configuration.
  static String getDropsetDisplay(int drops, int restBetweenDrops) {
    final restText = restBetweenDrops == 0 ? 'sem descanso' : '${restBetweenDrops}s';
    return '$drops drops, $restText';
  }

  /// Get display text for rest-pause configuration.
  static String getRestPauseDisplay(int pauseDuration) {
    return 'Pausa ${pauseDuration}s';
  }

  /// Get display text for cluster configuration.
  static String getClusterDisplay(int miniSets, int restBetweenMiniSets) {
    return '$miniSets mini-sets × ${restBetweenMiniSets}s';
  }

  /// Get the technique configuration display text based on exercise data.
  static String? getTechniqueConfigDisplay({
    required TechniqueType techniqueType,
    int? numberOfDrops,
    int? restBetweenDrops,
    int? restPauseDuration,
    int? clusterMiniSets,
    int? restBetweenClusters,
  }) {
    return switch (techniqueType) {
      TechniqueType.dropset when numberOfDrops != null =>
        getDropsetDisplay(numberOfDrops, restBetweenDrops ?? 0),
      TechniqueType.restPause when restPauseDuration != null =>
        getRestPauseDisplay(restPauseDuration),
      TechniqueType.cluster
          when clusterMiniSets != null && restBetweenClusters != null =>
        getClusterDisplay(clusterMiniSets, restBetweenClusters),
      _ => null,
    };
  }
}
