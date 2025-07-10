import 'dart:convert';

import 'database_service.dart';
import 'connectivity_service.dart';
import 'invoice_service.dart';
import 'customer_service.dart';
import 'task_service.dart';
import '../models/invoice_model.dart';
import '../models/customer_model.dart';
import '../models/task_model.dart';

class SyncService {
  SyncService._internal() {
    ConnectivityService.onStatusChange.listen((online) {
      if (online) syncAll();
    });
  }

  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;

  final _db = DatabaseService();

  Future<void> syncAll() async {
    if (!await ConnectivityService.isOnline()) return;
    await _syncInvoices();
    await _syncCustomers();
    await _syncTasks();
  }

  Future<void> _syncInvoices() async {
    final actions = await _db.getPendingActions('invoice');
    for (final a in actions) {
      final action = a['action'] as String;
      final id = a['id'] as String;
      final dataStr = a['data'] as String?;
      try {
        if (action == 'create') {
          final invoice = Invoice.fromJson(jsonDecode(dataStr!));
          final created = await InvoiceService.createInvoiceOnline(invoice);
          await _db.deleteInvoice(int.parse(id));
          await _db.upsertInvoice(created, isSynced: true);
        } else if (action == 'update') {
          final invoice = Invoice.fromJson(jsonDecode(dataStr!));
          await InvoiceService.updateInvoiceOnline(invoice);
          await _db.upsertInvoice(invoice, isSynced: true);
        } else if (action == 'delete') {
          await InvoiceService.deleteInvoiceOnline(int.parse(id));
        }
        await _db.removePendingAction(id);
      } catch (_) {
        // keep action for next attempt
      }
    }
  }

  Future<void> _syncCustomers() async {
    final actions = await _db.getPendingActions('customer');
    for (final a in actions) {
      final action = a['action'] as String;
      final id = a['id'] as String;
      final dataStr = a['data'] as String?;
      try {
        if (action == 'create') {
          final customer = Customer.fromJson(jsonDecode(dataStr!));
          final created = await CustomerService.createCustomerOnline(customer);
          await _db.deleteCustomer(id);
          await _db.upsertCustomer(created, isSynced: true);
        } else if (action == 'update') {
          final customer = Customer.fromJson(jsonDecode(dataStr!));
          await CustomerService.updateCustomerOnline(customer);
          await _db.upsertCustomer(customer, isSynced: true);
        } else if (action == 'delete') {
          await CustomerService.deleteCustomerOnline(id);
        }
        await _db.removePendingAction(id);
      } catch (_) {}
    }
  }

  Future<void> _syncTasks() async {
    final actions = await _db.getPendingActions('task');
    for (final a in actions) {
      final action = a['action'] as String;
      final id = a['id'] as String;
      final dataStr = a['data'] as String?;
      try {
        if (action == 'create') {
          final task = Task.fromJson(jsonDecode(dataStr!));
          final created = await TaskService.createTaskOnline(task);
          await _db.deleteTask(id);
          await _db.upsertTask(created, isSynced: true);
        } else if (action == 'update') {
          final task = Task.fromJson(jsonDecode(dataStr!));
          await TaskService.updateTaskOnline(task);
          await _db.upsertTask(task, isSynced: true);
        } else if (action == 'delete') {
          await TaskService.deleteTaskOnline(id);
        }
        await _db.removePendingAction(id);
      } catch (_) {}
    }
  }
}