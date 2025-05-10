import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/screen_utils.dart';

/// Card yang menyesuaikan ukuran secara otomatis untuk mencegah overflow
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double? minHeight;
  final double? maxHeight;
  final bool hoverable;
  final VoidCallback? onTap;
  
  const ResponsiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.minHeight,
    this.maxHeight,
    this.hoverable = false,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Pastikan ScreenUtils diinisialisasi
    if (ScreenUtils.screenWidth == 0) {
      ScreenUtils.init(context);
    }
    
    final bool isMobile = ScreenUtils.isMobileScreen();
    
    // Sesuaikan padding berdasarkan ukuran layar - dengan nilai default yang aman
    final double safePadding = isMobile ? 8.0 : 12.0;
    final effectivePadding = padding ?? EdgeInsets.all(safePadding);
    
    // Sesuaikan margin berdasarkan ukuran layar - dengan nilai default yang aman
    final double safeMarginVertical = isMobile ? 4.0 : 6.0;
    final double safeMarginHorizontal = isMobile ? 6.0 : 8.0;
    final effectiveMargin = margin ?? EdgeInsets.symmetric(
      vertical: safeMarginVertical, 
      horizontal: safeMarginHorizontal
    );
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: onTap == null ? Colors.transparent : null,
        highlightColor: onTap == null ? Colors.transparent : null,
        child: Container(
          margin: effectiveMargin,
          constraints: BoxConstraints(
            minHeight: minHeight?.h ?? 0,
            maxHeight: maxHeight?.h ?? double.infinity,
          ),
          decoration: BoxDecoration(
            color: color ?? HackerColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: borderColor ?? HackerColors.accent,
              width: isMobile ? 0.5 : 1.0,
            ),
            boxShadow: hoverable ? [
              BoxShadow(
                color: HackerColors.primary.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 0,
                offset: Offset(0, 2),
              )
            ] : null,
          ),
          child: Padding(
            padding: effectivePadding,
            child: child,
          ),
        ),
      ),
    );
  }
}