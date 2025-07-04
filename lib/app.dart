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
import 'package:autoledger/screens/widgets/payment_settings_screen.dart';
import 'package:autoledger/screens/widgets/invoice_detail.dart';
import 'package:autoledger/screens/widgets/contact_detail_screen.dart';
import 'package:autoledger/screens/widgets/signup_screen.dart';
import 'package:autoledger/screens/widgets/subscription_screen.dart';
import 'package:autoledger/screens/widgets/profile_screen.dart';

// New imports for voice overlay
import 'package:autoledger/widgets/voice_slot_overlay.dart';
import 'package:autoledger/utils/voice_event_bus.dart';

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
    return Stack(
      children: [
        MaterialApp(
          title: 'AutoLedger',
          theme: AppTheme.light,
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
            '/insights':       (_) => const AiInsightsWidget(),
            '/settings':       (_) => const PaymentSettingsScreen(),
            '/contacts':       (_) => const CustomersScreen(),
            '/signup':         (_) => const SignUpScreen(),
            '/subscription':   (_) => const SubscriptionScreen(),
            '/profile':        (_) => const ProfileScreen(),
            '/contacts/detail': (ctx) {
              final id = ModalRoute.of(ctx)!.settings.arguments as String;
              return ContactDetailScreen(contactId: id);
            },
            '/invoice/detail': (ctx) {
              final invoice = ModalRoute.of(ctx)!.settings.arguments as Invoice;
              return InvoiceDetail(invoice: invoice);
            },
          },
        ),
        // Overlay the live voice-slot chips on top of everything
        VoiceSlotOverlay(slots: _currentSlots),
      ],
    );
  }
}
