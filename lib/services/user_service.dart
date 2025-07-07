// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class EmailAlreadyExistsException implements Exception {
  final String message;
  EmailAlreadyExistsException([this.message = 'Email already exists']);
  @override
  String toString() => message;
}

class UserService {
  static String get _baseUrl => '$apiBaseUrl/api/user';
  static const String _emailExistsPath = 'email-exists';
  
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
  
    /// Returns `true` if an account with [email] already exists in the
  /// system. Throws an [Exception] if the check cannot be performed.
  static Future<bool> emailExists(String email) async {
    final token = await SecureStorage.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/$_emailExistsPath?email=$email'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['exists'] == true;
    }
    throw Exception('Failed to check email');
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

    if (response.statusCode == 409) {
      throw EmailAlreadyExistsException();
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to update user profile');
    }
  }
}
