import 'dart:convert';

class UserProfile {
  final int? id;
  final String username;
  final String email;
  final String? role;
  final int? firmId;
  final String? firmName;
  final String? phone;

  const UserProfile({
    this.id,
    required this.username,
    required this.email,
    this.role,
    this.firmId,
    this.firmName,
    this.phone,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? json['user_role']?.toString(),
      firmId: json['firm'] is int
          ? json['firm']
          : int.tryParse(
              json['firm_id']?.toString() ?? json['firm']?.toString() ?? '',
            ),
      firmName: json['firm_name']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'firm_id': firmId,
      'firm_name': firmName,
      'phone': phone,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserProfile.fromJsonString(String source) {
    return UserProfile.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}
