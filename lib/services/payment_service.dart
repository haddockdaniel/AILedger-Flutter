import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class PaymentService {
  static Future<String> createSubscription({
    required String planId,
    required String returnUrl,
    required String cancelUrl,
    required String userId,
  }) async {
    final res = await http.post(
      Uri.parse('$apiBaseUrl/api/payments/create-subscription'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({ 'planId': planId, 'returnUrl': returnUrl, 'cancelUrl': cancelUrl, 'userId': userId }),
    );
    final data = jsonDecode(res.body);
    return data['approvalUrl'];
  }

  static Future<void> executeSubscription(String token, String userId) async {
    final res = await http.get(Uri.parse(
        '$apiBaseUrl/api/payments/execute-subscription?token=$token&userId=$userId'));
    if (res.statusCode != 200) throw Exception('Execute failed');
  }

  static Future<void> cancelSubscription(String subscriptionId) async {
    final res = await http.post(
      Uri.parse('$apiBaseUrl/api/payments/cancel-subscription'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({ 'subscriptionId': subscriptionId }),
    );
    if (res.statusCode != 200) throw Exception('Cancel failed');
  }
}
