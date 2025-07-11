import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autoledger/providers/voice_settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'voice_enabled': false,
      'voice_offline_only': true,
      'voice_custom_cmds': jsonEncode({'hello': 'navigate_home'}),
    });
  });

  test('loads settings from SharedPreferences on init', () async {
    final provider = VoiceSettingsProvider();
    await Future.delayed(Duration.zero);
    expect(provider.isEnabled, isFalse);
    expect(provider.offlineOnly, isTrue);
    expect(provider.customCommands['hello'], 'navigate_home');
  });
}