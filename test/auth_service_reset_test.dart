import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:autoledger/services/auth_service.dart';
import 'package:autoledger/utils/constants.dart';

void main() {
  group('AuthService.resetPassword', () {
    test('returns true on success', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), '$apiBaseUrl/api/auth/reset-password');
        final body = jsonDecode(request.body) as Map;
        expect(body['email'], 'foo@example.com');
        return http.Response('', 200);
      });
      final result = await AuthService.resetPassword('foo@example.com', client: client);
      expect(result, isTrue);
    });

    test('returns false on failure', () async {
      final client = MockClient((_) async => http.Response('err', 500));
      final result = await AuthService.resetPassword('foo@example.com', client: client);
      expect(result, isFalse);
    });
  });
}