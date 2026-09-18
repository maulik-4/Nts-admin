import 'package:flutter/material.dart';

class PreviewSidebarItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const PreviewSidebarItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class PreviewSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color primaryColor;
  final Color accentColor;
  final String fontFamily;
  final bool sidebarDark;
  final bool isDarkMode;

  const PreviewSidebar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.primaryColor,
    required this.accentColor,
    required this.fontFamily,
    required this.sidebarDark,
    required this.isDarkMode,
  });

  static const List<PreviewSidebarItem> items = [
    PreviewSidebarItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    PreviewSidebarItem(
      label: 'Cases',
      icon: Icons.gavel_outlined,
      selectedIcon: Icons.gavel_rounded,
    ),
    PreviewSidebarItem(
      label: 'Clients',
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_alt_rounded,
    ),
    PreviewSidebarItem(
      label: 'Hearings',
      icon: Icons.event_note_outlined,
      selectedIcon: Icons.event_note_rounded,
    ),
    PreviewSidebarItem(
      label: 'More',
      icon: Icons.more_horiz_rounded,
      selectedIcon: Icons.more_horiz_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Resolve sidebar background and foreground based on sidebarDark setting
    final isDarkSurface = sidebarDark || isDarkMode;
    final sidebarBg = isDarkSurface
        ? const Color(0xFF0A0F1D)
        : const Color(0xFFF8FAFC);
    final unselectedColor = isDarkSurface
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final activeHighlightColor = isDarkSurface ? accentColor : primaryColor;
    final borderColor = isDarkSurface
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);

    return Container(
      width: 125,
      decoration: BoxDecoration(
        color: sidebarBg,
        border: Border(right: BorderSide(color: borderColor, width: 1.0)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          for (int i = 0; i < items.length; i++) ...[
            _buildRailItem(
              item: items[i],
              index: i,
              isSelected: selectedIndex == i,
              activeColor: activeHighlightColor,
              unselectedColor: unselectedColor,
              isDarkSurface: isDarkSurface,
            ),
            const SizedBox(height: 4),
          ],
          const Spacer(),
          // Small branded watermark tag
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              decoration: BoxDecoration(
                color: activeHighlightColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 9,
                        color: activeHighlightColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'SECURE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: activeHighlightColor,
                          letterSpacing: 0.5,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRailItem({
    required PreviewSidebarItem item,
    required int index,
    required bool isSelected,
    required Color activeColor,
    required Color unselectedColor,
    required bool isDarkSurface,
  }) {
    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDarkSurface ? 0.2 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: activeColor.withValues(alpha: 0.35), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              size: 16,
              color: isSelected ? activeColor : unselectedColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : unselectedColor,
                  fontFamily: fontFamily,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
