import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

enum NeoBadgeVariant { success, warning, error, info, neutral }

class NeoBadge extends StatelessWidget {
  final String label;
  final NeoBadgeVariant variant;
  final IconData? icon;

  const NeoBadge({
    super.key,
    required this.label,
    this.variant = NeoBadgeVariant.neutral,
    this.icon,
  });

  Color get _color {
    switch (variant) {
      case NeoBadgeVariant.success:
        return AppColors.success;
      case NeoBadgeVariant.warning:
        return AppColors.warning;
      case NeoBadgeVariant.error:
        return AppColors.error;
      case NeoBadgeVariant.info:
        return AppColors.info;
      case NeoBadgeVariant.neutral:
        return AppColors.textSecondary;
    }
  }

  Color get _bgColor {
    switch (variant) {
      case NeoBadgeVariant.success:
        return AppColors.successSurface;
      case NeoBadgeVariant.warning:
        return AppColors.warningSurface;
      case NeoBadgeVariant.error:
        return AppColors.errorSurface;
      case NeoBadgeVariant.info:
        return AppColors.infoSurface;
      case NeoBadgeVariant.neutral:
        return AppColors.surfaceHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: _color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: _color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
