import 'package:flutter_test/flutter_test.dart';
import 'package:autoledger/utils/voice_event_bus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('emitIntent dispatches VoiceIntentEvent', () async {
    final future = VoiceEventBus().on<VoiceIntentEvent>().first;
    VoiceEventBus.emitIntent('navigate', {'page': 'home'});
    final event = await future;
    expect(event.intent, 'navigate');
    expect(event.slots?['page'], 'home');
  });

  test('named events are handled', () async {
    final bus = VoiceEventBus();
    dynamic received;
    final sub = bus.onEvent('refresh', (data) => received = data);
    bus.emitEvent('refresh', 'tasks');
    await Future.delayed(Duration.zero);
    expect(received, 'tasks');
    await sub.cancel();
  });
}