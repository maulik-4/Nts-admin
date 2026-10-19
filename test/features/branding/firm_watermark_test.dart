import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/core/theme/firm_theme.dart';
import 'package:flutter_application_1/core/theme/firm_theme_provider.dart';
import 'package:flutter_application_1/core/theme/lex_theme.dart';
import 'package:flutter_application_1/features/auth/domain/models/role_capabilities.dart';
import 'package:flutter_application_1/features/auth/domain/models/user_role.dart';
import 'package:flutter_application_1/features/shell/presentation/screens/app_shell.dart';
import 'package:flutter_application_1/shared/widgets/firm_watermark_background.dart';
import 'package:flutter_application_1/shared/widgets/lex_button.dart';

void main() {
  group('FirmWatermarkBackground Tests', () {
    testWidgets('renders classical legal seal when logoUrl is null', (
      tester,
    ) async {
      final customTheme = FirmTheme(
        firmName: 'Veritas Legal Advocates',
        primaryColor: const Color(0xFF780016), // Deep Burgundy
        accentColor: const Color(0xFFC9A84C),
        fontFamily: 'system',
        sidebarDark: true,
        logoUrl: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirmWatermarkBackground(
              firmTheme: customTheme,
              isDark: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.balance), findsOneWidget);
      expect(find.text('VERITAS LEGAL ADVOCATES'), findsOneWidget);
      final ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(
          of: find.byType(FirmWatermarkBackground),
          matching: find.byType(IgnorePointer),
        ),
      );
      expect(ignorePointer.ignoring, isTrue);
    });

    testWidgets('renders network image when logoUrl is provided', (
      tester,
    ) async {
      final customTheme = FirmTheme(
        firmName: 'Apex Legal Chambers',
        primaryColor: const Color(0xFF0F5132), // Emerald
        accentColor: const Color(0xFFD97706),
        fontFamily: 'system',
        sidebarDark: true,
        logoUrl: 'https://example.com/logo.png',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirmWatermarkBackground(
              firmTheme: customTheme,
              isDark: false,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('APEX LEGAL CHAMBERS'), findsOneWidget);
    });

    testWidgets('calibrates opacity between underlay and overlay modes', (
      tester,
    ) async {
      final customTheme = FirmTheme.defaultTheme();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: FirmWatermarkBackground(
                    firmTheme: customTheme,
                    isOverlay: false,
                  ),
                ),
                Expanded(
                  child: FirmWatermarkBackground(
                    firmTheme: customTheme,
                    isOverlay: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final opacities = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .map((o) => o.opacity)
          .toList();

      expect(opacities.length, 2);
      expect(opacities[0], greaterThan(opacities[1]));
    });
  });

  group('LexTheme Dynamic Styling Tests', () {
    test(
      'buildDynamicTheme sets primary and accent colors across components',
      () {
        final customTheme = FirmTheme(
          firmName: 'Justice & Associates',
          primaryColor: const Color(0xFF1E3A8A), // Royal Blue
          accentColor: const Color(0xFFF59E0B), // Amber Gold
          fontFamily: 'system',
          sidebarDark: false,
        );

        final lightTheme = LexTheme.buildDynamicTheme(
          firmTheme: customTheme,
          isDark: false,
        );

        expect(lightTheme.colorScheme.primary, const Color(0xFF1E3A8A));
        expect(lightTheme.colorScheme.secondary, const Color(0xFFF59E0B));
        expect(
          lightTheme.floatingActionButtonTheme.backgroundColor,
          const Color(0xFF1E3A8A),
        );
        expect(
          lightTheme.floatingActionButtonTheme.foregroundColor,
          Colors.white,
        );
        expect(lightTheme.tabBarTheme.labelColor, const Color(0xFF1E3A8A));
        expect(lightTheme.scaffoldBackgroundColor, Colors.transparent);
      },
    );

    testWidgets('LexButton adopts dynamic primary and secondary colors', (
      tester,
    ) async {
      final customTheme = FirmTheme(
        firmName: 'Elite Law Firm',
        primaryColor: const Color(0xFF831843), // Crimson
        accentColor: const Color(0xFF10B981),
        fontFamily: 'system',
        sidebarDark: true,
      );

      final themeData = LexTheme.buildDynamicTheme(
        firmTheme: customTheme,
        isDark: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: themeData,
          home: Scaffold(
            body: Column(
              children: [
                LexButton(
                  label: 'Submit Case',
                  variant: LexButtonVariant.primary,
                  onPressed: () {},
                ),
                LexButton(
                  label: 'Cancel',
                  variant: LexButtonVariant.secondary,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Verify primary button uses the custom theme's primary color
      final primaryMaterial = tester.widget<Material>(
        find.descendant(
          of: find.widgetWithText(LexButton, 'Submit Case'),
          matching: find.byType(Material),
        ),
      );
      expect(primaryMaterial.color, const Color(0xFF831843));
    });
  });

  group('AppShell Watermark Integration Tests', () {
    GoRouter createTestRouter() {
      return GoRouter(
        initialLocation: '/test',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                AppShell(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/test',
                    builder: (context, state) =>
                        const Scaffold(body: Text('Workspace Child Screen')),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }

    testWidgets('does NOT render firm watermark on pages for lawyer role', (
      tester,
    ) async {
      final customTheme = FirmTheme(
        firmName: 'Veritas Legal Chambers',
        primaryColor: const Color(0xFF0F5132),
        accentColor: const Color(0xFFD97706),
        fontFamily: 'system',
        sidebarDark: true,
      );

      final router = createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserRoleProvider.overrideWithValue(UserRole.lawyer),
            firmThemeProvider.overrideWith(
              (ref) => _StaticFirmThemeNotifier(customTheme),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Workspace Child Screen'), findsOneWidget);
      // Firm watermark has been removed across all pages as requested
      expect(find.byType(FirmWatermarkBackground), findsNothing);
    });

    testWidgets('does NOT render firm watermark for super admin role', (
      tester,
    ) async {
      final router = createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserRoleProvider.overrideWithValue(UserRole.superAdmin),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Workspace Child Screen'), findsOneWidget);
      // Neutral platform console for Super Admin has no firm watermark
      expect(find.byType(FirmWatermarkBackground), findsNothing);
    });
  });
}

class _StaticFirmThemeNotifier extends StateNotifier<FirmTheme>
    implements FirmThemeNotifier {
  _StaticFirmThemeNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
