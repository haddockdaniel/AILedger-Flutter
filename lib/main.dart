import 'package:flutter/material.dart';
import 'package:autoledger/app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(const AutoLedgerApp());
}
