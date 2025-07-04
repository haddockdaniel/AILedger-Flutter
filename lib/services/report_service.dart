import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/storage.dart';

class ReportService {
  static const String baseUrl = 'https://your-api-url.com/api/reports';

  static Future<String?> _getToken() async {
    return await Storage.getToken();
  }

  static Future<http.Response> getReport({
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
    String? customerId,
    String? vendor,
    String format = 'json', // options: json, pdf, xlsx
  }) async {
    final token = await _getToken();

    final queryParameters = <String, String>{
      'format': format,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
      if (customerId != null) 'customerId': customerId,
      if (vendor != null) 'vendor': vendor,
    };

    final uri = Uri.parse('$baseUrl/$reportType').replace(queryParameters: queryParameters);

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load report: ${response.body}');
    }
  }
}
