import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// MedsKai Refresh Indicator
///
/// A styled RefreshIndicator that matches the app's visual identity
///
/// Usage:
/// ```dart
/// AppRefreshIndicator(
///   onRefresh: () async => await controller.refresh(),
///   child: ListView(...),
/// )
/// ```
class AppRefreshIndicator extends StatelessWidget {
  /// Child widget (must be scrollable)
  final Widget child;

  /// Callback when user pulls to refresh
  final Future<void> Function() onRefresh;

  /// Color of the refresh indicator (defaults to primary)
  final Color? color;

  /// Background color of the indicator
  final Color? backgroundColor;

  /// Stroke width of the indicator
  final double strokeWidth;

  /// Displacement of the indicator from top
  final double displacement;

  /// Edge offset for trigger
  final double edgeOffset;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 2.5,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? MedsKaiColors.primary,
      backgroundColor: backgroundColor ?? MedsKaiColors.white,
      strokeWidth: strokeWidth,
      displacement: displacement,
      edgeOffset: edgeOffset,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: child,
    );
  }
}

/// Alternative Sliver-based refresh indicator
class AppSliverRefreshIndicator extends StatelessWidget {
  /// Callback when user pulls to refresh
  final Future<void> Function() onRefresh;

  /// Color of the refresh indicator
  final Color? color;

  /// Background color
  final Color? backgroundColor;

  const AppSliverRefreshIndicator({
    super.key,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: color ?? MedsKaiColors.primary,
        backgroundColor: backgroundColor ?? MedsKaiColors.white,
        child: const SizedBox.shrink(),
      ),
    );
  }
}
