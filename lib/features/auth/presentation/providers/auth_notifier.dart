import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/firm_theme_provider.dart';
import '../../../cases/presentation/providers/cases_notifier.dart';
import '../../../client_portal/data/repositories/client_portal_repository.dart';
import '../../../client_portal/presentation/providers/client_portal_notifier.dart';
import '../../../clients/presentation/providers/clients_notifier.dart';
import '../../../dashboard/presentation/providers/dashboard_notifier.dart';
import '../../../documents/presentation/providers/documents_notifier.dart';
import '../../../firms/presentation/providers/firms_notifier.dart';
import '../../../hearings/presentation/providers/hearings_notifier.dart';
import '../../../notifications/presentation/providers/notifications_notifier.dart';
import '../../../payments/presentation/providers/payments_notifier.dart';
import '../../../subscriptions/presentation/providers/subscriptions_notifier.dart';
import '../../../support/presentation/providers/support_notifier.dart';
import '../../../tasks/presentation/providers/tasks_notifier.dart';
import '../../../team/presentation/providers/team_notifier.dart';
import '../../data/models/accept_invite_request.dart';
import '../../data/models/register_request.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  final clientRepo = ref.watch(clientPortalRepositoryProvider);
  final notifier = AuthNotifier(repository, clientRepo, ref);

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
  final ClientPortalRepository? _clientRepo;
  final Ref? _ref;

  AuthNotifier(this._repository, [this._clientRepo, this._ref])
    : super(const AuthState.initial());

  void hardRefreshAllScreens() {
    final ref = _ref;
    if (ref == null) return;
    try {
      ref.invalidate(dashboardNotifierProvider);
      ref.invalidate(casesNotifierProvider);
      ref.invalidate(clientsNotifierProvider);
      ref.invalidate(hearingsNotifierProvider);
      ref.invalidate(tasksNotifierProvider);
      ref.invalidate(paymentsNotifierProvider);
      ref.invalidate(documentsNotifierProvider);
      ref.invalidate(firmsNotifierProvider);
      ref.invalidate(teamNotifierProvider);
      ref.invalidate(supportNotifierProvider);
      ref.invalidate(notificationsNotifierProvider);
      ref.invalidate(platformPlansNotifierProvider);
      ref.invalidate(firmThemeProvider);
      ref.invalidate(clientDashboardProvider);
      ref.invalidate(clientDocumentsProvider);
    } catch (_) {
      // Ignored if any provider is not yet attached
    }
  }

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

  Future<bool> login(
    String username,
    String password, {
    bool isClient = false,
  }) async {
    if (isClient) {
      return loginClient(username, password);
    } else {
      return loginFirm(username, password);
    }
  }

  Future<bool> loginFirm(String username, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.login(
        username: username.trim(),
        password: password,
      );

      // If user is a client, reject firm workspace login and prompt cleanly
      if (user.isClient) {
        await _repository.logout();
        if (!mounted) return false;
        state = const AuthState.error(
          'This account is registered as a Client. Please switch to Client Login to sign in.',
        );
        return false;
      }

      if (!mounted) return false;
      hardRefreshAllScreens();
      state = AuthState.authenticated(user);
      return true;
    } on ApiException catch (e) {
      // Check if credentials actually belong to a Client account
      final clientRepo = _clientRepo;
      if (clientRepo != null) {
        try {
          await clientRepo.clientLogin(
            usernameOrEmail: username.trim(),
            password: password,
          );
          // If clientLogin succeeded, credentials definitely belong to a client
          await _repository.logout();
          if (!mounted) return false;
          state = const AuthState.error(
            'This account is registered as a Client. Please switch to Client Login to sign in.',
          );
          return false;
        } catch (_) {
          // Not a client account, fall through to original error
        }
      }

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

  Future<bool> loginClient(String username, String password) async {
    state = const AuthState.loading();
    try {
      final clientRepo = _clientRepo;
      if (clientRepo == null) {
        state = const AuthState.error(
          'Client authentication service is unavailable.',
        );
        return false;
      }

      final user = await clientRepo.clientLogin(
        usernameOrEmail: username.trim(),
        password: password,
      );

      final profile = UserProfile.fromUser(user);

      // If user is NOT a client (e.g. firm/lawyer trying to sign into client portal)
      if (!profile.isClient) {
        await _repository.logout();
        if (!mounted) return false;
        state = const AuthState.error(
          'This account is registered as a Firm account. Please switch to Firm Login to sign in.',
        );
        return false;
      }

      if (!mounted) return false;
      hardRefreshAllScreens();
      state = AuthState.authenticated(profile);
      return true;
    } on ApiException catch (e) {
      // Check if credentials actually belong to a Firm workspace user
      try {
        final firmUser = await _repository.login(
          username: username.trim(),
          password: password,
        );
        await _repository.logout();
        if (!firmUser.isClient) {
          if (!mounted) return false;
          state = const AuthState.error(
            'This account is registered as a Firm account. Please switch to Firm Login to sign in.',
          );
          return false;
        }
      } catch (_) {
        // Not a firm user either, fall through to original error
      }

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
    hardRefreshAllScreens();
    state = const AuthState.unauthenticated();
  }

  void handleUnauthorized() {
    if (!mounted) return;
    hardRefreshAllScreens();
    state = const AuthState.unauthenticated();
  }

  void clearError() {
    if (!mounted) return;
    if (state.hasError) {
      state = const AuthState.unauthenticated();
    }
  }

  void setAuthenticated(UserProfile profile) {
    if (!mounted) return;
    state = AuthState.authenticated(profile);
  }
}
