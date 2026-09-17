import 'package:flutter/material.dart';

import '../../core/theme/lex_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Color? color;
  final Color? backgroundColor;

  const StatusBadge({
    super.key,
    required this.status,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final (textColor, bgColor) = _resolveColors(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (color ?? textColor).withAlpha(60),
          width: 0.8,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color ?? textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
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
      final text = isDark ? const Color(0xFF34D399) : LexColors.success;
      final bg = isDark
          ? const Color(0xFF34D399).withValues(alpha: 0.18)
          : LexColors.successLight;
      return (text, bg);
    }

    if (normalized == 'pending' ||
        normalized == 'in_progress' ||
        normalized == 'in progress' ||
        normalized == 'trial') {
      final text = isDark ? LexColors.accentGold : LexColors.warning;
      final bg = isDark
          ? LexColors.accentGold.withValues(alpha: 0.18)
          : LexColors.accentLight;
      return (text, bg);
    }

    if (normalized == 'urgent' ||
        normalized == 'critical' ||
        normalized == 'overdue' ||
        normalized == 'cancelled') {
      final text = isDark ? const Color(0xFFF87171) : LexColors.error;
      final bg = isDark
          ? const Color(0xFFF87171).withValues(alpha: 0.18)
          : LexColors.errorLight;
      return (text, bg);
    }

    // Default / closed
    final text = isDark
        ? LexColors.textSecondaryDark
        : LexColors.textSecondaryLight;
    final bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    return (text, bg);
  }
}
