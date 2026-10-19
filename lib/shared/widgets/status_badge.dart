import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Color? color;
  final Color? backgroundColor;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.color,
    this.backgroundColor,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final (textColor, bgColor) = _resolveColors(context);
    final effectiveTextColor = color ?? textColor;
    final effectiveBgColor = backgroundColor ?? bgColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: effectiveTextColor.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: effectiveTextColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            status.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: effectiveTextColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _resolveColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalized = status.toLowerCase().trim();

    if (normalized == 'open' ||
        normalized == 'active' ||
        normalized == 'paid' ||
        normalized == 'completed' ||
        normalized == 'resolved') {
      final text = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
      final bg = isDark
          ? const Color(0xFF34D399).withValues(alpha: 0.18)
          : const Color(0xFFECFDF5);
      return (text, bg);
    }

    if (normalized == 'pending' ||
        normalized == 'in_progress' ||
        normalized == 'in progress' ||
        normalized == 'trial' ||
        normalized == 'medium') {
      final text = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
      final bg = isDark
          ? const Color(0xFFFBBF24).withValues(alpha: 0.18)
          : const Color(0xFFFFFBEB);
      return (text, bg);
    }

    if (normalized == 'urgent' ||
        normalized == 'critical' ||
        normalized == 'overdue' ||
        normalized == 'cancelled' ||
        normalized == 'high') {
      final text = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
      final bg = isDark
          ? const Color(0xFFF87171).withValues(alpha: 0.18)
          : const Color(0xFFFEF2F2);
      return (text, bg);
    }

    // Default / closed / neutral
    final text = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final bg = isDark
        ? const Color(0xFF334155).withValues(alpha: 0.3)
        : const Color(0xFFF1F5F9);
    return (text, bg);
  }
}
