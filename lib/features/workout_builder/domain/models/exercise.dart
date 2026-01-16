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
  fullBody;

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
  String get muscleGroupName {
    switch (muscleGroup) {
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
    }
  }

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
