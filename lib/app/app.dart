import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/design_system/theme/app_theme.dart';
import '../core/design_system/connectivity/connectivity_cubit.dart';
import '../core/design_system/persistence/onboarding_cubit.dart';
import '../core/design_system/theme/theme_controller.dart';
import '../features/style_try_on/controller/style_try_on_controller.dart';
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
          create: (_) => sl<StyleTryOnController>(),
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
