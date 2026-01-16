import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Shadow tokens matching web design
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get none => [];

  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withAlpha(13),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withAlpha(18),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withAlpha(25),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get xl => [
    BoxShadow(
      color: Colors.black.withAlpha(30),
      blurRadius: 40,
      offset: const Offset(0, 20),
    ),
  ];

  // Colored shadows for buttons
  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: AppColors.primary.withAlpha(76),
      blurRadius: 40,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get secondaryGlow => [
    BoxShadow(
      color: AppColors.secondary.withAlpha(76),
      blurRadius: 40,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get accentGlow => [
    BoxShadow(
      color: AppColors.accent.withAlpha(76),
      blurRadius: 40,
      offset: const Offset(0, 10),
    ),
  ];
}
