import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autoledger/services/logo_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saveLogo and getLogo return stored bytes', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    await LogoService.saveLogo(bytes);
    final result = await LogoService.getLogo();
    expect(result, isNotNull);
    expect(result!.toList(), bytes.toList());
  });

  test('clearLogo removes stored logo', () async {
    await LogoService.saveLogo(Uint8List.fromList([4, 5]));
    await LogoService.clearLogo();
    final result = await LogoService.getLogo();
    expect(result, isNull);
  });
}