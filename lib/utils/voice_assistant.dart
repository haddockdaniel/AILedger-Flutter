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
  static const int _maxChainDepth = 4;
  
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
            _processCommandChain(result.recognizedWords);
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
    _processCommandChain(text);
  }

  Future<void> _processCommandChain(String text, [int depth = 0]) async {
    if (depth >= _maxChainDepth) return;

    final parts = text.split(RegExp(r'\s+(?:and|then)\s+', caseSensitive: false));
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty) {
        await _processText(trimmed, depth);
      }
    }
  }

  Future<void> _processText(String inputText, [int depth = 0]) async {
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
          _handleIntent(data, depth);
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

  void _handleIntent(Map<String, dynamic> data, [int depth = 0]) {
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

    // Handle chaining - accept single string or list of strings
    final followUp = data['followUp'];
    if (followUp != null) {
      Future.delayed(const Duration(seconds: 1), () {
        if (followUp is List) {
          for (final item in followUp.take(_maxChainDepth)) {
            _processCommandChain(item.toString(), depth + 1);
          }
        } else if (followUp.toString().isNotEmpty) {
          _processCommandChain(followUp.toString(), depth + 1);
        }
      });
    }
  }

  void _speak(String text) async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }
}
