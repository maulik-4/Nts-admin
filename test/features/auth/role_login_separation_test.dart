import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/errors/api_exception.dart';
import 'package:flutter_application_1/core/storage/secure_token_storage.dart';
import 'package:flutter_application_1/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_application_1/features/auth/data/models/accept_invite_request.dart';
import 'package:flutter_application_1/features/auth/data/models/register_request.dart';
import 'package:flutter_application_1/features/auth/data/models/user_profile.dart';
import 'package:flutter_application_1/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/features/auth/domain/models/user.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_notifier.dart';
import 'package:flutter_application_1/features/client_portal/data/repositories/client_portal_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserProfile? nextUser;
  bool shouldThrow = false;
  String errorMessage = 'Invalid credentials';
  int logoutCallCount = 0;

  @override
  AuthRemoteDataSource get remoteDataSource => throw UnimplementedError();

  @override
  SecureTokenStorage get tokenStorage => throw UnimplementedError();

  @override
  Future<UserProfile> login({
    required String username,
    required String password,
    String? fcmToken,
  }) async {
    if (shouldThrow) {
      throw ApiException(message: errorMessage);
    }
    return nextUser ??
        UserProfile(
          id: 1,
          username: username,
          email: '$username@firm.com',
          role: 'lawyer',
        );
  }

  @override
  Future<void> logout() async {
    logoutCallCount++;
  }

  @override
  Future<Map<String, dynamic>> acceptInvite(
    AcceptInviteRequest request,
  ) async => {};
  @override
  Future<Map<String, dynamic>> forgotPassword(String email) async => {};
  @override
  Future<Map<String, dynamic>> register(RegisterRequest request) async => {};
  @override
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async => {};
  @override
  Future<UserProfile?> restoreSession() async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockClientRepository implements ClientPortalRepository {
  User? nextUser;
  bool shouldThrow = false;
  String errorMessage = 'Invalid client credentials';

  @override
  Future<User> clientLogin({
    required String usernameOrEmail,
    required String password,
  }) async {
    if (shouldThrow) {
      throw ApiException(message: errorMessage);
    }
    return nextUser ??
        User(
          id: 99,
          username: usernameOrEmail,
          email: '$usernameOrEmail@client.com',
          role: 'client',
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockAuthRepository authRepo;
  late MockClientRepository clientRepo;
  late AuthNotifier authNotifier;

  setUp(() {
    authRepo = MockAuthRepository();
    clientRepo = MockClientRepository();
    authNotifier = AuthNotifier(authRepo, clientRepo);
  });

  group('AuthNotifier Firm/Client Login Separation Tests', () {
    test('Firm login with client profile rejects and prompts to switch to Client Login', () async {
      // Simulate backend returning client user from /auth/login/
      authRepo.nextUser = const UserProfile(
        id: 42,
        username: 'acme_corp',
        email: 'acme@client.com',
        role: 'client',
      );

      final success = await authNotifier.login(
        'acme_corp',
        'password123',
        isClient: false,
      );

      expect(success, isFalse);
      expect(authNotifier.state.isAuthenticated, isFalse);
      expect(authNotifier.state.hasError, isTrue);
      expect(
        authNotifier.state.errorMessage,
        'This account is registered as a Client. Please switch to Client Login to sign in.',
      );
      expect(authRepo.logoutCallCount, 1);
    });

    test('Firm login where backend rejects but client portal recognizes credentials prompts switch', () async {
      // /auth/login/ throws Invalid credentials
      authRepo.shouldThrow = true;
      authRepo.errorMessage = 'Invalid username or password.';

      // client repo succeeds
      clientRepo.nextUser = const User(
        id: 42,
        username: 'client_alpha',
        email: 'alpha@client.com',
        role: 'client',
      );

      final success = await authNotifier.login(
        'client_alpha',
        'secret',
        isClient: false,
      );

      expect(success, isFalse);
      expect(authNotifier.state.isAuthenticated, isFalse);
      expect(authNotifier.state.hasError, isTrue);
      expect(
        authNotifier.state.errorMessage,
        'This account is registered as a Client. Please switch to Client Login to sign in.',
      );
    });

    test('Client login with lawyer/firm user rejects and prompts to switch to Firm Login', () async {
      // Simulate client portal returning user with role 'lawyer'
      clientRepo.nextUser = const User(
        id: 7,
        username: 'advocate_sharma',
        email: 'sharma@firm.com',
        role: 'lawyer',
      );

      final success = await authNotifier.login(
        'advocate_sharma',
        'lawyerPass',
        isClient: true,
      );

      expect(success, isFalse);
      expect(authNotifier.state.isAuthenticated, isFalse);
      expect(authNotifier.state.hasError, isTrue);
      expect(
        authNotifier.state.errorMessage,
        'This account is registered as a Firm account. Please switch to Firm Login to sign in.',
      );
      expect(authRepo.logoutCallCount, 1);
    });

    test('Client login where client repo rejects but firm login succeeds prompts switch to Firm Login', () async {
      // client repo throws Invalid credentials
      clientRepo.shouldThrow = true;
      clientRepo.errorMessage = 'No client found.';

      // firm repo succeeds with lawyer
      authRepo.nextUser = const UserProfile(
        id: 7,
        username: 'advocate_sharma',
        email: 'sharma@firm.com',
        role: 'lawyer',
      );

      final success = await authNotifier.login(
        'advocate_sharma',
        'lawyerPass',
        isClient: true,
      );

      expect(success, isFalse);
      expect(authNotifier.state.isAuthenticated, isFalse);
      expect(authNotifier.state.hasError, isTrue);
      expect(
        authNotifier.state.errorMessage,
        'This account is registered as a Firm account. Please switch to Firm Login to sign in.',
      );
    });

    test('Firm login with lawyer user successfully authenticates', () async {
      authRepo.nextUser = const UserProfile(
        id: 1,
        username: 'lawyer_bob',
        email: 'bob@firm.com',
        role: 'lawyer',
      );

      final success = await authNotifier.login(
        'lawyer_bob',
        'password123',
        isClient: false,
      );

      expect(success, isTrue);
      expect(authNotifier.state.isAuthenticated, isTrue);
      expect(authNotifier.state.user?.role, 'lawyer');
      expect(authNotifier.state.hasError, isFalse);
    });

    test('Client login with client user successfully authenticates', () async {
      clientRepo.nextUser = const User(
        id: 88,
        username: 'client_alice',
        email: 'alice@client.com',
        role: 'client',
      );

      final success = await authNotifier.login(
        'client_alice',
        'clientPass123',
        isClient: true,
      );

      expect(success, isTrue);
      expect(authNotifier.state.isAuthenticated, isTrue);
      expect(authNotifier.state.user?.isClient, isTrue);
      expect(authNotifier.state.hasError, isFalse);
    });
  });
}
