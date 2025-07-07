import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_tax_settings_model.dart';
import '../utils/secure_storage.dart';

class SettingsService {
  final String baseUrl;

  SettingsService({required this.baseUrl});

  Future<Map<String, String>> _headers() async {
    final token = await SecureStorage.getToken();
	    final tenantId = await SecureStorage.getTenantId() ?? defaultTenantId;
    return {
      'Authorization': 'Bearer $token',
      if (tenantId.isNotEmpty) tenantHeaderKey: tenantId,
      'Content-Type': 'application/json',
    };
  }

  Future<UserTaxSettings?> fetchUserTaxSettings() async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$baseUrl/api/settings/tax'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return UserTaxSettings.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<bool> updateUserTaxSettings(UserTaxSettings settings) async {
    final headers = await _headers();
    final response = await http.put(
      Uri.parse('$baseUrl/api/settings/tax'),
      headers: headers,
      body: json.encode(settings.toJson()),
    );

    return response.statusCode == 200;
  }
}
