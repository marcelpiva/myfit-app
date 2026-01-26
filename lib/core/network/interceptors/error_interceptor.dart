import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../error/api_exceptions.dart';

/// Error interceptor for Dio
/// Converts DioException to typed ApiException for easier handling
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _convertToApiException(err);

    if (kDebugMode) {
      print('🔴 API Error: ${apiException.runtimeType} - ${apiException.message}');
    }

    // Create a new DioException with our typed error
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
        message: apiException.message,
      ),
    );
  }

  /// Convert DioException to typed ApiException
  ApiException _convertToApiException(DioException err) {
    // Handle connection/timeout errors first
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return NetworkException.timeout();
    }

    // Check for connection errors (works on both mobile and web)
    if (err.type == DioExceptionType.connectionError) {
      return NetworkException.noConnection();
    }

    // Handle unknown errors that are actually network errors
    if (err.type == DioExceptionType.unknown) {
      final errorString = err.error?.toString().toLowerCase() ?? '';
      final messageString = err.message?.toLowerCase() ?? '';

      // Only treat as network error if it's actually a network-related issue
      if (errorString.contains('socketexception') ||
          errorString.contains('connection refused') ||
          errorString.contains('network is unreachable') ||
          errorString.contains('no route to host') ||
          messageString.contains('xmlhttprequest') ||
          messageString.contains('cors')) {
        return NetworkException.noConnection();
      }
    }

    // Handle HTTP response errors
    final response = err.response;
    if (response == null) {
      return UnknownApiException(
        err.message ?? 'Erro de conexão desconhecido',
        err,
      );
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Parse error message from response
    String message = _extractErrorMessage(data) ??
        err.message ??
        'Ocorreu um erro inesperado';

    return switch (statusCode) {
      400 => _handleValidationError(message, data),
      401 => AuthenticationException(message),
      403 => ForbiddenException(message),
      404 => NotFoundException(message),
      409 => ConflictException(message),
      429 => RateLimitException(message),
      >= 500 => ServerException(message, statusCode),
      _ => UnknownApiException(message, err),
    };
  }

  /// Extract error message from response data
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is String) return data;

    if (data is Map) {
      // FastAPI default error format
      if (data['detail'] != null) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          // Validation error array format
          return detail.map((e) => e['msg'] ?? e.toString()).join(', ');
        }
        if (detail is Map) {
          return detail['message'] ?? detail.toString();
        }
      }

      // Alternative error formats
      if (data['message'] != null) return data['message'] as String?;
      if (data['error'] != null) return data['error'] as String?;
    }

    return null;
  }

  /// Handle 400 validation errors with field details
  ValidationException _handleValidationError(String message, dynamic data) {
    Map<String, List<String>>? fieldErrors;

    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];

      if (detail is List) {
        // FastAPI validation error array format
        fieldErrors = {};
        for (final error in detail) {
          if (error is Map) {
            final loc = error['loc'] as List?;
            final msg = error['msg'] as String?;

            if (loc != null && loc.length > 1 && msg != null) {
              final field = loc.last.toString();
              fieldErrors.putIfAbsent(field, () => []).add(msg);
            }
          }
        }
      } else if (detail is Map) {
        // Structured error with code and message
        fieldErrors = {};
        if (detail['code'] != null) {
          fieldErrors['code'] = [detail['code'].toString()];
        }
        if (detail['message'] != null) {
          fieldErrors['message'] = [detail['message'].toString()];
        }
        if (detail['membership_id'] != null) {
          fieldErrors['membership_id'] = [detail['membership_id'].toString()];
        }
        if (detail['invite_id'] != null) {
          fieldErrors['invite_id'] = [detail['invite_id'].toString()];
        }
      }
    }

    return ValidationException(message, fieldErrors: fieldErrors);
  }
}

/// Extension to easily get ApiException from DioException
extension DioExceptionApiError on DioException {
  /// Get the ApiException from this DioException
  /// Returns the error if it's already an ApiException, otherwise creates one
  ApiException get apiException {
    if (error is ApiException) {
      return error as ApiException;
    }
    return UnknownApiException(message ?? 'Erro desconhecido', this);
  }

  /// Check if this is an authentication error
  bool get isAuthError => error is AuthenticationException;

  /// Check if this is a network error
  bool get isNetworkError => error is NetworkException;

  /// Check if this error is retryable
  bool get isRetryable => error is ApiException && (error as ApiException).isRetryable;
}
