import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class NeoSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const NeoSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  factory NeoSkeleton.card() => const NeoSkeleton(
        width: double.infinity,
        height: 120,
        borderRadius: 12,
      );

  factory NeoSkeleton.circle({double size = 40}) => NeoSkeleton(
        width: size,
        height: size,
        borderRadius: size / 2,
      );

  factory NeoSkeleton.text({double? width}) => NeoSkeleton(
        width: width,
        height: 14,
        borderRadius: 4,
      );

  @override
  State<NeoSkeleton> createState() => _NeoSkeletonState();
}

class _NeoSkeletonState extends State<NeoSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            colors: const [
              AppColors.shimmerBase,
              AppColors.shimmerHighlight,
              AppColors.shimmerBase,
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment(_ctrl.value * 3 - 1, 0),
            end: Alignment(_ctrl.value * 3, 0),
          ),
        ),
      ),
    );
  }
}
