import 'package:flutter/material.dart';

import '../../../../../core/theme/lex_colors.dart';
import 'preview_sidebar.dart';

class PreviewBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color primaryColor;
  final Color accentColor;
  final String fontFamily;
  final bool isDarkMode;

  const PreviewBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.primaryColor,
    required this.accentColor,
    required this.fontFamily,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? LexColors.surfaceDark : LexColors.surfaceLight;
    final borderColor = isDarkMode
        ? LexColors.borderDark
        : const Color(0xFFE2E8F0);
    final activeColor = isDarkMode ? accentColor : primaryColor;
    final unselectedColor = isDarkMode
        ? LexColors.textSecondaryDark
        : LexColors.textSecondaryLight;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < PreviewSidebar.items.length; i++) ...[
            _buildNavItem(
              item: PreviewSidebar.items[i],
              index: i,
              isSelected: selectedIndex == i,
              activeColor: activeColor,
              unselectedColor: unselectedColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required PreviewSidebarItem item,
    required int index,
    required bool isSelected,
    required Color activeColor,
    required Color unselectedColor,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                size: 16,
                color: isSelected ? activeColor : unselectedColor,
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? activeColor : unselectedColor,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
