import 'package:flutter/material.dart';
import 'package:autoledger/models/email_model.dart';
import 'package:autoledger/models/contact_model.dart';
import 'package:autoledger/services/email_service.dart';
import 'package:autoledger/services/contact_service.dart';
import 'package:autoledger/utils/voice_event_bus.dart';
import 'package:autoledger/utils/voice_events.dart';
import 'package:autoledger/widgets/search_bar.dart';
import 'package:autoledger/widgets/skeleton_loader.dart';  // ← new
import 'package:autoledger/widgets/confirmation_dialog.dart';
import 'package:autoledger/theme/app_theme.dart';

class EmailsWidget extends StatefulWidget {
  const EmailsWidget({Key? key}) : super(key: key);

  @override
  State<EmailsWidget> createState() => _EmailsWidgetState();
}

class _EmailsWidgetState extends State<EmailsWidget> {
  List<Email> _emails = [];
  List<Email> _filtered = [];
  List<Contact> _contacts = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    VoiceEventBus().on<VoiceIntentEvent>().listen(_handleVoiceIntent);
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    _contacts = await ContactService.fetchContacts();
    _emails = await EmailService.getEmails();
    _applySearch(_searchCtrl.text);
    setState(() => _loading = false);
  }

  void _applySearch(String q) {
    final term = q.toLowerCase();
    _filtered = _emails.where((e) {
      return e.subject.toLowerCase().contains(term) ||
             e.body.toLowerCase().contains(term);
    }).toList();
    setState(() {});
  }

  Future<void> _handleVoiceIntent(VoiceIntentEvent evt) async {
    switch (evt.intent) {
      case 'compose_email':
        _showEmailForm();
        break;
      case 'edit_email':
        final id = evt.slots?['emailId'];
        if (id != null) {
          final match = _emails.where((e) => e.emailId == id);
          if (match.isNotEmpty) _showEmailForm(edit: match.first);
        }
        break;
      case 'delete_email':
        final id = evt.slots?['emailId'];
        if (id != null) {
          final match = _emails.where((e) => e.emailId == id);
          if (match.isNotEmpty) _deleteEmail(match.first);
        }
        break;
      case 'send_email':
        final id = evt.slots?['emailId'];
        if (id != null) {
          final match = _emails.where((e) => e.emailId == id);
          if (match.isNotEmpty) _sendEmail(match.first);
        }
        break;
      case 'search_emails':
        final q = evt.slots?['query'] ?? '';
        _searchCtrl.text = q;
        _applySearch(q);
        break;
    }
  }

  Future<void> _showEmailForm({Email? edit}) async {
    final subjectCtrl = TextEditingController(text: edit?.subject);
    final bodyCtrl = TextEditingController(text: edit?.body);
    String? contactId = edit?.customerId;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(edit == null ? 'Compose Email' : 'Edit Email'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: contactId,
                decoration: const InputDecoration(labelText: 'Contact'),
                items: _contacts
                    .map((c) => DropdownMenuItem(
                          value: c.contactId,
                          child: Text('${c.firstName} ${c.lastName}'),
                        ))
                    .toList(),
                onChanged: (v) => contactId = v,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectCtrl,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                decoration: const InputDecoration(labelText: 'Body'),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = Email(
                emailId: edit?.emailId ?? '',
                userId: edit?.userId ?? '',
                customerId: contactId,
                subject: subjectCtrl.text,
                body: bodyCtrl.text,
                createdAt: edit?.createdAt ?? DateTime.now(),
                templateId: edit?.templateId,
              );
              if (edit == null) {
                await EmailService.createEmail(email);
              } else {
                await EmailService.updateEmail(email);
              }
              Navigator.pop(ctx);
              _loadData();
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  Future<void> _deleteEmail(Email e) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Delete Email',
        content: 'Delete email "${e.subject}"?',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        onConfirm: () => Navigator.pop(context, true),
      ),
    );
    if (confirmed == true) {
      await EmailService.deleteEmail(e.emailId);
      _loadData();
    }
  }

  Future<void> _sendEmail(Email e) async {
    await EmailService.sendEmail(e.emailId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email sent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBar(
          controller: _searchCtrl,
          hintText: 'Search emails...',
          onChanged: _applySearch,
        ),
        Expanded(
          child: _loading
              ? const SkeletonLoader()  // ← replaced spinner
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _filtered.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('No emails found')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final e = _filtered[i];
                            final contact = _contacts.firstWhere(
                              (c) => c.contactId == e.customerId,
                              orElse: () => null,
                            );
                            return ListTile(
                              title: Text(e.subject),
                              subtitle: Text(contact != null
                                  ? '${contact.firstName} ${contact.lastName}'
                                  : 'No contact'),
                              onTap: () => _showEmailForm(edit: e),
                              onLongPress: () => _deleteEmail(e),
                              trailing: IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () => _sendEmail(e),
                              ),
                            );
                          },
                        ),
                ),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'addEmail',
          tooltip: 'Compose Email',
          child: const Icon(Icons.email),
          onPressed: () => _showEmailForm(),
        ),
      ],
    );
  }
}
