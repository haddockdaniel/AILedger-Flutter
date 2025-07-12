import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer_model.dart';
import '../utils/constants.dart';
import '../utils/secure_storage.dart';
import 'database_service.dart';
import 'connectivity_service.dart';

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
    if (await ConnectivityService.isOnline()) {
      try {
        final res =
            await http.get(Uri.parse(_baseUrl), headers: await _headers());
        if (res.statusCode == 200) {
          final data = json.decode(res.body) as List;
          final customers = data.map((e) => Customer.fromJson(e)).toList();
          for (final c in customers) {
            await DatabaseService().upsertCustomer(c);
          }
          return customers;
        }
      } catch (_) {}
    }
    return DatabaseService().getCustomers();
  }

  static Future<Customer?> getCustomerById(String id) async {
    if (await ConnectivityService.isOnline()) {
      try {
        final res =
            await http.get(Uri.parse('$_baseUrl/$id'), headers: await _headers());
        if (res.statusCode == 200) {
          final c = Customer.fromJson(json.decode(res.body));
          await DatabaseService().upsertCustomer(c);
          return c;
        }
      } catch (_) {}
    }
    return DatabaseService().getCustomer(id);
  }
  
    /// Autofill a customer using email or phone via the backend API
  static Future<Customer?> autoFill({String? email, String? phone}) async {
    final uri = Uri.parse('$_baseUrl/autofill').replace(queryParameters: {
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    try {
      final res = await http.get(uri, headers: await _headers());
      if (res.statusCode == 200) {
        return Customer.fromJson(json.decode(res.body));
      }
    } catch (_) {}
    return null;
  }

  static Future<void> addCustomer(Customer customer) async {
      if (await ConnectivityService.isOnline()) {
      final created = await createCustomerOnline(customer);
      await DatabaseService().upsertCustomer(created, isSynced: true);
      return;
    }
    final id = '-${DateTime.now().millisecondsSinceEpoch}';
    final data = customer.toJson()..['customerId'] = id;
    final local = Customer.fromJson(data);
    await DatabaseService().upsertCustomer(local, isSynced: false);
    await DatabaseService().addPendingAction(
        id, 'customer', 'create', data: json.encode(customer.toJson()));
  }

  static Future<void> updateCustomer(Customer customer) async {
    if (await ConnectivityService.isOnline()) {
      await updateCustomerOnline(customer);
      await DatabaseService().upsertCustomer(customer, isSynced: true);
      return;
    }
    await DatabaseService().upsertCustomer(customer, isSynced: false);
    await DatabaseService().addPendingAction(
        customer.customerId, 'customer', 'update',
        data: json.encode(customer.toJson()));
  }

  static Future<void> deleteCustomer(String id) async {
    if (await ConnectivityService.isOnline()) {
      await deleteCustomerOnline(id);
      await DatabaseService().deleteCustomer(id);
      return;
    }
    await DatabaseService().deleteCustomer(id);
    await DatabaseService().addPendingAction(id, 'customer', 'delete');
  }

  // -------- Online helpers used by the sync service --------
  static Future<Customer> createCustomerOnline(Customer customer) async {
    final res = await http.post(Uri.parse(_baseUrl),
        headers: await _headers(), body: json.encode(customer.toJson()));
    if (res.statusCode == 201) {
      return Customer.fromJson(json.decode(res.body));
    }
	    throw Exception('Failed to add customer');
  }

  static Future<void> updateCustomerOnline(Customer customer) async {
    final res = await http.put(Uri.parse('$_baseUrl/${customer.customerId}'),
        headers: await _headers(), body: json.encode(customer.toJson()));
    if (res.statusCode != 200) {
      throw Exception('Failed to update customer');
    }
  }

  static Future<void> deleteCustomerOnline(String id) async {
    final res =
        await http.delete(Uri.parse('$_baseUrl/$id'), headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('Failed to delete customer');
    }
  }
}
