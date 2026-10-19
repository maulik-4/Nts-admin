import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/client_portal_theme.dart';
import '../../data/models/client_dashboard_model.dart';
import 'client_status_badge.dart';

class ClientHearingCard extends StatelessWidget {
  final HearingItem hearing;
  final VoidCallback onTap;

  const ClientHearingCard({
    super.key,
    required this.hearing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(hearing.date);
    } catch (_) {}

    final formattedDate = parsedDate != null
        ? DateFormat('EEE, MMM d, yyyy').format(parsedDate)
        : hearing.date;

    final isUpcoming = hearing.isUpcoming;

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ClientPortalDimensions.cardRadius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subtle accent bar on left for upcoming hearings
              if (isUpcoming)
                Container(width: 4, color: ClientPortalColors.warning),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Date and Status Badge
                          Row(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: isUpcoming
                                        ? ClientPortalColors.warning
                                        : (isDark
                                              ? ClientPortalColors
                                                    .darkSecondaryText
                                              : ClientPortalColors
                                                    .secondaryText),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: isUpcoming
                                          ? ClientPortalColors.warning
                                          : (isDark
                                                ? ClientPortalColors
                                                      .darkSecondaryText
                                                : ClientPortalColors
                                                      .secondaryText),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              ClientStatusBadge(
                                label: isUpcoming ? 'Upcoming' : 'Past',
                                type: isUpcoming
                                    ? ClientStatusType.upcoming
                                    : ClientStatusType.closed,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Hearing Title
                          Text(
                            hearing.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: isDark
                                  ? ClientPortalColors.darkPrimaryText
                                  : ClientPortalColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Related Case Title and Case Number
                          Text(
                            hearing.caseNumber.isNotEmpty
                                ? '${hearing.caseTitle} (${hearing.caseNumber})'
                                : hearing.caseTitle,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: ClientPortalColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Metadata: Court, Judge, Time
                          Wrap(
                            spacing: 14,
                            runSpacing: 6,
                            children: [
                              if (hearing.startTime != null &&
                                  hearing.startTime!.isNotEmpty)
                                _MetaRow(
                                  icon: Icons.access_time_rounded,
                                  text: hearing.startTime!,
                                  isDark: isDark,
                                ),
                              if (hearing.courtName.isNotEmpty)
                                _MetaRow(
                                  icon: Icons.account_balance_outlined,
                                  text: hearing.courtName,
                                  isDark: isDark,
                                ),
                              if (hearing.judgeName.isNotEmpty)
                                _MetaRow(
                                  icon: Icons.gavel_outlined,
                                  text: hearing.judgeName,
                                  isDark: isDark,
                                ),
                            ],
                          ),

                          if (hearing.notes.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              hearing.notes,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? ClientPortalColors.darkSecondaryText
                                    : ClientPortalColors.secondaryText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _MetaRow({
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
          size: 13,
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
