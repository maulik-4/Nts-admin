import 'package:flutter/material.dart';

import '../../../../../core/theme/lex_colors.dart';
import 'pdf_jump_dialog.dart';

class PdfPageNavigation extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onPageSelected;

  const PdfPageNavigation({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.onPageSelected,
  });

  bool get canGoPrevious => currentPage > 1;
  bool get canGoNext => pageCount > 0 && currentPage < pageCount;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPages = pageCount > 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? LexColors.surfaceDark.withValues(alpha: 0.8)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? LexColors.borderDark : LexColors.borderLight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: 'Previous page',
            onPressed: canGoPrevious
                ? () => onPageSelected(currentPage - 1)
                : null,
          ),
          InkWell(
            onTap: hasPages ? () => _openJumpDialog(context) : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Tooltip(
                message: hasPages ? 'Click to jump to a page' : '',
                child: Text(
                  hasPages ? '$currentPage / $pageCount' : '- / -',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : LexColors.textPrimaryLight,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: 'Next page',
            onPressed: canGoNext ? () => onPageSelected(currentPage + 1) : null,
          ),
        ],
      ),
    );
  }
}
