// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Exercise _$ExerciseFromJson(Map<String, dynamic> json) => _Exercise(
  id: json['id'] as String,
  name: json['name'] as String,
  muscleGroup: $enumDecode(_$MuscleGroupEnumMap, json['muscleGroup']),
  secondaryMuscles:
      (json['secondaryMuscles'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$MuscleGroupEnumMap, e))
          .toList() ??
      const [],
  equipment: $enumDecodeNullable(_$EquipmentTypeEnumMap, json['equipment']),
  description: json['description'] as String?,
  instructions: json['instructions'] as String?,
  imageUrl: json['imageUrl'] as String?,
  videoUrl: json['videoUrl'] as String?,
  difficulty: json['difficulty'] as String? ?? 'intermediate',
  isCompound: json['isCompound'] as bool? ?? false,
  isCustom: json['isCustom'] as bool? ?? false,
  createdBy: json['createdBy'] as String?,
);

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'muscleGroup': _$MuscleGroupEnumMap[instance.muscleGroup]!,
  'secondaryMuscles': instance.secondaryMuscles
      .map((e) => _$MuscleGroupEnumMap[e]!)
      .toList(),
  'equipment': _$EquipmentTypeEnumMap[instance.equipment],
  'description': instance.description,
  'instructions': instance.instructions,
  'imageUrl': instance.imageUrl,
  'videoUrl': instance.videoUrl,
  'difficulty': instance.difficulty,
  'isCompound': instance.isCompound,
  'isCustom': instance.isCustom,
  'createdBy': instance.createdBy,
};

const _$MuscleGroupEnumMap = {
  MuscleGroup.chest: 'chest',
  MuscleGroup.back: 'back',
  MuscleGroup.shoulders: 'shoulders',
  MuscleGroup.biceps: 'biceps',
  MuscleGroup.triceps: 'triceps',
  MuscleGroup.legs: 'legs',
  MuscleGroup.glutes: 'glutes',
  MuscleGroup.abs: 'abs',
  MuscleGroup.cardio: 'cardio',
  MuscleGroup.fullBody: 'fullBody',
};

const _$EquipmentTypeEnumMap = {
  EquipmentType.barbell: 'barbell',
  EquipmentType.dumbbell: 'dumbbell',
  EquipmentType.cable: 'cable',
  EquipmentType.machine: 'machine',
  EquipmentType.bodyweight: 'bodyweight',
  EquipmentType.kettlebell: 'kettlebell',
  EquipmentType.bands: 'bands',
  EquipmentType.other: 'other',
};
