import 'package:flutter/material.dart';
import 'package:autoledger/services/auth_service.dart';
import 'package:autoledger/services/payment_service.dart';
import 'package:autoledger/utils/constants.dart';
import 'package:autoledger/utils/secure_storage.dart';
import 'package:autoledger/theme/app_theme.dart';
import '../../widgets/skeleton_loader.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '', _tenantId = '';
  bool _loading = false;
  String? _error;

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      // 1) create user
      final userId = await AuthService.signUp(_email.trim(), _password, tenantId: _tenantId);
      if (_tenantId.isNotEmpty) {
        await SecureStorage.saveTenantId(_tenantId);
      }
      // 2) create subscription and get approval URL
      final approvalUrl = await PaymentService.createSubscription(
        planId: '19usd_monthly',
        returnUrl: '${apiBaseUrl}/api/payments/execute-subscription?userId=$userId',
        cancelUrl: '$apiBaseUrl/api/payments/cancel-subscription?userId=$userId',
        userId: userId,
      );
      // 3) open PayPal WebView
      Navigator.pushReplacementNamed(context, '/subscription', arguments: approvalUrl);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) => _email = v,
              validator: (v) =>
                  v != null && v.contains('@') ? null : 'Enter valid email',
            ),
			TextFormField(
              decoration: const InputDecoration(labelText: 'Tenant ID'),
              onChanged: (v) => _tenantId = v,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (v) => _password = v,
              validator: (v) => v != null && v.length >= 6
                  ? null
                  : 'Min 6 characters',
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(
                _error!,
                style: AppTheme.bodyStyle.copyWith(color: Colors.red),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _loading
                    ? const SkeletonLoader(itemCount: 2, height: 48, margin: EdgeInsets.symmetric(vertical: 8))
                    : const Text('Continue to Payment'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
