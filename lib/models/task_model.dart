class Task {
  final String taskId;
  final String userId;
  final String description;
  final DateTime entryDate;
  final DateTime dueDate;
  final bool isCompleted;
  final String priority; // e.g., Low, Medium, High
  final String? customerId;
  final bool autoReminders;
  final String? calendarEventId;

  Task({
    required this.taskId,
    required this.userId,
    required this.description,
    required this.entryDate,
    required this.dueDate,
    required this.isCompleted,
    required this.priority,
    this.customerId,
    required this.autoReminders,
    this.calendarEventId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['taskId'],
      userId: json['userId'],
      description: json['description'],
      entryDate: DateTime.parse(json['entryDate']),
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'] ?? false,
      priority: json['priority'] ?? 'Medium',
      customerId: json['customerId'],
      autoReminders: json['autoReminders'] ?? false,
      calendarEventId: json['calendarEventId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'userId': userId,
      'description': description,
      'entryDate': entryDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority,
      'customerId': customerId,
      'autoReminders': autoReminders,
      'calendarEventId': calendarEventId,
    };
  }
}
