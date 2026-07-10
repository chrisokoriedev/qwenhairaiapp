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
