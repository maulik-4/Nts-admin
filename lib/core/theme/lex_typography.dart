import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lex_colors.dart';

class LexTypography {
  LexTypography._();

  static TextTheme textTheme(bool isDark, {String fontFamily = 'Inter'}) {
    final primaryColor = isDark
        ? LexColors.textPrimaryDark
        : LexColors.textPrimaryLight;
    final secondaryColor = isDark
        ? LexColors.textSecondaryDark
        : LexColors.textSecondaryLight;
    final mutedColor = isDark
        ? LexColors.textMutedDark
        : LexColors.textMutedLight;

    final base = TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: -0.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mutedColor,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: mutedColor,
      ),
    );

    try {
      switch (fontFamily.toLowerCase().trim()) {
        case 'system':
        case 'none':
        case 'sans-serif':
          return base;
        case 'dm sans':
          return GoogleFonts.dmSansTextTheme(base);
        case 'poppins':
          return GoogleFonts.poppinsTextTheme(base);
        case 'playfair display':
          return GoogleFonts.playfairDisplayTextTheme(base);
        case 'roboto':
          return GoogleFonts.robotoTextTheme(base);
        case 'inter':
        default:
          return GoogleFonts.interTextTheme(base);
      }
    } catch (_) {
      return base;
    }
  }
}
