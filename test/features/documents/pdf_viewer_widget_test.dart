import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/features/documents/data/models/document_model.dart';
import 'package:flutter_application_1/features/documents/presentation/screens/document_detail_screen.dart';
import 'package:flutter_application_1/features/documents/presentation/providers/documents_notifier.dart';
import 'package:flutter_application_1/features/documents/presentation/widgets/pdf_viewer/pdf_jump_dialog.dart';
import 'package:flutter_application_1/features/documents/presentation/widgets/pdf_viewer/pdf_page_navigation.dart';
import 'package:flutter_application_1/features/documents/presentation/widgets/pdf_viewer/pdf_zoom_controls.dart';
import 'package:flutter_application_1/features/documents/presentation/widgets/pdf_viewer/pdf_viewer_toolbar.dart';
import 'package:flutter_application_1/features/documents/presentation/widgets/pdf_viewer/pdf_viewer_bottom_bar.dart';
import 'package:flutter_application_1/features/documents/presentation/widgets/pdf_viewer/pdf_document_renderer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

void main() {
  group('PDF Viewer Components Tests', () {
    testWidgets(
      'PdfZoomControls renders zoom percentage and responds to clicks',
      (tester) async {
        double currentZoom = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return PdfZoomControls(
                    zoomLevel: currentZoom,
                    onZoomChanged: (newZoom) {
                      setState(() => currentZoom = newZoom);
                    },
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('100%'), findsOneWidget);

        // Zoom in
        await tester.tap(find.byTooltip('Zoom in'));
        await tester.pumpAndSettle();
        expect(currentZoom, 1.25);
        expect(find.text('125%'), findsOneWidget);

        // Zoom out
        await tester.tap(find.byTooltip('Zoom out'));
        await tester.pumpAndSettle();
        expect(currentZoom, 1.0);
        expect(find.text('100%'), findsOneWidget);

        // Reset zoom
        await tester.tap(find.byTooltip('Zoom in'));
        await tester.pumpAndSettle();
        expect(find.text('125%'), findsOneWidget);

        await tester.tap(find.byTooltip('Reset zoom (100%)'));
        await tester.pumpAndSettle();
        expect(currentZoom, 1.0);
        expect(find.text('100%'), findsOneWidget);
      },
    );

    testWidgets('PdfPageNavigation displays page numbers and navigates', (
      tester,
    ) async {
      int currentPage = 2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return PdfPageNavigation(
                  currentPage: currentPage,
                  pageCount: 5,
                  onPageSelected: (p) => setState(() => currentPage = p),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('2 / 5'), findsOneWidget);

      // Previous button
      await tester.tap(find.byTooltip('Previous page'));
      await tester.pumpAndSettle();
      expect(currentPage, 1);
      expect(find.text('1 / 5'), findsOneWidget);

      // Previous button disabled on page 1
      final prevBtn = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left_rounded),
      );
      expect(prevBtn.onPressed, isNull);

      // Next button
      await tester.tap(find.byTooltip('Next page'));
      await tester.pumpAndSettle();
      expect(currentPage, 2);
      expect(find.text('2 / 5'), findsOneWidget);
    });

    testWidgets('PdfJumpDialog validates and submits valid page', (
      tester,
    ) async {
      int? submittedPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    submittedPage = await showDialog<int>(
                      context: context,
                      builder: (ctx) =>
                          const PdfJumpDialog(currentPage: 3, pageCount: 10),
                    );
                  },
                  child: const Text('Open Jump'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Jump'));
      await tester.pumpAndSettle();

      expect(find.text('Go to Page'), findsOneWidget);
      expect(find.text('Total pages: 10'), findsOneWidget);

      // Enter valid page 7
      final inputFinder = find.byType(TextField);
      await tester.enterText(inputFinder, '7');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(submittedPage, 7);
    });

    testWidgets('PdfViewerToolbar renders controls with accessibility labels', (
      tester,
    ) async {
      bool closed = false;
      bool downloaded = false;
      bool toggledFullscreen = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              child: PdfViewerToolbar(
                title: 'legal_brief_final.pdf',
                currentPage: 3,
                pageCount: 8,
                zoomLevel: 1.0,
                isFullscreen: false,
                isMobile: false,
                onClose: () => closed = true,
                onPageSelected: (_) {},
                onZoomChanged: (_) {},
                onDownload: () => downloaded = true,
                onToggleFullscreen: () => toggledFullscreen = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('legal_brief_final.pdf'), findsOneWidget);
      expect(find.text('3 / 8'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);

      expect(find.byTooltip('Close document preview'), findsOneWidget);
      expect(find.byTooltip('Download document'), findsOneWidget);
      expect(find.byTooltip('Fullscreen'), findsOneWidget);

      await tester.tap(find.byTooltip('Close document preview'));
      expect(closed, true);

      await tester.tap(find.byTooltip('Download document'));
      expect(downloaded, true);

      await tester.tap(find.byTooltip('Fullscreen'));
      expect(toggledFullscreen, true);
    });

    testWidgets('PdfViewerToolbar adapts to mobile layout without overflow', (
      tester,
    ) async {
      bool closed = false;
      bool toggledFullscreen = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: PdfViewerToolbar(
                title: 'very_long_legal_affidavit_filename_2026.pdf',
                currentPage: 1,
                pageCount: 12,
                zoomLevel: 1.0,
                isFullscreen: false,
                isMobile: true,
                onClose: () => closed = true,
                onPageSelected: (_) {},
                onZoomChanged: (_) {},
                onDownload: () {},
                onToggleFullscreen: () => toggledFullscreen = true,
              ),
            ),
          ),
        ),
      );

      // Title should render with ellipsis without overflow
      expect(
        find.text('very_long_legal_affidavit_filename_2026.pdf'),
        findsOneWidget,
      );
      expect(find.byTooltip('Close document preview'), findsOneWidget);
      expect(find.byTooltip('Download document'), findsOneWidget);
      expect(find.byTooltip('More options'), findsOneWidget);

      // Open overflow menu
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();

      expect(find.text('Fullscreen'), findsOneWidget);
      expect(find.text('Jump to Page...'), findsOneWidget);

      await tester.tap(find.text('Fullscreen'));
      await tester.pumpAndSettle();
      expect(toggledFullscreen, true);

      await tester.tap(find.byTooltip('Close document preview'));
      expect(closed, true);
    });

    testWidgets(
      'PdfViewerBottomBar renders zoom and page controls seamlessly',
      (tester) async {
        int page = 4;
        double zoom = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 360,
                child: PdfViewerBottomBar(
                  currentPage: page,
                  pageCount: 10,
                  zoomLevel: zoom,
                  onPageSelected: (p) => page = p,
                  onZoomChanged: (z) => zoom = z,
                ),
              ),
            ),
          ),
        );

        expect(find.text('100%'), findsOneWidget);
        expect(find.text('4 / 10'), findsOneWidget);

        // Zoom in
        await tester.tap(find.byTooltip('Zoom in'));
        expect(zoom, 1.25);

        // Next page
        await tester.tap(find.byTooltip('Next page'));
        expect(page, 5);
      },
    );

    testWidgets('PdfDocumentRenderer displays loading state correctly', (
      tester,
    ) async {
      final controller = PdfViewerController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PdfDocumentRenderer(
              pdfBytes: null,
              isLoading: true,
              errorMessage: null,
              controller: controller,
              onRetry: () {},
              onPageCountDetermined: (_) {},
              onPageChanged: (_) {},
              onZoomLevelChanged: (_) {},
              onLoadFailed: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Loading document...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('PdfDocumentRenderer displays error state and handles retry', (
      tester,
    ) async {
      final controller = PdfViewerController();
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PdfDocumentRenderer(
              pdfBytes: null,
              isLoading: false,
              errorMessage: 'Network timeout',
              controller: controller,
              onRetry: () => retried = true,
              onPageCountDetermined: (_) {},
              onPageChanged: (_) {},
              onZoomLevelChanged: (_) {},
              onLoadFailed: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Unable to preview this document.'), findsOneWidget);
      expect(find.text('Network timeout'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retried, true);
    });

    testWidgets('DocumentDetailScreen renders Preview Document button', (
      tester,
    ) async {
      const mockDoc = Document(
        id: 42,
        caseId: 10,
        caseTitle: 'Doe vs Smith',
        firm: 15,
        file: 'https://api.hphighcourt.site/files/contract.pdf',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentDetailProvider(42)
                .overrideWith((ref) => Future.value(mockDoc)),
          ],
          child: const MaterialApp(home: DocumentDetailScreen(documentId: 42)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Preview Document'), findsOneWidget);
      expect(find.text('Download Document'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsWidgets);
    });
  });
}
