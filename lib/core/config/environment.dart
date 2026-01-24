import 'package:flutter/foundation.dart' show kIsWeb;

/// Environment configuration for MyFit app
/// Manages different API base URLs for dev, staging, and production

enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static late Environment _environment;
  static late String _apiBaseUrl;
  static bool _initialized = false;

  /// Initialize environment configuration
  /// Call this in main() before runApp()
  static void init({
    Environment? environment,
    String? apiBaseUrl,
  }) {
    // Get environment from compile-time variables
    const envString = String.fromEnvironment('ENV', defaultValue: 'dev');
    const customApiUrl = String.fromEnvironment('API_URL', defaultValue: '');

    _environment = environment ?? _parseEnvironment(envString);
    _apiBaseUrl = apiBaseUrl ??
        (customApiUrl.isNotEmpty ? customApiUrl : _getDefaultApiUrl(_environment));
    _initialized = true;
  }

  static Environment _parseEnvironment(String env) {
    switch (env.toLowerCase()) {
      case 'prod':
      case 'production':
        return Environment.production;
      case 'staging':
      case 'stg':
        return Environment.staging;
      default:
        return Environment.development;
    }
  }

  static String _getDefaultApiUrl(Environment env) {
    switch (env) {
      case Environment.production:
        return 'https://api.myfitplatform.com/api/v1';
      case Environment.staging:
        return 'https://api.myfitplatform.com/api/v1';
      case Environment.development:
        // Use Mac IP for physical device testing
        return 'http://192.168.0.102:8000/api/v1';
    }
  }

  /// Get current environment
  static Environment get environment {
    _checkInitialized();
    return _environment;
  }

  /// Get API base URL
  static String get apiBaseUrl {
    _checkInitialized();
    return _apiBaseUrl;
  }

  /// Check if running in production
  static bool get isProduction => _environment == Environment.production;

  /// Check if running in development
  static bool get isDevelopment => _environment == Environment.development;

  /// Check if running in staging
  static bool get isStaging => _environment == Environment.staging;

  /// Check if debug mode (development or staging)
  static bool get isDebugMode => !isProduction;

  static void _checkInitialized() {
    if (!_initialized) {
      // Auto-initialize with defaults if not explicitly initialized
      init();
    }
  }

  /// Get environment name as string
  static String get environmentName {
    switch (_environment) {
      case Environment.production:
        return 'Production';
      case Environment.staging:
        return 'Staging';
      case Environment.development:
        return 'Development';
    }
  }
}
