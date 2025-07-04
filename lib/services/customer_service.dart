import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer_model.dart';
import '../utils/api_config.dart';

class CustomerService {
  final String baseUrl;
  final String token;

  CustomerService({required this.baseUrl, required this.token});

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<Customer>> fetchCustomers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/customers'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customers');
    }
  }

  Future<Customer> fetchCustomerById(String customerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/customers/$customerId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return Customer.fromJson(json.decode(response.body));
    } else {
      throw Exception('Customer not found');
    }
  }

  Future<void> addCustomer(Customer customer) async {
    final response = await http.post(
      Uri.parse('$baseUrl/customers'),
      headers: headers,
      body: json.encode(customer.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add customer');
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    final response = await http.put(
      Uri.parse('$baseUrl/customers/${customer.customerId}'),
      headers: headers,
      body: json.encode(customer.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update customer');
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/customers/$customerId'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete customer');
    }
  }
}
