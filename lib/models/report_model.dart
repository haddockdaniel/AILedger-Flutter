class Report {
  final String reportId;
  final String userId;
  final String reportType;
  final String reportContent;
  final DateTime createdAt;

  Report({
    required this.reportId,
    required this.userId,
    required this.reportType,
    required this.reportContent,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['reportId'],
      userId: json['userId'],
      reportType: json['reportType'],
      reportContent: json['reportContent'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'userId': userId,
      'reportType': reportType,
      'reportContent': reportContent,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
