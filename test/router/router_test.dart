import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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
