import 'package:autoledger/screens/auth/login_screen.dart';
import 'package:autoledger/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class TestSessionProvider extends SessionProvider {
  bool loginCalled = false;

  @override
  Future<bool> login(String email, String password, {String tenantId = ''}) async {
    loginCalled = true;
    return true;
  }
}

void main() {
  testWidgets('Login button triggers provider login', (tester) async {
    final provider = TestSessionProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<SessionProvider>.value(
        value: provider,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'pw');
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(provider.loginCalled, isTrue);
  });
}