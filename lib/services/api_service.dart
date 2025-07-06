// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

class ApiService {
  /// Common base URL for all API requests.
  static String get _baseUrl => '$apiBaseUrl/api';

  static Future<http.Response> get(String endpoint) async {
    final token = await SecureStorage.getToken();
    return http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  static Future<http.Response> post(String endpoint, dynamic body) async {
    final token = await SecureStorage.getToken();
    return http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(String endpoint, dynamic body) async {
    final token = await SecureStorage.getToken();
    return http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final token = await SecureStorage.getToken();
    return http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  static Future<http.Response> uploadFile(String endpoint, String filePath, String fieldName) async {
    final token = await SecureStorage.getToken();
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$endpoint'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
