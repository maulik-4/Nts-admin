import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/auth/data/models/user_profile.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_state.dart';

void main() {
  group('AuthState Tests', () {
    test('initial state has correct default values', () {
      const state = AuthState.initial();
      expect(state.status, AuthStatus.initial);
      expect(state.isInitial, isTrue);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isFalse);
      expect(state.user, isNull);
    });

    test('authenticated state has valid user and flags', () {
      const profile = UserProfile(
        id: 1,
        username: 'advocate.sharma',
        email: 'sharma@law.in',
        role: 'lawyer',
      );
      const state = AuthState.authenticated(profile);
      expect(state.status, AuthStatus.authenticated);
      expect(state.isAuthenticated, isTrue);
      expect(state.user?.username, 'advocate.sharma');
      expect(state.user?.role, 'lawyer');
      expect(state.isInitial, isFalse);
    });

    test('error state contains error message and hasError is true', () {
      const state = AuthState.error('Invalid credentials');
      expect(state.status, AuthStatus.error);
      expect(state.hasError, isTrue);
      expect(state.errorMessage, 'Invalid credentials');
      expect(state.isAuthenticated, isFalse);
    });

    test('unauthenticated state reflects logged out user', () {
      const state = AuthState.unauthenticated();
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isUnauthenticated, isTrue);
      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
    });
  });
}
