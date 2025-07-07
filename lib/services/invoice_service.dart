import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/invoice_model.dart';
import '../utils/constants.dart';
import '../utils/secure_storage.dart';

class InvoiceService {
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

  static Future<List<Invoice>> getInvoices() async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/invoices'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Invoice.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load invoices');
    }
  }

  static Future<Invoice> getInvoiceById(String id) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/invoices/$id'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return Invoice.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load invoice');
    }
  }
  
  static Future<List<Invoice>> getInvoicesByCustomerId(
      String customerId) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/invoices?customerId=$customerId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((j) => Invoice.fromJson(j)).toList();
    } else {
      throw Exception('Failed to load invoices');
    }
  }

  static Future<Invoice> createInvoice(Invoice invoice) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/invoices'),
      headers: headers,
      body: jsonEncode(invoice.toJson()),
    );
    if (response.statusCode == 201) {
      return Invoice.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create invoice');
    }
  }

  static Future<void> updateInvoice(Invoice invoice) async {
    final headers = await _headers();
    final response = await http.put(
      Uri.parse('$apiBaseUrl/api/invoices/${invoice.invoiceId}'),
      headers: headers,
      body: jsonEncode(invoice.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update invoice');
    }
  }

  static Future<void> deleteInvoice(String id) async {
    final headers = await _headers(isJson: false);
    final response = await http.delete(
      Uri.parse('$apiBaseUrl/api/invoices/$id'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete invoice');
    }
  }

  static Future<void> cancelInvoice(String id) async {
    final headers = await _headers(isJson: false);
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/invoices/$id/cancel'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to cancel invoice');
    }
  }

  static Future<void> writeOffInvoice(String id) async {
    final headers = await _headers(isJson: false);
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/invoices/$id/writeoff'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to write off invoice');
    }
  }

  static Future<void> discountInvoice(String id, double discount) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/invoices/$id/discount'),
      headers: headers,
      body: jsonEncode({'discount': discount}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to discount invoice');
    }
  }

  static Future<void> regenerateInvoicePdf(String id) async {
    final headers = await _headers(isJson: false);
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/invoices/$id/regenerate'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to regenerate invoice PDF');
    }
  }

  static Future<void> sendInvoice(String id) async {
    final headers = await _headers(isJson: false);
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/invoices/$id/send'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send invoice');
    }
  }
  
  static Future<void> sendPastDueReminder(String id) async {
    final headers = await _headers(isJson: false);
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/invoices/$id/reminder'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send reminder');
    }
  }
  
}
