import 'package:flutter/material.dart';
import 'package:autoledger/app_theme.dart';
import 'package:autoledger/app.dart';
import 'package:autoledger/screens/login_screen.dart';
import 'package:autoledger/screens/reset_password_screen.dart';
import 'package:autoledger/screens/dashboard_screen.dart';

void main() {
  runApp(const AppWithVoiceOverlay());
}

class AutoLedgerApp extends StatelessWidget {
  const AutoLedgerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoLedger',
      theme: AppTheme.themeData,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return DashboardScreen(
              initialRoute: args['route'] ?? '/customers',
              routeArgs: args['args'],
            );
          }
          return const DashboardScreen();
        },
      },
    );
  }
}
