import 'package:flutter/material.dart';

import '../theme/client_portal_theme.dart';

class ClientEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ClientEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2D4A)
                    : const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFDBEAFE),
                ),
              ),
              child: Icon(
                icon,
                size: 28,
                color: ClientPortalColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? ClientPortalColors.darkPrimaryText
                    : ClientPortalColors.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark
                    ? ClientPortalColors.darkSecondaryText
                    : ClientPortalColors.secondaryText,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ClientPortalDimensions.buttonRadius,
                    ),
                  ),
                  side: const BorderSide(color: ClientPortalColors.primaryBlue),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ClientPortalColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
