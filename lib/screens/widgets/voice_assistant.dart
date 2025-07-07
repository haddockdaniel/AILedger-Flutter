import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../services/voice_service.dart';
import '../../utils/voice_event_bus.dart';
import '../../theme/app_theme.dart';

class VoiceAssistant extends StatefulWidget {
  const VoiceAssistant({super.key});

  @override
  State<VoiceAssistant> createState() => _VoiceAssistantState();
}

class _VoiceAssistantState extends State<VoiceAssistant> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';
  String? _suggestion;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: (e) => debugPrint('Speech error: $e'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() => _lastWords = result.recognizedWords);
          if (result.finalResult) {
            _processCommand(_lastWords);
          }
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _onSpeechStatus(String status) {
    if (status == 'notListening') {
      _stopListening();
    }
  }

  Future<void> _processCommand(String command) async {
    final response = await VoiceService.processCommand(command);
    if (response.success) {
      setState(() => _suggestion = response.suggestion);
      VoiceEventBus.emitIntent(response.intent, response.parameters);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sorry, I didn’t understand that.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_suggestion != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              constraints: const BoxConstraints(maxWidth: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.primaryColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _suggestion!,
                style: AppTheme.bodyStyle,
              ),
            ),
          FloatingActionButton(
            backgroundColor:
                _isListening ? AppTheme.accentColor : AppTheme.primaryColor,
            onPressed: _isListening ? _stopListening : _startListening,
            child: Icon(_isListening ? Icons.mic_off : Icons.mic),
          ),
        ],
      ),
    );
  }
}
