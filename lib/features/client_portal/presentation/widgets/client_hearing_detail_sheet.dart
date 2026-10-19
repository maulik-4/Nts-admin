import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/client_portal_theme.dart';
import '../../data/models/client_dashboard_model.dart';
import 'client_status_badge.dart';

class ClientHearingDetailSheet extends StatelessWidget {
  final HearingItem hearing;

  const ClientHearingDetailSheet({super.key, required this.hearing});

  static Future<void> show(
    BuildContext context, {
    required HearingItem hearing,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClientHearingDetailSheet(hearing: hearing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(hearing.date);
    } catch (_) {}

    final formattedDate = parsedDate != null
        ? DateFormat('EEEE, MMMM d, yyyy').format(parsedDate)
        : hearing.date;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? ClientPortalColors.darkPageBackground
            : ClientPortalColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark
                ? ClientPortalColors.darkBorder
                : ClientPortalColors.border,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title and Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hearing.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDark
                                ? ClientPortalColors.darkPrimaryText
                                : ClientPortalColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hearing.caseTitle,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ClientPortalColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ClientStatusBadge(
                    label: hearing.isUpcoming ? 'Upcoming' : 'Past',
                    type: hearing.isUpcoming
                        ? ClientStatusType.upcoming
                        : ClientStatusType.closed,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Details Grid
              _DetailItem(
                icon: Icons.calendar_today_rounded,
                label: 'Hearing Date',
                value: formattedDate,
                isDark: isDark,
              ),
              if (hearing.startTime != null &&
                  hearing.startTime!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _DetailItem(
                  icon: Icons.access_time_rounded,
                  label: 'Time',
                  value:
                      hearing.startTime! +
                      (hearing.endTime != null && hearing.endTime!.isNotEmpty
                          ? ' - ${hearing.endTime}'
                          : ''),
                  isDark: isDark,
                ),
              ],
              const SizedBox(height: 12),
              _DetailItem(
                icon: Icons.account_balance_rounded,
                label: 'Court',
                value: hearing.courtName,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _DetailItem(
                icon: Icons.gavel_rounded,
                label: 'Presiding Judge',
                value: hearing.judgeName,
                isDark: isDark,
              ),
              if (hearing.caseNumber.isNotEmpty) ...[
                const SizedBox(height: 12),
                _DetailItem(
                  icon: Icons.tag_rounded,
                  label: 'Case Number',
                  value: hearing.caseNumber,
                  isDark: isDark,
                ),
              ],

              if (hearing.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2D4A).withValues(alpha: 0.5)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? ClientPortalColors.darkBorder
                          : ClientPortalColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 15,
                            color: ClientPortalColors.warning,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Session Notes / Instructions',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ClientPortalColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hearing.notes,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: isDark
                              ? ClientPortalColors.darkPrimaryText
                              : ClientPortalColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: ClientPortalColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ClientPortalDimensions.buttonRadius,
                      ),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2D4A) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: ClientPortalColors.primaryBlue),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? ClientPortalColors.darkSecondaryText
                    : ClientPortalColors.secondaryText,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? ClientPortalColors.darkPrimaryText
                    : ClientPortalColors.primaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
