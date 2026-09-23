import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/models/role_capabilities.dart';
import 'role_guard.dart';

import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/screens/accept_invite_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/new_user_feedback_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/branding/presentation/screens/branding_settings_screen.dart';
import '../../features/cases/presentation/screens/case_detail_screen.dart';
import '../../features/cases/presentation/screens/case_form_screen.dart';
import '../../features/cases/presentation/screens/cases_list_screen.dart';
import '../../features/clients/presentation/screens/client_detail_screen.dart';
import '../../features/clients/presentation/screens/client_form_screen.dart';
import '../../features/clients/presentation/screens/clients_list_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/documents/presentation/screens/document_detail_screen.dart';
import '../../features/documents/presentation/screens/document_upload_screen.dart';
import '../../features/documents/presentation/screens/documents_list_screen.dart';
import '../../features/firms/presentation/screens/firms_list_screen.dart';
import '../../features/hearings/presentation/screens/hearing_detail_screen.dart';
import '../../features/hearings/presentation/screens/hearing_form_screen.dart';
import '../../features/hearings/presentation/screens/hearings_list_screen.dart';
import '../../features/messages/presentation/screens/messages_list_screen.dart';
import '../../features/notifications/presentation/screens/notifications_list_screen.dart';
import '../../features/payments/presentation/screens/payment_detail_screen.dart';
import '../../features/payments/presentation/screens/payment_form_screen.dart';
import '../../features/payments/presentation/screens/payments_list_screen.dart';
import '../../features/platform_team/presentation/screens/platform_team_screen.dart';
import '../../features/profile/presentation/screens/user_profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shell/presentation/screens/app_shell.dart';
import '../../features/shell/presentation/screens/more_screen.dart';
import '../../features/subscriptions/presentation/screens/platform_plans_screen.dart';
import '../../features/subscriptions/presentation/screens/subscription_screen.dart';
import '../../features/support/presentation/screens/support_ticket_detail_screen.dart';
import '../../features/support/presentation/screens/support_tickets_list_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/tasks/presentation/screens/task_form_screen.dart';
import '../../features/tasks/presentation/screens/tasks_list_screen.dart';
import '../../features/team/presentation/screens/team_list_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: routerNotifier,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/new-user',
        builder: (context, state) => const NewUserFeedbackScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/accept-invite',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return AcceptInviteScreen(initialToken: token);
        },
      ),

      GoRoute(path: '/app', redirect: (context, state) => '/app/dashboard'),
      GoRoute(
        path: '/app/team',
        redirect: (context, state) => '/app/more/team',
      ),
      GoRoute(
        path: '/app/advocates',
        redirect: (context, state) => '/app/more/advocates',
      ),
      GoRoute(
        path: '/app/subscriptions',
        redirect: (context, state) => '/app/more/subscriptions',
      ),
      GoRoute(
        path: '/app/subscription',
        redirect: (context, state) => '/app/more/subscriptions',
      ),
      GoRoute(
        path: '/app/quota',
        redirect: (context, state) => '/app/more/subscriptions',
      ),
      GoRoute(
        path: '/app/branding',
        redirect: (context, state) => '/app/more/branding',
      ),
      GoRoute(
        path: '/app/notifications',
        redirect: (context, state) => '/app/more/notifications',
      ),
      GoRoute(
        path: '/app/support',
        redirect: (context, state) => '/app/more/support',
      ),
      GoRoute(
        path: '/app/messages',
        redirect: (context, state) => '/app/more/messages',
      ),
      GoRoute(
        path: '/app/profile',
        redirect: (context, state) => '/app/more/profile',
      ),
      GoRoute(
        path: '/app/settings',
        redirect: (context, state) => '/app/more/settings',
      ),

      // Stateful Shell Route for Core Legal Workspace
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 1: Cases
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/cases',
                builder: (context, state) => const CasesListScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) {
                      final clientId = int.tryParse(
                        state.uri.queryParameters['clientId'] ?? '',
                      );
                      return CaseFormScreen(initialClientId: clientId);
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return CaseDetailScreen(caseId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          return CaseFormScreen(caseId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Clients
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/clients',
                builder: (context, state) => const ClientsListScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const ClientFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return ClientDetailScreen(clientId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          return ClientFormScreen(clientId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Hearings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/hearings',
                builder: (context, state) => const HearingsListScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) {
                      final caseId = int.tryParse(
                        state.uri.queryParameters['caseId'] ?? '',
                      );
                      return HearingFormScreen(initialCaseId: caseId);
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return HearingDetailScreen(hearingId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          return HearingFormScreen(hearingId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Branch 4: Tasks (Primary branch for Staff and direct access)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/tasks',
                builder: (context, state) => const TasksListScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) {
                      final caseId = int.tryParse(
                        state.uri.queryParameters['caseId'] ?? '',
                      );
                      return TaskFormScreen(initialCaseId: caseId);
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return TaskDetailScreen(taskId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          return TaskFormScreen(taskId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Branch 5: Tenant Firms (Super Admin Platform management)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/firms',
                builder: (context, state) => const FirmsListScreen(),
              ),
            ],
          ),

          // Branch 6: More & Operations
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/more',
                builder: (context, state) => const MoreScreen(),
                routes: [
                  // Documents
                  GoRoute(
                    path: 'documents',
                    builder: (context, state) => const DocumentsListScreen(),
                    routes: [
                      GoRoute(
                        path: 'upload',
                        builder: (context, state) {
                          final caseId = int.tryParse(
                            state.uri.queryParameters['caseId'] ?? '',
                          );
                          return DocumentUploadScreen(initialCaseId: caseId);
                        },
                      ),
                      GoRoute(
                        path: ':id',
                        builder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          return DocumentDetailScreen(documentId: id);
                        },
                      ),
                    ],
                  ),

                  // Payments
                  GoRoute(
                    path: 'payments',
                    builder: (context, state) => const PaymentsListScreen(),
                    routes: [
                      GoRoute(
                        path: 'create',
                        builder: (context, state) {
                          final caseId = int.tryParse(
                            state.uri.queryParameters['caseId'] ?? '',
                          );
                          final clientId = int.tryParse(
                            state.uri.queryParameters['clientId'] ?? '',
                          );
                          return PaymentFormScreen(
                            initialCaseId: caseId,
                            initialClientId: clientId,
                          );
                        },
                      ),
                      GoRoute(
                        path: ':id',
                        builder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          return PaymentDetailScreen(paymentId: id);
                        },
                      ),
                    ],
                  ),

                  // Backwards compatibility redirects for /app/more/tasks/*
                  GoRoute(
                    path: 'tasks',
                    redirect: (context, state) {
                      final path = state.uri.path;
                      if (path == '/app/more/tasks' ||
                          path == '/app/more/tasks/') {
                        return '/app/tasks';
                      }
                      if (path.startsWith('/app/more/tasks/create')) {
                        final caseId = state.uri.queryParameters['caseId'];
                        return caseId != null
                            ? '/app/tasks/create?caseId=$caseId'
                            : '/app/tasks/create';
                      }
                      return null;
                    },
                    routes: [
                      GoRoute(
                        path: 'create',
                        redirect: (context, state) {
                          final caseId = state.uri.queryParameters['caseId'];
                          return caseId != null
                              ? '/app/tasks/create?caseId=$caseId'
                              : '/app/tasks/create';
                        },
                      ),
                      GoRoute(
                        path: ':id',
                        redirect: (context, state) {
                          final id = state.pathParameters['id'];
                          return '/app/tasks/$id';
                        },
                        routes: [
                          GoRoute(
                            path: 'edit',
                            redirect: (context, state) {
                              final id = state.pathParameters['id'];
                              return '/app/tasks/$id/edit';
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Team & Advocates
                  GoRoute(
                    path: 'team',
                    builder: (context, state) => const TeamListScreen(),
                  ),
                  GoRoute(
                    path: 'advocates',
                    builder: (context, state) =>
                        const TeamListScreen(initialFilter: 'advocates'),
                  ),

                  // Subscriptions & Quota
                  GoRoute(
                    path: 'subscriptions',
                    builder: (context, state) => const SubscriptionScreen(),
                  ),
                  GoRoute(
                    path: 'quota',
                    redirect: (context, state) => '/app/more/subscriptions',
                  ),

                  // Notifications
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) =>
                        const NotificationsListScreen(),
                  ),

                  // Help & Support
                  GoRoute(
                    path: 'support',
                    builder: (context, state) =>
                        const SupportTicketsListScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          return SupportTicketDetailScreen(ticketId: id);
                        },
                      ),
                    ],
                  ),

                  // Firm Messages
                  GoRoute(
                    path: 'messages',
                    builder: (context, state) => const MessagesListScreen(),
                  ),

                  // Firm Branding
                  GoRoute(
                    path: 'branding',
                    builder: (context, state) => const BrandingSettingsScreen(),
                  ),

                  // User Profile
                  GoRoute(
                    path: 'profile',
                    builder: (context, state) => const UserProfileScreen(),
                  ),

                  // Settings
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 7: Platform Plans (Super Admin)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/plans',
                builder: (context, state) => const PlatformPlansScreen(),
              ),
            ],
          ),

          // Branch 8: Platform Team (Super Admin)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/platform-team',
                builder: (context, state) => const PlatformTeamScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final userRole = ref.read(currentUserRoleProvider);

      return RoleGuard.evaluate(
        userRole: userRole,
        currentPath: state.matchedLocation,
        isAuthenticated: authState.isAuthenticated,
        isInitial: authState.isInitial,
      );
    },
  );
});

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.status != next.status ||
          previous?.user?.role != next.user?.role ||
          previous?.user?.isSuperuser != next.user?.isSuperuser ||
          previous?.user?.id != next.user?.id) {
        notifyListeners();
      }
    });
  }
}
