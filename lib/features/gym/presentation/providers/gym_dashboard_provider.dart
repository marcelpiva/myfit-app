import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/organization_service.dart';
import 'organization_provider.dart';

// ==================== Gym Reports State ====================

class GymReportsState {
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> planBreakdown;
  final List<Map<String, dynamic>> categoryBreakdown;
  final List<Map<String, dynamic>> recentTransactions;
  final bool isLoading;
  final String? error;

  const GymReportsState({
    this.summary = const {},
    this.planBreakdown = const [],
    this.categoryBreakdown = const [],
    this.recentTransactions = const [],
    this.isLoading = false,
    this.error,
  });

  GymReportsState copyWith({
    Map<String, dynamic>? summary,
    List<Map<String, dynamic>>? planBreakdown,
    List<Map<String, dynamic>>? categoryBreakdown,
    List<Map<String, dynamic>>? recentTransactions,
    bool? isLoading,
    String? error,
  }) {
    return GymReportsState(
      summary: summary ?? this.summary,
      planBreakdown: planBreakdown ?? this.planBreakdown,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class GymReportsNotifier extends StateNotifier<GymReportsState> {
  final OrganizationService _service;
  final String orgId;

  GymReportsNotifier(this._service, this.orgId) : super(const GymReportsState()) {
    loadReports();
  }

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Load stats from organization
      final stats = await _service.getOrganizationStats(orgId, days: 30);

      // Build summary from stats
      final summary = {
        'revenue': {
          'value': 'R\$ ${_formatCurrency(stats['total_revenue'] as num? ?? 0)}',
          'change': _formatChange(stats['revenue_change'] as num? ?? 0),
          'positive': (stats['revenue_change'] as num? ?? 0) >= 0,
        },
        'newMembers': {
          'value': '${stats['new_members'] ?? 0}',
          'change': _formatChange(stats['new_members_change'] as num? ?? 0),
          'positive': (stats['new_members_change'] as num? ?? 0) >= 0,
        },
        'cancellations': {
          'value': '${stats['cancellations'] ?? 0}',
          'change': _formatChange(stats['cancellations_change'] as num? ?? 0),
          'positive': (stats['cancellations_change'] as num? ?? 0) <= 0, // Less is better
        },
        'retention': {
          'value': '${(stats['retention_rate'] as num? ?? 0).toStringAsFixed(1)}%',
          'change': _formatChange(stats['retention_change'] as num? ?? 0),
          'positive': (stats['retention_change'] as num? ?? 0) >= 0,
        },
      };

      // Plan breakdown from stats
      final planBreakdown = (stats['plan_breakdown'] as List<dynamic>?)
              ?.map((p) => p as Map<String, dynamic>)
              .toList() ??
          [];

      // Category breakdown from stats
      final categoryBreakdown = (stats['category_breakdown'] as List<dynamic>?)
              ?.map((c) => c as Map<String, dynamic>)
              .toList() ??
          [];

      // Recent transactions from stats
      final recentTransactions = (stats['recent_transactions'] as List<dynamic>?)
              ?.map((t) => t as Map<String, dynamic>)
              .toList() ??
          [];

      state = state.copyWith(
        summary: summary,
        planBreakdown: planBreakdown,
        categoryBreakdown: categoryBreakdown,
        recentTransactions: recentTransactions,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar relatórios');
    }
  }

  String _formatCurrency(num value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(2);
  }

  String _formatChange(num value) {
    final prefix = value >= 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}%';
  }

  void refresh() => loadReports();
}

final gymReportsNotifierProvider =
    StateNotifierProvider.family<GymReportsNotifier, GymReportsState, String>((ref, orgId) {
  final service = ref.watch(organizationServiceProvider);
  return GymReportsNotifier(service, orgId);
});

// ==================== Gym Settings State ====================

class GymSettingsState {
  final Map<String, dynamic> profile;
  final List<Map<String, dynamic>> plans;
  final List<Map<String, dynamic>> priceCategories;
  final List<Map<String, dynamic>> promotions;
  final List<Map<String, dynamic>> roles;
  final Map<String, dynamic> alertSettings;
  final List<Map<String, dynamic>> reminders;
  final List<Map<String, dynamic>> emailTemplates;
  final List<Map<String, dynamic>> connectedApps;
  final bool isLoading;
  final String? error;

  const GymSettingsState({
    this.profile = const {},
    this.plans = const [],
    this.priceCategories = const [],
    this.promotions = const [],
    this.roles = const [],
    this.alertSettings = const {},
    this.reminders = const [],
    this.emailTemplates = const [],
    this.connectedApps = const [],
    this.isLoading = false,
    this.error,
  });

  GymSettingsState copyWith({
    Map<String, dynamic>? profile,
    List<Map<String, dynamic>>? plans,
    List<Map<String, dynamic>>? priceCategories,
    List<Map<String, dynamic>>? promotions,
    List<Map<String, dynamic>>? roles,
    Map<String, dynamic>? alertSettings,
    List<Map<String, dynamic>>? reminders,
    List<Map<String, dynamic>>? emailTemplates,
    List<Map<String, dynamic>>? connectedApps,
    bool? isLoading,
    String? error,
  }) {
    return GymSettingsState(
      profile: profile ?? this.profile,
      plans: plans ?? this.plans,
      priceCategories: priceCategories ?? this.priceCategories,
      promotions: promotions ?? this.promotions,
      roles: roles ?? this.roles,
      alertSettings: alertSettings ?? this.alertSettings,
      reminders: reminders ?? this.reminders,
      emailTemplates: emailTemplates ?? this.emailTemplates,
      connectedApps: connectedApps ?? this.connectedApps,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class GymSettingsNotifier extends StateNotifier<GymSettingsState> {
  final OrganizationService _service;
  final String orgId;

  GymSettingsNotifier(this._service, this.orgId) : super(const GymSettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Load organization details as profile
      final org = await _service.getOrganization(orgId);

      state = state.copyWith(
        profile: {
          'name': org['name'],
          'description': org['description'],
          'phone': org['phone'],
          'email': org['email'],
          'address': org['address'],
          'logo': org['logo_url'],
        },
        // TODO: Load other settings from dedicated endpoints when ready
        plans: [],
        priceCategories: [],
        promotions: [],
        roles: [],
        alertSettings: {},
        reminders: [],
        emailTemplates: [],
        connectedApps: [],
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar configurações');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      await _service.updateOrganization(
        orgId,
        name: updates['name'] as String?,
        description: updates['description'] as String?,
        phone: updates['phone'] as String?,
        email: updates['email'] as String?,
        address: updates['address'] as String?,
      );
      state = state.copyWith(
        profile: {...state.profile, ...updates},
      );
    } on ApiException {
      rethrow;
    }
  }

  void refresh() => loadSettings();
}

final gymSettingsNotifierProvider =
    StateNotifierProvider.family<GymSettingsNotifier, GymSettingsState, String>((ref, orgId) {
  final service = ref.watch(organizationServiceProvider);
  return GymSettingsNotifier(service, orgId);
});

// ==================== Convenience Providers ====================

final gymProfileProvider = Provider.family<Map<String, dynamic>, String>((ref, orgId) {
  return ref.watch(gymSettingsNotifierProvider(orgId)).profile;
});

final gymReportsSummaryProvider = Provider.family<Map<String, dynamic>, String>((ref, orgId) {
  return ref.watch(gymReportsNotifierProvider(orgId)).summary;
});

final gymTransactionsProvider = Provider.family<List<Map<String, dynamic>>, String>((ref, orgId) {
  return ref.watch(gymReportsNotifierProvider(orgId)).recentTransactions;
});
