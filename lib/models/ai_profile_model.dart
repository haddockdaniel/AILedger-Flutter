class AIProfile {
  final String profileId;
  final String userId;
  final String module; // e.g., "invoices", "emails", etc.
  final String preferences; // JSON string or encoded map
  final DateTime createdAt;

  AIProfile({
    required this.profileId,
    required this.userId,
    required this.module,
    required this.preferences,
    required this.createdAt,
  });

  factory AIProfile.fromJson(Map<String, dynamic> json) {
    return AIProfile(
      profileId: json['profileId'],
      userId: json['userId'],
      module: json['module'],
      preferences: json['preferences'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'userId': userId,
      'module': module,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
