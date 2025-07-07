import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class LogoService {
  static const _key = 'user_logo';

  static Future<void> saveLogo(Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final b64 = base64Encode(bytes);
    await prefs.setString(_key, b64);
  }

  static Future<Uint8List?> getLogo() async {
    final prefs = await SharedPreferences.getInstance();
    final b64 = prefs.getString(_key);
    if (b64 == null) return null;
    return base64Decode(b64);
  }

  static Future<void> clearLogo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}