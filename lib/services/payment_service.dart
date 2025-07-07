import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/secure_storage.dart';

class PaymentService {
  static Future<Map<String, String>> _headers() async {
    final token = await SecureStorage.getToken();
    final tenantId = await SecureStorage.getTenantId() ?? defaultTenantId;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (tenantId.isNotEmpty) tenantHeaderKey: tenantId,
    };
  }
  static Future<String> createSubscription({
    required String planId,
    required String returnUrl,
    required String cancelUrl,
    required String userId,
  }) async {
    final res = await http.post(
      Uri.parse('$apiBaseUrl/api/payments/create-subscription'),
      headers: await _headers(),
      body: jsonEncode({
        'planId': planId,
        'returnUrl': returnUrl,
        'cancelUrl': cancelUrl,
        'userId': userId,
      }),
    );
	
	    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to create subscription (${res.statusCode})');
    }
	
    final data = jsonDecode(res.body);
    return data['approvalUrl'];
  }

  static Future<void> executeSubscription(String token, String userId) async {
    final res = await http.get(
      Uri.parse('$apiBaseUrl/api/payments/execute-subscription?token=$token&userId=$userId'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception('Execute failed');
  }

  static Future<void> cancelSubscription(String subscriptionId) async {
    final res = await http.post(
      Uri.parse('$apiBaseUrl/api/payments/cancel-subscription'),
      headers: await _headers(),
      body: jsonEncode({ 'subscriptionId': subscriptionId }),
    );
    if (res.statusCode != 200) throw Exception('Cancel failed');
  }
}
