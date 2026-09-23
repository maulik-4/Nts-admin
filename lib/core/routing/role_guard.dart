import '../../features/auth/domain/models/user_role.dart';

/// Centralized RoleGuard engine evaluating access permissions for any route.
class RoleGuard {
  RoleGuard._();

  /// Evaluates whether [userRole] can access [currentPath].
  /// Returns null if access is ALLOWED.
  /// Returns redirect path (e.g. '/app/dashboard' or '/app/more') if access is DENIED.
  static String? evaluate({
    required UserRole userRole,
    required String currentPath,
    required bool isAuthenticated,
    required bool isInitial,
  }) {
    // 1. Splash check during initial startup
    if (isInitial) {
      return '/splash';
    }

    // Allow splash screen to display its artwork and manage its own transition
    if (currentPath == '/splash') {
      return null;
    }

    final isAuthRoute =
        currentPath == '/login' ||
        currentPath == '/new-user' ||
        currentPath == '/register' ||
        currentPath == '/accept-invite';

    // 2. Unauthenticated check
    if (!isAuthenticated) {
      if (currentPath.startsWith('/app')) {
        return '/login';
      }
      return null;
    }

    // 3. Authenticated user landing on entry or auth routes
    if (isAuthRoute || currentPath == '/app') {
      return '/app/dashboard';
    }

    // 4. ROLE SPECIFIC GUARDS

    // 4a. SUPER ADMIN
    if (userRole.isSuperAdmin) {
      // Super Admin is isolated from confidential tenant litigation cases, clients, hearings, and tasks
      if (currentPath.startsWith('/app/cases') ||
          currentPath.startsWith('/app/clients') ||
          currentPath.startsWith('/app/hearings') ||
          currentPath.startsWith('/app/tasks') ||
          currentPath.startsWith('/app/more/documents') ||
          currentPath.startsWith('/app/more/payments') ||
          currentPath.startsWith('/app/more/branding') ||
          currentPath.startsWith('/app/more/team') ||
          currentPath.startsWith('/app/more/advocates')) {
        return '/app/dashboard';
      }
      return null;
    }

    // 4b. NON-SUPER ADMIN BLOCKED FROM PLATFORM ROUTES
    if (currentPath.startsWith('/app/firms') ||
        currentPath.startsWith('/app/plans') ||
        currentPath.startsWith('/app/platform-team') ||
        currentPath.startsWith('/super-admin')) {
      return '/app/dashboard';
    }

    // 4c. ADMIN / FIRM ADMIN
    if (userRole.isAdmin || userRole.isFirmAdmin) {
      // Firm Admin has full litigation and firm management authority
      return null;
    }

    // 4d. LAWYER
    if (userRole.isLawyer) {
      // Subroutes under /app/more redirect back to /app/more
      if (currentPath.startsWith('/app/more/team') ||
          currentPath.startsWith('/app/more/advocates') ||
          currentPath.startsWith('/app/more/branding') ||
          currentPath.startsWith('/app/more/subscriptions') ||
          currentPath.startsWith('/app/more/quota')) {
        return '/app/more';
      }
      // Direct /app/team aliases or payments redirect to /app/dashboard
      if (currentPath.startsWith('/app/more/payments') ||
          currentPath.startsWith('/app/team') ||
          currentPath.startsWith('/app/advocates') ||
          currentPath.startsWith('/app/branding') ||
          currentPath.startsWith('/app/subscriptions') ||
          currentPath.startsWith('/app/quota')) {
        return '/app/dashboard';
      }
      return null;
    }

    // 4e. STAFF
    if (userRole.isStaff) {
      // Staff is blocked from Cases and Documents (backend returns 403 Forbidden)
      if (currentPath.startsWith('/app/cases') ||
          currentPath.startsWith('/app/more/documents') ||
          currentPath.startsWith('/app/more/payments')) {
        return '/app/dashboard';
      }
      // Subroutes under /app/more redirect back to /app/more
      if (currentPath.startsWith('/app/more/team') ||
          currentPath.startsWith('/app/more/advocates') ||
          currentPath.startsWith('/app/more/branding') ||
          currentPath.startsWith('/app/more/subscriptions') ||
          currentPath.startsWith('/app/more/quota')) {
        return '/app/more';
      }
      if (currentPath.startsWith('/app/team') ||
          currentPath.startsWith('/app/advocates') ||
          currentPath.startsWith('/app/branding') ||
          currentPath.startsWith('/app/subscriptions') ||
          currentPath.startsWith('/app/quota')) {
        return '/app/dashboard';
      }
      return null;
    }

    // 4f. UNKNOWN ROLE
    // Protect all privileged platform and litigation routes
    if (currentPath.startsWith('/app/cases') ||
        currentPath.startsWith('/app/clients') ||
        currentPath.startsWith('/app/hearings') ||
        currentPath.startsWith('/app/tasks') ||
        currentPath.startsWith('/app/firms') ||
        currentPath.startsWith('/app/plans') ||
        currentPath.startsWith('/app/platform-team') ||
        currentPath.startsWith('/app/more/team') ||
        currentPath.startsWith('/app/more/advocates') ||
        currentPath.startsWith('/app/more/documents') ||
        currentPath.startsWith('/app/more/payments') ||
        currentPath.startsWith('/app/more/branding') ||
        currentPath.startsWith('/app/more/subscriptions') ||
        currentPath.startsWith('/app/more/quota')) {
      return '/app/dashboard';
    }

    return null;
  }
}
