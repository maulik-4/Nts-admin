import 'package:flutter/material.dart';

import '../../../../../core/theme/lex_colors.dart';
import 'pdf_page_navigation.dart';
import 'pdf_zoom_controls.dart';

class PdfViewerBottomBar extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final double zoomLevel;
  final ValueChanged<int> onPageSelected;
  final ValueChanged<double> onZoomChanged;

  const PdfViewerBottomBar({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.zoomLevel,
    required this.onPageSelected,
    required this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? LexColors.surfaceDark : LexColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? LexColors.borderDark : LexColors.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Zoom Controls
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: PdfZoomControls(
                      zoomLevel: zoomLevel,
                      onZoomChanged: onZoomChanged,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Vertical Divider
                Container(
                  height: 24,
                  width: 1,
                  color: isDark ? LexColors.borderDark : LexColors.borderLight,
                ),
                const SizedBox(width: 8),

                // Page Navigation
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: PdfPageNavigation(
                      currentPage: currentPage,
                      pageCount: pageCount,
                      onPageSelected: onPageSelected,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
