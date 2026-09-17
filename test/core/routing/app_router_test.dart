import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/routing/app_router.dart';
import 'package:flutter_application_1/features/auth/data/models/user_profile.dart';
import 'package:flutter_application_1/features/auth/domain/models/role_capabilities.dart';
import 'package:flutter_application_1/features/auth/domain/models/user_role.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_notifier.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_application_1/features/dashboard/data/models/dashboard_models.dart';
import 'package:flutter_application_1/features/dashboard/presentation/providers/dashboard_notifier.dart';
import 'package:flutter_application_1/features/documents/data/models/document_model.dart';
import 'package:flutter_application_1/features/documents/presentation/providers/documents_notifier.dart';
import 'package:flutter_application_1/features/firms/data/models/tenant_firm.dart';
import 'package:flutter_application_1/features/firms/presentation/providers/firms_notifier.dart';
import 'package:flutter_application_1/features/payments/data/models/payment_model.dart';
import 'package:flutter_application_1/features/payments/presentation/providers/payments_notifier.dart';
import 'package:flutter_application_1/features/tasks/data/models/task_model.dart';
import 'package:flutter_application_1/features/tasks/presentation/providers/tasks_notifier.dart';

class _MockAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _MockAuthNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockDashboardNotifier extends StateNotifier<AsyncValue<DashboardData>>
    implements DashboardNotifier {
  _MockDashboardNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockTasksNotifier extends StateNotifier<AsyncValue<List<Task>>>
    implements TasksNotifier {
  _MockTasksNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockDocumentsNotifier extends StateNotifier<AsyncValue<List<Document>>>
    implements DocumentsNotifier {
  _MockDocumentsNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockPaymentsNotifier extends StateNotifier<AsyncValue<List<Payment>>>
    implements PaymentsNotifier {
  _MockPaymentsNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockFirmsNotifier extends StateNotifier<AsyncValue<List<TenantFirm>>>
    implements FirmsNotifier {
  _MockFirmsNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

final _mockOverrides = [
  dashboardNotifierProvider.overrideWith(
    (ref) => _MockDashboardNotifier(const AsyncValue.data(DashboardData())),
  ),
  tasksNotifierProvider.overrideWith(
    (ref) => _MockTasksNotifier(const AsyncValue.data([])),
  ),
  documentsNotifierProvider.overrideWith(
    (ref) => _MockDocumentsNotifier(const AsyncValue.data([])),
  ),
  paymentsNotifierProvider.overrideWith(
    (ref) => _MockPaymentsNotifier(const AsyncValue.data([])),
  ),
  firmsNotifierProvider.overrideWith(
    (ref) => _MockFirmsNotifier(const AsyncValue.data([])),
  ),
];

void main() {
  group('AppRouter Route Guard Tests', () {
    testWidgets(
      'Unauthenticated user is redirected to /login when navigating to /app/dashboard',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            ..._mockOverrides,
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState.unauthenticated()),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        router.go('/app/dashboard');
        await tester.pump(const Duration(seconds: 2));

        expect(router.routeInformationProvider.value.uri.path, '/login');
      },
    );

    testWidgets(
      'Non-super_admin is blocked from /app/firms and redirected to /app/dashboard',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            ..._mockOverrides,
            currentUserRoleProvider.overrideWithValue(UserRole.firmAdmin),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(
                const AuthState.authenticated(
                  UserProfile(
                    id: 2,
                    username: 'admin1',
                    email: 'admin@firm.com',
                    role: 'admin',
                  ),
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        router.go('/app/firms');
        await tester.pump(const Duration(seconds: 2));

        expect(
          router.routeInformationProvider.value.uri.path,
          '/app/dashboard',
        );
      },
    );

    testWidgets(
      'Lawyer is blocked from /app/more/payments and redirected to /app/dashboard',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            ..._mockOverrides,
            currentUserRoleProvider.overrideWithValue(UserRole.lawyer),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(
                const AuthState.authenticated(
                  UserProfile(
                    id: 3,
                    username: 'lawyer1',
                    email: 'lawyer@firm.com',
                    role: 'lawyer',
                  ),
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        router.go('/app/more/payments');
        await tester.pump(const Duration(seconds: 2));

        expect(
          router.routeInformationProvider.value.uri.path,
          '/app/dashboard',
        );
      },
    );

    testWidgets(
      'Staff is blocked from /app/cases and redirected to /app/dashboard',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            ..._mockOverrides,
            currentUserRoleProvider.overrideWithValue(UserRole.staff),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(
                const AuthState.authenticated(
                  UserProfile(
                    id: 4,
                    username: 'staff1',
                    email: 'staff@firm.com',
                    role: 'staff',
                  ),
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        router.go('/app/cases');
        await tester.pump(const Duration(seconds: 2));

        expect(
          router.routeInformationProvider.value.uri.path,
          '/app/dashboard',
        );
      },
    );

    testWidgets(
      'Staff is blocked from /app/more/documents and redirected to /app/dashboard',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            ..._mockOverrides,
            currentUserRoleProvider.overrideWithValue(UserRole.staff),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(
                const AuthState.authenticated(
                  UserProfile(
                    id: 4,
                    username: 'staff1',
                    email: 'staff@firm.com',
                    role: 'staff',
                  ),
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        router.go('/app/more/documents');
        await tester.pump(const Duration(seconds: 2));

        expect(
          router.routeInformationProvider.value.uri.path,
          '/app/dashboard',
        );
      },
    );

    testWidgets(
      'Lawyer is blocked from firm admin team routes and redirected to /app/more',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            ..._mockOverrides,
            currentUserRoleProvider.overrideWithValue(UserRole.lawyer),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(
                const AuthState.authenticated(
                  UserProfile(
                    id: 3,
                    username: 'lawyer1',
                    email: 'lawyer@firm.com',
                    role: 'lawyer',
                  ),
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        router.go('/app/more/team');
        await tester.pump(const Duration(seconds: 2));

        expect(router.routeInformationProvider.value.uri.path, '/app/more');
      },
    );

    testWidgets(
      'Lawyer is blocked from firm admin branding routes and redirected to /app/more',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            ..._mockOverrides,
            currentUserRoleProvider.overrideWithValue(UserRole.lawyer),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(
                const AuthState.authenticated(
                  UserProfile(
                    id: 3,
                    username: 'lawyer1',
                    email: 'lawyer@firm.com',
                    role: 'lawyer',
                  ),
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        router.go('/app/more/branding');
        await tester.pump(const Duration(seconds: 2));

        expect(router.routeInformationProvider.value.uri.path, '/app/more');
      },
    );

    testWidgets(
      'Staff is blocked from firm admin subscriptions route and redirected to /app/more',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            ..._mockOverrides,
            currentUserRoleProvider.overrideWithValue(UserRole.staff),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(
                const AuthState.authenticated(
                  UserProfile(
                    id: 4,
                    username: 'staff1',
                    email: 'staff@firm.com',
                    role: 'staff',
                  ),
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        router.go('/app/more/subscriptions');
        await tester.pump(const Duration(seconds: 2));

        expect(router.routeInformationProvider.value.uri.path, '/app/more');
      },
    );

    testWidgets(
      'Unauthenticated user is redirected to /login when navigating to /app/more/support',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            ..._mockOverrides,
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState.unauthenticated()),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        router.go('/app/more/support');
        await tester.pump(const Duration(seconds: 2));

        expect(router.routeInformationProvider.value.uri.path, '/login');
      },
    );

    testWidgets(
      'Lawyer is blocked from /app/plans and redirected to /app/dashboard',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            ..._mockOverrides,
            currentUserRoleProvider.overrideWithValue(UserRole.lawyer),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(
                const AuthState.authenticated(
                  UserProfile(
                    id: 3,
                    username: 'lawyer1',
                    email: 'lawyer@firm.com',
                    role: 'lawyer',
                  ),
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        router.go('/app/plans');
        await tester.pump(const Duration(seconds: 2));

        expect(
          router.routeInformationProvider.value.uri.path,
          '/app/dashboard',
        );
      },
    );

    testWidgets(
      'Lawyer is blocked from /app/platform-team and redirected to /app/dashboard',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            ..._mockOverrides,
            currentUserRoleProvider.overrideWithValue(UserRole.lawyer),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(
                const AuthState.authenticated(
                  UserProfile(
                    id: 3,
                    username: 'lawyer1',
                    email: 'lawyer@firm.com',
                    role: 'lawyer',
                  ),
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        router.go('/app/platform-team');
        await tester.pump(const Duration(seconds: 2));

        expect(
          router.routeInformationProvider.value.uri.path,
          '/app/dashboard',
        );
      },
    );

    testWidgets(
      'Super Admin is isolated from tenant cases and redirected to /app/dashboard',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            ..._mockOverrides,
            currentUserRoleProvider.overrideWithValue(UserRole.superAdmin),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(
                const AuthState.authenticated(
                  UserProfile(
                    id: 1,
                    username: 'superadmin',
                    email: 'admin@platform.com',
                    role: 'super_admin',
                    isSuperuser: true,
                  ),
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(appRouterProvider);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        router.go('/app/cases');
        await tester.pump(const Duration(seconds: 2));

        expect(
          router.routeInformationProvider.value.uri.path,
          '/app/dashboard',
        );
      },
    );
  });
}
