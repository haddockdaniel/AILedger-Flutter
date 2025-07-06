class VoiceIntentEvent {
  final String intent;
  final Map<String, dynamic>? slots;
  VoiceIntentEvent(this.intent, {this.slots});
}

class VoiceCommandEvent {
  final String command;
  final Map<String, dynamic> data;
  VoiceCommandEvent(this.command, [this.data = const {}]);
}

class _NamedEvent {
  final String name;
  final dynamic data;
  _NamedEvent(this.name, this.data);
}