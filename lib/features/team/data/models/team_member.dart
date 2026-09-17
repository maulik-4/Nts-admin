import 'package:flutter/material.dart';

import '../../../../core/theme/lex_colors.dart';

class TeamMember {
  final int id;
  final String username;
  final String email;
  final String role;
  final String firm;
  final DateTime? joined;

  const TeamMember({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.firm,
    this.joined,
  });

  bool get isSuperAdmin => role.toLowerCase() == 'super_admin';
  bool get isAdmin =>
      role.toLowerCase() == 'admin' || role.toLowerCase() == 'super_admin';
  bool get isLawyer =>
      role.toLowerCase() == 'lawyer' || role.toLowerCase() == 'admin';
  bool get isStaff => role.toLowerCase() == 'staff';

  String get displayRole {
    switch (role.toLowerCase()) {
      case 'super_admin':
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

    return TeamMember(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'staff',
      firm: json['firm']?.toString() ?? '',
      joined: joinedDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'role': role,
    'firm': firm,
    'joined': joined?.toIso8601String(),
  };
}
