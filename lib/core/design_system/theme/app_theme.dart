import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_elevations.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'hair_theme.dart';

/// Builds the Material 3 ThemeData for HairPredict in light and dark variants.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final brand = HairTheme.forBrightness(brightness);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.brandAmber : AppColors.brandCopper,
      onPrimary: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      secondary: AppColors.brandClay,
      onSecondary: AppColors.textPrimaryDark,
      error: AppColors.error,
      onError: AppColors.textPrimaryDark,
      surface: brand.colors.surface,
      onSurface: brand.colors.textPrimary,
      surfaceContainerHighest: brand.colors.surfaceVariant,
      outline: brand.colors.textSecondary.withValues(alpha: 0.3),
    );

    final textTheme = AppTypography.buildTextTheme(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: brand.colors.background,
      textTheme: textTheme,
      extensions: [brand],
      appBarTheme: AppBarTheme(
        backgroundColor: brand.colors.surface,
        foregroundColor: brand.colors.textPrimary,
        elevation: AppElevations.level0,
        scrolledUnderElevation: AppElevations.level1,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: brand.colors.surface,
        elevation: AppElevations.level1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: brand.colors.surfaceVariant,
        labelStyle: textTheme.labelMedium,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: brand.colors.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.28),
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brand.colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: brand.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: brand.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: brand.colors.surfaceVariant,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
