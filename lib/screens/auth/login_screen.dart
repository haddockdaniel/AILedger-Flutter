import 'package:autoledger/theme/app_theme.dart';
import 'package:autoledger/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/skeleton_loader.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _tenantController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final tenant = _tenantController.text.trim();
	
    final success = await context.read<SessionProvider>().login(
      email,
      password,
      tenantId: tenant,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  void _resetPassword() {
    // Navigate to reset password screen or implement inline
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reset password not implemented yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
 Image.asset('lib/assets/images/logo.png', height: 100),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
			                TextField(
                controller: _tenantController,
                decoration: const InputDecoration(labelText: 'Tenant ID'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              Consumer<SessionProvider>(
                builder: (_, session, __) {
                  return Column(
                    children: [
                      if (session.errorMessage != null)
                        Text(
                          session.errorMessage!,
                          style: AppTheme.bodyStyle.copyWith(color: Colors.red),
                        ),
                      const SizedBox(height: 12),
                      session.isLoading
                          ? const SkeletonLoader(itemCount: 4, height: 48, margin: EdgeInsets.symmetric(vertical: 8))
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                child: const Text('Login'),
                              ),
                            ),
                    ],
                  );
                },
              ),
			  const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: Text(
                  "Don't have an account? Sign Up",
                  style: AppTheme.bodyStyle.copyWith(
                    decoration: TextDecoration.underline,
                    color: AppTheme.accentColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/reset-password');
                },
                child: Text('Forgot Password?', style: AppTheme.bodyStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
