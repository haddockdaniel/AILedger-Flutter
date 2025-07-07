import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

class SessionProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _loggedIn = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _loggedIn;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password, {String tenantId = ''}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'tenantId': tenantId}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        await SecureStorage.saveToken(json['token']);
        await SecureStorage.saveRefreshToken(json['refreshToken']);
        if (tenantId.isNotEmpty) {
          await SecureStorage.saveTenantId(tenantId);
        }
        _loggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final body = jsonDecode(response.body);
        _errorMessage = body['message'] ?? 'Login failed';
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
    _loggedIn = false;
    notifyListeners();
  }
}