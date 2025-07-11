import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/voice_settings_provider.dart';
import '../../theme/app_theme.dart';
import '../widgets/skeleton_loader.dart';

class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({Key? key}) : super(key: key);

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  String _newPhrase = '';
  String _newIntent = '';
  bool _saving = false;

  Future<void> _addCommand(VoiceSettingsProvider provider) async {
    if (_newPhrase.trim().isEmpty || _newIntent.trim().isEmpty) return;
    setState(() => _saving = true);
    await provider.addCustomCommand(_newPhrase.trim(), _newIntent.trim());
    setState(() {
      _newPhrase = '';
      _newIntent = '';
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VoiceSettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Enable Voice Commands'),
              value: provider.isEnabled,
              onChanged: (v) => provider.setEnabled(v),
            ),
            SwitchListTile(
              title: const Text('Offline Only'),
              value: provider.offlineOnly,
              onChanged: (v) => provider.setOfflineOnly(v),
            ),
            const SizedBox(height: 16),
            Text('Custom Commands', style: AppTheme.subHeaderStyle),
            ...provider.customCommands.entries.map(
              (e) => ListTile(
                title: Text(e.key),
                subtitle: Text(e.value),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => provider.removeCustomCommand(e.key),
                ),
              ),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Phrase'),
              onChanged: (v) => _newPhrase = v,
              controller: TextEditingController(text: _newPhrase),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Intent'),
              onChanged: (v) => _newIntent = v,
              controller: TextEditingController(text: _newIntent),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _saving ? null : () => _addCommand(provider),
              child: _saving
                  ? const SkeletonLoader(itemCount: 1, height: 48)
                  : const Text('Add Command'),
            ),
          ],
        ),
      ),
    );
  }
}