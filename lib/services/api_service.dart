// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  /// Common base URL for all API requests.
  static String get _baseUrl => '$apiBaseUrl/api';

  static Future<http.Response> _retryRequest(
      Future<http.Response> Function() request,
      {int retries = 2}) async {
    int attempt = 0;
    while (true) {
      try {
        final response = await request();
        return response;
      } on SocketException {
        if (attempt >= retries) {
          throw ApiException(
              'Unable to reach the server. Please check your internet connection.');
        }
      } catch (_) {
        if (attempt >= retries) {
          throw ApiException('An unexpected error occurred. Please try again.');
        }
      }
      attempt++;
      await Future.delayed(Duration(seconds: 2 * attempt));
    }
  }

  static void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    if (response.statusCode >= 500) {
      throw ApiException(
          'Server error (${response.statusCode}). Please try again later.');
    }
    if (response.statusCode == 401) {
      throw ApiException('Unauthorized request. Please log in again.');
    }
    if (response.statusCode == 404) {
      throw ApiException('Requested resource not found.');
    }
    throw ApiException('Request failed with status ${response.statusCode}.');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await SecureStorage.getToken();
	    final tenantId = await SecureStorage.getTenantId() ?? defaultTenantId;
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      if (tenantId.isNotEmpty) tenantHeaderKey: tenantId,
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final headers = await _headers();
    final response = await _retryRequest(() => http.get(
          Uri.parse('$_baseUrl$endpoint'),
          headers: headers,
        ));
    _checkResponse(response);
    return response;
  }

  static Future<http.Response> post(String endpoint, dynamic body) async {
    final headers = await _headers();
    final response = await _retryRequest(() => http.post(
          Uri.parse('$_baseUrl$endpoint'),
          headers: headers,
          body: jsonEncode(body),
        ));
    _checkResponse(response);
    return response;
  }

  static Future<http.Response> put(String endpoint, dynamic body) async {
    final headers = await _headers();
    final response = await _retryRequest(() => http.put(
          Uri.parse('$_baseUrl$endpoint'),
          headers: headers,
          body: jsonEncode(body),
        ));
    _checkResponse(response);
    return response;
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await _headers();
    final response = await _retryRequest(() => http.delete(
          Uri.parse('$_baseUrl$endpoint'),
          headers: headers,
        ));
    _checkResponse(response);
    return response;
  }

  static Future<http.Response> uploadFile(String endpoint, String filePath, String fieldName) async {
    final token = await SecureStorage.getToken();
            final tenantId = await SecureStorage.getTenantId() ?? defaultTenantId;
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$endpoint'));
    request.headers['Authorization'] = 'Bearer $token';
            if (tenantId.isNotEmpty) {
      request.headers[tenantHeaderKey] = tenantId;
    }
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
    final streamedResponse = await _retryRequest(() => request.send().then(http.Response.fromStream));
    _checkResponse(streamedResponse);
    return streamedResponse;
  }
}
