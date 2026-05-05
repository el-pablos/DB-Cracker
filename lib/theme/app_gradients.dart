import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Neo-Violet Academic gradient definitions.
///
/// Provides reusable gradient presets for backgrounds, cards,
/// overlays, and shimmer effects.
class AppGradients {
  AppGradients._();

  // ─── Primary Gradient (Violet → Cyan, diagonal) ────────────────────────────
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.secondary,
    ],
  );

  // ─── Primary Vertical (Violet → Cyan, top to bottom) ──────────────────────
  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.primary,
      AppColors.secondary,
    ],
  );

  // ─── Surface Gradient (Surface → Background) ──────────────────────────────
  static const LinearGradient surface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.surface,
      AppColors.background,
    ],
  );

  // ─── Card Gradient (SurfaceHigh → Surface, diagonal) ──────────────────────
  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.surfaceHigh,
      AppColors.surface,
    ],
  );

  // ─── Dark Overlay (Transparent → Background) ──────────────────────────────
  static const LinearGradient darkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      AppColors.background,
    ],
  );

  // ─── Shimmer Gradient (Base → Highlight → Base) ────────────────────────────
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.shimmerBase,
      AppColors.shimmerHighlight,
      AppColors.shimmerBase,
    ],
    stops: [0.0, 0.5, 1.0],
  );
}
