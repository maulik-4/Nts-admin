import 'package:flutter/material.dart';

import '../../../../../core/theme/lex_colors.dart';

class PdfZoomControls extends StatelessWidget {
  final double zoomLevel;
  final ValueChanged<double> onZoomChanged;
  final double minZoom;
  final double maxZoom;
  final double zoomStep;

  const PdfZoomControls({
    super.key,
    required this.zoomLevel,
    required this.onZoomChanged,
    this.minZoom = 0.5,
    this.maxZoom = 3.0,
    this.zoomStep = 0.25,
  });

  bool get canZoomOut => zoomLevel > minZoom + 0.01;
  bool get canZoomIn => zoomLevel < maxZoom - 0.01;

  void _zoomIn() {
    final next = (zoomLevel + zoomStep).clamp(minZoom, maxZoom);
    onZoomChanged(next);
  }

  void _zoomOut() {
    final next = (zoomLevel - zoomStep).clamp(minZoom, maxZoom);
    onZoomChanged(next);
  }

  void _resetZoom() {
    onZoomChanged(1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percent = (zoomLevel * 100).round();

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
            icon: const Icon(Icons.remove_rounded, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 32),
            tooltip: 'Zoom out',
            onPressed: canZoomOut ? _zoomOut : null,
          ),
          InkWell(
            onTap: _resetZoom,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Tooltip(
                message: 'Reset zoom (100%)',
                child: Text(
                  '$percent%',
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
            icon: const Icon(Icons.add_rounded, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 32),
            tooltip: 'Zoom in',
            onPressed: canZoomIn ? _zoomIn : null,
          ),
        ],
      ),
    );
  }
}
