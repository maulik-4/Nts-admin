import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/errors/api_exception.dart';
import 'package:flutter_application_1/core/network/error_interceptor.dart';
import 'package:flutter_application_1/core/routing/role_guard.dart';
import 'package:flutter_application_1/core/routing/role_menu_config.dart';
import 'package:flutter_application_1/core/storage/secure_token_storage.dart';
import 'package:flutter_application_1/features/auth/data/models/auth_token_response.dart';
import 'package:flutter_application_1/features/auth/domain/models/auth_response.dart';
import 'package:flutter_application_1/features/auth/domain/models/user_role.dart';

class _InMemoryTokenStorage extends SecureTokenStorage {
  String? _access;
  String? _refresh;
  String? _userProfile;

  @override
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => _access;

  @override
  Future<String?> getRefreshToken() async => _refresh;

  @override
  Future<void> saveUserProfile(String userProfileJson) async {
    _userProfile = userProfileJson;
  }

  @override
  Future<String?> getUserProfile() async => _userProfile;

  @override
  Future<bool> hasAccessToken() async => _access != null && _access!.isNotEmpty;

  @override
  Future<void> clearTokens() async {
    _access = null;
    _refresh = null;
    _userProfile = null;
  }
}

void main() {
  group('Master Prompt RBAC — Role-Based Implementation Tests', () {
    // =========================================================================
    // 1. TEST CASE 30: EXACT LOGIN RESPONSE PARSING & ROLE RESOLUTION
    // =========================================================================
    test('Requirement 30: Test case TK_vadv lawyer payload parses and establishes Lawyer role', () {
      final jsonPayload = {
        "refresh": "TEST_REFRESH_TOKEN",
        "access": "TEST_ACCESS_TOKEN",
        "user": {
          "id": 6,
          "username": "TK_vadv",
          "email": "tkvadv1992@gmail.com",
          "role": "lawyer",
          "firm": 1,
        },
      };

      // 1. Parse via AuthTokenResponse
      final tokenResponse = AuthTokenResponse.fromJson(jsonPayload);
      expect(tokenResponse.accessToken, 'TEST_ACCESS_TOKEN');
      expect(tokenResponse.refreshToken, 'TEST_REFRESH_TOKEN');
      expect(tokenResponse.role, 'lawyer');

      final user = tokenResponse.user!;
      expect(user.id, 6);
      expect(user.username, 'TK_vadv');
      expect(user.email, 'tkvadv1992@gmail.com');
      expect(user.role, 'lawyer');
      expect(user.firm, 1);
      expect(user.firmId, 1);

      // 2. Authoritative role check: must resolve to UserRole.lawyer
      expect(user.userRole, UserRole.lawyer);
      expect(user.isLawyer, isTrue);
      expect(user.isSuperAdmin, isFalse);
      expect(user.isAdmin, isFalse);
      expect(user.isFirmAdmin, isFalse);
      expect(user.isStaff, isFalse);

      // 3. Parse via AuthResponse
      final authResponse = AuthResponse.fromJson(jsonPayload);
      expect(authResponse.access, 'TEST_ACCESS_TOKEN');
      expect(authResponse.refresh, 'TEST_REFRESH_TOKEN');
      expect(authResponse.userRole, UserRole.lawyer);
      expect(authResponse.user.firm, 1);

      // 4. Role Navigation Menu for Lawyer
      final lawyerMenu = RoleMenuConfig.getMenuForRole(UserRole.lawyer);
      final titles = lawyerMenu.map((m) => m.title).toList();
      expect(titles, contains('Dashboard'));
      expect(titles, contains('My Cases'));
      expect(titles, contains('My Clients'));
      expect(titles, contains('Hearings'));
      expect(titles, contains('Workspace'));
      expect(titles, isNot(contains('Tenant Firms')));
      expect(titles, isNot(contains('Platform Team')));

      // 5. RoleGuard protection for Lawyer
      // Allowed routes:
      expect(
        RoleGuard.evaluate(
          userRole: UserRole.lawyer,
          currentPath: '/app/dashboard',
          isAuthenticated: true,
          isInitial: false,
        ),
        isNull,
      );
      expect(
        RoleGuard.evaluate(
          userRole: UserRole.lawyer,
          currentPath: '/app/cases',
          isAuthenticated: true,
          isInitial: false,
        ),
        isNull,
      );
      expect(
        RoleGuard.evaluate(
          userRole: UserRole.lawyer,
          currentPath: '/app/more/documents',
          isAuthenticated: true,
          isInitial: false,
        ),
        isNull,
      );

      // Denied Super Admin platform routes:
      expect(
        RoleGuard.evaluate(
          userRole: UserRole.lawyer,
          currentPath: '/app/firms',
          isAuthenticated: true,
          isInitial: false,
        ),
        '/app/dashboard',
      );
      expect(
        RoleGuard.evaluate(
          userRole: UserRole.lawyer,
          currentPath: '/app/plans',
          isAuthenticated: true,
          isInitial: false,
        ),
        '/app/dashboard',
      );
      expect(
        RoleGuard.evaluate(
          userRole: UserRole.lawyer,
          currentPath: '/app/platform-team',
          isAuthenticated: true,
          isInitial: false,
        ),
        '/app/dashboard',
      );

      // Denied Firm Admin management routes:
      expect(
        RoleGuard.evaluate(
          userRole: UserRole.lawyer,
          currentPath: '/app/more/team',
          isAuthenticated: true,
          isInitial: false,
        ),
        '/app/more',
      );
      expect(
        RoleGuard.evaluate(
          userRole: UserRole.lawyer,
          currentPath: '/app/more/branding',
          isAuthenticated: true,
          isInitial: false,
        ),
        '/app/more',
      );
      expect(
        RoleGuard.evaluate(
          userRole: UserRole.lawyer,
          currentPath: '/app/more/payments',
          isAuthenticated: true,
          isInitial: false,
        ),
        '/app/dashboard',
      );
    });

    // =========================================================================
    // 2. ROLE PARSER & NORMALIZATION TESTS
    // =========================================================================
    test('Role parser normalizes admin, firm_admin, super_admin, lawyer, staff without guessing', () {
      expect(parseUserRole('super_admin'), UserRole.superAdmin);
      expect(parseUserRole('admin'), UserRole.admin);
      expect(parseUserRole('firm_admin'), UserRole.admin);
      expect(parseUserRole('lawyer'), UserRole.lawyer);
      expect(parseUserRole('staff'), UserRole.staff);

      // Unknown roles must NOT silently convert to staff/lawyer/admin
      expect(parseUserRole('unknown_role'), UserRole.unknown);
      expect(parseUserRole('contractor'), UserRole.unknown);
      expect(parseUserRole('guest'), UserRole.unknown);
      expect(parseUserRole(null), UserRole.unknown);
    });

    // =========================================================================
    // 3. SECURITY TESTS: ROUTE GUARD MATRIX
    // =========================================================================
    group('Security Tests — Multi-Role Route Guard Matrix', () {
      test('Super Admin has access to platform console and is isolated from tenant cases', () {
        const role = UserRole.superAdmin;
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/firms',
            isAuthenticated: true,
            isInitial: false,
          ),
          isNull,
        );
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/plans',
            isAuthenticated: true,
            isInitial: false,
          ),
          isNull,
        );
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/platform-team',
            isAuthenticated: true,
            isInitial: false,
          ),
          isNull,
        );

        // Isolated from confidential tenant matters:
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/cases',
            isAuthenticated: true,
            isInitial: false,
          ),
          '/app/dashboard',
        );
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/clients',
            isAuthenticated: true,
            isInitial: false,
          ),
          '/app/dashboard',
        );
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/hearings',
            isAuthenticated: true,
            isInitial: false,
          ),
          '/app/dashboard',
        );
      });

      test('Firm Admin has litigation and firm management access, blocked from platform console', () {
        const role = UserRole.admin;
        // Allowed:
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/cases',
            isAuthenticated: true,
            isInitial: false,
          ),
          isNull,
        );
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/more/team',
            isAuthenticated: true,
            isInitial: false,
          ),
          isNull,
        );
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/more/payments',
            isAuthenticated: true,
            isInitial: false,
          ),
          isNull,
        );
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/more/branding',
            isAuthenticated: true,
            isInitial: false,
          ),
          isNull,
        );

        // Blocked from Super Admin platform console:
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/firms',
            isAuthenticated: true,
            isInitial: false,
          ),
          '/app/dashboard',
        );
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/plans',
            isAuthenticated: true,
            isInitial: false,
          ),
          '/app/dashboard',
        );
      });

      test('Staff has operational tasks queue access, blocked from cases, documents, and payments', () {
        const role = UserRole.staff;
        // Allowed:
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/tasks',
            isAuthenticated: true,
            isInitial: false,
          ),
          isNull,
        );
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/clients',
            isAuthenticated: true,
            isInitial: false,
          ),
          isNull,
        );
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/hearings',
            isAuthenticated: true,
            isInitial: false,
          ),
          isNull,
        );

        // Blocked:
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/cases',
            isAuthenticated: true,
            isInitial: false,
          ),
          '/app/dashboard',
        );
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/more/documents',
            isAuthenticated: true,
            isInitial: false,
          ),
          '/app/dashboard',
        );
        expect(
          RoleGuard.evaluate(
            userRole: role,
            currentPath: '/app/more/payments',
            isAuthenticated: true,
            isInitial: false,
          ),
          '/app/dashboard',
        );
      });
    });

    // =========================================================================
    // 4. ERROR INTERCEPTOR: 401 REFRESH & 403 FORBIDDEN HANDLING
    // =========================================================================
    group('ErrorInterceptor 401 & 403 Handling', () {
      test('403 Forbidden does NOT trigger auto-logout and does NOT clear storage', () async {
        final storage = _InMemoryTokenStorage();
        await storage.saveTokens(accessToken: 'valid_access_token', refreshToken: 'valid_refresh_token');

        bool unauthorizedCalled = false;
        final interceptor = ErrorInterceptor(
          tokenStorage: storage,
          onUnauthorized: () {
            unauthorizedCalled = true;
          },
        );

        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/payments/'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/payments/'),
            statusCode: 403,
            data: {'detail': 'You do not have permission to perform this action.'},
          ),
        );

        final handler = _MockErrorInterceptorHandler();
        interceptor.onError(dioException, handler);

        // Verify tokens are NOT cleared
        expect(await storage.getAccessToken(), 'valid_access_token');
        expect(unauthorizedCalled, isFalse);
        expect(handler.rejectedError, isNotNull);
        expect(handler.rejectedError!.error, isA<ApiException>());
        expect((handler.rejectedError!.error as ApiException).statusCode, 403);
      });

      test('401 Unauthorized with missing refresh token clears storage and triggers onUnauthorized', () async {
        final storage = _InMemoryTokenStorage();
        await storage.saveTokens(accessToken: 'expired_access_token');

        bool unauthorizedCalled = false;
        final interceptor = ErrorInterceptor(
          tokenStorage: storage,
          onUnauthorized: () {
            unauthorizedCalled = true;
          },
        );

        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/cases/'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/cases/'),
            statusCode: 401,
            data: {'detail': 'Given token not valid for any token type'},
          ),
        );

        final handler = _MockErrorInterceptorHandler();
        interceptor.onError(dioException, handler);

        // Wait for async handler
        await Future.delayed(const Duration(milliseconds: 50));

        expect(await storage.getAccessToken(), isNull);
        expect(unauthorizedCalled, isTrue);
      });
    });
  });
}

class _MockErrorInterceptorHandler extends ErrorInterceptorHandler {
  DioException? rejectedError;
  Response<dynamic>? resolvedResponse;

  @override
  void reject(DioException error, [bool callFollowingErrorInterceptor = false]) {
    rejectedError = error;
  }

  @override
  void resolve(Response<dynamic> response) {
    resolvedResponse = response;
  }
}

