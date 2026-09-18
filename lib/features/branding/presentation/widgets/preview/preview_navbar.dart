import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/lex_colors.dart';
import 'preview_logo.dart';

class PreviewNavbar extends StatelessWidget {
  final String firmName;
  final PlatformFile? pickedLogoFile;
  final String? existingLogoUrl;
  final Color primaryColor;
  final Color accentColor;
  final String fontFamily;
  final bool isDarkMode;
  final bool isMobile;

  const PreviewNavbar({
    super.key,
    required this.firmName,
    this.pickedLogoFile,
    this.existingLogoUrl,
    required this.primaryColor,
    required this.accentColor,
    required this.fontFamily,
    required this.isDarkMode,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFirmName = firmName.trim().isNotEmpty
        ? firmName.trim()
        : 'Vidhanta Law Firm';

    final bgColor = isDarkMode ? LexColors.surfaceDark : LexColors.surfaceLight;
    final textColor = isDarkMode
        ? LexColors.textPrimaryDark
        : LexColors.slatePrimary;
    final subtextColor = isDarkMode
        ? LexColors.textSecondaryDark
        : LexColors.textSecondaryLight;
    final borderColor = isDarkMode
        ? LexColors.borderDark
        : const Color(0xFFE2E8F0);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1.0)),
      ),
      child: Row(
        children: [
          // Logo
          PreviewLogo(
            pickedFile: pickedLogoFile,
            existingUrl: existingLogoUrl,
            size: 30,
            borderRadius: 7,
            primaryColor: primaryColor,
            accentColor: accentColor,
            fallbackInitial: effectiveFirmName,
          ),
          const SizedBox(width: 10),

          // Firm Title & Tag
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effectiveFirmName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    fontFamily: fontFamily,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  isMobile ? 'Firm Portal' : 'Litigation Management System',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: subtextColor,
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
          ),

          // Notification indicator
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 20,
                color: isDarkMode
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight,
              ),
              Positioned(
                right: 0,
                top: -1,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // User Profile Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color:
                            ThemeData.estimateBrightnessForColor(
                                  primaryColor,
                                ) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 6),
                  Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
