import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Displays the currently filled voice slots as chips at the top of the screen.
class VoiceSlotOverlay extends StatelessWidget {
  /// A map of slot names → values from the last VoiceIntentEvent
  final Map<String, dynamic> slots;

  const VoiceSlotOverlay({Key? key, required this.slots}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) return const SizedBox.shrink();
    return Positioned(
      top: 56, // just below the AppBar
      left: 16,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.surfaceColor.withOpacity(0.95),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: slots.entries.map((e) {
              final label = e.key;
              final val   = e.value.toString();
              return Chip(
                label: Text('$label: $val'),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
				backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                labelStyle: AppTheme.bodyStyle,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
