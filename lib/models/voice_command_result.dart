class VoiceCommandResult {
  final bool success;
  final String intent;
  final Map<String, dynamic> parameters;
  final String suggestion;

  VoiceCommandResult({
    required this.success,
    required this.intent,
    required this.parameters,
    required this.suggestion,
  });

  factory VoiceCommandResult.fromJson(Map<String, dynamic> json) {
    return VoiceCommandResult(
      success: json['success'] ?? false,
      intent: json['intent'] ?? '',
      parameters: (json['parameters'] as Map?)?.cast<String, dynamic>() ?? {},
      suggestion: json['suggestion'] ?? '',
    );
  }
}