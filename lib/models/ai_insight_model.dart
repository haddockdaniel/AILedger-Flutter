class AiInsight {
  final String id;
  final String userId;
  final String module;
  final String insight;
  final DateTime createdAt;

  AiInsight({
    required this.id,
    required this.userId,
    required this.module,
    required this.insight,
    required this.createdAt,
  });

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      id: json['id'],
      userId: json['userId'],
      module: json['module'],
      insight: json['insight'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'module': module,
      'insight': insight,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
