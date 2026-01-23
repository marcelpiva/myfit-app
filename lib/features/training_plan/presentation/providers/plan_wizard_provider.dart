import 'dart:math' show max;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/services/workout_service.dart';
import '../../../workout_builder/domain/models/exercise.dart';
import '../../domain/models/training_plan.dart';

part 'plan_wizard_provider.freezed.dart';

/// Creation method for the plan
enum CreationMethod {
  scratch,
  ai,
  template,
}

/// Wizard exercise configuration
@freezed
sealed class WizardExercise with _$WizardExercise {
  const WizardExercise._();

  const factory WizardExercise({
    required String id,
    required String exerciseId,
    required String name,
    required String muscleGroup,
    @Default(3) int sets,
    @Default('10-12') String reps,
    @Default(60) int restSeconds,
    @Default('') String notes,
    // Advanced technique fields
    @Default('') String executionInstructions, // Individual exercise instructions
    @Default('') String groupInstructions,     // Group instructions (for bi-set, tri-set, etc.)
    int? isometricSeconds,
    @Default(TechniqueType.normal) TechniqueType techniqueType,
    String? exerciseGroupId,
    @Default(0) int exerciseGroupOrder,
    // Structured technique parameters (for dropset, rest-pause, cluster)
    int? dropCount,           // Dropset: number of drops (2-5)
    int? restBetweenDrops,    // Dropset: seconds between drops (0, 5, 10, 15)
    int? pauseDuration,       // Rest-Pause/Cluster: pause duration in seconds
    int? miniSetCount,        // Cluster: number of mini-sets (3-6)
    // Exercise mode (strength vs aerobic)
    @Default(ExerciseMode.strength) ExerciseMode exerciseMode,
    // Aerobic exercise fields - Duration mode (continuous cardio)
    int? durationMinutes,     // Total duration in minutes
    String? intensity,        // low, moderate, high, max
    // Aerobic exercise fields - Interval mode (HIIT)
    int? workSeconds,         // Work interval duration
    int? intervalRestSeconds, // Rest between intervals
    int? rounds,              // Number of rounds
    // Aerobic exercise fields - Distance mode (running)
    double? distanceKm,       // Distance in kilometers
    double? targetPaceMinPerKm, // Target pace (min/km)
  }) = _WizardExercise;

  /// Calculate estimated time for this exercise in seconds
  int get estimatedSeconds {
    // Handle aerobic exercise modes
    switch (exerciseMode) {
      case ExerciseMode.duration:
        // Continuous cardio - just duration
        return (durationMinutes ?? 30) * 60;
      case ExerciseMode.interval:
        // HIIT - rounds of work + rest
        final work = workSeconds ?? 30;
        final rest = intervalRestSeconds ?? 30;
        final numRounds = rounds ?? 10;
        return numRounds * (work + rest);
      case ExerciseMode.distance:
        // Distance-based - estimate from pace or default 6 min/km
        final distance = distanceKm ?? 5.0;
        final pace = targetPaceMinPerKm ?? 6.0;
        return (distance * pace * 60).toInt();
      case ExerciseMode.strength:
        // Fall through to strength mode logic below
        break;
    }

    // Strength mode - original logic
    // Base execution time per set (45s average)
    int execTimePerSet = 45;

    // Adjust for isometric holds
    if (isometricSeconds != null && isometricSeconds! > 0) {
      execTimePerSet = isometricSeconds! + 10; // hold + setup time
    }

    // Adjust for technique
    int restBetween;
    switch (techniqueType) {
      case TechniqueType.dropset:
        execTimePerSet = 90; // longer execution, multiple drops
        restBetween = 0;
      case TechniqueType.restPause:
        execTimePerSet = 60; // includes 10-15s micro-pauses
        restBetween = restSeconds;
      case TechniqueType.cluster:
        execTimePerSet = 75; // fractioned sets with intra-set rest
        restBetween = restSeconds;
      default:
        restBetween = restSeconds;
    }

    // Total time: execution + rest between sets (not after last set)
    return (sets * execTimePerSet) + ((sets - 1) * restBetween);
  }

  /// Formatted time string (e.g., "3:30")
  String get formattedTime {
    final minutes = estimatedSeconds ~/ 60;
    final seconds = estimatedSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Wizard workout configuration
@freezed
sealed class WizardWorkout with _$WizardWorkout {
  const factory WizardWorkout({
    required String id,
    required String label,
    required String name,
    @Default([]) List<String> muscleGroups,
    @Default([]) List<WizardExercise> exercises,
    @Default(0) int order,
    int? dayOfWeek,
  }) = _WizardWorkout;
}

/// Diet type enum
enum DietType {
  cutting,
  bulking,
  maintenance,
}

extension DietTypeExtension on DietType {
  String get displayName {
    switch (this) {
      case DietType.cutting:
        return 'Cutting (Definição)';
      case DietType.bulking:
        return 'Bulking (Massa)';
      case DietType.maintenance:
        return 'Manutenção';
    }
  }

  String get description {
    switch (this) {
      case DietType.cutting:
        return 'Déficit calórico para perda de gordura';
      case DietType.bulking:
        return 'Superávit calórico para ganho de massa';
      case DietType.maintenance:
        return 'Calorias para manter o peso atual';
    }
  }

  String toApiValue() {
    switch (this) {
      case DietType.cutting:
        return 'cutting';
      case DietType.bulking:
        return 'bulking';
      case DietType.maintenance:
        return 'maintenance';
    }
  }
}

/// Extension to parse DietType from string
extension DietTypeParsing on String? {
  DietType? toDietType() {
    if (this == null) return null;
    switch (this!.toLowerCase()) {
      case 'cutting':
        return DietType.cutting;
      case 'bulking':
        return DietType.bulking;
      case 'maintenance':
        return DietType.maintenance;
      default:
        return null;
    }
  }
}

/// Periodization phase type
enum PeriodizationPhase {
  progress,
  deload,
  newCycle,
}

extension PeriodizationPhaseExtension on PeriodizationPhase {
  String get displayName {
    switch (this) {
      case PeriodizationPhase.progress:
        return 'Progressão';
      case PeriodizationPhase.deload:
        return 'Deload';
      case PeriodizationPhase.newCycle:
        return 'Novo Ciclo';
    }
  }

  String get description {
    switch (this) {
      case PeriodizationPhase.progress:
        return 'Fase com cargas/volume aumentados';
      case PeriodizationPhase.deload:
        return 'Semana de recuperação com volume reduzido';
      case PeriodizationPhase.newCycle:
        return 'Novo ciclo baseado no plano anterior';
    }
  }

  String toApiValue() {
    switch (this) {
      case PeriodizationPhase.progress:
        return 'progress';
      case PeriodizationPhase.deload:
        return 'deload';
      case PeriodizationPhase.newCycle:
        return 'new_cycle';
    }
  }
}

extension PeriodizationPhaseParsing on String? {
  PeriodizationPhase? toPeriodizationPhase() {
    if (this == null) return null;
    switch (this!.toLowerCase()) {
      case 'progress':
        return PeriodizationPhase.progress;
      case 'deload':
        return PeriodizationPhase.deload;
      case 'new_cycle':
        return PeriodizationPhase.newCycle;
      default:
        return null;
    }
  }
}

/// Plan wizard state
@freezed
sealed class PlanWizardState with _$PlanWizardState {
  const PlanWizardState._();

  const factory PlanWizardState({
    @Default(0) int currentStep,
    CreationMethod? method,
    @Default('') String planName,
    @Default(WorkoutGoal.hypertrophy) WorkoutGoal goal,
    @Default(PlanDifficulty.intermediate) PlanDifficulty difficulty,
    @Default(SplitType.abc) SplitType splitType,
    int? durationWeeks,
    int? targetWorkoutMinutes, // Target duration per workout in minutes (null = free/unlimited)
    @Default([]) List<WizardWorkout> workouts,
    @Default(false) bool isLoading,
    String? error,
    @Default(false) bool isTemplate,
    String? templateId,
    String? studentId,
    String? editingPlanId,
    // Periodization fields
    String? basePlanId, // Source plan for periodization
    PeriodizationPhase? phaseType, // Type of periodization phase
    // Diet fields
    @Default(false) bool includeDiet,
    DietType? dietType,
    int? dailyCalories,
    int? proteinGrams,
    int? carbsGrams,
    int? fatGrams,
    int? mealsPerDay,
    String? dietNotes,
  }) = _PlanWizardState;

  /// Check if we're in edit mode
  bool get isEditing => editingPlanId != null;

  /// Check if current step is valid
  bool get isCurrentStepValid {
    switch (currentStep) {
      case 0:
        return method != null;
      case 1:
        return planName.trim().length >= 3;
      case 2:
        return true; // Split is always selected with default
      case 3:
        return workouts.isNotEmpty &&
            workouts.every((w) => w.exercises.isNotEmpty);
      case 4:
        // Diet step validation: if diet is included, calories must match macros
        if (!includeDiet) return true;
        return isCalorieMatchValid;
      case 5:
        return true; // Student assignment is optional
      case 6:
        return true; // Review step
      default:
        return false;
    }
  }

  /// Total step count (0-Method, 1-Info, 2-Split, 3-Workouts, 4-Diet, 5-Student, 6-Review)
  int get totalSteps => 7;

  /// Check if we're on the last step
  bool get isLastStep => currentStep == totalSteps - 1;

  /// Get total exercise count across all workouts
  int get totalExerciseCount {
    return workouts.fold<int>(0, (sum, w) => sum + w.exercises.length);
  }

  /// Get actual total duration calculated from exercises (in minutes)
  int get actualTotalMinutes {
    return workouts.fold<int>(0, (sum, w) {
      final exerciseDuration = w.exercises.fold<int>(0, (es, e) {
        return es + (e.sets * 45) + (e.sets * e.restSeconds);
      });
      return sum + (exerciseDuration ~/ 60);
    });
  }

  /// Check if daily calories match the calculated macros within tolerance
  /// Formula: (protein × 4) + (carbs × 4) + (fat × 9)
  /// Tolerance: ±100 kcal or ±5%, whichever is greater
  bool get isCalorieMatchValid {
    // If no calories set, no validation needed
    if (dailyCalories == null) return true;
    // If no macros set at all, no validation needed
    if (proteinGrams == null && carbsGrams == null && fatGrams == null) {
      return true;
    }

    final protein = proteinGrams ?? 0;
    final carbs = carbsGrams ?? 0;
    final fat = fatGrams ?? 0;
    final calculated = (protein * 4) + (carbs * 4) + (fat * 9);
    final target = dailyCalories!;

    // Margin: ±100 kcal or ±5%, whichever is greater
    final margin = max(100, (target * 0.05).round());
    return (calculated - target).abs() <= margin;
  }

  /// Get calculated calories from macros
  int get calculatedCalories {
    final protein = proteinGrams ?? 0;
    final carbs = carbsGrams ?? 0;
    final fat = fatGrams ?? 0;
    return (protein * 4) + (carbs * 4) + (fat * 9);
  }
}

/// Plan wizard notifier
class PlanWizardNotifier extends StateNotifier<PlanWizardState> {
  PlanWizardNotifier() : super(const PlanWizardState()) {
    // Generate default workout structure based on default split type (ABC)
    _generateWorkoutStructure();
  }

  // Step navigation
  void nextStep() {
    if (state.currentStep < state.totalSteps - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < state.totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  /// Cancel any loading operation and reset the loading state
  void cancelLoading() {
    state = state.copyWith(isLoading: false, error: null);
  }

  /// Restore workouts to a previous state (used for undo after cancellation)
  void restoreWorkouts(List<WizardWorkout> previousWorkouts) {
    state = state.copyWith(workouts: previousWorkouts, isLoading: false);
  }

  // Step 1: Method selection
  void selectMethod(CreationMethod method) {
    state = state.copyWith(method: method);
  }

  // Step 2: Plan info
  void setPlanName(String name) {
    state = state.copyWith(planName: name);
  }

  void setGoal(WorkoutGoal goal) {
    state = state.copyWith(goal: goal);
  }

  void setDifficulty(PlanDifficulty difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  void setDurationWeeks(int? weeks) {
    state = state.copyWith(durationWeeks: weeks);
  }

  void setTargetWorkoutMinutes(int? minutes) {
    state = state.copyWith(targetWorkoutMinutes: minutes);
  }

  void setIsTemplate(bool isTemplate) {
    state = state.copyWith(isTemplate: isTemplate);
  }

  void setStudentId(String? studentId) {
    state = state.copyWith(studentId: studentId);
  }

  // Diet configuration methods
  void setIncludeDiet(bool include) {
    state = state.copyWith(includeDiet: include);
    if (!include) {
      // Reset diet fields when not including diet
      state = state.copyWith(
        dietType: null,
        dailyCalories: null,
        proteinGrams: null,
        carbsGrams: null,
        fatGrams: null,
        mealsPerDay: null,
        dietNotes: null,
      );
    }
  }

  void setDietType(DietType? type) {
    state = state.copyWith(dietType: type);
  }

  void setDailyCalories(int? calories) {
    state = state.copyWith(dailyCalories: calories);
  }

  void setProteinGrams(int? grams) {
    state = state.copyWith(proteinGrams: grams);
  }

  void setCarbsGrams(int? grams) {
    state = state.copyWith(carbsGrams: grams);
  }

  void setFatGrams(int? grams) {
    state = state.copyWith(fatGrams: grams);
  }

  void setMealsPerDay(int? meals) {
    state = state.copyWith(mealsPerDay: meals);
  }

  void setDietNotes(String? notes) {
    state = state.copyWith(dietNotes: notes);
  }

  /// Load data from a template to clone
  void loadFromTemplate(Map<String, dynamic> template) {
    try {
      // Parse template data
      final name = '${template['name'] ?? 'Plano'} (Copia)';
      final goalStr = template['goal'] as String? ?? 'hypertrophy';
      final difficultyStr = template['difficulty'] as String? ?? 'intermediate';
      final splitTypeStr = template['split_type'] as String? ?? 'abc';
      final durationWeeks = template['duration_weeks'] as int?;
      final planWorkouts = (template['plan_workouts'] as List<dynamic>?) ?? [];

      if (planWorkouts.isEmpty) {
        state = state.copyWith(error: 'Template sem treinos definidos');
        return;
      }

      // Convert to wizard workouts
      final workouts = <WizardWorkout>[];
      for (final pw in planWorkouts) {
        final pwMap = pw as Map<String, dynamic>;
        final label = pwMap['label'] as String? ?? 'A';
        final workout = pwMap['workout'] as Map<String, dynamic>?;
        final workoutName = workout?['name'] as String? ?? 'Treino $label';
        final exercises = (workout?['exercises'] as List<dynamic>?) ?? [];

        final wizardExercises = <WizardExercise>[];
        for (final ex in exercises) {
          final exMap = ex as Map<String, dynamic>;
          final exerciseData = exMap['exercise'] as Map<String, dynamic>?;

          // Get exercise_id - could be UUID string or direct id
          String exerciseId = '';
          if (exMap['exercise_id'] != null) {
            exerciseId = exMap['exercise_id'].toString();
          }

          wizardExercises.add(WizardExercise(
            id: '${DateTime.now().millisecondsSinceEpoch}_${exerciseId.hashCode}',
            exerciseId: exerciseId,
            name: exerciseData?['name'] as String? ?? 'Exercício',
            muscleGroup: exerciseData?['muscle_group'] as String? ?? '',
            sets: exMap['sets'] as int? ?? 3,
            reps: (exMap['reps'] ?? '10-12').toString(),
            restSeconds: exMap['rest_seconds'] as int? ?? 60,
            notes: exMap['notes'] as String? ?? '',
            // Advanced technique fields
            executionInstructions: exMap['execution_instructions'] as String? ?? '',
            groupInstructions: exMap['group_instructions'] as String? ?? '',
            isometricSeconds: exMap['isometric_seconds'] as int?,
            techniqueType: (exMap['technique_type'] as String?)?.toTechniqueType() ?? TechniqueType.normal,
            exerciseGroupId: exMap['exercise_group_id'] as String?,
            exerciseGroupOrder: exMap['exercise_group_order'] as int? ?? 0,
          ));
        }

        workouts.add(WizardWorkout(
          id: label,
          label: label,
          name: workoutName,
          order: pwMap['order'] as int? ?? workouts.length,
          exercises: wizardExercises,
          muscleGroups: (workout?['target_muscles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
        ));
      }

      state = state.copyWith(
        templateId: template['id']?.toString(),
        planName: name,
        goal: goalStr.toWorkoutGoal(),
        difficulty: difficultyStr.toPlanDifficulty(),
        splitType: splitTypeStr.toSplitType(),
        durationWeeks: durationWeeks,
        workouts: workouts,
        currentStep: 1, // Go to step 1 (plan info) after loading template
        method: CreationMethod.template,
        isTemplate: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao processar template: $e');
    }
  }

  /// Load data from AI-generated plan
  void loadFromAIGenerated(Map<String, dynamic> aiData) {
    try {
      final name = aiData['name'] as String? ?? 'Plano IA';
      final description = aiData['description'] as String?;
      final goalStr = aiData['goal'] as String? ?? 'hypertrophy';
      final difficultyStr = aiData['difficulty'] as String? ?? 'intermediate';
      final splitTypeStr = aiData['split_type'] as String? ?? 'abc';
      final durationWeeks = aiData['duration_weeks'] as int?;
      final aiWorkouts = (aiData['workouts'] as List<dynamic>?) ?? [];

      // Convert AI workouts to wizard workouts
      final workouts = <WizardWorkout>[];
      for (final w in aiWorkouts) {
        final wMap = w as Map<String, dynamic>;
        final label = wMap['label'] as String? ?? String.fromCharCode(65 + workouts.length);
        final workoutName = wMap['name'] as String? ?? 'Treino $label';
        final exercises = (wMap['exercises'] as List<dynamic>?) ?? [];

        final wizardExercises = <WizardExercise>[];
        for (final ex in exercises) {
          final exMap = ex as Map<String, dynamic>;
          final exerciseId = exMap['exercise_id']?.toString() ?? '';

          wizardExercises.add(WizardExercise(
            id: '${DateTime.now().millisecondsSinceEpoch}_${exerciseId.hashCode}',
            exerciseId: exerciseId,
            name: exMap['name'] as String? ?? 'Exercício',
            muscleGroup: (exMap['muscle_group'] as String? ?? '').toString(),
            sets: exMap['sets'] as int? ?? 3,
            reps: (exMap['reps'] ?? '10-12').toString(),
            restSeconds: exMap['rest_seconds'] as int? ?? 60,
            notes: exMap['reason'] as String? ?? '',
            // Advanced technique fields
            executionInstructions: exMap['execution_instructions'] as String? ?? '',
            groupInstructions: exMap['group_instructions'] as String? ?? '',
            isometricSeconds: exMap['isometric_seconds'] as int?,
            techniqueType: (exMap['technique_type'] as String?)?.toTechniqueType() ?? TechniqueType.normal,
            exerciseGroupId: exMap['exercise_group_id'] as String?,
            exerciseGroupOrder: exMap['exercise_group_order'] as int? ?? 0,
          ));
        }

        // Parse target muscles from AI workout
        final targetMuscles = (wMap['target_muscles'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [];

        workouts.add(WizardWorkout(
          id: label,
          label: label,
          name: workoutName,
          order: wMap['order'] as int? ?? workouts.length,
          exercises: wizardExercises,
          muscleGroups: targetMuscles,
        ));
      }

      state = state.copyWith(
        planName: name,
        goal: goalStr.toWorkoutGoal(),
        difficulty: difficultyStr.toPlanDifficulty(),
        splitType: splitTypeStr.toSplitType(),
        durationWeeks: durationWeeks,
        workouts: workouts,
        method: CreationMethod.ai,
        isTemplate: false,
        error: null,
        currentStep: 2, // Go directly to workouts config step
      );
    } catch (e) {
      state = state.copyWith(error: 'Erro ao processar plano IA: $e');
    }
  }

  /// Load plan data for editing
  Future<void> loadPlanForEdit(String planId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final workoutService = WorkoutService();
      final plan = await workoutService.getPlan(planId);

      // Parse plan data
      final name = plan['name'] as String? ?? '';
      final goalStr = plan['goal'] as String? ?? 'hypertrophy';
      final difficultyStr = plan['difficulty'] as String? ?? 'intermediate';
      final splitTypeStr = plan['split_type'] as String? ?? 'abc';
      final durationWeeks = plan['duration_weeks'] as int?;
      final targetWorkoutMinutes = plan['target_workout_minutes'] as int?;
      final isTemplate = plan['is_template'] as bool? ?? false;
      final planWorkouts = (plan['plan_workouts'] as List<dynamic>?) ?? [];

      // Parse diet data
      final includeDiet = plan['include_diet'] as bool? ?? false;
      final dietTypeStr = plan['diet_type'] as String?;
      final dailyCalories = plan['daily_calories'] as int?;
      final proteinGrams = plan['protein_grams'] as int?;
      final carbsGrams = plan['carbs_grams'] as int?;
      final fatGrams = plan['fat_grams'] as int?;
      final mealsPerDay = plan['meals_per_day'] as int?;
      final dietNotes = plan['diet_notes'] as String?;

      // Convert to wizard workouts
      final workouts = planWorkouts.map((pw) {
        final pwMap = pw as Map<String, dynamic>;
        final label = pwMap['label'] as String? ?? '';
        final workout = pwMap['workout'] as Map<String, dynamic>?;
        final workoutName = workout?['name'] as String? ?? 'Treino $label';
        final exercises = (workout?['exercises'] as List<dynamic>?) ?? [];

        final wizardExercises = exercises.map((ex) {
          final exMap = ex as Map<String, dynamic>;
          final exerciseData = exMap['exercise'] as Map<String, dynamic>?;
          return WizardExercise(
            id: exMap['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
            exerciseId: exMap['exercise_id'] as String? ?? '',
            name: exerciseData?['name'] as String? ?? '',
            muscleGroup: exerciseData?['muscle_group'] as String? ?? '',
            sets: exMap['sets'] as int? ?? 3,
            reps: exMap['reps'] as String? ?? '10-12',
            restSeconds: exMap['rest_seconds'] as int? ?? 60,
            notes: exMap['notes'] as String? ?? '',
            // Advanced technique fields
            executionInstructions: exMap['execution_instructions'] as String? ?? '',
            groupInstructions: exMap['group_instructions'] as String? ?? '',
            isometricSeconds: exMap['isometric_seconds'] as int?,
            techniqueType: (exMap['technique_type'] as String?)?.toTechniqueType() ?? TechniqueType.normal,
            exerciseGroupId: exMap['exercise_group_id'] as String?,
            exerciseGroupOrder: exMap['exercise_group_order'] as int? ?? 0,
            // Structured technique parameters
            dropCount: exMap['drop_count'] as int?,
            restBetweenDrops: exMap['rest_between_drops'] as int?,
            pauseDuration: exMap['pause_duration'] as int?,
            miniSetCount: exMap['mini_set_count'] as int?,
            // Exercise mode (strength vs aerobic)
            exerciseMode: (exMap['exercise_mode'] as String?)?.toExerciseMode() ?? ExerciseMode.strength,
            // Aerobic exercise fields
            durationMinutes: exMap['duration_minutes'] as int?,
            intensity: exMap['intensity'] as String?,
            workSeconds: exMap['work_seconds'] as int?,
            intervalRestSeconds: exMap['interval_rest_seconds'] as int?,
            rounds: exMap['rounds'] as int?,
            distanceKm: (exMap['distance_km'] as num?)?.toDouble(),
            targetPaceMinPerKm: (exMap['target_pace_min_per_km'] as num?)?.toDouble(),
          );
        }).toList();

        return WizardWorkout(
          id: label,
          label: label,
          name: workoutName,
          order: pwMap['order'] as int? ?? 0,
          exercises: wizardExercises,
          muscleGroups: (workout?['target_muscles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
        );
      }).toList();

      state = state.copyWith(
        editingPlanId: planId,
        planName: name,
        goal: goalStr.toWorkoutGoal(),
        difficulty: difficultyStr.toPlanDifficulty(),
        splitType: splitTypeStr.toSplitType(),
        durationWeeks: durationWeeks,
        targetWorkoutMinutes: targetWorkoutMinutes,
        isTemplate: isTemplate,
        workouts: workouts,
        // Diet data
        includeDiet: includeDiet,
        dietType: dietTypeStr.toDietType(),
        dailyCalories: dailyCalories,
        proteinGrams: proteinGrams,
        carbsGrams: carbsGrams,
        fatGrams: fatGrams,
        mealsPerDay: mealsPerDay,
        dietNotes: dietNotes,
        // Navigation
        method: CreationMethod.scratch,
        currentStep: 1, // Skip method selection in edit mode
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load plan data for periodization (creating a new phase based on existing plan)
  Future<void> loadPlanForPeriodization(String basePlanId, PeriodizationPhase phaseType) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final workoutService = WorkoutService();
      final plan = await workoutService.getPlan(basePlanId);

      // Parse plan data
      final baseName = plan['name'] as String? ?? '';
      final goalStr = plan['goal'] as String? ?? 'hypertrophy';
      final difficultyStr = plan['difficulty'] as String? ?? 'intermediate';
      final splitTypeStr = plan['split_type'] as String? ?? 'abc';
      final durationWeeks = plan['duration_weeks'] as int?;
      final targetWorkoutMinutes = plan['target_workout_minutes'] as int?;
      final planWorkouts = (plan['plan_workouts'] as List<dynamic>?) ?? [];

      // Parse diet data
      final includeDiet = plan['include_diet'] as bool? ?? false;
      final dietTypeStr = plan['diet_type'] as String?;
      final dailyCalories = plan['daily_calories'] as int?;
      final proteinGrams = plan['protein_grams'] as int?;
      final carbsGrams = plan['carbs_grams'] as int?;
      final fatGrams = plan['fat_grams'] as int?;
      final mealsPerDay = plan['meals_per_day'] as int?;
      final dietNotes = plan['diet_notes'] as String?;

      // Generate new plan name based on phase type
      String newPlanName;
      switch (phaseType) {
        case PeriodizationPhase.progress:
          newPlanName = '$baseName - Progressão';
        case PeriodizationPhase.deload:
          newPlanName = '$baseName - Deload';
        case PeriodizationPhase.newCycle:
          newPlanName = '$baseName - Ciclo 2';
      }

      // Convert to wizard workouts with phase-specific adjustments
      final workouts = planWorkouts.map((pw) {
        final pwMap = pw as Map<String, dynamic>;
        final label = pwMap['label'] as String? ?? '';
        final workout = pwMap['workout'] as Map<String, dynamic>?;
        final workoutName = workout?['name'] as String? ?? 'Treino $label';
        final exercises = (workout?['exercises'] as List<dynamic>?) ?? [];

        final wizardExercises = exercises.map((ex) {
          final exMap = ex as Map<String, dynamic>;
          final exerciseData = exMap['exercise'] as Map<String, dynamic>?;

          // Base exercise values
          var sets = exMap['sets'] as int? ?? 3;
          var reps = exMap['reps'] as String? ?? '10-12';
          var restSeconds = exMap['rest_seconds'] as int? ?? 60;
          var notes = exMap['notes'] as String? ?? '';

          // Apply phase-specific adjustments
          switch (phaseType) {
            case PeriodizationPhase.progress:
              // Increase volume: +1 set, same reps
              sets = sets + 1;
              notes = notes.isEmpty ? 'Fase de progressão' : '$notes\nFase de progressão';
            case PeriodizationPhase.deload:
              // Reduce volume: ~50% sets, same reps, slightly longer rest
              sets = (sets * 0.5).ceil().clamp(1, sets);
              restSeconds = (restSeconds * 1.2).round();
              notes = notes.isEmpty ? 'Semana de deload - foco em recuperação' : '$notes\nSemana de deload';
            case PeriodizationPhase.newCycle:
              // Reset to original structure, no changes
              notes = notes.isEmpty ? 'Início do novo ciclo' : '$notes\nInício do novo ciclo';
          }

          return WizardExercise(
            id: '${DateTime.now().millisecondsSinceEpoch}_${exMap['id'] ?? ''}',
            exerciseId: exMap['exercise_id'] as String? ?? '',
            name: exerciseData?['name'] as String? ?? '',
            muscleGroup: exerciseData?['muscle_group'] as String? ?? '',
            sets: sets,
            reps: reps,
            restSeconds: restSeconds,
            notes: notes,
            // Advanced technique fields
            executionInstructions: exMap['execution_instructions'] as String? ?? '',
            groupInstructions: exMap['group_instructions'] as String? ?? '',
            isometricSeconds: exMap['isometric_seconds'] as int?,
            techniqueType: (exMap['technique_type'] as String?)?.toTechniqueType() ?? TechniqueType.normal,
            exerciseGroupId: exMap['exercise_group_id'] as String?,
            exerciseGroupOrder: exMap['exercise_group_order'] as int? ?? 0,
            // Structured technique parameters
            dropCount: exMap['drop_count'] as int?,
            restBetweenDrops: exMap['rest_between_drops'] as int?,
            pauseDuration: exMap['pause_duration'] as int?,
            miniSetCount: exMap['mini_set_count'] as int?,
            // Exercise mode (strength vs aerobic)
            exerciseMode: (exMap['exercise_mode'] as String?)?.toExerciseMode() ?? ExerciseMode.strength,
            // Aerobic exercise fields
            durationMinutes: exMap['duration_minutes'] as int?,
            intensity: exMap['intensity'] as String?,
            workSeconds: exMap['work_seconds'] as int?,
            intervalRestSeconds: exMap['interval_rest_seconds'] as int?,
            rounds: exMap['rounds'] as int?,
            distanceKm: (exMap['distance_km'] as num?)?.toDouble(),
            targetPaceMinPerKm: (exMap['target_pace_min_per_km'] as num?)?.toDouble(),
          );
        }).toList();

        return WizardWorkout(
          id: label,
          label: label,
          name: workoutName,
          order: pwMap['order'] as int? ?? 0,
          exercises: wizardExercises,
          muscleGroups: (workout?['target_muscles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
        );
      }).toList();

      // Adjust duration for deload (typically 1 week)
      int? newDurationWeeks = durationWeeks;
      if (phaseType == PeriodizationPhase.deload) {
        newDurationWeeks = 1; // Deload is typically 1 week
      }

      state = state.copyWith(
        basePlanId: basePlanId,
        phaseType: phaseType,
        planName: newPlanName,
        goal: goalStr.toWorkoutGoal(),
        difficulty: difficultyStr.toPlanDifficulty(),
        splitType: splitTypeStr.toSplitType(),
        durationWeeks: newDurationWeeks,
        targetWorkoutMinutes: targetWorkoutMinutes,
        isTemplate: false, // Periodized plans are not templates
        workouts: workouts,
        // Diet data (carry over from base plan)
        includeDiet: includeDiet,
        dietType: dietTypeStr.toDietType(),
        dailyCalories: dailyCalories,
        proteinGrams: proteinGrams,
        carbsGrams: carbsGrams,
        fatGrams: fatGrams,
        mealsPerDay: mealsPerDay,
        dietNotes: dietNotes,
        // Navigation - skip method selection for periodization
        method: CreationMethod.scratch,
        currentStep: 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Step 3: Split selection
  void selectSplit(SplitType splitType) {
    state = state.copyWith(splitType: splitType);
    _generateWorkoutStructure();
  }

  void _generateWorkoutStructure() {
    final workouts = <WizardWorkout>[];

    switch (state.splitType) {
      case SplitType.abc:
        workouts.addAll([
          WizardWorkout(
              id: 'A', label: 'A', name: 'Treino A', order: 0, muscleGroups: []),
          WizardWorkout(
              id: 'B', label: 'B', name: 'Treino B', order: 1, muscleGroups: []),
          WizardWorkout(
              id: 'C', label: 'C', name: 'Treino C', order: 2, muscleGroups: []),
        ]);
        break;
      case SplitType.abcd:
        workouts.addAll([
          WizardWorkout(
              id: 'A', label: 'A', name: 'Treino A', order: 0, muscleGroups: []),
          WizardWorkout(
              id: 'B', label: 'B', name: 'Treino B', order: 1, muscleGroups: []),
          WizardWorkout(
              id: 'C', label: 'C', name: 'Treino C', order: 2, muscleGroups: []),
          WizardWorkout(
              id: 'D', label: 'D', name: 'Treino D', order: 3, muscleGroups: []),
        ]);
        break;
      case SplitType.abcde:
        workouts.addAll([
          WizardWorkout(
              id: 'A', label: 'A', name: 'Treino A', order: 0, muscleGroups: []),
          WizardWorkout(
              id: 'B', label: 'B', name: 'Treino B', order: 1, muscleGroups: []),
          WizardWorkout(
              id: 'C', label: 'C', name: 'Treino C', order: 2, muscleGroups: []),
          WizardWorkout(
              id: 'D', label: 'D', name: 'Treino D', order: 3, muscleGroups: []),
          WizardWorkout(
              id: 'E', label: 'E', name: 'Treino E', order: 4, muscleGroups: []),
        ]);
        break;
      case SplitType.pushPullLegs:
        workouts.addAll([
          WizardWorkout(
              id: 'Push',
              label: 'Push',
              name: 'Push (Empurrar)',
              order: 0,
              muscleGroups: ['chest', 'shoulders', 'triceps']),
          WizardWorkout(
              id: 'Pull',
              label: 'Pull',
              name: 'Pull (Puxar)',
              order: 1,
              muscleGroups: ['back', 'biceps']),
          WizardWorkout(
              id: 'Legs',
              label: 'Legs',
              name: 'Legs (Pernas)',
              order: 2,
              muscleGroups: ['legs', 'glutes']),
        ]);
        break;
      case SplitType.upperLower:
        workouts.addAll([
          WizardWorkout(
              id: 'Upper',
              label: 'Upper',
              name: 'Upper (Superior)',
              order: 0,
              muscleGroups: ['chest', 'back', 'shoulders', 'biceps', 'triceps']),
          WizardWorkout(
              id: 'Lower',
              label: 'Lower',
              name: 'Lower (Inferior)',
              order: 1,
              muscleGroups: ['legs', 'glutes']),
        ]);
        break;
      case SplitType.fullBody:
        workouts.addAll([
          WizardWorkout(
              id: 'Full',
              label: 'Full',
              name: 'Full Body (Corpo Inteiro)',
              order: 0,
              muscleGroups: [
                'chest',
                'back',
                'shoulders',
                'legs',
                'biceps',
                'triceps'
              ]),
        ]);
        break;
      case SplitType.custom:
        // Start with empty for custom
        break;
    }

    state = state.copyWith(workouts: workouts);
  }

  // Step 4: Workout configuration

  /// Marks the plan as custom split when structural changes are made.
  /// Called when: adding/removing workouts, changing workout name/label.
  /// NOT called when: adding/removing exercises, changing muscle groups.
  void _markAsCustomSplit() {
    if (state.splitType != SplitType.custom) {
      state = state.copyWith(splitType: SplitType.custom);
    }
  }

  void addWorkout() {
    final label = String.fromCharCode(65 + state.workouts.length); // A, B, C...
    final workout = WizardWorkout(
      id: label,
      label: label,
      name: 'Treino $label',
      order: state.workouts.length,
      muscleGroups: [],
    );
    state = state.copyWith(workouts: [...state.workouts, workout]);
    _markAsCustomSplit();
  }

  void removeWorkout(String workoutId) {
    final workouts =
        state.workouts.where((w) => w.id != workoutId).toList();
    // Reorder remaining workouts
    for (var i = 0; i < workouts.length; i++) {
      workouts[i] = workouts[i].copyWith(order: i);
    }
    state = state.copyWith(workouts: workouts);
    _markAsCustomSplit();
  }

  void updateWorkoutName(String workoutId, String name) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        return w.copyWith(name: name);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
    _markAsCustomSplit();
  }

  /// Alias for updateWorkoutName - used by UI for clarity
  void renameWorkout(String workoutId, String newName) {
    updateWorkoutName(workoutId, newName);
  }

  /// Update workout label (A, B, C, etc.)
  void updateWorkoutLabel(String workoutId, String newLabel) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        return w.copyWith(label: newLabel);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
    _markAsCustomSplit();
  }

  /// Update workout completely (label, name, muscle groups)
  /// Only marks as custom split if label or name changes (not just muscle groups)
  void updateWorkout({
    required String workoutId,
    String? label,
    String? name,
    List<String>? muscleGroups,
  }) {
    // Check if label or name is being changed
    final workout = state.workouts.firstWhere(
      (w) => w.id == workoutId,
      orElse: () => const WizardWorkout(id: '', label: '', name: ''),
    );
    final isLabelChanged = label != null && label != workout.label;
    final isNameChanged = name != null && name != workout.name;

    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        return w.copyWith(
          label: label ?? w.label,
          name: name ?? w.name,
          muscleGroups: muscleGroups ?? w.muscleGroups,
        );
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);

    // Only mark as custom if label or name changed
    if (isLabelChanged || isNameChanged) {
      _markAsCustomSplit();
    }
  }

  /// Update workout and remove exercises that don't match the new muscle groups
  void updateWorkoutWithExerciseCleanup({
    required String workoutId,
    String? label,
    String? name,
    required List<String> muscleGroups,
  }) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        // Filter exercises to keep only those matching allowed muscle groups
        final filteredExercises = muscleGroups.isEmpty
            ? w.exercises // If no groups defined, keep all exercises
            : w.exercises.where((e) {
                final exerciseMuscle = e.muscleGroup.toLowerCase();
                return muscleGroups.any((g) {
                  final groupLower = g.toLowerCase();
                  final groupDisplayName = g.toMuscleGroup().displayName.toLowerCase();
                  return groupLower == exerciseMuscle ||
                      groupDisplayName == exerciseMuscle;
                });
              }).toList();

        return w.copyWith(
          label: label ?? w.label,
          name: name ?? w.name,
          muscleGroups: muscleGroups,
          exercises: filteredExercises,
        );
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Get exercises that would be removed if muscle groups change
  List<WizardExercise> getExercisesToRemove(String workoutId, List<String> newMuscleGroups) {
    final workout = state.workouts.firstWhere(
      (w) => w.id == workoutId,
      orElse: () => const WizardWorkout(id: '', label: '', name: ''),
    );

    if (newMuscleGroups.isEmpty) return []; // No restriction, keep all

    return workout.exercises.where((e) {
      final exerciseMuscle = e.muscleGroup.toLowerCase();
      return !newMuscleGroups.any((g) {
        final groupLower = g.toLowerCase();
        final groupDisplayName = g.toMuscleGroup().displayName.toLowerCase();
        return groupLower == exerciseMuscle || groupDisplayName == exerciseMuscle;
      });
    }).toList();
  }

  void setWorkoutMuscleGroups(String workoutId, List<String> groups) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        return w.copyWith(muscleGroups: groups);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  void addExerciseToWorkout(String workoutId, Exercise exercise) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final isCardio = exercise.muscleGroupName.toLowerCase() == 'cardio';

    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        final wizardExercise = isCardio
            ? WizardExercise(
                id: '${timestamp}_${exercise.id.hashCode}',
                exerciseId: exercise.id,
                name: exercise.name,
                muscleGroup: exercise.muscleGroupName,
                // Cardio defaults: no sets/reps/rest, use duration mode
                sets: 1,
                reps: '',
                restSeconds: 0,
                exerciseMode: ExerciseMode.duration,
                durationMinutes: 30,
                intensity: 'moderate',
              )
            : WizardExercise(
                id: '${timestamp}_${exercise.id.hashCode}',
                exerciseId: exercise.id,
                name: exercise.name,
                muscleGroup: exercise.muscleGroupName,
              );
        return w.copyWith(exercises: [...w.exercises, wizardExercise]);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Add multiple exercises to a workout in a single state update.
  /// This ensures all exercises are added atomically with unique IDs.
  void addExercisesToWorkout(String workoutId, List<Exercise> exercises) {
    if (exercises.isEmpty) return;

    final baseTimestamp = DateTime.now().millisecondsSinceEpoch;
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        final newExercises = exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          final isCardio = exercise.muscleGroupName.toLowerCase() == 'cardio';

          return isCardio
              ? WizardExercise(
                  id: '${baseTimestamp}_${index}_${exercise.id.hashCode}',
                  exerciseId: exercise.id,
                  name: exercise.name,
                  muscleGroup: exercise.muscleGroupName,
                  // Cardio defaults: no sets/reps/rest, use duration mode
                  sets: 1,
                  reps: '',
                  restSeconds: 0,
                  exerciseMode: ExerciseMode.duration,
                  durationMinutes: 30,
                  intensity: 'moderate',
                )
              : WizardExercise(
                  id: '${baseTimestamp}_${index}_${exercise.id.hashCode}',
                  exerciseId: exercise.id,
                  name: exercise.name,
                  muscleGroup: exercise.muscleGroupName,
                );
        }).toList();
        return w.copyWith(exercises: [...w.exercises, ...newExercises]);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  void removeExerciseFromWorkout(String workoutId, String exerciseId) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        // Find the exercise to check if it's in a group
        final exerciseToRemove = w.exercises.firstWhere(
          (e) => e.id == exerciseId,
          orElse: () => const WizardExercise(id: '', exerciseId: '', name: '', muscleGroup: ''),
        );
        final groupId = exerciseToRemove.exerciseGroupId;

        // Remove the exercise
        var exercises = w.exercises.where((e) => e.id != exerciseId).toList();

        // Renumber if it was in a group
        if (groupId != null && groupId.isNotEmpty) {
          exercises = _renumberGroup(exercises, groupId);
        }

        return w.copyWith(exercises: exercises);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  void updateExercise(
      String workoutId, String exerciseId, WizardExercise updated) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        final exercises = w.exercises.map((e) {
          if (e.id == exerciseId) {
            return updated;
          }
          return e;
        }).toList();
        return w.copyWith(exercises: exercises);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Reorder exercises using UI indices (where groups count as 1 item).
  /// This method converts UI indices to data indices and handles groups properly.
  void reorderExercises(String workoutId, int uiOldIndex, int uiNewIndex) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        final exercises = List<WizardExercise>.from(w.exercises);

        // Build UI-to-data index mapping
        final uiToDataMapping = _buildUiToDataMapping(exercises);

        if (uiOldIndex >= uiToDataMapping.length) return w;

        final oldMapping = uiToDataMapping[uiOldIndex];
        final isMovingGroup = oldMapping.isGroup;

        // Adjust uiNewIndex for ReorderableListView behavior
        var adjustedUiNewIndex = uiNewIndex;
        if (adjustedUiNewIndex > uiOldIndex) {
          adjustedUiNewIndex -= 1;
        }
        adjustedUiNewIndex = adjustedUiNewIndex.clamp(0, uiToDataMapping.length - 1);

        // If moving to same position, no change needed
        if (adjustedUiNewIndex == uiOldIndex) return w;

        if (isMovingGroup) {
          // Moving an entire group
          return w.copyWith(
            exercises: _reorderGroup(
              exercises,
              oldMapping.groupId!,
              uiOldIndex,
              adjustedUiNewIndex,
              uiToDataMapping,
            ),
          );
        } else {
          // Moving a single ungrouped exercise
          return w.copyWith(
            exercises: _reorderSingleExercise(
              exercises,
              oldMapping.dataStartIndex,
              uiOldIndex,
              adjustedUiNewIndex,
              uiToDataMapping,
            ),
          );
        }
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Mapping from UI position to data indices
  List<_UiDataMapping> _buildUiToDataMapping(List<WizardExercise> exercises) {
    final mapping = <_UiDataMapping>[];
    final processedGroups = <String>{};

    for (var i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];
      final groupId = exercise.exerciseGroupId;

      if (groupId == null) {
        // Ungrouped exercise
        mapping.add(_UiDataMapping(
          dataStartIndex: i,
          dataEndIndex: i,
          isGroup: false,
          groupId: null,
        ));
      } else if (!processedGroups.contains(groupId)) {
        // First exercise of a group
        processedGroups.add(groupId);

        // Find all exercises in this group
        var endIndex = i;
        for (var j = i + 1; j < exercises.length; j++) {
          if (exercises[j].exerciseGroupId == groupId) {
            endIndex = j;
          } else {
            break;
          }
        }

        mapping.add(_UiDataMapping(
          dataStartIndex: i,
          dataEndIndex: endIndex,
          isGroup: true,
          groupId: groupId,
        ));
      }
      // Skip subsequent exercises of already processed groups
    }

    return mapping;
  }

  /// Reorder a single ungrouped exercise
  List<WizardExercise> _reorderSingleExercise(
    List<WizardExercise> exercises,
    int dataIndex,
    int uiOldIndex,
    int uiNewIndex,
    List<_UiDataMapping> mapping,
  ) {
    final result = List<WizardExercise>.from(exercises);
    final item = result.removeAt(dataIndex);

    // Calculate new data index based on target UI position
    int newDataIndex;
    if (uiNewIndex >= mapping.length) {
      newDataIndex = result.length;
    } else if (uiNewIndex < uiOldIndex) {
      // Moving up - insert at the start of the target UI position
      newDataIndex = mapping[uiNewIndex].dataStartIndex;
      // Adjust because we removed an item before this position
      if (dataIndex < newDataIndex) {
        newDataIndex -= 1;
      }
    } else {
      // Moving down - insert AFTER the target UI position
      // So we use dataEndIndex + 1 to place after the target item
      newDataIndex = mapping[uiNewIndex].dataEndIndex + 1;
      // Adjust because we removed an item before this position
      if (dataIndex < newDataIndex) {
        newDataIndex -= 1;
      }
    }

    newDataIndex = newDataIndex.clamp(0, result.length);
    result.insert(newDataIndex, item);

    return result;
  }

  /// Reorder an entire group
  List<WizardExercise> _reorderGroup(
    List<WizardExercise> exercises,
    String groupId,
    int uiOldIndex,
    int uiNewIndex,
    List<_UiDataMapping> mapping,
  ) {
    final oldMapping = mapping[uiOldIndex];
    final groupSize = oldMapping.dataEndIndex - oldMapping.dataStartIndex + 1;

    // Extract group exercises
    final groupExercises = exercises
        .sublist(oldMapping.dataStartIndex, oldMapping.dataEndIndex + 1);

    // Remove group from list
    final result = <WizardExercise>[
      ...exercises.sublist(0, oldMapping.dataStartIndex),
      ...exercises.sublist(oldMapping.dataEndIndex + 1),
    ];

    // Calculate new insertion point
    int insertIndex;
    if (uiNewIndex >= mapping.length - 1) {
      insertIndex = result.length;
    } else if (uiNewIndex < uiOldIndex) {
      // Moving up - insert at the start of the target UI position
      insertIndex = mapping[uiNewIndex].dataStartIndex;
    } else {
      // Moving down - we need to recalculate because we removed items
      // Find the target in the new mapping (after group removal)
      final targetMapping = mapping[uiNewIndex + 1]; // +1 because we removed one UI item
      insertIndex = targetMapping.dataStartIndex - groupSize;
    }

    insertIndex = insertIndex.clamp(0, result.length);
    result.insertAll(insertIndex, groupExercises);

    return result;
  }

  /// Reorder exercises within a group (by exercise ID, not UI index)
  void reorderWithinGroup(String workoutId, String groupId, int oldGroupOrder, int newGroupOrder) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        final exercises = List<WizardExercise>.from(w.exercises);

        // Find group exercises
        final groupExercises = exercises
            .where((e) => e.exerciseGroupId == groupId)
            .toList()
          ..sort((a, b) => a.exerciseGroupOrder.compareTo(b.exerciseGroupOrder));

        if (oldGroupOrder >= groupExercises.length || newGroupOrder >= groupExercises.length) {
          return w;
        }

        // Reorder within group
        final item = groupExercises.removeAt(oldGroupOrder);
        groupExercises.insert(newGroupOrder, item);

        // Update exerciseGroupOrder
        for (var i = 0; i < groupExercises.length; i++) {
          groupExercises[i] = groupExercises[i].copyWith(exerciseGroupOrder: i);
        }

        // Rebuild exercises list maintaining group position
        final groupStartIndex = exercises.indexWhere((e) => e.exerciseGroupId == groupId);
        final result = <WizardExercise>[];
        var groupInserted = false;

        for (var i = 0; i < exercises.length; i++) {
          if (exercises[i].exerciseGroupId == groupId) {
            if (!groupInserted) {
              result.addAll(groupExercises);
              groupInserted = true;
            }
          } else {
            result.add(exercises[i]);
          }
        }

        return w.copyWith(exercises: result);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Copy an exercise from one workout to another
  void copyExerciseToWorkout(String fromWorkoutId, String exerciseId, String toWorkoutId) {
    // Find the exercise to copy
    WizardExercise? exerciseToCopy;
    for (final w in state.workouts) {
      if (w.id == fromWorkoutId) {
        for (final e in w.exercises) {
          if (e.id == exerciseId) {
            exerciseToCopy = e;
            break;
          }
        }
        break;
      }
    }

    if (exerciseToCopy == null) return;

    // Create a copy with a new ID
    final copiedExercise = exerciseToCopy.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    // Add to target workout
    final workouts = state.workouts.map((w) {
      if (w.id == toWorkoutId) {
        return w.copyWith(exercises: [...w.exercises, copiedExercise]);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Add a technique-based exercise group to a workout.
  /// This method creates multiple WizardExercise entries with a shared groupId,
  /// properly configured for the selected technique.
  void addTechniqueGroup({
    required String workoutId,
    required TechniqueType technique,
    required List<Exercise> exercises,
    int? dropCount,
    int? restBetweenDrops,
    int? pauseDuration,
    int? miniSetCount,
    String? executionInstructions,
  }) {
    // Generate unique group ID for multi-exercise techniques
    final groupId = techniqueRequiresGrouping(technique)
        ? 'group_${DateTime.now().millisecondsSinceEpoch}'
        : null;

    // Build execution instructions from technique config
    String instructions = executionInstructions ?? '';
    if (technique == TechniqueType.dropset && dropCount != null) {
      final dropInfo = '$dropCount drops${restBetweenDrops != null && restBetweenDrops > 0 ? ', ${restBetweenDrops}s descanso' : ', sem descanso'}';
      instructions = instructions.isEmpty ? dropInfo : '$instructions\n$dropInfo';
    } else if (technique == TechniqueType.restPause && pauseDuration != null) {
      final pauseInfo = 'Pausa de ${pauseDuration}s entre mini-falhas';
      instructions = instructions.isEmpty ? pauseInfo : '$instructions\n$pauseInfo';
    } else if (technique == TechniqueType.cluster && miniSetCount != null) {
      final clusterInfo = '$miniSetCount mini-sets com ${pauseDuration ?? 10}s de pausa';
      instructions = instructions.isEmpty ? clusterInfo : '$instructions\n$clusterInfo';
    }

    // Create WizardExercise entries
    final wizardExercises = exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final exercise = entry.value;
      final timestamp = DateTime.now().millisecondsSinceEpoch + index;

      return WizardExercise(
        id: timestamp.toString(),
        exerciseId: exercise.id,
        name: exercise.name,
        muscleGroup: exercise.muscleGroupName,
        techniqueType: technique,
        exerciseGroupId: groupId,
        exerciseGroupOrder: index,
        executionInstructions: instructions,
        // For supersets/trisets, rest only after the last exercise
        restSeconds: groupId != null && index < exercises.length - 1 ? 0 : 60,
        // Store structured technique parameters
        dropCount: technique == TechniqueType.dropset ? dropCount : null,
        restBetweenDrops: technique == TechniqueType.dropset ? restBetweenDrops : null,
        pauseDuration: (technique == TechniqueType.restPause || technique == TechniqueType.cluster) ? pauseDuration : null,
        miniSetCount: technique == TechniqueType.cluster ? miniSetCount : null,
      );
    }).toList();

    // Add all exercises to the workout
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        return w.copyWith(
          exercises: [...w.exercises, ...wizardExercises],
        );
      }
      return w;
    }).toList();

    state = state.copyWith(workouts: workouts);
  }

  /// Add a single exercise with a technique (for drop set, rest-pause, cluster)
  void addSingleTechniqueExercise({
    required String workoutId,
    required TechniqueType technique,
    required Exercise exercise,
    int? dropCount,
    int? restBetweenDrops,
    int? pauseDuration,
    int? miniSetCount,
    String? executionInstructions,
  }) {
    addTechniqueGroup(
      workoutId: workoutId,
      technique: technique,
      exercises: [exercise],
      dropCount: dropCount,
      restBetweenDrops: restBetweenDrops,
      pauseDuration: pauseDuration,
      miniSetCount: miniSetCount,
      executionInstructions: executionInstructions,
    );
  }

  /// Create an exercise group for techniques like biset, superset, triset, giantset.
  /// Automatically determines the technique type based on exercise count:
  /// - 2 exercises → keeps user's choice (biset or superset), defaults to biset
  /// - 3 exercises → triset
  /// - 4+ exercises → giantset
  /// Returns the group ID if successful
  String? createExerciseGroup({
    required String workoutId,
    required List<String> exerciseIds,
    TechniqueType? techniqueType,
  }) {
    if (exerciseIds.length < 2) return null;

    // Determine technique type based on exercise count
    // For 2 exercises: keep user's choice (biset or superset), default to biset
    // For 3 exercises: always triset
    // For 4+ exercises: always giantset
    TechniqueType finalTechniqueType;
    if (exerciseIds.length == 2) {
      // Keep biset or superset if specified, default to biset
      if (techniqueType == TechniqueType.biset || techniqueType == TechniqueType.superset) {
        finalTechniqueType = techniqueType!;
      } else {
        finalTechniqueType = TechniqueType.biset;
      }
    } else if (exerciseIds.length == 3) {
      finalTechniqueType = TechniqueType.triset;
    } else {
      finalTechniqueType = TechniqueType.giantset;
    }

    // Generate a unique group ID
    final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';

    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        int groupOrder = 0;
        final exercises = w.exercises.map((e) {
          if (exerciseIds.contains(e.id)) {
            final updated = e.copyWith(
              exerciseGroupId: groupId,
              exerciseGroupOrder: groupOrder++,
              techniqueType: finalTechniqueType,
            );
            return updated;
          }
          return e;
        }).toList();
        return w.copyWith(exercises: exercises);
      }
      return w;
    }).toList();

    state = state.copyWith(workouts: workouts);
    return groupId;
  }

  /// Remove an exercise from its group and renumber remaining exercises
  void removeFromExerciseGroup(String workoutId, String exerciseId) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        // Find the exercise to get its group ID before modification
        final exerciseToRemove = w.exercises.firstWhere(
          (e) => e.id == exerciseId,
          orElse: () => const WizardExercise(id: '', exerciseId: '', name: '', muscleGroup: ''),
        );
        final groupId = exerciseToRemove.exerciseGroupId;

        // Remove from group (set to null)
        var exercises = w.exercises.map((e) {
          if (e.id == exerciseId) {
            return e.copyWith(
              exerciseGroupId: null,
              exerciseGroupOrder: 0,
              techniqueType: TechniqueType.normal,
              groupInstructions: '', // Clear group instructions
              restSeconds: 60, // Reset rest to default
            );
          }
          return e;
        }).toList();

        // Renumber remaining exercises in the group
        if (groupId != null && groupId.isNotEmpty) {
          exercises = _renumberGroup(exercises, groupId);
        }

        return w.copyWith(exercises: exercises);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Disband an entire exercise group
  void disbandExerciseGroup(String workoutId, String groupId) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        final exercises = w.exercises.map((e) {
          if (e.exerciseGroupId == groupId) {
            return e.copyWith(
              exerciseGroupId: null,
              exerciseGroupOrder: 0,
              techniqueType: TechniqueType.normal,
              groupInstructions: '', // Clear group instructions
            );
          }
          return e;
        }).toList();
        return w.copyWith(exercises: exercises);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Delete an entire exercise group (removes all exercises in the group)
  void deleteExerciseGroup(String workoutId, String groupId) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        // Remove all exercises with this group ID
        final exercises = w.exercises.where((e) => e.exerciseGroupId != groupId).toList();
        return w.copyWith(exercises: exercises);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Add an exercise to an existing group
  void addExerciseToGroup({
    required String workoutId,
    required String groupId,
    required Exercise exercise,
  }) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        // Find the group's exercises to determine the next order
        final groupExercises = w.exercises.where((e) => e.exerciseGroupId == groupId).toList();
        if (groupExercises.isEmpty) return w;

        // Get technique type from existing group members
        final techniqueType = groupExercises.first.techniqueType;
        final nextOrder = groupExercises.map((e) => e.exerciseGroupOrder).reduce((a, b) => a > b ? a : b) + 1;

        // Update technique type based on new group size
        // 2 exercises → keep biset or superset (preserve user choice)
        // 3 exercises → triset
        // 4+ exercises → giantset
        final newGroupSize = groupExercises.length + 1;
        final currentType = techniqueType;
        TechniqueType newTechniqueType;
        if (newGroupSize == 2) {
          // Keep biset or superset
          if (currentType == TechniqueType.biset || currentType == TechniqueType.superset) {
            newTechniqueType = currentType;
          } else {
            newTechniqueType = TechniqueType.biset;
          }
        } else if (newGroupSize == 3) {
          newTechniqueType = TechniqueType.triset;
        } else {
          newTechniqueType = TechniqueType.giantset;
        }

        // Create new WizardExercise with group fields
        // Note: Don't copy group instructions - they stay on the leader only
        final newExercise = WizardExercise(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          exerciseId: exercise.id,
          name: exercise.name,
          muscleGroup: exercise.muscleGroupName,
          techniqueType: newTechniqueType,
          exerciseGroupId: groupId,
          exerciseGroupOrder: nextOrder,
          // Keep individual exercise instructions empty (don't copy group instructions)
          executionInstructions: '',
          // Rest is 0 for non-last exercises in group
          restSeconds: 0,
        );

        // Find the position of the last group exercise
        final lastGroupExerciseIndex = w.exercises.lastIndexWhere((e) => e.exerciseGroupId == groupId);

        // Insert the new exercise right after the last group exercise
        final updatedExercises = List<WizardExercise>.from(w.exercises);

        // Update existing group exercises technique type and fix rest times
        for (var i = 0; i < updatedExercises.length; i++) {
          if (updatedExercises[i].exerciseGroupId == groupId) {
            updatedExercises[i] = updatedExercises[i].copyWith(
              techniqueType: newTechniqueType,
              restSeconds: 0, // All existing will have 0 rest (new one at end will get rest)
            );
          }
        }

        // Insert new exercise and set appropriate rest time
        updatedExercises.insert(lastGroupExerciseIndex + 1, newExercise.copyWith(restSeconds: 60));

        return w.copyWith(exercises: updatedExercises);
      }
      return w;
    }).toList();

    state = state.copyWith(workouts: workouts);
  }

  /// Move an existing exercise from the workout into a group
  void addExistingExerciseToGroup({
    required String workoutId,
    required String groupId,
    required String exerciseId,
  }) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        // Find the exercise to move
        final exerciseIndex = w.exercises.indexWhere((e) => e.id == exerciseId);
        if (exerciseIndex == -1) return w;

        final exerciseToMove = w.exercises[exerciseIndex];

        // Find the group's exercises to determine the next order
        final groupExercises = w.exercises.where((e) => e.exerciseGroupId == groupId).toList();
        if (groupExercises.isEmpty) return w;

        // Get technique type from existing group members
        final nextOrder = groupExercises.map((e) => e.exerciseGroupOrder).reduce((a, b) => a > b ? a : b) + 1;

        // Update technique type based on new group size
        // 2 exercises → keep biset or superset (preserve user choice)
        // 3 exercises → triset
        // 4+ exercises → giantset
        final newGroupSize = groupExercises.length + 1;
        final currentType = groupExercises.first.techniqueType;
        TechniqueType newTechniqueType;
        if (newGroupSize == 2) {
          // Keep biset or superset
          if (currentType == TechniqueType.biset || currentType == TechniqueType.superset) {
            newTechniqueType = currentType;
          } else {
            newTechniqueType = TechniqueType.biset;
          }
        } else if (newGroupSize == 3) {
          newTechniqueType = TechniqueType.triset;
        } else {
          newTechniqueType = TechniqueType.giantset;
        }

        // Update the exercise with group fields
        // Copy groupInstructions from existing group, keep individual executionInstructions
        final existingGroupInstructions = groupExercises.first.groupInstructions;
        final updatedExercise = exerciseToMove.copyWith(
          techniqueType: newTechniqueType,
          exerciseGroupId: groupId,
          exerciseGroupOrder: nextOrder,
          groupInstructions: existingGroupInstructions, // Copy group instructions
          // Keep the exercise's own executionInstructions intact
          restSeconds: 60, // Last exercise in group gets rest
        );

        // Remove the exercise from its current position
        final updatedExercises = List<WizardExercise>.from(w.exercises);
        updatedExercises.removeAt(exerciseIndex);

        // Update existing group exercises technique type and fix rest times
        for (var i = 0; i < updatedExercises.length; i++) {
          if (updatedExercises[i].exerciseGroupId == groupId) {
            updatedExercises[i] = updatedExercises[i].copyWith(
              techniqueType: newTechniqueType,
              restSeconds: 0, // All existing will have 0 rest
            );
          }
        }

        // Find the position of the last group exercise and insert after it
        final lastGroupExerciseIndex = updatedExercises.lastIndexWhere((e) => e.exerciseGroupId == groupId);
        if (lastGroupExerciseIndex >= 0) {
          updatedExercises.insert(lastGroupExerciseIndex + 1, updatedExercise);
        } else {
          updatedExercises.add(updatedExercise);
        }

        return w.copyWith(exercises: updatedExercises);
      }
      return w;
    }).toList();

    state = state.copyWith(workouts: workouts);
  }

  /// Update group instructions for all exercises in the group
  void updateGroupInstructions({
    required String workoutId,
    required String groupId,
    required String instructions,
  }) {
    final workouts = state.workouts.map((w) {
      if (w.id == workoutId) {
        // Update groupInstructions on ALL exercises in the group
        final exercises = w.exercises.map((e) {
          if (e.exerciseGroupId == groupId) {
            return e.copyWith(groupInstructions: instructions);
          }
          return e;
        }).toList();
        return w.copyWith(exercises: exercises);
      }
      return w;
    }).toList();
    state = state.copyWith(workouts: workouts);
  }

  /// Helper to renumber exercises in a group and auto-disband if only 1 remains
  List<WizardExercise> _renumberGroup(List<WizardExercise> exercises, String groupId) {
    final result = <WizardExercise>[];
    int groupOrder = 0;
    int groupCount = exercises.where((e) => e.exerciseGroupId == groupId).length;

    // If only one exercise remains, disband the group
    if (groupCount <= 1) {
      for (final exercise in exercises) {
        if (exercise.exerciseGroupId == groupId) {
          result.add(exercise.copyWith(
            exerciseGroupId: null,
            exerciseGroupOrder: 0,
            techniqueType: TechniqueType.normal,
            restSeconds: 60, // Reset rest to default
          ));
        } else {
          result.add(exercise);
        }
      }
      return result;
    }

    // Update technique type based on remaining group size
    // 2 exercises → keep biset or superset (preserve user choice)
    // 3 exercises → triset
    // 4+ exercises → giantset
    final currentType = exercises.firstWhere((e) => e.exerciseGroupId == groupId).techniqueType;
    TechniqueType newTechniqueType;
    if (groupCount == 2) {
      // Keep biset or superset if already set, otherwise default to biset
      if (currentType == TechniqueType.biset || currentType == TechniqueType.superset) {
        newTechniqueType = currentType;
      } else {
        newTechniqueType = TechniqueType.biset;
      }
    } else if (groupCount == 3) {
      newTechniqueType = TechniqueType.triset;
    } else {
      newTechniqueType = TechniqueType.giantset;
    }

    // Renumber and update technique type
    final groupExercises = <WizardExercise>[];
    for (final exercise in exercises) {
      if (exercise.exerciseGroupId == groupId) {
        groupExercises.add(exercise);
      } else {
        result.add(exercise);
      }
    }

    // Sort by current order and reassign
    groupExercises.sort((a, b) => a.exerciseGroupOrder.compareTo(b.exerciseGroupOrder));
    for (var i = 0; i < groupExercises.length; i++) {
      final isLast = i == groupExercises.length - 1;
      result.add(groupExercises[i].copyWith(
        exerciseGroupOrder: i,
        techniqueType: newTechniqueType,
        restSeconds: isLast ? 60 : 0, // Only last exercise has rest
      ));
    }

    return result;
  }

  /// Get all exercises in a group within a workout
  List<WizardExercise> getExercisesInGroup(String workoutId, String groupId) {
    final workout = state.workouts.firstWhere(
      (w) => w.id == workoutId,
      orElse: () => const WizardWorkout(id: '', label: '', name: ''),
    );
    return workout.exercises
        .where((e) => e.exerciseGroupId == groupId)
        .toList()
      ..sort((a, b) => a.exerciseGroupOrder.compareTo(b.exerciseGroupOrder));
  }

  /// Check if a technique type requires grouping
  static bool techniqueRequiresGrouping(TechniqueType type) {
    return type == TechniqueType.superset ||
        type == TechniqueType.biset ||
        type == TechniqueType.triset ||
        type == TechniqueType.giantset;
  }

  // AI Integration
  /// Returns a map with 'success' (bool), 'message' (String), and 'count' (int)
  Future<Map<String, dynamic>> suggestExercisesForWorkout(
    String workoutId, {
    List<String>? allowedTechniques,
    List<String>? muscleGroups,
    int count = 6,
  }) async {
    final workout = state.workouts.firstWhere((w) => w.id == workoutId);

    // Use passed muscle groups or fallback to workout's muscle groups
    final effectiveMuscleGroups = muscleGroups ?? workout.muscleGroups;

    if (effectiveMuscleGroups.isEmpty) {
      return {
        'success': false,
        'message': 'Selecione pelo menos um grupo muscular antes de sugerir exercícios',
        'count': 0,
      };
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final workoutService = WorkoutService();

      // Get existing exercise IDs and names to exclude
      final existingIds = workout.exercises.map((e) => e.exerciseId).toList();
      final existingNames = workout.exercises.map((e) => e.name).toList();

      // Determine if advanced techniques are allowed based on selection
      final hasAdvancedTechniques = allowedTechniques != null &&
          allowedTechniques.any((t) => t != 'normal');

      // Call the API to get suggestions with workout context
      final response = await workoutService.suggestExercises(
        muscleGroups: effectiveMuscleGroups,
        goal: state.goal.toApiValue(),
        difficulty: state.difficulty.toApiValue(),
        count: count,
        excludeExerciseIds: existingIds.isNotEmpty ? existingIds : null,
        // Workout context
        workoutName: workout.name,
        workoutLabel: workout.label,
        planName: state.planName,
        planGoal: state.goal.toApiValue(),
        planSplitType: state.splitType.toApiValue(),
        existingExercises: existingNames.isNotEmpty ? existingNames : null,
        existingExerciseCount: workout.exercises.length,
        allowAdvancedTechniques: hasAdvancedTechniques,
        allowedTechniques: allowedTechniques,
      );

      final suggestions = (response['suggestions'] as List<dynamic>?) ?? [];
      final apiMessage = response['message'] as String?;

      if (suggestions.isEmpty) {
        state = state.copyWith(isLoading: false);
        return {
          'success': false,
          'message': apiMessage ?? 'Nenhum exercício encontrado. Execute o seed de exercícios no backend.',
          'count': 0,
        };
      }

      final workouts = state.workouts.map((w) {
        if (w.id == workoutId) {
          final wizardExercises = suggestions.map((s) {
            final sMap = s as Map<String, dynamic>;
            // Parse technique type from API response using the extension method
            final techniqueStr = sMap['technique_type'] as String? ?? 'normal';
            final techniqueType = techniqueStr.toTechniqueType();
            return WizardExercise(
              id: DateTime.now().millisecondsSinceEpoch.toString() + (sMap['exercise_id'] as String? ?? ''),
              exerciseId: sMap['exercise_id'] as String? ?? '',
              name: sMap['name'] as String? ?? '',
              muscleGroup: sMap['muscle_group'] as String? ?? '',
              sets: sMap['sets'] as int? ?? 3,
              reps: sMap['reps'] as String? ?? '10-12',
              restSeconds: sMap['rest_seconds'] as int? ?? 60,
              // Advanced technique fields from AI
              techniqueType: techniqueType,
              exerciseGroupId: sMap['exercise_group_id'] as String?,
              exerciseGroupOrder: sMap['exercise_group_order'] as int? ?? 0,
              executionInstructions: sMap['execution_instructions'] as String? ?? '',
              isometricSeconds: sMap['isometric_seconds'] as int?,
            );
          }).toList();
          return w.copyWith(exercises: [...w.exercises, ...wizardExercises]);
        }
        return w;
      }).toList();

      state = state.copyWith(workouts: workouts, isLoading: false);
      return {
        'success': true,
        'message': apiMessage ?? '${suggestions.length} exercícios sugeridos!',
        'count': suggestions.length,
      };
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {
        'success': false,
        'message': 'Erro ao sugerir exercícios: ${e.toString()}',
        'count': 0,
      };
    }
  }

  // Step 5: Create or update plan
  Future<String?> createPlan() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final workoutService = WorkoutService();

      final workoutsData = state.workouts.map((w) {
        return {
          'label': w.label,
          'workout_name': w.name,
          'order': w.order,
          'muscle_groups': w.muscleGroups,
          'workout_exercises': w.exercises.asMap().entries.map((entry) {
            final e = entry.value;
            final order = entry.key;
            return {
              'exercise_id': e.exerciseId,
              'order': order,
              'sets': e.sets,
              'reps': e.reps,
              'rest_seconds': e.restSeconds,
              'notes': e.notes,
              // Advanced technique fields
              'execution_instructions': e.executionInstructions.isNotEmpty ? e.executionInstructions : null,
              'group_instructions': e.groupInstructions.isNotEmpty ? e.groupInstructions : null,
              'isometric_seconds': e.isometricSeconds,
              'technique_type': e.techniqueType.toApiValue(),
              'exercise_group_id': e.exerciseGroupId,
              'exercise_group_order': e.exerciseGroupOrder,
              // Structured technique parameters
              'drop_count': e.dropCount,
              'rest_between_drops': e.restBetweenDrops,
              'pause_duration': e.pauseDuration,
              'mini_set_count': e.miniSetCount,
              // Exercise mode (strength vs aerobic)
              'exercise_mode': e.exerciseMode.toApiValue(),
              // Aerobic exercise fields
              'duration_minutes': e.durationMinutes,
              'intensity': e.intensity,
              'work_seconds': e.workSeconds,
              'interval_rest_seconds': e.intervalRestSeconds,
              'rounds': e.rounds,
              'distance_km': e.distanceKm,
              'target_pace_min_per_km': e.targetPaceMinPerKm,
            };
          }).toList(),
        };
      }).toList();

      String? planId;

      if (state.isEditing) {
        // Update existing plan with metadata and workouts
        await workoutService.updatePlan(
          state.editingPlanId!,
          name: state.planName,
          goal: state.goal.toApiValue(),
          difficulty: state.difficulty.toApiValue(),
          splitType: state.splitType.toApiValue(),
          durationWeeks: state.durationWeeks,
          updateDurationWeeks: true, // Always update duration (allows setting to null for continuous)
          targetWorkoutMinutes: state.targetWorkoutMinutes,
          isTemplate: state.isTemplate,
          workouts: workoutsData, // Include workouts data
          // Diet fields
          includeDiet: state.includeDiet,
          dietType: state.dietType?.toApiValue(),
          dailyCalories: state.dailyCalories,
          proteinGrams: state.proteinGrams,
          carbsGrams: state.carbsGrams,
          fatGrams: state.fatGrams,
          mealsPerDay: state.mealsPerDay,
          dietNotes: state.dietNotes,
        );
        planId = state.editingPlanId;
      } else {
        // Create new plan
        planId = await workoutService.createPlan(
          name: state.planName,
          goal: state.goal.toApiValue(),
          difficulty: state.difficulty.toApiValue(),
          splitType: state.splitType.toApiValue(),
          durationWeeks: state.durationWeeks,
          targetWorkoutMinutes: state.targetWorkoutMinutes,
          isTemplate: state.isTemplate,
          workouts: workoutsData,
          // Diet fields
          includeDiet: state.includeDiet,
          dietType: state.dietType?.toApiValue(),
          dailyCalories: state.dailyCalories,
          proteinGrams: state.proteinGrams,
          carbsGrams: state.carbsGrams,
          fatGrams: state.fatGrams,
          mealsPerDay: state.mealsPerDay,
          dietNotes: state.dietNotes,
        );
      }

      // Auto-assign to student if studentId is present
      if (planId != null && state.studentId != null) {
        await workoutService.createPlanAssignment(
          planId: planId,
          studentId: state.studentId!,
        );
      }

      state = state.copyWith(isLoading: false);
      return planId;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Reset
  void reset() {
    state = const PlanWizardState();
    // Generate default workout structure based on default split type (ABC)
    _generateWorkoutStructure();
  }
}

/// Provider for plan wizard
final planWizardProvider =
    StateNotifierProvider.autoDispose<PlanWizardNotifier, PlanWizardState>(
  (ref) => PlanWizardNotifier(),
);

/// Helper class for mapping UI indices to data indices
class _UiDataMapping {
  final int dataStartIndex;
  final int dataEndIndex;
  final bool isGroup;
  final String? groupId;

  const _UiDataMapping({
    required this.dataStartIndex,
    required this.dataEndIndex,
    required this.isGroup,
    required this.groupId,
  });
}
