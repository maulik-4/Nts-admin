import 'package:flutter/material.dart';

import '../theme/client_portal_theme.dart';
import '../../data/models/client_dashboard_model.dart';
import 'client_status_badge.dart';

class ClientCaseCard extends StatelessWidget {
  final ClientCaseItem caseItem;
  final HearingItem? nextHearing;
  final VoidCallback onTap;

  const ClientCaseCard({
    super.key,
    required this.caseItem,
    this.nextHearing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? ClientPortalColors.darkCardBackground
            : ClientPortalColors.cardBackground,
        borderRadius: BorderRadius.circular(ClientPortalDimensions.cardRadius),
        border: Border.all(
          color: isDark
              ? ClientPortalColors.darkBorder
              : ClientPortalColors.border,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A)
                .withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            ClientPortalDimensions.cardRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Case Number badge and Status badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: ClientPortalColors.primaryNavy.withValues(
                          alpha: isDark ? 0.3 : 0.08,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        caseItem.caseNumber.isNotEmpty
                            ? caseItem.caseNumber
                            : 'Case #${caseItem.id}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : ClientPortalColors.primaryNavy,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ClientStatusBadge(label: caseItem.status),
                  ],
                ),
                const SizedBox(height: 12),

                // Case Title
                Text(
                  caseItem.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark
                        ? ClientPortalColors.darkPrimaryText
                        : ClientPortalColors.primaryText,
                  ),
                ),
                const SizedBox(height: 10),

                // Case Details: Court, Type, Assigned Lawyer
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [
                    if (caseItem.courtName.isNotEmpty)
                      _InfoRow(
                        icon: Icons.account_balance_outlined,
                        text: caseItem.courtName,
                        isDark: isDark,
                      ),
                    if (caseItem.caseType.isNotEmpty)
                      _InfoRow(
                        icon: Icons.category_outlined,
                        text: caseItem.caseType,
                        isDark: isDark,
                      ),
                    if (caseItem.lawyerName.isNotEmpty)
                      _InfoRow(
                        icon: Icons.person_outline_rounded,
                        text: caseItem.lawyerName,
                        isDark: isDark,
                      ),
                  ],
                ),

                if (nextHearing != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ClientPortalColors.warning.withValues(
                        alpha: isDark ? 0.15 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ClientPortalColors.warning.withValues(
                          alpha: isDark ? 0.3 : 0.2,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_outlined,
                          size: 14,
                          color: ClientPortalColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Next Hearing: ${nextHearing!.title} (${nextHearing!.date})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: ClientPortalColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark
              ? ClientPortalColors.darkSecondaryText
              : ClientPortalColors.secondaryText,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? ClientPortalColors.darkSecondaryText
                : ClientPortalColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
