import 'dart:async';
import 'package:autoledger/services/auth_service.dart';

/// Base URL for all API calls. When running in production provide
/// `--dart-define=API_BASE_URL=https://example.com` at build time.
const String apiBaseUrl =
    String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');

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