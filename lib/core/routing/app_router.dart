import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/screens/accept_invite_screen.dart';
import '../../features/auth/presentation/screens/authenticated_placeholder_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';

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
      GoRoute(
        path: '/app',
        builder: (context, state) => const AuthenticatedPlaceholderScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isInitial = authState.isInitial;
      final isAuthenticated = authState.isAuthenticated;
      final currentPath = state.matchedLocation;

      // During session initialization, ensure we stay on splash
      if (isInitial) {
        return '/splash';
      }

      final isAuthRoute =
          currentPath == '/login' ||
          currentPath == '/register' ||
          currentPath == '/accept-invite';

      // If authenticated user is on splash or any auth route, send to /app
      if (isAuthenticated) {
        if (currentPath == '/splash' || isAuthRoute) {
          return '/app';
        }
        return null;
      }

      // If unauthenticated user is on /app or /splash, send to /login
      if (!isAuthenticated) {
        if (currentPath == '/app' || currentPath == '/splash') {
          return '/login';
        }
      }

      return null;
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
      if (previous?.status != next.status) {
        notifyListeners();
      }
    });
  }
}
