import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/tokens/app_motion.dart';

void main() {
  group('AppMotion durations', () {
    test('fast is 150ms', () {
      expect(AppMotion.durationFast, const Duration(milliseconds: 150));
    });

    test('normal is 240ms', () {
      expect(AppMotion.durationNormal, const Duration(milliseconds: 240));
    });

    test('slow is 400ms', () {
      expect(AppMotion.durationSlow, const Duration(milliseconds: 400));
    });
  });

  group('AppMotion curves', () {
    test('curveEmerge is easeOutCubic', () {
      expect(AppMotion.curveEmerge, Curves.easeOutCubic);
    });

    test('curveStandard is easeInOut', () {
      expect(AppMotion.curveStandard, Curves.easeInOut);
    });
  });
}
