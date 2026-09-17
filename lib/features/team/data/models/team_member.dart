import 'package:flutter/material.dart';

import '../../../../core/theme/lex_colors.dart';

class TeamMember {
  final int id;
  final String username;
  final String email;
  final String role;
  final String firm;
  final int? firmId;
  final bool isSuperuser;
  final DateTime? joined;

  const TeamMember({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.firm,
    this.firmId,
    this.isSuperuser = false,
    this.joined,
  });

  bool get isSuperAdmin =>
      isSuperuser ||
      role.toLowerCase() == 'super_admin' ||
      role.toLowerCase() == 'platform_admin';
  bool get isFirmAdmin => !isSuperAdmin && role.toLowerCase() == 'admin';
  bool get isAdmin => role.toLowerCase() == 'admin' || isSuperAdmin;
  bool get isLawyer =>
      !isSuperAdmin &&
      (role.toLowerCase() == 'lawyer' || role.toLowerCase() == 'admin');
  bool get isStaff => !isSuperAdmin && role.toLowerCase() == 'staff';

  String get displayRole {
    switch (role.toLowerCase()) {
      case 'super_admin':
      case 'platform_admin':
        return 'Super Admin';
      case 'admin':
        return 'Firm Admin';
      case 'lawyer':
        return 'Advocate / Lawyer';
      case 'staff':
        return 'Legal Staff';
      default:
        return role;
    }
  }

  Color get badgeColor {
    switch (role.toLowerCase()) {
      case 'super_admin':
      case 'platform_admin':
        return const Color(0xFFC9A84C);
      case 'admin':
        return LexColors.slatePrimary;
      case 'lawyer':
        return const Color(0xFF1E40AF); // Deep Blue
      case 'staff':
        return const Color(0xFF475569); // Slate Gray
      default:
        return Colors.grey;
    }
  }

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    DateTime? joinedDate;
    if (json['joined'] != null) {
      joinedDate = DateTime.tryParse(json['joined'].toString());
    }

    final bool isSuper = json['is_superuser'] == true;

    int? parsedFirmId;
    final rawFirm = json['firm'];
    final rawFirmId = json['firm_id'];
    if (rawFirmId != null) {
      parsedFirmId = rawFirmId is int
          ? rawFirmId
          : int.tryParse(rawFirmId.toString());
    } else if (rawFirm is int) {
      parsedFirmId = rawFirm;
    } else if (rawFirm is Map<String, dynamic>) {
      parsedFirmId = rawFirm['id'] is int
          ? rawFirm['id'] as int
          : int.tryParse(rawFirm['id']?.toString() ?? '');
    } else if (rawFirm is String) {
      parsedFirmId = int.tryParse(rawFirm);
    }

    String firmName = '';
    if (rawFirm is Map<String, dynamic>) {
      firmName = rawFirm['name']?.toString() ?? '';
    } else if (rawFirm != null) {
      firmName = rawFirm.toString();
    }

    return TeamMember(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'staff',
      firm: firmName,
      firmId: parsedFirmId,
      isSuperuser: isSuper,
      joined: joinedDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'role': role,
    'firm': firm,
    'firm_id': firmId,
    'is_superuser': isSuperuser,
    'joined': joined?.toIso8601String(),
  };
}
