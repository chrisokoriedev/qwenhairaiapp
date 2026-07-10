# HairPredict App Shell + Design System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the HairPredict app shell (5-tab navigation, light/dark theme, onboarding gate, offline-aware home) and the design system (token classes, HairTheme extension, 6 brand-critical custom widgets) so future sub-projects (Diagnostics, Coaching, Profile, Payments) can plug into a consistent, navigable foundation.

**Architecture:** Approach C from the design spec — rigorous tokens + 6 brand-critical custom widgets. Root providers (`OnboardingCubit`, `ThemeController`, `ConnectivityCubit`) lift to the `App` widget; tab branches host feature cubits. `go_router`'s `StatefulShellRoute.indexedStack` keeps per-tab scroll state. Brand lives in tokens, not widgets — Material 3 covers 80% of the surface.

**Tech Stack:** Flutter 3.x (Dart SDK ^3.11.5), `flutter_bloc ^9.1.1`, `go_router ^14.6.0`, `google_fonts ^6.2.1`, `flutter_animate ^4.5.0`, `shared_preferences ^2.3.3`, `connectivity_plus ^6.1.0`, `permission_handler ^11.3.1`, `app_settings ^5.1.1`, `logging ^1.3.0`.

**Spec reference:** `docs/superpowers/specs/2026-07-10-hairpredict-app-shell-design.md`

**Important execution note:** the Flutter SDK at `/mnt/c/flutter/bin/` has CRLF line endings on its shebang, so `flutter` shell commands cannot be invoked directly by tooling in this environment. Every "run flutter …" step in this plan is for the human user to run from their shell. The implementation steps (writing files) work normally.

---

## File Structure (created/modified by this plan)

```
lib/
├── core/
│   ├── design_system/                           # NEW
│   │   ├── design_system.dart                   # barrel export
│   │   ├── tokens/
│   │   │   ├── app_colors.dart                  # raw palette + semantic
│   │   │   ├── app_spacing.dart                 # 4/8/12/16/24/32/48/64
│   │   │   ├── app_radii.dart                   # 8/12/16/24/999
│   │   │   ├── app_typography.dart              # Fraunces + Inter scale
│   │   │   ├── app_elevations.dart              # 0..4
│   │   │   └── app_motion.dart                  # durations + curves
│   │   ├── theme/
│   │   │   ├── hair_theme.dart                  # ThemeExtension<HairTheme>
│   │   │   ├── app_theme.dart                   # buildLightTheme + buildDarkTheme
│   │   │   └── theme_controller.dart            # Cubit<ThemeMode>
│   │   ├── connectivity/
│   │   │   └── connectivity_cubit.dart          # Cubit<ConnectivityStatus>
│   │   ├── persistence/
│   │   │   └── onboarding_cubit.dart            # Cubit<OnboardingStatus>
│   │   ├── retry/
│   │   │   └── retry_queue.dart                 # offline write queue
│   │   └── components/
│   │       ├── loading_dots.dart                # animated 3-dot loader
│   │       ├── gradient_button.dart             # amber→copper primary CTA
│   │       ├── hair_brand_app_bar.dart          # editorial app bar
│   │       ├── capture_frame.dart               # 4-angle capture card
│   │       ├── empty_state.dart                 # branded empty placeholder
│   │       └── home_shell.dart                  # 5-tab shell + bottom nav
├── app/                                          # NEW
│   ├── app.dart                                  # root widget
│   ├── router.dart                               # GoRouter + StatefulShellRoute
│   ├── onboarding_gate.dart                      # redirect logic wrapper
│   └── screens/
│       ├── onboarding/
│       │   ├── onboarding_screen.dart
│       │   └── widgets/
│       │       ├── hair_type_picker.dart
│       │       └── display_name_field.dart
│       ├── home/
│       │   └── home_screen.dart                  # default landing
│       ├── profile/
│       │   └── profile_screen.dart               # minimal placeholder
│       └── shell_scaffolds/
│           ├── diagnostics_shell.dart
│           └── coaching_shell.dart
├── features/style_try_on/presentation/           # MODIFIED — themed
│   ├── camera_screen.dart                        # uses HairBrandAppBar
│   ├── hair_capture_screen.dart                  # uses CaptureFrame
│   └── render_viewer_screen.dart                 # uses HairBrandAppBar
├── injection_container.dart                      # MODIFIED — new singletons
└── main.dart                                     # MODIFIED — thin entry

test/
├── core/
│   ├── design_system/
│   │   ├── tokens/
│   │   │   ├── app_colors_test.dart
│   │   │   ├── app_spacing_test.dart
│   │   │   ├── app_radii_test.dart
│   │   │   └── app_motion_test.dart
│   │   └── theme/
│   │       ├── theme_controller_test.dart
│   │       ├── onboarding_cubit_test.dart
│   │       └── connectivity_cubit_test.dart
├── widgets/
│   ├── loading_dots_test.dart
│   ├── gradient_button_test.dart
│   ├── hair_brand_app_bar_test.dart
│   ├── capture_frame_test.dart
│   ├── empty_state_test.dart
│   └── home_shell_test.dart
├── theme/
│   ├── light_dark_parity_test.dart
│   └── goldens/
│       ├── home_screen_light.png
│       └── home_screen_dark.png
└── router/
    └── router_test.dart
```

**Rule for new files:** each new widget/cubit file is small (< 200 lines). If it grows, split by responsibility, not by technical layer.

---

## Phase 1 — Foundation

### Task 1: Add dependencies

**Files:**
- Modify: `pubspec.yaml:13-22` (dependencies block)

- [ ] **Step 1: Edit `pubspec.yaml` dependencies block**

Open `pubspec.yaml`. Replace the `dependencies:` block (lines 13–22) with:

```yaml
dependencies:
  app_settings: ^5.1.1
  camera: ^0.12.0+1
  connectivity_plus: ^6.1.0
  dio: ^5.10.0
  flutter:
    sdk: flutter
  flutter_animate: ^4.5.0
  flutter_bloc: ^9.1.1
  get_it: ^9.2.1
  go_router: ^14.6.0
  google_fonts: ^6.2.1
  image_picker: ^1.2.3
  logging: ^1.3.0
  model_viewer_plus: ^1.10.0
  path_provider: ^2.1.6
  permission_handler: ^11.3.1
  shared_preferences: ^2.3.3
```

- [ ] **Step 2: Run pub get (user)**

The user runs from their shell (WSL or Windows):

```bash
cd /mnt/c/Users/chrisokoriedev/Documents/work/qwenhairaiapp
flutter pub get
```

Expected: `Got dependencies!` (or `Resolving versions…` then success). If any version is unavailable, pin to the highest available and note it.

- [ ] **Step 3: Verify `pubspec.lock` updated**

```bash
grep -E "go_router|google_fonts|flutter_animate|shared_preferences|connectivity_plus|permission_handler|app_settings|logging" pubspec.lock | head -20
```

Expected: all 8 packages present with version lines.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore(deps): add app shell dependencies (go_router, google_fonts, etc.)"
```

---

### Task 2: Token — `AppColors`

**Files:**
- Create: `lib/core/design_system/tokens/app_colors.dart`
- Create: `test/core/design_system/tokens/app_colors_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/design_system/tokens/app_colors_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/tokens/app_colors.dart';

void main() {
  group('AppColors raw palette', () {
    test('brandAmber is a warm amber', () {
      expect(AppColors.brandAmber, const Color(0xFFE8A24C));
    });

    test('brandCopper is a warm copper', () {
      expect(AppColors.brandCopper, const Color(0xFFB45F3F));
    });

    test('backgroundDark is near-black with slight blue tint', () {
      expect(AppColors.backgroundDark, const Color(0xFF0F0E17));
    });

    test('backgroundLight is warm off-white', () {
      expect(AppColors.backgroundLight, const Color(0xFFFAF7F2));
    });
  });

  group('AppColors semantic mappings', () {
    test('onDark primary is amber', () {
      expect(AppColors.onDarkPrimary, AppColors.brandAmber);
    });

    test('onLight primary is copper', () {
      expect(AppColors.onLightPrimary, AppColors.brandCopper);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

User runs:

```bash
flutter test test/core/design_system/tokens/app_colors_test.dart
```

Expected: FAIL with `Target of URI doesn't exist: 'package:qwenhairaiapp/core/design_system/tokens/app_colors.dart'`.

- [ ] **Step 3: Implement `AppColors`**

Create `lib/core/design_system/tokens/app_colors.dart`:

```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

User runs:

```bash
flutter test test/core/design_system/tokens/app_colors_test.dart
```

Expected: 6 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/design_system/tokens/app_colors.dart test/core/design_system/tokens/app_colors_test.dart
git commit -m "feat(design-system): add AppColors token (raw + semantic)"
```

---

### Task 3: Token — `AppSpacing`

**Files:**
- Create: `lib/core/design_system/tokens/app_spacing.dart`
- Create: `test/core/design_system/tokens/app_spacing_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/design_system/tokens/app_spacing_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/tokens/app_spacing.dart';

void main() {
  group('AppSpacing scale', () {
    test('follows 4px base unit', () {
      expect(AppSpacing.xxs, 4.0);
      expect(AppSpacing.xs, 8.0);
      expect(AppSpacing.sm, 12.0);
      expect(AppSpacing.md, 16.0);
      expect(AppSpacing.lg, 24.0);
      expect(AppSpacing.xl, 32.0);
      expect(AppSpacing.xxl, 48.0);
      expect(AppSpacing.xxxl, 64.0);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/core/design_system/tokens/app_spacing_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Implement `AppSpacing`**

Create `lib/core/design_system/tokens/app_spacing.dart`:

```dart
/// Spacing scale for HairPredict, based on a 4px grid.
///
/// Use these instead of magic numbers everywhere. For ad-hoc gaps not covered
/// by the scale, multiply or add scale values (e.g. `AppSpacing.md * 1.5`).
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/core/design_system/tokens/app_spacing_test.dart
```

Expected: 1 test passes.

- [ ] **Step 5: Commit**

```bash
git add lib/core/design_system/tokens/app_spacing.dart test/core/design_system/tokens/app_spacing_test.dart
git commit -m "feat(design-system): add AppSpacing token"
```

---

### Task 4: Token — `AppRadii`

**Files:**
- Create: `lib/core/design_system/tokens/app_radii.dart`
- Create: `test/core/design_system/tokens/app_radii_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/design_system/tokens/app_radii_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/tokens/app_radii.dart';

void main() {
  group('AppRadii scale', () {
    test('values match design spec', () {
      expect(AppRadii.sm, 8.0);
      expect(AppRadii.md, 12.0);
      expect(AppRadii.lg, 16.0);
      expect(AppRadii.xl, 24.0);
      expect(AppRadii.pill, 999.0);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/core/design_system/tokens/app_radii_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Implement `AppRadii`**

Create `lib/core/design_system/tokens/app_radii.dart`:

```dart
/// Corner radius scale for HairPredict.
class AppRadii {
  AppRadii._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;

  /// Pill-shaped (effectively full rounding for any reasonable height).
  static const double pill = 999.0;
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/core/design_system/tokens/app_radii_test.dart
```

Expected: 1 test passes.

- [ ] **Step 5: Commit**

```bash
git add lib/core/design_system/tokens/app_radii.dart test/core/design_system/tokens/app_radii_test.dart
git commit -m "feat(design-system): add AppRadii token"
```

---

### Task 5: Token — `AppMotion`

**Files:**
- Create: `lib/core/design_system/tokens/app_motion.dart`
- Create: `test/core/design_system/tokens/app_motion_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/design_system/tokens/app_motion_test.dart`:

```dart
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/tokens/app_motion.dart';

void main() {
  group('AppMotion durations', () {
    test('fast is 150ms', () {
      expect(AppMotion.durationFast, const Duration(milliseconds: 150));
    });

    test('normal is 240ms', () {
      expect(AppMotion.durationNormal, const Duration(milliseconds: 240));
    });

    test('slow is 400ms', () {
      expect(AppMotion.durationSlow, const Duration(milliseconds: 400));
    });
  });

  group('AppMotion curves', () {
    test('curveEmerge is easeOutCubic', () {
      expect(AppMotion.curveEmerge, Curves.easeOutCubic);
    });

    test('curveStandard is easeInOut', () {
      expect(AppMotion.curveStandard, Curves.easeInOut);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/core/design_system/tokens/app_motion_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Implement `AppMotion`**

Create `lib/core/design_system/tokens/app_motion.dart`:

```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/core/design_system/tokens/app_motion_test.dart
```

Expected: 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/design_system/tokens/app_motion.dart test/core/design_system/tokens/app_motion_test.dart
git commit -m "feat(design-system): add AppMotion token"
```

---

### Task 6: Token — `AppTypography`

**Files:**
- Create: `lib/core/design_system/tokens/app_typography.dart`

(No test — typography is composed in the theme builder and tested there.)

- [ ] **Step 1: Implement `AppTypography`**

Create `lib/core/design_system/tokens/app_typography.dart`:

```dart
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/design_system/tokens/app_typography.dart
git commit -m "feat(design-system): add AppTypography (Fraunces + Inter via google_fonts)"
```

---

### Task 7: Token — `AppElevations`

**Files:**
- Create: `lib/core/design_system/tokens/app_elevations.dart`

(No test — values consumed by theme builder; covered by theme tests.)

- [ ] **Step 1: Implement `AppElevations`**

Create `lib/core/design_system/tokens/app_elevations.dart`:

```dart
/// Elevation levels for HairPredict.
///
/// We use Material 3 surface tint (no harsh shadows). These map directly
/// into `ThemeData.cardTheme.elevation` etc.
class AppElevations {
  AppElevations._();

  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 3.0;
  static const double level3 = 6.0;
  static const double level4 = 12.0;
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/design_system/tokens/app_elevations.dart
git commit -m "feat(design-system): add AppElevations token"
```

---

## Phase 2 — Theme system

### Task 8: `HairTheme` ThemeExtension

**Files:**
- Create: `lib/core/design_system/theme/hair_theme.dart`

- [ ] **Step 1: Implement `HairTheme`**

Create `lib/core/design_system/theme/hair_theme.dart`:

```dart
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
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/design_system/theme/hair_theme.dart
git commit -m "feat(design-system): add HairTheme ThemeExtension"
```

---

### Task 9: `AppTheme` builder (light + dark)

**Files:**
- Create: `lib/core/design_system/theme/app_theme.dart`

- [ ] **Step 1: Implement `AppTheme`**

Create `lib/core/design_system/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_elevations.dart';
import '../tokens/app_motion.dart';
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
```

- [ ] **Step 2: Smoke-check by writing a temporary widget**

The user runs (file deleted at end of task):

```bash
cat > /tmp/smoke_theme.dart <<'EOF'
import 'package:flutter/material.dart';
import 'package:qwenhairaiapp/core/design_system/theme/app_theme.dart';

void main() {
  runApp(MaterialApp(theme: AppTheme.light(), darkTheme: AppTheme.dark(), home: const SizedBox()));
}
EOF
cp /tmp/smoke_theme.dart lib/_smoke_theme.dart
flutter analyze lib/_smoke_theme.dart
rm lib/_smoke_theme.dart /tmp/smoke_theme.dart
```

Expected: `flutter analyze` reports 0 errors.

- [ ] **Step 3: Commit**

```bash
git add lib/core/design_system/theme/app_theme.dart
git commit -m "feat(design-system): add AppTheme builder (light + dark from tokens)"
```

---

### Task 10: Barrel export

**Files:**
- Create: `lib/core/design_system/design_system.dart`

- [ ] **Step 1: Implement barrel**

Create `lib/core/design_system/design_system.dart`:

```dart
/// Public surface of the HairPredict design system.
///
/// Import this single file to access tokens, theme, cubits, and components:
///
/// ```dart
/// import 'package:qwenhairaiapp/core/design_system/design_system.dart';
/// ```
library;

export 'components/capture_frame.dart';
export 'components/empty_state.dart';
export 'components/gradient_button.dart';
export 'components/hair_brand_app_bar.dart';
export 'components/home_shell.dart';
export 'components/loading_dots.dart';
export 'connectivity/connectivity_cubit.dart';
export 'persistence/onboarding_cubit.dart';
export 'retry/retry_queue.dart';
export 'theme/app_theme.dart';
export 'theme/hair_theme.dart';
export 'theme/theme_controller.dart';
export 'tokens/app_colors.dart';
export 'tokens/app_elevations.dart';
export 'tokens/app_motion.dart';
export 'tokens/app_radii.dart';
export 'tokens/app_spacing.dart';
export 'tokens/app_typography.dart';
```

(Components/cubits referenced here don't exist yet — the analyzer will complain until the dependent tasks land. To avoid blocking, the barrel is added LAST, after all dependencies exist.)

- [ ] **Step 2: Defer commit until Task 25** (after all barrel dependencies exist).

---

## Phase 3 — Root cubits

### Task 11: `ThemeController`

**Files:**
- Create: `lib/core/design_system/theme/theme_controller.dart`
- Create: `test/core/design_system/theme/theme_controller_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/design_system/theme/theme_controller_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeController', () {
    test('starts in system mode when no preference saved', () async {
      final prefs = await SharedPreferences.getInstance();
      final controller = ThemeController(prefs);
      expect(controller.state, ThemeMode.system);
    });

    test('setMode persists the choice', () async {
      final prefs = await SharedPreferences.getInstance();
      final controller = ThemeController(prefs);
      await controller.setMode(ThemeMode.dark);
      expect(controller.state, ThemeMode.dark);
      expect(prefs.getString('hairpredict.theme.v1'), 'dark');
    });

    test('hydrates from saved preference', () async {
      SharedPreferences.setMockInitialValues({
        'hairpredict.theme.v1': 'light',
      });
      final prefs = await SharedPreferences.getInstance();
      final controller = ThemeController(prefs);
      expect(controller.state, ThemeMode.light);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/core/design_system/theme/theme_controller_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Implement `ThemeController`**

Create `lib/core/design_system/theme/theme_controller.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's theme choice (system / light / dark).
class ThemeController extends Cubit<ThemeMode> {
  ThemeController(this._prefs) : super(_load(_prefs));

  static const _key = 'hairpredict.theme.v1';
  final SharedPreferences _prefs;

  static ThemeMode _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    await _prefs.setString(_key, _encode(mode));
    emit(mode);
  }

  String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/core/design_system/theme/theme_controller_test.dart
```

Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/design_system/theme/theme_controller.dart test/core/design_system/theme/theme_controller_test.dart
git commit -m "feat(design-system): add ThemeController cubit (persists via SharedPreferences)"
```

---

### Task 12: `OnboardingCubit`

**Files:**
- Create: `lib/core/design_system/persistence/onboarding_cubit.dart`
- Create: `test/core/design_system/theme/onboarding_cubit_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/design_system/theme/onboarding_cubit_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/persistence/onboarding_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OnboardingCubit', () {
    test('starts incomplete when no preference saved', () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = OnboardingCubit(prefs);
      await cubit.load();
      expect(cubit.state, OnboardingStatus.incomplete);
    });

    test('starts complete when preference saved', () async {
      SharedPreferences.setMockInitialValues({
        'hairpredict.onboarding.v1': 'complete',
      });
      final prefs = await SharedPreferences.getInstance();
      final cubit = OnboardingCubit(prefs);
      await cubit.load();
      expect(cubit.state, OnboardingStatus.complete);
    });

    test('complete() persists and emits', () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = OnboardingCubit(prefs);
      await cubit.load();
      await cubit.complete();
      expect(cubit.state, OnboardingStatus.complete);
      expect(prefs.getString('hairpredict.onboarding.v1'), 'complete');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/core/design_system/theme/onboarding_cubit_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Implement `OnboardingCubit`**

Create `lib/core/design_system/persistence/onboarding_cubit.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OnboardingStatus { incomplete, complete }

/// Tracks whether the user has completed onboarding.
class OnboardingCubit extends Cubit<OnboardingStatus> {
  OnboardingCubit(this._prefs) : super(OnboardingStatus.incomplete);

  static const _key = 'hairpredict.onboarding.v1';
  final SharedPreferences _prefs;

  Future<void> load() async {
    final saved = _prefs.getString(_key);
    if (saved == 'complete') {
      emit(OnboardingStatus.complete);
    }
  }

  Future<void> complete() async {
    await _prefs.setString(_key, 'complete');
    emit(OnboardingStatus.complete);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/core/design_system/theme/onboarding_cubit_test.dart
```

Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/design_system/persistence/onboarding_cubit.dart test/core/design_system/theme/onboarding_cubit_test.dart
git commit -m "feat(design-system): add OnboardingCubit (persists via SharedPreferences)"
```

---

### Task 13: `ConnectivityCubit`

**Files:**
- Create: `lib/core/design_system/connectivity/connectivity_cubit.dart`
- Create: `test/core/design_system/theme/connectivity_cubit_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/design_system/theme/connectivity_cubit_test.dart`:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/connectivity/connectivity_cubit.dart';

void main() {
  test('initial state defaults to online', () {
    final cubit = ConnectivityCubit(Connectivity());
    expect(cubit.state, ConnectivityStatus.online);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/core/design_system/theme/connectivity_cubit_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Implement `ConnectivityCubit`**

Create `lib/core/design_system/connectivity/connectivity_cubit.dart`:

```dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ConnectivityStatus { online, offline }

/// Streams online/offline status derived from connectivity_plus.
class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  ConnectivityCubit(this._connectivity) : super(ConnectivityStatus.online);

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void start() {
    _subscription = _connectivity.onConnectivityChanged.listen(_emit);
    // Seed with current state.
    _connectivity.checkConnectivity().then(_emit);
  }

  void _emit(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    emit(online ? ConnectivityStatus.online : ConnectivityStatus.offline);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/core/design_system/theme/connectivity_cubit_test.dart
```

Expected: 1 test passes.

- [ ] **Step 5: Commit**

```bash
git add lib/core/design_system/connectivity/connectivity_cubit.dart test/core/design_system/theme/connectivity_cubit_test.dart
git commit -m "feat(design-system): add ConnectivityCubit (streams online/offline)"
```

---

### Task 14: `RetryQueue` service

**Files:**
- Create: `lib/core/design_system/retry/retry_queue.dart`

(No test — interface-only placeholder; behavior covered when first consumer lands.)

- [ ] **Step 1: Implement `RetryQueue`**

Create `lib/core/design_system/retry/retry_queue.dart`:

```dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Queues failed write operations and retries them when connectivity returns.
///
/// Interface only — concrete queue implementation lands when the first
/// write-path consumer (3D reconstruction, diagnostic submission) needs it.
abstract class RetryQueue {
  Future<void> enqueue(Future<void> Function() op);
  Future<void> retryAll();
}

class NoopRetryQueue implements RetryQueue {
  @override
  Future<void> enqueue(Future<void> Function() op) async {}

  @override
  Future<void> retryAll() async {}
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/design_system/retry/retry_queue.dart
git commit -m "feat(design-system): add RetryQueue interface (Noop default)"
```

---

## Phase 4 — Custom widgets

### Task 15: `LoadingDots`

**Files:**
- Create: `lib/core/design_system/components/loading_dots.dart`
- Create: `test/widgets/loading_dots_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/loading_dots_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/components/loading_dots.dart';

void main() {
  testWidgets('pumps through animation cycle without exceptions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Center(child: LoadingDots()))),
    );
    // Pump through the full 600ms animation cycle.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sm size renders smaller dots than lg', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              LoadingDots(size: LoadingDotsSize.sm),
              SizedBox(width: 16),
              LoadingDots(size: LoadingDotsSize.lg),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(LoadingDots), findsNWidgets(2));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/widgets/loading_dots_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Implement `LoadingDots`**

Create `lib/core/design_system/components/loading_dots.dart`:

```dart
import 'package:flutter/material.dart';

import '../tokens/app_motion.dart';

enum LoadingDotsSize { sm, md, lg }

/// Three dots that pulse in sequence — replaces CircularProgressIndicator
/// for "agent thinking" feel.
class LoadingDots extends StatefulWidget {
  const LoadingDots({
    super.key,
    this.size = LoadingDotsSize.md,
    this.color,
  });

  final LoadingDotsSize size;
  final Color? color;

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _diameter {
    switch (widget.size) {
      case LoadingDotsSize.sm:
        return 6;
      case LoadingDotsSize.md:
        return 10;
      case LoadingDotsSize.lg:
        return 14;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Stagger: dot i is offset by i * 200ms in a 600ms cycle.
            final phase = (_controller.value - i * 0.33).clamp(0.0, 1.0);
            final scale = 1.0 + (0.3 * (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0));
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: _diameter * 0.4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: _diameter,
                  height: _diameter,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/widgets/loading_dots_test.dart
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/design_system/components/loading_dots.dart test/widgets/loading_dots_test.dart
git commit -m "feat(design-system): add LoadingDots component"
```

---

### Task 16: `GradientButton`

**Files:**
- Create: `lib/core/design_system/components/gradient_button.dart`
- Create: `test/widgets/gradient_button_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/gradient_button_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/components/gradient_button.dart';

void main() {
  testWidgets('renders label and responds to tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GradientButton(
            label: 'Continue',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );
    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.byType(GradientButton));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('isLoading swaps label for LoadingDots', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GradientButton(label: 'Continue', isLoading: true)),
      ),
    );
    expect(find.text('Continue'), findsNothing);
    // LoadingDots renders 3 animated containers.
    expect(find.byType(LoadingDots), findsOneWidget);
  });

  testWidgets('null onPressed disables button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GradientButton(label: 'Continue', onPressed: null)),
      ),
    );
    final button = tester.widget<GradientButton>(find.byType(GradientButton));
    expect(button.onPressed, isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/widgets/gradient_button_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Implement `GradientButton`**

Create `lib/core/design_system/components/gradient_button.dart`:

```dart
import 'package:flutter/material.dart';

import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';
import 'loading_dots.dart';

enum GradientButtonVariant { primary, secondary, tertiary }

/// Primary CTA — amber→copper gradient. Secondary = ghost outline.
/// Tertiary = text-only.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = GradientButtonVariant.primary,
    this.isLoading = false,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GradientButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<HairTheme>()!;
    final child = isLoading
        ? LoadingDots(
            size: LoadingDotsSize.sm,
            color: _foregroundColor(context),
          )
        : Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: _foregroundColor(context), size: 20),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: TextStyle(
                  color: _foregroundColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    return Opacity(
      opacity: _isEnabled ? 1.0 : 0.38,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: _isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(brand.radii.md),
          child: Container(
            height: 52,
            constraints: isExpanded
                ? const BoxConstraints.expand()
                : const BoxConstraints(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: variant == GradientButtonVariant.primary
                  ? LinearGradient(
                      colors: [brand.colors.brandAmber, brand.colors.brandCopper],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: variant == GradientButtonVariant.secondary
                  ? Colors.transparent
                  : null,
              borderRadius: BorderRadius.circular(brand.radii.md),
              border: variant == GradientButtonVariant.secondary
                  ? Border.all(color: brand.colors.brandAmber, width: 1.5)
                  : null,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Color _foregroundColor(BuildContext context) {
    final brand = Theme.of(context).extension<HairTheme>()!;
    switch (variant) {
      case GradientButtonVariant.primary:
        return brand.colors.textPrimary;
      case GradientButtonVariant.secondary:
      case GradientButtonVariant.tertiary:
        return brand.colors.brandAmber;
    }
  }
}

// HairTheme is referenced but defined in theme/hair_theme.dart.
// Import here so this file is self-contained for users.
class HairTheme extends ThemeExtension<HairTheme> {
  // Stub — actual definition is imported transitively via design_system.dart.
  @override
  HairTheme copyWith() => this;
  @override
  HairTheme lerp(ThemeExtension<HairTheme>? other, double t) => this;
}
```

Wait — that stub at the bottom is wrong. The real `HairTheme` lives in `theme/hair_theme.dart`. This widget must import it. Fix the file by replacing the import block with:

```dart
import 'package:flutter/material.dart';

import '../theme/hair_theme.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';
import 'loading_dots.dart';
```

…and **delete** the stub `class HairTheme` block at the bottom. The widget file should NOT redefine `HairTheme`.

- [ ] **Step 4: Fix imports (if Step 3 used the stub)**

If you wrote the file with the stub, open it and replace the file content with the version above that imports `../theme/hair_theme.dart` and has no stub class.

- [ ] **Step 5: Run test to verify it passes**

```bash
flutter test test/widgets/gradient_button_test.dart
```

Expected: 3 tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/core/design_system/components/gradient_button.dart test/widgets/gradient_button_test.dart
git commit -m "feat(design-system): add GradientButton (primary/secondary/tertiary)"
```

---

### Task 17: `HairBrandAppBar`

**Files:**
- Create: `lib/core/design_system/components/hair_brand_app_bar.dart`
- Create: `test/widgets/hair_brand_app_bar_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/hair_brand_app_bar_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/components/hair_brand_app_bar.dart';

void main() {
  testWidgets('renders title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          appBar: HairBrandAppBar(title: 'Welcome'),
        ),
      ),
    );
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('taller than default AppBar (kToolbarHeight + 16)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          appBar: HairBrandAppBar(title: 'Welcome'),
        ),
      ),
    );
    final bar = tester.widget<HairBrandAppBar>(find.byType(HairBrandAppBar));
    expect(bar.preferredSize.height, kToolbarHeight + 16);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/widgets/hair_brand_app_bar_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Implement `HairBrandAppBar`**

Create `lib/core/design_system/components/hair_brand_app_bar.dart`:

```dart
import 'package:flutter/material.dart';

/// Editorial app bar — taller than Material default, Fraunces title,
/// optional brand-mark slot on the left.
class HairBrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HairBrandAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBrandMark = true,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBrandMark;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);

  @override
  Widget build(BuildContext context) {
    final effectiveLeading = leading ??
        (showBrandMark
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.face_retouching_natural,
                      size: 18, color: Colors.white),
                ),
              )
            : null);

    return AppBar(
      title: Text(title),
      leading: effectiveLeading,
      actions: actions,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/widgets/hair_brand_app_bar_test.dart
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/design_system/components/hair_brand_app_bar.dart test/widgets/hair_brand_app_bar_test.dart
git commit -m "feat(design-system): add HairBrandAppBar (editorial height + brand-mark slot)"
```

---

### Task 18: `CaptureFrame`

**Files:**
- Create: `lib/core/design_system/components/capture_frame.dart`
- Create: `test/widgets/capture_frame_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/capture_frame_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/components/capture_frame.dart';

void main() {
  testWidgets('empty state shows angle label + tap hint', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CaptureFrame(
                angleLabel: 'Front',
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Front'), findsOneWidget);
    expect(find.text('Tap to capture'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
  });

  testWidgets('onTap fires when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CaptureFrame(
                angleLabel: 'Front',
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(CaptureFrame));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/widgets/capture_frame_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Implement `CaptureFrame`**

Create `lib/core/design_system/components/capture_frame.dart`:

```dart
import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/hair_theme.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radii.dart';

/// Reusable capture card for the 4-angle hair scan flow.
/// Renders 4 corner brackets + camera icon when empty; image + check mark when filled.
class CaptureFrame extends StatelessWidget {
  const CaptureFrame({
    super.key,
    required this.angleLabel,
    required this.onTap,
    this.imagePath,
  });

  final String angleLabel;
  final String? imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<HairTheme>()!;
    final filled = imagePath != null;
    final bracketColor = filled
        ? Theme.of(context).colorScheme.primary
        : brand.colors.brandAmber;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.durationNormal,
        curve: AppMotion.curveEmerge,
        decoration: BoxDecoration(
          color: brand.colors.surface,
          borderRadius: BorderRadius.circular(brand.radii.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: filled
                  ? Image.file(File(imagePath!), fit: BoxFit.cover)
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: brand.colors.textSecondary.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            angleLabel,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to capture',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: brand.colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
            ),
            if (filled)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
              ),
            // Corner brackets
            ..._buildCorners(bracketColor),
            if (filled)
              Positioned(
                bottom: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: bracketColor,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCorners(Color color) {
    const armLength = 16.0;
    const strokeWidth = 2.0;
    Widget corner(Alignment align) {
      return Align(
        alignment: align,
        child: SizedBox(
          width: armLength,
          height: armLength,
          child: CustomPaint(
            painter: _CornerPainter(color, strokeWidth, align),
          ),
        ),
      );
    }

    return [
      corner(Alignment.topLeft),
      corner(Alignment.topRight),
      corner(Alignment.bottomLeft),
      corner(Alignment.bottomRight),
    ];
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter(this.color, this.strokeWidth, this.alignment);

  final Color color;
  final double strokeWidth;
  final Alignment alignment;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final path = Path();
    final isLeft = alignment == Alignment.topLeft ||
        alignment == Alignment.bottomLeft;
    final isTop = alignment == Alignment.topLeft ||
        alignment == Alignment.topRight;
    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;

    if (isLeft) {
      path.moveTo(x, y + size.height);
      path.lineTo(x, y);
    } else {
      path.moveTo(x, y + size.height);
      path.lineTo(x, y);
    }
    if (isTop) {
      path.moveTo(0, y);
      path.lineTo(size.width, y);
    } else {
      path.moveTo(0, y);
      path.lineTo(size.width, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/widgets/capture_frame_test.dart
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/design_system/components/capture_frame.dart test/widgets/capture_frame_test.dart
git commit -m "feat(design-system): add CaptureFrame component (4-angle capture card)"
```

---

### Task 19: `EmptyState`

**Files:**
- Create: `lib/core/design_system/components/empty_state.dart`
- Create: `test/widgets/empty_state_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/empty_state_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/components/empty_state.dart';

void main() {
  testWidgets('renders title, description, illustration', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            illustration: Icon(Icons.image, size: 80),
            title: 'No scans yet',
            description: 'Start your first scan to see it here.',
          ),
        ),
      ),
    );
    expect(find.text('No scans yet'), findsOneWidget);
    expect(find.text('Start your first scan to see it here.'), findsOneWidget);
    expect(find.byIcon(Icons.image), findsOneWidget);
  });

  testWidgets('action button renders when provided', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            illustration: const Icon(Icons.image, size: 80),
            title: 'No scans',
            description: 'Start one.',
            action: ('Start scan', () => tapped = true),
          ),
        ),
      ),
    );
    expect(find.text('Start scan'), findsOneWidget);
    await tester.tap(find.text('Start scan'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/widgets/empty_state_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Implement `EmptyState`**

Create `lib/core/design_system/components/empty_state.dart`:

```dart
import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';
import 'gradient_button.dart';

/// Branded empty placeholder. Illustration slot + headline + body + optional CTA.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.illustration,
    required this.title,
    required this.description,
    this.action,
  });

  final Widget illustration;
  final String title;
  final String description;
  final ({String label, VoidCallback onPressed})? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            illustration,
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              GradientButton(
                label: action!.label,
                onPressed: action!.onPressed,
                variant: GradientButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/widgets/empty_state_test.dart
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/design_system/components/empty_state.dart test/widgets/empty_state_test.dart
git commit -m "feat(design-system): add EmptyState component"
```

---

### Task 20: `HomeShell`

**Files:**
- Create: `lib/core/design_system/components/home_shell.dart`
- Create: `test/widgets/home_shell_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/home_shell_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qwenhairaiapp/core/design_system/components/home_shell.dart';
import 'package:qwenhairaiapp/core/design_system/connectivity/connectivity_cubit.dart';

void main() {
  testWidgets('renders 5 navigation destinations', (tester) async {
    final shell = _FakeNavigationShell(currentIndex: 0);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ConnectivityCubit>(
          create: (_) => ConnectivityCubit(_FakeConnectivity()),
          child: HomeShell(navigationShell: shell),
        ),
      ),
    );
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Try-On'), findsOneWidget);
    expect(find.text('Diagnostics'), findsOneWidget);
    expect(find.text('Coaching'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('tapping a destination calls goBranch', (tester) async {
    final shell = _FakeNavigationShell(currentIndex: 0);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ConnectivityCubit>(
          create: (_) => ConnectivityCubit(_FakeConnectivity()),
          child: HomeShell(navigationShell: shell),
        ),
      ),
    );
    await tester.tap(find.text('Coaching'));
    await tester.pumpAndSettle();
    expect(shell.goBranchCalls, contains(3));
  });
}

// ── Fakes ─────────────────────────────────────────────────────────────

class _FakeNavigationShell implements StatefulNavigationShell {
  _FakeNavigationShell({required this.currentIndex});

  @override
  final int currentIndex;
  final List<int> goBranchCalls = [];

  @override
  void goBranch(int index, {bool initialLocation = false}) {
    goBranchCalls.add(index);
  }

  @override
  Widget build(BuildContext context, Widget Function(int) navigatorBuilder) {
    return const SizedBox();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConnectivity implements Connectivity {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Connectivity type from connectivity_plus; we import it for typing.
// Use `package:connectivity_plus/connectivity_plus.dart` in the file.
```

Wait — `Connectivity` is a concrete class from `connectivity_plus`, not an interface. Rewrite the fake: import `Connectivity` and override `onConnectivityChanged` + `checkConnectivity` directly. Since the cubit only uses those two methods on startup, stub them to no-op streams/futures:

```dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
// ...
class _FakeConnectivity extends Connectivity {
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.wifi];
}
```

Replace the `_FakeConnectivity` in the test file with the corrected version above.

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/widgets/home_shell_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Implement `HomeShell`**

Create `lib/core/design_system/components/home_shell.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../connectivity/connectivity_cubit.dart';
import '../theme/hair_theme.dart';

/// 5-tab shell + animated bottom navigation indicator.
/// Wraps the body of `StatefulShellRoute.indexedStack`.
class HomeShell extends StatelessWidget {
  const HomeShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const _destinations = <_NavDestination>[
    _NavDestination(
      label: 'Home',
      outlined: Icons.home_outlined,
      filled: Icons.home_rounded,
    ),
    _NavDestination(
      label: 'Try-On',
      outlined: Icons.face_retouching_natural_outlined,
      filled: Icons.face_retouching_natural,
    ),
    _NavDestination(
      label: 'Diagnostics',
      outlined: Icons.health_and_safety_outlined,
      filled: Icons.health_and_safety,
    ),
    _NavDestination(
      label: 'Coaching',
      outlined: Icons.chat_bubble_outline,
      filled: Icons.chat_bubble,
    ),
    _NavDestination(
      label: 'Profile',
      outlined: Icons.person_outline,
      filled: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
            builder: (context, status) {
              if (status == ConnectivityStatus.offline) {
                return const _OfflineBanner();
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        destinations: [
          for (var i = 0; i < _destinations.length; i++)
            NavigationDestination(
              icon: Icon(_destinations[i].outlined),
              selectedIcon: Icon(_destinations[i].filled),
              label: _destinations[i].label,
            ),
        ],
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.outlined,
    required this.filled,
  });
  final String label;
  final IconData outlined;
  final IconData filled;
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<HairTheme>()!;
    return Container(
      width: double.infinity,
      color: brand.colors.warning.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        "You're offline — recent scans available, new analyses will resume when you reconnect.",
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: brand.colors.textPrimary),
        textAlign: TextAlign.center,
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/widgets/home_shell_test.dart
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/design_system/components/home_shell.dart test/widgets/home_shell_test.dart
git commit -m "feat(design-system): add HomeShell (5-tab nav + offline banner)"
```

---

## Phase 5 — Router + screens

### Task 21: Onboarding sub-widgets — `HairTypePicker` + `DisplayNameField`

**Files:**
- Create: `lib/app/screens/onboarding/widgets/hair_type_picker.dart`
- Create: `lib/app/screens/onboarding/widgets/display_name_field.dart`

(No unit test — covered by `OnboardingScreen` integration test in Task 23.)

- [ ] **Step 1: Implement `HairTypePicker`**

Create `lib/app/screens/onboarding/widgets/hair_type_picker.dart`:

```dart
import 'package:flutter/material.dart';

enum HairType { type2A, type2B, type2C, type3A, type3B, type3C, type4A, type4B, type4C }

extension HairTypeLabel on HairType {
  String get label {
    switch (this) {
      case HairType.type2A:
        return '2A — Wavy';
      case HairType.type2B:
        return '2B — Wavy';
      case HairType.type2C:
        return '2C — Wavy';
      case HairType.type3A:
        return '3A — Curly';
      case HairType.type3B:
        return '3B — Curly';
      case HairType.type3C:
        return '3C — Curly';
      case HairType.type4A:
        return '4A — Coily';
      case HairType.type4B:
        return '4B — Coily';
      case HairType.type4C:
        return '4C — Coily';
    }
  }
}

class HairTypePicker extends StatelessWidget {
  const HairTypePicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final HairType? selected;
  final ValueChanged<HairType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: HairType.values.map((type) {
        final isSelected = type == selected;
        return ChoiceChip(
          label: Text(type.label),
          selected: isSelected,
          onSelected: (_) => onChanged(type),
        );
      }).toList(),
    );
  }
}
```

- [ ] **Step 2: Implement `DisplayNameField`**

Create `lib/app/screens/onboarding/widgets/display_name_field.dart`:

```dart
import 'package:flutter/material.dart';

class DisplayNameField extends StatelessWidget {
  const DisplayNameField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Display name',
        hintText: 'How should we address you?',
      ),
      textInputAction: TextInputAction.done,
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/app/screens/onboarding/widgets/hair_type_picker.dart lib/app/screens/onboarding/widgets/display_name_field.dart
git commit -m "feat(onboarding): add HairTypePicker + DisplayNameField widgets"
```

---

### Task 22: `OnboardingScreen`

**Files:**
- Create: `lib/app/screens/onboarding/onboarding_screen.dart`

- [ ] **Step 1: Implement `OnboardingScreen`**

Create `lib/app/screens/onboarding/onboarding_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/design_system.dart';
import 'widgets/display_name_field.dart';
import 'widgets/hair_type_picker.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  HairType? _hairType;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty && _hairType != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HairBrandAppBar(
        title: 'Welcome to HairPredict',
        showBrandMark: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Let's personalize your hair journey",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Two quick questions and you\'re in.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Text(
                'What should we call you?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              DisplayNameField(controller: _nameController),
              const SizedBox(height: 32),
              Text(
                'What\'s your hair type?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              HairTypePicker(
                selected: _hairType,
                onChanged: (t) => setState(() => _hairType = t),
              ),
              const SizedBox(height: 32),
              GradientButton(
                label: 'Continue',
                isExpanded: true,
                onPressed: _isValid
                    ? () => context.read<OnboardingCubit>().complete()
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/app/screens/onboarding/onboarding_screen.dart
git commit -m "feat(onboarding): add OnboardingScreen (name + hair type)"
```

---

### Task 23: Placeholder tab screens

**Files:**
- Create: `lib/app/screens/home/home_screen.dart`
- Create: `lib/app/screens/profile/profile_screen.dart`
- Create: `lib/app/screens/shell_scaffolds/diagnostics_shell.dart`
- Create: `lib/app/screens/shell_scaffolds/coaching_shell.dart`

- [ ] **Step 1: Implement `HomeScreen`**

Create `lib/app/screens/home/home_screen.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HairBrandAppBar(title: 'Home'),
      body: const EmptyState(
        illustration: Icon(Icons.waving_hand_outlined, size: 80),
        title: 'Welcome back',
        description:
            'Your recent scans and upcoming routines will show up here once you start using HairPredict.',
      ),
    );
  }
}
```

- [ ] **Step 2: Implement `ProfileScreen`**

Create `lib/app/screens/profile/profile_screen.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HairBrandAppBar(title: 'Profile'),
      body: const EmptyState(
        illustration: Icon(Icons.person_outline, size: 80),
        title: 'Your profile',
        description:
            'Hair type, chemical history, and preferences will live here.',
      ),
    );
  }
}
```

- [ ] **Step 3: Implement `DiagnosticsShell`**

Create `lib/app/screens/shell_scaffolds/diagnostics_shell.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';

class DiagnosticsShell extends StatelessWidget {
  const DiagnosticsShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HairBrandAppBar(title: 'Diagnostics'),
      body: const EmptyState(
        illustration: Icon(Icons.health_and_safety_outlined, size: 80),
        title: 'Diagnostics coming soon',
        description:
            'Qwen Vision analysis + PDF dossiers will be available in the next release.',
      ),
    );
  }
}
```

- [ ] **Step 4: Implement `CoachingShell`**

Create `lib/app/screens/shell_scaffolds/coaching_shell.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';

class CoachingShell extends StatelessWidget {
  const CoachingShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HairBrandAppBar(title: 'Coaching'),
      body: const EmptyState(
        illustration: Icon(Icons.chat_bubble_outline, size: 80),
        title: 'Coaching coming soon',
        description:
            'Daily routines and WhatsApp history will appear here once connected.',
      ),
    );
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/app/screens/home/home_screen.dart lib/app/screens/profile/profile_screen.dart lib/app/screens/shell_scaffolds/
git commit -m "feat(screens): add placeholder tab screens (Home, Profile, Diagnostics, Coaching)"
```

---

### Task 24: `OnboardingGate`

**Files:**
- Create: `lib/app/onboarding_gate.dart`

- [ ] **Step 1: Implement `OnboardingGate`**

Create `lib/app/onboarding_gate.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/design_system/design_system.dart';
import 'screens/onboarding/onboarding_screen.dart';

/// Shows the onboarding screen until OnboardingCubit reports complete.
///
/// Wrap your app's router in this so the first-launch flow is handled
/// declaratively.
class OnboardingGate extends StatelessWidget {
  const OnboardingGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingStatus>(
      builder: (context, status) {
        if (status == OnboardingStatus.incomplete) {
          return const OnboardingScreen();
        }
        return child;
      },
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/app/onboarding_gate.dart
git commit -m "feat(app): add OnboardingGate widget"
```

---

### Task 25: `app/router.dart` — GoRouter + StatefulShellRoute

**Files:**
- Create: `lib/app/router.dart`
- Create: `test/router/router_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/router/router_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qwenhairaiapp/app/router.dart';
import 'package:qwenhairaiapp/core/design_system/persistence/onboarding_cubit.dart';
import 'package:qwenhairaiapp/core/design_system/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('redirects to /onboarding when incomplete', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final onboarding = OnboardingCubit(prefs);
    await onboarding.load();
    final theme = ThemeController(prefs);
    final router = buildAppRouter(onboarding, theme);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: onboarding),
          BlocProvider.value(value: theme),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Welcome to HairPredict'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/router/router_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Implement `app/router.dart`**

Create `lib/app/router.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/components/home_shell.dart';
import '../core/design_system/persistence/onboarding_cubit.dart';
import '../core/design_system/theme/theme_controller.dart';
import 'onboarding_gate.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/shell_scaffolds/coaching_shell.dart';
import 'screens/shell_scaffolds/diagnostics_shell.dart';
import 'features/style_try_on/presentation/hair_capture_screen.dart';

/// Builds the root GoRouter for HairPredict.
///
/// Exposed as a function so tests can build their own router without
/// going through the DI container.
GoRouter buildAppRouter(
  OnboardingCubit onboardingCubit,
  ThemeController themeController,
) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final status = onboardingCubit.state;
      final goingToOnboarding = state.matchedLocation == '/onboarding';
      if (status == OnboardingStatus.incomplete && !goingToOnboarding) {
        return '/onboarding';
      }
      if (status == OnboardingStatus.complete && goingToOnboarding) {
        return '/home/try-on';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/try-on',
                builder: (context, state) => const HairCaptureScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/diagnostics',
                builder: (context, state) => const DiagnosticsShell(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/coaching',
                builder: (context, state) => const CoachingShell(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/router/router_test.dart
```

Expected: 1 test passes.

- [ ] **Step 5: Commit**

```bash
git add lib/app/router.dart test/router/router_test.dart
git commit -m "feat(app): add GoRouter with StatefulShellRoute (5 tabs + onboarding gate)"
```

---

## Phase 6 — App root + DI

### Task 26: Update `injection_container.dart`

**Files:**
- Modify: `lib/injection_container.dart`

- [ ] **Step 1: Replace the file**

Replace the contents of `lib/injection_container.dart` with:

```dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qwenhairaiapp/core/repositories/style_try_on_repository.dart';
import 'package:qwenhairaiapp/core/repositories/style_try_on_repository_impl.dart';
import 'package:qwenhairaiapp/core/usecases/process_camera_image.dart';
import 'package:qwenhairaiapp/core/usecases/generate_hair_3d_render.dart';
import 'package:qwenhairaiapp/features/style_try_on/controller/style_try_on_controller.dart';
import 'package:qwenhairaiapp/core/repositories/auth_repository.dart';
import 'package:qwenhairaiapp/core/repositories/auth_repository_impl.dart';
import 'package:qwenhairaiapp/core/repositories/hair_health_repository.dart';
import 'package:qwenhairaiapp/core/repositories/hair_health_repository_impl.dart';
import 'package:qwenhairaiapp/core/network/qwen_cloud_client.dart';

import 'package:qwenhairaiapp/core/design_system/theme/theme_controller.dart';
import 'package:qwenhairaiapp/core/design_system/persistence/onboarding_cubit.dart';
import 'package:qwenhairaiapp/core/design_system/connectivity/connectivity_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qwenhairaiapp/core/design_system/retry/retry_queue.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Design system cubits ────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<ThemeController>(() => ThemeController(sl()));
  sl.registerLazySingleton<OnboardingCubit>(() => OnboardingCubit(sl()));
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit(sl()));
  sl.registerLazySingleton<RetryQueue>(() => NoopRetryQueue());

  // ── Features - Style Try On ─────────────────────────────────────────
  sl.registerFactory(
    () => StyleTryOnController(
      repository: sl(),
      processCameraImageUseCase: sl(),
      generateHair3DRenderUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ProcessCameraImage(sl()));
  sl.registerLazySingleton(() => GenerateHair3DRender(sl()));

  // Repositories
  sl.registerLazySingleton<StyleTryOnRepository>(
    () => StyleTryOnRepositoryImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dio: sl()),
  );
  sl.registerLazySingleton<HairHealthRepository>(
    () => HairHealthRepositoryImpl(dio: sl()),
  );

  // ── External / Core Network Client ──────────────────────────────────
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = 'https://api.qwenhairai.com/v1';
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    return dio;
  });

  sl.registerLazySingleton(() => QwenCloudClient(sl()));
}
```

- [ ] **Step 2: Run analyzer (user)**

```bash
flutter analyze lib/injection_container.dart
```

Expected: 0 errors. If imports are wrong, fix paths.

- [ ] **Step 3: Commit**

```bash
git add lib/injection_container.dart
git commit -m "feat(di): register design-system cubits (Theme, Onboarding, Connectivity)"
```

---

### Task 27: Update `main.dart` + add `app/app.dart`

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/app/app.dart`

- [ ] **Step 1: Replace `main.dart`**

Replace the contents of `lib/main.dart` with:

```dart
import 'package:flutter/material.dart';

import 'package:qwenhairaiapp/app/app.dart';
import 'package:qwenhairaiapp/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const App());
}
```

- [ ] **Step 2: Implement `app/app.dart`**

Create `lib/app/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/design_system/design_system.dart';
import '../injection_container.dart';
import 'router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<OnboardingCubit>()..load(),
        ),
        BlocProvider(
          create: (_) => sl<ThemeController>(),
        ),
        BlocProvider(
          create: (_) => sl<ConnectivityCubit>()..start(),
        ),
        BlocProvider(
          create: (_) =>
              sl<StyleTryOnController>(), // existing feature controller
        ),
      ],
      child: BlocBuilder<ThemeController, ThemeMode>(
        builder: (context, mode) {
          final onboarding = context.read<OnboardingCubit>();
          final themeController = context.read<ThemeController>();
          final router = buildAppRouter(onboarding, themeController);
          return MaterialApp.router(
            title: 'HairPredict',
            debugShowCheckedModeBanner: false,
            themeMode: mode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 3: Run analyzer (user)**

```bash
flutter analyze
```

Expected: 0 errors (or only pre-existing warnings unrelated to this plan).

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart lib/app/app.dart
git commit -m "feat(app): wire MaterialApp.router with theme + onboarding providers"
```

---

## Phase 7 — Migrate existing screens

### Task 28: Migrate `CameraScreen` to `HairBrandAppBar`

**Files:**
- Modify: `lib/features/style_try_on/presentation/camera_screen.dart`

- [ ] **Step 1: Replace `AppBar` with `HairBrandAppBar`**

In `camera_screen.dart`, replace:

```dart
appBar: AppBar(
  title: const Text(
    'Hair AI Style Try-On',
    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
  ),
  backgroundColor: AppColors.surface,
  elevation: 0,
  centerTitle: true,
),
```

with:

```dart
appBar: HairBrandAppBar(
  title: 'Hair AI Style Try-On',
  showBrandMark: true,
),
```

Also replace the import for `app_colors.dart` with:

```dart
import 'package:qwenhairaiapp/core/design_system/design_system.dart';
```

And add this new import:

```dart
import 'package:qwenhairaiapp/core/constants/app_colors.dart' show AppColors;
```

(Keep the old `AppColors` import for any remaining usages — if there are none after the `AppBar` swap, you can remove the import entirely. Search-and-replace `AppColors.primary` → `Theme.of(context).colorScheme.primary` and similar.)

- [ ] **Step 2: Run analyzer (user)**

```bash
flutter analyze lib/features/style_try_on/presentation/camera_screen.dart
```

Expected: 0 errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/style_try_on/presentation/camera_screen.dart
git commit -m "refactor(try-on): migrate CameraScreen to HairBrandAppBar"
```

---

### Task 29: Migrate `HairCaptureScreen` — use `CaptureFrame`

**Files:**
- Modify: `lib/features/style_try_on/presentation/hair_capture_screen.dart`

- [ ] **Step 1: Replace inline capture cards with `CaptureFrame`**

In `hair_capture_screen.dart`, find the `GridView.count` block. Replace the entire `GestureDetector` block inside the `children: _capturedImages.keys.map((angle) { ... }).toList()` with:

```dart
CaptureFrame(
  angleLabel: angle,
  imagePath: _capturedImages[angle],
  onTap: () => _captureImage(angle),
)
```

Also replace the `appBar` block with:

```dart
appBar: HairBrandAppBar(
  title: '3D Hair Scan Scanner',
  showBrandMark: true,
),
```

And replace the `ElevatedButton.icon` for "Generate 3D Hair Model" with:

```dart
GradientButton(
  label: 'Generate 3D Hair Model',
  isExpanded: true,
  onPressed: _allImagesCaptured ? _submitReconstruction : null,
  icon: Icons.cloud_upload_outlined,
)
```

Replace the loading-state `Column` with:

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: const [
    LoadingDots(size: LoadingDotsSize.lg),
    SizedBox(height: 24),
    Text(
      'Reconstructing Hair in 3D...',
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: 8),
    Text(
      'Analyzing hair flow and volume via Qwen AI Cloud',
      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      textAlign: TextAlign.center,
    ),
  ],
)
```

Update imports:

```dart
import 'package:qwenhairaiapp/core/design_system/design_system.dart';
```

- [ ] **Step 2: Run analyzer + test (user)**

```bash
flutter analyze
flutter test
```

Expected: 0 errors, all tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/features/style_try_on/presentation/hair_capture_screen.dart
git commit -m "refactor(try-on): migrate HairCaptureScreen to CaptureFrame + GradientButton + LoadingDots"
```

---

### Task 30: Migrate `RenderViewerScreen` to `HairBrandAppBar`

**Files:**
- Modify: `lib/features/style_try_on/presentation/render_viewer_screen.dart`

- [ ] **Step 1: Replace `AppBar`**

Replace the `appBar:` block with:

```dart
appBar: HairBrandAppBar(
  title: '3D Hair Render',
  showBrandMark: false,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.of(context).pop(),
  ),
),
```

Replace the two `ElevatedButton.icon` for "Share" and "AR Mode" with:

```dart
GradientButton(
  label: 'Share',
  variant: GradientButtonVariant.secondary,
  icon: Icons.share_outlined,
  onPressed: () { /* unchanged */ },
),
GradientButton(
  label: 'AR Mode',
  icon: Icons.view_in_ar_outlined,
  onPressed: () { /* unchanged */ },
),
```

Update imports:

```dart
import 'package:qwenhairaiapp/core/design_system/design_system.dart';
```

- [ ] **Step 2: Run analyzer + test (user)**

```bash
flutter analyze
flutter test
```

Expected: 0 errors, all tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/features/style_try_on/presentation/render_viewer_screen.dart
git commit -m "refactor(try-on): migrate RenderViewerScreen to HairBrandAppBar + GradientButton"
```

---

## Phase 8 — Verification

### Task 31: Final barrel + parity tests

**Files:**
- Modify: `lib/core/design_system/design_system.dart` (now resolvable — all deps exist)
- Create: `test/theme/light_dark_parity_test.dart`

- [ ] **Step 1: Verify barrel compiles**

```bash
flutter analyze lib/core/design_system/design_system.dart
```

Expected: 0 errors.

If errors point to a missing file (e.g. a component or cubit that wasn't created), create it now with a minimal stub.

- [ ] **Step 2: Write light/dark parity tests**

Create `test/theme/light_dark_parity_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qwenhairaiapp/core/design_system/design_system.dart';
import 'package:qwenhairaiapp/features/style_try_on/presentation/camera_screen.dart';
import 'package:qwenhairaiapp/features/style_try_on/presentation/hair_capture_screen.dart';
import 'package:qwenhairaiapp/features/style_try_on/presentation/render_viewer_screen.dart';

import 'package:qwenhairaiapp/app/screens/onboarding/onboarding_screen.dart';
import 'package:qwenhairaiapp/app/screens/home/home_screen.dart';

Future<void> _pumpInTheme(WidgetTester tester, Widget child, ThemeData theme) async {
  await tester.pumpWidget(MaterialApp(theme: theme, home: child));
  await tester.pump();
}

void main() {
  for (final theme in [AppTheme.light(), AppTheme.dark()]) {
    testWidgets('CameraScreen renders in ${theme.brightness.name}', (tester) async {
      await _pumpInTheme(tester, const CameraScreen(), theme);
      expect(tester.takeException(), isNull);
    });
    testWidgets('HairCaptureScreen renders in ${theme.brightness.name}', (tester) async {
      await _pumpInTheme(tester, const HairCaptureScreen(), theme);
      expect(tester.takeException(), isNull);
    });
    testWidgets('RenderViewerScreen renders (skeleton) in ${theme.brightness.name}', (tester) async {
      await _pumpInTheme(tester, const RenderViewerScreen(render: _FakeRender()), theme);
      expect(tester.takeException(), isNull);
    });
    testWidgets('OnboardingScreen renders in ${theme.brightness.name}', (tester) async {
      await _pumpInTheme(tester, const OnboardingScreen(), theme);
      expect(tester.takeException(), isNull);
    });
    testWidgets('HomeScreen renders in ${theme.brightness.name}', (tester) async {
      await _pumpInTheme(tester, const HomeScreen(), theme);
      expect(tester.takeException(), isNull);
    });
  }
}

class _FakeRender extends Object implements dynamic {
  // RenderViewerScreen requires Hair3DRender which isn't trivially constructible
  // in tests without a real modelUrl. Replace with a stub by passing an empty URL.
  @override
  String get modelUrl => '';
  @override
  String get id => 'test';
  @override
  String get status => 'completed';
}
```

Wait — `RenderViewerScreen` requires a `Hair3DRender`. The stub won't work with `implements dynamic`. Replace with a real `Hair3DRender` instance:

```dart
import 'package:qwenhairaiapp/core/entities/hair_3d_render.dart';
// ...
const _render = Hair3DRender(id: 'test', modelUrl: '', status: 'completed');
// ...
RenderViewerScreen(render: _render)
```

Update the test file accordingly.

- [ ] **Step 3: Run parity tests (user)**

```bash
flutter test test/theme/light_dark_parity_test.dart
```

Expected: 10 tests pass (5 screens × 2 themes).

- [ ] **Step 4: Commit**

```bash
git add lib/core/design_system/design_system.dart test/theme/light_dark_parity_test.dart
git commit -m "test(design-system): add light/dark parity coverage for all screens"
```

---

### Task 32: Full test suite + analyze

**Files:** none (verification only)

- [ ] **Step 1: Run analyzer (user)**

```bash
flutter analyze
```

Expected: `No issues found!` (or only pre-existing warnings in non-plan files).

- [ ] **Step 2: Run all tests (user)**

```bash
flutter test
```

Expected: every test passes. There should be ~25+ tests across tokens, cubits, components, theme, and router.

- [ ] **Step 3: Manual smoke test (user)**

User runs:

```bash
flutter run
```

Then in the app:
1. First launch → onboarding screen appears (name + hair type)
2. Fill in name, pick hair type, tap "Continue" → routes to Try-On tab
3. Verify Try-On tab shows HairCaptureScreen with the 4 CaptureFrame cards
4. Verify bottom nav has 5 tabs (Home / Try-On / Diagnostics / Coaching / Profile)
5. Tap each tab → switches correctly, no scroll state loss
6. Toggle system theme (Settings → Display → Light/Dark) → app re-themes immediately
7. Kill the app + relaunch → goes straight to last tab (no onboarding re-prompt)
8. Toggle airplane mode → amber offline banner appears within 5s

- [ ] **Step 4: Final commit if any fixups were needed**

```bash
git add -A
git commit -m "chore: final fixups after smoke test"
```

If everything passed cleanly, no commit needed — the plan is done.

---

## Plan complete

All 32 tasks executed → app boots into onboarding on first launch → onboarding complete routes to 5-tab shell → light/dark theme follows system → all existing Try-On screens work with the new design system → offline banner appears → all tests pass.
