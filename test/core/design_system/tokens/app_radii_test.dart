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
