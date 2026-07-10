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
