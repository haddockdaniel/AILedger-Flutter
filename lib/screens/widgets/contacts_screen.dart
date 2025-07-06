import 'dart:io';

import 'package:flutter/material.dart';
import 'package:autoledger/models/contact_model.dart';
import 'package:autoledger/services/contact_service.dart';
import 'package:autoledger/widgets/search_bar.dart';
import 'package:autoledger/widgets/loading_indicator.dart';
import 'package:autoledger/widgets/skeleton_loader.dart';       // ← new
import 'package:autoledger/screens/widgets/contact_form_screen.dart';
import 'package:autoledger/screens/widgets/contact_detail_screen.dart';
import 'package:autoledger/utils/voice_event_bus.dart';
import 'package:autoledger/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _all = [];
  List<Contact> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    VoiceEventBus().on().listen(_handleVoiceIntent);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _all = await ContactService.fetchContacts();
    _applySearch(_searchCtrl.text);
    setState(() => _loading = false);
  }

  void _applySearch(String q) {
    final term = q.toLowerCase();
    _filtered = _all.where((c) =>
        c.firstName.toLowerCase().contains(term) ||
        c.lastName.toLowerCase().contains(term) ||
        (c.businessName?.toLowerCase().contains(term) ?? false) ||
        (c.email?.toLowerCase().contains(term) ?? false) ||
        (c.phone?.contains(term) ?? false)
    ).toList();
    setState(() {});
  }

  Future<void> _goToForm([Contact? edit]) async {
    await Navigator.push<Contact>(
      context,
      MaterialPageRoute(builder: (_) => ContactFormScreen(editContact: edit)),
    );
    _load();
  }

  Future<void> _goToDetail(Contact c) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContactDetailScreen(contactId: c.contactId)),
    );
    _load();
  }

  Future<void> _scanBusinessCard() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    setState(() => _loading = true);
    try {
      final parsed = await ContactService.parseBusinessCard(File(file.path));
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ContactFormScreen(editContact: parsed)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR failed: $e')),
      );
    } finally {
      _load();
    }
  }

  Future<void> _handleVoiceIntent(VoiceIntentEvent evt) async {
    switch (evt.intent) {
      case 'add_contact':
        _goToForm();
        break;
      case 'edit_contact':
        final id = evt.slots?['identifier'];
        if (id != null) {
          final match = _all.firstWhere(
            (c) => c.email == id || c.phone == id,
            orElse: () => Contact.empty(),
          );
          if (match.contactId.isNotEmpty) _goToForm(match);
        }
        break;
      case 'delete_contact':
        final id = evt.slots?['identifier'];
        if (id != null) {
          final match = _all.firstWhere(
            (c) => c.email == id || c.phone == id,
            orElse: () => Contact.empty(),
          );
          if (match.contactId.isNotEmpty) {
            await ContactService.deleteContact(match.contactId);
            _load();
          }
        }
        break;
      case 'search_contacts':
        final q = evt.slots?['query'] ?? '';
        _searchCtrl.text = q;
        _applySearch(q);
        break;
      case 'show_contact':
        final id = evt.slots?['identifier'];
        if (id != null) {
          final match = _all.firstWhere(
            (c) => c.email == id || c.phone == id,
            orElse: () => Contact.empty(),
          );
          if (match.contactId.isNotEmpty) _goToDetail(match);
        }
        break;
      case 'scan_card':
        _scanBusinessCard();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          SearchBar(
            controller: _searchCtrl,
            hintText: 'Search contacts…',
            onChanged: _applySearch,
          ),
          Expanded(
            child: _loading
                // ← replaced LoadingIndicator with SkeletonLoader
                ? const SkeletonLoader()
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final c = _filtered[i];
                        return ListTile(
                          title: Text('${c.firstName} ${c.lastName}'),
                          subtitle: Text(c.businessName ?? c.email ?? ''),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/contacts/detail',
                            arguments: c.contactId,
                          ).then((_) => _load()),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _goToForm(c),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'scan',
            tooltip: 'Scan Business Card',
            child: const Icon(Icons.camera_alt),
            onPressed: _scanBusinessCard,
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            tooltip: 'Add Contact',
            child: const Icon(Icons.add),
            onPressed: () => _goToForm(),
          ),
        ],
      ),
    );
  }
}
