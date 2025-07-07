import 'package:flutter/material.dart';
import 'package:autoledger/models/user_tax_settings_model.dart';
import 'package:autoledger/services/setting_service.dart';
import 'package:autoledger/theme/app_theme.dart';
import '../widgets/skeleton_loader.dart';

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
   String _currency = 'USD';
  String _region = 'US';
  String? _userId;
  bool _isSaving = false;

  static const List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD'
  ];

  static const List<String> _regions = [
    'US',
    'CA',
    'GB',
    'EU',
    'JP',
    'AU'
  ];

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
	  currency: _currency,
      region: _region,
    );

    final success = await _settingsService.updateUserTaxSettings(updatedSettings);
    setState(() => _isSaving = false);

    final snackBar = SnackBar(
      content: Text(
        success ? 'Settings updated successfully!' : 'Failed to update settings.',
        style: AppTheme.bodyStyle.copyWith(color: Colors.white),
      ),
      backgroundColor: success ? Colors.green : AppTheme.accentColor,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildContent(UserTaxSettings? settings) {
    if (settings != null) {
      _chargeTaxes = settings.chargeTaxes;
      _taxPercentage = settings.taxPercentage;
      _userId = settings.userId;
      _currency = settings.currency;
      _region = settings.region;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Charge Taxes'),
          value: _chargeTaxes,
          onChanged: (value) => setState(() => _chargeTaxes = value),
        ),
		        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: DropdownButtonFormField<String>(
            value: _currency,
            decoration: const InputDecoration(labelText: 'Currency'),
            items: _currencies
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _currency = v ?? _currency),
          ),
        ),
        if (_chargeTaxes)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: DropdownButtonFormField<String>(
              value: _region,
              decoration: const InputDecoration(labelText: 'Region'),
              items: _regions
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _region = v ?? _region),
            ),
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
              ? const SkeletonLoader(itemCount: 1, height: 48, margin: EdgeInsets.symmetric(vertical: 8))
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<UserTaxSettings?>(
          future: _futureSettings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: SkeletonLoader());
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
