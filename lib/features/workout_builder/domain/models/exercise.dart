import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

/// Muscle group for exercises
enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  legs,
  glutes,
  abs,
  cardio,
  fullBody,
  stretching,
  quadriceps,
  hamstrings,
  calves,
  forearms;

  /// Display name in Portuguese
  String get displayName {
    switch (this) {
      case MuscleGroup.chest:
        return 'Peito';
      case MuscleGroup.back:
        return 'Costas';
      case MuscleGroup.shoulders:
        return 'Ombros';
      case MuscleGroup.biceps:
        return 'Bíceps';
      case MuscleGroup.triceps:
        return 'Tríceps';
      case MuscleGroup.legs:
        return 'Pernas';
      case MuscleGroup.glutes:
        return 'Glúteos';
      case MuscleGroup.abs:
        return 'Abdômen';
      case MuscleGroup.cardio:
        return 'Cardio';
      case MuscleGroup.fullBody:
        return 'Corpo Inteiro';
      case MuscleGroup.stretching:
        return 'Alongamento';
      case MuscleGroup.quadriceps:
        return 'Quadríceps';
      case MuscleGroup.hamstrings:
        return 'Posterior';
      case MuscleGroup.calves:
        return 'Panturrilha';
      case MuscleGroup.forearms:
        return 'Antebraço';
    }
  }
}

/// Equipment type for exercises
enum EquipmentType {
  barbell,
  dumbbell,
  cable,
  machine,
  bodyweight,
  kettlebell,
  bands,
  other,
}

/// Exercise from the catalog/library
@freezed
sealed class Exercise with _$Exercise {
  const Exercise._();

  const factory Exercise({
    required String id,
    required String name,
    required MuscleGroup muscleGroup,
    @Default([]) List<MuscleGroup> secondaryMuscles,
    EquipmentType? equipment,
    String? description,
    String? instructions,
    String? imageUrl,
    String? videoUrl,
    @Default('intermediate') String difficulty,
    @Default(false) bool isCompound,
    @Default(false) bool isCustom,
    String? createdBy,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  /// Display name for muscle group
  String get muscleGroupName => muscleGroup.displayName;

  /// Display name for equipment
  String? get equipmentName {
    if (equipment == null) return null;
    switch (equipment!) {
      case EquipmentType.barbell:
        return 'Barra';
      case EquipmentType.dumbbell:
        return 'Halteres';
      case EquipmentType.cable:
        return 'Cabo';
      case EquipmentType.machine:
        return 'Máquina';
      case EquipmentType.bodyweight:
        return 'Peso Corporal';
      case EquipmentType.kettlebell:
        return 'Kettlebell';
      case EquipmentType.bands:
        return 'Elásticos';
      case EquipmentType.other:
        return 'Outro';
    }
  }
}

/// Extension for muscle group antagonist detection
extension MuscleGroupAntagonist on MuscleGroup {
  /// Returns the antagonist muscle group for super-set pairing
  /// Returns null if no clear antagonist exists
  MuscleGroup? get antagonist {
    switch (this) {
      case MuscleGroup.chest:
        return MuscleGroup.back;
      case MuscleGroup.back:
        return MuscleGroup.chest;
      case MuscleGroup.biceps:
        return MuscleGroup.triceps;
      case MuscleGroup.triceps:
        return MuscleGroup.biceps;
      case MuscleGroup.quadriceps:
        return MuscleGroup.hamstrings;
      case MuscleGroup.hamstrings:
        return MuscleGroup.quadriceps;
      // These don't have clear antagonists
      case MuscleGroup.shoulders:
      case MuscleGroup.legs:
      case MuscleGroup.glutes:
      case MuscleGroup.abs:
      case MuscleGroup.cardio:
      case MuscleGroup.fullBody:
      case MuscleGroup.stretching:
      case MuscleGroup.calves:
      case MuscleGroup.forearms:
        return null;
    }
  }

  /// Check if this muscle group is antagonist to another
  bool isAntagonistTo(MuscleGroup other) {
    return antagonist == other;
  }

  /// Check if this muscle group is in the same area as another
  /// (for bi-set: same muscle or synergistic muscles)
  bool isSameAreaAs(MuscleGroup other) {
    if (this == other) return true;

    // Define muscle group areas
    const pushMuscles = {MuscleGroup.chest, MuscleGroup.shoulders, MuscleGroup.triceps};
    const pullMuscles = {MuscleGroup.back, MuscleGroup.biceps};
    const lowerBody = {MuscleGroup.legs, MuscleGroup.glutes};

    // Check if both are in the same area
    if (pushMuscles.contains(this) && pushMuscles.contains(other)) return true;
    if (pullMuscles.contains(this) && pullMuscles.contains(other)) return true;
    if (lowerBody.contains(this) && lowerBody.contains(other)) return true;

    return false;
  }
}

/// Utility to detect technique type based on muscle groups
class MuscleGroupTechniqueDetector {
  /// Detect if two muscle groups should be a Super-Set (antagonists) or Bi-Set (same area)
  /// Returns true for Super-Set (antagonists), false for Bi-Set (same area)
  static bool isSuperSet(MuscleGroup group1, MuscleGroup group2) {
    return group1.isAntagonistTo(group2);
  }

  /// Detect technique type for a list of muscle groups
  /// For 2 exercises: Super-Set if antagonists, Bi-Set otherwise
  static bool shouldBeSuperSet(List<MuscleGroup> groups) {
    if (groups.length != 2) return false;
    return isSuperSet(groups[0], groups[1]);
  }

  /// Check if a list of muscle groups contains any antagonist pairs
  /// Returns true if Super-Set is possible with these muscle groups
  static bool hasAntagonistPairs(List<MuscleGroup> groups) {
    // Check for chest/back pair
    if (groups.contains(MuscleGroup.chest) && groups.contains(MuscleGroup.back)) {
      return true;
    }
    // Check for biceps/triceps pair
    if (groups.contains(MuscleGroup.biceps) && groups.contains(MuscleGroup.triceps)) {
      return true;
    }
    return false;
  }

  /// Check if a list of muscle group strings contains any antagonist pairs
  static bool hasAntagonistPairsFromStrings(List<String> groups) {
    final muscleGroups = groups.map((g) => g.toMuscleGroup()).toList();
    return hasAntagonistPairs(muscleGroups);
  }
}

/// Extension to parse muscle group from string
extension MuscleGroupParsing on String {
  MuscleGroup toMuscleGroup() {
    switch (toLowerCase()) {
      case 'chest':
      case 'peito':
        return MuscleGroup.chest;
      case 'back':
      case 'costas':
        return MuscleGroup.back;
      case 'shoulders':
      case 'ombros':
        return MuscleGroup.shoulders;
      case 'biceps':
      case 'bíceps':
        return MuscleGroup.biceps;
      case 'triceps':
      case 'tríceps':
        return MuscleGroup.triceps;
      case 'legs':
      case 'pernas':
        return MuscleGroup.legs;
      case 'quadriceps':
      case 'quadríceps':
        return MuscleGroup.quadriceps;
      case 'hamstrings':
      case 'isquiotibiais':
      case 'posterior':
        return MuscleGroup.hamstrings;
      case 'calves':
      case 'panturrilha':
      case 'panturrilhas':
        return MuscleGroup.calves;
      case 'forearms':
      case 'antebraço':
      case 'antebraco':
        return MuscleGroup.forearms;
      case 'glutes':
      case 'glúteos':
        return MuscleGroup.glutes;
      case 'abs':
      case 'abdômen':
      case 'abdomen':
        return MuscleGroup.abs;
      case 'cardio':
        return MuscleGroup.cardio;
      case 'full_body':
      case 'fullbody':
      case 'corpo inteiro':
        return MuscleGroup.fullBody;
      case 'stretching':
      case 'alongamento':
        return MuscleGroup.stretching;
      default:
        return MuscleGroup.fullBody;
    }
  }
}

/// Extension to parse equipment from string
extension EquipmentParsing on String {
  EquipmentType toEquipmentType() {
    switch (toLowerCase()) {
      case 'barbell':
      case 'barra':
        return EquipmentType.barbell;
      case 'dumbbell':
      case 'halteres':
        return EquipmentType.dumbbell;
      case 'cable':
      case 'cabo':
        return EquipmentType.cable;
      case 'machine':
      case 'máquina':
        return EquipmentType.machine;
      case 'bodyweight':
      case 'peso corporal':
        return EquipmentType.bodyweight;
      case 'kettlebell':
        return EquipmentType.kettlebell;
      case 'bands':
      case 'elásticos':
        return EquipmentType.bands;
      default:
        return EquipmentType.other;
    }
  }
}
