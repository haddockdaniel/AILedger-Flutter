import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/invoice_model.dart';
import '../models/customer_model.dart';
import '../models/task_model.dart';

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'autoledger.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE invoices(
            invoiceId INTEGER PRIMARY KEY,
            data TEXT NOT NULL,
            is_synced INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE customers(
            customerId TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            is_synced INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE tasks(
            taskId TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            is_synced INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE pending_actions(
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            action TEXT NOT NULL,
            data TEXT
          )
        ''');
      },
    );
  }

  // Invoice operations
  Future<void> upsertInvoice(Invoice invoice, {bool isSynced = true}) async {
    final db = await database;
    await db.insert(
      'invoices',
      {
        'invoiceId': invoice.invoiceId,
        'data': jsonEncode(invoice.toJson()),
        'is_synced': isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Invoice>> getInvoices() async {
    final db = await database;
    final rows = await db.query('invoices');
    return rows
        .map((r) => Invoice.fromJson(jsonDecode(r['data'] as String)))
        .toList();
  }

  Future<Invoice?> getInvoice(int id) async {
    final db = await database;
    final rows =
        await db.query('invoices', where: 'invoiceId = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Invoice.fromJson(jsonDecode(rows.first['data'] as String));
  }

  Future<void> deleteInvoice(int id) async {
    final db = await database;
    await db.delete('invoices', where: 'invoiceId = ?', whereArgs: [id]);
  }

  // Customer operations
  Future<void> upsertCustomer(Customer customer, {bool isSynced = true}) async {
    final db = await database;
    await db.insert(
      'customers',
      {
        'customerId': customer.customerId,
        'data': jsonEncode(customer.toJson()),
        'is_synced': isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final rows = await db.query('customers');
    return rows
        .map((r) => Customer.fromJson(jsonDecode(r['data'] as String)))
        .toList();
  }

  Future<Customer?> getCustomer(String id) async {
    final db = await database;
    final rows =
        await db.query('customers', where: 'customerId = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Customer.fromJson(jsonDecode(rows.first['data'] as String));
  }

  Future<void> deleteCustomer(String id) async {
    final db = await database;
    await db.delete('customers', where: 'customerId = ?', whereArgs: [id]);
  }

  // Task operations
  Future<void> upsertTask(Task task, {bool isSynced = true}) async {
    final db = await database;
    await db.insert(
      'tasks',
      {
        'taskId': task.taskId,
        'data': jsonEncode(task.toJson()),
        'is_synced': isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final rows = await db.query('tasks');
    return rows
        .map((r) => Task.fromJson(jsonDecode(r['data'] as String)))
        .toList();
  }

  Future<Task?> getTask(String id) async {
    final db = await database;
    final rows = await db.query('tasks', where: 'taskId = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Task.fromJson(jsonDecode(rows.first['data'] as String));
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'taskId = ?', whereArgs: [id]);
  }

  // Pending actions
  Future<void> addPendingAction(String id, String type, String action,
      {String? data}) async {
    final db = await database;
    await db.insert(
      'pending_actions',
      {'id': id, 'type': type, 'action': action, 'data': data},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingActions(String type) async {
    final db = await database;
    return db.query('pending_actions', where: 'type = ?', whereArgs: [type]);
  }

  Future<void> removePendingAction(String id) async {
    final db = await database;
    await db.delete('pending_actions', where: 'id = ?', whereArgs: [id]);
  }
}
