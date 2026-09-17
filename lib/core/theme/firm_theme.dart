import 'package:flutter/material.dart';

import '../../features/branding/data/models/firm_profile.dart';

/// Preset theme configurations matching the firm branding design options.
class FirmBrandingPreset {
  final String name;
  final Color primaryColor;
  final Color accentColor;
  final bool sidebarDark;
  final String fontFamily;

  const FirmBrandingPreset({
    required this.name,
    required this.primaryColor,
    required this.accentColor,
    required this.sidebarDark,
    required this.fontFamily,
  });

  static const List<FirmBrandingPreset> presets = [
    FirmBrandingPreset(
      name: 'Navy Gold',
      primaryColor: Color(0xFF0D1B2A),
      accentColor: Color(0xFFC9A84C),
      sidebarDark: true,
      fontFamily: 'DM Sans',
    ),
    FirmBrandingPreset(
      name: 'Forest',
      primaryColor: Color(0xFF1B4332),
      accentColor: Color(0xFF52B788),
      sidebarDark: true,
      fontFamily: 'Inter',
    ),
    FirmBrandingPreset(
      name: 'Slate',
      primaryColor: Color(0xFF1E293B),
      accentColor: Color(0xFF38BDF8),
      sidebarDark: true,
      fontFamily: 'Inter',
    ),
    FirmBrandingPreset(
      name: 'Burgundy',
      primaryColor: Color(0xFF4A0E17),
      accentColor: Color(0xFFE2C275),
      sidebarDark: true,
      fontFamily: 'Playfair Display',
    ),
  ];
}

/// Centralized firm branding theme configuration.
///
/// Drives the dynamic theming of the application for firm-scoped users.
class FirmTheme {
  final Color primaryColor;
  final Color accentColor;
  final String fontFamily;
  final bool sidebarDark;
  final String? logoUrl;
  final int? firmId;
  final String? firmName;

  const FirmTheme({
    required this.primaryColor,
    required this.accentColor,
    required this.fontFamily,
    required this.sidebarDark,
    this.logoUrl,
    this.firmId,
    this.firmName,
  });

  /// Default baseline firm theme matching legal standards.
  factory FirmTheme.defaultTheme() {
    return const FirmTheme(
      primaryColor: Color(0xFF0D1B2A), // Deep Navy
      accentColor: Color(0xFFC9A84C), // Warm Gold
      fontFamily: 'DM Sans',
      sidebarDark: true,
      logoUrl: null,
      firmId: null,
      firmName: null,
    );
  }

  /// Constructs a [FirmTheme] from a backend [FirmProfile].
  factory FirmTheme.fromProfile(FirmProfile profile) {
    return FirmTheme(
      primaryColor: hexToColor(
        profile.themeColor,
        defaultColor: const Color(0xFF0D1B2A),
      ),
      accentColor: hexToColor(
        profile.accentColor,
        defaultColor: const Color(0xFFC9A84C),
      ),
      fontFamily: resolveFlutterFontFamily(profile.fontFamily),
      sidebarDark: profile.sidebarDark,
      logoUrl: profile.logo,
      firmId: profile.id > 0 ? profile.id : null,
      firmName: profile.name.isNotEmpty ? profile.name : null,
    );
  }

  FirmTheme copyWith({
    Color? primaryColor,
    Color? accentColor,
    String? fontFamily,
    bool? sidebarDark,
    String? logoUrl,
    int? firmId,
    String? firmName,
  }) {
    return FirmTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      fontFamily: fontFamily ?? this.fontFamily,
      sidebarDark: sidebarDark ?? this.sidebarDark,
      logoUrl: logoUrl ?? this.logoUrl,
      firmId: firmId ?? this.firmId,
      firmName: firmName ?? this.firmName,
    );
  }

  Map<String, dynamic> toJson() => {
    'primary_color': colorToHex(primaryColor),
    'accent_color': colorToHex(accentColor),
    'font_family': fontFamily,
    'sidebar_dark': sidebarDark,
    'logo_url': logoUrl,
    'firm_id': firmId,
    'firm_name': firmName,
  };

  factory FirmTheme.fromJson(Map<String, dynamic> json) {
    return FirmTheme(
      primaryColor: hexToColor(
        json['primary_color']?.toString(),
        defaultColor: const Color(0xFF0D1B2A),
      ),
      accentColor: hexToColor(
        json['accent_color']?.toString(),
        defaultColor: const Color(0xFFC9A84C),
      ),
      fontFamily: resolveFlutterFontFamily(json['font_family']?.toString()),
      sidebarDark: json['sidebar_dark'] as bool? ?? true,
      logoUrl: json['logo_url']?.toString(),
      firmId: json['firm_id'] as int?,
      firmName: json['firm_name']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirmTheme &&
          runtimeType == other.runtimeType &&
          primaryColor.toARGB32() == other.primaryColor.toARGB32() &&
          accentColor.toARGB32() == other.accentColor.toARGB32() &&
          fontFamily == other.fontFamily &&
          sidebarDark == other.sidebarDark &&
          logoUrl == other.logoUrl &&
          firmId == other.firmId;

  @override
  int get hashCode =>
      primaryColor.toARGB32().hashCode ^
      accentColor.toARGB32().hashCode ^
      fontFamily.hashCode ^
      sidebarDark.hashCode ^
      logoUrl.hashCode ^
      firmId.hashCode;
}

/// Parses a hex color string into a Flutter [Color].
///
/// Handles `#RGB`, `#RRGGBB`, `#AARRGGBB`, without leading `#`,
/// and gracefully returns [defaultColor] for null, empty, or malformed strings.
Color hexToColor(String? hex, {Color defaultColor = const Color(0xFF0D1B2A)}) {
  if (hex == null || hex.trim().isEmpty) return defaultColor;

  var cleaned = hex
      .trim()
      .toUpperCase()
      .replaceAll('#', '')
      .replaceAll('0X', '');

  // Handle shorthand 3-digit hex #RGB -> #RRGGBB
  if (cleaned.length == 3) {
    cleaned =
        '${cleaned[0]}${cleaned[0]}${cleaned[1]}${cleaned[1]}${cleaned[2]}${cleaned[2]}';
  }

  // Handle 6-digit hex #RRGGBB -> #AARRGGBB with full opacity
  if (cleaned.length == 6) {
    cleaned = 'FF$cleaned';
  }

  if (cleaned.length == 8) {
    final parsed = int.tryParse(cleaned, radix: 16);
    if (parsed != null) {
      return Color(parsed);
    }
  }

  return defaultColor;
}

/// Formats a Flutter [Color] into a 6-digit hex string `#RRGGBB`.
String colorToHex(Color color, {bool includeHash = true}) {
  final rgb = color.toARGB32() & 0x00FFFFFF;
  final hex = rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
  return includeHash ? '#$hex' : hex;
}

/// Resolves a backend CSS font-family string (e.g. `'DM Sans, sans-serif'`)
/// into a clean, supported Flutter font-family name.
String resolveFlutterFontFamily(String? backendFont) {
  if (backendFont == null || backendFont.trim().isEmpty) {
    return 'DM Sans';
  }

  final lower = backendFont.toLowerCase();

  if (lower.contains('dm sans')) {
    return 'DM Sans';
  } else if (lower.contains('inter')) {
    return 'Inter';
  } else if (lower.contains('poppins')) {
    return 'Poppins';
  } else if (lower.contains('playfair')) {
    return 'Playfair Display';
  } else if (lower.contains('roboto')) {
    return 'Roboto';
  }

  return 'DM Sans';
}
