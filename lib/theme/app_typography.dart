import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Neo-Violet Academic typography system.
///
/// Uses JetBrains Mono for display/code elements and Inter for body text,
/// creating a technical-academic aesthetic.
class AppTypography {
  AppTypography._();

  // ─── Font Families ─────────────────────────────────────────────────────────
  static const String fontDisplay = 'JetBrainsMono';
  static const String fontBody = 'Inter';
  static const String fontCode = 'JetBrainsMono';

  // ─── Display Styles (JetBrains Mono) ───────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  // ─── Headline Styles (Inter) ───────────────────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ─── Body Styles (Inter) ───────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  // ─── Label Styles (Inter) ──────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  // ─── Code Styles (JetBrains Mono) ─────────────────────────────────────────
  static const TextStyle codeLarge = TextStyle(
    fontFamily: fontCode,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  static const TextStyle codeMedium = TextStyle(
    fontFamily: fontCode,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  static const TextStyle codeSmall = TextStyle(
    fontFamily: fontCode,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  // ─── Material 3 TextTheme ──────────────────────────────────────────────────
  static TextTheme get textTheme => const TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
        titleLarge: headlineLarge,
        titleMedium: headlineMedium,
        titleSmall: headlineSmall,
      );
}
