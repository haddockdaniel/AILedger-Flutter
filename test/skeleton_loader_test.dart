import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:autoledger/widgets/skeleton_loader.dart';

void main() {
  testWidgets('SkeletonLoader shows correct number of shimmer items', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SkeletonLoader(itemCount: 3, height: 20)),
    ));

    expect(find.byType(SkeletonLoader), findsOneWidget);
    expect(find.byType(Shimmer), findsNWidgets(3));
  });
}