import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/lex_card.dart';
import '../../data/models/client_dashboard_model.dart';

class NextHearingCard extends StatelessWidget {
  final HearingItem hearing;

  const NextHearingCard({super.key, required this.hearing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    DateTime? hearingDate;
    try {
      hearingDate = DateTime.parse(hearing.date);
    } catch (_) {}

    final formattedDate = hearingDate != null
        ? DateFormat('EEEE, MMMM d, yyyy').format(hearingDate)
        : hearing.date;

    String daysCountdown = '';
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
      } else if (difference == 1) {
        daysCountdown = 'TOMORROW';
      } else if (difference > 1) {
        daysCountdown = 'IN $difference DAYS';
      } else {
        daysCountdown = 'PAST';
      }
    }

    return LexCard(
      borderRadius: 18,
      leftAccentColor: const Color(0xFFD97706), // Legal Amber Gold
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.event_available_rounded,
                      size: 14,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'NEXT COURT HEARING',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (daysCountdown.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    daysCountdown,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Hearing Title
          Text(
            hearing.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),

          // Case Title & Number
          Text(
            '${hearing.caseTitle} (${hearing.caseNumber})',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(height: 24),

          // Date & Time
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (hearing.startTime != null &&
                  hearing.startTime!.isNotEmpty) ...[
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  hearing.startTime!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Court & Judge
          Row(
            children: [
              const Icon(
                Icons.account_balance_rounded,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${hearing.courtName} • ${hearing.judgeName}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),

          if (hearing.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hearing.notes,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
