import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/expense_model.dart';
import '../../models/invoice_model.dart';
import '../../services/expense_service.dart';
import '../../services/invoice_service.dart';
import '../../services/receipt_parser.dart';
import '../../widgets/skeleton_loader.dart';
import '../../theme/app_theme.dart';
import '../../services/scheduler_service.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({Key? key}) : super(key: key);

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  File? _image;
  final _vendorCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _loading = false;
  bool _parsing = false;

  @override
  void dispose() {
    _vendorCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _captureReceipt();
  }

  Future<void> _captureReceipt() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      _parsing = true;
    });
    final parsed = await ReceiptParser.parseReceipt(_image!);
    setState(() {
      _vendorCtrl.text = parsed['vendor'] ?? '';
      final amt = parsed['amount'];
      if (amt != null && amt > 0) {
        _amountCtrl.text = amt.toString();
      }
      if (parsed['date'] != null) {
        _date = parsed['date'];
      }
      _parsing = false;
    });
  }

  Future<void> _createExpense() async {
    setState(() => _loading = true);
    try {
      final expense = Expense(
        expenseId: '',
        userId: '',
        vendor: _vendorCtrl.text,
        amount: double.tryParse(_amountCtrl.text) ?? 0,
        category: 'Receipt',
        notes: 'Scanned via app',
        date: _date,
        receiptUrl: null,
      );
      await ExpenseService.createExpense(expense);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving expense: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createInvoice() async {
    setState(() => _loading = true);
    try {
      final total = double.tryParse(_amountCtrl.text) ?? 0;
      final lineItem = InvoiceLineItem(
        lineItemId: 0,
        invoiceId: 0,
        userId: 0,
        description: 'Receipt Purchase',
        quantity: 1,
        unitPrice: total,
        total: total,
      );
      final invoice = Invoice(
        invoiceId: 0,
        invoiceNumber: '',
        userId: 0,
        customerId: null,
        customerName: _vendorCtrl.text,
        customerEmail: null,
        customerPhone: null,
        invoiceDate: _date,
        dueDate: _date,
        subtotal: total,
        taxRate: 0,
        taxAmount: 0,
        total: total,
        isPaid: true,
        isWrittenOff: false,
        isCanceled: false,
        status: 'Paid',
        paymentLink: null,
        sendAutomatically: false,
        chargeTaxes: false,
        notes: 'Generated from receipt',
        createdAt: DateTime.now(),
        updatedAt: null,
        lineItems: [lineItem],
      );
      final created = await InvoiceService.createInvoice(invoice);
      if (created.dueDate != null && !created.isPaid && !created.isCanceled) {
        SchedulerService.scheduleInvoiceReminder(
          created,
          created.dueDate!,
          () {},
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving invoice: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildForm() {
    return ListView(
      children: [
        if (_image != null) Image.file(_image!, height: 200),
        const SizedBox(height: 12),
        TextField(
          controller: _vendorCtrl,
          decoration: const InputDecoration(labelText: 'Vendor'),
        ),
        TextField(
          controller: _amountCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Total'),
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
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _createExpense,
          child: const Text('Save as Expense'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _createInvoice,
          child: const Text('Save as Invoice'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _captureReceipt,
          ),
        ],
      ),
      body: _parsing
          ? const Center(child: SkeletonLoader(itemCount: 4))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: _buildForm(),
            ),
    );
  }
}