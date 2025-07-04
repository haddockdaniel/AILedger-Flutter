class Email {
  final String emailId;
  final String userId;
  final String? customerId;
  final String subject;
  final String body;
  final DateTime createdAt;
  final String? templateId;

  Email({
    required this.emailId,
    required this.userId,
    this.customerId,
    required this.subject,
    required this.body,
    required this.createdAt,
    this.templateId,
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      emailId: json['emailId'],
      userId: json['userId'],
      customerId: json['customerId'],
      subject: json['subject'],
      body: json['body'],
      createdAt: DateTime.parse(json['createdAt']),
      templateId: json['templateId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailId': emailId,
      'userId': userId,
      'customerId': customerId,
      'subject': subject,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'templateId': templateId,
    };
  }
}
