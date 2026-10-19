import 'dart:convert';

import '../../domain/models/user.dart';
import '../../domain/models/user_role.dart';

class UserProfile {
  final int? id;
  final String username;
  final String email;
  final String? name;
  final String? role;
  final int? firmId;
  final String? firmName;
  final String? phone;
  final bool isSuperuser;

  const UserProfile({
    this.id,
    required this.username,
    required this.email,
    this.name,
    this.role,
    this.firmId,
    this.firmName,
    this.phone,
    this.isSuperuser = false,
  });

  /// Authoritative role resolution.
  ///
  /// If [isSuperuser] is true, returns [UserRole.superAdmin] regardless of [role] string,
  /// matching the React frontend behavior `user?.is_superuser || role === 'super_admin'`.
  UserRole get userRole => parseUserRole(role, isSuperuser: isSuperuser);

  /// Helper getters directly matching React auth hook:
  /// `const isSuperAdmin = user?.is_superuser || role === 'super_admin';`
  /// `const isAdmin = role === 'admin';`
  /// `const isLawyer = role === 'lawyer';`
  /// `const isStaff = role === 'staff';`
  bool get isSuperAdmin => isSuperuser || userRole.isSuperAdmin;
  bool get isAdmin => !isSuperAdmin && userRole.isAdmin;
  bool get isFirmAdmin => isAdmin;
  bool get isLawyer => !isSuperAdmin && userRole.isLawyer;
  bool get isStaff => !isSuperAdmin && userRole.isStaff;
  bool get isClient => userRole.isClient;

  /// Firm scoping matching User model
  int? get firm => firmId;

  String get displayName {
    if (name != null && name!.trim().isNotEmpty) return name!.trim();
    if (username.trim().isNotEmpty) return username.trim();
    return 'Legal User';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Check if payload is wrapped in a "user" object (e.g., login response)
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    final firmData = userMap['firm'] ?? json['firm'];
    int? parsedFirmId;
    String? parsedFirmName = (userMap['firm_name'] ?? json['firm_name'])
        ?.toString();

    if (firmData is Map<String, dynamic>) {
      parsedFirmId = firmData['id'] is int
          ? firmData['id'] as int
          : int.tryParse(firmData['id']?.toString() ?? '');
      parsedFirmName ??= firmData['name']?.toString();
    } else if (firmData is int) {
      parsedFirmId = firmData;
    } else {
      parsedFirmId = int.tryParse(
        (userMap['firm_id'] ?? json['firm_id'] ?? firmData)?.toString() ?? '',
      );
    }

    final bool isSuper =
        userMap['is_superuser'] == true || json['is_superuser'] == true;

    String? extractedRole =
        userMap['role']?.toString() ??
        json['role']?.toString() ??
        userMap['user_role']?.toString() ??
        json['user_role']?.toString();

    if (isSuper && (extractedRole == null || extractedRole == 'admin')) {
      extractedRole = 'super_admin';
    }

    final parsedName =
        (userMap['name'] ??
                userMap['full_name'] ??
                json['name'] ??
                json['full_name'])
            ?.toString();

    return UserProfile(
      id: userMap['id'] is int
          ? userMap['id']
          : int.tryParse((userMap['id'] ?? json['id'])?.toString() ?? ''),
      username: (userMap['username'] ?? json['username'])?.toString() ?? '',
      email: (userMap['email'] ?? json['email'])?.toString() ?? '',
      name: parsedName,
      role: extractedRole,
      firmId: parsedFirmId,
      firmName: parsedFirmName,
      phone: (userMap['phone'] ?? json['phone'])?.toString(),
      isSuperuser: isSuper,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'role': role,
      'firm_id': firmId,
      'firm_name': firmName,
      'phone': phone,
      'is_superuser': isSuperuser,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserProfile.fromJsonString(String source) {
    return UserProfile.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }

  factory UserProfile.fromUser(User user) {
    return UserProfile(
      id: user.id,
      username: user.username,
      email: user.email,
      name: user.name,
      role: user.role,
      firmId: user.firm,
      firmName: user.firmName,
      phone: user.phone,
      isSuperuser: user.isSuperuser,
    );
  }

  User toUser() {
    return User(
      id: id ?? 0,
      username: username,
      email: email,
      role: role ?? '',
      firm: firmId,
      name: name,
      phone: phone,
      firmName: firmName,
      isSuperuser: isSuperuser,
    );
  }

  UserProfile copyWith({
    int? id,
    String? username,
    String? email,
    String? name,
    String? role,
    int? firmId,
    String? firmName,
    String? phone,
    bool? isSuperuser,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      firmId: firmId ?? this.firmId,
      firmName: firmName ?? this.firmName,
      phone: phone ?? this.phone,
      isSuperuser: isSuperuser ?? this.isSuperuser,
    );
  }
}
