import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/email_template_model.dart';
import '../utils/storage.dart';

class EmailTemplateService {
  static const String baseUrl = 'https://your-api-url.com/api/email-templates';

  static Future<String?> _getAuthToken() async {
    return await SecureStorage.getToken();
  }

  static Future<List<EmailTemplate>> getTemplates() async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => EmailTemplate.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load email templates');
    }
  }

  static Future<EmailTemplate> getTemplateById(String templateId) async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$templateId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return EmailTemplate.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch email template');
    }
  }

  static Future<bool> createTemplate(EmailTemplate template) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(template.toJson()),
    );

    return response.statusCode == 201;
  }

  static Future<bool> updateTemplate(String templateId, EmailTemplate template) async {
    final token = await _getAuthToken();
    final response = await http.put(
      Uri.parse('$baseUrl/$templateId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(template.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteTemplate(String templateId) async {
    final token = await _getAuthToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$templateId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }
}
