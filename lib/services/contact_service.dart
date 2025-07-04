import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/contact_model.dart';
import '../utils/constants.dart';
import '../utils/secure_storage.dart';

class ContactService {
  static Future<String?> _getToken() => SecureStorage.getToken();

  static Future<Map<String, String>> _getHeaders({bool isJson = true}) async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      if (isJson) 'Content-Type': 'application/json',
    };
  }

  /// Fetch all contacts for the current user
  static Future<List<Contact>> fetchContacts() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/contacts'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Contact.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load contacts (${response.statusCode})');
    }
  }

  /// Fetch a single contact by ID
  static Future<Contact> getContactById(String id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/contacts/$id'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return Contact.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load contact (${response.statusCode})');
    }
  }

  /// Create a new contact
  static Future<void> createContact(Contact contact) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/contacts'),
      headers: headers,
      body: jsonEncode(contact.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create contact (${response.statusCode})');
    }
  }

  /// Update an existing contact
  static Future<void> updateContact(Contact contact) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$apiBaseUrl/api/contacts/${contact.contactId}'),
      headers: headers,
      body: jsonEncode(contact.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update contact (${response.statusCode})');
    }
  }

  /// Delete a contact
  static Future<void> deleteContact(String id) async {
    final headers = await _getHeaders(isJson: false);
    final response = await http.delete(
      Uri.parse('$apiBaseUrl/api/contacts/$id'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete contact (${response.statusCode})');
    }
  }

  /// Parse a business card image (no storage) and return a Contact prefill
  static Future<Contact> parseBusinessCard(File imageFile) async {
    final headers = await _getHeaders(isJson: false);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiBaseUrl/api/contacts/parse-business-card'),
    )..headers.addAll(headers)
     ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode == 200) {
      return Contact.fromJson(jsonDecode(body));
    } else {
      throw Exception('Failed to parse business card (${streamed.statusCode})');
    }
  }
}
