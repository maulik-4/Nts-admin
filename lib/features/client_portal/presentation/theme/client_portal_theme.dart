import 'package:flutter/material.dart';

/// Centralized Design System tokens for the Legal Management System Client Portal.
/// Strictly follows the prescribed color palette and UI guidelines:
/// - Primary navy: #19365C
/// - Dark navy: #12233F
/// - Primary blue: #2F6FED
/// - Page background: #F5F7FB
/// - Card background: #FFFFFF
/// - Primary text: #172338
/// - Secondary text: #69778B
/// - Borders: #E4EAF2
/// - Success: #16845B
/// - Warning / Amber: #D97706
/// - Error: #D64545
class ClientPortalColors {
  ClientPortalColors._();

  static const Color primaryNavy = Color(0xFF19365C);
  static const Color darkNavy = Color(0xFF12233F);
  static const Color primaryBlue = Color(0xFF2F6FED);
  static const Color pageBackground = Color(0xFFF5F7FB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF172338);
  static const Color secondaryText = Color(0xFF69778B);
  static const Color border = Color(0xFFE4EAF2);
  static const Color success = Color(0xFF16845B);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFD64545);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Dark mode variants
  static const Color darkPageBackground = Color(0xFF0C1425);
  static const Color darkCardBackground = Color(0xFF131D33);
  static const Color darkBorder = Color(0xFF1E2D4A);
  static const Color darkPrimaryText = Color(0xFFF1F5F9);
  static const Color darkSecondaryText = Color(0xFF94A3B8);
}

class ClientPortalDimensions {
  ClientPortalDimensions._();

  static const double cardRadius = 18.0;
  static const double buttonRadius = 12.0;
  static const double inputRadius = 12.0;
  static const double badgeRadius = 6.0;

  static const double mobilePadding = 16.0;
  static const double tabletPadding = 24.0;
  static const double maxContentWidth = 1080.0;
}
