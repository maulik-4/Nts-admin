import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/auth/domain/models/user_role.dart';
import 'package:flutter_application_1/core/routing/role_guard.dart';

void main() {
  group('Case, Hearing & Task Creation Access Tests', () {
    test('Firm Admin can access /app/cases/create, /app/hearings/create, /app/tasks/create', () {
      const role = UserRole.admin;

      expect(
        RoleGuard.evaluate(
          userRole: role,
          currentPath: '/app/cases/create',
          isAuthenticated: true,
          isInitial: false,
        ),
        isNull,
      );

      expect(
        RoleGuard.evaluate(
          userRole: role,
          currentPath: '/app/hearings/create',
          isAuthenticated: true,
          isInitial: false,
        ),
        isNull,
      );

      expect(
        RoleGuard.evaluate(
          userRole: role,
          currentPath: '/app/tasks/create',
          isAuthenticated: true,
          isInitial: false,
        ),
        isNull,
      );
    });

    test('Lawyer can access /app/cases/create, /app/hearings/create, /app/tasks/create', () {
      const role = UserRole.lawyer;

      expect(
        RoleGuard.evaluate(
          userRole: role,
          currentPath: '/app/cases/create',
          isAuthenticated: true,
          isInitial: false,
        ),
        isNull,
      );

      expect(
        RoleGuard.evaluate(
          userRole: role,
          currentPath: '/app/hearings/create',
          isAuthenticated: true,
          isInitial: false,
        ),
        isNull,
      );

      expect(
        RoleGuard.evaluate(
          userRole: role,
          currentPath: '/app/tasks/create',
          isAuthenticated: true,
          isInitial: false,
        ),
        isNull,
      );
    });

    test('Staff can access /app/hearings/create and /app/tasks/create, but is barred from cases', () {
      const role = UserRole.staff;

      // Staff can create hearings and tasks
      expect(
        RoleGuard.evaluate(
          userRole: role,
          currentPath: '/app/hearings/create',
          isAuthenticated: true,
          isInitial: false,
        ),
        isNull,
      );

      expect(
        RoleGuard.evaluate(
          userRole: role,
          currentPath: '/app/tasks/create',
          isAuthenticated: true,
          isInitial: false,
        ),
        isNull,
      );

      // Staff is blocked from cases
      expect(
        RoleGuard.evaluate(
          userRole: role,
          currentPath: '/app/cases/create',
          isAuthenticated: true,
          isInitial: false,
        ),
        '/app/dashboard',
      );
    });
  });
}
