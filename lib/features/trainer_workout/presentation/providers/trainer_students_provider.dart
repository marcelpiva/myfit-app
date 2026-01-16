import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/organization_service.dart';
import '../../../../core/services/workout_service.dart';

// Service providers
final trainerStudentsOrgServiceProvider = Provider<OrganizationService>((ref) {
  return OrganizationService();
});

final trainerStudentsWorkoutServiceProvider = Provider<WorkoutService>((ref) {
  return WorkoutService();
});

// ==================== Student with Workout Info ====================

class TrainerStudent {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String? phone;
  final bool isActive;
  final DateTime? joinedAt;
  final DateTime? lastWorkoutAt;
  final String? currentWorkoutName;
  final int totalWorkouts;
  final int completedWorkouts;
  final double adherencePercent;
  final String? goal;
  final Map<String, dynamic>? stats;

  const TrainerStudent({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.phone,
    this.isActive = true,
    this.joinedAt,
    this.lastWorkoutAt,
    this.currentWorkoutName,
    this.totalWorkouts = 0,
    this.completedWorkouts = 0,
    this.adherencePercent = 0,
    this.goal,
    this.stats,
  });

  /// Returns true if student joined within the last 30 days
  bool get isNew {
    if (joinedAt == null) return false;
    return DateTime.now().difference(joinedAt!).inDays <= 30;
  }

  /// Formatted last activity string
  String get lastActivity {
    if (lastWorkoutAt == null) return 'Nunca';
    final now = DateTime.now();
    final diff = now.difference(lastWorkoutAt!);
    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return 'Há ${diff.inDays} dias';
    if (diff.inDays < 30) return 'Há ${(diff.inDays / 7).floor()} semanas';
    return 'Há ${(diff.inDays / 30).floor()} meses';
  }

  /// Get initials from name
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  TrainerStudent copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? phone,
    bool? isActive,
    DateTime? joinedAt,
    DateTime? lastWorkoutAt,
    String? currentWorkoutName,
    int? totalWorkouts,
    int? completedWorkouts,
    double? adherencePercent,
    String? goal,
    Map<String, dynamic>? stats,
  }) {
    return TrainerStudent(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      joinedAt: joinedAt ?? this.joinedAt,
      lastWorkoutAt: lastWorkoutAt ?? this.lastWorkoutAt,
      currentWorkoutName: currentWorkoutName ?? this.currentWorkoutName,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      completedWorkouts: completedWorkouts ?? this.completedWorkouts,
      adherencePercent: adherencePercent ?? this.adherencePercent,
      goal: goal ?? this.goal,
      stats: stats ?? this.stats,
    );
  }
}

// ==================== Trainer Students State ====================

class TrainerStudentsState {
  final List<TrainerStudent> students;
  final bool isLoading;
  final String? error;

  const TrainerStudentsState({
    this.students = const [],
    this.isLoading = false,
    this.error,
  });

  TrainerStudentsState copyWith({
    List<TrainerStudent>? students,
    bool? isLoading,
    String? error,
  }) {
    return TrainerStudentsState(
      students: students ?? this.students,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get activeCount => students.where((s) => s.isActive).length;
  int get inactiveCount => students.where((s) => !s.isActive).length;
}

class TrainerStudentsNotifier extends StateNotifier<TrainerStudentsState> {
  final OrganizationService _orgService;
  final WorkoutService _workoutService;
  final String? orgId;

  TrainerStudentsNotifier(
    this._orgService,
    this._workoutService,
    this.orgId,
  ) : super(const TrainerStudentsState()) {
    loadStudents();
  }

  Future<void> loadStudents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Load members with role 'member' or 'student'
      List<Map<String, dynamic>> members = [];
      if (orgId != null) {
        members = await _orgService.getMembers(orgId!, role: 'student');
      }

      // Load workout assignments to get workout info per student
      final workouts = await _workoutService.getWorkoutAssignments();

      // Build student list with workout info
      final students = members.map((member) {
        final userId = member['user_id'] as String;
        final studentWorkouts = workouts.where((w) => w['student_id'] == userId).toList();

        final activeWorkout = studentWorkouts.where((w) => w['status'] == 'active').firstOrNull;
        final completedCount = studentWorkouts.where((w) => w['status'] == 'completed').length;

        return TrainerStudent(
          id: userId,
          name: member['user_name'] as String? ?? member['name'] as String? ?? 'Aluno',
          email: member['email'] as String?,
          avatarUrl: member['avatar_url'] as String?,
          phone: member['phone'] as String?,
          isActive: member['status'] == 'active',
          joinedAt: DateTime.tryParse(member['joined_at'] as String? ?? ''),
          lastWorkoutAt: DateTime.tryParse(member['last_workout_at'] as String? ?? ''),
          currentWorkoutName: activeWorkout?['name'] as String?,
          totalWorkouts: studentWorkouts.length,
          completedWorkouts: completedCount,
          adherencePercent: studentWorkouts.isNotEmpty
              ? (completedCount / studentWorkouts.length) * 100
              : 0,
          goal: member['goal'] as String?,
        );
      }).toList();

      state = state.copyWith(students: students, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar alunos');
    }
  }

  void refresh() => loadStudents();
}

final trainerStudentsNotifierProvider =
    StateNotifierProvider.family<TrainerStudentsNotifier, TrainerStudentsState, String?>((ref, orgId) {
  final orgService = ref.watch(trainerStudentsOrgServiceProvider);
  final workoutService = ref.watch(trainerStudentsWorkoutServiceProvider);
  return TrainerStudentsNotifier(orgService, workoutService, orgId);
});

// ==================== Simple Providers ====================

final trainerStudentsProvider = Provider.family<List<TrainerStudent>, String?>((ref, orgId) {
  return ref.watch(trainerStudentsNotifierProvider(orgId)).students;
});

// ==================== Filter Providers ====================

final studentSearchQueryProvider = StateProvider<String>((ref) => '');
final studentFilterProvider = StateProvider<String?>((ref) => null); // 'active', 'inactive', null for all
final studentSortProvider = StateProvider<String>((ref) => 'name'); // 'name', 'lastWorkout', 'adherence'

final filteredTrainerStudentsProvider = Provider.family<List<TrainerStudent>, String?>((ref, orgId) {
  final students = ref.watch(trainerStudentsProvider(orgId));
  final searchQuery = ref.watch(studentSearchQueryProvider).toLowerCase();
  final filter = ref.watch(studentFilterProvider);
  final sortBy = ref.watch(studentSortProvider);

  var filtered = students.where((student) {
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final matchesName = student.name.toLowerCase().contains(searchQuery);
      final matchesEmail = student.email?.toLowerCase().contains(searchQuery) ?? false;
      if (!matchesName && !matchesEmail) return false;
    }

    // Apply status filter
    if (filter == 'active' && !student.isActive) return false;
    if (filter == 'inactive' && student.isActive) return false;

    return true;
  }).toList();

  // Apply sorting
  switch (sortBy) {
    case 'name':
      filtered.sort((a, b) => a.name.compareTo(b.name));
      break;
    case 'lastWorkout':
      filtered.sort((a, b) {
        if (a.lastWorkoutAt == null && b.lastWorkoutAt == null) return 0;
        if (a.lastWorkoutAt == null) return 1;
        if (b.lastWorkoutAt == null) return -1;
        return b.lastWorkoutAt!.compareTo(a.lastWorkoutAt!);
      });
      break;
    case 'adherence':
      filtered.sort((a, b) => b.adherencePercent.compareTo(a.adherencePercent));
      break;
  }

  return filtered;
});

// ==================== Stats Provider ====================

final trainerStudentStatsProvider = Provider.family<Map<String, int>, String?>((ref, orgId) {
  final state = ref.watch(trainerStudentsNotifierProvider(orgId));
  return {
    'total': state.students.length,
    'active': state.activeCount,
    'inactive': state.inactiveCount,
  };
});

final isStudentsLoadingProvider = Provider.family<bool, String?>((ref, orgId) {
  return ref.watch(trainerStudentsNotifierProvider(orgId)).isLoading;
});

// ==================== Pending Invites ====================

class PendingInvite {
  final String id;
  final String email;
  final String role;
  final String organizationId;
  final String? organizationName;
  final String? invitedByName;
  final DateTime expiresAt;
  final DateTime createdAt;
  final bool isExpired;
  final String? token;

  const PendingInvite({
    required this.id,
    required this.email,
    required this.role,
    required this.organizationId,
    this.organizationName,
    this.invitedByName,
    required this.expiresAt,
    required this.createdAt,
    this.isExpired = false,
    this.token,
  });

  /// Check if invite expires within n days
  bool expiresWithinDays(int days) {
    return expiresAt.difference(DateTime.now()).inDays <= days;
  }

  /// Formatted time since invite was created
  String get timeSinceCreated {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    if (diff.inDays == 1) return 'Há 1 dia';
    return 'Há ${diff.inDays} dias';
  }

  /// Formatted time until expiration
  String get timeUntilExpiration {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 'Expirado';
    if (diff.inDays == 0) return 'Expira hoje';
    if (diff.inDays == 1) return 'Expira amanhã';
    return 'Expira em ${diff.inDays} dias';
  }

  factory PendingInvite.fromJson(Map<String, dynamic> json) {
    return PendingInvite(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      organizationId: json['organization_id'] as String,
      organizationName: json['organization_name'] as String?,
      invitedByName: json['invited_by_name'] as String?,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      isExpired: json['is_expired'] as bool? ?? false,
      token: json['token'] as String?,
    );
  }
}

class PendingInvitesState {
  final List<PendingInvite> invites;
  final bool isLoading;
  final String? error;

  const PendingInvitesState({
    this.invites = const [],
    this.isLoading = false,
    this.error,
  });

  PendingInvitesState copyWith({
    List<PendingInvite>? invites,
    bool? isLoading,
    String? error,
  }) {
    return PendingInvitesState(
      invites: invites ?? this.invites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PendingInvitesNotifier extends StateNotifier<PendingInvitesState> {
  final OrganizationService _orgService;
  final String? orgId;

  PendingInvitesNotifier(this._orgService, this.orgId)
      : super(const PendingInvitesState()) {
    loadInvites();
  }

  Future<void> loadInvites() async {
    if (orgId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _orgService.getInvites(orgId!);
      final invites = data.map((json) => PendingInvite.fromJson(json)).toList();
      // Filter out accepted invites
      final pendingOnly = invites.where((i) => !i.isExpired).toList();
      state = state.copyWith(invites: pendingOnly, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar convites');
    }
  }

  Future<void> cancelInvite(String inviteId) async {
    if (orgId == null) return;
    try {
      await _orgService.cancelInvite(orgId!, inviteId);
      state = state.copyWith(
        invites: state.invites.where((i) => i.id != inviteId).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendInvite(String inviteId) async {
    if (orgId == null) return;
    try {
      final updated = await _orgService.resendInvite(orgId!, inviteId);
      final updatedInvite = PendingInvite.fromJson(updated);
      state = state.copyWith(
        invites: state.invites.map((i) => i.id == inviteId ? updatedInvite : i).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  void refresh() => loadInvites();
}

final pendingInvitesNotifierProvider =
    StateNotifierProvider.family<PendingInvitesNotifier, PendingInvitesState, String?>((ref, orgId) {
  final orgService = ref.watch(trainerStudentsOrgServiceProvider);
  return PendingInvitesNotifier(orgService, orgId);
});

final pendingInvitesProvider = Provider.family<List<PendingInvite>, String?>((ref, orgId) {
  return ref.watch(pendingInvitesNotifierProvider(orgId)).invites;
});

final pendingInvitesCountProvider = Provider.family<int, String?>((ref, orgId) {
  return ref.watch(pendingInvitesProvider(orgId)).length;
});
