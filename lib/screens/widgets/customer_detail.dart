import 'package:flutter/material.dart';
import 'package:autoledger/models/customer_model.dart';
import 'package:autoledger/models/invoice_model.dart';
import 'package:autoledger/services/customer_service.dart';
import 'package:autoledger/services/invoice_service.dart';
import 'package:autoledger/theme/app_theme.dart';

class CustomerDetail extends StatefulWidget {
  final String customerId;

  const CustomerDetail({Key? key, required this.customerId}) : super(key: key);

  @override
  State<CustomerDetail> createState() => _CustomerDetailState();
}

class _CustomerDetailState extends State<CustomerDetail> {
  Customer? _customer;
  List<Invoice> _paidInvoices = [];
  List<Invoice> _unpaidInvoices = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    try {
      final customer = await CustomerService.getCustomerById(widget.customerId);
      final invoices =
          await InvoiceService.getInvoicesByCustomerId(widget.customerId);

      setState(() {
        _customer = customer;
        _paidInvoices = invoices.where((inv) => inv.isPaid).toList();
        _unpaidInvoices = invoices.where((inv) => !inv.isPaid).toList();
        _loading = false;
      });
    } catch (e) {
      print('Error loading customer detail: $e');
      setState(() => _loading = false);
    }
  }

  Widget _buildAddressList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _customer!.addresses.map((addr) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.location_on),
            title:
                Text('${addr.street}, ${addr.city}, ${addr.state} ${addr.zip}'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInvoiceList(List<Invoice> invoices, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.sectionHeader),
        ...invoices.map((inv) => Card(
              child: ListTile(
                title: Text(
                    'Invoice #${inv.invoiceNumber} - \$${inv.total.toStringAsFixed(2)}'),
                subtitle:
                    Text('Due: ${inv.dueDate.toLocal().toShortDateString()}'),
                trailing: inv.isPaid
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.warning, color: Colors.orange),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_customer == null) {
      return const Center(child: Text("Customer not found."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_customer!.fullName, style: AppTheme.headerStyle),
          const SizedBox(height: 8),
          Text('Email: ${_customer!.email}'),
          Text('Phone: ${_customer!.phone}'),
          Text('Invoice Preference: ${_customer!.invoicePreference}'),
          const SizedBox(height: 16),
          if (_customer!.addresses.isNotEmpty) _buildAddressList(),
          const SizedBox(height: 16),
          _buildInvoiceList(_unpaidInvoices, 'Unpaid Invoices'),
          const SizedBox(height: 16),
          _buildInvoiceList(_paidInvoices, 'Paid Invoices'),
          const SizedBox(height: 16),
          // Placeholder for future AI insights
        ],
      ),
    );
  }
}

extension _DateHelpers on DateTime {
  String toShortDateString() {
    return "${month}/${day}/${year}";
  }
}
