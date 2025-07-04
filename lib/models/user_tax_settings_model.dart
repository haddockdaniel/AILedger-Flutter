class UserTaxSettings {
  final String userId;
  final bool chargeTaxes;
  final double taxPercentage;

  UserTaxSettings({
    required this.userId,
    required this.chargeTaxes,
    required this.taxPercentage,
  });

  factory UserTaxSettings.fromJson(Map<String, dynamic> json) {
    return UserTaxSettings(
      userId: json['userId'],
      chargeTaxes: json['chargeTaxes'] ?? false,
      taxPercentage: (json['taxPercentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'chargeTaxes': chargeTaxes,
      'taxPercentage': taxPercentage,
    };
  }
}
