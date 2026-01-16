import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/environment.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// Singleton API client using Dio
/// Handles all HTTP requests to the MyFit backend
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  /// Private constructor
  ApiClient._() {
    _dio = Dio(_defaultOptions);
    _setupInterceptors();
  }

  /// Get singleton instance
  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  /// Get Dio instance for direct access (if needed)
  Dio get dio => _dio;

  /// Default Dio options
  BaseOptions get _defaultOptions => BaseOptions(
        baseUrl: EnvironmentConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      );

  /// Setup interceptors
  void _setupInterceptors() {
    // Auth interceptor - adds token to requests and handles refresh
    _dio.interceptors.add(AuthInterceptor(_dio));

    // Error interceptor - converts Dio errors to ApiExceptions
    _dio.interceptors.add(ErrorInterceptor());

    // Logging interceptor (only in debug mode)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint('🌐 API: $obj'),
        ),
      );
    }
  }

  /// Reset instance (useful for testing or logout)
  static void reset() {
    _instance = null;
  }

  /// Update base URL (useful for environment switching)
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  // ==================== HTTP Methods ====================

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Upload file (multipart/form-data)
  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? extraFields,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      if (extraFields != null) ...extraFields,
    });

    return _dio.post<T>(
      path,
      data: formData,
      options: options?.copyWith(
            contentType: 'multipart/form-data',
          ) ??
          Options(contentType: 'multipart/form-data'),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  /// Download file
  Future<Response> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return _dio.download(
      path,
      savePath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
