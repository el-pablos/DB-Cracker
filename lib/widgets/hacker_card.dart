import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Custom Card Widget yang konsisten styling-nya di seluruh aplikasi
/// Digunakan sebagai pengganti Card theme yang menimbulkan error
class HackerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  
  const HackerCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation = 0,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.all(8),
      elevation: elevation,
      color: backgroundColor ?? HackerColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: borderColor ?? HackerColors.accent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(12),
          child: child,
        ),
      ),
    );
  }
}