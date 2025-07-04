class EmailTemplate {
  final String templateId;
  final String userId;
  final String templateName;
  final String subject;
  final String body;
  final DateTime createdAt;

  EmailTemplate({
    required this.templateId,
    required this.userId,
    required this.templateName,
    required this.subject,
    required this.body,
    required this.createdAt,
  });

  factory EmailTemplate.fromJson(Map<String, dynamic> json) {
    return EmailTemplate(
      templateId: json['templateId'],
      userId: json['userId'],
      templateName: json['templateName'],
      subject: json['subject'],
      body: json['body'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'userId': userId,
      'templateName': templateName,
      'subject': subject,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
