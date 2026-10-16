import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/role_menu_config.dart';
import '../../../../core/theme/firm_theme_provider.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/app_brand_logo.dart';
import '../../../auth/domain/models/role_capabilities.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider);
    final firmTheme = ref.watch(firmThemeProvider);
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

    final sidebarBg = isDark ? const Color(0xFF0A0F1D) : LexColors.canvasLight;
    final sidebarTextDark = isDark;
    final selectedColor = userRole.isSuperAdmin
        ? (isDark ? LexColors.accentGold : LexColors.slatePrimary)
        : (isDark ? firmTheme.accentColor : firmTheme.primaryColor);

    Widget buildScreenWithWatermark(Widget child) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Base gradient canvas background matching legal aesthetic
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [
                        Color(0xFF090E1A),
                        Color(0xFF0F172A),
                        Color(0xFF070B14),
                      ]
                    : const [
                        Color(0xFFF1F6FB),
                        Color(0xFFF8FAFD),
                        Color(0xFFEBF2FA),
                      ],
              ),
            ),
          ),
          // Screen Route Content
          Positioned.fill(child: child),
        ],
      );
    }

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
              backgroundColor: sidebarBg,
              selectedIconTheme: IconThemeData(color: selectedColor),
              selectedLabelTextStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: selectedColor,
              ),
              unselectedIconTheme: IconThemeData(
                color: sidebarTextDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: sidebarTextDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight,
              ),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppBrandLogo(size: 38),
                    if (isExpanded) ...[
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            !userRole.isSuperAdmin && firmTheme.firmName != null
                                ? firmTheme.firmName!
                                : 'Vidhanta',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: isDark
                                  ? LexColors.textPrimaryDark
                                  : LexColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
            Expanded(child: buildScreenWithWatermark(navigationShell)),
          ],
        ),
      );
    }

    // Mobile layout (< 600dp) with elevated rounded dock bar matching UI mocks
    return Scaffold(
      body: buildScreenWithWatermark(navigationShell),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.4 : 0.06),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: isDark
                  ? const Color(0xFF334155).withValues(alpha: 0.6)
                  : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
              width: 1.0,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 68,
              elevation: 0,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              indicatorColor: selectedColor.withValues(
                alpha: isDark ? 0.25 : 0.14,
              ),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: selectedColor,
                  );
                }
                return TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onTap,
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(
                      d.icon,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                    selectedIcon: Icon(d.selectedIcon, color: selectedColor),
                    label: d.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
