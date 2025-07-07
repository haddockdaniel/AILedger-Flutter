import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  static Future<void> saveTenantId(String tenantId) async {
    await _storage.write(key: 'tenant_id', value: tenantId);
  }

  static Future<String?> getTenantId() async {
    return await _storage.read(key: 'tenant_id');
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}