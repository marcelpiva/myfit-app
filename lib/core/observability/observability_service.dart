/// Main observability service for MyFit app.
///
/// Provides centralized error tracking, performance monitoring,
/// and user context management using GlitchTip (via Sentry SDK).
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'observability_config.dart';

/// Severity levels for custom events
enum EventSeverity {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Main service for observability (error tracking and performance monitoring)
class ObservabilityService {
  ObservabilityService._();

  static bool _initialized = false;

  /// Check if service is initialized
  static bool get isInitialized => _initialized;

  /// Initialize observability with Sentry/GlitchTip
  ///
  /// Call this in main() before runApp(), typically wrapped in SentryFlutter.init
  static Future<void> init({
    required FutureOr<void> Function() appRunner,
  }) async {
    if (!ObservabilityConfig.isEnabled) {
      debugPrint('[Observability] Disabled - no DSN configured');
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = ObservabilityConfig.dsn;
        options.environment = ObservabilityConfig.environmentName;
        options.release = ObservabilityConfig.release;
        options.dist = ObservabilityConfig.dist;

        // Performance monitoring
        options.tracesSampleRate = ObservabilityConfig.tracesSampleRate;
        options.profilesSampleRate = ObservabilityConfig.profilesSampleRate;
        options.enableAutoPerformanceTracing =
            ObservabilityConfig.enableAutoPerformanceTracing;
        options.enableUserInteractionTracing =
            ObservabilityConfig.enableUserInteractionTracing;

        // Session tracking
        options.enableAutoSessionTracking =
            ObservabilityConfig.enableAutoSessionTracking;

        // Breadcrumbs
        options.maxBreadcrumbs = ObservabilityConfig.maxBreadcrumbs;

        // Screenshots and view hierarchy
        options.attachScreenshot = ObservabilityConfig.attachScreenshot;
        options.attachViewHierarchy = ObservabilityConfig.attachViewHierarchy;

        // PII settings
        options.sendDefaultPii = ObservabilityConfig.sendDefaultPii;

        // Debug mode
        options.debug = ObservabilityConfig.debug;

        // Before send hook - can be used to filter/modify events
        options.beforeSend = _beforeSend;

        // Before breadcrumb hook
        options.beforeBreadcrumb = _beforeBreadcrumb;
      },
      appRunner: () async {
        _initialized = true;
        await appRunner();
      },
    );
  }

  /// Hook to modify/filter events before sending
  static FutureOr<SentryEvent?> _beforeSend(
    SentryEvent event,
    Hint hint,
  ) async {
    // Filter out specific errors if needed
    // Return null to drop the event

    // Example: Filter out user cancellation errors
    final exception = event.throwable;
    if (exception != null) {
      final message = exception.toString().toLowerCase();
      if (message.contains('user cancelled') ||
          message.contains('connection closed') ||
          message.contains('socketexception')) {
        return null;
      }
    }

    return event;
  }

  /// Hook to modify/filter breadcrumbs before adding
  static Breadcrumb? _beforeBreadcrumb(
    Breadcrumb? breadcrumb,
    Hint hint,
  ) {
    // Filter out sensitive data from breadcrumbs
    if (breadcrumb == null) return null;

    // Redact sensitive headers
    if (breadcrumb.category == 'http' && breadcrumb.data != null) {
      final data = Map<String, dynamic>.from(breadcrumb.data!);
      if (data.containsKey('headers')) {
        final headers = Map<String, dynamic>.from(data['headers'] as Map);
        headers.remove('Authorization');
        headers.remove('X-API-Key');
        data['headers'] = headers;
        return breadcrumb.copyWith(data: data);
      }
    }

    return breadcrumb;
  }

  // ===========================================================================
  // User Context
  // ===========================================================================

  /// Set user context for error reports
  ///
  /// Call this after successful login
  static Future<void> setUserContext({
    required String userId,
    String? email,
    String? name,
    String? role,
    String? organizationId,
    String? organizationName,
  }) async {
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: userId,
        email: email,
        name: name,
        data: {
          if (role != null) 'role': role,
          if (organizationId != null) 'organization_id': organizationId,
          if (organizationName != null) 'organization_name': organizationName,
        },
      ));
    });
  }

  /// Clear user context
  ///
  /// Call this on logout
  static Future<void> clearUserContext() async {
    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  /// Set current organization context
  static Future<void> setOrganizationContext({
    required String organizationId,
    String? organizationName,
    String? role,
  }) async {
    await Sentry.configureScope((scope) {
      scope.setContexts('organization', {
        'id': organizationId,
        if (organizationName != null) 'name': organizationName,
        if (role != null) 'role': role,
      });
    });
  }

  // ===========================================================================
  // Error Capture
  // ===========================================================================

  /// Capture an exception with optional context
  static Future<SentryId?> captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? message,
    EventSeverity severity = EventSeverity.error,
    Map<String, dynamic>? extras,
    List<String>? tags,
  }) async {
    if (!_initialized) return null;

    return await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (message != null) {
          scope.setContexts('custom', {'message': message});
        }
        if (extras != null) {
          scope.setContexts('extras', extras);
        }
        if (tags != null) {
          for (final tag in tags) {
            final parts = tag.split(':');
            if (parts.length == 2) {
              scope.setTag(parts[0], parts[1]);
            }
          }
        }
        scope.level = _mapSeverity(severity);
      },
    );
  }

  /// Capture a message (non-exception event)
  static Future<SentryId?> captureMessage(
    String message, {
    EventSeverity severity = EventSeverity.info,
    Map<String, dynamic>? extras,
  }) async {
    if (!_initialized) return null;

    return await Sentry.captureMessage(
      message,
      level: _mapSeverity(severity),
      withScope: extras != null
          ? (scope) {
              scope.setContexts('extras', extras);
            }
          : null,
    );
  }

  /// Map severity to Sentry level
  static SentryLevel _mapSeverity(EventSeverity severity) {
    switch (severity) {
      case EventSeverity.debug:
        return SentryLevel.debug;
      case EventSeverity.info:
        return SentryLevel.info;
      case EventSeverity.warning:
        return SentryLevel.warning;
      case EventSeverity.error:
        return SentryLevel.error;
      case EventSeverity.fatal:
        return SentryLevel.fatal;
    }
  }

  // ===========================================================================
  // Breadcrumbs
  // ===========================================================================

  /// Add a navigation breadcrumb
  static void addNavigationBreadcrumb({
    required String from,
    required String to,
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(Breadcrumb(
      category: 'navigation',
      message: '$from -> $to',
      data: data,
      type: 'navigation',
    ));
  }

  /// Add a user action breadcrumb
  static void addUserActionBreadcrumb({
    required String action,
    String? element,
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(Breadcrumb(
      category: 'user.action',
      message: element != null ? '$action on $element' : action,
      data: data,
      type: 'user',
    ));
  }

  /// Add an HTTP breadcrumb
  static void addHttpBreadcrumb({
    required String method,
    required String url,
    int? statusCode,
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(Breadcrumb(
      category: 'http',
      message: '$method $url',
      data: {
        'method': method,
        'url': url,
        if (statusCode != null) 'status_code': statusCode,
        ...?data,
      },
      type: 'http',
    ));
  }

  /// Add a state change breadcrumb
  static void addStateBreadcrumb({
    required String provider,
    required String action,
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(Breadcrumb(
      category: 'state.$provider',
      message: action,
      data: data,
      type: 'info',
    ));
  }

  /// Add a custom breadcrumb
  static void addBreadcrumb({
    required String category,
    required String message,
    String type = 'info',
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(Breadcrumb(
      category: category,
      message: message,
      type: type,
      data: data,
    ));
  }

  // ===========================================================================
  // Performance Monitoring
  // ===========================================================================

  /// Start a transaction for performance monitoring
  static ISentrySpan? startTransaction({
    required String name,
    required String operation,
    String? description,
  }) {
    if (!_initialized) return null;

    return Sentry.startTransaction(
      name,
      operation,
      description: description,
    );
  }

  /// Create a child span from an existing span
  static ISentrySpan? startChildSpan({
    required ISentrySpan parent,
    required String operation,
    String? description,
  }) {
    return parent.startChild(
      operation,
      description: description,
    );
  }
}

/// Extension to easily wrap async operations with performance tracking
extension ObservabilityTransaction on ISentrySpan {
  /// Execute an async operation and automatically finish the span
  Future<T> wrapAsync<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      setData('success', true);
      return result;
    } catch (e, stack) {
      setData('success', false);
      setData('error', e.toString());
      ObservabilityService.captureException(e, stackTrace: stack);
      rethrow;
    } finally {
      await finish();
    }
  }
}
