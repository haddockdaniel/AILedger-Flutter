import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

class ReportService {
  static String get baseUrl => '$apiBaseUrl/api/reports';

  static Future<String?> _getToken() async {
    return await SecureStorage.getToken();
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
  
    /// Retrieve a human readable report string from the server.
  static Future<String> generateReport({
    required String reportType,
    DateTime? from,
    DateTime? to,
    String? customerId,
    String? vendor,
  }) async {
    final response = await getReport(
      reportType: reportType,
      startDate: from,
      endDate: to,
      customerId: customerId,
      vendor: vendor,
      format: 'text',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data['content'] != null) {
        return data['content'] as String;
      }
      return response.body;
    } else {
      throw Exception('Failed to generate report: ${response.body}');
    }
  }

  /// Export the given [content] as a PDF written to [path].
  static Future<void> exportPdf(String content, String path) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/export/pdf'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final bytes = base64Decode(data['file'] ?? data['pdf']);
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);
    } else {
      throw Exception('Failed to export PDF: ${response.body}');
    }
  }
  
}
