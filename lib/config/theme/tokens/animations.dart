import 'package:flutter/material.dart';

/// Animation tokens matching Framer Motion patterns from web
class AppAnimations {
  AppAnimations._();

  // Durations
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration entrance = Duration(milliseconds: 600);
  static const Duration pageTransition = Duration(milliseconds: 400);

  // Curves (matching web easeOut)
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve spring = Curves.elasticOut;
  static const Curve bouncy = Curves.bounceOut;

  // Scale values
  static const double tapScale = 0.95;
  static const double hoverScale = 1.05;
  static const double pressedScale = 0.98;
  static const double buttonPressedScale = 0.98;

  // Offsets for entrance animations
  static const Offset slideUpStart = Offset(0, 60);
  static const Offset slideLeftStart = Offset(-60, 0);
  static const Offset slideRightStart = Offset(60, 0);
}
