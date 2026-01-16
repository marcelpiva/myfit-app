import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/nutrition_service.dart';

// Service provider
final nutritionServiceProvider = Provider<NutritionService>((ref) {
  return NutritionService();
});

// ==================== Food Search ====================

class FoodSearchState {
  final List<Map<String, dynamic>> results;
  final bool isLoading;
  final String? error;
  final String query;

  const FoodSearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
  });

  FoodSearchState copyWith({
    List<Map<String, dynamic>>? results,
    bool? isLoading,
    String? error,
    String? query,
  }) {
    return FoodSearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
    );
  }
}

class FoodSearchNotifier extends StateNotifier<FoodSearchState> {
  final NutritionService _service;

  FoodSearchNotifier(this._service) : super(const FoodSearchState());

  Future<void> searchFoods(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(results: [], query: '');
      return;
    }

    state = state.copyWith(isLoading: true, error: null, query: query);
    try {
      final results = await _service.searchFoods(query: query);
      state = state.copyWith(results: results, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro na busca');
    }
  }

  Future<Map<String, dynamic>?> getFoodByBarcode(String barcode) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final food = await _service.getFoodByBarcode(barcode);
      state = state.copyWith(isLoading: false);
      return food;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Alimento não encontrado');
      return null;
    }
  }

  void clearSearch() {
    state = const FoodSearchState();
  }
}

final foodSearchNotifierProvider = StateNotifierProvider<FoodSearchNotifier, FoodSearchState>((ref) {
  final service = ref.watch(nutritionServiceProvider);
  return FoodSearchNotifier(service);
});

// ==================== Favorites ====================

class FavoriteFoodsState {
  final List<Map<String, dynamic>> favorites;
  final bool isLoading;
  final String? error;

  const FavoriteFoodsState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  FavoriteFoodsState copyWith({
    List<Map<String, dynamic>>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return FavoriteFoodsState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FavoriteFoodsNotifier extends StateNotifier<FavoriteFoodsState> {
  final NutritionService _service;

  FavoriteFoodsNotifier(this._service) : super(const FavoriteFoodsState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final favorites = await _service.getFavorites();
      state = state.copyWith(favorites: favorites, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar favoritos');
    }
  }

  Future<void> addFavorite(String foodId) async {
    try {
      await _service.addFavorite(foodId);
      loadFavorites();
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> removeFavorite(String foodId) async {
    try {
      await _service.removeFavorite(foodId);
      state = state.copyWith(
        favorites: state.favorites.where((f) => f['id'] != foodId).toList(),
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  void refresh() => loadFavorites();
}

final favoriteFoodsNotifierProvider = StateNotifierProvider<FavoriteFoodsNotifier, FavoriteFoodsState>((ref) {
  final service = ref.watch(nutritionServiceProvider);
  return FavoriteFoodsNotifier(service);
});

// ==================== Diet Plans ====================

class DietPlansState {
  final List<Map<String, dynamic>> plans;
  final bool isLoading;
  final String? error;

  const DietPlansState({
    this.plans = const [],
    this.isLoading = false,
    this.error,
  });

  DietPlansState copyWith({
    List<Map<String, dynamic>>? plans,
    bool? isLoading,
    String? error,
  }) {
    return DietPlansState(
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DietPlansNotifier extends StateNotifier<DietPlansState> {
  final NutritionService _service;

  DietPlansNotifier(this._service) : super(const DietPlansState()) {
    loadDietPlans();
  }

  Future<void> loadDietPlans() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final plans = await _service.getDietPlans();
      state = state.copyWith(plans: plans, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar planos');
    }
  }

  Future<Map<String, dynamic>?> getDietPlan(String planId) async {
    try {
      return await _service.getDietPlan(planId);
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> createDietPlan({
    required String name,
    String? description,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
  }) async {
    try {
      final plan = await _service.createDietPlan(
        name: name,
        description: description,
        targetCalories: targetCalories,
        targetProtein: targetProtein,
        targetCarbs: targetCarbs,
        targetFat: targetFat,
      );
      state = state.copyWith(plans: [plan, ...state.plans]);
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> deleteDietPlan(String planId) async {
    try {
      await _service.deleteDietPlan(planId);
      state = state.copyWith(
        plans: state.plans.where((p) => p['id'] != planId).toList(),
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  void refresh() => loadDietPlans();
}

final dietPlansNotifierProvider = StateNotifierProvider<DietPlansNotifier, DietPlansState>((ref) {
  final service = ref.watch(nutritionServiceProvider);
  return DietPlansNotifier(service);
});

// ==================== Meal Logs ====================

class MealLogsState {
  final List<Map<String, dynamic>> logs;
  final bool isLoading;
  final String? error;

  const MealLogsState({
    this.logs = const [],
    this.isLoading = false,
    this.error,
  });

  MealLogsState copyWith({
    List<Map<String, dynamic>>? logs,
    bool? isLoading,
    String? error,
  }) {
    return MealLogsState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MealLogsNotifier extends StateNotifier<MealLogsState> {
  final NutritionService _service;

  MealLogsNotifier(this._service) : super(const MealLogsState()) {
    loadMealLogs();
  }

  Future<void> loadMealLogs({DateTime? date, DateTime? fromDate, DateTime? toDate}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final logs = await _service.getMealLogs(
        date: date,
        fromDate: fromDate,
        toDate: toDate,
      );
      state = state.copyWith(logs: logs, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar refeições');
    }
  }

  Future<void> addMealLog({
    required String foodId,
    required String mealType,
    required double quantity,
    DateTime? loggedAt,
    String? notes,
  }) async {
    try {
      final log = await _service.createMealLog(
        foodId: foodId,
        mealType: mealType,
        quantity: quantity,
        loggedAt: loggedAt,
        notes: notes,
      );
      state = state.copyWith(logs: [log, ...state.logs]);
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> updateMealLog(String logId, {
    String? mealType,
    double? quantity,
    String? notes,
  }) async {
    try {
      final log = await _service.updateMealLog(
        logId,
        mealType: mealType,
        quantity: quantity,
        notes: notes,
      );
      state = state.copyWith(
        logs: state.logs.map((l) => l['id'] == logId ? log : l).toList(),
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> deleteMealLog(String logId) async {
    try {
      await _service.deleteMealLog(logId);
      state = state.copyWith(
        logs: state.logs.where((l) => l['id'] != logId).toList(),
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  void refresh() => loadMealLogs();
}

final mealLogsNotifierProvider = StateNotifierProvider<MealLogsNotifier, MealLogsState>((ref) {
  final service = ref.watch(nutritionServiceProvider);
  return MealLogsNotifier(service);
});

// ==================== Daily Summary ====================

class DailySummaryState {
  final Map<String, dynamic> summary;
  final bool isLoading;
  final String? error;

  const DailySummaryState({
    this.summary = const {},
    this.isLoading = false,
    this.error,
  });

  DailySummaryState copyWith({
    Map<String, dynamic>? summary,
    bool? isLoading,
    String? error,
  }) {
    return DailySummaryState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DailySummaryNotifier extends StateNotifier<DailySummaryState> {
  final NutritionService _service;

  DailySummaryNotifier(this._service) : super(const DailySummaryState()) {
    loadDailySummary();
  }

  Future<void> loadDailySummary({DateTime? date}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final summary = await _service.getDailySummary(date: date);
      state = state.copyWith(summary: summary, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar resumo');
    }
  }

  void refresh() => loadDailySummary();
}

final dailySummaryNotifierProvider = StateNotifierProvider<DailySummaryNotifier, DailySummaryState>((ref) {
  final service = ref.watch(nutritionServiceProvider);
  return DailySummaryNotifier(service);
});

// ==================== Weekly Summary ====================

class WeeklySummaryState {
  final Map<String, dynamic> summary;
  final bool isLoading;
  final String? error;

  const WeeklySummaryState({
    this.summary = const {},
    this.isLoading = false,
    this.error,
  });

  WeeklySummaryState copyWith({
    Map<String, dynamic>? summary,
    bool? isLoading,
    String? error,
  }) {
    return WeeklySummaryState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WeeklySummaryNotifier extends StateNotifier<WeeklySummaryState> {
  final NutritionService _service;

  WeeklySummaryNotifier(this._service) : super(const WeeklySummaryState()) {
    loadWeeklySummary();
  }

  Future<void> loadWeeklySummary({DateTime? startDate}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final summary = await _service.getWeeklySummary(startDate: startDate);
      state = state.copyWith(summary: summary, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar resumo');
    }
  }

  void refresh() => loadWeeklySummary();
}

final weeklySummaryNotifierProvider = StateNotifierProvider<WeeklySummaryNotifier, WeeklySummaryState>((ref) {
  final service = ref.watch(nutritionServiceProvider);
  return WeeklySummaryNotifier(service);
});

// ==================== Convenience Providers ====================

// Simple providers for backward compatibility
final foodSearchResultsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(foodSearchNotifierProvider).results;
});

final favoriteFoodsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(favoriteFoodsNotifierProvider).favorites;
});

final dietPlansProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(dietPlansNotifierProvider).plans;
});

final mealLogsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(mealLogsNotifierProvider).logs;
});

final dailySummaryProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(dailySummaryNotifierProvider).summary;
});

final weeklySummaryProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(weeklySummaryNotifierProvider).summary;
});

// Loading state providers
final isFoodSearchLoadingProvider = Provider<bool>((ref) {
  return ref.watch(foodSearchNotifierProvider).isLoading;
});

final isMealLogsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(mealLogsNotifierProvider).isLoading;
});

final isDailySummaryLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dailySummaryNotifierProvider).isLoading;
});
