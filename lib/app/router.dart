import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/components/home_shell.dart';
import '../core/design_system/persistence/onboarding_cubit.dart';
import '../core/design_system/theme/theme_controller.dart';
import '../features/style_try_on/presentation/hair_capture_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/shell_scaffolds/coaching_shell.dart';
import 'screens/shell_scaffolds/diagnostics_shell.dart';

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
