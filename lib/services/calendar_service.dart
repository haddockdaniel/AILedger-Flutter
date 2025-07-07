import 'package:device_calendar/device_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarService {
  static final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();
  static String? _calendarId;

  static Future<void> initialize() async {
    await _ensurePermissions();
    await _getCalendar();
  }

  static Future<void> _ensurePermissions() async {
    final hasPerm = await _plugin.hasPermissions();
    if (hasPerm.isSuccess && !hasPerm.data!) {
      await _plugin.requestPermissions();
    }
  }

  static Future<String?> _getCalendar() async {
    if (_calendarId != null) return _calendarId;
    final cals = await _plugin.retrieveCalendars();
    if (cals.isSuccess && cals.data!.isNotEmpty) {
      final cal = cals.data!.firstWhere(
          (c) => c.isDefault ?? false,
          orElse: () => cals.data!.first);
      _calendarId = cal.id;
    }
    return _calendarId;
  }

  static Future<String?> createEvent(
      {required String title,
      String? description,
      required DateTime start,
      required DateTime end}) async {
    await _ensurePermissions();
    final calId = await _getCalendar();
    if (calId == null) return null;
    final event = Event(calId,
        title: title, description: description, start: start, end: end);
    final res = await _plugin.createOrUpdateEvent(event);
    if (res.isSuccess) {
      return res.data;
    }
    return null;
  }

  static Future<void> deleteEvent(String? eventId) async {
    if (eventId == null) return;
    final calId = await _getCalendar();
    if (calId == null) return;
    await _plugin.deleteEvent(calId, eventId);
  }

  // persistence helpers
  static Future<void> saveTaskEvent(String taskId, String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('task_event_$taskId', eventId);
  }

  static Future<String?> getTaskEvent(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('task_event_$taskId');
  }

  static Future<void> removeTaskEvent(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('task_event_$taskId');
  }

  static Future<void> saveInvoiceEvent(int invoiceId, String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('invoice_event_$invoiceId', eventId);
  }

  static Future<String?> getInvoiceEvent(int invoiceId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('invoice_event_$invoiceId');
  }

  static Future<void> removeInvoiceEvent(int invoiceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('invoice_event_$invoiceId');
  }
}