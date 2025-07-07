import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
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
    late FlutterTts _tts;
  bool _isListening = false;
  String _lastWords = '';
  String? _suggestion;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
	_tts = FlutterTts();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: (e) => debugPrint('Speech error: $e'),
    );
  }

  void _startListening() async {
    if (_isListening) return;
    if (!_speech.isAvailable) {
      await _tts.speak('Speech recognition unavailable');
      return;
    }
	    await _tts.speak('Listening');
    setState(() => _isListening = true);
    _speech.listen(
      onResult: (result) {
        setState(() => _lastWords = result.recognizedWords);
        if (result.finalResult) {
          _processCommand(_lastWords);
        }
      },
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: 'en_US',
      onDevice: true,
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
	_tts.speak('Stopped listening');
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
	  if (response.suggestion.isNotEmpty) {
        _tts.speak(response.suggestion);
      } else {
        _tts.speak('Command received');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sorry, I didn’t understand that.')),
      );
	  _tts.speak("Sorry, I didn't understand that");
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
                color: AppTheme.surfaceColor,
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
