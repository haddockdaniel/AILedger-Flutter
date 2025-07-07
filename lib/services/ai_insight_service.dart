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
import 'expense_service.dart';
import 'customer_service.dart';
import '../models/invoice_model.dart';
import '../models/expense_model.dart';
import '../models/customer_model.dart';
import '../models/task_model.dart';
import 'dart:math';

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
  
    /// Forecast net cash flow for the next [days] using outstanding invoices
  /// and historical expense averages.
  static Future<List<Map<String, dynamic>>> forecastCashFlow({
    int days = 30,
    List<Invoice>? invoices,
    List<Expense>? expenses,
  }) async {
    invoices ??= await InvoiceService.getInvoices();
    final now = DateTime.now();
    final upcoming = invoices.where((i) =>
        !i.isPaid &&
        i.dueDate != null &&
        i.dueDate!.isAfter(now) &&
        i.dueDate!.isBefore(now.add(Duration(days: days))));

    expenses ??= await ExpenseService.getExpenses(
        startDate: now.subtract(const Duration(days: 30)), endDate: now);
    final avgDailyExpense = expenses.isEmpty
        ? 0.0
        : expenses.fold<double>(0.0, (s, e) => s + e.amount) / 30.0;

    final List<Map<String, dynamic>> result = [];
    for (var i = 0; i < days; i++) {
      final date = now.add(Duration(days: i + 1));
      final inflow = upcoming
          .where((inv) => inv.dueDate!.year == date.year &&
              inv.dueDate!.month == date.month &&
              inv.dueDate!.day == date.day)
          .fold<double>(0.0, (s, inv) => s + inv.total);
      result.add({'date': date, 'net': inflow - avgDailyExpense});
    }
    return result;
  }

  /// Calculate late payment risk score per customer based on overdue ratio.
  static Future<List<Map<String, dynamic>>> latePaymentRiskScores({
    List<Invoice>? invoices,
    List<Customer>? customers,
  }) async {
    invoices ??= await InvoiceService.getInvoices();
    customers ??= await CustomerService.fetchCustomers();

    final Map<String, List<Invoice>> byCustomer = {};
    for (final inv in invoices) {
      final id = inv.customerId?.toString() ?? '';
      byCustomer.putIfAbsent(id, () => []).add(inv);
    }

    final List<Map<String, dynamic>> scores = [];
    for (final c in customers) {
      final custInvoices = byCustomer[c.customerId] ?? [];
      if (custInvoices.isEmpty) continue;
      final overdue = custInvoices.where((i) =>
          !i.isPaid && i.dueDate != null && i.dueDate!.isBefore(DateTime.now()));
      final score = overdue.isEmpty
          ? 0.0
          : (overdue.length / custInvoices.length) * 100.0;
      scores.add({
        'customerId': c.customerId,
        'name': c.fullName,
        'score': double.parse(score.toStringAsFixed(2)),
      });
    }
    return scores;
  }

  /// Predict customer lifetime value using total paid and tenure heuristics.
  static Future<List<Map<String, dynamic>>> predictCustomerLifetimeValue({
    List<Invoice>? invoices,
    List<Customer>? customers,
  }) async {
    invoices ??= await InvoiceService.getInvoices();
    customers ??= await CustomerService.fetchCustomers();

    final Map<String, List<Invoice>> byCustomer = {};
    for (final inv in invoices) {
      final id = inv.customerId?.toString() ?? '';
      byCustomer.putIfAbsent(id, () => []).add(inv);
    }

    final List<Map<String, dynamic>> cltv = [];
    for (final c in customers) {
      final custInvoices = byCustomer[c.customerId] ?? [];
      if (custInvoices.isEmpty) continue;
      final paid = custInvoices
          .where((i) => i.isPaid)
          .fold<double>(0.0, (s, i) => s + i.total);
      final firstDate = custInvoices
          .map((e) => e.invoiceDate)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final months = DateTime.now().difference(firstDate).inDays / 30.0;
      final avgMonthly = months > 0 ? paid / months : paid;
      final prediction = paid + avgMonthly * 12; // assume 12 months more
      cltv.add({
        'customerId': c.customerId,
        'name': c.fullName,
        'cltv': double.parse(prediction.toStringAsFixed(2)),
      });
    }
    return cltv;
  }

  /// Detect expenses that are significant outliers using standard deviation.
  static Future<List<Expense>> detectExpenseAnomalies({List<Expense>? expenses}) async {
    expenses ??= await ExpenseService.getExpenses();
    if (expenses.isEmpty) return [];
    final amounts = expenses.map((e) => e.amount).toList();
    final mean = amounts.reduce((a, b) => a + b) / amounts.length;
    final variance =
        amounts.map((a) => (a - mean) * (a - mean)).reduce((a, b) => a + b) /
            amounts.length;
    final std = variance <= 0 ? 0 : sqrt(variance);
    final threshold = mean + 2 * std;
    return expenses.where((e) => e.amount > threshold).toList();
  }

  /// Recommend next best action for customer engagement.
  static Future<List<Map<String, String>>> nextBestCustomerAction({
    List<Invoice>? invoices,
    List<Customer>? customers,
    List<Task>? tasks,
  }) async {
    invoices ??= await InvoiceService.getInvoices();
    customers ??= await CustomerService.fetchCustomers();
    tasks ??= await TaskService.getTasks();

    final Map<String, List<Invoice>> byCustomer = {};
    for (final inv in invoices) {
      final id = inv.customerId?.toString() ?? '';
      byCustomer.putIfAbsent(id, () => []).add(inv);
    }

    final Map<String, List<Task>> tasksByCustomer = {};
    for (final t in tasks) {
      if (t.customerId == null) continue;
      tasksByCustomer.putIfAbsent(t.customerId!, () => []).add(t);
    }

    final List<Map<String, String>> actions = [];
    for (final c in customers) {
      final custInvoices = byCustomer[c.customerId] ?? [];
      final overdue = custInvoices.where((i) =>
          !i.isPaid && i.dueDate != null && i.dueDate!.isBefore(DateTime.now()));
      final dueSoon = custInvoices.where((i) =>
          !i.isPaid &&
          i.dueDate != null &&
          i.dueDate!.isAfter(DateTime.now()) &&
          i.dueDate!.isBefore(DateTime.now().add(const Duration(days: 5))));

      String action;
      if (overdue.isNotEmpty) {
        action = 'Send payment reminder';
      } else if (dueSoon.isNotEmpty) {
        action = 'Notify about upcoming invoice';
      } else if ((tasksByCustomer[c.customerId] ?? []).isNotEmpty) {
        action = 'Follow up on open tasks';
      } else {
        action = 'Send thank you note';
      }
      actions.add({'customerId': c.customerId, 'name': c.fullName, 'action': action});
    }
    return actions;
  }
  
}
