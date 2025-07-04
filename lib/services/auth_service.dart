// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';

class AuthService {
  static const String _baseUrl = 'https://your-api-domain.com/api/auth';

  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await SecureStorage.saveToken(data['token']);
      await SecureStorage.saveRefreshToken(data['refreshToken']);
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> resetPassword(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    return response.statusCode == 200;
  }

  static Future<bool> refreshToken() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await SecureStorage.saveToken(data['token']);
      await SecureStorage.saveRefreshToken(data['refreshToken']);
      return true;
    } else {
      return false;
    }
  }

static Future<String> signUp(String email, String password) async {
  final res = await http.post(
    Uri.parse('$apiBaseUrl/api/auth/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({ 'email': email, 'password': password }),
  );
  if (res.statusCode == 201) {
    final data = jsonDecode(res.body);
    return data['userId'];
  }
  throw Exception('Signup failed');
}

  static Future<void> logout() async {
    await SecureStorage.clearAll();
  }
}
