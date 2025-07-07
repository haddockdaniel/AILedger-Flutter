import 'package:flutter/material.dart';
import 'package:autoledger/models/customer_model.dart';
import 'package:autoledger/services/customer_service.dart';
import 'package:autoledger/utils/voice_event_bus.dart';
import 'package:autoledger/utils/search_bar.dart';
import 'package:autoledger/theme/app_theme.dart';
import 'package:autoledger/widgets/customer_detail.dart';
import 'package:autoledger/widgets/empty_state.dart';

class CustomersWidget extends StatefulWidget {
  const CustomersWidget({Key? key}) : super(key: key);

  @override
  State<CustomersWidget> createState() => _CustomersWidgetState();
}

class _CustomersWidgetState extends State<CustomersWidget> {
  final CustomerService _customerService = CustomerService();
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    VoiceEventBus().on<VoiceCommandEvent>().listen(_handleVoiceCommand);
    VoiceEventBus().on<VoiceEvent>().listen(_handleVoiceEvent);
  }

  void _loadCustomers() async {
    final customers = await _customerService.fetchCustomers();
    setState(() {
      _customers = customers;
      _filteredCustomers = _applySearch(customers, _searchQuery);
    });
  }

  List<Customer> _applySearch(List<Customer> list, String query) {
    return list.where((c) {
      final match = c.fullName.toLowerCase().contains(query.toLowerCase()) ||
          c.email.toLowerCase().contains(query.toLowerCase()) ||
          c.phone.contains(query);
      return match;
    }).toList();
  }

  void _handleVoiceCommand(VoiceCommandEvent event) {
    final intent = event.intent;
    final data = intent.data;

    switch (intent.command) {
      case 'add_customer':
        _showCustomerForm();
        break;
      case 'search_customer':
        setState(() {
          _searchQuery = data['query'] ?? '';
          _filteredCustomers = _applySearch(_customers, _searchQuery);
        });
        break;
      case 'delete_customer':
        final id = data['customerId'];
        _deleteCustomer(id);
        break;
      case 'view_customer':
        final id = data['customerId'];
        final match = _customers.firstWhere((c) => c.customerId == id,
            orElse: () => Customer.empty());
        if (match.customerId.isNotEmpty) _openDetail(match);
        break;
    }
  }
  
    Future<void> _handleVoiceEvent(VoiceEvent evt) async {
    if (evt.type != 'action') return;
    switch (evt.payload) {
      case 'customer.delete':
        final id = evt.data['customerId'];
        if (id != null) {
          await _customerService.deleteCustomer(id.toString());
          _loadCustomers();
        }
        break;
    }
  }

  void _showCustomerForm([Customer? existing]) {
    final nameController =
        TextEditingController(text: existing?.fullName ?? '');
    final emailController = TextEditingController(text: existing?.email ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    String invoicePref = existing?.invoicePreference ?? 'email';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Customer' : 'Edit Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: invoicePref,
              decoration:
                  const InputDecoration(labelText: 'Invoice Preference'),
              items: const [
                DropdownMenuItem(value: 'email', child: Text('Email')),
                DropdownMenuItem(value: 'text', child: Text('Text')),
              ],
              onChanged: (val) => invoicePref = val ?? 'email',
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final customer = Customer.basic(
                customerId: existing?.customerId ?? '',
                fullName: nameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
                invoicePreference: invoicePref,
              );
              if (existing == null) {
                await _customerService.addCustomer(customer);
              } else {
                await _customerService.updateCustomer(customer);
              }
              Navigator.pop(ctx);
              _loadCustomers();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomer(String id) async {
    await _customerService.deleteCustomer(id);
    _loadCustomers();
  }

  void _openDetail(Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CustomerDetail(customerId: customer.customerId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBar(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _filteredCustomers = _applySearch(_customers, value);
            });
          },
          hintText: 'Search customers...',
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _filteredCustomers.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 200),
                    EmptyState(
                      assetPath:
                          'lib/assets/illustrations/empty_contacts.png',
                      title: 'No customers found',
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: _filteredCustomers.length,
                  itemBuilder: (ctx, index) {
                    final customer = _filteredCustomers[index];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        title: Text(customer.fullName),
                        subtitle: Text('${customer.email} | ${customer.phone}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showCustomerForm(customer),
                        ),
                        onTap: () => _openDetail(customer),
                        onLongPress: () => _deleteCustomer(customer.customerId),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Customer'),
          onPressed: _showCustomerForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentColor,
          ),
        ),
      ],
    );
  }
}
