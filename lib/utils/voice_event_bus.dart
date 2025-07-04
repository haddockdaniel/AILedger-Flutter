import 'dart:async';

class VoiceEvent {
  final String type; // e.g., 'navigate', 'refresh', 'action'
  final String payload; // e.g., 'customers', 'invoices', 'add_task'
  final dynamic data;

  VoiceEvent({required this.type, required this.payload, this.data});
}

class VoiceEventBus {
  static final VoiceEventBus _instance = VoiceEventBus._internal();
  final StreamController<VoiceEvent> _controller = StreamController.broadcast();

  factory VoiceEventBus() {
    return _instance;
  }

  VoiceEventBus._internal();

  Stream<VoiceEvent> get stream => _controller.stream;

  void emit(VoiceEvent event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}
