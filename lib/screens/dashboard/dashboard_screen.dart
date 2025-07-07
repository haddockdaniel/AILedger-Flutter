import 'package:flutter/material.dart';
import 'package:autoledger/theme/app_theme.dart';
import 'package:autoledger/utils/secure_storage.dart';
import 'package:autoledger/utils/voice_event_bus.dart';
import 'package:autoledger/screens/widgets/voice_assistant.dart';
import 'package:autoledger/screens/widgets/customers_widget.dart';
import 'package:autoledger/screens/widgets/invoices_widget.dart';
import 'package:autoledger/screens/widgets/invoice_detail.dart';
import 'package:autoledger/screens/widgets/tasks_widget.dart';
import 'package:autoledger/screens/widgets/emails_widget.dart';
import 'package:autoledger/screens/widgets/expenses_widget.dart';
import 'package:autoledger/screens/widgets/reports_widget.dart';
import 'package:autoledger/screens/widgets/ai_insights_widget.dart';
import 'package:autoledger/screens/settings/payment_settings_screen.dart';
import 'package:autoledger/screens/widgets/customer_detail.dart';

class DashboardScreen extends StatefulWidget {
  final String initialRoute;
  final Map<String, dynamic>? routeArgs;

  const DashboardScreen(
      {Key? key, this.initialRoute = '/customers', this.routeArgs})
      : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String _currentScreen;
  late Widget _currentWidget;

  @override
  void initState() {
    super.initState();
    _currentScreen = widget.initialRoute;
    _currentWidget = _getScreenWidget(_currentScreen, widget.routeArgs);

    voiceEventBus.stream.listen((event) {
      if (event.intent == 'navigate' && event.targetScreen != null) {
        setState(() {
          _currentScreen = event.targetScreen!;
          _currentWidget = _getScreenWidget(_currentScreen, event.arguments);
        });
      }
    });
  }

  Widget _getScreenWidget(String screen, Map<String, dynamic>? args) {
    switch (screen) {
      case '/customers':
        if (args != null && args.containsKey('customerId')) {
          return CustomerDetail(customerId: args['customerId'].toString());
        }
        return const CustomersWidget();
      case '/invoices':
        if (args != null && args.containsKey('invoiceId')) {
          return InvoiceDetail(invoiceId: args['invoiceId']);
        }
        return const InvoicesWidget();
      case '/tasks':
        return const TasksWidget();
      case '/emails':
        return const EmailsWidget();
      case '/expenses':
        return const ExpensesWidget();
      case '/reports':
        return const ReportsWidget();
      case '/insights':
        return const AIInsightsWidget();
      case '/settings':
        return const PaymentSettingsScreen();
      case '/profile':
        return const ProfileScreen();
      default:
        return const Center(child: Text('Unknown screen'));
    }
  }

  void _handleDrawerNavigation(String route, {Map<String, dynamic>? args}) {
    Navigator.pop(context); // Close drawer
    setState(() {
      _currentScreen = route;
      _currentWidget = _getScreenWidget(route, args);
    });
  }

  Future<void> _handleLogout() async {
    await SecureStorage.clearAll();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Widget _buildDrawerItem(String title, String route) {
    final isSelected = _currentScreen == route;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.accentColor : AppTheme.textPrimary,
        ),
      ),
      selected: isSelected,
      onTap: () => _handleDrawerNavigation(route),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoLedger Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppTheme.primaryColor),
              child: const Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            _buildDrawerItem('Customers', '/customers'),
            _buildDrawerItem('Invoices', '/invoices'),
            _buildDrawerItem('Tasks', '/tasks'),
            _buildDrawerItem('Emails', '/emails'),
            _buildDrawerItem('Expenses', '/expenses'),
            _buildDrawerItem('Reports', '/reports'),
            _buildDrawerItem('Insights', '/insights'),
            _buildDrawerItem('Settings', '/settings'),
			_buildDrawerItem('Profile', '/profile'),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _currentWidget,
          const Align(
            alignment: Alignment.bottomRight,
            child: VoiceAssistant(),
          ),
        ],
      ),
    );
  }
}
