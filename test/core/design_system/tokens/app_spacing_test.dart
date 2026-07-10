import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/tokens/app_spacing.dart';

void main() {
  group('AppSpacing scale', () {
    test('follows 4px base unit', () {
      expect(AppSpacing.xxs, 4.0);
      expect(AppSpacing.xs, 8.0);
      expect(AppSpacing.sm, 12.0);
      expect(AppSpacing.md, 16.0);
      expect(AppSpacing.lg, 24.0);
      expect(AppSpacing.xl, 32.0);
      expect(AppSpacing.xxl, 48.0);
      expect(AppSpacing.xxxl, 64.0);
    });
  });
}
