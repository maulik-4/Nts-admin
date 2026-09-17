import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/auth/data/models/user_profile.dart';
import 'package:flutter_application_1/features/auth/domain/models/role_capabilities.dart';
import 'package:flutter_application_1/features/auth/domain/models/user_role.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_notifier.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_application_1/features/cases/data/models/case_model.dart';
import 'package:flutter_application_1/features/clients/data/models/client_model.dart';
import 'package:flutter_application_1/features/clients/presentation/providers/clients_notifier.dart';
import 'package:flutter_application_1/features/dashboard/data/models/dashboard_models.dart';
import 'package:flutter_application_1/features/dashboard/presentation/providers/dashboard_notifier.dart';
import 'package:flutter_application_1/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter_application_1/features/documents/data/models/document_model.dart';
import 'package:flutter_application_1/features/documents/presentation/providers/documents_notifier.dart';
import 'package:flutter_application_1/features/firms/data/models/tenant_firm.dart';
import 'package:flutter_application_1/features/firms/presentation/providers/firms_notifier.dart';
import 'package:flutter_application_1/features/hearings/data/models/hearing_model.dart';
import 'package:flutter_application_1/features/hearings/presentation/providers/hearings_notifier.dart';
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

class _MockFirmsNotifier extends StateNotifier<AsyncValue<List<TenantFirm>>>
    implements FirmsNotifier {
  _MockFirmsNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockDashboardNotifier extends StateNotifier<AsyncValue<DashboardData>>
    implements DashboardNotifier {
  _MockDashboardNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockPaymentsNotifier extends StateNotifier<AsyncValue<List<Payment>>>
    implements PaymentsNotifier {
  _MockPaymentsNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockDocumentsNotifier extends StateNotifier<AsyncValue<List<Document>>>
    implements DocumentsNotifier {
  _MockDocumentsNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockTasksNotifier extends StateNotifier<AsyncValue<List<Task>>>
    implements TasksNotifier {
  _MockTasksNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHearingsNotifier extends StateNotifier<AsyncValue<List<Hearing>>>
    implements HearingsNotifier {
  _MockHearingsNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockClientsNotifier extends StateNotifier<AsyncValue<List<Client>>>
    implements ClientsNotifier {
  _MockClientsNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  const dummyDashboardData = DashboardData(
    totalClients: 8,
    totalCases: 14,
    openCases: 10,
    closedCases: 4,
    upcomingHearingsCount: 3,
    upcomingHearings: [
      Hearing(
        id: 1,
        title: 'Bail Hearing - Sharma v State',
        courtName: 'High Court of HP',
        date: '2026-09-20',
        caseId: 101,
      ),
    ],
    recentCases: [
      Case(
        id: 101,
        caseNumber: 'CRL/2026/042',
        title: 'Sharma v State',
        courtName: 'High Court of HP',
        status: 'open',
        caseType: 'Criminal',
        client: 5,
        firm: 15,
      ),
    ],
    taskStats: TaskStats(
      total: 5,
      pending: 2,
      inProgress: 1,
      completed: 2,
      overdue: 0,
    ),
  );

  group('Role-Distinct DashboardScreen Tests', () {
    testWidgets(
      'Super Admin dashboard renders platform metrics and tenant firms',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserRoleProvider.overrideWithValue(UserRole.superAdmin),
              authNotifierProvider.overrideWith(
                (ref) => _MockAuthNotifier(
                  const AuthState.authenticated(
                    UserProfile(
                      id: 1,
                      username: 'platform_super',
                      email: 'super@hphighcourt.site',
                      role: 'super_admin',
                      isSuperuser: true,
                    ),
                  ),
                ),
              ),
              firmsNotifierProvider.overrideWith(
                (ref) => _MockFirmsNotifier(
                  const AsyncValue.data([
                    TenantFirm(
                      id: 1,
                      name: 'Sharma & Associates',
                      email: 'sharma@firm.com',
                      isActive: true,
                      isBlocked: false,
                    ),
                    TenantFirm(
                      id: 2,
                      name: 'Verma Legal Chambers',
                      email: 'verma@firm.com',
                      isActive: false,
                      isBlocked: true,
                    ),
                  ]),
                ),
              ),
            ],
            child: const MaterialApp(home: DashboardScreen()),
          ),
        );

        await tester.pumpAndSettle();

        // Check Super Admin specific widgets
        expect(find.text('SUPER ADMIN'), findsOneWidget);
        expect(find.text('TENANT FIRMS'), findsOneWidget);
        expect(find.text('ACTIVE FIRMS'), findsOneWidget);
        expect(find.text('BLOCKED / INACTIVE'), findsOneWidget);
        expect(find.text('Tenant Law Firms Registry'), findsOneWidget);
        expect(find.text('Sharma & Associates'), findsOneWidget);
        expect(find.text('Manage Firms'), findsOneWidget);

        // Super Admin should NOT see firm operational widgets
        expect(find.text('Operational Tasks Queue'), findsNothing);
        expect(find.text('Firm Collections'), findsNothing);
      },
    );

    testWidgets(
      'Firm Admin dashboard renders full executive metrics and payments',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserRoleProvider.overrideWithValue(UserRole.firmAdmin),
              authNotifierProvider.overrideWith(
                (ref) => _MockAuthNotifier(
                  const AuthState.authenticated(
                    UserProfile(
                      id: 2,
                      username: 'firm_admin_user',
                      email: 'admin@firm.com',
                      role: 'admin',
                      firmName: 'Apex Legal Partners',
                    ),
                  ),
                ),
              ),
              dashboardNotifierProvider.overrideWith(
                (ref) => _MockDashboardNotifier(
                  const AsyncValue.data(dummyDashboardData),
                ),
              ),
              paymentsNotifierProvider.overrideWith(
                (ref) => _MockPaymentsNotifier(
                  const AsyncValue.data([
                    Payment(
                      id: 1,
                      amount: '15000',
                      caseId: 101,
                      clientId: 5,
                      firm: 15,
                      paymentMethod: PaymentMethod.bankTransfer,
                      status: PaymentStatus.paid,
                    ),
                  ]),
                ),
              ),
            ],
            child: const MaterialApp(home: DashboardScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('FIRM ADMIN'), findsOneWidget);
        expect(find.text('ACTIVE CLIENTS'), findsOneWidget);
        expect(find.text('TOTAL CASES'), findsOneWidget);
        expect(find.text('FIRM COLLECTIONS'), findsOneWidget);
        expect(find.text('Payment'), findsOneWidget);
        expect(find.text('Upcoming Hearings'), findsOneWidget);
        expect(find.text('Recent Cases'), findsOneWidget);
      },
    );

    testWidgets(
      'Lawyer dashboard renders advocate case and hearings workspace',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserRoleProvider.overrideWithValue(UserRole.lawyer),
              authNotifierProvider.overrideWith(
                (ref) => _MockAuthNotifier(
                  const AuthState.authenticated(
                    UserProfile(
                      id: 3,
                      username: 'advocate_raman',
                      email: 'raman@firm.com',
                      role: 'lawyer',
                      firmName: 'Apex Legal Partners',
                    ),
                  ),
                ),
              ),
              dashboardNotifierProvider.overrideWith(
                (ref) => _MockDashboardNotifier(
                  const AsyncValue.data(dummyDashboardData),
                ),
              ),
              documentsNotifierProvider.overrideWith(
                (ref) => _MockDocumentsNotifier(const AsyncValue.data([])),
              ),
            ],
            child: const MaterialApp(home: DashboardScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('LAWYER'), findsOneWidget);
        expect(find.text('ACTIVE CASES'), findsOneWidget);
        expect(find.text('COURT HEARINGS'), findsOneWidget);
        expect(find.text('ASSIGNED TASKS'), findsOneWidget);
        expect(find.text('DOCUMENTS'), findsOneWidget);

        // Lawyer should NOT see payments
        expect(find.text('FIRM COLLECTIONS'), findsNothing);
        expect(find.text('Payment'), findsNothing);
      },
    );

    testWidgets('Staff dashboard renders operational task queue and no cases', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserRoleProvider.overrideWithValue(UserRole.staff),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(
                const AuthState.authenticated(
                  UserProfile(
                    id: 4,
                    username: 'clerk_suman',
                    email: 'suman@firm.com',
                    role: 'staff',
                    firmName: 'Apex Legal Partners',
                  ),
                ),
              ),
            ),
            tasksNotifierProvider.overrideWith(
              (ref) => _MockTasksNotifier(
                const AsyncValue.data([
                  Task(
                    id: 201,
                    title: 'Draft Bail Application',
                    priority: TaskPriority.high,
                    status: TaskStatus.pending,
                    dueDate: '2026-09-22',
                  ),
                ]),
              ),
            ),
            hearingsNotifierProvider.overrideWith(
              (ref) => _MockHearingsNotifier(const AsyncValue.data([])),
            ),
            clientsNotifierProvider.overrideWith(
              (ref) => _MockClientsNotifier(const AsyncValue.data([])),
            ),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('STAFF'), findsOneWidget);
      expect(find.text('Operational Tasks Queue'), findsOneWidget);
      expect(find.text('Draft Bail Application'), findsOneWidget);
      expect(find.text('PENDING TASKS'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('Create Task'), findsOneWidget);
      expect(find.text('Register Client'), findsOneWidget);

      // Staff does not see Recent Cases or New Case quick action
      expect(find.text('Recent Cases'), findsNothing);
      expect(find.text('New Case'), findsNothing);
      expect(find.text('Firm Collections'), findsNothing);
    });
  });
}
