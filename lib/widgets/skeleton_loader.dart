import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: height,
            width: double.infinity,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
