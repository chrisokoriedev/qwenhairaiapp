import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale for HairPredict.
///
/// Display + headlines use Fraunces (editorial serif with personality).
/// Body + labels use Inter (high legibility sans-serif).
class AppTypography {
  AppTypography._();

  /// Full Material 3 TextTheme with Fraunces (display/title) + Inter (rest).
  ///
  /// Use `GoogleFonts` so the fonts are loaded at runtime and cached. Falls
  /// back to platform default if Google Fonts is unreachable.
  static TextTheme buildTextTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;

    final fraunces = GoogleFonts.frauncesTextTheme(base);
    final inter = GoogleFonts.interTextTheme(fraunces);

    return inter.copyWith(
      displayLarge: fraunces.displayLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      displayMedium: fraunces.displayMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      displaySmall: fraunces.displaySmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: fraunces.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: fraunces.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: fraunces.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: fraunces.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 22,
      ),
      titleMedium: inter.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleSmall: inter.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: inter.bodyLarge,
      bodyMedium: inter.bodyMedium,
      bodySmall: inter.bodySmall,
      labelLarge: inter.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      labelMedium: inter.labelMedium,
      labelSmall: inter.labelSmall,
    );
  }
}
