import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/client_portal_theme.dart';

class ClientPortalShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ClientPortalShell({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedIndex = navigationShell.currentIndex;

    if (isTablet) {
      final isExpanded = width >= 900;

      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: _onTap,
              extended: isExpanded,
              minExtendedWidth: 200,
              backgroundColor: isDark
                  ? ClientPortalColors.darkPageBackground
                  : ClientPortalColors.cardBackground,
              selectedIconTheme: const IconThemeData(
                color: ClientPortalColors.primaryBlue,
              ),
              unselectedIconTheme: IconThemeData(
                color: isDark
                    ? ClientPortalColors.darkSecondaryText
                    : ClientPortalColors.secondaryText,
              ),
              selectedLabelTextStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                color: ClientPortalColors.primaryBlue,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: isDark
                    ? ClientPortalColors.darkSecondaryText
                    : ClientPortalColors.secondaryText,
              ),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: ClientPortalColors.primaryNavy,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.balance_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    if (isExpanded) ...[
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client Portal',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Legal Tech Hub',
                            style: TextStyle(
                              fontSize: 10,
                              color: ClientPortalColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: Text('Hearings'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.balance_outlined),
                  selectedIcon: Icon(Icons.balance_rounded),
                  label: Text('Cases'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder_rounded),
                  label: Text('Documents'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    // Mobile layout with modern seamless bottom navigation bar
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? ClientPortalColors.darkCardBackground : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? ClientPortalColors.darkBorder
                  : ClientPortalColors.border,
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A)
                  .withValues(alpha: isDark ? 0.35 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 66,
            elevation: 0,
            backgroundColor: isDark
                ? ClientPortalColors.darkCardBackground
                : Colors.white,
            indicatorColor: ClientPortalColors.primaryBlue.withValues(
              alpha: isDark ? 0.22 : 0.12,
            ),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: ClientPortalColors.primaryBlue,
                  );
                }
                return TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? ClientPortalColors.darkSecondaryText
                      : ClientPortalColors.secondaryText,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: _onTap,
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.dashboard_outlined,
                    color: isDark
                        ? ClientPortalColors.darkSecondaryText
                        : ClientPortalColors.secondaryText,
                  ),
                  selectedIcon: const Icon(
                    Icons.dashboard_rounded,
                    color: ClientPortalColors.primaryBlue,
                  ),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.calendar_month_outlined,
                    color: isDark
                        ? ClientPortalColors.darkSecondaryText
                        : ClientPortalColors.secondaryText,
                  ),
                  selectedIcon: const Icon(
                    Icons.calendar_month_rounded,
                    color: ClientPortalColors.primaryBlue,
                  ),
                  label: 'Hearings',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.balance_outlined,
                    color: isDark
                        ? ClientPortalColors.darkSecondaryText
                        : ClientPortalColors.secondaryText,
                  ),
                  selectedIcon: const Icon(
                    Icons.balance_rounded,
                    color: ClientPortalColors.primaryBlue,
                  ),
                  label: 'Cases',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.folder_outlined,
                    color: isDark
                        ? ClientPortalColors.darkSecondaryText
                        : ClientPortalColors.secondaryText,
                  ),
                  selectedIcon: const Icon(
                    Icons.folder_rounded,
                    color: ClientPortalColors.primaryBlue,
                  ),
                  label: 'Documents',
                ),
              ],
            ),
          ),
        ),
      );
  }
}
