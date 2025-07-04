import 'package:flutter/material.dart';
import 'package:autoledger/models/email_model.dart';
import 'package:autoledger/models/contact_model.dart';
import 'package:autoledger/services/email_service.dart';
import 'package:autoledger/services/contact_service.dart';
import 'package:autoledger/utils/voice_event_bus.dart';
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
    // ... existing voice logic unchanged ...
  }

  Future<void> _showEmailForm({Email? edit}) async {
    // ... existing form logic ...
  }

  Future<void> _deleteEmail(Email e) async {
    // ... existing delete logic ...
  }

  Future<void> _sendEmail(Email e) async {
    // ... existing send logic ...
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
