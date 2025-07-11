import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autoledger/utils/voice_assistant.dart';
import 'package:autoledger/providers/voice_settings_provider.dart';
import 'package:autoledger/utils/voice_event_bus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    const MethodChannel ttsChannel = MethodChannel('flutter_tts');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (methodCall) async {});
  });

  tearDown(() {
    const MethodChannel ttsChannel = MethodChannel('flutter_tts');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, null);
  });

  test('simulateCommand emits no events when offline mode enabled', () async {
    final provider = VoiceSettingsProvider();
    await Future.delayed(Duration.zero);
    await provider.setOfflineOnly(true);

    final assistant = VoiceAssistant();
    assistant.settingsProvider = provider;

    final events = <VoiceEvent>[];
    VoiceEventBus().on<VoiceEvent>().listen(events.add);

    assistant.simulateCommand('test command');
    await Future.delayed(const Duration(milliseconds: 10));

    expect(events, isEmpty);
  });
}