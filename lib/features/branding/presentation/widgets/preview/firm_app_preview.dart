import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/firm_theme.dart';
import '../../../../../core/theme/lex_colors.dart';
import '../../../../../core/theme/lex_theme.dart';
import '../../../data/models/firm_profile.dart';
import 'preview_bottom_nav.dart';
import 'preview_device_frame.dart';
import 'preview_navbar.dart';
import 'preview_sidebar.dart';
import 'preview_views.dart';

class FirmAppPreview extends StatefulWidget {
  final FirmProfile profile;
  final Color draftPrimaryColor;
  final Color draftAccentColor;
  final String draftFontFamily;
  final bool draftSidebarDark;
  final PlatformFile? pickedLogoFile;
  final String? existingLogoUrl;
  final bool hasUnsavedChanges;

  const FirmAppPreview({
    super.key,
    required this.profile,
    required this.draftPrimaryColor,
    required this.draftAccentColor,
    required this.draftFontFamily,
    required this.draftSidebarDark,
    this.pickedLogoFile,
    this.existingLogoUrl,
    required this.hasUnsavedChanges,
  });

  @override
  State<FirmAppPreview> createState() => _FirmAppPreviewState();
}

class _FirmAppPreviewState extends State<FirmAppPreview> {
  bool _isMobile = false;
  bool _isDarkMode = false;
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Generate scoped dynamic theme using real draft configuration
    final previewFirmTheme = FirmTheme(
      primaryColor: widget.draftPrimaryColor,
      accentColor: widget.draftAccentColor,
      fontFamily: widget.draftFontFamily,
      sidebarDark: widget.draftSidebarDark,
      logoUrl: widget.existingLogoUrl,
      firmName: widget.profile.name,
    );

    final dynamicTheme = LexTheme.buildDynamicTheme(
      firmTheme: previewFirmTheme,
      isDark: _isDarkMode,
    );

    final canvasBg = _isDarkMode ? LexColors.canvasDark : LexColors.canvasLight;

    return PreviewDeviceFrame(
      isMobile: _isMobile,
      isDarkMode: _isDarkMode,
      hasUnsavedChanges: widget.hasUnsavedChanges,
      onViewportChanged: (mobile) => setState(() => _isMobile = mobile),
      onThemeChanged: (dark) => setState(() => _isDarkMode = dark),
      child: Theme(
        data: dynamicTheme,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          color: canvasBg,
          height: _isMobile ? 490 : 440,
          child: _isMobile
              ? _buildMobileLayout(canvasBg)
              : _buildDesktopLayout(canvasBg),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(Color canvasBg) {
    return Column(
      children: [
        // Top App Bar
        PreviewNavbar(
          firmName: widget.profile.name,
          pickedLogoFile: widget.pickedLogoFile,
          existingLogoUrl: widget.existingLogoUrl,
          primaryColor: widget.draftPrimaryColor,
          accentColor: widget.draftAccentColor,
          fontFamily: widget.draftFontFamily,
          isDarkMode: _isDarkMode,
          isMobile: false,
        ),

        // Body: Sidebar + Active View
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PreviewSidebar(
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  setState(() => _selectedTabIndex = index);
                },
                primaryColor: widget.draftPrimaryColor,
                accentColor: widget.draftAccentColor,
                fontFamily: widget.draftFontFamily,
                sidebarDark: widget.draftSidebarDark,
                isDarkMode: _isDarkMode,
              ),
              Expanded(
                child: Container(
                  color: canvasBg,
                  child: _buildCurrentView(false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Color canvasBg) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: canvasBg,
          border: Border.symmetric(
            vertical: BorderSide(
              color: _isDarkMode
                  ? LexColors.borderDark
                  : const Color(0xFFCBD5E1),
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          children: [
            // Top App Bar
            PreviewNavbar(
              firmName: widget.profile.name,
              pickedLogoFile: widget.pickedLogoFile,
              existingLogoUrl: widget.existingLogoUrl,
              primaryColor: widget.draftPrimaryColor,
              accentColor: widget.draftAccentColor,
              fontFamily: widget.draftFontFamily,
              isDarkMode: _isDarkMode,
              isMobile: true,
            ),

            // Mobile Main View Area
            Expanded(
              child: Container(color: canvasBg, child: _buildCurrentView(true)),
            ),

            // Bottom Navigation Bar
            PreviewBottomNav(
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() => _selectedTabIndex = index);
              },
              primaryColor: widget.draftPrimaryColor,
              accentColor: widget.draftAccentColor,
              fontFamily: widget.draftFontFamily,
              isDarkMode: _isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView(bool isMobile) {
    switch (_selectedTabIndex) {
      case 0:
        return PreviewDashboardView(
          primaryColor: widget.draftPrimaryColor,
          accentColor: widget.draftAccentColor,
          fontFamily: widget.draftFontFamily,
          isDarkMode: _isDarkMode,
          isMobile: isMobile,
        );
      case 1:
        return PreviewCasesView(
          primaryColor: widget.draftPrimaryColor,
          accentColor: widget.draftAccentColor,
          fontFamily: widget.draftFontFamily,
          isDarkMode: _isDarkMode,
        );
      case 2:
        return PreviewClientsView(
          primaryColor: widget.draftPrimaryColor,
          accentColor: widget.draftAccentColor,
          fontFamily: widget.draftFontFamily,
          isDarkMode: _isDarkMode,
        );
      case 3:
        return PreviewHearingsView(
          primaryColor: widget.draftPrimaryColor,
          accentColor: widget.draftAccentColor,
          fontFamily: widget.draftFontFamily,
          isDarkMode: _isDarkMode,
        );
      case 4:
        return PreviewMoreView(
          primaryColor: widget.draftPrimaryColor,
          accentColor: widget.draftAccentColor,
          fontFamily: widget.draftFontFamily,
          isDarkMode: _isDarkMode,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
