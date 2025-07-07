import 'dart:async';
import 'package:flutter/material.dart';
import 'package:autoledger/theme/app_theme.dart';
import 'package:autoledger/screens/auth/login_screen.dart';
import 'package:autoledger/screens/auth/reset_password_screen.dart';
import 'package:autoledger/screens/dashboard/dashboard_screen.dart';
import 'package:autoledger/screens/widgets/customers_widget.dart';
import 'package:autoledger/screens/widgets/invoices_widget.dart';
import 'package:autoledger/screens/widgets/tasks_widget.dart';
import 'package:autoledger/screens/widgets/emails_widget.dart';
import 'package:autoledger/screens/widgets/expenses_widget.dart';
import 'package:autoledger/screens/widgets/reports_widget.dart';
import 'package:autoledger/screens/widgets/ai_insights_widget.dart';
import 'package:autoledger/screens/widgets/analytics_dashboard.dart';
import 'package:autoledger/screens/settings/payment_settings_screen.dart';
import 'package:autoledger/screens/widgets/invoice_detail.dart';
import 'package:autoledger/screens/widgets/contact_detail_screen.dart';
import 'package:autoledger/screens/auth/signup_screen.dart';
import 'package:autoledger/screens/auth/subscription_screen.dart';
import 'package:autoledger/screens/profile_screen.dart';
import 'package:autoledger/screens/widgets/contacts_screen.dart';
import 'package:autoledger/screens/widgets/receipt_scanner.dart';

// New imports for voice overlay
import 'package:autoledger/widgets/voice_slot_overlay.dart';
import 'package:autoledger/utils/voice_event_bus.dart';
import 'package:provider/provider.dart';
import 'providers/session_provider.dart';

class AutoLedgerApp extends StatefulWidget {
  const AutoLedgerApp({Key? key}) : super(key: key);

  @override
  State<AutoLedgerApp> createState() => _AutoLedgerAppState();
}

class _AutoLedgerAppState extends State<AutoLedgerApp> {
  Map<String, dynamic> _currentSlots = {};
  late final StreamSubscription _voiceSub;

  @override
  void initState() {
    super.initState();
    // Subscribe to all voice intent events
    _voiceSub = VoiceEventBus().on<VoiceIntentEvent>().listen((evt) {
      setState(() {
        _currentSlots = evt.slots ?? {};
      });
      // clear after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _currentSlots = {};
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _voiceSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),
      ],
      child: Stack(
        children: [
          MaterialApp(
            title: 'AutoLedger',
            theme: AppTheme.lightTheme,
            initialRoute: '/login',
            routes: {
              '/login':          (_) => const LoginScreen(),
            '/reset-password': (_) => const ResetPasswordScreen(),
            '/dashboard':      (_) => const DashboardScreen(),
            '/customers':      (_) => const CustomersScreen(),
            '/invoices':       (_) => const InvoicesWidget(),
            '/tasks':          (_) => const TasksWidget(),
            '/emails':         (_) => const EmailsWidget(),
            '/expenses':       (_) => const ExpensesWidget(),
            '/reports':        (_) => const ReportsWidget(),
			'/analytics':      (_) => const AnalyticsDashboard(),
            '/insights':       (_) => const AIInsightsWidget(),
            '/settings':       (_) => const PaymentSettingsScreen(),
            '/contacts':       (_) => const ContactsScreen(),
			'/receipt-scan':  (_) => const ReceiptScannerScreen(),
            '/signup':         (_) => const SignUpScreen(),
            '/subscription':   (_) => const SubscriptionScreen(),
            '/profile':        (_) => const ProfileScreen(),
            '/contacts/detail': (ctx) {
              final id = ModalRoute.of(ctx)!.settings.arguments as String;
              return ContactDetailScreen(contactId: id);
            },
            '/invoice/detail': (ctx) {
              final id = ModalRoute.of(ctx)!.settings.arguments as int;
              return InvoiceDetail(invoiceId: id);
            },
          },
        ),
        // Overlay the live voice-slot chips on top of everything
        VoiceSlotOverlay(slots: _currentSlots),
      ],
    ));
  }
}
