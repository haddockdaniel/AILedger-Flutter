// lib/services/ai_insight_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';
import '../models/ai_insight_model.dart';
import '../utils/constants.dart';
import 'invoice_service.dart';
import 'task_service.dart';
import 'email_service.dart';
import 'open_ai_service.dart';

class AIInsightService {
  static String get _baseUrl => '$apiBaseUrl/api/ai';

  static Future<List<AIInsight>> fetchInsights(String module) async {
    final token = await SecureStorage.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/insights?module=$module'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => AIInsight.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load AI insights');
    }
  }

  static Future<String> fetchNaturalLanguageResponse(String query) async {
    final token = await SecureStorage.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/nlp'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result'] ?? 'No result returned';
    } else {
      throw Exception('Failed to process natural language query');
    }
  }
  
  /// Generate actionable insights for the user by leveraging the OpenAI API.
  ///
  /// The method aggregates key statistics from invoices, tasks and emails,
  /// then asks the language model for short recommendations. The response is
  /// expected to be a JSON object with string values describing suggestions for
  /// each category. Example keys returned are `invoices`, `tasks` and `emails`.
  static Future<Map<String, String>> getInsights() async {
    final invoices = await InvoiceService.getInvoices();
    final tasks = await TaskService.getTasks();
    final emails = await EmailService.getEmails();

    final overdueInvoices = invoices.where((i) {
      return !i.isPaid &&
          i.dueDate != null &&
          i.dueDate!.isBefore(DateTime.now());
    }).length;

    final draftInvoices =
        invoices.where((i) => i.status.toLowerCase() == 'draft').length;

    final tasksDueSoon = tasks.where((t) {
      return !t.isCompleted &&
          t.dueDate.isBefore(DateTime.now().add(const Duration(days: 3)));
    }).length;

    final prompt = '''You are an assistant helping a small business owner stay on top of their work.
Return a JSON object with concise recommendations for the following categories: invoices, tasks and emails.
Statistics:
- overdueInvoices: $overdueInvoices
- draftInvoices: $draftInvoices
- tasksDueSoon: $tasksDueSoon
- emailDrafts: ${emails.length}
Keep suggestions short.''';

    final result = await OpenAIService.getCompletion(prompt);

    try {
      final data = jsonDecode(result) as Map<String, dynamic>;
      return data.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      // If parsing fails, return the raw response under a general key.
      return {'general': result};
    }
  }
  
}
