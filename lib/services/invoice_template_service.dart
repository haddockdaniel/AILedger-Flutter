import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/invoice_template_model.dart';
import '../utils/secure_storage.dart';
import '../utils/constants.dart';
import '../data/default_invoice_templates.dart';

class InvoiceTemplateService {
  static String get baseUrl => '$apiBaseUrl/api/invoice-templates';

  static Future<String?> _getAuthToken() async {
    return await SecureStorage.getToken();
  }

  static Future<List<InvoiceTemplate>> getTemplates() async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => InvoiceTemplate.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load invoice templates');
    }
  }

  static Future<InvoiceTemplate> getTemplateById(String templateId) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$baseUrl/$templateId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return InvoiceTemplate.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch invoice template');
    }
  }

  static Future<bool> createTemplate(InvoiceTemplate template) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(template.toJson()),
    );

    return response.statusCode == 201;
  }

  static Future<bool> updateTemplate(String templateId, InvoiceTemplate template) async {
    final headers = await _headers();
    final response = await http.put(
      Uri.parse('$baseUrl/$templateId'),
      headers: headers,
      body: jsonEncode(template.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteTemplate(String templateId) async {
    final headers = await _headers(isJson: false);
    final response = await http.delete(
      Uri.parse('$baseUrl/$templateId'),
      headers: headers,
    );

    return response.statusCode == 200;
  }
  
    /// Return a predefined set of invoice templates for new installs.
  static Future<List<InvoiceTemplate>> getDefaultTemplates() async {
    return defaultInvoiceTemplates
        .map((t) => InvoiceTemplate(
              templateId: t.templateId,
              userId: t.userId,
              templateName: t.templateName,
              lineItems: t.lineItems
                  .map((l) => TemplateLineItem(
                        description: l.description,
                        amount: l.amount,
                      ))
                  .toList(),
              taxPercentage: t.taxPercentage,
              chargeTaxes: t.chargeTaxes,
              sendAutomatically: t.sendAutomatically,
              createdAt: t.createdAt,
            ))
        .toList();
  }
  
}
