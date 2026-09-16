import '../../data/models/user_profile.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? errorMessage;
  final Map<String, dynamic>? fieldErrors;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.fieldErrors,
  });

  const AuthState.initial()
    : status = AuthStatus.initial,
      user = null,
      errorMessage = null,
      fieldErrors = null;

  const AuthState.loading({UserProfile? currentUser})
    : status = AuthStatus.loading,
      user = currentUser,
      errorMessage = null,
      fieldErrors = null;

  const AuthState.authenticated(UserProfile profile)
    : status = AuthStatus.authenticated,
      user = profile,
      errorMessage = null,
      fieldErrors = null;

  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      user = null,
      errorMessage = null,
      fieldErrors = null;

  const AuthState.error(this.errorMessage, {this.fieldErrors})
    : status = AuthStatus.error,
      user = null;

  bool get isInitial => status == AuthStatus.initial;
  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          user == other.user &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => status.hashCode ^ user.hashCode ^ errorMessage.hashCode;
}
