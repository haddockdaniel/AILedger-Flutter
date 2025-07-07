import 'package:flutter/material.dart';
import 'package:autoledger/models/customer_model.dart';
import 'package:autoledger/models/invoice_model.dart';
import 'package:autoledger/services/customer_service.dart';
import 'package:autoledger/services/invoice_service.dart';
import 'package:autoledger/theme/app_theme.dart';
import 'package:autoledger/widgets/skeleton_loader.dart';
import 'package:autoledger/services/ai_insight_service.dart';

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
  double? _riskScore;
  double? _cltv;

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
      try {
        final risk = await AIInsightService.latePaymentRiskScores(
            invoices: invoices, customers: [customer]);
        final cltv = await AIInsightService.predictCustomerLifetimeValue(
            invoices: invoices, customers: [customer]);
        _riskScore = risk.isNotEmpty ? risk.first['score'] as double : null;
        _cltv = cltv.isNotEmpty ? cltv.first['cltv'] as double : null;
      } catch (_) {
        _riskScore = null;
        _cltv = null;
      }
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
    if (_loading) return const Center(child: SkeletonLoader(itemCount: 4));

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
          if (_riskScore != null || _cltv != null)
            Card(
              elevation: 2,
              child: ListTile(
                title: const Text('AI Insights'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_riskScore != null)
                      Text('Late Payment Risk: ${_riskScore!.toStringAsFixed(2)}%'),
                    if (_cltv != null)
                      Text('Predicted CLTV: $${_cltv!.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
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
