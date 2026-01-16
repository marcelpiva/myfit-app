import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/nutrition_service.dart';
import '../../../../core/services/organization_service.dart';

// Service providers
final coachOrgServiceProvider = Provider<OrganizationService>((ref) {
  return OrganizationService();
});

final coachNutritionServiceProvider = Provider<NutritionService>((ref) {
  return NutritionService();
});

// ==================== Coach Program Model ====================

class CoachProgram {
  final String id;
  final String name;
  final String studentName;
  final String? studentAvatarUrl;
  final int daysRemaining;
  final double adherencePercent;
  final String status; // active, paused, completed

  const CoachProgram({
    required this.id,
    required this.name,
    required this.studentName,
    this.studentAvatarUrl,
    required this.daysRemaining,
    required this.adherencePercent,
    required this.status,
  });
}

// ==================== Coach Activity Model ====================

class CoachActivity {
  final String id;
  final String type; // meal_logged, plan_completed, goal_reached
  final String studentName;
  final String? studentAvatarUrl;
  final String description;
  final DateTime timestamp;

  const CoachActivity({
    required this.id,
    required this.type,
    required this.studentName,
    this.studentAvatarUrl,
    required this.description,
    required this.timestamp,
  });
}

// ==================== Coach Dashboard State ====================

class CoachDashboardState {
  final int totalPatients;
  final int activePrograms;
  final double averageAdherence;
  final List<CoachProgram> programs;
  final List<CoachActivity> recentActivities;
  final bool isLoading;
  final String? error;

  const CoachDashboardState({
    this.totalPatients = 0,
    this.activePrograms = 0,
    this.averageAdherence = 0,
    this.programs = const [],
    this.recentActivities = const [],
    this.isLoading = false,
    this.error,
  });

  CoachDashboardState copyWith({
    int? totalPatients,
    int? activePrograms,
    double? averageAdherence,
    List<CoachProgram>? programs,
    List<CoachActivity>? recentActivities,
    bool? isLoading,
    String? error,
  }) {
    return CoachDashboardState(
      totalPatients: totalPatients ?? this.totalPatients,
      activePrograms: activePrograms ?? this.activePrograms,
      averageAdherence: averageAdherence ?? this.averageAdherence,
      programs: programs ?? this.programs,
      recentActivities: recentActivities ?? this.recentActivities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CoachDashboardNotifier extends StateNotifier<CoachDashboardState> {
  final OrganizationService _orgService;
  final NutritionService _nutritionService;
  final String? orgId;

  CoachDashboardNotifier(
    this._orgService,
    this._nutritionService,
    this.orgId,
  ) : super(const CoachDashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Load patients (members with role 'student')
      List<Map<String, dynamic>> patients = [];
      if (orgId != null) {
        patients = await _orgService.getMembers(orgId!, role: 'student');
      }

      // Load diet plans
      final plans = await _nutritionService.getDietPlans();

      // Build programs from plans
      final programs = plans.map((plan) {
        final endDate = DateTime.tryParse(plan['end_date'] as String? ?? '');
        final daysRemaining = endDate != null ? endDate.difference(DateTime.now()).inDays : 0;

        return CoachProgram(
          id: plan['id'] as String,
          name: plan['name'] as String? ?? 'Plano',
          studentName: plan['patient_name'] as String? ?? 'Paciente',
          studentAvatarUrl: plan['patient_avatar_url'] as String?,
          daysRemaining: daysRemaining > 0 ? daysRemaining : 0,
          adherencePercent: (plan['adherence'] as num?)?.toDouble() ?? 0,
          status: plan['status'] as String? ?? 'active',
        );
      }).toList();

      final activePrograms = programs.where((p) => p.status == 'active').length;
      final avgAdherence = programs.isNotEmpty
          ? programs.map((p) => p.adherencePercent).reduce((a, b) => a + b) / programs.length
          : 0.0;

      state = state.copyWith(
        totalPatients: patients.length,
        activePrograms: activePrograms,
        averageAdherence: avgAdherence,
        programs: programs,
        recentActivities: [], // TODO: Load from activity feed API when ready
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar dashboard');
    }
  }

  void refresh() => loadDashboard();
}

final coachDashboardNotifierProvider =
    StateNotifierProvider.family<CoachDashboardNotifier, CoachDashboardState, String?>((ref, orgId) {
  final orgService = ref.watch(coachOrgServiceProvider);
  final nutritionService = ref.watch(coachNutritionServiceProvider);
  return CoachDashboardNotifier(orgService, nutritionService, orgId);
});

// ==================== Convenience Providers ====================

final coachStatsProvider = Provider.family<Map<String, dynamic>, String?>((ref, orgId) {
  final state = ref.watch(coachDashboardNotifierProvider(orgId));
  return {
    'totalPatients': state.totalPatients,
    'activePrograms': state.activePrograms,
    'averageAdherence': state.averageAdherence,
  };
});

final coachProgramsProvider = Provider.family<List<CoachProgram>, String?>((ref, orgId) {
  return ref.watch(coachDashboardNotifierProvider(orgId)).programs;
});

final coachActivitiesProvider = Provider.family<List<CoachActivity>, String?>((ref, orgId) {
  return ref.watch(coachDashboardNotifierProvider(orgId)).recentActivities;
});

final isCoachDashboardLoadingProvider = Provider.family<bool, String?>((ref, orgId) {
  return ref.watch(coachDashboardNotifierProvider(orgId)).isLoading;
});
