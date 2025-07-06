class Customer {
  final String customerId;
  final String userId;
  final String fullName;
  final String? companyName;
  final String phone;
  final String email;
  final List<CustomerAddress> addresses;
  final List<String> tags;
  final String? notes;
  final double totalOwed;
  final double totalPaid;
  final int daysSinceFirstInvoice;
  final int oldestDelinquentInvoice;
  final String invoicePreference;

  Customer({
    required this.customerId,
    required this.userId,
    required this.fullName,
    this.companyName,
    required this.phone,
    required this.email,
    required this.addresses,
    required this.tags,
    this.notes,
    required this.totalOwed,
    required this.totalPaid,
    required this.daysSinceFirstInvoice,
    required this.oldestDelinquentInvoice,
    required this.invoicePreference,
  });
  
    factory Customer.basic({
    String customerId = '',
    String userId = '',
    required String fullName,
    required String phone,
    required String email,
    String invoicePreference = 'email',
  }) =>
      Customer(
        customerId: customerId,
        userId: userId,
        fullName: fullName,
        companyName: null,
        phone: phone,
        email: email,
        addresses: const [],
        tags: const [],
        notes: null,
        totalOwed: 0,
        totalPaid: 0,
        daysSinceFirstInvoice: 0,
        oldestDelinquentInvoice: 0,
        invoicePreference: invoicePreference,
      );

  String get id => customerId;

  static Customer empty() => Customer(
        customerId: '',
        userId: '',
        fullName: '',
        companyName: null,
        phone: '',
        email: '',
        addresses: const [],
        tags: const [],
        notes: null,
        totalOwed: 0,
        totalPaid: 0,
        daysSinceFirstInvoice: 0,
        oldestDelinquentInvoice: 0,
        invoicePreference: 'email',
      );

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'],
      userId: json['userId'],
      fullName: json['fullName'] ?? json['name'] ?? '',
      companyName: json['companyName'],
      phone: json['phone'],
      email: json['email'],
      addresses: (json['addresses'] as List<dynamic>)
          .map((a) => CustomerAddress.fromJson(a))
          .toList(),
      tags: List<String>.from(json['tags'] ?? []),
      notes: json['notes'],
      totalOwed: (json['totalOwed'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      daysSinceFirstInvoice: json['daysSinceFirstInvoice'] ?? 0,
      oldestDelinquentInvoice: json['oldestDelinquentInvoice'] ?? 0,
      invoicePreference: json['invoicePreference'] ?? 'email',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'userId': userId,
      'fullName': fullName,
      'companyName': companyName,
      'phone': phone,
      'email': email,
      'addresses': addresses.map((a) => a.toJson()).toList(),
      'tags': tags,
      'notes': notes,
      'totalOwed': totalOwed,
      'totalPaid': totalPaid,
      'daysSinceFirstInvoice': daysSinceFirstInvoice,
      'oldestDelinquentInvoice': oldestDelinquentInvoice,
      'invoicePreference': invoicePreference,
    };
  }
}

class CustomerAddress {
  final String addressId;
  final String userId;
  final String customerId;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  CustomerAddress({
    required this.addressId,
    required this.userId,
    required this.customerId,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      addressId: json['addressId'],
      userId: json['userId'],
      customerId: json['customerId'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'userId': userId,
      'customerId': customerId,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }
}
