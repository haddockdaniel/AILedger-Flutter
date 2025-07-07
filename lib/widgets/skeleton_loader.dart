import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

/// A vertical list of grey bars to indicate loading state.
class SkeletonLoader extends StatelessWidget {
  final int itemCount;
  final double height;
  final EdgeInsetsGeometry margin;

  const SkeletonLoader({
    Key? key,
    this.itemCount = 6,
    this.height = 60,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => Padding(
        padding: margin,
        child: Shimmer.fromColors(
          baseColor: AppTheme.borderColor.withOpacity(0.5),
          highlightColor: AppTheme.borderColor.withOpacity(0.2),
          child: Container(
            height: height,
            width: double.infinity,
            color: AppTheme.surfaceColor,
          ),
        ),
      ),
    );
  }
}
