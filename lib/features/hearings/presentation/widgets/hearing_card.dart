import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
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
    final dayStr = parsedDate != null ? DateFormat('d').format(parsedDate) : '';
    final monthStr = parsedDate != null
        ? DateFormat('MMM').format(parsedDate).toUpperCase()
        : '';
    final weekdayStr = parsedDate != null
        ? DateFormat('EEE').format(parsedDate)
        : '';

    return LexCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Block
          Container(
            width: 54,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? LexColors.surfaceDark
                  : const Color(0xFFFEF3C7).withAlpha(120),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? LexColors.borderDark
                    : LexColors.accentBronze.withAlpha(60),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  monthStr,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: LexColors.accentBronze,
                  ),
                ),
                Text(
                  dayStr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : LexColors.slatePrimary,
                  ),
                ),
                Text(
                  weekdayStr,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? LexColors.textSecondaryDark
                        : LexColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Hearing Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hearing.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : LexColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                if (caseTitle != null && caseTitle!.isNotEmpty) ...[
                  Text(
                    'Case: $caseTitle',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: LexColors.accentBronze,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 13,
                      color: isDark
                          ? LexColors.textSecondaryDark
                          : LexColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hearing.startTime != null
                          ? '${hearing.startTime}${hearing.endTime != null ? " - ${hearing.endTime}" : ""}'
                          : 'Time not specified',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? LexColors.textSecondaryDark
                            : LexColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_outlined,
                      size: 13,
                      color: isDark
                          ? LexColors.textSecondaryDark
                          : LexColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hearing.courtName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? LexColors.textMutedDark
                              : LexColors.textMutedLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: LexColors.textSecondaryLight,
          ),
        ],
      ),
    );
  }
}
