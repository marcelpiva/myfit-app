import 'package:myfit_app/features/trainer_workout/presentation/providers/trainer_students_provider.dart';

/// Fixtures for student-related test data
class StudentFixtures {
  /// Creates an active student with recent workout
  static TrainerStudent active({
    String id = 'student-1',
    String name = 'João Silva',
    String? email = 'joao@example.com',
    DateTime? lastWorkoutAt,
    DateTime? joinedAt,
  }) {
    return TrainerStudent(
      id: id,
      name: name,
      email: email,
      avatarUrl: null,
      phone: '11999999999',
      isActive: true,
      joinedAt: joinedAt ?? DateTime.now().subtract(const Duration(days: 60)),
      lastWorkoutAt: lastWorkoutAt ?? DateTime.now().subtract(const Duration(days: 1)),
      currentWorkoutName: 'Treino A - Peito e Tríceps',
      totalWorkouts: 12,
      completedWorkouts: 8,
      adherencePercent: 66.67,
      goal: 'Hipertrofia',
    );
  }

  /// Creates an inactive student (no recent workout)
  static TrainerStudent inactive({
    String id = 'student-2',
    String name = 'Maria Santos',
  }) {
    return TrainerStudent(
      id: id,
      name: name,
      email: 'maria@example.com',
      avatarUrl: null,
      phone: '11988888888',
      isActive: false,
      joinedAt: DateTime.now().subtract(const Duration(days: 90)),
      lastWorkoutAt: DateTime.now().subtract(const Duration(days: 30)),
      currentWorkoutName: null,
      totalWorkouts: 5,
      completedWorkouts: 2,
      adherencePercent: 40.0,
      goal: 'Emagrecimento',
    );
  }

  /// Creates a new student (joined within last 30 days)
  static TrainerStudent newStudent({
    String id = 'student-3',
    String name = 'Carlos Oliveira',
  }) {
    return TrainerStudent(
      id: id,
      name: name,
      email: 'carlos@example.com',
      avatarUrl: null,
      phone: '11977777777',
      isActive: true,
      joinedAt: DateTime.now().subtract(const Duration(days: 10)),
      lastWorkoutAt: DateTime.now().subtract(const Duration(days: 2)),
      currentWorkoutName: 'Treino Iniciante',
      totalWorkouts: 3,
      completedWorkouts: 3,
      adherencePercent: 100.0,
      goal: 'Condicionamento',
    );
  }

  /// Creates a student with no workouts
  static TrainerStudent withoutWorkouts({
    String id = 'student-4',
    String name = 'Ana Costa',
  }) {
    return TrainerStudent(
      id: id,
      name: name,
      email: 'ana@example.com',
      avatarUrl: null,
      phone: null,
      isActive: true,
      joinedAt: DateTime.now().subtract(const Duration(days: 5)),
      lastWorkoutAt: null,
      currentWorkoutName: null,
      totalWorkouts: 0,
      completedWorkouts: 0,
      adherencePercent: 0,
      goal: null,
    );
  }

  /// Creates a list of mixed students for testing
  static List<TrainerStudent> mixedList() {
    return [
      active(id: 'student-1', name: 'João Silva'),
      inactive(id: 'student-2', name: 'Maria Santos'),
      newStudent(id: 'student-3', name: 'Carlos Oliveira'),
      withoutWorkouts(id: 'student-4', name: 'Ana Costa'),
      active(id: 'student-5', name: 'Pedro Almeida'),
    ];
  }

  /// Creates a student API response map
  static Map<String, dynamic> activeApiResponse({
    String userId = 'student-1',
    String userName = 'João Silva',
  }) {
    return {
      'user_id': userId,
      'user_name': userName,
      'email': 'joao@example.com',
      'avatar_url': null,
      'phone': '11999999999',
      'status': 'active',
      'joined_at': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
      'last_workout_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'goal': 'Hipertrofia',
    };
  }

  /// Creates an inactive student API response map
  static Map<String, dynamic> inactiveApiResponse({
    String userId = 'student-2',
    String userName = 'Maria Santos',
  }) {
    return {
      'user_id': userId,
      'user_name': userName,
      'email': 'maria@example.com',
      'avatar_url': null,
      'phone': '11988888888',
      'status': 'inactive',
      'joined_at': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      'last_workout_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'goal': 'Emagrecimento',
    };
  }

  /// Creates a list of student API responses
  static List<Map<String, dynamic>> apiResponseList({int count = 5}) {
    return List.generate(count, (index) {
      final isActive = index % 2 == 0;
      return {
        'user_id': 'student-$index',
        'user_name': 'Student $index',
        'email': 'student$index@example.com',
        'avatar_url': null,
        'phone': '1199999999$index',
        'status': isActive ? 'active' : 'inactive',
        'joined_at': DateTime.now().subtract(Duration(days: 30 + index * 10)).toIso8601String(),
        'last_workout_at': isActive
            ? DateTime.now().subtract(Duration(days: index)).toIso8601String()
            : DateTime.now().subtract(Duration(days: 20 + index)).toIso8601String(),
        'goal': isActive ? 'Hipertrofia' : 'Emagrecimento',
      };
    });
  }

  /// Creates a pending invite
  static PendingInvite pendingInvite({
    String id = 'invite-1',
    String email = 'novo@example.com',
  }) {
    return PendingInvite(
      id: id,
      email: email,
      role: 'student',
      organizationId: 'org-1',
      organizationName: 'Academia Fitness',
      invitedByName: 'Trainer João',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isExpired: false,
      token: 'token-abc-123',
    );
  }

  /// Creates an expired invite
  static PendingInvite expiredInvite({
    String id = 'invite-2',
    String email = 'expirado@example.com',
  }) {
    return PendingInvite(
      id: id,
      email: email,
      role: 'student',
      organizationId: 'org-1',
      organizationName: 'Academia Fitness',
      invitedByName: 'Trainer João',
      expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      isExpired: true,
      token: 'token-expired-123',
    );
  }

  /// Creates a pending invite API response
  static Map<String, dynamic> pendingInviteApiResponse({
    String id = 'invite-1',
    String email = 'novo@example.com',
  }) {
    return {
      'id': id,
      'email': email,
      'role': 'student',
      'organization_id': 'org-1',
      'organization_name': 'Academia Fitness',
      'invited_by_name': 'Trainer João',
      'expires_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'is_expired': false,
      'token': 'token-abc-123',
    };
  }
}
