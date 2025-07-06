import 'package:flutter/material.dart';
import 'package:autoledger/models/invoice_model.dart';
import 'package:autoledger/services/invoice_service.dart';
import 'package:autoledger/theme/app_theme.dart';
import 'package:autoledger/utils/voice_assistant.dart';
import 'package:autoledger/utils/voice_event_bus.dart';
import 'package:autoledger/utils/voice_events.dart';
import 'package:autoledger/screens/widgets/template_picker.dart';
import 'package:autoledger/screens/widgets/invoice_detail.dart';
import 'package:autoledger/widgets/skeleton_loader.dart';  // ← new

class InvoicesWidget extends StatefulWidget {
  @override
  _InvoicesWidgetState createState() => _InvoicesWidgetState();
}

class _InvoicesWidgetState extends State<InvoicesWidget> {
  List<Invoice> invoices = [];
  List<Invoice> filteredInvoices = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadInvoices();
    VoiceEventBus().onEvent('refresh_invoices', (_) => loadInvoices());
    VoiceEventBus().onEvent('search_invoices', (query) {
      _searchController.text = query;
      applySearchFilter(query);
    });
    VoiceEventBus().onEvent('navigate_invoice_detail', (id) {
      final match = invoices.firstWhere(
        (i) => i.invoiceId.toString() == id.toString(),
        orElse: () => null,
      );
      if (match != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InvoiceDetail(invoiceId: match.invoiceId)),
        );
      }
    });
    VoiceEventBus().on<VoiceIntentEvent>().listen(_handleVoiceIntent);
    VoiceEventBus().on<VoiceEvent>().listen(_handleVoiceEvent);
  }

  Future<void> loadInvoices() async {
    setState(() => isLoading = true);
    final loaded = await InvoiceService.getInvoices();
    setState(() {
      invoices = loaded;
      filteredInvoices = loaded;
      isLoading = false;
    });
  }

  void applySearchFilter(String query) {
    setState(() {
      filteredInvoices = invoices.where((invoice) {
        final q = query.toLowerCase();
        return invoice.customerName.toLowerCase().contains(q) ||
            invoice.status.toLowerCase().contains(q) ||
            invoice.notes.toLowerCase().contains(q);
      }).toList();
    });
  }

  void triggerAddInvoice() {
    VoiceAssistant().simulateCommand("Add invoice");
  }

  void showTemplateSelector() async {
    final template = await showModalBottomSheet(
      context: context,
      builder: (_) => TemplatePicker(type: 'invoice'),
    );
    if (template != null) {
      VoiceAssistant().simulateCommand("Use template ${template['name']}");
    }
  }

  void openInvoiceDetail(Invoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceDetail(invoiceId: invoice.invoiceId),
      ),
    );
  }
  
  Future<void> _handleVoiceIntent(VoiceIntentEvent evt) async {
    switch (evt.intent) {
      case 'send_invoice_reminder':
        final name = (evt.slots?['customer'] ?? evt.slots?['contact'])?.toString();
        if (name == null) return;
        final lower = name.toLowerCase();
        Invoice? match;
        for (final i in invoices) {
          if (i.customerName.toLowerCase() == lower &&
              i.status.toLowerCase().contains('overdue')) {
            match = i;
            break;
          }
        }
        if (match != null) {
          await InvoiceService.sendPastDueReminder(match.invoiceId.toString());
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Reminder sent to $name')),
            );
          }
        }
        break;
    }
  }
  
    Future<void> _handleVoiceEvent(VoiceEvent evt) async {
    if (evt.type != 'action') return;
    switch (evt.payload) {
      case 'invoice.write_off':
        final id = evt.data['invoiceId']?.toString();
        if (id != null) {
          await InvoiceService.writeOffInvoice(id);
          await loadInvoices();
        }
        break;
      case 'invoice.send':
        final id = evt.data['invoiceId']?.toString();
        if (id != null) {
          await InvoiceService.sendInvoice(id);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Invoices'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: "Generate Report",
            onPressed: () => VoiceAssistant().simulateCommand("Generate invoice report"),
          ),
          IconButton(
            icon: Icon(Icons.mic),
            tooltip: "Voice Command",
            onPressed: () => VoiceAssistant().startListening(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor,
        onPressed: triggerAddInvoice,
        child: Icon(Icons.add),
        tooltip: "Create Invoice",
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              onChanged: applySearchFilter,
              decoration: InputDecoration(
                labelText: 'Search invoices or proposals',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const SkeletonLoader() // ← replaced spinner
                : RefreshIndicator(
                    onRefresh: loadInvoices,
                    child: filteredInvoices.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 200),
                              Center(child: Text('No invoices found')),
                            ],
                          )
                        : ListView.builder(
                            itemCount: filteredInvoices.length,
                            itemBuilder: (context, index) {
                              final invoice = filteredInvoices[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                child: ListTile(
                                  title: Text(
                                    '${invoice.customerName} - \$${invoice.total.toStringAsFixed(2)}'
                                  ),
                                  subtitle: Text(
                                    '${invoice.status} • ${invoice.createdAt.toLocal().toShortDateString()}'
                                  ),
                                  trailing: Icon(Icons.chevron_right),
                                  onTap: () => openInvoiceDetail(invoice),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
