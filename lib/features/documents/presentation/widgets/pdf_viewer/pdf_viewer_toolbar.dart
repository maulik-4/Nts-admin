import 'package:flutter/material.dart';

import '../../../../../core/theme/lex_colors.dart';
import 'pdf_jump_dialog.dart';
import 'pdf_page_navigation.dart';
import 'pdf_zoom_controls.dart';

class PdfViewerToolbar extends StatelessWidget {
  final String title;
  final int currentPage;
  final int pageCount;
  final double zoomLevel;
  final bool isFullscreen;
  final bool isDownloading;
  final bool? isMobile;
  final VoidCallback onClose;
  final ValueChanged<int> onPageSelected;
  final ValueChanged<double> onZoomChanged;
  final VoidCallback onDownload;
  final VoidCallback onToggleFullscreen;

  const PdfViewerToolbar({
    super.key,
    required this.title,
    required this.currentPage,
    required this.pageCount,
    required this.zoomLevel,
    required this.isFullscreen,
    this.isDownloading = false,
    this.isMobile,
    required this.onClose,
    required this.onPageSelected,
    required this.onZoomChanged,
    required this.onDownload,
    required this.onToggleFullscreen,
  });

  Future<void> _openJumpDialog(BuildContext context) async {
    if (pageCount <= 1) return;
    final targetPage = await showDialog<int>(
      context: context,
      builder: (ctx) =>
          PdfJumpDialog(currentPage: currentPage, pageCount: pageCount),
    );
    if (targetPage != null && targetPage != currentPage) {
      onPageSelected(targetPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? LexColors.surfaceDark : LexColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? LexColors.borderDark : LexColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final effectiveIsMobile = isMobile ?? (constraints.maxWidth < 540);

          if (effectiveIsMobile) {
            return _buildMobileToolbar(context, isDark);
          }

          final isCompact = constraints.maxWidth < 720;
          return _buildDesktopToolbar(context, isDark, isCompact);
        },
      ),
    );
  }

  Widget _buildMobileToolbar(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Back / Close button
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          tooltip: 'Close document preview',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: onClose,
        ),
        const SizedBox(width: 4),

        // Mini PDF Icon
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF7F1D1D).withValues(alpha: 0.3)
                : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.picture_as_pdf_rounded,
            size: 16,
            color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
          ),
        ),
        const SizedBox(width: 8),

        // Document Title
        Expanded(
          child: Tooltip(
            message: title,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? LexColors.textPrimaryDark
                    : LexColors.slatePrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),

        // Download Action
        IconButton(
          icon: isDownloading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_rounded, size: 20),
          tooltip: 'Download document',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: isDownloading ? null : onDownload,
        ),

        // Overflow Options Menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, size: 20),
          tooltip: 'More options',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onSelected: (value) {
            if (value == 'fullscreen') {
              onToggleFullscreen();
            } else if (value == 'jump') {
              _openJumpDialog(context);
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'fullscreen',
              child: Row(
                children: [
                  Icon(
                    isFullscreen
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(isFullscreen ? 'Exit Fullscreen' : 'Fullscreen'),
                ],
              ),
            ),
            if (pageCount > 1)
              const PopupMenuItem(
                value: 'jump',
                child: Row(
                  children: [
                    Icon(Icons.find_in_page_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('Jump to Page...'),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopToolbar(
    BuildContext context,
    bool isDark,
    bool isCompact,
  ) {
    return Row(
      children: [
        // Close button
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          tooltip: 'Close document preview',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: onClose,
        ),
        const SizedBox(width: 4),

        // PDF Icon
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF7F1D1D).withValues(alpha: 0.3)
                : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.picture_as_pdf_rounded,
            size: 18,
            color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
          ),
        ),
        const SizedBox(width: 8),

        // Document Title
        Expanded(
          child: Tooltip(
            message: title,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isCompact ? 13 : 14,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? LexColors.textPrimaryDark
                    : LexColors.slatePrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Page Navigation
        FittedBox(
          fit: BoxFit.scaleDown,
          child: PdfPageNavigation(
            currentPage: currentPage,
            pageCount: pageCount,
            onPageSelected: onPageSelected,
          ),
        ),
        const SizedBox(width: 8),

        // Zoom Controls
        FittedBox(
          fit: BoxFit.scaleDown,
          child: PdfZoomControls(
            zoomLevel: zoomLevel,
            onZoomChanged: onZoomChanged,
          ),
        ),
        const SizedBox(width: 8),

        // Download Button
        IconButton(
          icon: isDownloading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_rounded, size: 20),
          tooltip: 'Download document',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: isDownloading ? null : onDownload,
        ),

        // Fullscreen Button
        IconButton(
          icon: Icon(
            isFullscreen
                ? Icons.fullscreen_exit_rounded
                : Icons.fullscreen_rounded,
            size: 22,
          ),
          tooltip: isFullscreen ? 'Exit fullscreen' : 'Fullscreen',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: onToggleFullscreen,
        ),
      ],
    );
  }
}
