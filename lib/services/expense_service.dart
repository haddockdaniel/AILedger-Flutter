import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/expense_model.dart';
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

class ExpenseService {
  static String get baseUrl => '$apiBaseUrl/api/expenses';

  static Future<String?> _getToken() async {
    return await SecureStorage.getToken();
  }

  static Future<Map<String, String>> _headers({bool isJson = true}) async {
    final token = await _getToken();
    final tenantId = await SecureStorage.getTenantId() ?? defaultTenantId;
    return {
      'Authorization': 'Bearer $token',
      if (tenantId.isNotEmpty) tenantHeaderKey: tenantId,
      if (isJson) 'Content-Type': 'application/json',
    };
  }

  static Future<List<Expense>> getExpenses({String? vendor, DateTime? startDate, DateTime? endDate}) async {
    final headers = await _headers();
    Map<String, String> queryParams = {};
    if (vendor != null) queryParams['vendor'] = vendor;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Expense.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  static Future<Expense> getExpenseById(String id) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Expense not found');
    }
  }

  static Future<void> createExpense(Expense expense) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(expense.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create expense');
    }
  }

  static Future<void> createExpenseWithImage(Expense expense, File imageFile) async {
    final token = await _getToken();
    final tenantId = await SecureStorage.getTenantId() ?? defaultTenantId;
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/with-image'))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['data'] = jsonEncode(expense.toJson())
      ..headers.addAll({if (tenantId.isNotEmpty) tenantHeaderKey: tenantId})
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path, contentType: MediaType('image', 'jpeg')));

    final response = await request.send();
    if (response.statusCode != 201) {
      throw Exception('Failed to create expense with image');
    }
  }

  static Future<void> updateExpense(String id, Expense expense) async {
    final headers = await _headers();
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: jsonEncode(expense.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update expense');
    }
  }

  static Future<void> deleteExpense(String id) async {
    final headers = await _headers(isJson: false);
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense');
    }
  }
  
  static Future<void> attachReceipt(String id, String url) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$baseUrl/$id/receipt'),
      headers: headers,
      body: jsonEncode({'url': url}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to attach receipt');
    }
  }
  
}
