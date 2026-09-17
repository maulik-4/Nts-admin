import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/role_menu_config.dart';
import '../../../../core/theme/firm_theme_provider.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/app_brand_logo.dart';
import '../../../../shared/widgets/firm_watermark_background.dart';
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
          // Base solid canvas background
          Container(
            color: isDark ? LexColors.canvasDark : LexColors.canvasLight,
          ),
          // Underlay Firm Identity Watermark
          if (!userRole.isSuperAdmin)
            Positioned.fill(
              child: FirmWatermarkBackground(
                firmTheme: firmTheme,
                isDark: isDark,
                isOverlay: false,
              ),
            ),
          // Screen Route Content
          Positioned.fill(child: child),
          // Ambient watermark overlay across cards
          if (!userRole.isSuperAdmin)
            Positioned.fill(
              child: FirmWatermarkBackground(
                firmTheme: firmTheme,
                isDark: isDark,
                isOverlay: true,
              ),
            ),
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

    // Mobile layout (< 600dp)
    return Scaffold(
      body: buildScreenWithWatermark(navigationShell),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? LexColors.borderDark : LexColors.borderLight,
              width: 1.0,
            ),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selectedColor,
                );
              }
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onTap,
            backgroundColor: isDark
                ? LexColors.surfaceDark
                : LexColors.surfaceLight,
            indicatorColor: selectedColor.withValues(
              alpha: isDark ? 0.25 : 0.15,
            ),
            destinations: [
              for (final d in destinations)
                NavigationDestination(
                  icon: Icon(
                    d.icon,
                    color: isDark
                        ? LexColors.textSecondaryDark
                        : LexColors.textSecondaryLight,
                  ),
                  selectedIcon: Icon(d.selectedIcon, color: selectedColor),
                  label: d.label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
