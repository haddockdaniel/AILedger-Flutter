import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/invoice_model.dart';
import '../utils/constants.dart';
import '../utils/secure_storage.dart';
import 'database_service.dart';
import 'connectivity_service.dart';

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
    if (await ConnectivityService.isOnline()) {
      try {
        final headers = await _headers();
        final response = await http.get(
          Uri.parse('$apiBaseUrl/api/invoices'),
          headers: headers,
        );
        if (response.statusCode == 200) {
          List<dynamic> body = jsonDecode(response.body);
          final invoices =
              body.map((json) => Invoice.fromJson(json)).toList();
          for (final inv in invoices) {
            await DatabaseService().upsertInvoice(inv);
          }
          return invoices;
        }
      } catch (_) {}
    }
    // Fallback to local cache
    return DatabaseService().getInvoices();
  }

  static Future<Invoice?> getInvoiceById(int id) async {
    if (await ConnectivityService.isOnline()) {
      try {
        final headers = await _headers();
        final response = await http.get(
          Uri.parse('$apiBaseUrl/api/invoices/$id'),
          headers: headers,
        );
        if (response.statusCode == 200) {
          final inv = Invoice.fromJson(jsonDecode(response.body));
          await DatabaseService().upsertInvoice(inv);
          return inv;
        }
      } catch (_) {}
    }
    return DatabaseService().getInvoice(id);
  }
  
  static Future<List<Invoice>> getInvoicesByCustomerId(
     String customerId) async {
     if (await ConnectivityService.isOnline()) {
      try {
        final headers = await _headers();
        final response = await http.get(
          Uri.parse('$apiBaseUrl/api/invoices?customerId=$customerId'),
          headers: headers,
        );
        if (response.statusCode == 200) {
          final list = jsonDecode(response.body) as List<dynamic>;
          final invoices = list.map((j) => Invoice.fromJson(j)).toList();
          for (final inv in invoices) {
            await DatabaseService().upsertInvoice(inv);
          }
          return invoices;
        }
      } catch (_) {}
    }
    final all = await DatabaseService().getInvoices();
    return all.where((i) => i.customerId?.toString() == customerId).toList();
  }

  static Future<Invoice> createInvoice(Invoice invoice) async {
    if (await ConnectivityService.isOnline()) {
      final created = await createInvoiceOnline(invoice);
      await DatabaseService().upsertInvoice(created, isSynced: true);
      return created;
    }
    final tmpId = -DateTime.now().millisecondsSinceEpoch;
    final data = invoice.toJson()..['invoiceId'] = tmpId;
    final local = Invoice.fromJson(data);
    await DatabaseService().upsertInvoice(local, isSynced: false);
    await DatabaseService().addPendingAction(
        tmpId.toString(), 'invoice', 'create', data: jsonEncode(invoice.toJson()));
    return local;
  }

  static Future<void> updateInvoice(Invoice invoice) async {
    if (await ConnectivityService.isOnline()) {
      await updateInvoiceOnline(invoice);
      await DatabaseService().upsertInvoice(invoice, isSynced: true);
      return;
    }
    await DatabaseService().upsertInvoice(invoice, isSynced: false);
    await DatabaseService().addPendingAction(
        invoice.invoiceId.toString(), 'invoice', 'update',
        data: jsonEncode(invoice.toJson()));
  }

  static Future<void> deleteInvoice(int id) async {
    if (await ConnectivityService.isOnline()) {
      await deleteInvoiceOnline(id);
      await DatabaseService().deleteInvoice(id);
      return;
    }
    await DatabaseService().deleteInvoice(id);
    await DatabaseService()
        .addPendingAction(id.toString(), 'invoice', 'delete');
  }

  static Future<void> cancelInvoice(int id) async {
    final headers = await _headers(isJson: false);
    final response = await http.post(
        Uri.parse('$apiBaseUrl/api/invoices/$id/cancel'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to cancel invoice');
    }
  }

  static Future<void> writeOffInvoice(int id) async {
    final headers = await _headers(isJson: false);
    final response = await http.post(
        Uri.parse('$apiBaseUrl/api/invoices/$id/writeoff'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to write off invoice');
    }
  }

  static Future<void> discountInvoice(int id, double discount) async {
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

  static Future<void> regenerateInvoicePdf(int id) async {
    final headers = await _headers(isJson: false);
    final response = await http.post(
        Uri.parse('$apiBaseUrl/api/invoices/$id/regenerate'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to regenerate invoice PDF');
    }
  }

  static Future<void> sendInvoice(int id) async {
    final headers = await _headers(isJson: false);
    final response = await http.post(
        Uri.parse('$apiBaseUrl/api/invoices/$id/send'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send invoice');
    }
  }
  
  static Future<void> sendPastDueReminder(int id) async {
    final headers = await _headers(isJson: false);
    final response = await http.post(
        Uri.parse('$apiBaseUrl/api/invoices/$id/reminder'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send reminder');
    }
  }
  
  // -------- Online helpers used by the sync service --------
  static Future<Invoice> createInvoiceOnline(Invoice invoice) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/invoices'),
      headers: headers,
      body: jsonEncode(invoice.toJson()),
    );
    if (response.statusCode == 201) {
      return Invoice.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create invoice');
  }

  static Future<void> updateInvoiceOnline(Invoice invoice) async {
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

  static Future<void> deleteInvoiceOnline(int id) async {
    final headers = await _headers(isJson: false);
    final response = await http.delete(
      Uri.parse('$apiBaseUrl/api/invoices/$id'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete invoice');
    }
  }
  
}
