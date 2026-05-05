import 'package:flutter/material.dart';

/// Responsive utility for adaptive layouts across screen sizes.
class Responsive {
  Responsive._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  static EdgeInsets screenPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return const EdgeInsets.symmetric(horizontal: 200);
    if (w >= 900) return const EdgeInsets.symmetric(horizontal: 80);
    if (w >= 600) return const EdgeInsets.symmetric(horizontal: 32);
    return const EdgeInsets.symmetric(horizontal: 16);
  }

  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 3;
  }

  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 800;
    if (isTablet(context)) return 600;
    return double.infinity;
  }
}
