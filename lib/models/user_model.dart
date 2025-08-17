class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final bool isVerified;
  final DateTime createdAt;
  final List<String> addedLocations;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.isVerified = false,
    required this.createdAt,
    this.addedLocations = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'isVerified': isVerified,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'addedLocations': addedLocations,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'],
      isVerified: map['isVerified'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      addedLocations: List<String>.from(map['addedLocations'] ?? []),
    );
  }
}