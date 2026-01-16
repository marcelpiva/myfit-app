import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Fonts
  static TextStyle get _sansSerif => GoogleFonts.arOneSans();
  static TextStyle get _serif => GoogleFonts.sourceSerif4();
  static TextStyle get _mono => GoogleFonts.jetBrainsMono();

  // Border radius - straight lines, no radius
  static const double _radius = 0.0;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.foreground,
        onPrimary: AppColors.background,
        secondary: AppColors.primary,
        surface: AppColors.background,
        onSurface: AppColors.foreground,
        outline: AppColors.border,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: _sansSerif.fontFamily,
      textTheme: _buildTextTheme(AppColors.foreground, AppColors.mutedForeground),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: _sansSerif.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.foreground,
          foregroundColor: AppColors.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          textStyle: _sansSerif.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          side: const BorderSide(color: AppColors.border, width: 1),
          textStyle: _sansSerif.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.foreground,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          textStyle: _sansSerif.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.foreground, width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.destructive, width: 1),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.destructive, width: 2),
        ),
        labelStyle: _sansSerif.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedForeground,
        ),
        hintStyle: _sansSerif.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedForeground,
        ),
        errorStyle: _sansSerif.copyWith(
          fontSize: 12,
          color: AppColors.destructive,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        minVerticalPadding: 0,
        dense: false,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        side: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.foreground,
        size: 22,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.foreground,
        contentTextStyle: _sansSerif.copyWith(
          color: AppColors.background,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        titleTextStyle: _sansSerif.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        indicatorShape: const RoundedRectangleBorder(), // Zero radius
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return IconThemeData(color: AppColors.foreground.withValues(alpha: 0.6), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _sansSerif.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return _sansSerif.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.foreground.withValues(alpha: 0.6),
          );
        }),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.foregroundDark,
        onPrimary: AppColors.backgroundDark,
        secondary: AppColors.primaryDark,
        surface: AppColors.backgroundDark,
        onSurface: AppColors.foregroundDark,
        outline: AppColors.borderDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: _sansSerif.fontFamily,
      textTheme: _buildTextTheme(AppColors.foregroundDark, AppColors.mutedForegroundDark),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.foregroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: _sansSerif.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.foregroundDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.foregroundDark,
          foregroundColor: AppColors.backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          textStyle: _sansSerif.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foregroundDark,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
          textStyle: _sansSerif.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.foregroundDark,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          textStyle: _sansSerif.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderDark, width: 1),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderDark, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.foregroundDark, width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.destructive, width: 1),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.destructive, width: 2),
        ),
        labelStyle: _sansSerif.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedForegroundDark,
        ),
        hintStyle: _sansSerif.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedForegroundDark,
        ),
        errorStyle: _sansSerif.copyWith(
          fontSize: 12,
          color: AppColors.destructive,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.backgroundDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        minVerticalPadding: 0,
        dense: false,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 0,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        side: const BorderSide(color: AppColors.borderDark, width: 1.5),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.foregroundDark,
        size: 22,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.foregroundDark,
        contentTextStyle: _sansSerif.copyWith(
          color: AppColors.backgroundDark,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        titleTextStyle: _sansSerif.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.foregroundDark,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryDark.withValues(alpha: 0.15),
        indicatorShape: const RoundedRectangleBorder(), // Zero radius
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryDark, size: 24);
          }
          return IconThemeData(color: AppColors.foregroundDark.withValues(alpha: 0.6), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _sansSerif.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            );
          }
          return _sansSerif.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.foregroundDark.withValues(alpha: 0.6),
          );
        }),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color foreground, Color muted) {
    return TextTheme(
      displayLarge: _sansSerif.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: foreground,
        height: 1.2,
      ),
      displayMedium: _sansSerif.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: foreground,
        height: 1.2,
      ),
      displaySmall: _sansSerif.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: foreground,
        height: 1.3,
      ),
      headlineLarge: _sansSerif.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: foreground,
        height: 1.3,
      ),
      headlineMedium: _sansSerif.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: foreground,
        height: 1.3,
      ),
      headlineSmall: _sansSerif.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: foreground,
        height: 1.4,
      ),
      titleLarge: _sansSerif.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: foreground,
        height: 1.4,
      ),
      titleMedium: _sansSerif.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: foreground,
        height: 1.4,
      ),
      titleSmall: _sansSerif.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: foreground,
        height: 1.4,
      ),
      bodyLarge: _sansSerif.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: foreground,
        height: 1.5,
      ),
      bodyMedium: _sansSerif.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: foreground,
        height: 1.5,
      ),
      bodySmall: _sansSerif.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: muted,
        height: 1.4,
      ),
      labelLarge: _sansSerif.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: foreground,
        height: 1.4,
      ),
      labelMedium: _sansSerif.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: foreground,
        height: 1.4,
      ),
      labelSmall: _sansSerif.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: muted,
        height: 1.3,
      ),
    );
  }

  // Utility getters for font families
  static String get fontFamilySans => _sansSerif.fontFamily ?? 'AR One Sans';
  static String get fontFamilySerif => _serif.fontFamily ?? 'Source Serif 4';
  static String get fontFamilyMono => _mono.fontFamily ?? 'JetBrains Mono';
}
