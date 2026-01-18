import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/organization_service.dart';

// Service provider
final organizationServiceProvider = Provider<OrganizationService>((ref) {
  return OrganizationService();
});

// ==================== Current Organization ====================

class CurrentOrganizationState {
  final Map<String, dynamic>? organization;
  final bool isLoading;
  final String? error;

  const CurrentOrganizationState({
    this.organization,
    this.isLoading = false,
    this.error,
  });

  CurrentOrganizationState copyWith({
    Map<String, dynamic>? organization,
    bool? isLoading,
    String? error,
    bool clearOrg = false,
  }) {
    return CurrentOrganizationState(
      organization: clearOrg ? null : (organization ?? this.organization),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CurrentOrganizationNotifier extends StateNotifier<CurrentOrganizationState> {
  final OrganizationService _service;
  final String? orgId;

  CurrentOrganizationNotifier(this._service, this.orgId) : super(const CurrentOrganizationState()) {
    if (orgId != null) {
      loadOrganization();
    }
  }

  Future<void> loadOrganization() async {
    if (orgId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final org = await _service.getOrganization(orgId!);
      state = state.copyWith(organization: org, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar organização');
    }
  }

  Future<void> updateOrganization({
    String? name,
    String? description,
    String? address,
    String? phone,
    String? email,
  }) async {
    if (orgId == null) return;
    try {
      final org = await _service.updateOrganization(
        orgId!,
        name: name,
        description: description,
        address: address,
        phone: phone,
        email: email,
      );
      state = state.copyWith(organization: org);
    } on ApiException {
      rethrow;
    }
  }

  void refresh() => loadOrganization();
}

final currentOrganizationNotifierProvider = StateNotifierProvider.family<CurrentOrganizationNotifier, CurrentOrganizationState, String?>((ref, orgId) {
  final service = ref.watch(organizationServiceProvider);
  return CurrentOrganizationNotifier(service, orgId);
});

// ==================== Members ====================

class MembersState {
  final List<Map<String, dynamic>> members;
  final bool isLoading;
  final String? error;

  const MembersState({
    this.members = const [],
    this.isLoading = false,
    this.error,
  });

  MembersState copyWith({
    List<Map<String, dynamic>>? members,
    bool? isLoading,
    String? error,
  }) {
    return MembersState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MembersNotifier extends StateNotifier<MembersState> {
  final OrganizationService _service;
  final String orgId;

  MembersNotifier(this._service, this.orgId) : super(const MembersState()) {
    loadMembers();
  }

  Future<void> loadMembers({String? role, String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final members = await _service.getMembers(orgId, role: role, status: status);
      state = state.copyWith(members: members, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar membros');
    }
  }

  Future<void> updateMemberRole(String userId, String role) async {
    try {
      final updated = await _service.updateMember(orgId, userId, role: role);
      state = state.copyWith(
        members: state.members.map((m) => m['user_id'] == userId ? updated : m).toList(),
      );
    } on ApiException {
      rethrow;
    }
  }

  Future<void> updateMemberStatus(String userId, String status) async {
    try {
      final updated = await _service.updateMember(orgId, userId, status: status);
      state = state.copyWith(
        members: state.members.map((m) => m['user_id'] == userId ? updated : m).toList(),
      );
    } on ApiException {
      rethrow;
    }
  }

  Future<void> removeMember(String userId) async {
    try {
      await _service.removeMember(orgId, userId);
      state = state.copyWith(
        members: state.members.where((m) => m['user_id'] != userId).toList(),
      );
    } on ApiException {
      rethrow;
    }
  }

  void refresh() => loadMembers();
}

final membersNotifierProvider = StateNotifierProvider.family<MembersNotifier, MembersState, String>((ref, orgId) {
  final service = ref.watch(organizationServiceProvider);
  return MembersNotifier(service, orgId);
});

// Filter for members by role
final membersFilterProvider = StateProvider<String?>((ref) => null);
final membersStatusFilterProvider = StateProvider<String?>((ref) => null);

// Filtered members
final filteredMembersProvider = Provider.family<List<Map<String, dynamic>>, String>((ref, orgId) {
  final members = ref.watch(membersNotifierProvider(orgId)).members;
  final roleFilter = ref.watch(membersFilterProvider);
  final statusFilter = ref.watch(membersStatusFilterProvider);

  return members.where((m) {
    if (roleFilter != null && m['role'] != roleFilter) return false;
    if (statusFilter != null && m['status'] != statusFilter) return false;
    return true;
  }).toList();
});

// ==================== Trainers (Filtered Members) ====================

final trainersProvider = Provider.family<List<Map<String, dynamic>>, String>((ref, orgId) {
  final members = ref.watch(membersNotifierProvider(orgId)).members;
  return members.where((m) => m['role'] == 'trainer').toList();
});

// ==================== Staff (Filtered Members) ====================

final staffProvider = Provider.family<List<Map<String, dynamic>>, String>((ref, orgId) {
  final members = ref.watch(membersNotifierProvider(orgId)).members;
  return members.where((m) => m['role'] == 'staff' || m['role'] == 'admin').toList();
});

// ==================== Students (Filtered Members) ====================

final studentsProvider = Provider.family<List<Map<String, dynamic>>, String>((ref, orgId) {
  final members = ref.watch(membersNotifierProvider(orgId)).members;
  return members.where((m) => m['role'] == 'member' || m['role'] == 'student').toList();
});

// ==================== Invites ====================

class InvitesState {
  final List<Map<String, dynamic>> invites;
  final bool isLoading;
  final String? error;

  const InvitesState({
    this.invites = const [],
    this.isLoading = false,
    this.error,
  });

  InvitesState copyWith({
    List<Map<String, dynamic>>? invites,
    bool? isLoading,
    String? error,
  }) {
    return InvitesState(
      invites: invites ?? this.invites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class InvitesNotifier extends StateNotifier<InvitesState> {
  final OrganizationService _service;
  final String orgId;

  InvitesNotifier(this._service, this.orgId) : super(const InvitesState()) {
    loadInvites();
  }

  Future<void> loadInvites() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final invites = await _service.getInvites(orgId);
      state = state.copyWith(invites: invites, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar convites');
    }
  }

  Future<void> sendInvite({
    required String email,
    required String role,
  }) async {
    try {
      final invite = await _service.sendInvite(orgId, email: email, role: role);
      state = state.copyWith(invites: [invite, ...state.invites]);
    } on ApiException {
      rethrow;
    }
  }

  void refresh() => loadInvites();
}

final invitesNotifierProvider = StateNotifierProvider.family<InvitesNotifier, InvitesState, String>((ref, orgId) {
  final service = ref.watch(organizationServiceProvider);
  return InvitesNotifier(service, orgId);
});

// ==================== Organization Stats ====================

class OrganizationStatsState {
  final Map<String, dynamic> stats;
  final bool isLoading;
  final String? error;

  const OrganizationStatsState({
    this.stats = const {},
    this.isLoading = false,
    this.error,
  });

  OrganizationStatsState copyWith({
    Map<String, dynamic>? stats,
    bool? isLoading,
    String? error,
  }) {
    return OrganizationStatsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OrganizationStatsNotifier extends StateNotifier<OrganizationStatsState> {
  final OrganizationService _service;
  final String orgId;

  OrganizationStatsNotifier(this._service, this.orgId) : super(const OrganizationStatsState()) {
    loadStats();
  }

  Future<void> loadStats({int days = 30}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stats = await _service.getOrganizationStats(orgId, days: days);
      state = state.copyWith(stats: stats, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar estatísticas');
    }
  }

  void refresh() => loadStats();
}

final organizationStatsNotifierProvider = StateNotifierProvider.family<OrganizationStatsNotifier, OrganizationStatsState, String>((ref, orgId) {
  final service = ref.watch(organizationServiceProvider);
  return OrganizationStatsNotifier(service, orgId);
});

// ==================== Organization Reports ====================

class OrganizationReportState {
  final Map<String, dynamic> report;
  final bool isLoading;
  final String? error;

  const OrganizationReportState({
    this.report = const {},
    this.isLoading = false,
    this.error,
  });

  OrganizationReportState copyWith({
    Map<String, dynamic>? report,
    bool? isLoading,
    String? error,
  }) {
    return OrganizationReportState(
      report: report ?? this.report,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OrganizationReportNotifier extends StateNotifier<OrganizationReportState> {
  final OrganizationService _service;
  final String orgId;

  OrganizationReportNotifier(this._service, this.orgId) : super(const OrganizationReportState());

  Future<void> generateReport({
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final report = await _service.getOrganizationReport(
        orgId,
        reportType: reportType,
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(report: report, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao gerar relatório');
    }
  }

  void clearReport() {
    state = const OrganizationReportState();
  }
}

final organizationReportNotifierProvider = StateNotifierProvider.family<OrganizationReportNotifier, OrganizationReportState, String>((ref, orgId) {
  final service = ref.watch(organizationServiceProvider);
  return OrganizationReportNotifier(service, orgId);
});

// ==================== Convenience Providers ====================

// Members count by role
final memberCountsProvider = Provider.family<Map<String, int>, String>((ref, orgId) {
  final members = ref.watch(membersNotifierProvider(orgId)).members;
  final counts = <String, int>{
    'total': members.length,
    'students': 0,
    'trainers': 0,
    'staff': 0,
    'active': 0,
    'inactive': 0,
  };

  for (final member in members) {
    final role = member['role'] as String? ?? '';
    final status = member['status'] as String? ?? '';

    if (role == 'member' || role == 'student') {
      counts['students'] = (counts['students'] ?? 0) + 1;
    } else if (role == 'trainer') {
      counts['trainers'] = (counts['trainers'] ?? 0) + 1;
    } else if (role == 'staff' || role == 'admin') {
      counts['staff'] = (counts['staff'] ?? 0) + 1;
    }

    if (status == 'active') {
      counts['active'] = (counts['active'] ?? 0) + 1;
    } else {
      counts['inactive'] = (counts['inactive'] ?? 0) + 1;
    }
  }

  return counts;
});

// Loading states
final isMembersLoadingProvider = Provider.family<bool, String>((ref, orgId) {
  return ref.watch(membersNotifierProvider(orgId)).isLoading;
});

final isOrganizationStatsLoadingProvider = Provider.family<bool, String>((ref, orgId) {
  return ref.watch(organizationStatsNotifierProvider(orgId)).isLoading;
});
