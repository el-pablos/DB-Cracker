import 'package:flutter/material.dart';

/// Utility class untuk responsive design yang beneran jalan
/// Harus panggil init(context) di build() sebelum pake method lain
class ScreenUtils {
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double blockSizeHorizontal = 0;
  static double blockSizeVertical = 0;

  static const double maxFontSize = 24.0;
  static const double maxIconSize = 48.0;

  /// Inisialisasi dengan MediaQuery dari context
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }

  /// Cek apakah layar mobile (< 600px)
  static bool isMobileScreen() => screenWidth > 0 && screenWidth < 600;

  /// Cek apakah layar tablet (600-1024px)
  static bool isTabletScreen() => screenWidth >= 600 && screenWidth < 1024;

  /// Cek apakah layar desktop (>= 1024px)
  static bool isDesktopScreen() => screenWidth >= 1024;

  /// Scale factor berdasarkan ukuran layar
  static double getScaleFactor() {
    if (screenWidth <= 0) return 1.0;
    if (screenWidth < 360) return 0.8;
    if (screenWidth < 600) return 1.0;
    if (screenWidth < 1024) return 1.2;
    return 1.4;
  }

  /// Font size yang di-clamp antara min dan max
  static double sp(double size) {
    final scaled = size * getScaleFactor();
    return scaled.clamp(8.0, maxFontSize);
  }

  /// Icon size yang di-clamp
  static double iconSize(double size) {
    return size.clamp(12.0, maxIconSize);
  }

  /// Adaptive font size
  static double getAdaptiveFontSize(double size) {
    return size.clamp(8.0, maxFontSize);
  }

  /// Responsive padding helper
  static EdgeInsets responsivePadding({
    double all = 0,
    double horizontal = 0,
    double vertical = 0,
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    if (all > 0) return EdgeInsets.all(all);
    if (horizontal > 0 || vertical > 0) {
      return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
    }
    return EdgeInsets.only(
      left: left > 0 ? left : horizontal,
      top: top > 0 ? top : vertical,
      right: right > 0 ? right : horizontal,
      bottom: bottom > 0 ? bottom : vertical,
    );
  }
}

/// Extension buat num supaya bisa pake .w, .h, .sp langsung
extension SizeExtension on num {
  double get w => toDouble() * (ScreenUtils.screenWidth > 0 ? ScreenUtils.screenWidth / 375 : 1.0);
  double get h => toDouble() * (ScreenUtils.screenHeight > 0 ? ScreenUtils.screenHeight / 812 : 1.0);
  double get sp => ScreenUtils.sp(toDouble());
  double get iconSize => ScreenUtils.iconSize(toDouble());
  double get adaptiveFont => ScreenUtils.getAdaptiveFontSize(toDouble());
}
