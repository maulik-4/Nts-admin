import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/accept_invite_request.dart';
import '../../data/models/register_request.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  final notifier = AuthNotifier(repository);

  // Safely attach the unauthorized callback to the ErrorInterceptor without rebuilding Dio
  final errorInterceptor = ref.read(errorInterceptorProvider);
  errorInterceptor.onUnauthorized = notifier.handleUnauthorized;
  ref.onDispose(() {
    errorInterceptor.onUnauthorized = null;
  });

  return notifier;
});

/// Canonical auth provider alias matching the centralized auth architecture.
final authProvider = authNotifierProvider;


class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState.initial());

  Future<void> checkSession() async {
    if (state.isLoading) return;
    state = const AuthState.loading();
    try {
      final user = await _repository.restoreSession();
      if (!mounted) return;
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      if (!mounted) return;
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> login(String username, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.login(
        username: username.trim(),
        password: password,
      );
      if (!mounted) return false;
      state = AuthState.authenticated(user);
      return true;
    } on ApiException catch (e) {
      if (!mounted) return false;
      state = AuthState.error(e.message, fieldErrors: e.fieldErrors);
      return false;
    } catch (e) {
      if (!mounted) return false;
      state = const AuthState.error(
        'An unexpected error occurred. Please try again.',
      );
      return false;
    }
  }

  Future<bool> register(RegisterRequest request) async {
    state = const AuthState.loading();
    try {
      await _repository.register(request);
      if (!mounted) return false;
      state = const AuthState.unauthenticated();
      return true;
    } on ApiException catch (e) {
      if (!mounted) return false;
      state = AuthState.error(e.message, fieldErrors: e.fieldErrors);
      return false;
    } catch (e) {
      if (!mounted) return false;
      state = const AuthState.error(
        'Registration failed. Please check your inputs and try again.',
      );
      return false;
    }
  }

  Future<bool> acceptInvite(AcceptInviteRequest request) async {
    state = const AuthState.loading();
    try {
      await _repository.acceptInvite(request);
      if (!mounted) return false;
      state = const AuthState.unauthenticated();
      return true;
    } on ApiException catch (e) {
      if (!mounted) return false;
      state = AuthState.error(e.message, fieldErrors: e.fieldErrors);
      return false;
    } catch (e) {
      if (!mounted) return false;
      state = const AuthState.error(
        'Unable to accept invite. Please try again.',
      );
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      await _repository.forgotPassword(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    await _repository.logout();
    if (!mounted) return;
    state = const AuthState.unauthenticated();
  }

  void handleUnauthorized() {
    if (!mounted) return;
    state = const AuthState.unauthenticated();
  }

  void clearError() {
    if (!mounted) return;
    if (state.hasError) {
      state = const AuthState.unauthenticated();
    }
  }
}
