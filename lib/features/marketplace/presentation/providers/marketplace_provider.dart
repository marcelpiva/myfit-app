import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/marketplace_service.dart';

// ==================== Service Provider ====================

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  return MarketplaceService();
});

// ==================== Template Models ====================

class MarketplaceTemplate {
  final String id;
  final String templateType;
  final String title;
  final String? shortDescription;
  final String? coverImageUrl;
  final int priceCents;
  final String priceDisplay;
  final bool isFree;
  final String? category;
  final String difficulty;
  final int purchaseCount;
  final double? ratingAverage;
  final int ratingCount;
  final bool isFeatured;
  final String creatorId;
  final String creatorName;
  final String? creatorAvatarUrl;

  const MarketplaceTemplate({
    required this.id,
    required this.templateType,
    required this.title,
    this.shortDescription,
    this.coverImageUrl,
    required this.priceCents,
    required this.priceDisplay,
    required this.isFree,
    this.category,
    required this.difficulty,
    required this.purchaseCount,
    this.ratingAverage,
    required this.ratingCount,
    required this.isFeatured,
    required this.creatorId,
    required this.creatorName,
    this.creatorAvatarUrl,
  });

  factory MarketplaceTemplate.fromJson(Map<String, dynamic> json) {
    final creator = json['creator'] as Map<String, dynamic>?;
    return MarketplaceTemplate(
      id: json['id'] ?? '',
      templateType: json['template_type'] ?? 'workout',
      title: json['title'] ?? '',
      shortDescription: json['short_description'],
      coverImageUrl: json['cover_image_url'],
      priceCents: json['price_cents'] ?? 0,
      priceDisplay: json['price_display'] ?? 'Grátis',
      isFree: json['is_free'] ?? true,
      category: json['category'],
      difficulty: json['difficulty'] ?? 'intermediate',
      purchaseCount: json['purchase_count'] ?? 0,
      ratingAverage: json['rating_average'] != null
          ? double.tryParse(json['rating_average'].toString())
          : null,
      ratingCount: json['rating_count'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      creatorId: creator?['id'] ?? '',
      creatorName: creator?['name'] ?? 'Criador',
      creatorAvatarUrl: creator?['avatar_url'],
    );
  }
}

class TemplateCategory {
  final String category;
  final String name;
  final int templateCount;

  const TemplateCategory({
    required this.category,
    required this.name,
    required this.templateCount,
  });

  factory TemplateCategory.fromJson(Map<String, dynamic> json) {
    return TemplateCategory(
      category: json['category'] ?? '',
      name: json['name'] ?? '',
      templateCount: json['template_count'] ?? 0,
    );
  }
}

class TemplatePurchase {
  final String id;
  final String templateId;
  final String templateTitle;
  final String templateType;
  final int priceCents;
  final String status;
  final String? duplicatedWorkoutId;
  final String? duplicatedDietPlanId;
  final DateTime? completedAt;
  final DateTime createdAt;

  const TemplatePurchase({
    required this.id,
    required this.templateId,
    required this.templateTitle,
    required this.templateType,
    required this.priceCents,
    required this.status,
    this.duplicatedWorkoutId,
    this.duplicatedDietPlanId,
    this.completedAt,
    required this.createdAt,
  });

  factory TemplatePurchase.fromJson(Map<String, dynamic> json) {
    return TemplatePurchase(
      id: json['id'] ?? '',
      templateId: json['template_id'] ?? '',
      templateTitle: json['template_title'] ?? '',
      templateType: json['template_type'] ?? 'workout',
      priceCents: json['price_cents'] ?? 0,
      status: json['status'] ?? 'pending',
      duplicatedWorkoutId: json['duplicated_workout_id'],
      duplicatedDietPlanId: json['duplicated_diet_plan_id'],
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isCompleted => status == 'completed';
}

// ==================== Templates State ====================

class MarketplaceState {
  final List<MarketplaceTemplate> templates;
  final List<MarketplaceTemplate> featuredTemplates;
  final List<TemplateCategory> categories;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;
  final String? selectedType;
  final String? searchQuery;

  const MarketplaceState({
    this.templates = const [],
    this.featuredTemplates = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.selectedType,
    this.searchQuery,
  });

  MarketplaceState copyWith({
    List<MarketplaceTemplate>? templates,
    List<MarketplaceTemplate>? featuredTemplates,
    List<TemplateCategory>? categories,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    String? selectedType,
    String? searchQuery,
    bool clearError = false,
  }) {
    return MarketplaceState(
      templates: templates ?? this.templates,
      featuredTemplates: featuredTemplates ?? this.featuredTemplates,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedType: selectedType ?? this.selectedType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class MarketplaceNotifier extends StateNotifier<MarketplaceState> {
  final MarketplaceService _service;

  MarketplaceNotifier(this._service) : super(const MarketplaceState()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _service.getTemplates(),
        _service.getFeaturedTemplates(),
        _service.getCategories(),
      ]);

      final templates = (results[0] as List)
          .map((t) => MarketplaceTemplate.fromJson(t))
          .toList();
      final featured = (results[1] as List)
          .map((t) => MarketplaceTemplate.fromJson(t))
          .toList();
      final categories = (results[2] as List)
          .map((c) => TemplateCategory.fromJson(c))
          .toList();

      state = state.copyWith(
        templates: templates,
        featuredTemplates: featured,
        categories: categories,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar marketplace');
    }
  }

  Future<void> loadTemplates({
    String? category,
    String? templateType,
    String? search,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedCategory: category,
      selectedType: templateType,
      searchQuery: search,
    );
    try {
      final templates = await _service.getTemplates(
        category: category,
        templateType: templateType,
        search: search,
      );
      state = state.copyWith(
        templates: templates.map((t) => MarketplaceTemplate.fromJson(t)).toList(),
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar templates');
    }
  }

  void setFilter({String? category, String? type}) {
    loadTemplates(
      category: category,
      templateType: type,
      search: state.searchQuery,
    );
  }

  void search(String query) {
    loadTemplates(
      category: state.selectedCategory,
      templateType: state.selectedType,
      search: query.isEmpty ? null : query,
    );
  }

  void refresh() => loadInitialData();
}

final marketplaceNotifierProvider =
    StateNotifierProvider<MarketplaceNotifier, MarketplaceState>((ref) {
  final service = ref.watch(marketplaceServiceProvider);
  return MarketplaceNotifier(service);
});

// ==================== Purchases State ====================

class PurchasesState {
  final List<TemplatePurchase> purchases;
  final bool isLoading;
  final String? error;

  const PurchasesState({
    this.purchases = const [],
    this.isLoading = false,
    this.error,
  });

  PurchasesState copyWith({
    List<TemplatePurchase>? purchases,
    bool? isLoading,
    String? error,
  }) {
    return PurchasesState(
      purchases: purchases ?? this.purchases,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PurchasesNotifier extends StateNotifier<PurchasesState> {
  final MarketplaceService _service;

  PurchasesNotifier(this._service) : super(const PurchasesState()) {
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final purchases = await _service.getMyPurchases();
      state = state.copyWith(
        purchases: purchases.map((p) => TemplatePurchase.fromJson(p)).toList(),
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar compras');
    }
  }

  void refresh() => loadPurchases();
}

final purchasesNotifierProvider =
    StateNotifierProvider<PurchasesNotifier, PurchasesState>((ref) {
  final service = ref.watch(marketplaceServiceProvider);
  return PurchasesNotifier(service);
});

// ==================== Convenience Providers ====================

final marketplaceTemplatesProvider = Provider<List<MarketplaceTemplate>>((ref) {
  return ref.watch(marketplaceNotifierProvider).templates;
});

final featuredTemplatesProvider = Provider<List<MarketplaceTemplate>>((ref) {
  return ref.watch(marketplaceNotifierProvider).featuredTemplates;
});

final marketplaceCategoriesProvider = Provider<List<TemplateCategory>>((ref) {
  return ref.watch(marketplaceNotifierProvider).categories;
});

final isMarketplaceLoadingProvider = Provider<bool>((ref) {
  return ref.watch(marketplaceNotifierProvider).isLoading;
});

final myPurchasesProvider = Provider<List<TemplatePurchase>>((ref) {
  return ref.watch(purchasesNotifierProvider).purchases;
});
