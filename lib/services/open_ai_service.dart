import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple wrapper around the OpenAI chat completion API used to generate
/// natural language insights.
class OpenAIService {
  static const String _apiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String _chatEndpoint =
      'https://api.openai.com/v1/chat/completions';
  static const String _imageEndpoint =
      'https://api.openai.com/v1/images/generations';

  /// Sends [prompt] to the OpenAI API and returns the response text.
  static Future<String> getCompletion(String prompt) async {
    final response = await http.post(
      Uri.parse(_chatEndpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful assistant providing short financial suggestions.'
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('OpenAI request failed: ${response.body}');
    }
  }
  
  /// Generates an image in base64 format based on [prompt].
  static Future<String> generateImage(String prompt) async {
    final response = await http.post(
      Uri.parse(_imageEndpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': prompt,
        'n': 1,
        'size': '512x512',
        'response_format': 'b64_json'
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'][0]['b64_json'];
    } else {
      throw Exception('OpenAI image generation failed: ${response.body}');
    }
  }
  
}