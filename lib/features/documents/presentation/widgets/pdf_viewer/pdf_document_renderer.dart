import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../../core/theme/lex_colors.dart';

class PdfDocumentRenderer extends StatelessWidget {
  final Uint8List? pdfBytes;
  final bool isLoading;
  final String? errorMessage;
  final PdfViewerController controller;
  final VoidCallback onRetry;
  final ValueChanged<int> onPageCountDetermined;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<double> onZoomLevelChanged;
  final ValueChanged<String> onLoadFailed;

  const PdfDocumentRenderer({
    super.key,
    required this.pdfBytes,
    required this.isLoading,
    required this.errorMessage,
    required this.controller,
    required this.onRetry,
    required this.onPageCountDetermined,
    required this.onPageChanged,
    required this.onZoomLevelChanged,
    required this.onLoadFailed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final workspaceColor = isDark
        ? const Color(0xFF0A0F1D)
        : const Color(0xFFE2E8F0);

    if (isLoading) {
      return Container(
        color: workspaceColor,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? LexColors.surfaceDark : LexColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF7F1D1D).withValues(alpha: 0.25)
                        : const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 30,
                    color: isDark
                        ? const Color(0xFFF87171)
                        : const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: isDark
                        ? LexColors.accentGold
                        : LexColors.slatePrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading document...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : LexColors.slatePrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Decrypting and preparing preview',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? LexColors.textSecondaryDark
                        : LexColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (errorMessage != null || pdfBytes == null) {
      return Container(
        color: workspaceColor,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? LexColors.surfaceDark : LexColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? LexColors.borderDark : LexColors.borderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF7F1D1D).withValues(alpha: 0.3)
                        : const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 32,
                    color: LexColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to preview this document.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : LexColors.slatePrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage ?? 'The document could not be rendered.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? LexColors.textSecondaryDark
                        : LexColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: LexColors.slatePrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: workspaceColor,
      child: SfPdfViewer.memory(
        pdfBytes!,
        controller: controller,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        canShowPaginationDialog: false,
        enableDoubleTapZooming: true,
        pageSpacing: 8,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          onPageCountDetermined(details.document.pages.count);
        },
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          onLoadFailed(details.description);
        },
        onPageChanged: (PdfPageChangedDetails details) {
          onPageChanged(details.newPageNumber);
        },
        onZoomLevelChanged: (PdfZoomDetails details) {
          onZoomLevelChanged(details.newZoomLevel);
        },
      ),
    );
  }
}
