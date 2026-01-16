import 'package:flutter/material.dart';

/// MyFit Design System Colors - Blue Theme (based on logo)
abstract class AppColors {
  // Brand - Blue gradient from logo
  static const primary = Color(0xFF2563EB);        // Bright blue
  static const primaryDark = Color(0xFF3B82F6);    // Lighter blue for dark mode

  // Light Theme - Clean & Professional
  static const background = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF0F172A);     // Slate 900
  static const card = Color(0xFFF8FAFC);           // Slate 50
  static const border = Color(0xFFE2E8F0);         // Slate 200
  static const muted = Color(0xFFF1F5F9);          // Slate 100
  static const mutedForeground = Color(0xFF64748B); // Slate 500

  // Dark Theme - Deep Navy (like logo background)
  static const backgroundDark = Color(0xFF0F172A);  // Slate 900
  static const foregroundDark = Color(0xFFF8FAFC);  // Slate 50
  static const cardDark = Color(0xFF334155);        // Slate 700 - Mais claro para melhor visibilidade
  static const borderDark = Color(0xFF475569);      // Slate 600 - Mais claro
  static const mutedDark = Color(0xFF334155);       // Slate 700
  static const mutedForegroundDark = Color(0xFFCBD5E1); // Slate 300 - Mais claro para melhor leitura

  // Semantic
  static const destructive = Color(0xFFDC2626);     // Red 600
  static const destructiveForeground = Color(0xFFFFFFFF);
  static const success = Color(0xFF16A34A);         // Green 600
  static const warning = Color(0xFFCA8A04);         // Yellow 600
  static const info = Color(0xFF0EA5E9);            // Sky 500

  // Secondary - Cyan accent (from logo streaks)
  static const secondary = Color(0xFF0EA5E9);       // Sky 500
  static const secondaryDark = Color(0xFF38BDF8);   // Sky 400
  static const accent = Color(0xFF06B6D4);          // Cyan 500
  static const accentDark = Color(0xFF22D3EE);      // Cyan 400

  // Legacy aliases
  static const primaryForeground = Color(0xFFFFFFFF);
  static const primaryForegroundDark = Color(0xFFFFFFFF);
  static const secondaryForeground = Color(0xFFFFFFFF);
  static const secondaryForegroundDark = Color(0xFF0F172A);
  static const accentForeground = Color(0xFFFFFFFF);
  static const accentForegroundDark = Color(0xFF0F172A);
  static const ring = primary;
  static const ringDark = primaryDark;
  static const cardForeground = foreground;
  static const cardForegroundDark = foregroundDark;
}
