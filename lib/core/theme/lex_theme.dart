import 'package:flutter/material.dart';

import 'firm_theme.dart';
import 'lex_colors.dart';
import 'lex_typography.dart';

class LexTheme {
  LexTheme._();

  /// Builds a dynamic [ThemeData] driven by the firm's branding settings.
  static ThemeData buildDynamicTheme({
    required FirmTheme firmTheme,
    required bool isDark,
  }) {
    final textTheme = LexTypography.textTheme(
      isDark,
      fontFamily: firmTheme.fontFamily,
    );

    if (isDark) {
      final sidebarBg = firmTheme.sidebarDark
          ? const Color(0xFF0A0F1D)
          : LexColors.surfaceDark;

      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.dark(
          primary: firmTheme.accentColor,
          onPrimary: Colors.black,
          secondary: firmTheme.accentColor,
          onSecondary: Colors.black,
          primaryContainer: firmTheme.accentColor.withValues(alpha: 0.2),
          onPrimaryContainer: firmTheme.accentColor,
          secondaryContainer: firmTheme.accentColor.withValues(alpha: 0.15),
          onSecondaryContainer: firmTheme.accentColor,
          surface: LexColors.surfaceDark,
          onSurface: LexColors.textPrimaryDark,
          error: LexColors.error,
          onError: Colors.white,
        ),
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: LexColors.textPrimaryDark,
          iconTheme: IconThemeData(color: firmTheme.accentColor),
          actionsIconTheme: IconThemeData(color: firmTheme.accentColor),
          titleTextStyle: textTheme.titleLarge?.copyWith(
            color: LexColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: LexColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: LexColors.borderDark, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 3,
          backgroundColor: firmTheme.accentColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        chipTheme: ChipThemeData(
          selectedColor: firmTheme.accentColor.withValues(alpha: 0.25),
          checkmarkColor: firmTheme.accentColor,
          labelStyle: const TextStyle(
            fontSize: 12,
            color: LexColors.textPrimaryDark,
          ),
          secondaryLabelStyle: TextStyle(
            fontSize: 12,
            color: firmTheme.accentColor,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(
            color: firmTheme.accentColor.withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: firmTheme.accentColor,
          unselectedLabelColor: LexColors.textSecondaryDark,
          indicatorColor: firmTheme.accentColor,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: firmTheme.accentColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: LexColors.surfaceDark,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintStyle: TextStyle(color: LexColors.textMutedDark, fontSize: 14),
          labelStyle: TextStyle(
            color: LexColors.textSecondaryDark,
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: LexColors.borderDark, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: LexColors.borderDark, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: firmTheme.accentColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: LexColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: LexColors.error, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: firmTheme.accentColor,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: sidebarBg,
          selectedIconTheme: IconThemeData(color: firmTheme.accentColor),
          unselectedIconTheme: const IconThemeData(
            color: LexColors.textSecondaryDark,
          ),
          selectedLabelTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            color: firmTheme.accentColor,
          ),
          unselectedLabelTextStyle: const TextStyle(
            color: LexColors.textSecondaryDark,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: sidebarBg,
          indicatorColor: firmTheme.accentColor.withValues(alpha: 0.25),
        ),
        dividerTheme: const DividerThemeData(
          color: LexColors.borderDark,
          thickness: 1,
          space: 1,
        ),
      );
    }

    // Light Theme
    final sidebarBg = firmTheme.sidebarDark
        ? const Color(0xFF0F172A)
        : LexColors.canvasLight;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.light(
        primary: firmTheme.primaryColor,
        onPrimary: Colors.white,
        secondary: firmTheme.accentColor,
        onSecondary: Colors.white,
        primaryContainer: firmTheme.primaryColor.withValues(alpha: 0.12),
        onPrimaryContainer: firmTheme.primaryColor,
        secondaryContainer: firmTheme.accentColor.withValues(alpha: 0.15),
        onSecondaryContainer: firmTheme.accentColor,
        surface: LexColors.surfaceLight,
        onSurface: LexColors.textPrimaryLight,
        error: LexColors.error,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: firmTheme.primaryColor,
        iconTheme: IconThemeData(color: firmTheme.primaryColor),
        actionsIconTheme: IconThemeData(color: firmTheme.primaryColor),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: firmTheme.primaryColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: LexColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: LexColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        backgroundColor: firmTheme.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: firmTheme.primaryColor.withValues(alpha: 0.15),
        checkmarkColor: firmTheme.primaryColor,
        labelStyle: const TextStyle(
          fontSize: 12,
          color: LexColors.textPrimaryLight,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: 12,
          color: firmTheme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(
          color: firmTheme.primaryColor.withValues(alpha: 0.2),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: firmTheme.primaryColor,
        unselectedLabelColor: LexColors.textSecondaryLight,
        indicatorColor: firmTheme.primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: firmTheme.primaryColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: LexColors.textMutedLight, fontSize: 14),
        labelStyle: TextStyle(
          color: LexColors.textSecondaryLight,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: LexColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: LexColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: firmTheme.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: LexColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: LexColors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: firmTheme.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: sidebarBg,
        selectedIconTheme: IconThemeData(
          color: firmTheme.sidebarDark
              ? firmTheme.accentColor
              : firmTheme.primaryColor,
        ),
        unselectedIconTheme: IconThemeData(
          color: firmTheme.sidebarDark
              ? Colors.white60
              : LexColors.textSecondaryLight,
        ),
        selectedLabelTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: firmTheme.sidebarDark
              ? firmTheme.accentColor
              : firmTheme.primaryColor,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: firmTheme.sidebarDark
              ? Colors.white60
              : LexColors.textSecondaryLight,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: sidebarBg,
        indicatorColor: firmTheme.sidebarDark
            ? firmTheme.accentColor.withValues(alpha: 0.3)
            : const Color(0xFFE2E8F0),
      ),
      dividerTheme: const DividerThemeData(
        color: LexColors.borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get lightTheme =>
      buildDynamicTheme(firmTheme: FirmTheme.defaultTheme(), isDark: false);

  static ThemeData get darkTheme =>
      buildDynamicTheme(firmTheme: FirmTheme.defaultTheme(), isDark: true);
}
