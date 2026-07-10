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
