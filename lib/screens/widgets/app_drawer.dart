import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/secure_storage.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/settings/payment_settings_screen.dart';

class AppDrawer extends StatelessWidget {
  final Function(String route)? onNavigate;

  const AppDrawer({super.key, this.onNavigate});

  void _logout(BuildContext context) async {
    await SecureStorage.clearAll();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 30),
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primaryColor),
            child: Center(
              child: Text(
                'AutoLedger',
                style: AppTheme.headerStyle.copyWith(color: Colors.white),
              ),
            ),
          ),
          _buildNavTile(
            context,
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: '/dashboard',
          ),
          _buildNavTile(
            context,
            icon: Icons.people,
            label: 'Customers',
            route: '/customers',
          ),
          _buildNavTile(
            context,
            icon: Icons.receipt_long,
            label: 'Invoices',
            route: '/invoices',
          ),
          _buildNavTile(
            context,
            icon: Icons.task,
            label: 'Tasks',
            route: '/tasks',
          ),
          _buildNavTile(
            context,
            icon: Icons.email,
            label: 'Emails',
            route: '/emails',
          ),
          _buildNavTile(
            context,
            icon: Icons.money_off,
            label: 'Expenses',
            route: '/expenses',
          ),
		    _buildNavTile(
            context,
            icon: Icons.camera_alt,
            label: 'Scan Receipt',
            route: '/receipt-scan',
          ),
          _buildNavTile(
            context,
            icon: Icons.bar_chart,
            label: 'Reports',
            route: '/reports',
          ),
          _buildNavTile(
            context,
            icon: Icons.insights,
            label: 'AI Insights',
            route: '/ai-insights',
          ),
          _buildNavTile(
            context,
            icon: Icons.settings,
            label: 'Payment Settings',
            route: '/payment-settings',
          ),
          _buildNavTile(
            context,
            icon: Icons.settings,
            label: 'Contacts',
            route: '/Contacts',
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(BuildContext context,
      {required IconData icon,
      required String label,
      required String route}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: AppTheme.bodyStyle),
      onTap: () {
        Navigator.pop(context);
        if (onNavigate != null) {
          onNavigate!(route);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}
