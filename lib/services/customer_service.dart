import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer_model.dart';
import '../utils/constants.dart';
import '../utils/secure_storage.dart';

class CustomerService {
  static String get _baseUrl => '$apiBaseUrl/api/customers';

  static Future<Map<String, String>> _headers() async {
    final token = await SecureStorage.getToken();
    final tenantId = await SecureStorage.getTenantId() ?? defaultTenantId;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      if (tenantId.isNotEmpty) tenantHeaderKey: tenantId,
    };
  }

  static Future<List<Customer>> fetchCustomers() async {
    final res = await http.get(Uri.parse(_baseUrl), headers: await _headers());
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.map((e) => Customer.fromJson(e)).toList();
    }
    throw Exception('Failed to load customers');
  }

  static Future<Customer> getCustomerById(String id) async {
    final res =
        await http.get(Uri.parse('$_baseUrl/$id'), headers: await _headers());
    if (res.statusCode == 200) {
      return Customer.fromJson(json.decode(res.body));
    }
    throw Exception('Customer not found');
  }

  static Future<void> addCustomer(Customer customer) async {
    final res = await http.post(Uri.parse(_baseUrl),
        headers: await _headers(), body: json.encode(customer.toJson()));
    if (res.statusCode != 201) {
      throw Exception('Failed to add customer');
    }
  }

  static Future<void> updateCustomer(Customer customer) async {
    final res = await http.put(Uri.parse('$_baseUrl/${customer.customerId}'),
        headers: await _headers(), body: json.encode(customer.toJson()));
    if (res.statusCode != 200) {
      throw Exception('Failed to update customer');
    }
  }

  static Future<void> deleteCustomer(String id) async {
    final res = await http.delete(Uri.parse('$_baseUrl/$id'),
        headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('Failed to delete customer');
    }
  }
}
