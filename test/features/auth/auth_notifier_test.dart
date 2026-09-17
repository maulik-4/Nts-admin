import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/errors/api_exception.dart';
import 'package:flutter_application_1/core/storage/secure_token_storage.dart';
import 'package:flutter_application_1/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_application_1/features/auth/data/models/accept_invite_request.dart';
import 'package:flutter_application_1/features/auth/data/models/register_request.dart';
import 'package:flutter_application_1/features/auth/data/models/user_profile.dart';
import 'package:flutter_application_1/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_notifier.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_state.dart';

class FakeAuthRepository implements AuthRepository {
  bool shouldFail = false;
  String? failMessage;
  UserProfile? mockUser;

  @override
  AuthRemoteDataSource get remoteDataSource => throw UnimplementedError();

  @override
  SecureTokenStorage get tokenStorage => throw UnimplementedError();

  @override
  Future<UserProfile> login({
    required String username,
    required String password,
  }) async {
    if (shouldFail) {
      throw ApiException(message: failMessage ?? 'Invalid credentials');
    }
    return mockUser ??
        UserProfile(
          id: 1,
          username: username,
          email: '$username@firm.com',
          role: 'lawyer',
        );
  }

  @override
  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    if (shouldFail) {
      throw ApiException(message: failMessage ?? 'Registration failed');
    }
    return {'message': 'Success'};
  }

  @override
  Future<Map<String, dynamic>> acceptInvite(AcceptInviteRequest request) async {
    if (shouldFail) {
      throw ApiException(message: failMessage ?? 'Accept invite failed');
    }
    return {'message': 'Invite accepted'};
  }

  @override
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    if (shouldFail) {
      throw ApiException(message: failMessage ?? 'Forgot password failed');
    }
    return {'message': 'Reset link sent'};
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async {
    if (shouldFail) {
      throw ApiException(message: failMessage ?? 'Reset password failed');
    }
    return {'message': 'Password reset successful'};
  }

  @override
  Future<UserProfile?> restoreSession() async {
    if (shouldFail) {
      return null;
    }
    return mockUser;
  }

  @override
  Future<void> logout() async {
    mockUser = null;
  }
}

void main() {
  group('AuthNotifier Tests', () {
    late FakeAuthRepository repository;
    late AuthNotifier notifier;

    setUp(() {
      repository = FakeAuthRepository();
      notifier = AuthNotifier(repository);
    });

    test('initial state is AuthStatus.initial', () {
      expect(notifier.state.status, AuthStatus.initial);
      expect(notifier.state.isInitial, isTrue);
    });

    test(
      'successful login sets state to authenticated with UserProfile',
      () async {
        final success = await notifier.login('advocate.test', 'password123');

        expect(success, isTrue);
        expect(notifier.state.status, AuthStatus.authenticated);
        expect(notifier.state.isAuthenticated, isTrue);
        expect(notifier.state.user?.username, 'advocate.test');
        expect(notifier.state.hasError, isFalse);
      },
    );

    test(
      'failed login sets state to error with user-friendly message',
      () async {
        repository.shouldFail = true;
        repository.failMessage = 'Invalid username or password.';

        final success = await notifier.login('wrong.user', 'wrong.pass');

        expect(success, isFalse);
        expect(notifier.state.status, AuthStatus.error);
        expect(notifier.state.hasError, isTrue);
        expect(notifier.state.errorMessage, 'Invalid username or password.');
        expect(notifier.state.isAuthenticated, isFalse);
      },
    );

    test(
      'logout clears user profile and sets state to unauthenticated',
      () async {
        // First login
        await notifier.login('advocate.test', 'password123');
        expect(notifier.state.isAuthenticated, isTrue);

        // Now logout
        await notifier.logout();
        expect(notifier.state.status, AuthStatus.unauthenticated);
        expect(notifier.state.isUnauthenticated, isTrue);
        expect(notifier.state.user, isNull);
      },
    );

    test('handleUnauthorized transitions state to unauthenticated', () async {
      await notifier.login('advocate.test', 'password123');
      expect(notifier.state.isAuthenticated, isTrue);

      notifier.handleUnauthorized();
      expect(notifier.state.status, AuthStatus.unauthenticated);
      expect(notifier.state.user, isNull);
    });

    test('checkSession with valid existing credentials restores authenticated state', () async {
      repository.mockUser = const UserProfile(
        id: 10,
        username: 'senior.partner',
        email: 'partner@lawfirm.in',
        role: 'admin',
      );

      await notifier.checkSession();
      expect(notifier.state.status, AuthStatus.authenticated);
      expect(notifier.state.user?.username, 'senior.partner');
      expect(notifier.state.user?.role, 'admin');
    });

    test(
      'checkSession with no credentials transitions to unauthenticated',
      () async {
        repository.mockUser = null;

        await notifier.checkSession();
        expect(notifier.state.status, AuthStatus.unauthenticated);
        expect(notifier.state.user, isNull);
      },
    );
  });
}
