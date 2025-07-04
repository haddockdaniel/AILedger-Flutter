class Contact {
  final String contactId;
  final String userId;
  final String firstName;
  final String lastName;
  final String? businessName;
  final String? email;
  final String? phone;
  final String? notes;

  Contact({
    required this.contactId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.businessName,
    this.email,
    this.phone,
    this.notes,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      contactId: json['contactId'] as String,
      userId: json['userId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      businessName: json['businessName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'contactId': contactId,
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'businessName': businessName,
        'email': email,
        'phone': phone,
        'notes': notes,
      };
}
