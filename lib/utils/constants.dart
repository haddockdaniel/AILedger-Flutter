import 'dart:async';
import 'package:autoledger/services/auth_service.dart';

class SessionManager {
  static final _authService = AuthService();
  static Timer? _refreshTimer;

  static Future<void> initializeSessionRefresh() async {
    // Refresh every 14 minutes to avoid token expiration
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 14), (_) async {
      await _authService.refresh();
    });
  }

  static void stop() {
    _refreshTimer?.cancel();
  }
}