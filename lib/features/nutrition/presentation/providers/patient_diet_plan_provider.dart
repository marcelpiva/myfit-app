import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/nutrition_service.dart';

// ==================== Models ====================

/// Food item in a meal
class MealFood {
  final String id;
  final String name;
  final String portion;
  final int calories;

  const MealFood({
    required this.id,
    required this.name,
    required this.portion,
    required this.calories,
  });

  factory MealFood.fromJson(Map<String, dynamic> json) {
    return MealFood(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['food_name'] ?? '',
      portion: json['portion'] ?? json['serving_size'] ?? '',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Meal in a diet plan
class PlanMeal {
  final String id;
  final String name;
  final String time;
  final int calories;
  final IconData icon;
  final Color color;
  final List<MealFood> foods;

  const PlanMeal({
    required this.id,
    required this.name,
    required this.time,
    required this.calories,
    required this.icon,
    required this.color,
    required this.foods,
  });

  factory PlanMeal.fromJson(Map<String, dynamic> json) {
    final mealType = json['meal_type'] ?? json['type'] ?? 'snack';
    final foods = (json['foods'] as List<dynamic>?)
            ?.map((f) => MealFood.fromJson(f as Map<String, dynamic>))
            .toList() ??
        [];

    return PlanMeal(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? _getMealName(mealType),
      time: json['time'] ?? json['scheduled_time'] ?? _getMealTime(mealType),
      calories: (json['calories'] as num?)?.toInt() ??
          foods.fold(0, (sum, food) => sum + food.calories),
      icon: _getMealIcon(mealType),
      color: _getMealColor(mealType),
      foods: foods,
    );
  }

  static String _getMealName(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return 'Café da Manhã';
      case 'lunch':
        return 'Almoço';
      case 'dinner':
        return 'Jantar';
      case 'snack':
      case 'afternoon_snack':
        return 'Lanche';
      case 'morning_snack':
        return 'Lanche da Manhã';
      default:
        return 'Refeição';
    }
  }

  static String _getMealTime(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return '07:00 - 08:00';
      case 'morning_snack':
        return '10:00 - 10:30';
      case 'lunch':
        return '12:00 - 13:00';
      case 'afternoon_snack':
      case 'snack':
        return '16:00 - 17:00';
      case 'dinner':
        return '19:00 - 20:00';
      default:
        return '';
    }
  }

  static IconData _getMealIcon(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return LucideIcons.coffee;
      case 'lunch':
        return LucideIcons.utensils;
      case 'dinner':
        return LucideIcons.moon;
      case 'snack':
      case 'afternoon_snack':
      case 'morning_snack':
        return LucideIcons.apple;
      default:
        return LucideIcons.utensils;
    }
  }

  static Color _getMealColor(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return AppColors.warning;
      case 'lunch':
        return AppColors.success;
      case 'dinner':
        return AppColors.secondary;
      case 'snack':
      case 'afternoon_snack':
      case 'morning_snack':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'calories': calories,
      'icon': icon,
      'color': color,
      'foods': foods
          .map((f) => {'name': f.name, 'portion': f.portion, 'calories': f.calories})
          .toList(),
    };
  }
}

/// Daily nutrition targets
class DailyTargets {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const DailyTargets({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  factory DailyTargets.fromJson(Map<String, dynamic> json) {
    return DailyTargets(
      calories: (json['target_calories'] ?? json['calories'] ?? 0) as int,
      protein: (json['target_protein'] ?? json['protein'] ?? 0) as int,
      carbs: (json['target_carbs'] ?? json['carbs'] ?? 0) as int,
      fat: (json['target_fat'] ?? json['fat'] ?? 0) as int,
    );
  }
}

/// Patient diet plan summary
class PatientPlanSummary {
  final String planId;
  final String planName;
  final DateTime? startDate;
  final int durationDays;
  final double adherence;

  const PatientPlanSummary({
    required this.planId,
    required this.planName,
    this.startDate,
    this.durationDays = 0,
    this.adherence = 0,
  });

  factory PatientPlanSummary.fromJson(Map<String, dynamic> json) {
    return PatientPlanSummary(
      planId: json['plan_id']?.toString() ?? json['id']?.toString() ?? '',
      planName: json['plan_name'] ?? json['name'] ?? '',
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
      durationDays: (json['duration_days'] ?? json['duration'] ?? 0) as int,
      adherence: (json['adherence'] as num?)?.toDouble() ?? 0,
    );
  }

  String get formattedStartDate {
    if (startDate == null) return '';
    final months = [
      '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${startDate!.day} ${months[startDate!.month]}';
  }

  String get formattedDuration {
    return '$durationDays dias';
  }
}

/// Previous diet plan in history
class PreviousPlan {
  final String id;
  final String name;
  final String period;
  final int calories;
  final int adherence;

  const PreviousPlan({
    required this.id,
    required this.name,
    required this.period,
    required this.calories,
    required this.adherence,
  });

  factory PreviousPlan.fromJson(Map<String, dynamic> json) {
    return PreviousPlan(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      period: json['period'] ?? _formatPeriod(json['start_date'], json['end_date']),
      calories: (json['target_calories'] ?? json['calories'] ?? 0) as int,
      adherence: (json['adherence'] as num?)?.toInt() ?? 0,
    );
  }

  static String _formatPeriod(String? start, String? end) {
    if (start == null || end == null) return '';
    final startDate = DateTime.tryParse(start);
    final endDate = DateTime.tryParse(end);
    if (startDate == null || endDate == null) return '';

    final months = [
      '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[startDate.month]} - ${months[endDate.month]} ${endDate.year}';
  }
}

/// Patient note from nutritionist
class PatientNote {
  final String id;
  final String date;
  final String content;
  final String? category;

  const PatientNote({
    required this.id,
    required this.date,
    required this.content,
    this.category,
  });

  factory PatientNote.fromJson(Map<String, dynamic> json) {
    return PatientNote(
      id: json['id']?.toString() ?? '',
      date: json['formatted_date'] ?? _formatDate(json['created_at']),
      content: json['content'] ?? '',
      category: json['category'],
    );
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';

    final months = [
      '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}

// ==================== State ====================

class PatientDietPlanState {
  final PatientPlanSummary? summary;
  final DailyTargets targets;
  final List<PlanMeal> meals;
  final List<PreviousPlan> previousPlans;
  final List<PatientNote> notes;
  final bool isLoading;
  final String? error;

  const PatientDietPlanState({
    this.summary,
    this.targets = const DailyTargets(),
    this.meals = const [],
    this.previousPlans = const [],
    this.notes = const [],
    this.isLoading = false,
    this.error,
  });

  PatientDietPlanState copyWith({
    PatientPlanSummary? summary,
    DailyTargets? targets,
    List<PlanMeal>? meals,
    List<PreviousPlan>? previousPlans,
    List<PatientNote>? notes,
    bool? isLoading,
    String? error,
  }) {
    return PatientDietPlanState(
      summary: summary ?? this.summary,
      targets: targets ?? this.targets,
      meals: meals ?? this.meals,
      previousPlans: previousPlans ?? this.previousPlans,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasPlan => summary != null;
  int get previousPlansCount => previousPlans.length;
}

// ==================== Notifier ====================

class PatientDietPlanNotifier extends StateNotifier<PatientDietPlanState> {
  final NutritionService _service;
  final String patientId;

  PatientDietPlanNotifier(this._service, this.patientId)
      : super(const PatientDietPlanState()) {
    loadAll();
  }

  /// Load all data in parallel
  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.wait([
        _loadDietPlan(),
        _loadHistory(),
        _loadNotes(),
      ]);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar dados do paciente',
      );
    }
  }

  Future<void> _loadDietPlan() async {
    try {
      final data = await _service.getPatientDietPlan(patientId);
      final summary = PatientPlanSummary.fromJson(data);
      final targets = DailyTargets.fromJson(data);
      final meals = (data['meals'] as List<dynamic>?)
              ?.map((m) => PlanMeal.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [];
      state = state.copyWith(summary: summary, targets: targets, meals: meals);
    } catch (e) {
      // No diet plan assigned - this is valid
    }
  }

  Future<void> _loadHistory() async {
    try {
      final data = await _service.getPatientDietHistory(patientId);
      final plans = data.map((p) => PreviousPlan.fromJson(p)).toList();
      state = state.copyWith(previousPlans: plans);
    } catch (e) {
      // No history - this is valid
    }
  }

  Future<void> _loadNotes() async {
    try {
      final data = await _service.getPatientNotes(patientId);
      final notes = data.map((n) => PatientNote.fromJson(n)).toList();
      state = state.copyWith(notes: notes);
    } catch (e) {
      // No notes - this is valid
    }
  }

  /// Add a note to the patient
  Future<bool> addNote(String content, {String? category}) async {
    try {
      await _service.createPatientNote(
        patientId: patientId,
        content: content,
        category: category,
      );
      await _loadNotes();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Refresh all data
  Future<void> refresh() async => loadAll();
}

// ==================== Providers ====================

/// Service provider
final patientDietPlanServiceProvider = Provider<NutritionService>((ref) {
  return NutritionService();
});

/// Patient diet plan provider (family - receives patientId)
final patientDietPlanNotifierProvider = StateNotifierProvider.family<
    PatientDietPlanNotifier, PatientDietPlanState, String>((ref, patientId) {
  final service = ref.watch(patientDietPlanServiceProvider);
  return PatientDietPlanNotifier(service, patientId);
});

/// Convenience providers
final patientMealsProvider = Provider.family<List<PlanMeal>, String>((ref, patientId) {
  return ref.watch(patientDietPlanNotifierProvider(patientId)).meals;
});

final patientNotesProvider = Provider.family<List<PatientNote>, String>((ref, patientId) {
  return ref.watch(patientDietPlanNotifierProvider(patientId)).notes;
});

final patientPreviousPlansProvider = Provider.family<List<PreviousPlan>, String>((ref, patientId) {
  return ref.watch(patientDietPlanNotifierProvider(patientId)).previousPlans;
});

final isPatientDietPlanLoadingProvider = Provider.family<bool, String>((ref, patientId) {
  return ref.watch(patientDietPlanNotifierProvider(patientId)).isLoading;
});
