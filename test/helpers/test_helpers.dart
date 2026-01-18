import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a ProviderContainer with optional overrides for testing
ProviderContainer createContainer({
  List<Override> overrides = const [],
  ProviderContainer? parent,
}) {
  final container = ProviderContainer(
    overrides: overrides,
    parent: parent,
  );
  addTearDown(container.dispose);
  return container;
}

/// Creates a ProviderScope widget wrapper for widget tests
Widget createTestApp({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Creates a ProviderScope with navigation support
Widget createTestAppWithNavigation({
  required Widget child,
  List<Override> overrides = const [],
  List<NavigatorObserver>? navigatorObservers,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
      navigatorObservers: navigatorObservers ?? [],
    ),
  );
}

/// Helper to pump and settle with a timeout
extension WidgetTesterExtensions on WidgetTester {
  /// Pumps the widget and settles, with an optional duration
  Future<void> pumpAndSettleWithTimeout({
    Duration duration = const Duration(seconds: 10),
  }) async {
    await pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      duration,
    );
  }

  /// Pumps frames for async operations
  Future<void> pumpFrames(int count) async {
    for (var i = 0; i < count; i++) {
      await pump(const Duration(milliseconds: 16));
    }
  }
}

/// Test date/time helpers
class TestDateTime {
  /// Returns a fixed DateTime for testing (2024-01-15 10:00:00)
  static DateTime get now => DateTime(2024, 1, 15, 10, 0, 0);

  /// Returns today's date at midnight
  static DateTime get today => DateTime(2024, 1, 15);

  /// Returns yesterday's date
  static DateTime get yesterday => DateTime(2024, 1, 14);

  /// Returns a date n days ago
  static DateTime daysAgo(int days) => today.subtract(Duration(days: days));

  /// Returns a date n days from now
  static DateTime daysFromNow(int days) => today.add(Duration(days: days));

  /// Returns a date n weeks ago
  static DateTime weeksAgo(int weeks) => daysAgo(weeks * 7);

  /// Returns a date n months ago (approximately)
  static DateTime monthsAgo(int months) => daysAgo(months * 30);
}

/// Creates mock API response data
Map<String, dynamic> createApiResponse({
  required dynamic data,
  int statusCode = 200,
  String? message,
}) {
  return {
    'status_code': statusCode,
    'data': data,
    if (message != null) 'message': message,
  };
}

/// Creates a list of mock items with IDs
List<Map<String, dynamic>> createMockList(
  int count,
  Map<String, dynamic> Function(int index) factory,
) {
  return List.generate(count, factory);
}

/// Wait helper for async operations in tests
Future<void> waitForAsync() async {
  await Future<void>.delayed(Duration.zero);
}

/// Wait for a condition to be true with timeout
Future<void> waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
  Duration pollInterval = const Duration(milliseconds: 50),
}) async {
  final endTime = DateTime.now().add(timeout);
  while (!condition() && DateTime.now().isBefore(endTime)) {
    await Future<void>.delayed(pollInterval);
  }
}

/// Wait for a provider state to satisfy a condition
Future<void> waitForProviderState<T>(
  ProviderContainer container,
  ProviderListenable<T> provider,
  bool Function(T state) condition, {
  Duration timeout = const Duration(seconds: 5),
  Duration pollInterval = const Duration(milliseconds: 50),
}) async {
  final endTime = DateTime.now().add(timeout);
  while (!condition(container.read(provider)) && DateTime.now().isBefore(endTime)) {
    await Future<void>.delayed(pollInterval);
  }
}

/// Helper to verify that a StateNotifier has a specific state
void verifyState<T>(
  StateNotifier<T> notifier,
  bool Function(T state) predicate, {
  String? reason,
}) {
  expect(predicate(notifier.state), isTrue, reason: reason);
}
