import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import '../utils/constants.dart';
import '../utils/secure_storage.dart';

class TaskService {
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

  static Future<List<Task>> getTasks() async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/tasks'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  static Future<Task> getTaskById(String id) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/tasks/$id'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load task');
    }
  }

  static Future<Task> createTask(Task task) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/tasks'),
      headers: headers,
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  static Future<void> updateTask(Task task) async {
    final headers = await _headers();
    final response = await http.put(
      Uri.parse('$apiBaseUrl/api/tasks/${task.taskId}'),
      headers: headers,
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  static Future<void> deleteTask(String id) async {
    final headers = await _headers(isJson: false);
    final response = await http.delete(
      Uri.parse('$apiBaseUrl/api/tasks/$id'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }

  static Future<void> markTaskComplete(String id) async {
    final headers = await _headers(isJson: false);
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/tasks/$id/complete'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark task as complete');
    }
  }
}
