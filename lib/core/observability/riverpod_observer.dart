/// Riverpod observer for state change tracking.
///
/// Captures state changes in providers and adds them as breadcrumbs
/// for better debugging and error context.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'observability_service.dart';

/// Observer that tracks Riverpod provider state changes
class ObservabilityProviderObserver extends ProviderObserver {
  const ObservabilityProviderObserver();

  /// List of providers to track (empty = track all)
  /// Add provider names here to track only specific providers
  static const Set<String> _trackedProviders = {
    // Authentication
    'authNotifierProvider',
    'currentUserProvider',

    // Context switching
    'activeContextProvider',
    'organizationsProvider',

    // Dashboard
    'studentDashboardProvider',
    'trainerDashboardNotifierProvider',

    // Workouts
    'plansNotifierProvider',
    'activeSessionProvider',
    'workoutSessionProvider',

    // Add more providers as needed
  };

  /// Check if provider should be tracked
  bool _shouldTrack(ProviderBase<dynamic> provider) {
    if (_trackedProviders.isEmpty) return true;

    final name = provider.name ?? provider.runtimeType.toString();
    return _trackedProviders.any((p) => name.contains(p));
  }

  /// Get a safe name for the provider
  String _getProviderName(ProviderBase<dynamic> provider) {
    return provider.name ??
        provider.runtimeType.toString().replaceAll(RegExp(r'<.*>'), '');
  }

  /// Get a safe value representation (avoid logging sensitive data)
  String _getSafeValue(Object? value) {
    if (value == null) return 'null';

    // Avoid logging sensitive types
    final typeName = value.runtimeType.toString();
    if (typeName.contains('User') ||
        typeName.contains('Token') ||
        typeName.contains('Password') ||
        typeName.contains('Credential')) {
      return '[$typeName]';
    }

    // For AsyncValue, get the state
    if (value is AsyncLoading) return 'loading';
    if (value is AsyncError) return 'error: ${value.error.runtimeType}';
    if (value is AsyncData) {
      final data = value.value;
      if (data == null) return 'data: null';
      if (data is List) return 'data: List(${data.length})';
      if (data is Map) return 'data: Map(${data.length})';
      return 'data: ${data.runtimeType}';
    }

    // For other types
    if (value is List) return 'List(${value.length})';
    if (value is Map) return 'Map(${value.length})';

    return value.runtimeType.toString();
  }

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    if (!_shouldTrack(provider)) return;

    ObservabilityService.addStateBreadcrumb(
      provider: _getProviderName(provider),
      action: 'initialized',
      data: {'value': _getSafeValue(value)},
    );
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (!_shouldTrack(provider)) return;

    ObservabilityService.addStateBreadcrumb(
      provider: _getProviderName(provider),
      action: 'updated',
      data: {
        'previous': _getSafeValue(previousValue),
        'new': _getSafeValue(newValue),
      },
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    if (!_shouldTrack(provider)) return;

    ObservabilityService.addStateBreadcrumb(
      provider: _getProviderName(provider),
      action: 'disposed',
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    // Always capture provider failures
    final providerName = _getProviderName(provider);

    ObservabilityService.addStateBreadcrumb(
      provider: providerName,
      action: 'failed',
      data: {'error': error.runtimeType.toString()},
    );

    // Capture the exception with context
    ObservabilityService.captureException(
      error,
      stackTrace: stackTrace,
      message: 'Provider $providerName failed',
      extras: {'provider': providerName},
      tags: ['provider:$providerName'],
    );
  }
}
