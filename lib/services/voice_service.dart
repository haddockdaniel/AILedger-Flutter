// lib/services/voice_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';
import '../utils/constants.dart';
import '../models/voice_command_result.dart';

class VoiceService {
  static String get _baseUrl => '$apiBaseUrl/api/voice';

  static Future<Map<String, dynamic>> sendVoiceCommand(String transcript) async {
    final token = await SecureStorage.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/intent'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'transcript': transcript,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Voice intent processing failed');
    }
  }
  
    static Future<VoiceCommandResult> processCommand(String transcript) async {
    final data = await sendVoiceCommand(transcript);
    return VoiceCommandResult.fromJson(data);
  }

  static Future<void> cancelActiveIntent() async {
    final token = await SecureStorage.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/cancel'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel intent');
    }
  }
}
