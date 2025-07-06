import 'dart:async';
import 'voice_events.dart';

class VoiceEventBus {
  static final VoiceEventBus _instance = VoiceEventBus._internal();
  factory VoiceEventBus() => _instance;
  VoiceEventBus._internal();

  final StreamController<dynamic> _typedController = StreamController.broadcast();
  final StreamController<_NamedEvent> _namedController = StreamController.broadcast();

  /// Listen for typed voice events
  Stream<T> on<T>() {
    return _typedController.stream.where((e) => e is T).cast<T>();
  }

  /// Listen for string-named events
  StreamSubscription onEvent(String name, void Function(dynamic) handler) {
    return _namedController.stream
        .where((e) => e.name == name)
        .listen((e) => handler(e.data));
  }

  void emit(dynamic event) {
    _typedController.add(event);
  }

  void emitEvent(String name, [dynamic data]) {
    _namedController.add(_NamedEvent(name, data));
  }

  static void emitIntent(String intent, [Map<String, dynamic>? slots]) {
    _instance.emit(VoiceIntentEvent(intent, slots: slots));
  }

  void emit(VoiceEvent event) {
    _controller.add(event);
  }

  void dispose() {
    _typedController.close();
    _namedController.close();
  }
}
