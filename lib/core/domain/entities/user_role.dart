/// User roles in the MyFit platform
enum UserRole {
  /// Student/Client - follows workouts and diet plans
  student,

  /// Personal Trainer - creates workouts, manages students
  trainer,

  /// Coach - similar to trainer, focused on performance
  coach,

  /// Nutritionist - creates diet plans, manages nutrition
  nutritionist,

  /// Gym/Academy Owner - manages trainers and organization
  gymOwner,

  /// Gym Admin - administrative access to gym
  gymAdmin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Aluno';
      case UserRole.trainer:
        return 'Personal';
      case UserRole.coach:
        return 'Coach';
      case UserRole.nutritionist:
        return 'Nutricionista';
      case UserRole.gymOwner:
        return 'Proprietario';
      case UserRole.gymAdmin:
        return 'Administrador';
    }
  }

  String get displayNameEn {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.trainer:
        return 'Trainer';
      case UserRole.coach:
        return 'Coach';
      case UserRole.nutritionist:
        return 'Nutritionist';
      case UserRole.gymOwner:
        return 'Owner';
      case UserRole.gymAdmin:
        return 'Admin';
    }
  }

  String get icon {
    switch (this) {
      case UserRole.student:
        return '🎯';
      case UserRole.trainer:
        return '🏋️';
      case UserRole.coach:
        return '🏆';
      case UserRole.nutritionist:
        return '🥗';
      case UserRole.gymOwner:
        return '🏢';
      case UserRole.gymAdmin:
        return '⚙️';
    }
  }

  /// Returns true if this role is a professional role (not student)
  bool get isProfessional =>
      this != UserRole.student;

  /// Returns true if this role can manage students
  bool get canManageStudents =>
      this == UserRole.trainer ||
      this == UserRole.coach ||
      this == UserRole.nutritionist ||
      this == UserRole.gymOwner ||
      this == UserRole.gymAdmin;

  /// Returns true if this role can manage trainers
  bool get canManageTrainers =>
      this == UserRole.gymOwner || this == UserRole.gymAdmin;

  /// Returns true if this role can manage the organization
  bool get canManageOrganization =>
      this == UserRole.gymOwner;

  /// Returns true if this role can create workouts
  bool get canCreateWorkouts =>
      this == UserRole.trainer ||
      this == UserRole.coach ||
      this == UserRole.gymOwner ||
      this == UserRole.gymAdmin;

  /// Returns true if this role can create nutrition plans
  bool get canCreateNutritionPlans =>
      this == UserRole.nutritionist ||
      this == UserRole.trainer ||
      this == UserRole.gymOwner ||
      this == UserRole.gymAdmin;

  /// Returns true if this role can invite students
  bool get canInviteStudents =>
      this == UserRole.trainer ||
      this == UserRole.coach ||
      this == UserRole.nutritionist ||
      this == UserRole.gymOwner ||
      this == UserRole.gymAdmin;

  /// Returns true if this role can view analytics
  bool get canViewAnalytics =>
      this == UserRole.trainer ||
      this == UserRole.coach ||
      this == UserRole.nutritionist ||
      this == UserRole.gymOwner ||
      this == UserRole.gymAdmin;

  /// Returns true if this role focuses on workouts
  bool get isWorkoutFocused =>
      this == UserRole.trainer ||
      this == UserRole.coach ||
      this == UserRole.gymOwner ||
      this == UserRole.gymAdmin;

  /// Returns true if this role focuses on nutrition
  bool get isNutritionFocused =>
      this == UserRole.nutritionist;

  /// Returns true if this role manages a gym/academy
  bool get isGymRole =>
      this == UserRole.gymOwner ||
      this == UserRole.gymAdmin;
}
