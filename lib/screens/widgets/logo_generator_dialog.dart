import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../services/open_ai_service.dart';
import '../../services/logo_service.dart';

class LogoGeneratorDialog extends StatefulWidget {
  const LogoGeneratorDialog({super.key});

  @override
  State<LogoGeneratorDialog> createState() => _LogoGeneratorDialogState();
}

class _LogoGeneratorDialogState extends State<LogoGeneratorDialog> {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _image;
  bool _generating = false;
  String? _error;

  late stt.SpeechToText _speech;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _startListening() async {
    if (_listening) return;
    final available = await _speech.initialize();
    if (!available) return;
    setState(() => _listening = true);
    _speech.listen(onResult: (result) {
      setState(() {
        _controller.text = result.recognizedWords;
      });
    });
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _listening = false);
  }

  Future<void> _generate([String? prefix]) async {
    final prompt = '${(prefix ?? '')} ${_controller.text}'.trim();
    if (prompt.isEmpty) return;
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      final b64 = await OpenAIService.generateImage(prompt);
      setState(() {
        _image = base64Decode(b64);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _generating = false);
    }
  }

  Future<void> _handleAction(String action) async {
    switch (action) {
      case 'love':
        if (_image != null) {
          await LogoService.saveLogo(_image!);
        }
        if (mounted) Navigator.of(context).pop(true);
        break;
      case 'improve':
        await _generate('Refine the following idea.');
        break;
      case 'hate':
        await _generate('Create a completely different logo.');
        break;
      case 'cancel':
        Navigator.of(context).pop(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI Logo Generator'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Describe your business and logo preferences',
                suffixIcon: IconButton(
                  icon: Icon(_listening ? Icons.mic_off : Icons.mic),
                  onPressed: _listening ? _stopListening : _startListening,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_generating) const CircularProgressIndicator(),
            if (_image != null) ...[
              Image.memory(_image!, height: 150),
              const SizedBox(height: 12),
            ],
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red))
          ],
        ),
      ),
      actions: _image == null
          ? [
              TextButton(
                onPressed: () => _handleAction('cancel'),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _generating ? null : () => _generate(),
                child: const Text('Generate'),
              ),
            ]
          : [
              TextButton(
                onPressed: () => _handleAction('hate'),
                child: const Text('I hate it'),
              ),
              TextButton(
                onPressed: () => _handleAction('improve'),
                child: const Text('Improve it'),
              ),
              TextButton(
                onPressed: () => _handleAction('cancel'),
                child: const Text('Not right now'),
              ),
              ElevatedButton(
                onPressed: () => _handleAction('love'),
                child: const Text('I love it'),
              ),
            ],
    );
  }
}