import 'dart:async';
import 'email_service.dart';
import '../models/email_model.dart';
import '../models/task_model.dart';
import '../models/invoice_model.dart';
import 'notification_service.dart';
import 'calendar_service.dart';

/// Simple in-memory scheduler for demo purposes.
class SchedulerService {
  static final Map<String, Timer> _timers = {};
  static final Map<String, Timer> _taskTimers = {};
  static final Map<int, Timer> _invoiceTimers = {};

  /// Schedule sending [email] at [sendAt].
  static Future<void> scheduleEmail(Email email, DateTime sendAt) async {
    final duration = sendAt.difference(DateTime.now());
    if (duration.isNegative) {
      // If time already passed, send immediately
      await EmailService.sendEmail(email.emailId);
      return;
    }
    _timers[email.emailId]?.cancel();
    _timers[email.emailId] = Timer(duration, () async {
      await EmailService.sendEmail(email.emailId);
      _timers.remove(email.emailId);
    });
  }

  /// Cancel a scheduled email if it hasn't been sent yet.
  static void cancelEmail(String emailId) {
    _timers[emailId]?.cancel();
    _timers.remove(emailId);
  }
  
  static void scheduleTaskReminder(
    Task task,
    DateTime remindAt,
    Function onReminder,
  ) {
    final duration = remindAt.difference(DateTime.now());
    if (duration.isNegative) {
      onReminder();
	        NotificationService.scheduleNotification(
        task.taskId.hashCode,
        'Task Due',
        task.description,
        DateTime.now().add(const Duration(seconds: 1)),
      );
      return;
    }
    _taskTimers[task.taskId]?.cancel();
    _taskTimers[task.taskId] = Timer(duration, () {
      onReminder();
      _taskTimers.remove(task.taskId);
    });
    NotificationService.scheduleNotification(
      task.taskId.hashCode,
      'Task Due',
      task.description,
      remindAt,
    );
	    CalendarService.getTaskEvent(task.taskId).then((existing) async {
      if (existing != null) return;
      final id = await CalendarService.createEvent(
        title: 'Task: ${task.description}',
        description: 'Task due',
        start: remindAt,
        end: remindAt.add(const Duration(hours: 1)),
      );
      if (id != null) {
        await CalendarService.saveTaskEvent(task.taskId, id);
      }
    });
  }

  static void cancelTask(String taskId) {
    _taskTimers[taskId]?.cancel();
    _taskTimers.remove(taskId);
            NotificationService.cancel(taskId.hashCode);
    CalendarService.getTaskEvent(taskId).then((id) {
      CalendarService.deleteEvent(id);
      CalendarService.removeTaskEvent(taskId);
    });
  }

  static void scheduleInvoiceReminder(
    Invoice invoice,
    DateTime remindAt,
    Function onReminder,
  ) {
    final duration = remindAt.difference(DateTime.now());
    if (duration.isNegative) {
      onReminder();
      NotificationService.scheduleNotification(
        invoice.invoiceId,
        'Invoice Due',
        'Invoice #${invoice.invoiceNumber} is due',
        DateTime.now().add(const Duration(seconds: 1)),
      );
      return;
    }
    _invoiceTimers[invoice.invoiceId]?.cancel();
    _invoiceTimers[invoice.invoiceId] = Timer(duration, () {
      onReminder();
      _invoiceTimers.remove(invoice.invoiceId);
    });
    NotificationService.scheduleNotification(
      invoice.invoiceId,
      'Invoice Due',
      'Invoice #${invoice.invoiceNumber} is due',
      remindAt,
    );
	    CalendarService.getInvoiceEvent(invoice.invoiceId).then((existing) async {
      if (existing != null) return;
      final id = await CalendarService.createEvent(
        title: 'Invoice #${invoice.invoiceNumber} due',
        description: 'Invoice payment due',
        start: remindAt,
        end: remindAt.add(const Duration(hours: 1)),
      );
      if (id != null) {
        await CalendarService.saveInvoiceEvent(invoice.invoiceId, id);
      }
    });
  }

  static void cancelInvoice(int invoiceId) {
    _invoiceTimers[invoiceId]?.cancel();
    _invoiceTimers.remove(invoiceId);
    NotificationService.cancel(invoiceId);
	    CalendarService.getInvoiceEvent(invoiceId).then((id) {
      CalendarService.deleteEvent(id);
      CalendarService.removeInvoiceEvent(invoiceId);
    });
  }
  
}