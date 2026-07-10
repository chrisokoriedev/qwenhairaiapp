import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/persistence/onboarding_cubit.dart';
import 'package:qwenhairaiapp/core/entities/hair_type.dart';
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
      expect(cubit.displayName, isNull);
      expect(cubit.hairType, isNull);
    });

    test('starts complete when preference saved', () async {
      SharedPreferences.setMockInitialValues({
        'hairpredict.onboarding.v1': 'complete',
        'hairpredict.onboarding.display_name.v1': 'Jane Doe',
        'hairpredict.onboarding.hair_type.v1': 'type3C',
      });
      final prefs = await SharedPreferences.getInstance();
      final cubit = OnboardingCubit(prefs);
      await cubit.load();
      expect(cubit.state, OnboardingStatus.complete);
      expect(cubit.displayName, 'Jane Doe');
      expect(cubit.hairType, HairType.type3C);
    });

    test('complete() persists and emits', () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = OnboardingCubit(prefs);
      await cubit.load();
      await cubit.complete('John Smith', HairType.type4B);
      expect(cubit.state, OnboardingStatus.complete);
      expect(prefs.getString('hairpredict.onboarding.v1'), 'complete');
      expect(prefs.getString('hairpredict.onboarding.display_name.v1'), 'John Smith');
      expect(prefs.getString('hairpredict.onboarding.hair_type.v1'), 'type4B');
      expect(cubit.displayName, 'John Smith');
      expect(cubit.hairType, HairType.type4B);
    });
  });
}
