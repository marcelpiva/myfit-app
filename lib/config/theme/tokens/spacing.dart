/// Spacing tokens based on 8px grid (matching web Tailwind)
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;    // 0.25rem
  static const double sm = 8.0;    // 0.5rem
  static const double md = 16.0;   // 1rem
  static const double lg = 24.0;   // 1.5rem
  static const double xl = 32.0;   // 2rem
  static const double xxl = 48.0;  // 3rem
  static const double xxxl = 64.0; // 4rem

  // Section padding (like py-24 in web)
  static const double sectionVertical = 96.0;
  static const double sectionHorizontal = 24.0;

  // Component specific
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 16.0;
  static const double inputPaddingHorizontal = 16.0;
  static const double inputPaddingVertical = 14.0;
  static const double cardPadding = 24.0;

  // Screen padding
  static const double screenPadding = 24.0;
}
