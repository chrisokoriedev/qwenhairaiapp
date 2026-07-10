import 'package:flutter/material.dart';

/// Raw brand palette + semantic mappings for HairPredict.
///
/// The raw values are the source of truth — semantic mappings should always
/// point to a raw value, never to another semantic value.
class AppColors {
  AppColors._();

  // ── Raw palette ──────────────────────────────────────────────────────
  // Brand
  static const Color brandAmber = Color(0xFFE8A24C);
  static const Color brandCopper = Color(0xFFB45F3F);
  static const Color brandClay = Color(0xFF8A4A2E);

  // Neutral (dark)
  static const Color backgroundDark = Color(0xFF0F0E17);
  static const Color surfaceDark = Color(0xFF1E1E2A);
  static const Color surfaceDarkVariant = Color(0xFF2A2A38);
  static const Color textPrimaryDark = Color(0xFFFFFFFE);
  static const Color textSecondaryDark = Color(0xFFA7A9BE);

  // Neutral (light)
  static const Color backgroundLight = Color(0xFFFAF7F2);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightVariant = Color(0xFFF1ECE3);
  static const Color textPrimaryLight = Color(0xFF1A1A1F);
  static const Color textSecondaryLight = Color(0xFF5A5A6A);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFFF5252);

  // ── Semantic mappings (always point to raw values) ──────────────────
  // Dark mode
  static const Color onDarkPrimary = brandAmber;
  static const Color onDarkOnPrimary = textPrimaryDark;
  static const Color onDarkSurface = surfaceDark;
  static const Color onDarkOnSurface = textPrimaryDark;

  // Light mode
  static const Color onLightPrimary = brandCopper;
  static const Color onLightOnPrimary = textPrimaryLight;
  static const Color onLightSurface = surfaceLight;
  static const Color onLightOnSurface = textPrimaryLight;
}
