import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Neo-Violet Academic spacing, radius, shadow, and animation system.
///
/// Provides a consistent spatial rhythm across the entire application.
class AppSpacing {
  AppSpacing._();

  // ─── Spacing Scale ─────────────────────────────────────────────────────────
  static const double xs2 = 2;
  static const double xs = 4;
  static const double sm2 = 6;
  static const double sm = 8;
  static const double sm3 = 10;
  static const double md2 = 12;
  static const double md = 16;
  static const double lg2 = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double xl2 = 40;
  static const double xl3 = 48;
  static const double xl4 = 56;
  static const double xl5 = 64;

  // ─── Padding Presets ───────────────────────────────────────────────────────
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg2,
  );

  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md2,
  );

  // ─── Border Radius Values ──────────────────────────────────────────────────
  static const double radiusXs = 4;
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radius2xl = 20;
  static const double radiusFull = 999;

  // ─── BorderRadius Constants ────────────────────────────────────────────────
  static const BorderRadius borderRadiusXs =
      BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderRadiusSm =
      BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd =
      BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg =
      BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl =
      BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadius2xl =
      BorderRadius.all(Radius.circular(radius2xl));
  static const BorderRadius borderRadiusFull =
      BorderRadius.all(Radius.circular(radiusFull));

  // ─── Shadows ───────────────────────────────────────────────────────────────
  static const List<BoxShadow> shadowNone = [];

  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowGlow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.3),
      blurRadius: 16,
      spreadRadius: 2,
      offset: const Offset(0, 0),
    ),
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.1),
      blurRadius: 32,
      spreadRadius: 4,
      offset: const Offset(0, 0),
    ),
  ];

  // ─── Animation Durations ───────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);

  // ─── Breakpoints ───────────────────────────────────────────────────────────
  static const double breakpointSm = 360;
  static const double breakpointMd = 400;
  static const double breakpointLg = 600;
  static const double breakpointXl = 900;
}
