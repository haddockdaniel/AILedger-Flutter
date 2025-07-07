import 'package:flutter/material.dart';
import 'package:autoledger/models/invoice_model.dart';
import 'package:autoledger/models/customer_model.dart';
import 'package:autoledger/services/invoice_service.dart';
import 'package:autoledger/services/customer_service.dart';
import 'package:autoledger/theme/app_theme.dart';

class InvoiceDetail extends StatefulWidget {
  final int invoiceId;

  const InvoiceDetail({Key? key, required this.invoiceId}) : super(key: key);

  @override
  State<InvoiceDetail> createState() => _InvoiceDetailState();
}

class _InvoiceDetailState extends State<InvoiceDetail> {
  Invoice? _invoice;
  Customer? _customer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    try {
      final invoice = await InvoiceService.getInvoiceById(widget.invoiceId);
      final customer =
          await CustomerService.getCustomerById(invoice.customerId);

      setState(() {
        _invoice = invoice;
        _customer = customer;
        _loading = false;
      });
    } catch (e) {
      print('Error loading invoice: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _writeOffInvoice() async {
    if (_invoice == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Write Off Invoice"),
        content: const Text("Are you sure you want to write off this invoice?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes")),
        ],
      ),
    );
    if (confirmed == true) {
      await InvoiceService.writeOffInvoice(_invoice!.invoiceId);
      await _loadInvoice();
    }
  }

  Future<void> _cancelInvoice() async {
    if (_invoice == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel Invoice"),
        content: const Text(
            "Are you sure you want to cancel this invoice? This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes")),
        ],
      ),
    );
    if (confirmed == true) {
      await InvoiceService.cancelInvoice(_invoice!.invoiceId);
      Navigator.pop(context);
    }
  }

  Widget _buildLineItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _invoice!.lineItems.map((item) {
        return ListTile(
          title: Text(item.description),
          subtitle: Text(
              "Qty: ${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}"),
          trailing: Text(
            "\$${(item.quantity * item.unitPrice).toStringAsFixed(2)}",
            style: AppTheme.subHeaderStyle,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_invoice == null || _customer == null) {
      return const Center(child: Text("Invoice not found."));
    }

    final isPaid = _invoice!.isPaid;
    final isWrittenOff = _invoice!.isWrittenOff;
    final isCanceled = _invoice!.isCanceled;

    return Scaffold(
      appBar: AppBar(title: Text("Invoice #${_invoice!.invoiceNumber}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Customer: ${_customer!.fullName}",
                style: AppTheme.headerStyle),
            Text("Email: ${_customer!.email}"),
            Text("Phone: ${_customer!.phone}"),
            const Divider(height: 32),
            _buildLineItems(),
            const Divider(),
            if (_invoice!.taxAmount > 0)
              ListTile(
                title: const Text("Tax"),
                trailing: Text("\$${_invoice!.taxAmount.toStringAsFixed(2)}"),
              ),
            ListTile(
              title: const Text("Total",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(
                "\$${_invoice!.total.toStringAsFixed(2)}",
                style: AppTheme.headerStyle,
              ),
            ),
            const SizedBox(height: 16),
            Text(
                "Status: ${isCanceled ? 'Canceled' : isWrittenOff ? 'Written Off' : isPaid ? 'Paid' : 'Unpaid'}"),
            if (!isPaid && !isCanceled && !isWrittenOff)
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.money_off),
                    label: const Text("Write Off"),
                    onPressed: _writeOffInvoice,
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: const Text("Cancel"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
                    onPressed: _cancelInvoice,
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // Placeholder for future AI insights
          ],
        ),
      ),
    );
  }
}
