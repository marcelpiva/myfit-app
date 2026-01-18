import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Centralized platform detection utilities for web compatibility
class PlatformUtils {
  PlatformUtils._();

  /// Returns true if running on web platform
  static bool get isWeb => kIsWeb;

  /// Returns true if running on mobile (iOS or Android)
  static bool get isMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Returns true if running on iOS (native, not web)
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Returns true if running on Android (native, not web)
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Returns true if running on desktop (macOS, Windows, Linux)
  static bool get isDesktop =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  /// Returns true if running on macOS (native)
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Returns true if running on Windows (native)
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Returns true if running on Linux (native)
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Returns true if device supports camera (not available on web currently)
  static bool get supportsCamera => isMobile;

  /// Returns true if device supports biometric authentication
  static bool get supportsBiometric => isMobile;

  /// Returns true if device supports haptic feedback
  static bool get supportsHaptics => isMobile;

  /// Returns true if device supports QR/barcode scanning
  static bool get supportsNativeScanner => isMobile;
}
