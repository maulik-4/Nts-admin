import 'package:flutter/material.dart';

import '../../../../../core/theme/lex_colors.dart';

class PreviewDeviceFrame extends StatelessWidget {
  final Widget child;
  final bool isMobile;
  final bool isDarkMode;
  final bool hasUnsavedChanges;
  final ValueChanged<bool> onViewportChanged;
  final ValueChanged<bool> onThemeChanged;

  const PreviewDeviceFrame({
    super.key,
    required this.child,
    required this.isMobile,
    required this.isDarkMode,
    required this.hasUnsavedChanges,
    required this.onViewportChanged,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final frameBorderColor = isDarkMode
        ? LexColors.borderDark
        : const Color(0xFFCBD5E1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Frame Controls & Badges
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'LIVE APP PREVIEW',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: hasUnsavedChanges
                        ? Colors.amber.withValues(alpha: 0.18)
                        : Colors.green.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: hasUnsavedChanges
                          ? Colors.orange.withValues(alpha: 0.5)
                          : Colors.green.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    hasUnsavedChanges ? 'UNSAVED DRAFT' : 'CURRENT SAVED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: hasUnsavedChanges
                          ? Colors.orange[800]
                          : Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),

            // Mode controls (Desktop / Mobile + Light / Dark)
            Row(
              children: [
                // Viewport Switcher
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? LexColors.surfaceDark
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: frameBorderColor),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton(
                        icon: Icons.computer_rounded,
                        tooltip: 'Desktop View',
                        isSelected: !isMobile,
                        onTap: () => onViewportChanged(false),
                      ),
                      _buildToggleButton(
                        icon: Icons.smartphone_rounded,
                        tooltip: 'Mobile View',
                        isSelected: isMobile,
                        onTap: () => onViewportChanged(true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Theme Mode Switcher
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? LexColors.surfaceDark
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: frameBorderColor),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton(
                        icon: Icons.light_mode_rounded,
                        tooltip: 'Light Preview',
                        isSelected: !isDarkMode,
                        onTap: () => onThemeChanged(false),
                      ),
                      _buildToggleButton(
                        icon: Icons.dark_mode_rounded,
                        tooltip: 'Dark Preview',
                        isSelected: isDarkMode,
                        onTap: () => onThemeChanged(true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Device Outer Window Frame
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: frameBorderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Browser / Window Titlebar
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkMode
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // macOS window dots
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // URL address pill
                    Expanded(
                      child: Container(
                        height: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF0F172A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDarkMode
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 11,
                              color: isDarkMode
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                isMobile
                                    ? 'mobile.vidhanta.app/app/dashboard'
                                    : 'firm.vidhanta.app/app/dashboard',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDarkMode
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Simulated Viewport Content
              child,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode ? LexColors.accentGold : LexColors.slatePrimary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected
                ? (isDarkMode ? Colors.black : Colors.white)
                : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}
