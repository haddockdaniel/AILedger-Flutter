import 'package:flutter/material.dart';
import 'package:autoledger/models/task_model.dart';
import 'package:autoledger/models/contact_model.dart';
import 'package:autoledger/services/task_service.dart';
import 'package:autoledger/services/contact_service.dart';
import 'package:autoledger/widgets/loading_indicator.dart';
import 'package:autoledger/theme/app_theme.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? editTask;

  const TaskFormScreen({Key? key, this.editTask}) : super(key: key);

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descCtrl;
  DateTime? _dueDate;
  String? _priority;
  bool _autoReminders = false;
  Contact? _selectedContact;
  List<Contact> _contacts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.editTask?.description);
    _dueDate = widget.editTask?.dueDate;
    _priority = widget.editTask?.priority;
    _autoReminders = widget.editTask?.autoReminders ?? false;
    if (widget.editTask?.customerId != null) {
      ContactService.getContactById(widget.editTask!.customerId!)
          .then((c) => setState(() => _selectedContact = c));
    }
    // load contacts for dropdown
    ContactService.fetchContacts().then((list) {
      setState(() {
        _contacts = list;
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final t = Task(
      taskId: widget.editTask?.taskId ?? '',
      userId: widget.editTask?.userId ?? '',
      description: _descCtrl.text.trim(),
      entryDate: widget.editTask?.entryDate ?? DateTime.now(),
      dueDate: _dueDate ?? DateTime.now(),
      isCompleted: widget.editTask?.isCompleted ?? false,
      priority: _priority ?? 'Medium',
      customerId: _selectedContact?.contactId,
      autoReminders: _autoReminders,
    );
    if (widget.editTask == null) {
      await TaskService.createTask(t);
    } else {
      await TaskService.updateTask(t);
    }
    Navigator.pop(context, t);
  }

  @override
  Widget build(BuildContext c) {
    final isEdit = widget.editTask != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : 'New Task'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _loading
          ? const LoadingIndicator()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(labelText: 'Description'),
                      validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: Text(_dueDate == null
                          ? 'Pick due date'
                          : 'Due: ${_dueDate!.toLocal().toShortDateString()}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDueDate,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _priority,
                      items: ['Low', 'Normal', 'High']
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (v) => setState(() => _priority = v),
                      decoration: const InputDecoration(labelText: 'Priority'),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('Auto Reminders'),
                      value: _autoReminders,
                      onChanged: (v) => setState(() => _autoReminders = v!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Contact>(
                      value: _selectedContact,
                      items: _contacts
                          .map((c) => DropdownMenuItem(value: c, child: Text(c.fullName)))
                          .toList(),
                      onChanged: (c) => setState(() => _selectedContact = c),
                      decoration: const InputDecoration(labelText: 'Link to Contact (optional)'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _save,
                      child: Text(isEdit ? 'Update Task' : 'Create Task'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

extension on DateTime {
  String toShortDateString() =>
      '${this.month}/${this.day}/${this.year}';
}
