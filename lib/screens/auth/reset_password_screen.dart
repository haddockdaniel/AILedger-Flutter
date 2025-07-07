import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:autoledger/theme/app_theme.dart';
import 'package:autoledger/utils/constants.dart';
import '../widgets/error_snackbar.dart';
import '../../widgets/skeleton_loader.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> sendResetLink() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ErrorSnackbar.show(context, 'Enter a valid email address');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/auth/request-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
          ErrorSnackbar.show(context, 'Password reset link sent to your email.');
        Navigator.pop(context);
      } else {
   ErrorSnackbar.show(context, data['message'] ?? 'Failed to send reset link.');
      }
    } catch (e) {
      ErrorSnackbar.show(context, 'Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              'Enter your email to receive a password reset link.',
              style: AppTheme.bodyStyle,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : sendResetLink,
                child: isLoading
                    ? const SkeletonLoader(itemCount: 1, height: 48, margin: EdgeInsets.symmetric(vertical: 8))
                    : const Text('Send Reset Link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
