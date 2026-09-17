import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/providers/auth_notifier.dart';
import 'user_role.dart';

enum UserCapability {
  // Dashboard
  viewDashboard,
  viewPlatformDashboard,

  // Platform Firms
  viewFirms,
  manageFirms,

  // Cases
  viewCases,
  createCase,
  createCases,
  editCase,
  editCases,
  deleteCase,
  deleteCases,

  // Clients
  viewClients,
  createClient,
  editClient,
  deleteClient,

  // Hearings
  viewHearings,
  createHearing,
  editHearing,
  deleteHearing,

  // Documents
  viewDocuments,
  uploadDocuments,
  deleteDocuments,

  // Tasks
  viewTasks,
  createTask,
  editTask,
  deleteTask,

  // Payments
  viewPayments,
  createPayments,
  managePayments,

  // Firm Administration & Settings
  viewTeam,
  manageTeam,
  viewSubscriptions,
  manageSubscriptions,
  viewBranding,
  manageBranding,
  viewSettings,
  manageSettings,

  // General
  viewProfile,
  viewSupport,
}

class RoleCapabilities {
  static const Map<UserRole, Set<UserCapability>> _roleMatrix = {
    UserRole.superAdmin: {
      UserCapability.viewDashboard,
      UserCapability.viewPlatformDashboard,
      UserCapability.viewFirms,
      UserCapability.manageFirms,
      UserCapability.viewProfile,
      UserCapability.viewSettings,
      UserCapability.viewSupport,
    },
    UserRole.firmAdmin: {
      UserCapability.viewDashboard,
      // Cases
      UserCapability.viewCases,
      UserCapability.createCase,
      UserCapability.createCases,
      UserCapability.editCase,
      UserCapability.editCases,
      UserCapability.deleteCase,
      UserCapability.deleteCases,
      // Clients
      UserCapability.viewClients,
      UserCapability.createClient,
      UserCapability.editClient,
      UserCapability.deleteClient,
      // Hearings
      UserCapability.viewHearings,
      UserCapability.createHearing,
      UserCapability.editHearing,
      UserCapability.deleteHearing,
      // Documents
      UserCapability.viewDocuments,
      UserCapability.uploadDocuments,
      UserCapability.deleteDocuments,
      // Tasks
      UserCapability.viewTasks,
      UserCapability.createTask,
      UserCapability.editTask,
      UserCapability.deleteTask,
      // Payments
      UserCapability.viewPayments,
      UserCapability.createPayments,
      UserCapability.managePayments,
      // Team & Firm Admin
      UserCapability.viewTeam,
      UserCapability.manageTeam,
      UserCapability.viewSubscriptions,
      UserCapability.manageSubscriptions,
      UserCapability.viewBranding,
      UserCapability.manageBranding,
      UserCapability.viewSettings,
      UserCapability.manageSettings,
      // General
      UserCapability.viewProfile,
      UserCapability.viewSupport,
    },
    UserRole.lawyer: {
      UserCapability.viewDashboard,
      // Cases
      UserCapability.viewCases,
      UserCapability.createCase,
      UserCapability.createCases,
      UserCapability.editCase,
      UserCapability.editCases,
      UserCapability.deleteCase,
      UserCapability.deleteCases,
      // Clients
      UserCapability.viewClients,
      UserCapability.createClient,
      UserCapability.editClient,
      // Hearings
      UserCapability.viewHearings,
      UserCapability.createHearing,
      UserCapability.editHearing,
      // Documents (lawyer can view & upload files)
      UserCapability.viewDocuments,
      UserCapability.uploadDocuments,
      // Tasks
      UserCapability.viewTasks,
      UserCapability.createTask,
      UserCapability.editTask,
      // General
      UserCapability.viewProfile,
      UserCapability.viewSupport,
    },
    UserRole.staff: {
      UserCapability.viewDashboard,
      // Clients (allowed on backend)
      UserCapability.viewClients,
      UserCapability.createClient,
      // Hearings (allowed on backend)
      UserCapability.viewHearings,
      // Tasks (fully permitted on backend)
      UserCapability.viewTasks,
      UserCapability.createTask,
      UserCapability.editTask,
      // General
      UserCapability.viewProfile,
      UserCapability.viewSupport,
    },
    UserRole.unknown: {UserCapability.viewProfile},
  };

  static bool hasCapability(UserRole role, UserCapability capability) {
    return _roleMatrix[role]?.contains(capability) ?? false;
  }

  static Set<UserCapability> capabilitiesFor(UserRole role) {
    return _roleMatrix[role] ?? const {};
  }
}

/// Central authoritative source of the current authenticated user's role.
///
/// Replicates React hook logic:
/// `const isSuperAdmin = user?.is_superuser || role === 'super_admin';`
final currentUserRoleProvider = Provider<UserRole>((ref) {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) {
    return UserRole.unknown;
  }
  if (user.isSuperuser == true ||
      user.role?.toLowerCase() == 'super_admin' ||
      user.userRole == UserRole.superAdmin) {
    return UserRole.superAdmin;
  }
  return user.userRole;
});

/// Direct boolean helper providers matching the React equivalent accessors
final isSuperAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentUserRoleProvider).isSuperAdmin;
});

final isFirmAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentUserRoleProvider).isFirmAdmin;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentUserRoleProvider).isAdmin;
});


final isLawyerProvider = Provider<bool>((ref) {
  return ref.watch(currentUserRoleProvider).isLawyer;
});

final isStaffProvider = Provider<bool>((ref) {
  return ref.watch(currentUserRoleProvider).isStaff;
});

final userCapabilitiesProvider = Provider<Set<UserCapability>>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return RoleCapabilities.capabilitiesFor(role);
});

final hasCapabilityProvider = Provider.family<bool, UserCapability>((
  ref,
  capability,
) {
  final role = ref.watch(currentUserRoleProvider);
  return RoleCapabilities.hasCapability(role, capability);
});

