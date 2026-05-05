import 'package:flutter/material.dart';

/// Neo-Violet Academic color palette.
///
/// All colors are defined as static constants to enable tree-shaking
/// and compile-time const usage throughout the app.
class AppColors {
  AppColors._();

  // ─── Primary ───────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF6D28D9);

  // ─── Secondary ─────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryLight = Color(0xFF22D3EE);
  static const Color secondaryDark = Color(0xFF0891B2);

  // ─── Background & Surface ──────────────────────────────────────────────────
  static const Color background = Color(0xFF0F0F23);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceHigh = Color(0xFF252547);
  static const Color surfaceHighest = Color(0xFF2F2F5C);

  // ─── Border & Divider ──────────────────────────────────────────────────────
  static const Color border = Color(0xFF2E2E52);
  static const Color borderLight = Color(0xFF3D3D6B);
  static const Color divider = Color(0xFF1F1F3D);

  // ─── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF475569);
  static const Color textInverse = Color(0xFF0F172A);

  // ─── Semantic: Success ─────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successSurface = Color(0xFF052E16);

  // ─── Semantic: Warning ─────────────────────────────────────────────────────
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningSurface = Color(0xFF422006);

  // ─── Semantic: Error ───────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorSurface = Color(0xFF450A0A);

  // ─── Semantic: Info ────────────────────────────────────────────────────────
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoSurface = Color(0xFF172554);

  // ─── Special ───────────────────────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFF1A1A2E);
  static const Color shimmerHighlight = Color(0xFF252547);
  static const Color overlay = Color(0xCC0F0F23);

  // ─── Material 3 ColorScheme ────────────────────────────────────────────────
  static ColorScheme get colorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: textPrimary,
        primaryContainer: primaryDark,
        onPrimaryContainer: primaryLight,
        secondary: secondary,
        onSecondary: textInverse,
        secondaryContainer: secondaryDark,
        onSecondaryContainer: secondaryLight,
        tertiary: primaryLight,
        onTertiary: textInverse,
        tertiaryContainer: surfaceHighest,
        onTertiaryContainer: textPrimary,
        error: error,
        onError: textPrimary,
        errorContainer: errorSurface,
        onErrorContainer: errorLight,
        surface: surface,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceHighest,
        onSurfaceVariant: textSecondary,
        outline: border,
        outlineVariant: borderLight,
        shadow: Colors.black,
        scrim: overlay,
        inverseSurface: textPrimary,
        onInverseSurface: textInverse,
        inversePrimary: primaryDark,
      );
}
