import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/skeleton_loader.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final int itemCount;
  final double height;

  const LoadingIndicator({super.key, this.message, this.itemCount = 3, this.height = 60});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
		mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: itemCount * height,
            width: double.infinity,
            child: SkeletonLoader(itemCount: itemCount, height: height, margin: EdgeInsets.zero),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTheme.bodyStyle,
            ),
          ],
        ],
      ),
    );
  }
}
