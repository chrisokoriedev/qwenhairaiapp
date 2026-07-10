# HairPredict — App Shell + Design System Design

**Status:** Draft — pending user review
**Date:** 2026-07-10
**Slice:** First sub-project from the broader HairPredict UI work (chosen by user decomposition)
**Out of scope:** Diagnostics feature, Coaching feature, Profile feature, Payments, WhatsApp mirror — each is a separate spec.

---

## 1. Context

`TECHNICAL.md` describes HairPredict — an AI-powered hair health analysis and virtual style try-on app built on Qwen Cloud for the Qwen AI Hackathon. The current codebase has only three flat screens (camera, 4-angle capture, 3D viewer) under `features/style_try_on/`, no navigation, no theme system beyond a single `AppColors` constant, and no onboarding.

The user picked **app shell + nav + design system** as the first sub-project to build. Everything else (diagnostics flow, coaching mirror, profile) will plug into this shell once it exists.

### What `TECHNICAL.md` requires of the shell

| Requirement | Implication |
|---|---|
| MemoryAgent retains hair type + chemical history | Onboarding + Profile destination are mandatory |
| Autopilot framing ("autonomous end-to-end agent") | Capture/processing screens should feel like handing off to an agent, not clicking a button |
| Target audience: African hair textures (locs, coils, complex patterns) | Brand identity should celebrate African hair care explicitly |
| Bidirectional WhatsApp coaching | App needs deep-link entry points from WhatsApp into Coaching tab |
| Offline-first | Shell must handle cold start, cached state, offline banner |

### User decisions captured during brainstorming

| Decision | Choice |
|---|---|
| Brand direction | Evolved warm palette — dark base, amber/copper accents, editorial feel |
| Navigation | 5 tabs: Home / Try-On / Diagnostics / Coaching / Profile |
| Theme support | Both light + dark, follows system |
| Onboarding | Minimal + blocking (hair type + display name only) |
| Routing library | `go_router` |
| Typography | Fraunces (display) + Inter (body) via `google_fonts` |
| Motion | Built-in implicit animations + `flutter_animate` |
| Architecture approach | **Approach C** — Hybrid: rigorous tokens + 6 brand-critical custom widgets |

---

## 2. Architecture

### Folder structure (target)

```
lib/
├── core/
│   ├── constants/                       # (existing) app_colors.dart → kept for back-compat, re-exported
│   ├── entities/                        # (existing)
│   ├── errors/                          # (existing) failures.dart, exceptions.dart
│   ├── models/                          # (existing)
│   ├── network/                         # (existing) qwen_cloud_client.dart
│   ├── repositories/                    # (existing)
│   ├── usecases/                        # (existing)
│   └── design_system/                   # NEW
│       ├── design_system.dart           # barrel export
│       ├── tokens/
│       │   ├── app_colors.dart          # raw brand palette + semantic mappings
│       │   ├── app_spacing.dart         # 4/8/12/16/24/32/48/64 scale
│       │   ├── app_radii.dart           # sm/md/lg/xl/pill (8/12/16/24/999)
│       │   ├── app_typography.dart      # Fraunces + Inter scale (display/title/body/label)
│       │   ├── app_elevations.dart      # 0/1/2/3/4 levels with M3 surfaceTint
│       │   └── app_motion.dart          # durations + curves (easeOutCubic, etc.)
│       ├── theme/
│       │   ├── app_theme.dart           # buildLightTheme() + buildDarkTheme() from tokens
│       │   ├── hair_theme.dart          # ThemeExtension<HairTheme> definition
│       │   └── theme_controller.dart    # ThemeMode cubit (system/light/dark)
│       ├── connectivity/
│       │   └── connectivity_cubit.dart  # wraps connectivity_plus, broadcasts Online/Offline
│       ├── persistence/
│       │   └── onboarding_cubit.dart    # persists onboarding-complete flag
│       ├── retry/
│       │   └── retry_queue.dart         # offline write-queue service
│       └── components/
│           ├── gradient_button.dart
│           ├── hair_brand_app_bar.dart
│           ├── capture_frame.dart
│           ├── empty_state.dart
│           ├── loading_dots.dart
│           └── home_shell.dart
├── features/
│   └── style_try_on/                    # (existing — controller + state only)
│       ├── controller/style_try_on_controller.dart
│       ├── state/style_try_on_event.dart
│       ├── state/style_try_on_state.dart
│       └── presentation/
│           ├── camera_screen.dart
│           ├── hair_capture_screen.dart
│           └── render_viewer_screen.dart
├── app/                                 # NEW
│   ├── app.dart                         # root widget: MultiBlocProvider + MaterialApp.router
│   ├── router.dart                      # GoRouter config + StatefulShellRoute
│   ├── onboarding_gate.dart             # routes to /onboarding vs /home
│   └── screens/
│       ├── onboarding/
│       │   ├── onboarding_screen.dart
│       │   └── widgets/
│       │       ├── hair_type_picker.dart
│       │       └── display_name_field.dart
│       ├── home/
│       │   └── home_screen.dart         # default landing for each tab branch
│       ├── profile/
│       │   └── profile_screen.dart
│       └── shell_scaffolds/             # minimal placeholder scaffolds for unimplemented tabs
│           ├── diagnostics_shell.dart
│           └── coaching_shell.dart
├── injection_container.dart             # (existing — extended)
└── main.dart                            # thin: ensureInitialized + runApp(App())
```

### Composition at runtime

1. `main.dart`: `WidgetsFlutterBinding.ensureInitialized()` → `await di.init()` → `runApp(App())`.
2. `App` widget: `MultiBlocProvider` for `OnboardingCubit`, `ThemeController`, `ConnectivityCubit`. Wraps `MaterialApp.router` configured with the router from `app/router.dart`, reading `themeMode` from `ThemeController`.
3. `app/router.dart` builds a `GoRouter` with:
   - Top-level `redirect` consulting `OnboardingCubit` state.
   - `StatefulShellRoute.indexedStack` with 5 branches for the 5 tabs.
   - Each branch has its own `Navigator` so scroll + form state survives tab switches.
   - Deep-link configuration so `hairpredict://home/coaching` opens Coaching tab.
4. `HomeShell` wraps the body of `StatefulShellRoute`. It watches `navigationShell.currentIndex` and renders the bottom nav with the animated indicator.
5. Each tab branch has its own `MultiBlocProvider` for feature cubits (Try-On keeps the existing `StyleTryOnController`).

### Theme switching

- `ThemeController` is a `Cubit<ThemeMode>` with state persisted via `SharedPreferences` (key: `hairpredict.theme.v1`).
- `MaterialApp.router` reads `themeMode: context.watch<ThemeController>().state`.
- Light/dark themes are both pre-built from the same token classes — the only thing that differs is which raw color is mapped to each semantic role.

### Onboarding gate

- `OnboardingCubit` is a `Cubit<OnboardingStatus>` with state `OnboardingIncomplete | OnboardingComplete`.
- Persisted via `SharedPreferences` (key: `hairpredict.onboarding.v1`).
- The router's `redirect` callback:
  - If state == `OnboardingIncomplete` and path != `/onboarding` → redirect to `/onboarding`.
  - If state == `OnboardingComplete` and path == `/onboarding` → redirect to `/home/try-on` (default landing).

---

## 3. Components

### The 6 brand-critical custom widgets

#### `GradientButton`

| Prop | Type | Required | Notes |
|---|---|---|---|
| `label` | `String` | yes | Button text |
| `onPressed` | `VoidCallback?` | yes | null = disabled |
| `icon` | `IconData?` | no | Leading icon |
| `variant` | `enum {primary, secondary, tertiary}` | no, default primary | primary = gradient bg, secondary = ghost outline, tertiary = text-only |
| `isLoading` | `bool` | no, default false | Swaps label for `LoadingDots` |
| `isExpanded` | `bool` | no, default false | Wraps width to parent |

Visual: amber→copper linear gradient background, white label, 12px radius (md), subtle inner glow. Secondary = 1.5px brand-amber border + transparent bg + brand-amber label. Tertiary = transparent bg + brand-amber label.

States: enabled (full opacity), disabled (38% opacity), loading (label replaced by `LoadingDots`, onPressed suppressed).

Used by: hero CTAs ("Generate 3D Hair Model", "Start Diagnostic Scan", "Book Trichologist"), onboarding "Continue" button.

#### `HairBrandAppBar`

| Prop | Type | Required | Notes |
|---|---|---|---|
| `title` | `String` | yes | Rendered as Fraunces 22sp |
| `leading` | `Widget?` | no | If null and `showBrandMark: true`, shows brand-mark slot |
| `actions` | `List<Widget>?` | no | |
| `showBrandMark` | `bool` | no, default true | When true and `leading` is null, shows brand mark on left |

Visual: surface bg, height = `kToolbarHeight + 16` (taller than M3 default), Fraunces title, brand-mark placeholder slot on left when `showBrandMark: true`. Bottom 1px border in surface variant color.

Used by: every primary screen — replaces current `AppBar(title: Text(...))` pattern.

#### `CaptureFrame`

| Prop | Type | Required | Notes |
|---|---|---|---|
| `angleLabel` | `String` | yes | "Front" / "Back" / "Left" / "Right" |
| `imagePath` | `String?` | no, default null | null = empty state |
| `onTap` | `VoidCallback` | yes | Fires when card tapped |

Visual: rounded rect (radius lg = 16), 4 corner brackets (8px arms, 2px stroke, brand-amber when empty, primary when filled). Empty state shows camera icon (40px, textSecondary 60%) + `angleLabel` (Fraunces 16sp bold) + "Tap to capture" (Inter 12sp textSecondary). Filled state shows `Image.file(fit: BoxFit.cover)` + gradient overlay (transparent → black87) + check mark icon + `angleLabel`. Fill transition uses `AnimatedContainer` (200ms easeOutCubic).

Used by: 4-angle capture grid in `HairCaptureScreen` (replaces the 4 inline capture cards). Future: try-on image upload step.

#### `EmptyState`

| Prop | Type | Required | Notes |
|---|---|---|---|
| `illustration` | `Widget` | yes | Lottie OR static SVG/PNG slot, 160x160 |
| `title` | `String` | yes | Fraunces 24sp bold |
| `description` | `String` | yes | Inter 14sp textSecondary |
| `action` | `({String label, VoidCallback onPressed})?` | no | If present, renders `GradientButton` (variant: secondary) |

Visual: centered column, 48px vertical spacing. Padding: 32px horizontal.

Used by: Home tab empty (no scans yet), Diagnostics empty (no reports), Coaching empty (no routines), Profile empty (no history), feature-level error states that benefit from illustration + retry.

#### `LoadingDots`

| Prop | Type | Required | Notes |
|---|---|---|---|
| `size` | `enum {sm, md, lg}` | no, default md | dot diameter 6/10/14 |
| `color` | `Color?` | no, default primary | |

Visual: 3 dots in a row with 8px gap, sequence-staggered scale animation (1.0 → 1.3 → 1.0, 600ms total, easeInOut). Implemented via `AnimatedBuilder` + `Tween<double>`.

Used by: "Reconstructing Hair in 3D…" (lg, primary), "Analyzing with Qwen Vision…" (md, primary), "Compiling PDF dossier…" (md, primary), inline button loading states (sm, onPrimary).

#### `HomeShell`

| Prop | Type | Required | Notes |
|---|---|---|---|
| `navigationShell` | `StatefulNavigationShell` | yes | from go_router |

Visual: body slot at top (takes remaining space after app bar + nav). Bottom nav at bottom: 5 destinations — Home (Icons.home_outlined / Icons.home), Try-On (Icons.face_retouching_natural_outlined / Icons.face_retouching_natural), Diagnostics (Icons.health_and_safety_outlined / Icons.health_and_safety), Coaching (Icons.chat_bubble_outline / Icons.chat_bubble), Profile (Icons.person_outline / Icons.person). Always-show labels. Animated indicator pill (`AnimatedAlign` + `Curves.easeOutCubic`, 280ms). Optional offline banner slot above body when `ConnectivityCubit.state == Offline`.

Used by: wraps the entire `StatefulShellRoute.indexedStack` body — instantiated once, never rebuilt.

### M3 components inherited as-is (only themed)

- `NavigationBar` — themed via `ThemeData.navigationBarTheme`: indicator = brand primary (28% alpha), label display = always shown, height = 72px. No custom wrapper widget.
- `TextField` + `InputDecoration` — focused border = primary, filled = surface, label = Fraunces 14sp.
- `Card`, `Chip`, `ListTile`, `Switch`, `Checkbox`, `Radio`, `Slider` — themed via `cardTheme`, `chipTheme`, `listTileTheme`, `switchTheme`, `checkboxTheme`, `radioTheme`, `sliderTheme`.
- `Dialog`, `BottomSheet`, `SnackBar` — themed via `dialogTheme`, `bottomSheetTheme`, `snackBarTheme`.
- `Hero` — used for camera thumbnail → viewer, scan card → diagnostics.

### Token API surface

Single import: `package:qwenhairaiapp/core/design_system/design_system.dart`.

**Standard M3 surface** (use these in 80% of screen code — zero brand extension imports needed):

```dart
Theme.of(context).colorScheme.primary         // brand primary
Theme.of(context).colorScheme.surface         // card bg
Theme.of(context).colorScheme.onSurface       // primary text on cards
Theme.of(context).textTheme.titleLarge        // title text style (Fraunces)
Theme.of(context).textTheme.bodyMedium        // body text style (Inter)
```

**Brand extensions** (read via `ThemeExtension`, used only inside custom widgets):

```dart
final brand = Theme.of(context).extension<HairTheme>()!;
brand.colors.brandAmber          // raw brand amber (#E8A24C candidate)
brand.colors.brandCopper         // raw brand copper (#B45F3F candidate)
brand.spacing.lg                 // 24
brand.spacing.xl                 // 32
brand.radii.md                   // 12
brand.motion.durationNormal      // 240ms
brand.motion.curveEmerge         // Curves.easeOutCubic
```

### Reuse rule

Add a new custom widget only when both: (a) the screen would look generic without it AND (b) the implementation is < 100 lines. Otherwise inherit from M3 and theme via `ThemeData`. Enforced in code review.

---

## 4. Data flow

### Root providers (lifted to `App` widget)

```dart
class App extends StatelessWidget {
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<OnboardingCubit>()..load()),
        BlocProvider(create: (_) => sl<ThemeController>()),
        BlocProvider(create: (_) => sl<ConnectivityCubit>()..start()),
      ],
      child: BlocBuilder<ThemeController, ThemeMode>(
        builder: (context, mode) => MaterialApp.router(
          title: 'HairPredict',
          themeMode: mode,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
```

- **`OnboardingCubit`** — state `OnboardingIncomplete | OnboardingComplete`. Persisted via `SharedPreferences`. On `load()` reads flag; on `complete()` writes it. Router redirects consult this state.
- **`ThemeController`** — state `ThemeMode.system | ThemeMode.light | ThemeMode.dark`. Persisted. `MaterialApp.router` reads via `BlocBuilder`.
- **`ConnectivityCubit`** — state `Online | Offline`. Wraps `connectivity_plus`. `start()` subscribes; `close()` cancels. `HomeShell` renders banner when offline.

### Feature controllers stay inside their tab branch

```
StatefulShellRoute.indexedStack
├── branch 0: HomeTab        → MultiBlocProvider(HomeCubit)             [NEW — placeholder cubit]
├── branch 1: TryOnTab       → MultiBlocProvider(StyleTryOnController)  [existing]
├── branch 2: DiagnosticsTab → MultiBlocProvider(DiagnosticsCubit)      [NEW — placeholder cubit]
├── branch 3: CoachingTab    → MultiBlocProvider(CoachingCubit)         [NEW — placeholder cubit]
└── branch 4: ProfileTab     → MultiBlocProvider(ProfileCubit)          [NEW — placeholder cubit]
```

Placeholder cubits (`HomeCubit`, `DiagnosticsCubit`, `CoachingCubit`, `ProfileCubit`) emit minimal state (`Uninitialized`) for now. Each future sub-project will replace its placeholder with a real cubit.

Each branch has its own `Navigator` so scroll position, in-flight text fields, and partial form state survive tab switches. `StatefulNavigationShell.currentIndex` is the single source of truth for active tab — `HomeShell` watches it.

### DI additions (in `injection_container.dart`)

```dart
sl.registerLazySingleton<SharedPreferences>(() async => /* ... */);
sl.registerLazySingleton<OnboardingCubit>(() => OnboardingCubit(sl()));
sl.registerLazySingleton<ThemeController>(() => ThemeController(sl()));
sl.registerLazySingleton<Connectivity>(() async => Connectivity());
sl.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit(sl()));
sl.registerLazySingleton<RetryQueue>(() => RetryQueue(sl()));
```

### State persistence rule

Only `OnboardingCubit` and `ThemeController` persist. Feature state lives in memory; re-entering a tab re-fetches from the repository (which itself caches via the offline layer — out of scope for this spec).

---

## 5. Error handling

### Three categories, three UI patterns

| Category | Where it surfaces | UI pattern |
|---|---|---|
| **Recoverable** (network timeout, 5xx, AI job failed) | Inside the feature (e.g. `Hair3DError`) | Inline error card: muted surface bg + icon + short message + "Try again" `GradientButton` (tertiary). No full-screen takeover. |
| **Blocking** (camera permission denied, no storage, biometrics unavailable) | At the entry to the feature | `EmptyState`-style full-screen explanation + primary CTA to open Settings / re-grant permission. |
| **Fatal** (unrecoverable corruption, version mismatch) | Root | App-wide `ErrorScreen` with restart button + "Send diagnostic report" link. Logged to crash reporting. |

### Offline handling

- `ConnectivityCubit` broadcasts `Offline`.
- `HomeShell` subscribes; when offline, renders a slim amber banner above body: "You're offline — recent scans available, new analyses will resume when you reconnect."
- Read paths (Home, Profile, Diagnostics history) read from local cache first, network second — out of scope for this spec but the cubit exposes the signal.
- Write paths (3D reconstruction, diagnostic submission, PDF generation) queue offline via `RetryQueue` and retry on reconnect — out of scope for this spec but the cubit exposes the signal.

### Permission handling

- **Camera**: requested lazily on first capture. If denied → `EmptyState` with "Open Settings" CTA. If permanently denied → same, plus detect via `permission_handler` and link directly to app settings via `app_settings` package.
- **Notifications**: requested after onboarding completes. If denied → Coaching tab shows a one-time banner asking to enable; not blocking.

### Existing failure plumbing reused

`core/errors/failures.dart` already defines `Failure`, `ServerFailure`, `CacheFailure`, `ConnectionFailure` + the `Result<S, E>` sealed type. The new UI just consumes these — no error-type changes.

### Logging

Every error path logs a structured `Logger` (package:logging) entry with a correlation id. No PII in logs (no image bytes, no user names, no email).

---

## 6. Testing

### Unit tests (`test/core/`)

- Token classes are pure → shape + equality only.
- `OnboardingCubit`, `ThemeController`, `ConnectivityCubit` — pump in mock `SharedPreferences` / `Connectivity`, assert state transitions.

### Widget tests (`test/widgets/`)

- `HomeShell` — given a fake `StatefulNavigationShell`, renders 5 nav items; tapping each calls `goBranch(i)`; active item shows filled icon + label.
- `GradientButton` — all 3 variants render; `isLoading` swaps label for `LoadingDots`; `onPressed: null` disables; responds to tap.
- `CaptureFrame` — empty renders corner brackets + camera icon; with `imagePath` renders `Image.file` + check mark; `onTap` fires.
- `EmptyState` — renders illustration + title + description + (optional) action.
- `LoadingDots` — pumps through full animation cycle without exceptions.
- `OnboardingScreen` — happy path completes and calls `OnboardingCubit.complete()`; back button suppressed.

### Theme parity tests (`test/theme/`)

For each custom widget + each M3-inherited widget used in a screen (`HairCaptureScreen`, `RenderViewerScreen`, `OnboardingScreen`, `HomeScreen`), pump once in `ThemeData.light()` and once in `ThemeData.dark()`, capture `WidgetTester.takeException()` → must be empty.

Golden tests for `HomeScreen`, `OnboardingScreen`, `HairCaptureScreen` in both themes — visual regression safety net.

### Route tests (`test/router/`)

- Unauthenticated user (onboarding incomplete) → `/` redirects to `/onboarding`.
- Authenticated (onboarding complete) user → `/` redirects to `/home/try-on` (default landing).
- Deep link `hairpredict://home/coaching` lands on Coaching tab.
- Offline → `HomeShell` renders the offline banner.

### What's NOT tested

- Camera capture flow itself (requires device/emulator) — manual QA only.
- `model_viewer_plus` 3D viewer — manual QA only.
- AI vision endpoints — mocked in widget tests.

### Test runner

`flutter test` (already standard). CI integration is out of scope for this spec.

---

## 7. Dependencies (additions to `pubspec.yaml`)

```yaml
dependencies:
  go_router: ^14.6.0                   # routing
  google_fonts: ^6.2.1                  # Fraunces + Inter
  flutter_animate: ^4.5.0               # concise entrance/exit animations
  shared_preferences: ^2.3.3            # persistence for OnboardingCubit + ThemeController
  connectivity_plus: ^6.1.0             # online/offline signal
  permission_handler: ^11.3.1           # camera + notification permission UX
  app_settings: ^5.1.1                  # deep-link to system settings on permanent denial
  logging: ^1.3.0                       # structured error logging
```

No removals. Existing dependencies preserved.

---

## 8. Migration / rollback

### Existing code touched

- `lib/main.dart` — shrinks to `ensureInitialized` + `runApp(App())`.
- `lib/injection_container.dart` — registers new singletons; preserves existing registrations.
- `lib/features/style_try_on/presentation/*.dart` — replace `AppBar(...)` with `HairBrandAppBar(...)`. Replace inline capture cards in `HairCaptureScreen` with `CaptureFrame`. **No controller/state changes.**
- `lib/core/constants/app_colors.dart` — kept (re-exported from `design_system.dart` for back-compat). New tokens live in `core/design_system/tokens/`.

### Rollback

This is a greenfield addition — no existing behavior is removed. The Try-On feature works the same way it did before, just visually themed + wrapped in the shell. To roll back: `git revert` the merge commit; existing screens continue to function without the shell.

---

## 9. Out of scope (deferred to future specs)

- Diagnostics feature (Qwen Vision analysis + PDF dossier)
- Coaching feature (in-app WhatsApp mirror)
- Profile feature (history, preferences, hair-type editing)
- Trichologist booking + Paystack payments
- Real-time notifications (coaching routines)
- CI integration for tests
- Localization (English-only for hackathon)
- Analytics + crash reporting wiring (interfaces only, no provider yet)

---

## 10. Success criteria

- [ ] `flutter pub get` succeeds with the new dependencies
- [ ] `flutter analyze` returns 0 issues
- [ ] `flutter test` passes all unit, widget, theme parity, and route tests
- [ ] App boots into onboarding on first launch (verified by clearing `SharedPreferences` and launching)
- [ ] Onboarding completion routes to `/home/try-on` and persists across app restarts
- [ ] Toggling system theme (light ↔ dark) immediately re-themes the entire app without restart
- [ ] Bottom nav switches between 5 tabs, preserving scroll position per tab
- [ ] Offline state (airplane mode) shows the amber banner within 5 seconds
- [ ] All 6 custom widgets are used in at least one screen (not just defined)
- [ ] No existing `style_try_on` behavior regresses (4-angle capture + 3D viewer still work end-to-end)
