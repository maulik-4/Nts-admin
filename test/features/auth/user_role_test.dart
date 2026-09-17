import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/auth/domain/models/user_role.dart';
import 'package:flutter_application_1/features/auth/data/models/user_profile.dart';

void main() {
  group('UserRole Enum & Parsing Tests', () {
    test('UserRole.fromString correctly parses Super Admin variants', () {
      expect(UserRole.fromString('super_admin'), UserRole.superAdmin);
      expect(UserRole.fromString('superadmin'), UserRole.superAdmin);
      expect(UserRole.fromString('platform_admin'), UserRole.superAdmin);
      expect(UserRole.fromString('superuser'), UserRole.superAdmin);
      expect(
        UserRole.fromString('admin', isSuperuser: true),
        UserRole.superAdmin,
      );
    });

    test('fromRoleString standalone helper functions identically', () {
      expect(fromRoleString('super_admin'), UserRole.superAdmin);
      expect(fromRoleString('admin'), UserRole.firmAdmin);
      expect(fromRoleString('lawyer'), UserRole.lawyer);
      expect(fromRoleString('staff'), UserRole.staff);
      expect(fromRoleString('unknown_role'), UserRole.unknown);
      expect(fromRoleString('admin', isSuperuser: true), UserRole.superAdmin);
    });

    test('UserRole.fromString correctly parses Firm Admin variants', () {
      expect(UserRole.fromString('admin'), UserRole.firmAdmin);
      expect(UserRole.fromString('firm_admin'), UserRole.firmAdmin);
      expect(UserRole.fromString('firmadmin'), UserRole.firmAdmin);
      expect(UserRole.fromString('owner'), UserRole.firmAdmin);
      expect(UserRole.fromString('ADMIN'), UserRole.firmAdmin);
    });

    test('UserRole.fromString correctly parses Lawyer variants', () {
      expect(UserRole.fromString('lawyer'), UserRole.lawyer);
      expect(UserRole.fromString('advocate'), UserRole.lawyer);
      expect(UserRole.fromString('attorney'), UserRole.lawyer);
      expect(UserRole.fromString('counsel'), UserRole.lawyer);
      expect(UserRole.fromString('LAWYER'), UserRole.lawyer);
    });

    test('UserRole.fromString correctly parses Staff variants', () {
      expect(UserRole.fromString('staff'), UserRole.staff);
      expect(UserRole.fromString('clerk'), UserRole.staff);
      expect(UserRole.fromString('assistant'), UserRole.staff);
      expect(UserRole.fromString('paralegal'), UserRole.staff);
      expect(UserRole.fromString('STAFF'), UserRole.staff);
    });

    test('UserRole.fromString falls back to unknown on unrecognized values and never defaults to admin', () {
      expect(UserRole.fromString('unknown_role'), UserRole.unknown);
      expect(UserRole.fromString(null), UserRole.unknown);
      expect(UserRole.fromString(''), UserRole.unknown);
      expect(UserRole.fromString('random_string'), UserRole.unknown);
    });

    test('UserRole booleans behave as expected', () {
      expect(UserRole.superAdmin.isSuperAdmin, isTrue);
      expect(UserRole.superAdmin.isFirmAdmin, isFalse);
      expect(UserRole.superAdmin.isFirmUser, isFalse);

      expect(UserRole.firmAdmin.isFirmAdmin, isTrue);
      expect(UserRole.firmAdmin.isFirmUser, isTrue);
      expect(UserRole.firmAdmin.isSuperAdmin, isFalse);

      expect(UserRole.lawyer.isLawyer, isTrue);
      expect(UserRole.lawyer.isFirmUser, isTrue);
      expect(UserRole.lawyer.isFirmAdmin, isFalse);

      expect(UserRole.staff.isStaff, isTrue);
      expect(UserRole.staff.isFirmUser, isTrue);
      expect(UserRole.staff.isLawyer, isFalse);
    });

    test(
      'RoleConfig provides required titles, descriptions, and badge colors',
      () {
        expect(UserRole.superAdmin.config.title, 'Super Admin');
        expect(
          UserRole.superAdmin.config.description,
          'Super Admin / Platform Administrator',
        );
        expect(UserRole.firmAdmin.config.title, 'Firm Admin');
        expect(UserRole.firmAdmin.config.description, 'Firm Administrator');
        expect(UserRole.lawyer.config.title, 'Lawyer');
        expect(UserRole.lawyer.config.description, 'Advocate / Lawyer');
        expect(UserRole.staff.config.title, 'Staff');
        expect(UserRole.staff.config.description, 'Legal Staff / Paralegal');

        for (final role in UserRole.values) {
          expect(role.badgeColor, isA<Color>());
          expect(role.displayTitle.isNotEmpty, isTrue);
          expect(role.description.isNotEmpty, isTrue);
        }
      },
    );

    test('Critical Super Admin detection: is_superuser = true with role = admin must resolve as Super Admin', () {
      final promotedUser = UserProfile(
        id: 99,
        username: 'promoted_admin',
        email: 'promoted@firm.com',
        role: 'admin',
        isSuperuser: true,
      );

      expect(promotedUser.isSuperAdmin, isTrue);
      expect(promotedUser.userRole, UserRole.superAdmin);
      expect(promotedUser.isFirmAdmin, isFalse);
      expect(promotedUser.isLawyer, isFalse);
      expect(promotedUser.isStaff, isFalse);
    });

    test('UserProfile userRole and role getters extract correctly', () {
      final superProfile = UserProfile(
        id: 1,
        username: 'super',
        email: 'super@platform.com',
        role: 'super_admin',
        isSuperuser: true,
      );
      expect(superProfile.userRole, UserRole.superAdmin);
      expect(superProfile.isSuperAdmin, isTrue);
      expect(superProfile.isFirmAdmin, isFalse);

      final adminProfile = UserProfile(
        id: 2,
        username: 'firmadmin',
        email: 'admin@firm.com',
        role: 'admin',
      );
      expect(adminProfile.userRole, UserRole.firmAdmin);
      expect(adminProfile.isFirmAdmin, isTrue);
      expect(adminProfile.isSuperAdmin, isFalse);

      final lawyerProfile = UserProfile(
        id: 3,
        username: 'advocate1',
        email: 'lawyer@firm.com',
        role: 'lawyer',
      );
      expect(lawyerProfile.userRole, UserRole.lawyer);
      expect(lawyerProfile.isLawyer, isTrue);
      expect(lawyerProfile.isFirmAdmin, isFalse);

      final staffProfile = UserProfile(
        id: 4,
        username: 'staff1',
        email: 'staff@firm.com',
        role: 'staff',
      );
      expect(staffProfile.userRole, UserRole.staff);
      expect(staffProfile.isStaff, isTrue);
      expect(staffProfile.isLawyer, isFalse);
    });

    test('UserProfile handles name and displayName gracefully', () {
      final namedUser = UserProfile(
        username: 'jdoe',
        email: 'jdoe@firm.com',
        name: 'John Doe',
      );
      expect(namedUser.displayName, 'John Doe');

      final unnamedUser = UserProfile(username: 'jdoe', email: 'jdoe@firm.com');
      expect(unnamedUser.displayName, 'jdoe');
    });
  });
}
