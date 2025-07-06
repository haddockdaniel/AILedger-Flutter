import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/email_model.dart';
import '../utils/constants.dart';
import '../utils/secure_storage.dart';

class EmailService {
  static Future<String?> _getToken() async {
    return await SecureStorage.getToken();
  }

  static Future<List<Email>> getEmails() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/emails'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Email.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load emails');
    }
  }

  static Future<Email> getEmailById(String id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/emails/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return Email.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load email');
    }
  }

  static Future<Email> createEmail(Email email) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/emails'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(email.toJson()),
    );
    if (response.statusCode == 201) {
      return Email.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create email');
    }
  }

  static Future<void> updateEmail(Email email) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$apiBaseUrl/api/emails/${email.emailId}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(email.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update email');
    }
  }

  static Future<void> deleteEmail(String id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$apiBaseUrl/api/emails/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete email');
    }
  }
  
  static Future<void> sendEmail(String id) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/emails/$id/send'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send email');
    }
  }
  
}
