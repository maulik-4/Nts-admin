import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/models/role_capabilities.dart';
import '../../features/auth/domain/models/user_role.dart';

class CapabilityGate extends ConsumerWidget {
  final UserCapability capability;
  final Widget child;
  final Widget? fallback;

  const CapabilityGate({
    super.key,
    required this.capability,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermission = ref.watch(hasCapabilityProvider(capability));
    if (hasPermission) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}

class RoleGate extends ConsumerWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const RoleGate({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(currentUserRoleProvider);
    if (allowedRoles.contains(currentRole)) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}
