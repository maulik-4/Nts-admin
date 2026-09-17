import 'package:flutter/material.dart';

import '../../features/auth/domain/models/user_role.dart';

/// Navigation menu item representing a role-authorized destination.
class RoleMenuItem {
  final String title;
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final int branchIndex;
  final String? badge;

  const RoleMenuItem({
    required this.title,
    required this.route,
    required this.icon,
    IconData? selectedIcon,
    required this.branchIndex,
    this.badge,
  }) : selectedIcon = selectedIcon ?? icon;

  String get label => title;
}

/// Centralized role navigation menu configuration.
/// Ensures each role receives only authorized destinations without cross-role leakage.
class RoleMenuConfig {
  RoleMenuConfig._();

  static const List<RoleMenuItem> superAdminMenu = [
    RoleMenuItem(
      title: 'Dashboard',
      route: '/app/dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      branchIndex: 0,
    ),
    RoleMenuItem(
      title: 'Firms',
      route: '/app/firms',
      icon: Icons.business_outlined,
      selectedIcon: Icons.business,
      branchIndex: 5,
    ),
    RoleMenuItem(
      title: 'Plans',
      route: '/app/plans',
      icon: Icons.card_membership_outlined,
      selectedIcon: Icons.card_membership,
      branchIndex: 7,
    ),
    RoleMenuItem(
      title: 'Team',
      route: '/app/platform-team',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      branchIndex: 8,
    ),
    RoleMenuItem(
      title: 'More',
      route: '/app/more',
      icon: Icons.more_horiz_outlined,
      selectedIcon: Icons.more_horiz,
      branchIndex: 6,
    ),
  ];

  static const List<RoleMenuItem> adminMenu = [
    RoleMenuItem(
      title: 'Dashboard',
      route: '/app/dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      branchIndex: 0,
    ),
    RoleMenuItem(
      title: 'Cases',
      route: '/app/cases',
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
      branchIndex: 1,
    ),
    RoleMenuItem(
      title: 'Tasks',
      route: '/app/tasks',
      icon: Icons.task_alt_outlined,
      selectedIcon: Icons.task_alt,
      branchIndex: 4,
    ),
    RoleMenuItem(
      title: 'Hearings',
      route: '/app/hearings',
      icon: Icons.gavel_outlined,
      selectedIcon: Icons.gavel,
      branchIndex: 3,
    ),
    RoleMenuItem(
      title: 'More',
      route: '/app/more',
      icon: Icons.more_horiz_outlined,
      selectedIcon: Icons.more_horiz,
      branchIndex: 6,
    ),
  ];

  static const List<RoleMenuItem> lawyerMenu = [
    RoleMenuItem(
      title: 'Dashboard',
      route: '/app/dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      branchIndex: 0,
    ),
    RoleMenuItem(
      title: 'Cases',
      route: '/app/cases',
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
      branchIndex: 1,
    ),
    RoleMenuItem(
      title: 'Tasks',
      route: '/app/tasks',
      icon: Icons.task_alt_outlined,
      selectedIcon: Icons.task_alt,
      branchIndex: 4,
    ),
    RoleMenuItem(
      title: 'Hearings',
      route: '/app/hearings',
      icon: Icons.gavel_outlined,
      selectedIcon: Icons.gavel,
      branchIndex: 3,
    ),
    RoleMenuItem(
      title: 'More',
      route: '/app/more',
      icon: Icons.more_horiz_outlined,
      selectedIcon: Icons.more_horiz,
      branchIndex: 6,
    ),
  ];

  static const List<RoleMenuItem> staffMenu = [
    RoleMenuItem(
      title: 'Dashboard',
      route: '/app/dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      branchIndex: 0,
    ),
    RoleMenuItem(
      title: 'Tasks',
      route: '/app/tasks',
      icon: Icons.task_alt_outlined,
      selectedIcon: Icons.task_alt,
      branchIndex: 4,
    ),
    RoleMenuItem(
      title: 'Clients',
      route: '/app/clients',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      branchIndex: 2,
    ),
    RoleMenuItem(
      title: 'Hearings',
      route: '/app/hearings',
      icon: Icons.gavel_outlined,
      selectedIcon: Icons.gavel,
      branchIndex: 3,
    ),
    RoleMenuItem(
      title: 'More',
      route: '/app/more',
      icon: Icons.more_horiz_outlined,
      selectedIcon: Icons.more_horiz,
      branchIndex: 6,
    ),
  ];

  static const List<RoleMenuItem> unknownMenu = [
    RoleMenuItem(
      title: 'Dashboard',
      route: '/app/dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      branchIndex: 0,
    ),
    RoleMenuItem(
      title: 'Menu',
      route: '/app/more',
      icon: Icons.more_horiz_outlined,
      selectedIcon: Icons.more_horiz,
      branchIndex: 6,
    ),
  ];

  static List<RoleMenuItem> getMenuForRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return superAdminMenu;
      case UserRole.admin:
        return adminMenu;
      case UserRole.lawyer:
        return lawyerMenu;
      case UserRole.staff:
        return staffMenu;
      case UserRole.unknown:
        return unknownMenu;
    }
  }
}
