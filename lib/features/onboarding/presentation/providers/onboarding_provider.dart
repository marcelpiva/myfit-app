import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding step types for trainers
enum TrainerOnboardingStep {
  welcome,
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

/// State for trainer onboarding
@immutable
class TrainerOnboardingState {
  final TrainerOnboardingStep currentStep;
  final bool hasInvitedStudent;
  final bool hasCreatedPlan;
  final bool hasExploredTemplates;
  final bool skipped;

  const TrainerOnboardingState({
    this.currentStep = TrainerOnboardingStep.welcome,
    this.hasInvitedStudent = false,
    this.hasCreatedPlan = false,
    this.hasExploredTemplates = false,
    this.skipped = false,
  });

  TrainerOnboardingState copyWith({
    TrainerOnboardingStep? currentStep,
    bool? hasInvitedStudent,
    bool? hasCreatedPlan,
    bool? hasExploredTemplates,
    bool? skipped,
  }) {
    return TrainerOnboardingState(
      currentStep: currentStep ?? this.currentStep,
      hasInvitedStudent: hasInvitedStudent ?? this.hasInvitedStudent,
      hasCreatedPlan: hasCreatedPlan ?? this.hasCreatedPlan,
      hasExploredTemplates: hasExploredTemplates ?? this.hasExploredTemplates,
      skipped: skipped ?? this.skipped,
    );
  }

  int get stepIndex => currentStep.index;
  int get totalSteps => TrainerOnboardingStep.values.length - 1; // Exclude complete
  double get progress => stepIndex / totalSteps;
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
  final int? age;
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
    this.age,
    this.weeklyFrequency,
    this.injuries = const [],
    this.otherInjuries,
    this.skipped = false,
  });

  StudentOnboardingState copyWith({
    StudentOnboardingStep? currentStep,
    FitnessGoal? fitnessGoal,
    String? otherGoal,
    ExperienceLevel? experienceLevel,
    double? weight,
    double? height,
    int? age,
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
      age: age ?? this.age,
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
      'age': age,
      'weekly_frequency': weeklyFrequency,
      'injuries': injuries,
      'injuries_other': otherInjuries,
      'onboarding_completed': !skipped,
    };
  }
}

/// Provider for trainer onboarding
class TrainerOnboardingNotifier extends StateNotifier<TrainerOnboardingState> {
  TrainerOnboardingNotifier() : super(const TrainerOnboardingState());

  void nextStep() {
    final nextIndex = state.stepIndex + 1;
    if (nextIndex < TrainerOnboardingStep.values.length) {
      state = state.copyWith(
        currentStep: TrainerOnboardingStep.values[nextIndex],
      );
    }
  }

  void previousStep() {
    final prevIndex = state.stepIndex - 1;
    if (prevIndex >= 0) {
      state = state.copyWith(
        currentStep: TrainerOnboardingStep.values[prevIndex],
      );
    }
  }

  void goToStep(TrainerOnboardingStep step) {
    state = state.copyWith(currentStep: step);
  }

  void markStudentInvited() {
    state = state.copyWith(hasInvitedStudent: true);
  }

  void markPlanCreated() {
    state = state.copyWith(hasCreatedPlan: true);
  }

  void markTemplatesExplored() {
    state = state.copyWith(hasExploredTemplates: true);
  }

  void skip() {
    state = state.copyWith(
      skipped: true,
      currentStep: TrainerOnboardingStep.complete,
    );
  }

  void reset() {
    state = const TrainerOnboardingState();
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

  void setPhysicalData({double? weight, double? height, int? age}) {
    state = state.copyWith(
      weight: weight,
      height: height,
      age: age,
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
  (ref) => TrainerOnboardingNotifier(),
);

final studentOnboardingProvider =
    StateNotifierProvider<StudentOnboardingNotifier, StudentOnboardingState>(
  (ref) => StudentOnboardingNotifier(),
);
