import 'package:flutter/material.dart';

import '../theme/client_portal_theme.dart';

enum ClientStatusType {
  active,
  pending,
  closed,
  upcoming,
  overdue,
  neutral;

  static ClientStatusType fromString(String status) {
    final s = status.trim().toLowerCase();
    if (s.contains('active') || s.contains('progress') || s.contains('open')) {
      return ClientStatusType.active;
    }
    if (s.contains('pend') || s.contains('schedul')) {
      return ClientStatusType.pending;
    }
    if (s.contains('close') || s.contains('settl') || s.contains('resolv')) {
      return ClientStatusType.closed;
    }
    if (s.contains('upcom')) {
      return ClientStatusType.upcoming;
    }
    if (s.contains('overdue') || s.contains('urgent')) {
      return ClientStatusType.overdue;
    }
    return ClientStatusType.neutral;
  }
}

class ClientStatusBadge extends StatelessWidget {
  final String label;
  final ClientStatusType? type;

  const ClientStatusBadge({super.key, required this.label, this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedType = type ?? ClientStatusType.fromString(label);

    Color bg;
    Color text;
    Color border;

    switch (resolvedType) {
      case ClientStatusType.active:
        bg = isDark
            ? ClientPortalColors.success.withValues(alpha: 0.18)
            : const Color(0xFFE8F5E9);
        text = isDark ? const Color(0xFF4ADE80) : ClientPortalColors.success;
        border = text.withValues(alpha: 0.35);
        break;
      case ClientStatusType.pending:
      case ClientStatusType.upcoming:
        bg = isDark
            ? ClientPortalColors.warning.withValues(alpha: 0.18)
            : const Color(0xFFFEF3C7);
        text = isDark ? const Color(0xFFFBBF24) : ClientPortalColors.warning;
        border = text.withValues(alpha: 0.35);
        break;
      case ClientStatusType.overdue:
        bg = isDark
            ? ClientPortalColors.error.withValues(alpha: 0.18)
            : const Color(0xFFFEE2E2);
        text = isDark ? const Color(0xFFF87171) : ClientPortalColors.error;
        border = text.withValues(alpha: 0.35);
        break;
      case ClientStatusType.closed:
      case ClientStatusType.neutral:
        bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
        text = isDark
            ? ClientPortalColors.darkSecondaryText
            : ClientPortalColors.secondaryText;
        border = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(ClientPortalDimensions.badgeRadius),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: text,
        ),
      ),
    );
  }
}
