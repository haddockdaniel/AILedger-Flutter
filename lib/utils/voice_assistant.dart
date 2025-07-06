import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:autoledger/utils/voice_event_bus.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceAssistant {
  static final VoiceAssistant _instance = VoiceAssistant._internal();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  final String _intentApiUrl = 'https://yourapi.com/api/voice/intent'; // Replace with env value if needed
  final String _apiKey = 'YOUR_API_KEY'; // Securely load this in prod

  factory VoiceAssistant() => _instance;

  VoiceAssistant._internal();

  Future<void> init() async {
    await _speech.initialize();
  }

  Future<void> startListening() async {
    if (!_isListening) {
      _isListening = true;
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            _isListening = false;
            _processText(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
      );
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }
  
    /// Simulate handling a text command without speech input
  void simulateCommand(String text) {
    _processText(text);
  }

  Future<void> _processText(String inputText) async {
    try {
      final response = await http.post(
        Uri.parse(_intentApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({'input': inputText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['intent'] != null) {
          _handleIntent(data);
        } else {
          _speak("Sorry, I didn't understand that.");
        }
      } else {
        _speak("Error contacting the server.");
      }
    } catch (e) {
      _speak("Something went wrong. Please try again.");
    }
  }

  void _handleIntent(Map<String, dynamic> data) {
    final intent = data['intent'];
    final action = intent['action'];
    final target = intent['target'];
    final payload = intent['payload'];

    switch (action) {
      case 'navigate':
        VoiceEventBus().emit(VoiceEvent(type: 'navigate', payload: target));
        break;
      case 'refresh':
        VoiceEventBus().emit(VoiceEvent(type: 'refresh', payload: target));
        break;
      case 'action':
        VoiceEventBus().emit(VoiceEvent(type: 'action', payload: target, data: payload));
        break;
      case 'error':
        _speak(intent['message'] ?? "Unknown error.");
        break;
      default:
        _speak("Unrecognized command.");
    }

    // Handle chaining
    if (data['followUp'] != null && data['followUp'].toString().isNotEmpty) {
      Future.delayed(const Duration(seconds: 1), () {
        _processText(data['followUp']);
      });
    }
  }

  void _speak(String text) async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }
}
