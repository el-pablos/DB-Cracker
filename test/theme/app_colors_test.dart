import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/theme/app_colors.dart';
import 'package:db_cracker_tamaengs/theme/app_theme.dart';

void main() {
  group('AppColors — Neo-Violet palette', () {
    test('primary is violet #7C3AED', () {
      expect(AppColors.primary, equals(const Color(0xFF7C3AED)));
    });

    test('background is deep navy #0F0F23, not pure black', () {
      expect(AppColors.background, equals(const Color(0xFF0F0F23)));
      expect(AppColors.background, isNot(equals(Colors.black)));
      expect(AppColors.background, isNot(equals(const Color(0xFF000000))));
    });

    test('colorScheme brightness is dark', () {
      final scheme = AppColors.colorScheme;
      expect(scheme.brightness, equals(Brightness.dark));
    });

    test('textPrimary has luminance > 0.5 (readable on dark bg)', () {
      final luminance = AppColors.textPrimary.computeLuminance();
      expect(luminance, greaterThan(0.5));
    });

    test('background has luminance < 0.1 (dark surface)', () {
      final luminance = AppColors.background.computeLuminance();
      expect(luminance, lessThan(0.1));
    });

    test('semantic colors are distinct from each other', () {
      final semanticColors = <Color>[
        AppColors.success,
        AppColors.warning,
        AppColors.error,
        AppColors.info,
      ];

      // Every pair must be different
      for (var i = 0; i < semanticColors.length; i++) {
        for (var j = i + 1; j < semanticColors.length; j++) {
          expect(
            semanticColors[i],
            isNot(equals(semanticColors[j])),
            reason:
                'Semantic color at index $i should differ from index $j',
          );
        }
      }
    });

    test('semantic colors are distinct from primary', () {
      expect(AppColors.success, isNot(equals(AppColors.primary)));
      expect(AppColors.warning, isNot(equals(AppColors.primary)));
      expect(AppColors.error, isNot(equals(AppColors.primary)));
      expect(AppColors.info, isNot(equals(AppColors.primary)));
    });
  });

  group('AppTheme.darkTheme integration', () {
    test('darkTheme uses AppColors.colorScheme', () {
      final theme = AppTheme.darkTheme;
      expect(theme.colorScheme.primary, equals(AppColors.primary));
      expect(theme.colorScheme.brightness, equals(Brightness.dark));
    });

    test('scaffoldBackgroundColor matches AppColors.background', () {
      final theme = AppTheme.darkTheme;
      expect(theme.scaffoldBackgroundColor, equals(AppColors.background));
    });
  });
}
