// lib/models/invoice_model.dart

class Invoice {
  final int invoiceId;
  final String invoiceNumber;
  final int userId;
  final int? customerId;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final bool isPaid;
  final bool isWrittenOff;
  final bool isCanceled;
  final String status; // e.g., 'Draft', 'Sent', 'Paid', 'Overdue'
  final String? paymentLink;
  final bool sendAutomatically;
  final bool chargeTaxes;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? calendarEventId;
  
  final List<InvoiceLineItem> lineItems;

  Invoice({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.userId,
    required this.customerId,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.invoiceDate,
    this.dueDate,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.isPaid,
    required this.isWrittenOff,
    required this.isCanceled,
    required this.status,
    this.paymentLink,
    required this.sendAutomatically,
    required this.chargeTaxes,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    required this.lineItems,
	this.calendarEventId,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceId: json['invoiceId'],
      invoiceNumber: json['invoiceNumber'],
      userId: json['userId'],
      customerId: json['customerId'],
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      taxRate: (json['taxRate'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      isPaid: json['isPaid'] ?? false,
      isWrittenOff: json['isWrittenOff'] ?? false,
      isCanceled: json['isCanceled'] ?? false,
      status: json['status'] ?? 'Draft',
      paymentLink: json['paymentLink'],
      sendAutomatically: json['sendAutomatically'] ?? false,
      chargeTaxes: json['chargeTaxes'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      lineItems: (json['lineItems'] as List<dynamic>?)
              ?.map((item) => InvoiceLineItem.fromJson(item))
              .toList() ??
          [],
		  calendarEventId: json['calendarEventId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceId': invoiceId,
      'invoiceNumber': invoiceNumber,
      'userId': userId,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'invoiceDate': invoiceDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'total': total,
      'isPaid': isPaid,
      'isWrittenOff': isWrittenOff,
      'isCanceled': isCanceled,
      'status': status,
      'paymentLink': paymentLink,
      'sendAutomatically': sendAutomatically,
      'chargeTaxes': chargeTaxes,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lineItems': lineItems.map((item) => item.toJson()).toList(),
	  'calendarEventId': calendarEventId,
    };
  }
}

class InvoiceLineItem {
  final int lineItemId;
  final int invoiceId;
  final int userId;
  final String description;
  final double quantity;
  final double unitPrice;
  final double total;

  InvoiceLineItem({
    required this.lineItemId,
    required this.invoiceId,
    required this.userId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItem(
      lineItemId: json['lineItemId'],
      invoiceId: json['invoiceId'],
      userId: json['userId'],
      description: json['description'],
      quantity: (json['quantity'] ?? 0).toDouble(),
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lineItemId': lineItemId,
      'invoiceId': invoiceId,
      'userId': userId,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
    };
  }
}
