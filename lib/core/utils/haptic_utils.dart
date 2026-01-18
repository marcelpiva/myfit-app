import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Web-safe haptic feedback wrapper
/// Ignores haptic calls on web platform to prevent errors
class HapticUtils {
  HapticUtils._();

  /// Light impact haptic feedback
  /// No-op on web platform
  static void lightImpact() {
    if (!kIsWeb) {
      HapticFeedback.lightImpact();
    }
  }

  /// Medium impact haptic feedback
  /// No-op on web platform
  static void mediumImpact() {
    if (!kIsWeb) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Heavy impact haptic feedback
  /// No-op on web platform
  static void heavyImpact() {
    if (!kIsWeb) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Selection click haptic feedback
  /// No-op on web platform
  static void selectionClick() {
    if (!kIsWeb) {
      HapticFeedback.selectionClick();
    }
  }

  /// Vibrate haptic feedback
  /// No-op on web platform
  static void vibrate() {
    if (!kIsWeb) {
      HapticFeedback.vibrate();
    }
  }
}
