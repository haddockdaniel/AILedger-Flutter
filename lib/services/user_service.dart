// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';
import '../models/user_model.dart';

class UserService {
  static const String _baseUrl = 'https://your-api-domain.com/api/user';

  static Future<User> fetchUserProfile() async {
    final token = await SecureStorage.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  static Future<void> updateUserProfile(User updatedUser) async {
    final token = await SecureStorage.getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedUser.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user profile');
    }
  }
}
