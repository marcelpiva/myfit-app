import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/nutrition_service.dart';

/// Diet Plan model
class DietPlan {
  final String id;
  final String name;
  final String description;
  final int calories;
  final int assignedCount;
  final List<String> tags;
  final bool isTemplate;
  final bool isShared;

  const DietPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
    this.assignedCount = 0,
    this.tags = const [],
    this.isTemplate = false,
    this.isShared = false,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    return DietPlan(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      calories: json['target_calories'] ?? json['calories'] ?? 0,
      assignedCount: json['assigned_count'] ?? json['assignedCount'] ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isTemplate: json['is_template'] ?? json['isTemplate'] ?? false,
      isShared: json['is_shared'] ?? json['isShared'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'calories': calories,
      'assignedCount': assignedCount,
      'tags': tags,
      'isTemplate': isTemplate,
      'isShared': isShared,
    };
  }
}

/// State for diet plans
class DietPlansState {
  final List<DietPlan> plans;
  final bool isLoading;
  final String? error;

  const DietPlansState({
    this.plans = const [],
    this.isLoading = false,
    this.error,
  });

  DietPlansState copyWith({
    List<DietPlan>? plans,
    bool? isLoading,
    String? error,
  }) {
    return DietPlansState(
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get myPlansCount => plans.where((p) => !p.isTemplate && !p.isShared).length;
  int get templatesCount => plans.where((p) => p.isTemplate).length;
  int get sharedCount => plans.where((p) => p.isShared).length;
}

/// Diet plans notifier
class DietPlansNotifier extends StateNotifier<DietPlansState> {
  final NutritionService _service;

  DietPlansNotifier({NutritionService? service})
      : _service = service ?? NutritionService(),
        super(const DietPlansState());

  /// Load diet plans
  Future<void> loadPlans() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getDietPlans();
      final plans = data.map((e) => DietPlan.fromJson(e)).toList();
      state = state.copyWith(plans: plans, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create diet plan
  Future<bool> createPlan({
    required String name,
    String? description,
    int? targetCalories,
  }) async {
    try {
      await _service.createDietPlan(
        name: name,
        description: description,
        targetCalories: targetCalories,
      );
      await loadPlans();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete diet plan
  Future<bool> deletePlan(String planId) async {
    try {
      await _service.deleteDietPlan(planId);
      state = state.copyWith(
        plans: state.plans.where((p) => p.id != planId).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for diet plans
final dietPlansProvider =
    StateNotifierProvider<DietPlansNotifier, DietPlansState>((ref) {
  return DietPlansNotifier();
});
