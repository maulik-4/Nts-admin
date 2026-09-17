import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/role_menu_config.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../auth/domain/models/role_capabilities.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider);
    final destinations = RoleMenuConfig.getMenuForRole(userRole);

    final currentBranch = navigationShell.currentIndex;
    final destIndex = destinations.indexWhere(
      (d) => d.branchIndex == currentBranch,
    );
    final selectedIndex = destIndex >= 0 ? destIndex : 0;

    void onTap(int index) {
      final targetBranch = destinations[index].branchIndex;
      navigationShell.goBranch(
        targetBranch,
        initialLocation: targetBranch == navigationShell.currentIndex,
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isTablet) {
      final isExpanded = width >= 950;

      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onTap,
              extended: isExpanded,
              minExtendedWidth: 200,
              backgroundColor: isDark
                  ? LexColors.surfaceDark
                  : LexColors.canvasLight,
              selectedIconTheme: IconThemeData(
                color: isDark ? LexColors.accentGold : LexColors.slatePrimary,
              ),
              selectedLabelTextStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? LexColors.accentGold : LexColors.slatePrimary,
              ),
              unselectedIconTheme: IconThemeData(
                color: isDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight,
              ),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: LexColors.slatePrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        userRole.isSuperAdmin
                            ? Icons.admin_panel_settings
                            : Icons.balance,
                        size: 20,
                        color: isDark ? LexColors.accentGold : Colors.white,
                      ),
                    ),
                    if (isExpanded) ...[
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NTS Legal Pro',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            userRole.displayTitle,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: userRole.badgeColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    // Mobile layout (< 600dp)
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onTap,
        backgroundColor: isDark
            ? LexColors.surfaceDark
            : LexColors.surfaceLight,
        indicatorColor: isDark
            ? LexColors.accentGold.withAlpha(60)
            : const Color(0xFFE2E8F0),
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
