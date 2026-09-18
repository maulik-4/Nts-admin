import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/branding/data/models/firm_profile.dart';
import 'package:flutter_application_1/features/branding/presentation/widgets/preview/firm_app_preview.dart';
import 'package:flutter_application_1/features/branding/presentation/widgets/preview/preview_bottom_nav.dart';
import 'package:flutter_application_1/features/branding/presentation/widgets/preview/preview_logo.dart';
import 'package:flutter_application_1/features/branding/presentation/widgets/preview/preview_sidebar.dart';

void main() {
  group('FirmAppPreview Realistic Experience Widget Tests', () {
    Widget buildTestWidget({
      String firmName = 'Lex & Partners Legal',
      Color primaryColor = const Color(0xFF1B365D),
      Color accentColor = const Color(0xFFC5A059),
      String fontFamily = 'Cinzel',
      bool sidebarDark = true,
      String? logoUrl,
      bool hasUnsavedChanges = true,
    }) {
      final profile = FirmProfile(
        id: 1,
        name: firmName,
        themeColor: '#1B365D',
        accentColor: '#C5A059',
        fontFamily: fontFamily,
        sidebarDark: sidebarDark,
        logo: logoUrl,
      );

      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              height: 1000,
              child: FirmAppPreview(
                profile: profile,
                draftPrimaryColor: primaryColor,
                draftAccentColor: accentColor,
                draftFontFamily: fontFamily,
                draftSidebarDark: sidebarDark,
                existingLogoUrl: logoUrl,
                hasUnsavedChanges: hasUnsavedChanges,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'renders firm name and realistic application elements dynamically',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(firmName: 'Apex Advocacy Chambers'),
        );
        await tester.pumpAndSettle();

        // Check header firm name
        expect(find.text('Apex Advocacy Chambers'), findsWidgets);

        // Check browser frame decorations
        expect(find.text('UNSAVED DRAFT'), findsOneWidget);
        expect(find.text('firm.vidhanta.app/app/dashboard'), findsOneWidget);

        // Check dashboard content
        expect(find.text('Active Cases'), findsOneWidget);
        expect(find.text('Clients'), findsWidgets);
        expect(find.text('Hearings (Week)'), findsOneWidget);
        expect(find.text('Billed Revenue'), findsOneWidget);

        // Check action buttons
        expect(find.text('+ New Case'), findsOneWidget);
        expect(find.text('+ New Client'), findsOneWidget);

        // Check litigation activity table
        expect(find.text('Recent Case Matters & Filings'), findsOneWidget);
        expect(find.text('Sharma vs. State of Maharashtra'), findsOneWidget);
        expect(find.text('Commercial Division · High Court'), findsOneWidget);
      },
    );

    testWidgets('sidebar switches views smoothly without real API mutations', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(firmName: 'National Legal Associates'),
      );
      await tester.pumpAndSettle();

      // Initially on Dashboard
      expect(find.text('Recent Case Matters & Filings'), findsOneWidget);

      // Tap on Cases item in NavigationRail
      final casesTextFinder = find.descendant(
        of: find.byType(PreviewSidebar),
        matching: find.text('Cases'),
      );
      expect(casesTextFinder, findsOneWidget);
      await tester.tap(casesTextFinder);
      await tester.pumpAndSettle();

      // Should now show Cases View
      expect(find.text('Litigation Cases Docket'), findsOneWidget);

      // Tap on Clients item in NavigationRail
      final clientsTextFinder = find.descendant(
        of: find.byType(PreviewSidebar),
        matching: find.text('Clients'),
      );
      expect(clientsTextFinder, findsOneWidget);
      await tester.tap(clientsTextFinder);
      await tester.pumpAndSettle();

      // Should now show Clients View
      expect(find.text('Client Directory (142)'), findsOneWidget);

      // Tap on Hearings
      final hearingsTextFinder = find.descendant(
        of: find.byType(PreviewSidebar),
        matching: find.text('Hearings'),
      );
      expect(hearingsTextFinder, findsOneWidget);
      await tester.tap(hearingsTextFinder);
      await tester.pumpAndSettle();

      // Should show Hearings View
      expect(find.text('Court Docket & Hearings'), findsOneWidget);

      // Tap on More
      final moreTextFinder = find.descendant(
        of: find.byType(PreviewSidebar),
        matching: find.text('More'),
      );
      expect(moreTextFinder, findsOneWidget);
      await tester.tap(moreTextFinder);
      await tester.pumpAndSettle();

      // Should show More View
      expect(find.text('Firm Administration Modules'), findsOneWidget);
    });

    testWidgets('toggles viewport between desktop and mobile previews', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(firmName: 'Veritas Law Group'));
      await tester.pumpAndSettle();

      // Desktop shows NavigationRail, not bottom nav
      expect(find.byType(PreviewSidebar), findsOneWidget);
      expect(find.byType(PreviewBottomNav), findsNothing);

      // Switch to Mobile viewport
      final mobileToggleFinder = find.byTooltip('Mobile View');
      expect(mobileToggleFinder, findsOneWidget);
      await tester.tap(mobileToggleFinder);
      await tester.pumpAndSettle();

      // Mobile now shows bottom nav, not NavigationRail
      expect(find.byType(PreviewSidebar), findsNothing);
      expect(find.byType(PreviewBottomNav), findsOneWidget);

      // Switch back to Desktop viewport
      final desktopToggleFinder = find.byTooltip('Desktop View');
      expect(desktopToggleFinder, findsOneWidget);
      await tester.tap(desktopToggleFinder);
      await tester.pumpAndSettle();

      // Desktop is back
      expect(find.byType(PreviewSidebar), findsOneWidget);
      expect(find.byType(PreviewBottomNav), findsNothing);
    });

    testWidgets('toggles between light and dark preview themes cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(firmName: 'Veritas Law Group'));
      await tester.pumpAndSettle();

      // Both Light and Dark preview mode toggle buttons exist
      final darkToggleFinder = find.byTooltip('Dark Preview');
      final lightToggleFinder = find.byTooltip('Light Preview');
      expect(darkToggleFinder, findsOneWidget);
      expect(lightToggleFinder, findsOneWidget);

      // Tap to switch to dark preview
      await tester.tap(darkToggleFinder);
      await tester.pumpAndSettle();

      // Tap to switch back to light preview
      await tester.tap(lightToggleFinder);
      await tester.pumpAndSettle();

      expect(lightToggleFinder, findsOneWidget);
    });

    testWidgets(
      'PreviewLogo gracefully falls back to initials when logo is absent',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(child: PreviewLogo(fallbackInitial: 'AL', size: 40)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should display firm initials 'AL'
        expect(find.text('AL'), findsOneWidget);
      },
    );
  });
}
