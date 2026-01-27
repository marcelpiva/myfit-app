import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/shared_preferences_provider.dart';

/// Storage keys for onboarding persistence
class OnboardingStorageKeys {
  static const trainerProgress = 'onboarding_trainer_progress';
  static const studentProgress = 'onboarding_student_progress';
  static const skippedSteps = 'onboarding_skipped_steps';
  static const stepTimestamps = 'onboarding_step_timestamps';
}

/// Onboarding step types for trainers
enum TrainerOnboardingStep {
  welcome,
  professionalProfile, // CREF and professional info
  inviteStudent,
  createPlan,
  exploreTemplates,
  complete,
}

/// Onboarding step types for students
enum StudentOnboardingStep {
  welcome,
  fitnessGoal,
  experienceLevel,
  physicalData,
  weeklyFrequency,
  injuries,
  complete,
}

/// Fitness goals for students
enum FitnessGoal {
  loseWeight,
  gainMuscle,
  improveEndurance,
  maintainHealth,
  flexibility,
  other,
}

/// Experience level for students
enum ExperienceLevel {
  beginner,
  intermediate,
  advanced,
}

/// Brazilian states for CREF registration
enum BrazilState {
  AC, AL, AP, AM, BA, CE, DF, ES, GO, MA, MT, MS, MG, PA,
  PB, PR, PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO,
}

/// State for trainer onboarding
@immutable
class TrainerOnboardingState {
  final TrainerOnboardingStep currentStep;
  final bool hasInvitedStudent;
  final bool hasCreatedPlan;
  final bool hasExploredTemplates;
  final bool skipped;
  // Professional profile fields
  final String? crefNumber;
  final BrazilState? crefState;
  final bool hasCrefToggle; // Whether user has CREF toggle enabled
  final List<String> specialties;
  final int? yearsOfExperience;
  final String? bio;
  // Progress tracking
  final Set<TrainerOnboardingStep> completedSteps;
  final Set<TrainerOnboardingStep> skippedSteps;
  final Map<TrainerOnboardingStep, DateTime> stepStartTimes;
  // Validation state
  final bool isCrefValid;
  final String? crefValidationError;
  // Loading states
  final bool isSaving;
  final bool isLoading;
  final String? error;

  const TrainerOnboardingState({
    this.currentStep = TrainerOnboardingStep.welcome,
    this.hasInvitedStudent = false,
    this.hasCreatedPlan = false,
    this.hasExploredTemplates = false,
    this.skipped = false,
    this.crefNumber,
    this.crefState,
    this.hasCrefToggle = false,
    this.specialties = const [],
    this.yearsOfExperience,
    this.bio,
    this.completedSteps = const {},
    this.skippedSteps = const {},
    this.stepStartTimes = const {},
    this.isCrefValid = false,
    this.crefValidationError,
    this.isSaving = false,
    this.isLoading = false,
    this.error,
  });

  TrainerOnboardingState copyWith({
    TrainerOnboardingStep? currentStep,
    bool? hasInvitedStudent,
    bool? hasCreatedPlan,
    bool? hasExploredTemplates,
    bool? skipped,
    String? crefNumber,
    BrazilState? crefState,
    bool? hasCrefToggle,
    List<String>? specialties,
    int? yearsOfExperience,
    String? bio,
    Set<TrainerOnboardingStep>? completedSteps,
    Set<TrainerOnboardingStep>? skippedSteps,
    Map<TrainerOnboardingStep, DateTime>? stepStartTimes,
    bool? isCrefValid,
    String? crefValidationError,
    bool? isSaving,
    bool? isLoading,
    String? error,
  }) {
    return TrainerOnboardingState(
      currentStep: currentStep ?? this.currentStep,
      hasInvitedStudent: hasInvitedStudent ?? this.hasInvitedStudent,
      hasCreatedPlan: hasCreatedPlan ?? this.hasCreatedPlan,
      hasExploredTemplates: hasExploredTemplates ?? this.hasExploredTemplates,
      skipped: skipped ?? this.skipped,
      crefNumber: crefNumber ?? this.crefNumber,
      crefState: crefState ?? this.crefState,
      hasCrefToggle: hasCrefToggle ?? this.hasCrefToggle,
      specialties: specialties ?? this.specialties,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      bio: bio ?? this.bio,
      completedSteps: completedSteps ?? this.completedSteps,
      skippedSteps: skippedSteps ?? this.skippedSteps,
      stepStartTimes: stepStartTimes ?? this.stepStartTimes,
      isCrefValid: isCrefValid ?? this.isCrefValid,
      crefValidationError: crefValidationError,
      isSaving: isSaving ?? this.isSaving,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get stepIndex => currentStep.index;
  int get totalSteps => TrainerOnboardingStep.values.length - 1; // Exclude complete
  double get progress => stepIndex / totalSteps;

  /// Check if CREF is filled
  bool get hasCref => crefNumber != null && crefNumber!.isNotEmpty && crefState != null;

  /// Check if professional profile step has minimum required data
  bool get hasMinimumProfileData =>
      specialties.isNotEmpty || yearsOfExperience != null;

  /// Get formatted CREF string (e.g., "CREF 012345/SP")
  String? get formattedCref {
    if (!hasCref) return null;
    return 'CREF $crefNumber/${crefState!.name}';
  }

  /// Get step labels for progress bar
  List<String> get stepLabels => [
        'Início',
        'Perfil',
        'Convite',
        'Plano',
        'Templates',
      ];

  /// Check if a step was skipped
  bool wasStepSkipped(TrainerOnboardingStep step) => skippedSteps.contains(step);

  /// Check if a step is completed
  bool isStepCompleted(TrainerOnboardingStep step) => completedSteps.contains(step);

  /// Get incomplete steps that need attention
  List<TrainerOnboardingStep> get incompleteSteps {
    final List<TrainerOnboardingStep> incomplete = [];
    if (skippedSteps.contains(TrainerOnboardingStep.professionalProfile) ||
        !hasMinimumProfileData) {
      incomplete.add(TrainerOnboardingStep.professionalProfile);
    }
    if (skippedSteps.contains(TrainerOnboardingStep.inviteStudent) &&
        !hasInvitedStudent) {
      incomplete.add(TrainerOnboardingStep.inviteStudent);
    }
    return incomplete;
  }

  Map<String, dynamic> toProfileData() {
    return {
      'cref_number': crefNumber,
      'cref_state': crefState?.name,
      'specialties': specialties,
      'years_of_experience': yearsOfExperience,
      'bio': bio,
      'onboarding_completed': !skipped,
    };
  }

  /// Convert state to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep.index,
      'hasInvitedStudent': hasInvitedStudent,
      'hasCreatedPlan': hasCreatedPlan,
      'hasExploredTemplates': hasExploredTemplates,
      'skipped': skipped,
      'crefNumber': crefNumber,
      'crefState': crefState?.index,
      'hasCrefToggle': hasCrefToggle,
      'specialties': specialties,
      'yearsOfExperience': yearsOfExperience,
      'bio': bio,
      'completedSteps': completedSteps.map((s) => s.index).toList(),
      'skippedSteps': skippedSteps.map((s) => s.index).toList(),
    };
  }

  /// Create state from JSON
  factory TrainerOnboardingState.fromJson(Map<String, dynamic> json) {
    return TrainerOnboardingState(
      currentStep: TrainerOnboardingStep.values[json['currentStep'] as int? ?? 0],
      hasInvitedStudent: json['hasInvitedStudent'] as bool? ?? false,
      hasCreatedPlan: json['hasCreatedPlan'] as bool? ?? false,
      hasExploredTemplates: json['hasExploredTemplates'] as bool? ?? false,
      skipped: json['skipped'] as bool? ?? false,
      crefNumber: json['crefNumber'] as String?,
      crefState: json['crefState'] != null
          ? BrazilState.values[json['crefState'] as int]
          : null,
      hasCrefToggle: json['hasCrefToggle'] as bool? ?? false,
      specialties: (json['specialties'] as List<dynamic>?)?.cast<String>() ?? const [],
      yearsOfExperience: json['yearsOfExperience'] as int?,
      bio: json['bio'] as String?,
      completedSteps: (json['completedSteps'] as List<dynamic>?)
              ?.map((i) => TrainerOnboardingStep.values[i as int])
              .toSet() ??
          const {},
      skippedSteps: (json['skippedSteps'] as List<dynamic>?)
              ?.map((i) => TrainerOnboardingStep.values[i as int])
              .toSet() ??
          const {},
    );
  }
}

/// State for student onboarding
@immutable
class StudentOnboardingState {
  final StudentOnboardingStep currentStep;
  final FitnessGoal? fitnessGoal;
  final String? otherGoal;
  final ExperienceLevel? experienceLevel;
  final double? weight; // kg
  final double? height; // cm
  final DateTime? birthDate;
  final int? weeklyFrequency;
  final List<String> injuries;
  final String? otherInjuries;
  final bool skipped;

  const StudentOnboardingState({
    this.currentStep = StudentOnboardingStep.welcome,
    this.fitnessGoal,
    this.otherGoal,
    this.experienceLevel,
    this.weight,
    this.height,
    this.birthDate,
    this.weeklyFrequency,
    this.injuries = const [],
    this.otherInjuries,
    this.skipped = false,
  });

  /// Calculate age from birth date
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int years = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      years--;
    }
    return years;
  }

  StudentOnboardingState copyWith({
    StudentOnboardingStep? currentStep,
    FitnessGoal? fitnessGoal,
    String? otherGoal,
    ExperienceLevel? experienceLevel,
    double? weight,
    double? height,
    DateTime? birthDate,
    int? weeklyFrequency,
    List<String>? injuries,
    String? otherInjuries,
    bool? skipped,
  }) {
    return StudentOnboardingState(
      currentStep: currentStep ?? this.currentStep,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      otherGoal: otherGoal ?? this.otherGoal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      birthDate: birthDate ?? this.birthDate,
      weeklyFrequency: weeklyFrequency ?? this.weeklyFrequency,
      injuries: injuries ?? this.injuries,
      otherInjuries: otherInjuries ?? this.otherInjuries,
      skipped: skipped ?? this.skipped,
    );
  }

  int get stepIndex => currentStep.index;
  int get totalSteps => StudentOnboardingStep.values.length - 1; // Exclude complete
  double get progress => stepIndex / totalSteps;

  Map<String, dynamic> toProfileData() {
    return {
      'fitness_goal': fitnessGoal?.name,
      'fitness_goal_other': otherGoal,
      'experience_level': experienceLevel?.name,
      'weight': weight,
      'height': height,
      'birth_date': birthDate?.toIso8601String(),
      'age': age, // Calculated from birthDate
      'weekly_frequency': weeklyFrequency,
      'injuries': injuries,
      'injuries_other': otherInjuries,
      'onboarding_completed': !skipped,
    };
  }
}

/// Provider for trainer onboarding
class TrainerOnboardingNotifier extends StateNotifier<TrainerOnboardingState> {
  final SharedPreferences? _prefs;
  bool _hasBeenReset = false;

  TrainerOnboardingNotifier({SharedPreferences? prefs})
      : _prefs = prefs,
        super(const TrainerOnboardingState()) {
    _loadSavedProgress();
  }

  /// Load previously saved progress
  Future<void> _loadSavedProgress() async {
    if (_prefs == null) return;
    // Don't load if reset() was called - prevents race condition
    if (_hasBeenReset) return;

    state = state.copyWith(isLoading: true);
    try {
      final savedJson = _prefs.getString(OnboardingStorageKeys.trainerProgress);
      // Check again in case reset was called while we were loading
      if (_hasBeenReset) return;
      if (savedJson != null) {
        final json = jsonDecode(savedJson) as Map<String, dynamic>;
        state = TrainerOnboardingState.fromJson(json).copyWith(isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('Error loading onboarding progress: $e');
      if (!_hasBeenReset) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Save current progress to storage
  Future<void> _saveProgress() async {
    if (_prefs == null) return;

    try {
      await _prefs.setString(
        OnboardingStorageKeys.trainerProgress,
        jsonEncode(state.toJson()),
      );
    } catch (e) {
      debugPrint('Error saving onboarding progress: $e');
    }
  }

  /// Clear saved progress
  Future<void> clearSavedProgress() async {
    if (_prefs == null) return;
    await _prefs.remove(OnboardingStorageKeys.trainerProgress);
  }

  /// Start tracking time for current step
  void _trackStepStart() {
    final newTimes = Map<TrainerOnboardingStep, DateTime>.from(state.stepStartTimes);
    newTimes[state.currentStep] = DateTime.now();
    state = state.copyWith(stepStartTimes: newTimes);
  }

  void nextStep() {
    final currentStep = state.currentStep;
    final nextIndex = state.stepIndex + 1;

    if (nextIndex < TrainerOnboardingStep.values.length) {
      // Mark current step as completed
      final newCompleted = Set<TrainerOnboardingStep>.from(state.completedSteps)
        ..add(currentStep);

      state = state.copyWith(
        currentStep: TrainerOnboardingStep.values[nextIndex],
        completedSteps: newCompleted,
      );
      _trackStepStart();
      _saveProgress();
    }
  }

  void previousStep() {
    final prevIndex = state.stepIndex - 1;
    if (prevIndex >= 0) {
      state = state.copyWith(
        currentStep: TrainerOnboardingStep.values[prevIndex],
      );
      _trackStepStart();
      _saveProgress();
    }
  }

  void goToStep(TrainerOnboardingStep step) {
    state = state.copyWith(currentStep: step);
    _trackStepStart();
    _saveProgress();
  }

  /// Skip current step and move to next
  void skipCurrentStep() {
    final currentStep = state.currentStep;
    final nextIndex = state.stepIndex + 1;

    if (nextIndex < TrainerOnboardingStep.values.length) {
      // Mark current step as skipped
      final newSkipped = Set<TrainerOnboardingStep>.from(state.skippedSteps)
        ..add(currentStep);

      state = state.copyWith(
        currentStep: TrainerOnboardingStep.values[nextIndex],
        skippedSteps: newSkipped,
      );
      _trackStepStart();
      _saveProgress();
    }
  }

  void markStudentInvited() {
    // Remove from skipped if it was skipped
    final newSkipped = Set<TrainerOnboardingStep>.from(state.skippedSteps)
      ..remove(TrainerOnboardingStep.inviteStudent);

    state = state.copyWith(
      hasInvitedStudent: true,
      skippedSteps: newSkipped,
    );
    _saveProgress();
  }

  void markPlanCreated() {
    state = state.copyWith(hasCreatedPlan: true);
    _saveProgress();
  }

  void markTemplatesExplored() {
    state = state.copyWith(hasExploredTemplates: true);
    _saveProgress();
  }

  /// Toggle CREF registration
  void toggleCref(bool hasCref) {
    state = state.copyWith(
      hasCrefToggle: hasCref,
      // Clear CREF data if toggle is off
      crefNumber: hasCref ? state.crefNumber : null,
      crefState: hasCref ? state.crefState : null,
      isCrefValid: hasCref ? state.isCrefValid : true,
      crefValidationError: null,
    );
    _saveProgress();
  }

  /// Validate CREF number format
  /// Format: 6 digits (e.g., "012345")
  String? validateCrefNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o número do CREF';
    }
    // Remove any non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 6) {
      return 'CREF deve ter 6 dígitos';
    }
    if (digitsOnly.length > 6) {
      return 'CREF deve ter apenas 6 dígitos';
    }
    return null; // Valid
  }

  void setCrefData({
    required String crefNumber,
    required BrazilState crefState,
  }) {
    final error = validateCrefNumber(crefNumber);
    state = state.copyWith(
      crefNumber: crefNumber,
      crefState: crefState,
      isCrefValid: error == null,
      crefValidationError: error,
    );
    _saveProgress();
  }

  void setCrefNumber(String number) {
    final error = validateCrefNumber(number);
    state = state.copyWith(
      crefNumber: number,
      isCrefValid: error == null && state.crefState != null,
      crefValidationError: error,
    );
    _saveProgress();
  }

  void setCrefState(BrazilState crefState) {
    state = state.copyWith(
      crefState: crefState,
      isCrefValid: state.crefValidationError == null,
    );
    _saveProgress();
  }

  void setProfileData({
    List<String>? specialties,
    int? yearsOfExperience,
    String? bio,
  }) {
    // Remove profile step from skipped if user is completing it
    final newSkipped = Set<TrainerOnboardingStep>.from(state.skippedSteps)
      ..remove(TrainerOnboardingStep.professionalProfile);

    state = state.copyWith(
      specialties: specialties,
      yearsOfExperience: yearsOfExperience,
      bio: bio,
      skippedSteps: newSkipped,
    );
    _saveProgress();
  }

  void addSpecialty(String specialty) {
    if (state.specialties.length >= 5) return; // Max 5 specialties
    final newSpecialties = List<String>.from(state.specialties)..add(specialty);
    state = state.copyWith(specialties: newSpecialties);
    _saveProgress();
  }

  void removeSpecialty(String specialty) {
    final newSpecialties = List<String>.from(state.specialties)..remove(specialty);
    state = state.copyWith(specialties: newSpecialties);
    _saveProgress();
  }

  void setYearsOfExperience(int years) {
    state = state.copyWith(yearsOfExperience: years);
    _saveProgress();
  }

  void setBio(String bio) {
    state = state.copyWith(bio: bio.isEmpty ? null : bio);
    _saveProgress();
  }

  void skip() {
    state = state.copyWith(
      skipped: true,
      currentStep: TrainerOnboardingStep.complete,
    );
    _saveProgress();
  }

  void reset() {
    _hasBeenReset = true;
    state = const TrainerOnboardingState();
    clearSavedProgress();
  }

  /// Check if user can continue from current step
  bool canContinueFromCurrentStep() {
    switch (state.currentStep) {
      case TrainerOnboardingStep.welcome:
        return true;
      case TrainerOnboardingStep.professionalProfile:
        // Can continue if CREF is valid (or not required) and has some specialties
        if (state.hasCrefToggle && !state.isCrefValid) return false;
        return state.specialties.isNotEmpty;
      case TrainerOnboardingStep.inviteStudent:
      case TrainerOnboardingStep.createPlan:
      case TrainerOnboardingStep.exploreTemplates:
      case TrainerOnboardingStep.complete:
        return true;
    }
  }
}

/// Provider for student onboarding
class StudentOnboardingNotifier extends StateNotifier<StudentOnboardingState> {
  StudentOnboardingNotifier() : super(const StudentOnboardingState());

  void nextStep() {
    final nextIndex = state.stepIndex + 1;
    if (nextIndex < StudentOnboardingStep.values.length) {
      state = state.copyWith(
        currentStep: StudentOnboardingStep.values[nextIndex],
      );
    }
  }

  void previousStep() {
    final prevIndex = state.stepIndex - 1;
    if (prevIndex >= 0) {
      state = state.copyWith(
        currentStep: StudentOnboardingStep.values[prevIndex],
      );
    }
  }

  void goToStep(StudentOnboardingStep step) {
    state = state.copyWith(currentStep: step);
  }

  void setFitnessGoal(FitnessGoal goal, {String? otherGoal}) {
    state = state.copyWith(fitnessGoal: goal, otherGoal: otherGoal);
  }

  void setExperienceLevel(ExperienceLevel level) {
    state = state.copyWith(experienceLevel: level);
  }

  void setPhysicalData({double? weight, double? height, DateTime? birthDate}) {
    state = state.copyWith(
      weight: weight,
      height: height,
      birthDate: birthDate,
    );
  }

  void setWeeklyFrequency(int frequency) {
    state = state.copyWith(weeklyFrequency: frequency);
  }

  void setInjuries(List<String> injuries, {String? otherInjuries}) {
    state = state.copyWith(injuries: injuries, otherInjuries: otherInjuries);
  }

  void skip() {
    state = state.copyWith(
      skipped: true,
      currentStep: StudentOnboardingStep.complete,
    );
  }

  void reset() {
    state = const StudentOnboardingState();
  }
}

/// Providers
final trainerOnboardingProvider =
    StateNotifierProvider<TrainerOnboardingNotifier, TrainerOnboardingState>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider).valueOrNull;
    return TrainerOnboardingNotifier(prefs: prefs);
  },
);

final studentOnboardingProvider =
    StateNotifierProvider<StudentOnboardingNotifier, StudentOnboardingState>(
  (ref) => StudentOnboardingNotifier(),
);

// Convenience providers for trainer onboarding
final trainerOnboardingProgressProvider = Provider<double>((ref) {
  return ref.watch(trainerOnboardingProvider).progress;
});

final trainerOnboardingCurrentStepProvider = Provider<TrainerOnboardingStep>((ref) {
  return ref.watch(trainerOnboardingProvider).currentStep;
});

final trainerOnboardingCanContinueProvider = Provider<bool>((ref) {
  final notifier = ref.watch(trainerOnboardingProvider.notifier);
  return notifier.canContinueFromCurrentStep();
});

final trainerOnboardingIncompleteStepsProvider = Provider<List<TrainerOnboardingStep>>((ref) {
  return ref.watch(trainerOnboardingProvider).incompleteSteps;
});

final trainerOnboardingIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(trainerOnboardingProvider).isLoading;
});

final trainerOnboardingIsSavingProvider = Provider<bool>((ref) {
  return ref.watch(trainerOnboardingProvider).isSaving;
});
