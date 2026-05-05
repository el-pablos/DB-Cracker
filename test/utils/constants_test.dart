import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/utils/constants.dart';
import 'package:db_cracker_tamaengs/theme/app_colors.dart';
import 'package:db_cracker_tamaengs/theme/app_typography.dart';
import 'package:db_cracker_tamaengs/theme/app_spacing.dart';

void main() {
  group('AppColors (Neo-Violet)', () {
    test('primary is violet', () {
      expect(AppColors.primary, const Color(0xFF7C3AED));
    });

    test('secondary is cyan', () {
      expect(AppColors.secondary, const Color(0xFF06B6D4));
    });

    test('background is deep navy not pure black', () {
      expect(AppColors.background, const Color(0xFF0F0F23));
      expect(AppColors.background, isNot(const Color(0xFF000000)));
    });

    test('error is red', () {
      expect(AppColors.error, const Color(0xFFEF4444));
    });

    test('success is emerald', () {
      expect(AppColors.success, const Color(0xFF10B981));
    });

    test('text colors have proper hierarchy', () {
      // Primary text should be lightest
      expect(AppColors.textPrimary, const Color(0xFFE2E8F0));
      expect(AppColors.textSecondary, const Color(0xFF94A3B8));
      expect(AppColors.textTertiary, const Color(0xFF64748B));
    });
  });

  group('CtOSColors (legacy compat)', () {
    test('primary maps to violet', () {
      expect(CtOSColors.primary, AppColors.primary);
    });

    test('background maps to deep navy', () {
      expect(CtOSColors.background, AppColors.background);
    });

    test('textAccent matches primary', () {
      expect(CtOSColors.textAccent, CtOSColors.primary);
    });
  });

  group('AppStrings', () {
    test('appName is not empty', () {
      expect(AppStrings.appName.isNotEmpty, true);
    });

    test('homeTitle is not empty', () {
      expect(AppStrings.homeTitle.isNotEmpty, true);
    });
  });

  group('AnimationDurations', () {
    test('fast < medium < slow < verySlow', () {
      expect(AnimationDurations.fast < AnimationDurations.medium, true);
      expect(AnimationDurations.medium < AnimationDurations.slow, true);
      expect(AnimationDurations.slow < AnimationDurations.verySlow, true);
    });
  });

  group('AppDimensions', () {
    test('spacing values are ordered', () {
      expect(AppDimensions.xs < AppDimensions.sm, true);
      expect(AppDimensions.sm < AppDimensions.md, true);
      expect(AppDimensions.md < AppDimensions.lg, true);
      expect(AppDimensions.lg < AppDimensions.xl, true);
      expect(AppDimensions.xl < AppDimensions.xxl, true);
    });

    test('radius values are ordered', () {
      expect(AppDimensions.radiusSm < AppDimensions.radiusMd, true);
      expect(AppDimensions.radiusMd < AppDimensions.radiusLg, true);
      expect(AppDimensions.radiusLg < AppDimensions.radiusXl, true);
    });
  });

  group('AppSpacing', () {
    test('spacing scale is ordered', () {
      expect(AppSpacing.xs < AppSpacing.sm, true);
      expect(AppSpacing.sm < AppSpacing.md, true);
      expect(AppSpacing.md < AppSpacing.lg, true);
      expect(AppSpacing.lg < AppSpacing.xl, true);
    });

    test('border radius values are ordered', () {
      expect(AppSpacing.radiusSm < AppSpacing.radiusMd, true);
      expect(AppSpacing.radiusMd < AppSpacing.radiusLg, true);
      expect(AppSpacing.radiusLg < AppSpacing.radiusXl, true);
    });
  });

  group('AppTypography', () {
    test('fontBody is Inter', () {
      expect(AppTypography.fontBody, 'Inter');
    });

    test('fontDisplay is JetBrainsMono', () {
      expect(AppTypography.fontDisplay, 'JetBrainsMono');
    });

    test('display sizes are ordered large > medium > small', () {
      expect(AppTypography.displayLarge.fontSize! > AppTypography.displayMedium.fontSize!, true);
      expect(AppTypography.displayMedium.fontSize! > AppTypography.displaySmall.fontSize!, true);
    });

    test('body sizes are ordered large > medium > small', () {
      expect(AppTypography.bodyLarge.fontSize! > AppTypography.bodyMedium.fontSize!, true);
      expect(AppTypography.bodyMedium.fontSize! > AppTypography.bodySmall.fontSize!, true);
    });
  });

  group('ApiConstants', () {
    test('pddiktiBaseUrl starts with https', () {
      expect(ApiConstants.pddiktiBaseUrl.startsWith('https://'), true);
    });

    test('defaultTimeout is reasonable', () {
      expect(ApiConstants.defaultTimeout.inSeconds, greaterThanOrEqualTo(10));
      expect(ApiConstants.defaultTimeout.inSeconds, lessThanOrEqualTo(60));
    });
  });
}
