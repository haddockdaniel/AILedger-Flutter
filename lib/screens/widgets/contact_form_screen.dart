import 'package:flutter/material.dart';
import 'package:autoledger/models/contact_model.dart';
import 'package:autoledger/services/contact_service.dart';
import 'package:autoledger/theme/app_theme.dart';
import 'package:autoledger/widgets/skeleton_loader.dart';
import 'package:autoledger/utils/voice_event_bus.dart';
import 'package:autoledger/utils/voice_events.dart';

class ContactFormScreen extends StatefulWidget {
  final Contact? editContact;
  const ContactFormScreen({Key? key, this.editContact}) : super(key: key);

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameCtrl, _lastNameCtrl, _businessNameCtrl, _emailCtrl, _phoneCtrl, _notesCtrl;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final c = widget.editContact;
    _firstNameCtrl    = TextEditingController(text: c?.firstName);
    _lastNameCtrl     = TextEditingController(text: c?.lastName);
    _businessNameCtrl = TextEditingController(text: c?.businessName);
    _emailCtrl        = TextEditingController(text: c?.email);
    _phoneCtrl        = TextEditingController(text: c?.phone);
    _notesCtrl        = TextEditingController(text: c?.notes);

    // NEW: support “confirm_save” intent to submit
    VoiceEventBus().on().listen((evt) {
      if (evt.intent == 'confirm_save' && _formKey.currentState!.validate()) {
        _onSave();
      }
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _businessNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final contact = Contact(
        contactId:   widget.editContact?.contactId ?? '',
        userId:      widget.editContact?.userId ?? '',
        firstName:   _firstNameCtrl.text.trim(),
        lastName:    _lastNameCtrl.text.trim(),
        businessName: _businessNameCtrl.text.trim().isEmpty ? null : _businessNameCtrl.text.trim(),
        email:       _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        phone:       _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        notes:       _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      if (widget.editContact == null) {
        await ContactService.createContact(contact);
      } else {
        await ContactService.updateContact(contact);
      }
      Navigator.pop(context, contact);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editContact != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Contact' : 'New Contact'),
      ),
      body: _loading
          ? const SkeletonLoader(itemCount: 6)
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(children: [
                    TextFormField(
                      controller: _firstNameCtrl,
                      decoration: const InputDecoration(labelText: 'First Name'),
                      validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lastNameCtrl,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _businessNameCtrl,
                      decoration: const InputDecoration(labelText: 'Business Name (optional)'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email (optional)'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        return v.contains('@') ? null : 'Invalid email';
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone (optional)'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesCtrl,
                      decoration: const InputDecoration(labelText: 'Notes (optional)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    if (_error != null)
                      Text(
                        _error!,
                        style: AppTheme.bodyStyle.copyWith(color: Colors.red),
                      ),
                    ElevatedButton(
                      onPressed: _onSave,
                      child: Text(isEditing ? 'Update Contact' : 'Create Contact'),
                    ),
                  ]),
                ),
              ),
            ),
    );
  }
}
