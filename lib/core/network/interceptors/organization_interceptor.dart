import 'package:dio/dio.dart';

/// Organization context interceptor for Dio
/// Adds X-Organization-ID header to all requests when an organization is active
class OrganizationInterceptor extends Interceptor {
  /// Static callback to get current organization ID
  /// This is set by the app when the organization context changes
  static String? Function()? _organizationIdGetter;

  /// Set the organization ID getter callback
  static void setOrganizationIdGetter(String? Function() getter) {
    _organizationIdGetter = getter;
  }

  /// Clear the organization ID getter (on logout)
  static void clearOrganizationIdGetter() {
    _organizationIdGetter = null;
  }

  /// Get the current organization ID
  static String? get currentOrganizationId {
    return _organizationIdGetter?.call();
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add organization ID header if available
    final orgId = _organizationIdGetter?.call();
    if (orgId != null && orgId.isNotEmpty) {
      options.headers['X-Organization-ID'] = orgId;
    }

    return handler.next(options);
  }
}
