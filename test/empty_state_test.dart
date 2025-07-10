import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autoledger/widgets/empty_state.dart';

void main() {
  testWidgets('EmptyState displays text and button calls handler', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: EmptyState(
        assetPath: 'lib/assets/images/logo.png',
        title: 'Nothing here',
        subtitle: 'Add items to continue',
        buttonText: 'Add',
        onButtonPressed: () => tapped = true,
      ),
    ));

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Add items to continue'), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(tapped, isTrue);
  });
}