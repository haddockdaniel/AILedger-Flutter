import 'dart:convert';

class InvoiceTemplate {
  final String templateId;
  final String userId;
  final String templateName;
  final List<TemplateLineItem> lineItems;
  final double taxPercentage;
  final bool chargeTaxes;
  final bool sendAutomatically;
  final String createdAt;

  InvoiceTemplate({
    required this.templateId,
    required this.userId,
    required this.templateName,
    required this.lineItems,
    required this.taxPercentage,
    required this.chargeTaxes,
    required this.sendAutomatically,
    required this.createdAt,
  });

  factory InvoiceTemplate.fromJson(Map<String, dynamic> json) {
    return InvoiceTemplate(
      templateId: json['templateId'],
      userId: json['userId'],
      templateName: json['templateName'],
      lineItems: (json['lineItems'] as List<dynamic>)
          .map((item) => TemplateLineItem.fromJson(item))
          .toList(),
      taxPercentage: (json['taxPercentage'] ?? 0).toDouble(),
      chargeTaxes: json['chargeTaxes'] ?? false,
      sendAutomatically: json['sendAutomatically'] ?? false,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'userId': userId,
      'templateName': templateName,
      'lineItems': lineItems.map((item) => item.toJson()).toList(),
      'taxPercentage': taxPercentage,
      'chargeTaxes': chargeTaxes,
      'sendAutomatically': sendAutomatically,
      'createdAt': createdAt,
    };
  }
}

class TemplateLineItem {
  final String description;
  final double amount;

  TemplateLineItem({
    required this.description,
    required this.amount,
  });

  factory TemplateLineItem.fromJson(Map<String, dynamic> json) {
    return TemplateLineItem(
      description: json['description'],
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
    };
  }
}
