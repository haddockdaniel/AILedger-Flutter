import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_tax_settings_model.dart';
import '../utils/storage.dart';

class SettingsService {
  final String baseUrl;

  SettingsService({required this.baseUrl});

  Future<UserTaxSettings?> fetchUserTaxSettings() async {
    final token = await Storage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/settings/tax'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserTaxSettings.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<bool> updateUserTaxSettings(UserTaxSettings settings) async {
    final token = await Storage.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/settings/tax'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(settings.toJson()),
    );

    return response.statusCode == 200;
  }
}
