import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';

/// Brand-specific theme extension that rides alongside Material 3.
///
/// Read via:
/// ```dart
/// final brand = Theme.of(context).extension<HairTheme>()!;
/// brand.spacing.lg
/// ```
class HairTheme extends ThemeExtension<HairTheme> {
  const HairTheme({
    required this.colors,
    required this.spacing,
    required this.radii,
    required this.motion,
  });

  final HairColors colors;
  final HairSpacing spacing;
  final HairRadii radii;
  final HairMotion motion;

  /// Default brand extension for the given brightness.
  factory HairTheme.forBrightness(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return HairTheme(
      colors: HairColors.forBrightness(brightness),
      spacing: const HairSpacing(),
      radii: const HairRadii(),
      motion: const HairMotion(),
    );
  }

  @override
  HairTheme copyWith({
    HairColors? colors,
    HairSpacing? spacing,
    HairRadii? radii,
    HairMotion? motion,
  }) {
    return HairTheme(
      colors: colors ?? this.colors,
      spacing: spacing ?? this.spacing,
      radii: radii ?? this.radii,
      motion: motion ?? this.motion,
    );
  }

  @override
  HairTheme lerp(ThemeExtension<HairTheme>? other, double t) {
    if (other is! HairTheme) return this;
    return HairTheme(
      colors: HairColors.lerp(colors, other.colors, t),
      spacing: spacing,
      radii: radii,
      motion: motion,
    );
  }
}

class HairColors {
  const HairColors({
    required this.brandAmber,
    required this.brandCopper,
    required this.brandClay,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.error,
  });

  final Color brandAmber;
  final Color brandCopper;
  final Color brandClay;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color error;

  factory HairColors.forBrightness(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return HairColors(
      brandAmber: AppColors.brandAmber,
      brandCopper: AppColors.brandCopper,
      brandClay: AppColors.brandClay,
      background: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      surfaceVariant:
          isDark ? AppColors.surfaceDarkVariant : AppColors.surfaceLightVariant,
      textPrimary:
          isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      textSecondary:
          isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      success: AppColors.success,
      warning: AppColors.warning,
      error: AppColors.error,
    );
  }

  static HairColors lerp(HairColors a, HairColors b, double t) {
    return HairColors(
      brandAmber: Color.lerp(a.brandAmber, b.brandAmber, t)!,
      brandCopper: Color.lerp(a.brandCopper, b.brandCopper, t)!,
      brandClay: Color.lerp(a.brandClay, b.brandClay, t)!,
      background: Color.lerp(a.background, b.background, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      surfaceVariant: Color.lerp(a.surfaceVariant, b.surfaceVariant, t)!,
      textPrimary: Color.lerp(a.textPrimary, b.textPrimary, t)!,
      textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
      success: Color.lerp(a.success, b.success, t)!,
      warning: Color.lerp(a.warning, b.warning, t)!,
      error: Color.lerp(a.error, b.error, t)!,
    );
  }
}

class HairSpacing {
  const HairSpacing();
  double get xxs => AppSpacing.xxs;
  double get xs => AppSpacing.xs;
  double get sm => AppSpacing.sm;
  double get md => AppSpacing.md;
  double get lg => AppSpacing.lg;
  double get xl => AppSpacing.xl;
  double get xxl => AppSpacing.xxl;
  double get xxxl => AppSpacing.xxxl;
}

class HairRadii {
  const HairRadii();
  double get sm => AppRadii.sm;
  double get md => AppRadii.md;
  double get lg => AppRadii.lg;
  double get xl => AppRadii.xl;
  double get pill => AppRadii.pill;
}

class HairMotion {
  const HairMotion();
  Duration get durationFast => AppMotion.durationFast;
  Duration get durationNormal => AppMotion.durationNormal;
  Duration get durationSlow => AppMotion.durationSlow;
  Curve get curveEmerge => AppMotion.curveEmerge;
  Curve get curveStandard => AppMotion.curveStandard;
}
