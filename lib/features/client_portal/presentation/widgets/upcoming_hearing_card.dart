import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/client_portal_theme.dart';
import '../../data/models/client_dashboard_model.dart';

class UpcomingHearingCard extends StatelessWidget {
  final HearingItem? hearing;
  final VoidCallback? onTap;

  const UpcomingHearingCard({super.key, required this.hearing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (hearing == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? ClientPortalColors.darkCardBackground
              : ClientPortalColors.cardBackground,
          borderRadius: BorderRadius.circular(
            ClientPortalDimensions.cardRadius,
          ),
          border: Border.all(
            color: isDark
                ? ClientPortalColors.darkBorder
                : ClientPortalColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ClientPortalColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_outlined,
                color: ClientPortalColors.primaryBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Upcoming Hearings',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? ClientPortalColors.darkPrimaryText
                          : ClientPortalColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'You are all caught up. No court appearances are currently scheduled.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? ClientPortalColors.darkSecondaryText
                          : ClientPortalColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final item = hearing!;
    DateTime? hearingDate;
    try {
      hearingDate = DateTime.parse(item.date);
    } catch (_) {}

    final formattedDate = hearingDate != null
        ? DateFormat('EEEE, MMMM d, yyyy').format(hearingDate)
        : item.date;

    String daysCountdown = '';
    Color countdownBg = const Color(0xFFFEF3C7);
    Color countdownColor = ClientPortalColors.warning;

    if (hearingDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(
        hearingDate.year,
        hearingDate.month,
        hearingDate.day,
      );
      final difference = target.difference(today).inDays;

      if (difference == 0) {
        daysCountdown = 'TODAY';
        countdownBg = const Color(0xFFFEE2E2);
        countdownColor = ClientPortalColors.error;
      } else if (difference == 1) {
        daysCountdown = 'TOMORROW';
        countdownBg = const Color(0xFFFEF3C7);
        countdownColor = ClientPortalColors.warning;
      } else if (difference > 1) {
        daysCountdown = 'IN $difference DAYS';
        countdownBg = const Color(0xFFFEF3C7);
        countdownColor = ClientPortalColors.warning;
      } else {
        daysCountdown = 'PAST';
        countdownBg = const Color(0xFFE2E8F0);
        countdownColor = const Color(0xFF475569);
      }
    }

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
                .withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ClientPortalDimensions.cardRadius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Amber Accent Bar communicating urgency
              Container(width: 5, color: ClientPortalColors.warning),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Tag and Countdown Badge
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: ClientPortalColors.warning.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    ClientPortalDimensions.badgeRadius,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      size: 13,
                                      color: ClientPortalColors.warning,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'NEXT COURT HEARING',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                        color: ClientPortalColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (daysCountdown.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 3.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? countdownColor.withValues(alpha: 0.2)
                                        : countdownBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: countdownColor.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    daysCountdown,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                      color: countdownColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Hearing Title
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 18,
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
                            item.caseNumber.isNotEmpty
                                ? '${item.caseTitle} (${item.caseNumber})'
                                : item.caseTitle,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ClientPortalColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 14),

                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark
                                ? ClientPortalColors.darkBorder
                                : ClientPortalColors.border,
                          ),
                          const SizedBox(height: 14),

                          // Details: Date, Court, Reference
                          Wrap(
                            spacing: 16,
                            runSpacing: 10,
                            children: [
                              _DetailChip(
                                icon: Icons.event_rounded,
                                label: formattedDate,
                                isDark: isDark,
                              ),
                              if (item.startTime != null &&
                                  item.startTime!.isNotEmpty)
                                _DetailChip(
                                  icon: Icons.schedule_rounded,
                                  label: item.startTime!,
                                  isDark: isDark,
                                ),
                              if (item.courtName.isNotEmpty)
                                _DetailChip(
                                  icon: Icons.account_balance_rounded,
                                  label: item.judgeName.isNotEmpty
                                      ? '${item.courtName} • ${item.judgeName}'
                                      : item.courtName,
                                  isDark: isDark,
                                ),
                              if (item.caseNumber.isNotEmpty)
                                _DetailChip(
                                  icon: Icons.tag_rounded,
                                  label: item.caseNumber,
                                  isDark: isDark,
                                ),
                            ],
                          ),

                          if (item.notes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E2D4A)
                                          .withValues(alpha: 0.5)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark
                                      ? ClientPortalColors.darkBorder
                                      : ClientPortalColors.border,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    size: 14,
                                    color: ClientPortalColors.warning,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.notes,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.35,
                                        color: isDark
                                            ? ClientPortalColors
                                                  .darkSecondaryText
                                            : ClientPortalColors.secondaryText,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _DetailChip({
    required this.icon,
    required this.label,
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
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? ClientPortalColors.darkPrimaryText
                : ClientPortalColors.primaryText,
          ),
        ),
      ],
    );
  }
}
