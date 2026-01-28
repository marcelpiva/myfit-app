import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../auth/auth_event_notifier.dart';
import '../../storage/token_storage.dart';
import '../api_endpoints.dart';

/// Auth interceptor for Dio
/// Handles:
/// - Adding Bearer token to requests
/// - Detecting 401 errors and attempting token refresh
/// - Redirecting to login if refresh fails
class AuthInterceptor extends Interceptor {
  final Dio _dio;

  // Flag to prevent multiple simultaneous refresh attempts
  bool _isRefreshing = false;

  // Queue of requests waiting for token refresh
  final List<_RequestRetry> _pendingRequests = [];

  // Endpoints that don't require authentication
  static const _publicEndpoints = [
    ApiEndpoints.authLogin,
    ApiEndpoints.authRegister,
    ApiEndpoints.authRefresh,
    ApiEndpoints.health,
    '/organizations/invite/preview/', // Public invite preview
  ];

  AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    // Get token and add to header
    final token = await TokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 errors
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Skip retry for auth endpoints (already failed authentication)
    if (_isAuthEndpoint(err.requestOptions.path)) {
      return handler.next(err);
    }

    // Try to refresh token
    final refreshed = await _tryRefreshToken(err.requestOptions);

    if (refreshed) {
      // Retry original request with new token
      try {
        final retryResponse = await _retryRequest(err.requestOptions);
        return handler.resolve(retryResponse);
      } catch (retryError) {
        if (retryError is DioException) {
          return handler.next(retryError);
        }
        return handler.next(err);
      }
    }

    // Refresh failed - trigger logout
    await _handleAuthFailure();
    return handler.next(err);
  }

  /// Check if endpoint is public (doesn't require auth)
  bool _isPublicEndpoint(String path) {
    return _publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  /// Check if endpoint is an auth endpoint that should NOT retry on 401
  /// (login, register, refresh endpoints - NOT /auth/me)
  bool _isAuthEndpoint(String path) {
    // /auth/me should still attempt token refresh on 401
    if (path.contains('/auth/me')) {
      return false;
    }
    return path.contains('/auth/');
  }

  /// Try to refresh the access token
  Future<bool> _tryRefreshToken(RequestOptions originalRequest) async {
    // If already refreshing, queue this request
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _pendingRequests.add(_RequestRetry(
        options: originalRequest,
        completer: completer,
      ));
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Call refresh endpoint
      final response = await _dio.post(
        ApiEndpoints.authRefresh,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': ''}, // No auth for refresh
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await TokenStorage.saveAccessToken(newAccessToken);
          if (newRefreshToken != null) {
            await TokenStorage.saveRefreshToken(newRefreshToken);
          }

          // Resolve pending requests
          _resolvePendingRequests(true);
          return true;
        }
      }

      _resolvePendingRequests(false);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Token refresh failed: $e');
      }
      _resolvePendingRequests(false);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Retry a request with new token
  Future<Response<dynamic>> _retryRequest(RequestOptions options) async {
    final token = await TokenStorage.getAccessToken();
    options.headers['Authorization'] = 'Bearer $token';

    return _dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: options.headers,
        contentType: options.contentType,
      ),
    );
  }

  /// Resolve all pending requests
  void _resolvePendingRequests(bool success) {
    for (final request in _pendingRequests) {
      request.completer.complete(success);
    }
    _pendingRequests.clear();
  }

  /// Handle authentication failure (clear tokens, notify listeners)
  Future<void> _handleAuthFailure() async {
    await TokenStorage.clearTokens();

    // Emit force logout event - auth provider listens and updates state
    // This triggers the router redirect to login
    AuthEventNotifier.instance.emitForceLogout(
      reason: 'Token refresh failed',
    );

    if (kDebugMode) {
      print('🔴 Auth failed - tokens cleared, force logout emitted');
    }
  }
}

/// Helper class for queuing requests during token refresh
class _RequestRetry {
  final RequestOptions options;
  final Completer<bool> completer;

  _RequestRetry({
    required this.options,
    required this.completer,
  });
}
