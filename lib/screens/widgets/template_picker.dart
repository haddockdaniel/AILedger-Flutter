import 'package:flutter/material.dart';

class TemplatePicker extends StatefulWidget {
  final List<String> templateNames;
  final String selectedTemplate;
  final void Function(String) onTemplateSelected;
  final VoidCallback onEditTemplate;
  final VoidCallback onCreateTemplate;
  final String contextLabel;
  final String? aiSuggestion;
  final bool isVoiceEnabled;
  final void Function()? onVoiceTrigger;

  const TemplatePicker({
    Key? key,
    required this.templateNames,
    required this.selectedTemplate,
    required this.onTemplateSelected,
    required this.onEditTemplate,
    required this.onCreateTemplate,
    required this.contextLabel,
    this.aiSuggestion,
    this.isVoiceEnabled = false,
    this.onVoiceTrigger,
  }) : super(key: key);

  @override
  State<TemplatePicker> createState() => _TemplatePickerState();
}

class _TemplatePickerState extends State<TemplatePicker> {
  late String currentSelection;

  @override
  void initState() {
    super.initState();
    currentSelection = widget.selectedTemplate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select ${widget.contextLabel} Template"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.aiSuggestion != null && widget.aiSuggestion!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Suggested: ${widget.aiSuggestion!}",
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          DropdownButtonFormField<String>(
            value: currentSelection.isNotEmpty ? currentSelection : null,
            decoration: const InputDecoration(
              labelText: "Template",
              border: OutlineInputBorder(),
            ),
            items: widget.templateNames
                .map((name) => DropdownMenuItem(
                      value: name,
                      child: Text(name),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  currentSelection = value;
                });
                widget.onTemplateSelected(value);
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: widget.onEditTemplate,
                icon: const Icon(Icons.edit),
                label: const Text("Edit"),
              ),
              ElevatedButton.icon(
                onPressed: widget.onCreateTemplate,
                icon: const Icon(Icons.add),
                label: const Text("New"),
              ),
              if (widget.isVoiceEnabled && widget.onVoiceTrigger != null)
                IconButton(
                  icon: const Icon(Icons.mic),
                  tooltip: 'Voice Select',
                  onPressed: widget.onVoiceTrigger,
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
