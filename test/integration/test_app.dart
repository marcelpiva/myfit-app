import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/mock_services.dart';
import '../helpers/test_helpers.dart';

/// Base test app wrapper for integration tests
class TestApp extends StatelessWidget {
  final Widget child;
  final List<Override> overrides;
  final GlobalKey<NavigatorState>? navigatorKey;

  const TestApp({
    required this.child,
    this.overrides = const [],
    this.navigatorKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: child,
        theme: ThemeData.light(),
        localizationsDelegates: const [],
      ),
    );
  }
}

/// Base class for integration journey tests
abstract class JourneyTest {
  late WidgetTester tester;
  late MockTrainerService mockTrainerService;
  late MockWorkoutService mockWorkoutService;
  late MockOrganizationService mockOrganizationService;

  /// Setup mocks and register fallback values
  void setUpMocks() {
    registerFallbackValues();
    mockTrainerService = MockTrainerService();
    mockWorkoutService = MockWorkoutService();
    mockOrganizationService = MockOrganizationService();
  }

  /// Get provider overrides for the test
  List<Override> get providerOverrides;

  /// Pump the app with the given child widget
  Future<void> pumpApp(Widget child) async {
    await tester.pumpWidget(
      TestApp(
        overrides: providerOverrides,
        child: child,
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Tap a widget by key
  Future<void> tapByKey(String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  /// Tap a widget by text
  Future<void> tapByText(String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  /// Tap a widget by type
  Future<void> tapByType(Type type) async {
    await tester.tap(find.byType(type));
    await tester.pumpAndSettle();
  }

  /// Tap an icon button
  Future<void> tapIcon(IconData icon) async {
    await tester.tap(find.byIcon(icon));
    await tester.pumpAndSettle();
  }

  /// Enter text in a text field
  Future<void> enterText(String key, String text) async {
    await tester.enterText(find.byKey(Key(key)), text);
    await tester.pumpAndSettle();
  }

  /// Enter text in a text field by finder
  Future<void> enterTextByFinder(Finder finder, String text) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Scroll until a widget is visible
  Future<void> scrollUntilVisible(
    Finder finder, {
    Finder? scrollable,
    double delta = 100,
  }) async {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
  }

  /// Verify a widget exists by text
  void verifyTextExists(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verify a widget does not exist by text
  void verifyTextNotExists(String text) {
    expect(find.text(text), findsNothing);
  }

  /// Verify a widget exists by key
  void verifyKeyExists(String key) {
    expect(find.byKey(Key(key)), findsOneWidget);
  }

  /// Verify a widget exists by type
  void verifyTypeExists(Type type) {
    expect(find.byType(type), findsOneWidget);
  }

  /// Verify widget count by type
  void verifyTypeCount(Type type, int count) {
    expect(find.byType(type), findsNWidgets(count));
  }

  /// Wait for async operations
  Future<void> waitForAsync() async {
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  }

  /// Drag from one location to another
  Future<void> drag(Finder finder, Offset offset) async {
    await tester.drag(finder, offset);
    await tester.pumpAndSettle();
  }

  /// Long press a widget
  Future<void> longPress(Finder finder) async {
    await tester.longPress(finder);
    await tester.pumpAndSettle();
  }
}

/// Test utilities for common widget patterns
class TestWidgetUtils {
  /// Find a button by label
  static Finder findButton(String label) {
    return find.widgetWithText(ElevatedButton, label);
  }

  /// Find a text button by label
  static Finder findTextButton(String label) {
    return find.widgetWithText(TextButton, label);
  }

  /// Find a text field by label
  static Finder findTextField(String label) {
    return find.widgetWithText(TextField, label);
  }

  /// Find a list tile by title
  static Finder findListTile(String title) {
    return find.widgetWithText(ListTile, title);
  }

  /// Find a card containing text
  static Finder findCardWithText(String text) {
    return find.ancestor(
      of: find.text(text),
      matching: find.byType(Card),
    );
  }

  /// Find a dialog
  static Finder findDialog() {
    return find.byType(AlertDialog);
  }

  /// Find a snackbar
  static Finder findSnackBar() {
    return find.byType(SnackBar);
  }

  /// Find a bottom sheet
  static Finder findBottomSheet() {
    return find.byType(BottomSheet);
  }

  /// Find a circular progress indicator
  static Finder findLoadingIndicator() {
    return find.byType(CircularProgressIndicator);
  }
}

/// Extensions for widget testing
extension WidgetTesterJourneyExtensions on WidgetTester {
  /// Pump app with provider scope
  Future<void> pumpTestApp(
    Widget child, {
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      TestApp(
        overrides: overrides,
        child: child,
      ),
    );
    await pumpAndSettle();
  }

  /// Find and tap a button
  Future<void> tapButton(String label) async {
    await tap(TestWidgetUtils.findButton(label));
    await pumpAndSettle();
  }

  /// Find and tap a text button
  Future<void> tapTextButton(String label) async {
    await tap(TestWidgetUtils.findTextButton(label));
    await pumpAndSettle();
  }

  /// Verify dialog is shown
  void expectDialogShown() {
    expect(TestWidgetUtils.findDialog(), findsOneWidget);
  }

  /// Verify snackbar is shown
  void expectSnackBarShown() {
    expect(TestWidgetUtils.findSnackBar(), findsOneWidget);
  }

  /// Verify loading indicator
  void expectLoading() {
    expect(TestWidgetUtils.findLoadingIndicator(), findsOneWidget);
  }

  /// Verify no loading indicator
  void expectNotLoading() {
    expect(TestWidgetUtils.findLoadingIndicator(), findsNothing);
  }
}
