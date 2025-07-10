import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceSettingsProvider extends ChangeNotifier {
  static const _enabledKey = 'voice_enabled';
  static const _offlineKey = 'voice_offline_only';
  static const _customKey = 'voice_custom_cmds';

  bool _enabled = true;
  bool _offlineOnly = false;
  Map<String, String> _customCommands = {};

  bool get isEnabled => _enabled;
  bool get offlineOnly => _offlineOnly;
  Map<String, String> get customCommands => _customCommands;

  VoiceSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? true;
    _offlineOnly = prefs.getBool(_offlineKey) ?? false;
    final custom = prefs.getString(_customKey);
    if (custom != null) {
      final Map<String, dynamic> json = jsonDecode(custom);
      _customCommands = json.map((k, v) => MapEntry(k, v.toString()));
    }
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    notifyListeners();
  }

  Future<void> setOfflineOnly(bool value) async {
    _offlineOnly = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineKey, value);
    notifyListeners();
  }

  Future<void> addCustomCommand(String phrase, String intent) async {
    _customCommands[phrase.toLowerCase()] = intent;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customKey, jsonEncode(_customCommands));
    notifyListeners();
  }

  Future<void> removeCustomCommand(String phrase) async {
    _customCommands.remove(phrase.toLowerCase());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customKey, jsonEncode(_customCommands));
    notifyListeners();
  }
}
