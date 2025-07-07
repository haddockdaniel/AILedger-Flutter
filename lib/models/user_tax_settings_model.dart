class UserTaxSettings {
  final String? userId;
  final bool chargeTaxes;
  final double taxPercentage;
    final String currency;
  final String region;

  UserTaxSettings({
    this.userId,
    required this.chargeTaxes,
    required this.taxPercentage,
	    required this.currency,
    required this.region,
  });

  factory UserTaxSettings.fromJson(Map<String, dynamic> json) {
    return UserTaxSettings(
      userId: json['userId'],
      chargeTaxes: json['chargeTaxes'] ?? false,
      taxPercentage: (json['taxPercentage'] ?? 0).toDouble(),
	        currency: json['currency'] ?? 'USD',
      region: json['region'] ?? 'US',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      'chargeTaxes': chargeTaxes,
      'taxPercentage': taxPercentage,
	        'currency': currency,
      'region': region,
    };
  }
}
