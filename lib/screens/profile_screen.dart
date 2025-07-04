import 'package:flutter/material.dart';
import 'package:autoledger/models/user_model.dart';
import 'package:autoledger/services/auth_service.dart';
import 'package:autoledger/services/payment_service.dart';
import 'package:autoledger/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> _futureUser;
  bool _updating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _futureUser = UserService.fetchUserProfile();
  }

  Future<void> _cancelSubscription(String subscriptionId) async {
    setState(() => _updating = true);
    try {
      await PaymentService.cancelSubscription(subscriptionId);
      setState(() => _error = null);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Subscription canceled')));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: FutureBuilder<User>(
        future: _futureUser,
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final user = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              TextFormField(
                initialValue: user.name,
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (v) => user.name = v,
              ),
              TextFormField(
                initialValue: user.companyName,
                decoration: const InputDecoration(labelText: 'Company'),
                onChanged: (v) => user.companyName = v,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updating
                    ? null
                    : () async {
                        setState(() => _updating = true);
                        await UserService.updateUserProfile(user);
                        setState(() => _updating = false);
                      },
                child: _updating
                    ? const CircularProgressIndicator()
                    : const Text('Save Profile'),
              ),
              const Divider(height: 32),
              ElevatedButton(
                onPressed: () => AuthService.resetPassword(user.email),
                child: const Text('Change Password'),
              ),
              const Divider(height: 32),
              if (user.subscriptionId != null) ...[
                Text('Subscription: ${user.subscriptionStatus}'),
                const SizedBox(height: 8),
                if (user.subscriptionStatus == 'ACTIVE')
                  ElevatedButton(
                    onPressed: _updating
                        ? null
                        : () => _cancelSubscription(user.subscriptionId!),
                    child: const Text('Cancel Subscription'),
                  ),
              ],
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
            ]),
          );
        },
      ),
    );
  }
}
