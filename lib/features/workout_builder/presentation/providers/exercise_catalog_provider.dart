import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/workout_service.dart';
import '../../domain/models/exercise.dart';

/// Provider for WorkoutService
final workoutServiceProvider = Provider<WorkoutService>((ref) {
  return WorkoutService();
});

/// Search query for exercise catalog
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

/// Selected muscle group filter
final exerciseMuscleGroupFilterProvider = StateProvider<MuscleGroup?>((ref) => null);

/// Exercise catalog provider - fetches from API
final exerciseCatalogProvider = FutureProvider.family<List<Exercise>, ExerciseCatalogParams>((ref, params) async {
  final service = ref.read(workoutServiceProvider);

  final data = await service.getExercises(
    muscleGroup: params.muscleGroup?.name,
    query: params.query?.isNotEmpty == true ? params.query : null,
    limit: params.limit,
    offset: params.offset,
  );

  return data.map((json) => _parseExercise(json)).toList();
});

/// Simplified provider for filtered exercises
final filteredExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final service = ref.read(workoutServiceProvider);
  final query = ref.watch(exerciseSearchQueryProvider);
  final muscleGroup = ref.watch(exerciseMuscleGroupFilterProvider);

  final data = await service.getExercises(
    muscleGroup: muscleGroup?.name,
    query: query.isNotEmpty ? query : null,
    limit: 200,
  );

  return data.map((json) => _parseExercise(json)).toList();
});

/// Exercises grouped by muscle group
final exercisesByMuscleGroupProvider = FutureProvider<Map<MuscleGroup, List<Exercise>>>((ref) async {
  final service = ref.read(workoutServiceProvider);

  final data = await service.getExercises(limit: 200);
  final exercises = data.map((json) => _parseExercise(json)).toList();

  final grouped = <MuscleGroup, List<Exercise>>{};
  for (final muscleGroup in MuscleGroup.values) {
    grouped[muscleGroup] = exercises.where((e) => e.muscleGroup == muscleGroup).toList();
  }

  return grouped;
});

/// Parse JSON to Exercise
Exercise _parseExercise(Map<String, dynamic> json) {
  // Parse equipment - can be list or string
  EquipmentType? equipmentType;
  final equipmentData = json['equipment'];
  if (equipmentData != null) {
    if (equipmentData is List && equipmentData.isNotEmpty) {
      // Take first equipment from list
      equipmentType = (equipmentData.first as String).toEquipmentType();
    } else if (equipmentData is String) {
      equipmentType = equipmentData.toEquipmentType();
    }
  }

  return Exercise(
    id: json['id'] as String,
    name: json['name'] as String,
    muscleGroup: (json['muscle_group'] as String? ?? 'full_body').toMuscleGroup(),
    secondaryMuscles: (json['secondary_muscles'] as List<dynamic>?)
        ?.map((e) => (e as String).toMuscleGroup())
        .toList() ?? [],
    equipment: equipmentType,
    description: json['description'] as String?,
    instructions: json['instructions'] as String?,
    imageUrl: json['image_url'] as String?,
    videoUrl: json['video_url'] as String?,
    difficulty: json['difficulty'] as String? ?? 'intermediate',
    isCompound: json['is_compound'] as bool? ?? false,
    isCustom: json['is_custom'] as bool? ?? false,
    createdBy: json['created_by'] as String?,
  );
}

/// Parameters for exercise catalog query
class ExerciseCatalogParams {
  final MuscleGroup? muscleGroup;
  final String? query;
  final int limit;
  final int offset;

  const ExerciseCatalogParams({
    this.muscleGroup,
    this.query,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseCatalogParams &&
          runtimeType == other.runtimeType &&
          muscleGroup == other.muscleGroup &&
          query == other.query &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode => Object.hash(muscleGroup, query, limit, offset);
}
