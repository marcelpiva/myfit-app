/// Visual testing helpers and utilities.
///
/// Provides wrapper functions and utilities for Alchemist golden tests.
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'device_profiles.dart';

/// Wrapper for widgets in visual tests with Riverpod support.
class VisualTestWrapper extends StatelessWidget {
  const VisualTestWrapper({
    super.key,
    required this.child,
    this.overrides = const [],
  });

  final Widget child;
  final List<Override> overrides;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        home: Material(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  static ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1), // Indigo primary
        brightness: Brightness.light,
      ),
    );
  }
}

/// Wrapper for full screen widgets (without Scaffold).
class FullScreenTestWrapper extends StatelessWidget {
  const FullScreenTestWrapper({
    super.key,
    required this.child,
    this.overrides = const [],
    this.isDark = false,
  });

  final Widget child;
  final List<Override> overrides;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(isDark),
        home: child,
      ),
    );
  }

  static ThemeData _buildTheme(bool isDark) {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }
}

/// Extension for running visual tests with common configurations.
extension VisualTestRunner on WidgetTester {
  /// Pump a widget with Riverpod support.
  Future<void> pumpVisualWidget(
    Widget widget, {
    List<Override> overrides = const [],
    Duration? duration,
  }) async {
    await pumpWidget(
      VisualTestWrapper(
        overrides: overrides,
        child: widget,
      ),
    );
    if (duration != null) {
      await pump(duration);
    }
  }

  /// Pump a full screen widget.
  Future<void> pumpFullScreen(
    Widget widget, {
    List<Override> overrides = const [],
    Duration? duration,
    bool isDark = false,
  }) async {
    await pumpWidget(
      FullScreenTestWrapper(
        overrides: overrides,
        isDark: isDark,
        child: widget,
      ),
    );
    if (duration != null) {
      await pump(duration);
    }
  }
}

/// Extension to easily setup locale for tests if needed.
extension LocaleTestWrapper on Widget {
  Widget withLocale([Locale? locale]) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      home: this,
    );
  }
}

/// Run multi-device golden test.
void multiDeviceGoldenTest(
  String description, {
  required String fileName,
  required Widget Function(DeviceConfig device) builder,
  List<DeviceConfig> devices = const [],
  bool skip = false,
}) {
  final deviceList = devices.isEmpty ? DeviceProfiles.critical : devices;

  for (final device in deviceList) {
    goldenTest(
      '$description - ${device.name}',
      fileName: '${fileName}_${device.safeFileName}',
      builder: () => builder(device),
      constraints: BoxConstraints.tight(device.size),
      skip: skip,
    );
  }
}
