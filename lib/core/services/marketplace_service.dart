import 'package:dio/dio.dart';

import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Marketplace service for templates, purchases, and creator dashboard
class MarketplaceService {
  final ApiClient _client;

  MarketplaceService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // ==================== Templates ====================

  /// List marketplace templates with filters
  Future<List<Map<String, dynamic>>> getTemplates({
    String? templateType,
    String? category,
    String? difficulty,
    int? minPrice,
    int? maxPrice,
    bool? freeOnly,
    String? search,
    String sortBy = 'created_at',
    bool sortDesc = true,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'sort_by': sortBy,
        'sort_desc': sortDesc,
      };
      if (templateType != null) params['template_type'] = templateType;
      if (category != null) params['category'] = category;
      if (difficulty != null) params['difficulty'] = difficulty;
      if (minPrice != null) params['min_price'] = minPrice;
      if (maxPrice != null) params['max_price'] = maxPrice;
      if (freeOnly != null) params['free_only'] = freeOnly;
      if (search != null && search.isNotEmpty) params['search'] = search;

      final response = await _client.get(
        ApiEndpoints.marketplaceTemplates,
        queryParameters: params,
      );
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar templates', e);
    }
  }

  /// Get featured templates
  Future<List<Map<String, dynamic>>> getFeaturedTemplates({int limit = 10}) async {
    try {
      final response = await _client.get(
        ApiEndpoints.marketplaceFeatured,
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar destaques', e);
    }
  }

  /// Get template details
  Future<Map<String, dynamic>> getTemplate(String templateId) async {
    try {
      final response = await _client.get(ApiEndpoints.marketplaceTemplate(templateId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Template não encontrado');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar template', e);
    }
  }

  /// Get template preview (limited info)
  Future<Map<String, dynamic>> getTemplatePreview(String templateId) async {
    try {
      final response = await _client.get(ApiEndpoints.marketplaceTemplatePreview(templateId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Template não encontrado');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar preview', e);
    }
  }

  /// Create a new template listing
  Future<Map<String, dynamic>> createTemplate({
    required String templateType,
    required String title,
    int priceCents = 0,
    String? workoutId,
    String? dietPlanId,
    String? organizationId,
    String? shortDescription,
    String? fullDescription,
    String? coverImageUrl,
    List<String>? previewImages,
    String? category,
    String difficulty = 'intermediate',
    List<String>? tags,
    String currency = 'BRL',
  }) async {
    try {
      final data = <String, dynamic>{
        'template_type': templateType,
        'title': title,
        'price_cents': priceCents,
        'difficulty': difficulty,
        'currency': currency,
      };
      if (workoutId != null) data['workout_id'] = workoutId;
      if (dietPlanId != null) data['diet_plan_id'] = dietPlanId;
      if (organizationId != null) data['organization_id'] = organizationId;
      if (shortDescription != null) data['short_description'] = shortDescription;
      if (fullDescription != null) data['full_description'] = fullDescription;
      if (coverImageUrl != null) data['cover_image_url'] = coverImageUrl;
      if (previewImages != null) data['preview_images'] = previewImages;
      if (category != null) data['category'] = category;
      if (tags != null) data['tags'] = tags;

      final response = await _client.post(
        ApiEndpoints.marketplaceTemplates,
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao criar template');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao criar template', e);
    }
  }

  /// Update a template
  Future<Map<String, dynamic>> updateTemplate(
    String templateId, {
    int? priceCents,
    String? title,
    String? shortDescription,
    String? fullDescription,
    String? coverImageUrl,
    List<String>? previewImages,
    String? category,
    String? difficulty,
    List<String>? tags,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (priceCents != null) data['price_cents'] = priceCents;
      if (title != null) data['title'] = title;
      if (shortDescription != null) data['short_description'] = shortDescription;
      if (fullDescription != null) data['full_description'] = fullDescription;
      if (coverImageUrl != null) data['cover_image_url'] = coverImageUrl;
      if (previewImages != null) data['preview_images'] = previewImages;
      if (category != null) data['category'] = category;
      if (difficulty != null) data['difficulty'] = difficulty;
      if (tags != null) data['tags'] = tags;
      if (isActive != null) data['is_active'] = isActive;

      final response = await _client.put(
        ApiEndpoints.marketplaceTemplate(templateId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar template');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar template', e);
    }
  }

  /// Delete (deactivate) a template
  Future<void> deleteTemplate(String templateId) async {
    try {
      await _client.delete(ApiEndpoints.marketplaceTemplate(templateId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao remover template', e);
    }
  }

  /// Get my templates with stats
  Future<List<Map<String, dynamic>>> getMyTemplates({bool includeInactive = false}) async {
    try {
      final response = await _client.get(
        ApiEndpoints.marketplaceMyTemplates,
        queryParameters: {'include_inactive': includeInactive},
      );
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar meus templates', e);
    }
  }

  // ==================== Purchases ====================

  /// Start checkout process
  Future<Map<String, dynamic>> checkout(
    String templateId, {
    String paymentProvider = 'pix',
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.marketplaceCheckout(templateId),
        data: {'payment_provider': paymentProvider},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao iniciar compra');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao iniciar compra', e);
    }
  }

  /// Get purchase status
  Future<Map<String, dynamic>> getPurchaseStatus(String purchaseId) async {
    try {
      final response = await _client.get(ApiEndpoints.marketplacePurchaseStatus(purchaseId));
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const NotFoundException('Compra não encontrada');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao verificar compra', e);
    }
  }

  /// Get my purchases
  Future<List<Map<String, dynamic>>> getMyPurchases({String? status}) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status;

      final response = await _client.get(
        ApiEndpoints.marketplaceMyPurchases,
        queryParameters: params,
      );
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar compras', e);
    }
  }

  // ==================== Reviews ====================

  /// Create a review for a purchased template
  Future<Map<String, dynamic>> createReview(
    String purchaseId, {
    required int rating,
    String? title,
    String? comment,
  }) async {
    try {
      final data = <String, dynamic>{'rating': rating};
      if (title != null) data['title'] = title;
      if (comment != null) data['comment'] = comment;

      final response = await _client.post(
        ApiEndpoints.marketplacePurchaseReview(purchaseId),
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao enviar avaliação');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao enviar avaliação', e);
    }
  }

  /// Get template reviews
  Future<Map<String, dynamic>> getTemplateReviews(
    String templateId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.marketplaceTemplateReviews(templateId),
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return {'reviews': [], 'total_count': 0, 'rating_distribution': {}};
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar avaliações', e);
    }
  }

  // ==================== Categories ====================

  /// Get categories with template counts
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _client.get(ApiEndpoints.marketplaceCategories);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar categorias', e);
    }
  }

  // ==================== Creator Dashboard ====================

  /// Get creator dashboard stats
  Future<Map<String, dynamic>> getCreatorDashboard() async {
    try {
      final response = await _client.get(ApiEndpoints.marketplaceCreatorDashboard);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao carregar dashboard');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar dashboard', e);
    }
  }

  /// Get creator earnings details
  Future<Map<String, dynamic>> getCreatorEarnings() async {
    try {
      final response = await _client.get(ApiEndpoints.marketplaceCreatorEarnings);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return {
        'balance_cents': 0,
        'total_earned_cents': 0,
        'total_withdrawn_cents': 0,
        'history': [],
      };
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar ganhos', e);
    }
  }

  /// Get creator payouts history
  Future<List<Map<String, dynamic>>> getCreatorPayouts() async {
    try {
      final response = await _client.get(ApiEndpoints.marketplaceCreatorPayouts);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar saques', e);
    }
  }

  /// Request a payout
  Future<Map<String, dynamic>> requestPayout({
    required int amountCents,
    required String payoutMethod,
    String? pixKey,
    Map<String, dynamic>? bankAccount,
  }) async {
    try {
      final data = <String, dynamic>{
        'amount_cents': amountCents,
        'payout_method': payoutMethod,
      };
      if (pixKey != null) data['pix_key'] = pixKey;
      if (bankAccount != null) data['bank_account'] = bankAccount;

      final response = await _client.post(
        ApiEndpoints.marketplaceCreatorPayouts,
        data: data,
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao solicitar saque');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao solicitar saque', e);
    }
  }

  // ==================== Organization Templates ====================

  /// Get templates available to organization members
  Future<List<Map<String, dynamic>>> getOrganizationTemplates(String organizationId) async {
    try {
      final response = await _client.get(ApiEndpoints.organizationTemplates(organizationId));
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar templates', e);
    }
  }

  /// Grant organization template access
  Future<Map<String, dynamic>> grantOrganizationAccess(
    String organizationId, {
    required String templateId,
    bool isFreeForMembers = false,
    int memberDiscountPercent = 0,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.organizationTemplates(organizationId),
        data: {
          'marketplace_template_id': templateId,
          'is_free_for_members': isFreeForMembers,
          'member_discount_percent': memberDiscountPercent,
        },
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao conceder acesso');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao conceder acesso', e);
    }
  }
}
