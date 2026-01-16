import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/organization_service.dart';

/// Patient model for nutritionists
class Patient {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime? nextAppointment;
  final double adherence;
  final String? goal;
  final bool hasPlan;

  const Patient({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.nextAppointment,
    this.adherence = 0,
    this.goal,
    this.hasPlan = false,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['user_name'] ?? '',
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      nextAppointment: json['next_appointment'] != null
          ? DateTime.tryParse(json['next_appointment'])
          : null,
      adherence: (json['adherence'] as num?)?.toDouble() ?? 0,
      goal: json['goal'] ?? json['nutrition_goal'],
      hasPlan: json['has_plan'] ?? json['hasPlan'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'nextAppointment': nextAppointment?.toIso8601String(),
      'adherence': adherence,
      'goal': goal,
      'hasPlan': hasPlan,
    };
  }
}

/// State for patients list
class PatientsState {
  final List<Patient> patients;
  final bool isLoading;
  final String? error;

  const PatientsState({
    this.patients = const [],
    this.isLoading = false,
    this.error,
  });

  PatientsState copyWith({
    List<Patient>? patients,
    bool? isLoading,
    String? error,
  }) {
    return PatientsState(
      patients: patients ?? this.patients,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get totalCount => patients.length;
  int get withPlanCount => patients.where((p) => p.hasPlan).length;
  int get withoutPlanCount => patients.where((p) => !p.hasPlan).length;
}

/// Patients notifier
class PatientsNotifier extends StateNotifier<PatientsState> {
  final OrganizationService _service;
  final String? orgId;

  PatientsNotifier(this._service, this.orgId) : super(const PatientsState()) {
    if (orgId != null) {
      loadPatients();
    }
  }

  /// Load patients for the organization
  Future<void> loadPatients() async {
    if (orgId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getMembers(orgId!, role: 'student');
      final patients = data.map((e) => Patient.fromJson(e)).toList();
      state = state.copyWith(patients: patients, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar pacientes',
      );
    }
  }

  /// Refresh patients list
  Future<void> refresh() async {
    await loadPatients();
  }
}

/// Service provider
final patientsServiceProvider = Provider<OrganizationService>((ref) {
  return OrganizationService();
});

/// Patients provider (family - receives orgId)
final patientsNotifierProvider =
    StateNotifierProvider.family<PatientsNotifier, PatientsState, String?>((ref, orgId) {
  final service = ref.watch(patientsServiceProvider);
  return PatientsNotifier(service, orgId);
});

/// Simple provider for backward compatibility
final patientsProvider = Provider.family<List<Patient>, String?>((ref, orgId) {
  return ref.watch(patientsNotifierProvider(orgId)).patients;
});

/// Loading state provider
final isPatientsLoadingProvider = Provider.family<bool, String?>((ref, orgId) {
  return ref.watch(patientsNotifierProvider(orgId)).isLoading;
});
