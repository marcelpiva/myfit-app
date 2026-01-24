/// Navigation observer for route tracking.
///
/// Captures navigation events and adds them as breadcrumbs
/// for better debugging and user journey tracking.
library;

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'observability_service.dart';

/// Observer that tracks navigation events
class ObservabilityNavigationObserver extends NavigatorObserver {
  ObservabilityNavigationObserver();

  String? _currentRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackNavigation(
      from: previousRoute?.settings.name ?? 'unknown',
      to: route.settings.name ?? 'unknown',
      action: 'push',
    );
    _currentRoute = route.settings.name;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _trackNavigation(
      from: route.settings.name ?? 'unknown',
      to: previousRoute?.settings.name ?? 'unknown',
      action: 'pop',
    );
    _currentRoute = previousRoute?.settings.name;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _trackNavigation(
      from: oldRoute?.settings.name ?? 'unknown',
      to: newRoute?.settings.name ?? 'unknown',
      action: 'replace',
    );
    _currentRoute = newRoute?.settings.name;
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _trackNavigation(
      from: route.settings.name ?? 'unknown',
      to: previousRoute?.settings.name ?? 'unknown',
      action: 'remove',
    );
    _currentRoute = previousRoute?.settings.name;
  }

  void _trackNavigation({
    required String from,
    required String to,
    required String action,
  }) {
    ObservabilityService.addNavigationBreadcrumb(
      from: from,
      to: to,
      data: {
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Also add as Sentry breadcrumb for performance monitoring
    // (only for significant navigations, not every push/pop)
    if (action == 'push' && to != 'unknown') {
      Sentry.addBreadcrumb(Breadcrumb(
        category: 'navigation',
        type: 'navigation',
        message: '$from -> $to',
        data: {'from': from, 'to': to},
      ));
    }
  }

  /// Get the current route name
  String? get currentRoute => _currentRoute;
}

/// GoRouter observer for navigation tracking
/// Use this if using go_router package
class ObservabilityGoRouterObserver extends NavigatorObserver {
  ObservabilityGoRouterObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackRoute(route, 'push');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackRoute(previousRoute, 'pop');
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _trackRoute(newRoute, 'replace');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void _trackRoute(Route<dynamic>? route, String action) {
    if (route == null) return;

    final settings = route.settings;
    final routeName = settings.name ?? route.runtimeType.toString();
    final arguments = settings.arguments;

    ObservabilityService.addBreadcrumb(
      category: 'navigation.gorouter',
      message: '$action: $routeName',
      data: {
        'route': routeName,
        'action': action,
        if (arguments != null) 'has_arguments': true,
      },
    );
  }
}
