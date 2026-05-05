import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

class NeoTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final ValueChanged<int>? onTap;

  const NeoTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelLarge.copyWith(fontSize: 12),
        unselectedLabelStyle: AppTypography.labelMedium,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        tabs: tabs
            .map((t) => Tab(
                  height: 34,
                  child: Text(t, maxLines: 1, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
      ),
    );
  }
}
