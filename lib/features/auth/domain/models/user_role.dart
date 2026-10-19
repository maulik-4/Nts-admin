import 'package:flutter/material.dart';

import '../../../../core/theme/lex_colors.dart';

/// Centralized configuration and metadata for a user role.
class RoleConfig {
  final String title;
  final String description;
  final Color badgeColor;

  const RoleConfig({
    required this.title,
    required this.description,
    required this.badgeColor,
  });
}

/// Centralized role model representing the supported user roles in NTS Legal Pro:
/// - [superAdmin]: Platform-level administrator (super_admin or is_superuser == true)
/// - [firmAdmin]: Law firm tenant administrator (admin)
/// - [lawyer]: Advocate / practicing lawyer (lawyer)
/// - [staff]: Legal clerk / paralegal / operational staff (staff)
/// - [client]: Law firm end client (client)
/// - [unknown]: Fallback for unassigned or unrecognized roles
enum UserRole {
  superAdmin,
  firmAdmin,
  lawyer,
  staff,
  client,
  unknown;

  /// Safe parser mapping backend strings and superuser flag to [UserRole].
  ///
  /// CRITICAL: If [isSuperuser] is true, the user is always treated as [UserRole.superAdmin],
  /// replicating the React frontend logic `user?.is_superuser || role === 'super_admin'`.
  static UserRole fromString(String? role, {bool isSuperuser = false}) {
    if (isSuperuser) return UserRole.superAdmin;
    if (role == null) return UserRole.unknown;
    final normalized = role.trim().toLowerCase();

    switch (normalized) {
      case 'super_admin':
      case 'superadmin':
      case 'platform_admin':
      case 'superuser':
        return UserRole.superAdmin;
      case 'admin':
      case 'firm_admin':
      case 'firmadmin':
      case 'owner':
        return UserRole.firmAdmin;
      case 'lawyer':
      case 'advocate':
      case 'attorney':
      case 'counsel':
        return UserRole.lawyer;
      case 'staff':
      case 'clerk':
      case 'assistant':
      case 'paralegal':
        return UserRole.staff;
      case 'client':
        return UserRole.client;
      default:
        return UserRole.unknown;
    }
  }

  /// Centralized role configuration including title, description, and visual color tokens.
  RoleConfig get config {
    switch (this) {
      case UserRole.superAdmin:
        return const RoleConfig(
          title: 'Super Admin',
          description: 'Super Admin / Platform Administrator',
          badgeColor: Color(0xFFD97706), // Gold
        );
      case UserRole.firmAdmin:
        return const RoleConfig(
          title: 'Firm Admin',
          description: 'Firm Administrator',
          badgeColor: Color(0xFF2563EB), // Blue
        );
      case UserRole.lawyer:
        return const RoleConfig(
          title: 'Lawyer',
          description: 'Advocate / Lawyer',
          badgeColor: Color(0xFF059669), // Green
        );
      case UserRole.staff:
        return const RoleConfig(
          title: 'Staff',
          description: 'Legal Staff / Paralegal',
          badgeColor: Color(0xFF64748B), // Neutral Slate
        );
      case UserRole.client:
        return const RoleConfig(
          title: 'Client',
          description: 'Law Firm Client',
          badgeColor: Color(0xFF7C3AED), // Violet
        );
      case UserRole.unknown:
        return const RoleConfig(
          title: 'Member',
          description: 'Unknown Role',
          badgeColor: LexColors.textSecondaryLight,
        );
    }
  }

  static const UserRole admin = UserRole.firmAdmin;

  String get serializedName {
    switch (this) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.firmAdmin:
        return 'admin';
      case UserRole.lawyer:
        return 'lawyer';
      case UserRole.staff:
        return 'staff';
      case UserRole.client:
        return 'client';
      case UserRole.unknown:
        return 'unknown';
    }
  }

  String get displayTitle => config.title;
  String get description => config.description;
  Color get badgeColor => config.badgeColor;

  bool get isSuperAdmin => this == UserRole.superAdmin;
  bool get isAdmin => this == UserRole.firmAdmin;
  bool get isFirmAdmin => this == UserRole.firmAdmin;
  bool get isLawyer => this == UserRole.lawyer;
  bool get isStaff => this == UserRole.staff;
  bool get isClient => this == UserRole.client;

  /// Returns true for tenant users associated with a specific law firm
  bool get isFirmUser =>
      this == UserRole.firmAdmin ||
      this == UserRole.lawyer ||
      this == UserRole.staff;
}

/// Standalone parser matching the prompt specification:
/// Maps 'super_admin', 'admin', 'firm_admin', 'lawyer', 'staff', 'client'.
/// Does not guess role and handles unknown roles safely.
UserRole parseUserRole(String? role, {bool isSuperuser = false}) {
  if (isSuperuser) return UserRole.superAdmin;
  if (role == null) return UserRole.unknown;
  final normalized = role.trim().toLowerCase();
  switch (normalized) {
    case 'super_admin':
    case 'superadmin':
    case 'platform_admin':
    case 'superuser':
      return UserRole.superAdmin;
    case 'admin':
    case 'firm_admin':
    case 'firmadmin':
    case 'owner':
      return UserRole.admin;
    case 'lawyer':
    case 'advocate':
    case 'attorney':
    case 'counsel':
      return UserRole.lawyer;
    case 'staff':
    case 'clerk':
    case 'assistant':
    case 'paralegal':
      return UserRole.staff;
    case 'client':
      return UserRole.client;
    default:
      return UserRole.unknown;
  }
}

/// Standalone safe parser matching the prompt specification.
UserRole fromRoleString(String? role, {bool isSuperuser = false}) =>
    parseUserRole(role, isSuperuser: isSuperuser);

/// Extension providing direct role checks on [UserRole].
extension UserRoleExtension on UserRole {
  bool get isSuperAdminRole => this == UserRole.superAdmin;
  bool get isAdminRole => this == UserRole.firmAdmin;
  bool get isFirmAdminRole => this == UserRole.firmAdmin;
  bool get isLawyerRole => this == UserRole.lawyer;
  bool get isStaffRole => this == UserRole.staff;
  bool get isClientRole => this == UserRole.client;
}
