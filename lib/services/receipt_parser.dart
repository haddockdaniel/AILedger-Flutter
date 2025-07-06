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
    final amount = _extractAmount(text);
    final date = _extractDate(text);

    return {
      'vendor': vendor,
      'amount': amount,
      'date': date,
    };
  }

  static String _extractVendor(String text) {
    final lines = text.split("\n");
    return lines.isNotEmpty ? lines.first.trim() : "";
  }
  static double _extractAmount(String text) {
    final regex = RegExp(r'(?:total|amount)\s*[:\-]?\s*\$?(\d+[\.\d{2}]*)', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match != null ? double.tryParse(match.group(1)!) ?? 0 : 0;
  }

  static DateTime _extractDate(String text) {
    final regex = RegExp(r'(\d{1,2}[\-/]\d{1,2}[\-/]\d{2,4})');
    final match = regex.firstMatch(text);
    if (match != null) {
      final raw = match.group(1)!;
      try {
        return DateTime.parse(raw.replaceAll('/', '-'));
      } catch (_) {}
    }
    return DateTime.now();
  }
}