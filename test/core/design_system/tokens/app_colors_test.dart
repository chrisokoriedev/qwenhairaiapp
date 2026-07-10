import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwenhairaiapp/core/design_system/tokens/app_colors.dart';

void main() {
  group('AppColors raw palette', () {
    test('brandAmber is a warm amber', () {
      expect(AppColors.brandAmber, const Color(0xFFE8A24C));
    });

    test('brandCopper is a warm copper', () {
      expect(AppColors.brandCopper, const Color(0xFFB45F3F));
    });

    test('backgroundDark is near-black with slight blue tint', () {
      expect(AppColors.backgroundDark, const Color(0xFF0F0E17));
    });

    test('backgroundLight is warm off-white', () {
      expect(AppColors.backgroundLight, const Color(0xFFFAF7F2));
    });
  });

  group('AppColors semantic mappings', () {
    test('onDark primary is amber', () {
      expect(AppColors.onDarkPrimary, AppColors.brandAmber);
    });

    test('onLight primary is copper', () {
      expect(AppColors.onLightPrimary, AppColors.brandCopper);
    });
  });
}
