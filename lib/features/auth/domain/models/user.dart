import 'dart:convert';

import 'user_role.dart';

/// Strongly typed User model as specified in the RBAC architecture.
/// Backend user.role is the single source of truth for the user's role.
class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final int? firm;
  final String? name;
  final String? phone;
  final String? firmName;
  final bool isSuperuser;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.firm,
    this.name,
    this.phone,
    this.firmName,
    this.isSuperuser = false,
  });

  /// Authoritative role resolution derived solely from user.role.
  UserRole get userRole => parseUserRole(role, isSuperuser: isSuperuser);

  /// Role checks
  bool get isSuperAdmin => isSuperuser || userRole == UserRole.superAdmin;
  bool get isAdmin => !isSuperAdmin && userRole == UserRole.admin;
  bool get isFirmAdmin => isAdmin;
  bool get isLawyer => !isSuperAdmin && userRole == UserRole.lawyer;
  bool get isStaff => !isSuperAdmin && userRole == UserRole.staff;

  /// Firm scoping
  int? get firmId => firm;

  String get displayName {
    if (name != null && name!.trim().isNotEmpty) return name!.trim();
    if (username.trim().isNotEmpty) return username.trim();
    return 'Legal User';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // Support payloads wrapped in 'user' object or flat
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    final rawFirm = userMap['firm'] ?? json['firm'];
    int? parsedFirm;
    String? parsedFirmName = (userMap['firm_name'] ?? json['firm_name'])?.toString();

    if (rawFirm is Map<String, dynamic>) {
      parsedFirm = rawFirm['id'] is int
          ? rawFirm['id'] as int
          : int.tryParse(rawFirm['id']?.toString() ?? '');
      parsedFirmName ??= rawFirm['name']?.toString();
    } else if (rawFirm is int) {
      parsedFirm = rawFirm;
    } else {
      parsedFirm = int.tryParse(
        (userMap['firm_id'] ?? json['firm_id'] ?? rawFirm)?.toString() ?? '',
      );
    }

    final bool isSuper =
        userMap['is_superuser'] == true || json['is_superuser'] == true;

    String extractedRole =
        userMap['role']?.toString() ??
        json['role']?.toString() ??
        userMap['user_role']?.toString() ??
        json['user_role']?.toString() ??
        '';

    if (isSuper && (extractedRole.isEmpty || extractedRole == 'admin')) {
      extractedRole = 'super_admin';
    }

    final parsedId = userMap['id'] is int
        ? userMap['id'] as int
        : int.tryParse((userMap['id'] ?? json['id'])?.toString() ?? '') ?? 0;

    final parsedName = (userMap['name'] ??
            userMap['full_name'] ??
            json['name'] ??
            json['full_name'])
        ?.toString();

    return User(
      id: parsedId,
      username: (userMap['username'] ?? json['username'])?.toString() ?? '',
      email: (userMap['email'] ?? json['email'])?.toString() ?? '',
      role: extractedRole,
      firm: parsedFirm,
      name: parsedName,
      phone: (userMap['phone'] ?? json['phone'])?.toString(),
      firmName: parsedFirmName,
      isSuperuser: isSuper,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'firm': firm,
      'name': name,
      'phone': phone,
      'firm_name': firmName,
      'is_superuser': isSuperuser,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory User.fromJsonString(String source) {
    return User.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}
