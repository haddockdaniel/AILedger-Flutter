import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/invoice_model.dart';
import 'invoice_detail.dart';

class FilteredInvoices extends StatelessWidget {
  final List<Invoice> invoices;
  final String title;

  const FilteredInvoices({super.key, required this.invoices, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final inv = invoices[index];
          return ListTile(
            title: Text(inv.invoiceNumber),
            subtitle: Text('${inv.customerName} - ${DateFormat.yMd().format(inv.invoiceDate)}'),
            trailing: Text('\$${inv.total.toStringAsFixed(2)}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => InvoiceDetail(invoiceId: inv.invoiceId)),
              );
            },
          );
        },
      ),
    );
  }
}