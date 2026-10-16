import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/hearing_model.dart';

class HearingCard extends StatelessWidget {
  final Hearing hearing;
  final String? caseTitle;
  final VoidCallback onTap;

  const HearingCard({
    super.key,
    required this.hearing,
    this.caseTitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final parsedDate = hearing.parsedDate;
    final dateFormatted = parsedDate != null
        ? DateFormat('EEE, MMM d, yyyy').format(parsedDate)
        : hearing.date;

    return LexCard(
      onTap: onTap,
      borderRadius: 16,
      leftAccentColor: const Color(0xFF2563EB),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category + Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFDBEAFE),
                  ),
                ),
                child: Text(
                  hearing.hearingType.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const Spacer(),
              StatusBadge(status: hearing.status, showDot: true),
            ],
          ),
          const SizedBox(height: 10),

          // Hearing Title
          Text(
            hearing.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: isDark ? LexColors.textPrimaryDark : const Color(0xFF0F172A),
            ),
          ),

          // Case Association
          if (caseTitle != null && caseTitle!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 13,
                    color: isDark ? LexColors.accentGold : const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      caseTitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 10),

          // Schedule Details (Date, Time, Venue, Judge)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time & Date Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dateFormatted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Time
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            hearing.startTime != null
                                ? '${hearing.startTime}${hearing.endTime != null ? " - ${hearing.endTime}" : ""}'
                                : 'Time not specified',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Venue & Judge Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Court Venue
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_outlined,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            hearing.courtName.isNotEmpty ? hearing.courtName : 'Courtroom',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Judge
                    if (hearing.judgeName != null && hearing.judgeName!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.gavel_rounded,
                            size: 13,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              hearing.judgeName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bottom Action Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'View Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
