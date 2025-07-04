// lib/models/user_model.dart

class User {
  final String id;
  final String name;
  final String? companyName;
  final String email;
  final String? phone;
  final String? address;

  User({
    required this.id,
    required this.name,
    this.companyName,
    required this.email,
    this.phone,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      companyName: json['companyName'],
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'companyName': companyName,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}
