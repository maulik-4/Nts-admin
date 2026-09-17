import 'package:flutter_application_1/core/routing/role_guard.dart';
import 'package:flutter_application_1/features/auth/domain/models/role_capabilities.dart';
import 'package:flutter_application_1/features/auth/domain/models/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Firm Admin Role Normalization Tests', () {
    test(
      'backend "admin" and "firm_admin" strings map to UserRole.firmAdmin',
      () {
        expect(UserRole.fromString('admin'), equals(UserRole.firmAdmin));
        expect(UserRole.fromString('firm_admin'), equals(UserRole.firmAdmin));
        expect(UserRole.fromString('ADMIN'), equals(UserRole.firmAdmin));
        expect(UserRole.fromString('owner'), equals(UserRole.firmAdmin));
        expect(UserRole.admin, equals(UserRole.firmAdmin));
      },
    );

    test('other roles normalize accurately', () {
      expect(UserRole.fromString('lawyer'), equals(UserRole.lawyer));
      expect(UserRole.fromString('advocate'), equals(UserRole.lawyer));
      expect(UserRole.fromString('staff'), equals(UserRole.staff));
      expect(UserRole.fromString('super_admin'), equals(UserRole.superAdmin));
      expect(UserRole.fromString('unknown'), equals(UserRole.unknown));
    });

    test('isSuperuser true always resolves to UserRole.superAdmin', () {
      expect(
        UserRole.fromString('admin', isSuperuser: true),
        equals(UserRole.superAdmin),
      );
      expect(
        UserRole.fromString('lawyer', isSuperuser: true),
        equals(UserRole.superAdmin),
      );
      expect(
        UserRole.fromString(null, isSuperuser: true),
        equals(UserRole.superAdmin),
      );
    });
  });

  group('Centralized Role Permissions Matrix (Section 25)', () {
    test('canEditFirmBranding permission check', () {
      expect(canEditFirmBranding(UserRole.firmAdmin), isTrue);
      expect(canEditFirmBranding(UserRole.lawyer), isFalse);
      expect(canEditFirmBranding(UserRole.staff), isFalse);
      expect(canEditFirmBranding(UserRole.superAdmin), isFalse);
    });

    test('canManageFirmSubscription permission check', () {
      expect(canManageFirmSubscription(UserRole.firmAdmin), isTrue);
      expect(canManageFirmSubscription(UserRole.lawyer), isFalse);
      expect(canManageFirmSubscription(UserRole.staff), isFalse);
      expect(canManageFirmSubscription(UserRole.superAdmin), isFalse);
    });

    test('canViewFirmBranding permission check', () {
      expect(canViewFirmBranding(UserRole.firmAdmin), isTrue);
      expect(canViewFirmBranding(UserRole.lawyer), isTrue);
      expect(canViewFirmBranding(UserRole.staff), isTrue);
      expect(canViewFirmBranding(UserRole.superAdmin), isFalse);
    });

    test(
      'RoleGuard protects branding and subscription from lawyer and staff',
      () {
        // Firm Admin can access
        final adminBranding = RoleGuard.evaluate(
          userRole: UserRole.firmAdmin,
          currentPath: '/app/more/branding',
          isAuthenticated: true,
          isInitial: false,
        );
        expect(adminBranding, isNull);

        final adminSub = RoleGuard.evaluate(
          userRole: UserRole.firmAdmin,
          currentPath: '/app/more/subscriptions',
          isAuthenticated: true,
          isInitial: false,
        );
        expect(adminSub, isNull);

        // Lawyer is redirected
        final lawyerBranding = RoleGuard.evaluate(
          userRole: UserRole.lawyer,
          currentPath: '/app/more/branding',
          isAuthenticated: true,
          isInitial: false,
        );
        expect(lawyerBranding, equals('/app/more'));

        final lawyerSub = RoleGuard.evaluate(
          userRole: UserRole.lawyer,
          currentPath: '/app/more/subscriptions',
          isAuthenticated: true,
          isInitial: false,
        );
        expect(lawyerSub, equals('/app/more'));

        // Staff is redirected
        final staffBranding = RoleGuard.evaluate(
          userRole: UserRole.staff,
          currentPath: '/app/more/branding',
          isAuthenticated: true,
          isInitial: false,
        );
        expect(staffBranding, equals('/app/more'));
      },
    );
  });
}
