import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/expense_model.dart';
import '../../services/receipt_parser.dart';
import '../../services/s3_service.dart';
import '../../services/expense_service.dart';
import '../../widgets/loading_indicator.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? editExpense;
  const ExpenseFormScreen({Key? key, this.editExpense}) : super(key: key);

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vendorCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  File? _receipt;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final exp = widget.editExpense;
    if (exp != null) {
      _vendorCtrl.text = exp.vendor;
      _amountCtrl.text = exp.amount.toStringAsFixed(2);
      _categoryCtrl.text = exp.category;
      _notesCtrl.text = exp.notes ?? '';
      _date = exp.date;
    }
  }

  @override
  void dispose() {
    _vendorCtrl.dispose();
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final file = File(picked.path);
      setState(() => _receipt = file);
      final parsed = await ReceiptParser.parseReceipt(file);
      setState(() {
        _vendorCtrl.text = parsed['vendor'] ?? _vendorCtrl.text;
        if (parsed['amount'] != null && parsed['amount'] > 0) {
          _amountCtrl.text = parsed['amount'].toString();
        }
        if (parsed['date'] != null) {
          _date = parsed['date'];
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      var exp = Expense(
        expenseId: widget.editExpense?.expenseId ?? '',
        userId: widget.editExpense?.userId ?? '',
        vendor: _vendorCtrl.text,
        amount: double.tryParse(_amountCtrl.text) ?? 0,
        category: _categoryCtrl.text,
        notes: _notesCtrl.text,
        date: _date,
        receiptUrl: null,
      );
      String? url;
      if (_receipt != null) {
        final key = 'receipts/${DateTime.now().millisecondsSinceEpoch}.jpg';
        url = await S3Service.uploadReceipt(_receipt!, key);
        exp = Expense(
          expenseId: exp.expenseId,
          userId: exp.userId,
          vendor: exp.vendor,
          amount: exp.amount,
          category: exp.category,
          notes: exp.notes,
          date: exp.date,
          receiptUrl: url,
        );
      }
      if (widget.editExpense == null) {
        await ExpenseService.createExpense(exp);
      } else {
        await ExpenseService.updateExpense(exp.expenseId, exp);
      }
      if (url != null) {
        await ExpenseService.attachReceipt(exp.expenseId, url);
      }
      Navigator.pop(context, exp);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.editExpense == null ? 'New Expense' : 'Edit Expense')),
      body: _loading
          ? const LoadingIndicator()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _vendorCtrl,
                      decoration: const InputDecoration(labelText: 'Vendor'),
                      validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                    ),
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      validator: (v) => (double.tryParse(v ?? '') != null) ? null : 'Required',
                    ),
                    TextFormField(
                      controller: _categoryCtrl,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    TextFormField(
                      controller: _notesCtrl,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    ListTile(
                      title: Text('Date: ${_date.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                    ),
                    if (_receipt != null)
                      Image.file(_receipt!, height: 200),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Capture Receipt'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}