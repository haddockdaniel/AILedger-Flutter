import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import '../utils/constants.dart';
import '../utils/secure_storage.dart';
import 'database_service.dart';
import 'connectivity_service.dart';

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
     if (await ConnectivityService.isOnline()) {
      try {
        final headers = await _headers();
        final response = await http.get(
          Uri.parse('$apiBaseUrl/api/tasks'),
          headers: headers,
        );
        if (response.statusCode == 200) {
          List<dynamic> body = jsonDecode(response.body);
          final tasks = body.map((json) => Task.fromJson(json)).toList();
          for (final t in tasks) {
            await DatabaseService().upsertTask(t);
          }
          return tasks;
        }
      } catch (_) {}
    }
    return DatabaseService().getTasks();
  }

  static Future<Task?> getTaskById(String id) async {
    if (await ConnectivityService.isOnline()) {
      try {
        final headers = await _headers();
        final response = await http.get(
          Uri.parse('$apiBaseUrl/api/tasks/$id'),
          headers: headers,
        );
        if (response.statusCode == 200) {
          final t = Task.fromJson(jsonDecode(response.body));
          await DatabaseService().upsertTask(t);
          return t;
        }
      } catch (_) {}
    }
    return DatabaseService().getTask(id);
  }

  static Future<Task> createTask(Task task) async {
    if (await ConnectivityService.isOnline()) {
      final created = await createTaskOnline(task);
      await DatabaseService().upsertTask(created, isSynced: true);
      return created;
    }
    final id = '-${DateTime.now().millisecondsSinceEpoch}';
    final data = task.toJson()..['taskId'] = id;
    final local = Task.fromJson(data);
    await DatabaseService().upsertTask(local, isSynced: false);
    await DatabaseService().addPendingAction(
        id, 'task', 'create', data: jsonEncode(task.toJson()));
    return local;
  }

  static Future<void> updateTask(Task task) async {
    if (await ConnectivityService.isOnline()) {
      await updateTaskOnline(task);
      await DatabaseService().upsertTask(task, isSynced: true);
      return;
    }
    await DatabaseService().upsertTask(task, isSynced: false);
    await DatabaseService().addPendingAction(
        task.taskId, 'task', 'update', data: jsonEncode(task.toJson()));
  }

  static Future<void> deleteTask(String id) async {
    if (await ConnectivityService.isOnline()) {
      await deleteTaskOnline(id);
      await DatabaseService().deleteTask(id);
      return;
    }
    await DatabaseService().deleteTask(id);
    await DatabaseService().addPendingAction(id, 'task', 'delete');
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

  // -------- Online helpers used by the sync service --------
  static Future<Task> createTaskOnline(Task task) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/tasks'),
      headers: headers,
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    throw Exception('Failed to create task');
    }
  }

  static Future<void> updateTaskOnline(Task task) async {
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

  static Future<void> deleteTaskOnline(String id) async {
    final headers = await _headers(isJson: false);
    final response = await http.delete(
      Uri.parse('$apiBaseUrl/api/tasks/$id'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }

}
