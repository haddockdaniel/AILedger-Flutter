import 'package:flutter/material.dart';
import 'package:autoledger/app.dart';
import 'services/notification_service.dart';
import 'services/calendar_service.dart';
import 'services/database_service.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await CalendarService.initialize();
  await DatabaseService().database;
  SyncService();
  runApp(const AutoLedgerApp());
}
