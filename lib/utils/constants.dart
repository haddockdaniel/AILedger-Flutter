import 'dart:async';
import 'package:autoledger/services/auth_service.dart';

/// Base URL for all API calls. When running in production provide
/// `--dart-define=API_BASE_URL=https://example.com` at build time.
const String apiBaseUrl =
    String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');

const String awsRegion = String.fromEnvironment('AWS_REGION', defaultValue: 'us-east-1');
const String awsBucket = String.fromEnvironment('AWS_BUCKET', defaultValue: '');
const String awsAccessKey = String.fromEnvironment('AWS_ACCESS_KEY', defaultValue: '');
const String awsSecretKey = String.fromEnvironment('AWS_SECRET_KEY', defaultValue: '');

/// Endpoint used by the [VoiceAssistant] to resolve intents.
/// Defaults to the voice intent endpoint of [apiBaseUrl].
const String voiceIntentUrl = String.fromEnvironment(
    'VOICE_INTENT_URL',
    defaultValue: '$apiBaseUrl/api/voice/intent');

/// API key used for authenticating requests to the voice intent service.
const String voiceApiKey =
    String.fromEnvironment('VOICE_API_KEY', defaultValue: '');

/// Tenant identifier used for multi-tenant API requests.
/// Can be provided via `--dart-define=TENANT_ID=mytenant` at build time.
const String defaultTenantId =
    String.fromEnvironment('TENANT_ID', defaultValue: '');

/// Header key for passing the tenant id to the backend API.
const String tenantHeaderKey = 'X-Tenant-ID';

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