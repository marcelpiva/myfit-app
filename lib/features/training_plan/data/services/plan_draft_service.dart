import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/training_plan.dart';
import '../../presentation/providers/plan_wizard_provider.dart';

/// Draft data model for storing wizard state
class PlanDraft {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> data;

  PlanDraft({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'data': data,
  };

  factory PlanDraft.fromJson(Map<String, dynamic> json) => PlanDraft(
    id: json['id'] as String,
    name: json['name'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    data: json['data'] as Map<String, dynamic>,
  );
}

/// Service for managing plan drafts in local storage
class PlanDraftService {
  static const String _draftsKey = 'plan_drafts';
  static const int _maxDrafts = 10;

  PlanDraftService._();
  static final PlanDraftService instance = PlanDraftService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Save wizard state as draft
  Future<String> saveDraft(PlanWizardState state, {String? existingDraftId}) async {
    final prefs = await this.prefs;
    final drafts = await getDrafts();

    final now = DateTime.now();
    final draftId = existingDraftId ?? 'draft_${now.millisecondsSinceEpoch}';
    final name = state.planName.isNotEmpty ? state.planName : 'Rascunho ${drafts.length + 1}';

    // Serialize wizard state
    final data = _serializeWizardState(state);

    // Find existing draft or create new one
    final existingIndex = drafts.indexWhere((d) => d.id == draftId);
    final draft = PlanDraft(
      id: draftId,
      name: name,
      createdAt: existingIndex >= 0 ? drafts[existingIndex].createdAt : now,
      updatedAt: now,
      data: data,
    );

    if (existingIndex >= 0) {
      drafts[existingIndex] = draft;
    } else {
      drafts.insert(0, draft);
    }

    // Limit number of drafts
    while (drafts.length > _maxDrafts) {
      drafts.removeLast();
    }

    // Save to storage
    final encoded = drafts.map((d) => d.toJson()).toList();
    await prefs.setString(_draftsKey, jsonEncode(encoded));

    return draftId;
  }

  /// Get all drafts
  Future<List<PlanDraft>> getDrafts() async {
    final prefs = await this.prefs;
    final jsonStr = prefs.getString(_draftsKey);

    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded
          .map((d) => PlanDraft.fromJson(d as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Get a specific draft by ID
  Future<PlanDraft?> getDraft(String draftId) async {
    final drafts = await getDrafts();
    try {
      return drafts.firstWhere((d) => d.id == draftId);
    } catch (_) {
      return null;
    }
  }

  /// Delete a draft
  Future<void> deleteDraft(String draftId) async {
    final prefs = await this.prefs;
    final drafts = await getDrafts();
    drafts.removeWhere((d) => d.id == draftId);

    final encoded = drafts.map((d) => d.toJson()).toList();
    await prefs.setString(_draftsKey, jsonEncode(encoded));
  }

  /// Clear all drafts
  Future<void> clearAllDrafts() async {
    final prefs = await this.prefs;
    await prefs.remove(_draftsKey);
  }

  /// Restore wizard state from draft
  PlanWizardState? restoreFromDraft(PlanDraft draft) {
    try {
      return _deserializeWizardState(draft.data);
    } catch (_) {
      return null;
    }
  }

  /// Serialize wizard state to JSON-compatible map
  Map<String, dynamic> _serializeWizardState(PlanWizardState state) {
    return {
      'currentStep': state.currentStep,
      'method': state.method?.name,
      'planName': state.planName,
      'goal': state.goal.name,
      'difficulty': state.difficulty.name,
      'splitType': state.splitType.name,
      'durationWeeks': state.durationWeeks,
      'targetWorkoutMinutes': state.targetWorkoutMinutes,
      'isTemplate': state.isTemplate,
      'templateId': state.templateId,
      'studentId': state.studentId,
      'isDirectPrescription': state.isDirectPrescription,
      'editingPlanId': state.editingPlanId,
      'basePlanId': state.basePlanId,
      'phaseType': state.phaseType?.name,
      'includeDiet': state.includeDiet,
      'dietType': state.dietType?.name,
      'dailyCalories': state.dailyCalories,
      'proteinGrams': state.proteinGrams,
      'carbsGrams': state.carbsGrams,
      'fatGrams': state.fatGrams,
      'mealsPerDay': state.mealsPerDay,
      'dietNotes': state.dietNotes,
      'workouts': state.workouts.map((w) => _serializeWorkout(w)).toList(),
    };
  }

  /// Serialize a wizard workout
  Map<String, dynamic> _serializeWorkout(WizardWorkout workout) {
    return {
      'id': workout.id,
      'label': workout.label,
      'name': workout.name,
      'muscleGroups': workout.muscleGroups,
      'order': workout.order,
      'dayOfWeek': workout.dayOfWeek,
      'exercises': workout.exercises.map((e) => _serializeExercise(e)).toList(),
    };
  }

  /// Serialize a wizard exercise
  Map<String, dynamic> _serializeExercise(WizardExercise exercise) {
    return {
      'id': exercise.id,
      'exerciseId': exercise.exerciseId,
      'name': exercise.name,
      'muscleGroup': exercise.muscleGroup,
      'sets': exercise.sets,
      'reps': exercise.reps,
      'restSeconds': exercise.restSeconds,
      'notes': exercise.notes,
      'executionInstructions': exercise.executionInstructions,
      'groupInstructions': exercise.groupInstructions,
      'isometricSeconds': exercise.isometricSeconds,
      'techniqueType': exercise.techniqueType.name,
      'exerciseGroupId': exercise.exerciseGroupId,
      'exerciseGroupOrder': exercise.exerciseGroupOrder,
      'exerciseMode': exercise.exerciseMode.name,
      'durationMinutes': exercise.durationMinutes,
      'intensity': exercise.intensity,
      'workSeconds': exercise.workSeconds,
      'intervalRestSeconds': exercise.intervalRestSeconds,
      'rounds': exercise.rounds,
      'distanceKm': exercise.distanceKm,
      'targetPaceMinPerKm': exercise.targetPaceMinPerKm,
      'dropCount': exercise.dropCount,
      'restBetweenDrops': exercise.restBetweenDrops,
      'pauseDuration': exercise.pauseDuration,
      'miniSetCount': exercise.miniSetCount,
    };
  }

  /// Deserialize wizard state from JSON
  PlanWizardState _deserializeWizardState(Map<String, dynamic> data) {
    final workoutsData = (data['workouts'] as List<dynamic>?) ?? [];
    final workouts = workoutsData
        .map((w) => _deserializeWorkout(w as Map<String, dynamic>))
        .toList();

    return PlanWizardState(
      currentStep: data['currentStep'] as int? ?? 0,
      method: _parseCreationMethod(data['method'] as String?),
      planName: data['planName'] as String? ?? '',
      goal: _parseWorkoutGoal(data['goal'] as String?),
      difficulty: _parsePlanDifficulty(data['difficulty'] as String?),
      splitType: _parseSplitType(data['splitType'] as String?),
      durationWeeks: data['durationWeeks'] as int?,
      targetWorkoutMinutes: data['targetWorkoutMinutes'] as int?,
      isTemplate: data['isTemplate'] as bool? ?? false,
      templateId: data['templateId'] as String?,
      studentId: data['studentId'] as String?,
      isDirectPrescription: data['isDirectPrescription'] as bool? ?? false,
      editingPlanId: data['editingPlanId'] as String?,
      basePlanId: data['basePlanId'] as String?,
      phaseType: _parsePeriodizationPhase(data['phaseType'] as String?),
      includeDiet: data['includeDiet'] as bool? ?? false,
      dietType: _parseDietType(data['dietType'] as String?),
      dailyCalories: data['dailyCalories'] as int?,
      proteinGrams: data['proteinGrams'] as int?,
      carbsGrams: data['carbsGrams'] as int?,
      fatGrams: data['fatGrams'] as int?,
      mealsPerDay: data['mealsPerDay'] as int?,
      dietNotes: data['dietNotes'] as String?,
      workouts: workouts,
    );
  }

  /// Deserialize a wizard workout
  WizardWorkout _deserializeWorkout(Map<String, dynamic> data) {
    final exercisesData = (data['exercises'] as List<dynamic>?) ?? [];
    final exercises = exercisesData
        .map((e) => _deserializeExercise(e as Map<String, dynamic>))
        .toList();

    return WizardWorkout(
      id: data['id'] as String? ?? '',
      label: data['label'] as String? ?? '',
      name: data['name'] as String? ?? '',
      muscleGroups: ((data['muscleGroups'] as List<dynamic>?) ?? [])
          .map((e) => e.toString())
          .toList(),
      order: data['order'] as int? ?? 0,
      dayOfWeek: data['dayOfWeek'] as int?,
      exercises: exercises,
    );
  }

  /// Deserialize a wizard exercise
  WizardExercise _deserializeExercise(Map<String, dynamic> data) {
    return WizardExercise(
      id: data['id'] as String? ?? '',
      exerciseId: data['exerciseId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      muscleGroup: data['muscleGroup'] as String? ?? '',
      sets: data['sets'] as int? ?? 3,
      reps: data['reps'] as String? ?? '10-12',
      restSeconds: data['restSeconds'] as int? ?? 60,
      notes: data['notes'] as String? ?? '',
      executionInstructions: data['executionInstructions'] as String? ?? '',
      groupInstructions: data['groupInstructions'] as String? ?? '',
      isometricSeconds: data['isometricSeconds'] as int?,
      techniqueType: _parseTechniqueType(data['techniqueType'] as String?),
      exerciseGroupId: data['exerciseGroupId'] as String?,
      exerciseGroupOrder: data['exerciseGroupOrder'] as int? ?? 0,
      exerciseMode: _parseExerciseMode(data['exerciseMode'] as String?),
      durationMinutes: data['durationMinutes'] as int?,
      intensity: data['intensity'] as String?,
      workSeconds: data['workSeconds'] as int?,
      intervalRestSeconds: data['intervalRestSeconds'] as int?,
      rounds: data['rounds'] as int?,
      distanceKm: (data['distanceKm'] as num?)?.toDouble(),
      targetPaceMinPerKm: (data['targetPaceMinPerKm'] as num?)?.toDouble(),
      dropCount: data['dropCount'] as int?,
      restBetweenDrops: data['restBetweenDrops'] as int?,
      pauseDuration: data['pauseDuration'] as int?,
      miniSetCount: data['miniSetCount'] as int?,
    );
  }

  // Parse helpers
  CreationMethod? _parseCreationMethod(String? value) {
    if (value == null) return null;
    return CreationMethod.values.cast<CreationMethod?>().firstWhere(
      (e) => e?.name == value,
      orElse: () => null,
    );
  }

  WorkoutGoal _parseWorkoutGoal(String? value) {
    if (value == null) return WorkoutGoal.hypertrophy;
    return WorkoutGoal.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WorkoutGoal.hypertrophy,
    );
  }

  PlanDifficulty _parsePlanDifficulty(String? value) {
    if (value == null) return PlanDifficulty.intermediate;
    return PlanDifficulty.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PlanDifficulty.intermediate,
    );
  }

  SplitType _parseSplitType(String? value) {
    if (value == null) return SplitType.abc;
    return SplitType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SplitType.abc,
    );
  }

  PeriodizationPhase? _parsePeriodizationPhase(String? value) {
    if (value == null) return null;
    return PeriodizationPhase.values.cast<PeriodizationPhase?>().firstWhere(
      (e) => e?.name == value,
      orElse: () => null,
    );
  }

  DietType? _parseDietType(String? value) {
    if (value == null) return null;
    return DietType.values.cast<DietType?>().firstWhere(
      (e) => e?.name == value,
      orElse: () => null,
    );
  }

  TechniqueType _parseTechniqueType(String? value) {
    if (value == null) return TechniqueType.normal;
    return TechniqueType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TechniqueType.normal,
    );
  }

  ExerciseMode _parseExerciseMode(String? value) {
    if (value == null) return ExerciseMode.strength;
    return ExerciseMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExerciseMode.strength,
    );
  }
}
