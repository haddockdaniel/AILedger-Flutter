import 'package:flutter/material.dart';
import 'package:autoledger/models/contact_model.dart';
import 'package:autoledger/services/contact_service.dart';
import 'package:autoledger/screens/widgets/contact_form_screen.dart';
import 'package:autoledger/widgets/loading_indicator.dart';
import 'package:autoledger/widgets/confirmation_dialog.dart';
import 'package:autoledger/utils/voice_event_bus.dart';
import 'package:autoledger/utils/voice_events.dart';
import 'package:autoledger/theme/app_theme.dart';

class ContactDetailScreen extends StatefulWidget {
  final String contactId;
  const ContactDetailScreen({Key? key, required this.contactId}) : super(key: key);

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  Contact? _contact;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadContact();
    // NEW: handle voice delete/edit for this contact
    VoiceEventBus().on().listen(_handleVoiceIntent);
  }

  Future<void> _loadContact() async {
    setState(() => _loading = true);
    try {
      _contact = await ContactService.getContactById(widget.contactId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _edit() async {
    if (_contact == null) return;
    final updated = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(builder: (_) => ContactFormScreen(editContact: _contact)),
    );
    if (updated != null) _loadContact();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Delete Contact',
        content: 'Are you sure you want to delete this contact?',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
    if (confirmed == true) {
      await ContactService.deleteContact(widget.contactId);
      Navigator.of(context).pop();
    }
  }

  /// NEW: voice handler for delete/edit on this screen
  void _handleVoiceIntent(VoiceIntentEvent evt) {
    final id = evt.slots?['identifier'];
    if (id == null || id != _contact?.email && id != _contact?.phone) return;
    switch (evt.intent) {
      case 'edit_contact':
        _edit();
        break;
      case 'delete_contact':
        _delete();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: LoadingIndicator());
    if (_contact == null) return const Center(child: Text('Contact not found.'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${_contact!.firstName} ${_contact!.lastName}', style: AppTheme.headerStyle),
          const SizedBox(height: 8),
          if (_contact!.businessName != null) ...[
            Text('Business: ${_contact!.businessName}', style: AppTheme.bodyStyle),
            const SizedBox(height: 4),
          ],
          if (_contact!.email != null) ...[
            Text('Email: ${_contact!.email}', style: AppTheme.bodyStyle),
            const SizedBox(height: 4),
          ],
          if (_contact!.phone != null) ...[
            Text('Phone: ${_contact!.phone}', style: AppTheme.bodyStyle),
            const SizedBox(height: 4),
          ],
          if (_contact!.notes != null && _contact!.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Notes', style: AppTheme.subHeaderStyle),
            const SizedBox(height: 4),
            Text(_contact!.notes!, style: AppTheme.bodyStyle),
          ],
        ]),
      ),
    );
  }
}
