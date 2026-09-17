import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/auth/domain/models/role_capabilities.dart';
import 'package:flutter_application_1/features/auth/domain/models/user_role.dart';
import 'package:flutter_application_1/shared/widgets/capability_gate.dart';

void main() {
  group('CapabilityGate Widget Tests', () {
    testWidgets('CapabilityGate renders child when capability is present', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserRoleProvider.overrideWithValue(UserRole.firmAdmin),
          ],
          child: const MaterialApp(
            home: CapabilityGate(
              capability: UserCapability.createCase,
              child: Text('Add Case Button'),
            ),
          ),
        ),
      );

      expect(find.text('Add Case Button'), findsOneWidget);
    });

    testWidgets('CapabilityGate renders fallback when capability is absent', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserRoleProvider.overrideWithValue(UserRole.staff),
          ],
          child: const MaterialApp(
            home: CapabilityGate(
              capability: UserCapability.createCase,
              fallback: Text('Access Denied'),
              child: Text('Add Case Button'),
            ),
          ),
        ),
      );

      expect(find.text('Add Case Button'), findsNothing);
      expect(find.text('Access Denied'), findsOneWidget);
    });

    testWidgets(
      'CapabilityGate renders SizedBox.shrink when capability is absent without fallback',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserRoleProvider.overrideWithValue(UserRole.staff),
            ],
            child: const MaterialApp(
              home: CapabilityGate(
                capability: UserCapability.createCase,
                child: Text('Add Case Button'),
              ),
            ),
          ),
        );

        expect(find.text('Add Case Button'), findsNothing);
      },
    );
  });

  group('RoleGate Widget Tests', () {
    testWidgets('RoleGate renders child when role is in allowedRoles', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserRoleProvider.overrideWithValue(UserRole.superAdmin),
          ],
          child: const MaterialApp(
            home: RoleGate(
              allowedRoles: [UserRole.superAdmin],
              child: Text('Platform Console'),
            ),
          ),
        ),
      );

      expect(find.text('Platform Console'), findsOneWidget);
    });

    testWidgets('RoleGate hides child when role is not in allowedRoles', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserRoleProvider.overrideWithValue(UserRole.lawyer),
          ],
          child: const MaterialApp(
            home: RoleGate(
              allowedRoles: [UserRole.superAdmin],
              child: Text('Platform Console'),
            ),
          ),
        ),
      );

      expect(find.text('Platform Console'), findsNothing);
    });
  });
}
