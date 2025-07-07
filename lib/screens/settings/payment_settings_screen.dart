import 'package:flutter/material.dart';
import 'package:autoledger/models/user_tax_settings_model.dart';
import 'package:autoledger/services/setting_service.dart';
import 'package:autoledger/theme/app_theme.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  final SettingsService _settingsService =
      SettingsService(baseUrl: const String.fromEnvironment('API_BASE_URL'));
  late Future<UserTaxSettings?> _futureSettings;

  bool _chargeTaxes = false;
  double _taxPercentage = 0.0;
  String? _userId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _futureSettings = _settingsService.fetchUserTaxSettings();
  }

  void _saveSettings() async {
    setState(() => _isSaving = true);
    final updatedSettings = UserTaxSettings(
	  userId: _userId,
      chargeTaxes: _chargeTaxes,
      taxPercentage: _taxPercentage,
    );

    final success = await _settingsService.updateUserTaxSettings(updatedSettings);
    setState(() => _isSaving = false);

    final snackBar = SnackBar(
      content: Text(success ? 'Settings updated successfully!' : 'Failed to update settings.'),
      backgroundColor: success ? Colors.green : Colors.red,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildContent(UserTaxSettings? settings) {
    if (settings != null) {
      _chargeTaxes = settings.chargeTaxes;
      _taxPercentage = settings.taxPercentage;
      _userId = settings.userId;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Charge Taxes'),
          value: _chargeTaxes,
          onChanged: (value) => setState(() => _chargeTaxes = value),
        ),
        if (_chargeTaxes)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Tax Percentage',
                suffixText: '%',
              ),
              onChanged: (value) =>
                  _taxPercentage = double.tryParse(value) ?? _taxPercentage,
            ),
          ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveSettings,
          child: _isSaving
              ? const CircularProgressIndicator()
              : const Text('Save Settings'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Settings'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<UserTaxSettings?>(
          future: _futureSettings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Failed to load settings.'));
            } else {
              return _buildContent(snapshot.data);
            }
          },
        ),
      ),
    );
  }
}
