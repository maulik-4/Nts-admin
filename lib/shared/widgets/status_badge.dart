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
    final normalized = status.toLowerCase().trim();

    if (normalized == 'open' ||
        normalized == 'active' ||
        normalized == 'paid' ||
        normalized == 'completed' ||
        normalized == 'resolved') {
      return (LexColors.success, LexColors.successLight);
    }

    if (normalized == 'pending' ||
        normalized == 'in_progress' ||
        normalized == 'in progress' ||
        normalized == 'trial') {
      return (LexColors.warning, LexColors.accentLight);
    }

    if (normalized == 'urgent' ||
        normalized == 'critical' ||
        normalized == 'overdue' ||
        normalized == 'cancelled') {
      return (LexColors.error, LexColors.errorLight);
    }

    // Default / closed
    return (LexColors.textSecondaryLight, const Color(0xFFF1F5F9));
  }
}
