import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptParser {
  static Future<Map<String, dynamic>> parseReceipt(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognized = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    final text = recognized.text;
    final vendor = _extractVendor(text);
    final total = _extractTotal(text);
    final date = _extractDate(text);
    final subtotal = _extractSubtotal(text);
    final tax = _extractTax(text);

    return {
      'vendor': vendor,
      'amount': total,
      'date': date,
      'subtotal': subtotal,
      'tax': tax,
    };
  }

  static String _extractVendor(String text) {
    final lines = text.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (RegExp(r'^(store|vendor|merchant|from)[:\s]', caseSensitive: false)
          .hasMatch(trimmed)) {
        return trimmed.split(':').last.trim();
      }
      // Use first non-empty line as fallback
      if (trimmed.length > 3) return trimmed;
    }
    return '';
  }

  static double _extractSubtotal(String text) {
    final regex = RegExp(r'subtotal\s*[:\-]?\s*\$?(\d+[\.\d{2}]*)',
        caseSensitive: false);
    final match = regex.firstMatch(text);
    return match != null ? double.tryParse(match.group(1)!) ?? 0 : 0;
  }

  static double _extractTax(String text) {
    final regex =
        RegExp(r'(?:tax|vat)\s*[:\-]?\s*\$?(\d+[\.\d{2}]*)', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match != null ? double.tryParse(match.group(1)!) ?? 0 : 0;
  }

  static double _extractTotal(String text) {
    final regex = RegExp(
        r'(?:total|amount due|amount)\s*[:\-]?\s*\$?(\d+[\.\d{2}]*)',
        caseSensitive: false);
    final matches = regex.allMatches(text);
    if (matches.isNotEmpty) {
      final match = matches.last;
      return double.tryParse(match.group(1)!) ?? 0;
    }
    return 0;
  }

  static DateTime _extractDate(String text) {
    final patterns = [
      RegExp(r'(\d{1,2}[\-/]\d{1,2}[\-/]\d{2,4})'),
      RegExp(r'(\d{4}[\-/]\d{1,2}[\-/]\d{1,2})'),
    ];
    for (final regex in patterns) {
      final match = regex.firstMatch(text);
      if (match != null) {
        final raw = match.group(1)!;
        try {
          return DateTime.parse(raw.replaceAll('/', '-'));
        } catch (_) {}
      }
    }
    return DateTime.now();
  }
  
}