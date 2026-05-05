import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_gradients.dart';

enum NeoCardVariant { flat, elevated, gradient, outlined }

class NeoCard extends StatelessWidget {
  final Widget child;
  final NeoCardVariant variant;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final VoidCallback? onTap;

  const NeoCard({
    super.key,
    required this.child,
    this.variant = NeoCardVariant.flat,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.radiusLg;

    final decoration = BoxDecoration(
      color: variant == NeoCardVariant.gradient
          ? null
          : variant == NeoCardVariant.elevated
              ? AppColors.surfaceHigh
              : AppColors.surface,
      gradient: variant == NeoCardVariant.gradient ? AppGradients.card : null,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border, width: 1),
      boxShadow: variant == NeoCardVariant.elevated
          ? AppSpacing.shadowMd
          : AppSpacing.shadowNone,
    );

    Widget card = Container(
      margin: margin,
      decoration: decoration,
      child: Padding(
        padding: padding ?? AppSpacing.cardPadding,
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: AppColors.primary.withOpacity(0.08),
          highlightColor: AppColors.primary.withOpacity(0.04),
          child: card,
        ),
      );
    }
    return card;
  }
}
