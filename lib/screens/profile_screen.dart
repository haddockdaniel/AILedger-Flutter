import 'package:flutter/material.dart';
import 'package:autoledger/models/user_model.dart';
import 'package:autoledger/services/auth_service.dart';
import 'package:autoledger/services/payment_service.dart';
import 'package:autoledger/services/user_service.dart';
import 'package:autoledger/theme/app_theme.dart';
import 'dart:typed_data';
import '../widgets/skeleton_loader.dart';
import '../widgets/logo_generator_dialog.dart';
import '../services/logo_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> _futureUser;
  bool _updating = false;
  String? _error;

  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _controllersInitialized = false;
  Uint8List? _logoImage;

  @override
  void initState() {
    super.initState();
    _futureUser = UserService.fetchUserProfile();
    _loadLogo();
  }

  Future<void> _loadLogo() async {
    _logoImage = await LogoService.getLogo();
    if (mounted) setState(() {});
  }
    Future<void> _uploadLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    await LogoService.saveLogo(bytes);
    setState(() => _logoImage = bytes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
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

  Future<void> _showLogoGenerator() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoGeneratorDialog(),
    );
    if (result == true) {
      await _loadLogo();
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: FutureBuilder<User>(
        future: _futureUser,
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: SkeletonLoader());
          }
          final user = snap.data!;
		            if (!_controllersInitialized) {
            _nameController.text = user.name;
            _companyController.text = user.companyName ?? '';
            _emailController.text = user.email;
            _phoneController.text = user.phone ?? '';
            _addressController.text = user.address ?? '';
            _controllersInitialized = true;
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _companyController,
                    decoration: const InputDecoration(labelText: 'Company'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                  ),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updating
                        ? null
                        : () async {
                            setState(() { _updating = true; _error = null; });
                            try {
                              final newEmail = _emailController.text.trim();
                              if (newEmail != user.email) {
                                final exists = await UserService.emailExists(newEmail);
                                if (exists) {
                                  setState(() {
                                    _error = 'This email already exists. Please use a different email or cancel.';
                                    _updating = false;
                                  });
                                  return;
                                }
                              }

                              final updatedUser = User(
                                id: user.id,
                                name: _nameController.text.trim(),
                                companyName: _companyController.text.trim().isEmpty
                                    ? null
                                    : _companyController.text.trim(),
                                email: newEmail,
                                phone: _phoneController.text.trim().isEmpty
                                    ? null
                                    : _phoneController.text.trim(),
                                address: _addressController.text.trim().isEmpty
                                    ? null
                                    : _addressController.text.trim(),
                              );
                              await UserService.updateUserProfile(updatedUser);
                              setState(() { _error = null; });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile updated')),
                              );
                            } on EmailAlreadyExistsException {
                              setState(() => _error = 'This email already exists. Please use a different email or cancel.');
                            } catch (e) {
                              setState(() => _error = e.toString());
                            } finally {
                              setState(() => _updating = false);
                            }
                          },
                    child: _updating
                        ? const SkeletonLoader(itemCount: 1, height: 48, margin: EdgeInsets.symmetric(vertical: 8))
                        : const Text('Save Profile'),
                  ),
                  const SizedBox(height: 12),
                  if (_logoImage != null)
                    Column(
                      children: [
                        Image.memory(_logoImage!, height: 80),
                        const SizedBox(height: 8),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _uploadLogo,
                        child: const Text('Upload Logo'),
                      ),
                      ElevatedButton(
                        onPressed: _showLogoGenerator,
                        child: const Text('Use AI to create your logo'),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  ElevatedButton(
                    onPressed: () => AuthService.resetPassword(user.email),
                    child: const Text('Change Password'),
                  ),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: context.watch<ThemeProvider>().mode == ThemeMode.dark,
                    onChanged: (val) => context
                        .read<ThemeProvider>()
                        .setDarkMode(val),
                  ),
                  const Divider(height: 32),
              if (user.subscriptionId != null) ...[
                Text('Subscription: ${user.subscriptionStatus}',
                    style: AppTheme.bodyStyle),
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
                    Text(
                      _error!,
                      style:
                          AppTheme.bodyStyle.copyWith(color: AppTheme.errorColor),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
