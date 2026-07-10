import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/design_system/persistence/onboarding_cubit.dart';
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
