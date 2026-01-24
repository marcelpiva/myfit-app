/// Observability configuration for MyFit app.
///
/// Configures GlitchTip (open-source) error tracking and performance monitoring.
/// Uses sentry_flutter SDK which is compatible with GlitchTip.
library;

import '../config/environment.dart';

/// Configuration for observability (GlitchTip/Sentry compatible)
class ObservabilityConfig {
  ObservabilityConfig._();

  /// GlitchTip DSN (Data Source Name) per environment
  /// Format: `https://[key]@[glitchtip-domain]/[project-id]`
  ///
  /// Replace with your actual GlitchTip DSN values
  static String get dsn {
    switch (EnvironmentConfig.environment) {
      case Environment.production:
        // TODO: Replace with your production GlitchTip DSN
        return const String.fromEnvironment(
          'GLITCHTIP_DSN',
          defaultValue: 'https://key@glitchtip.yourdomain.com/1',
        );
      case Environment.staging:
        // TODO: Replace with your staging GlitchTip DSN
        return const String.fromEnvironment(
          'GLITCHTIP_DSN_STAGING',
          defaultValue: 'https://key@glitchtip.yourdomain.com/2',
        );
      case Environment.development:
        // Development uses local GlitchTip or empty DSN to disable
        return const String.fromEnvironment(
          'GLITCHTIP_DSN_DEV',
          defaultValue: '', // Empty to disable in development
        );
    }
  }

  /// Check if observability is enabled
  static bool get isEnabled => dsn.isNotEmpty;

  /// Environment name for Sentry/GlitchTip
  static String get environmentName {
    switch (EnvironmentConfig.environment) {
      case Environment.production:
        return 'production';
      case Environment.staging:
        return 'staging';
      case Environment.development:
        return 'development';
    }
  }

  /// Traces sample rate (0.0 to 1.0)
  /// Controls how many transactions are captured for performance monitoring
  static double get tracesSampleRate {
    switch (EnvironmentConfig.environment) {
      case Environment.production:
        return 0.2; // 20% of transactions in production
      case Environment.staging:
        return 0.5; // 50% in staging
      case Environment.development:
        return 1.0; // 100% in development
    }
  }

  /// Profiles sample rate (0.0 to 1.0)
  /// Controls how many transactions are profiled for performance analysis
  static double get profilesSampleRate {
    switch (EnvironmentConfig.environment) {
      case Environment.production:
        return 0.1; // 10% of profiled transactions in production
      case Environment.staging:
        return 0.3; // 30% in staging
      case Environment.development:
        return 1.0; // 100% in development
    }
  }

  /// Enable automatic session tracking
  static bool get enableAutoSessionTracking => true;

  /// Enable automatic performance tracking
  static bool get enableAutoPerformanceTracing => true;

  /// Enable user interaction tracing (button clicks, etc.)
  static bool get enableUserInteractionTracing => true;

  /// Enable automatic breadcrumb capture
  static bool get attachScreenshot {
    // Only capture screenshots in production for privacy
    return EnvironmentConfig.isProduction;
  }

  /// Enable view hierarchy capture (for debugging)
  static bool get attachViewHierarchy {
    return !EnvironmentConfig.isProduction;
  }

  /// Max breadcrumbs to keep
  static int get maxBreadcrumbs => 100;

  /// Debug mode - set to true to see Sentry logs
  static bool get debug => EnvironmentConfig.isDevelopment;

  /// Send default PII (Personally Identifiable Information)
  static bool get sendDefaultPii => false;

  /// App version for release tracking
  static String get release {
    const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
    const buildNumber = String.fromEnvironment('BUILD_NUMBER', defaultValue: '1');
    return 'myfit@$appVersion+$buildNumber';
  }

  /// Distribution for release identification
  static String get dist {
    return const String.fromEnvironment('BUILD_NUMBER', defaultValue: '1');
  }
}
