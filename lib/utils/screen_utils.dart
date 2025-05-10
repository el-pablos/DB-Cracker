import 'package:flutter/material.dart';

/// Utility class untuk mengatur responsivitas UI dan mencegah overflow
class ScreenUtils {
  static MediaQueryData? _mediaQueryData;
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double blockSizeHorizontal = 0;
  static double blockSizeVertical = 0;
  static double _safeAreaHorizontal = 0;
  static double _safeAreaVertical = 0;
  static double safeBlockHorizontal = 0;
  static double safeBlockVertical = 0;
  static double textScaleFactor = 1.0;
  
  // Batasan ukuran untuk mencegah overflow
  static const double MAX_FONT_SIZE = 24.0;
  static const double MAX_ICON_SIZE = 48.0;

  /// Inisialisasi ScreenUtils dengan context saat ini
  static void init(BuildContext context) {
    try {
      _mediaQueryData = MediaQuery.of(context);
      if (_mediaQueryData != null) {
        screenWidth = _mediaQueryData!.size.width;
        screenHeight = _mediaQueryData!.size.height;
        blockSizeHorizontal = screenWidth / 100;
        blockSizeVertical = screenHeight / 100;

        _safeAreaHorizontal = _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;
        _safeAreaVertical = _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;
        safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
        safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
        textScaleFactor = _mediaQueryData!.textScaleFactor;
      }
    } catch (e) {
      print('Error initializing ScreenUtils: $e');
      // Default values
      screenWidth = 360;
      screenHeight = 640;
      blockSizeHorizontal = 3.6;
      blockSizeVertical = 6.4;
      safeBlockHorizontal = 3.6;
      safeBlockVertical = 6.4;
      textScaleFactor = 1.0;
    }
  }

  /// Mengembalikan ukuran relatif terhadap lebar layar dengan batasan
  static double w(double width) {
    // Prevent division by zero
    if (blockSizeHorizontal == 0) return width;
    
    double size = blockSizeHorizontal * width;
    // Error checking
    return (size.isFinite && !size.isNaN) ? size : width;
  }

  /// Mengembalikan ukuran relatif terhadap tinggi layar dengan batasan
  static double h(double height) {
    // Prevent division by zero
    if (blockSizeVertical == 0) return height;
    
    double size = blockSizeVertical * height;
    // Error checking
    return (size.isFinite && !size.isNaN) ? size : height;
  }

  /// Skala font sesuai ukuran layar dengan batasan maksimum
  static double sp(double size) {
    if (textScaleFactor == 0) return size;
    
    double scaledSize = size * textScaleFactor;
    // Membatasi ukuran font untuk mencegah overflow
    double clampedSize = scaledSize.clamp(0.0, MAX_FONT_SIZE);
    return clampedSize.isFinite ? clampedSize : size;
  }
  
  /// Ukuran ikon dengan batasan maksimum
  static double iconSize(double size) {
    if (textScaleFactor == 0) return size;
    
    double scaledSize = size * textScaleFactor;
    // Membatasi ukuran ikon untuk mencegah overflow
    double clampedSize = scaledSize.clamp(0.0, MAX_ICON_SIZE);
    return clampedSize.isFinite ? clampedSize : size;
  }
  
  /// Menentukan apakah layar berukuran kecil (mobile)
  static bool isMobileScreen() {
    return screenWidth < 600;
  }
  
  /// Menentukan apakah layar berukuran tablet
  static bool isTabletScreen() {
    return screenWidth >= 600 && screenWidth < 1200;
  }
  
  /// Menentukan apakah layar berukuran desktop
  static bool isDesktopScreen() {
    return screenWidth >= 1200;
  }
  
  /// Mendapatkan orientasi layar
  static bool isLandscape() {
    return _mediaQueryData?.orientation == Orientation.landscape;
  }
  
  /// Mendapatkan faktor skala yang sesuai berdasarkan lebar layar
  static double getScaleFactor() {
    if (screenWidth < 320) return 0.7;  // Perangkat sangat kecil
    if (screenWidth < 400) return 0.8;  // Perangkat kecil
    if (screenWidth < 600) return 0.9;  // Smartphone standar
    if (screenWidth < 900) return 1.0;  // Tablet kecil
    if (screenWidth < 1200) return 1.1; // Tablet besar
    return 1.2;                         // Desktop
  }
  
  /// Membuat ukuran padding yang responsif dan aman
  static EdgeInsets responsivePadding({
    double horizontal = 0.0,
    double vertical = 0.0,
    double all = 0.0,
    double left = 0.0,
    double right = 0.0,
    double top = 0.0, 
    double bottom = 0.0
  }) {
    if (all > 0) {
      return EdgeInsets.all(w(all));
    }
    
    return EdgeInsets.fromLTRB(
      left > 0 ? w(left) : horizontal > 0 ? w(horizontal) : 0.0,
      top > 0 ? h(top) : vertical > 0 ? h(vertical) : 0.0,
      right > 0 ? w(right) : horizontal > 0 ? w(horizontal) : 0.0,
      bottom > 0 ? h(bottom) : vertical > 0 ? h(vertical) : 0.0
    );
  }
  
  /// Mendapatkan font size yang aman berdasarkan ukuran layar
  static double getAdaptiveFontSize(double size) {
    double scaleFactor = getScaleFactor();
    return (size * scaleFactor).clamp(8.0, MAX_FONT_SIZE);
  }
}

/// Extension untuk memudahkan penggunaan
extension SizeExtension on num {
  double get w => ScreenUtils.w(this.toDouble());
  double get h => ScreenUtils.h(this.toDouble());
  double get sp => ScreenUtils.sp(this.toDouble());
  double get iconSize => ScreenUtils.iconSize(this.toDouble());
  double get adaptiveFont => ScreenUtils.getAdaptiveFontSize(this.toDouble());
}