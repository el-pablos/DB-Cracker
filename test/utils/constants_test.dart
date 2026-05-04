import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/utils/constants.dart';

void main() {
  group('CtOSColors', () {
    test('primary color is cyan', () {
      expect(CtOSColors.primary.value, 0xFF00E5FF);
    });

    test('background is black', () {
      expect(CtOSColors.background.value, 0xFF000000);
    });

    test('error is red', () {
      expect(CtOSColors.error.value, 0xFFFF1744);
    });

    test('success is green', () {
      expect(CtOSColors.success.value, 0xFF00E676);
    });
  });

  group('HackerColors backward compatibility', () {
    test('primary maps to CtOSColors.primary', () {
      expect(HackerColors.primary, CtOSColors.primary);
    });

    test('background maps to CtOSColors.background', () {
      expect(HackerColors.background, CtOSColors.background);
    });

    test('text maps to CtOSColors.textPrimary', () {
      expect(HackerColors.text, CtOSColors.textPrimary);
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

  group('ApiConstants', () {
    test('pddiktiBaseUrl starts with https', () {
      expect(ApiConstants.pddiktiBaseUrl.startsWith('https://'), true);
    });

    test('defaultTimeout is reasonable', () {
      expect(ApiConstants.defaultTimeout.inSeconds, greaterThanOrEqualTo(10));
      expect(ApiConstants.defaultTimeout.inSeconds, lessThanOrEqualTo(60));
    });
  });

  group('AppTextStyles', () {
    test('fontFamily is Courier', () {
      expect(AppTextStyles.fontFamily, 'Courier');
    });

    test('heading fontSize is 18', () {
      expect(AppTextStyles.heading.fontSize, 18);
    });

    test('body fontSize is 14', () {
      expect(AppTextStyles.body.fontSize, 14);
    });
  });
}
