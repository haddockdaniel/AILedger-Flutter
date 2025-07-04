import 'package:flutter/material.dart';
import 'package:autoledger/theme/app_theme.dart';

/// A generic empty-state display with an illustration and message.
class EmptyState extends StatelessWidget {
  /// Path to the asset image (PNG/SVG) under /assets/.
  final String assetPath;

  /// Primary message (e.g. “No contacts yet”).
  final String title;

  /// Secondary hint (optional).
  final String? subtitle;

  /// Button label and its tap handler (optional).
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    Key? key,
    required this.assetPath,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(assetPath, height: 120),
            const SizedBox(height: 24),
            Text(title,
                style: AppTheme.headerStyle.copyWith(fontSize: 20),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  style: AppTheme.bodyStyle, textAlign: TextAlign.center),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
