// lib/services/ai_insight_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';
import '../models/ai_insight_model.dart';

class AiInsightService {
  static const String _baseUrl = 'https://your-api-domain.com/api/ai';

  static Future<List<AIInsight>> fetchInsights(String module) async {
    final token = await SecureStorage.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/insights?module=$module'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => AIInsight.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load AI insights');
    }
  }

  static Future<String> fetchNaturalLanguageResponse(String query) async {
    final token = await SecureStorage.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/nlp'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result'] ?? 'No result returned';
    } else {
      throw Exception('Failed to process natural language query');
    }
  }
}
