import 'user_role.dart';

/// Organization types in MyFit
enum OrganizationType {
  /// Gym/Academy with multiple trainers
  gym,

  /// Independent personal trainer
  personal,

  /// Nutritionist practice
  nutritionist,

  /// Health clinic
  clinic,
}

extension OrganizationTypeExtension on OrganizationType {
  String get displayName {
    switch (this) {
      case OrganizationType.gym:
        return 'Academia';
      case OrganizationType.personal:
        return 'Personal Trainer';
      case OrganizationType.nutritionist:
        return 'Nutricionista';
      case OrganizationType.clinic:
        return 'Clínica';
    }
  }

  String get icon {
    switch (this) {
      case OrganizationType.gym:
        return '🏢';
      case OrganizationType.personal:
        return '🏋️';
      case OrganizationType.nutritionist:
        return '🥗';
      case OrganizationType.clinic:
        return '🏥';
    }
  }
}

/// Represents an organization (gym, personal trainer, etc.)
class Organization {
  final String id;
  final String name;
  final OrganizationType type;
  final String? logoUrl;
  final String? description;
  final int memberCount;
  final int trainerCount;
  final DateTime createdAt;

  const Organization({
    required this.id,
    required this.name,
    required this.type,
    this.logoUrl,
    this.description,
    this.memberCount = 0,
    this.trainerCount = 0,
    required this.createdAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _parseOrganizationType(json['type'] as String),
      logoUrl: json['logo_url'] as String?,
      description: json['description'] as String?,
      memberCount: json['member_count'] as int? ?? 0,
      trainerCount: json['trainer_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static OrganizationType _parseOrganizationType(String type) {
    switch (type) {
      case 'gym':
        return OrganizationType.gym;
      case 'personal':
        return OrganizationType.personal;
      case 'nutritionist':
        return OrganizationType.nutritionist;
      case 'clinic':
        return OrganizationType.clinic;
      default:
        return OrganizationType.personal;
    }
  }

  String get initials {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}

/// Represents a user's membership in an organization with a specific role
class OrganizationMembership {
  final String id;
  final Organization organization;
  final UserRole role;
  final DateTime joinedAt;
  final bool isActive;
  final String? invitedBy;

  const OrganizationMembership({
    required this.id,
    required this.organization,
    required this.role,
    required this.joinedAt,
    this.isActive = true,
    this.invitedBy,
  });

  factory OrganizationMembership.fromJson(Map<String, dynamic> json) {
    return OrganizationMembership(
      id: json['id'] as String,
      organization: Organization.fromJson(json['organization'] as Map<String, dynamic>),
      role: _parseUserRole(json['role'] as String),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      invitedBy: json['invited_by'] as String?,
    );
  }

  static UserRole _parseUserRole(String role) {
    switch (role) {
      case 'student':
        return UserRole.student;
      case 'trainer':
        return UserRole.trainer;
      case 'coach':
        return UserRole.coach;
      case 'nutritionist':
        return UserRole.nutritionist;
      case 'gym_owner':
        return UserRole.gymOwner;
      case 'gym_admin':
        return UserRole.gymAdmin;
      default:
        return UserRole.student;
    }
  }
}

/// Represents the current active context (organization + role)
class ActiveContext {
  final OrganizationMembership membership;

  const ActiveContext({required this.membership});

  Organization get organization => membership.organization;
  UserRole get role => membership.role;

  bool get isStudent => role == UserRole.student;
  bool get isTrainer => role == UserRole.trainer || role == UserRole.coach;
  bool get isNutritionist => role == UserRole.nutritionist;
  bool get isGymOwner => role == UserRole.gymOwner;
  bool get isGymAdmin => role == UserRole.gymAdmin;
  bool get isGymRole => role.isGymRole;

  bool get canManageStudents => role.canManageStudents;
  bool get canManageTrainers => role.canManageTrainers;
  bool get canCreateWorkouts => role.canCreateWorkouts;
  bool get canCreateNutritionPlans => role.canCreateNutritionPlans;

  /// Get the home route for this context
  String get homeRoute {
    if (isStudent) return '/home';
    if (isTrainer) return '/trainer-home';
    if (isNutritionist) return '/nutritionist-home';
    if (isGymRole) return '/gym-home';
    return '/home';
  }
}
