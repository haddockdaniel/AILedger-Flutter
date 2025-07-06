import 'dart:async';
import 'email_service.dart';
import '../models/email_model.dart';
import '../models/task_model.dart';

/// Simple in-memory scheduler for demo purposes.
class SchedulerService {
  static final Map<String, Timer> _timers = {};
    static final Map<String, Timer> _taskTimers = {};

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
      return;
    }
    _taskTimers[task.taskId]?.cancel();
    _taskTimers[task.taskId] = Timer(duration, () {
      onReminder();
      _taskTimers.remove(task.taskId);
    });
  }

  static void cancelTask(String taskId) {
    _taskTimers[taskId]?.cancel();
    _taskTimers.remove(taskId);
  }
  
}