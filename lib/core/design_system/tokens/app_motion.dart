import 'package:flutter/animation.dart';

/// Motion durations + curves for HairPredict.
class AppMotion {
  AppMotion._();

  // ── Durations ────────────────────────────────────────────────────────
  /// Use for micro-interactions (hover, tap feedback, focus ring).
  static const Duration durationFast = Duration(milliseconds: 150);

  /// Default for state transitions (animated container, page swap).
  static const Duration durationNormal = Duration(milliseconds: 240);

  /// Use for hero animations (tab indicator slide, capture frame fill).
  static const Duration durationSlow = Duration(milliseconds: 400);

  // ── Curves ───────────────────────────────────────────────────────────
  /// Used when something emerges (indicator slides in, frame fills).
  static const Curve curveEmerge = Curves.easeOutCubic;

  /// Used for general state changes (loading dot pulse).
  static const Curve curveStandard = Curves.easeInOut;
}
