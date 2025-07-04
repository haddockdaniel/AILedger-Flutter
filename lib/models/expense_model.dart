class Expense {
  final String expenseId;
  final String userId;
  final String vendor;
  final double amount;
  final String category;
  final String? notes;
  final DateTime date;
  final String? receiptUrl;

  Expense({
    required this.expenseId,
    required this.userId,
    required this.vendor,
    required this.amount,
    required this.category,
    this.notes,
    required this.date,
    this.receiptUrl,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: json['expenseId'],
      userId: json['userId'],
      vendor: json['vendor'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      notes: json['notes'],
      date: DateTime.parse(json['date']),
      receiptUrl: json['receiptUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'userId': userId,
      'vendor': vendor,
      'amount': amount,
      'category': category,
      'notes': notes,
      'date': date.toIso8601String(),
      'receiptUrl': receiptUrl,
    };
  }
}
