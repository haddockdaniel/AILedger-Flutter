import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:autoledger/services/auth_service.dart';
import 'package:autoledger/utils/constants.dart';

void main() {
  group('AuthService.signUp', () {
    test('returns user id when signup succeeds', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), '$apiBaseUrl/api/auth/signup');
        final body = jsonDecode(request.body) as Map;
        expect(body['email'], 'test@example.com');
        expect(body['password'], 'password');
		expect(body['tenantId'], 't1');
        return http.Response(jsonEncode({'userId': 'u123'}), 201);
      });

      final userId = await AuthService.signUp('test@example.com', 'password', tenantId: 't1', client: client);
      expect(userId, 'u123');
    });

    test('throws exception on failure', () async {
      final client = MockClient((_) async => http.Response('bad', 400));
      expect(
        () => AuthService.signUp('a@b.com', 'pass', tenantId: '', client: client),
        throwsA(isA<Exception>()),
      );
    });
  });
}