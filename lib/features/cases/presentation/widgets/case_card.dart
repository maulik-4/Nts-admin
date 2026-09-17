import 'package:flutter/material.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/case_model.dart';

class CaseCard extends StatelessWidget {
  final Case caseItem;
  final VoidCallback onTap;

  const CaseCard({super.key, required this.caseItem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LexCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? LexColors.surfaceDark
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? LexColors.borderDark
                              : LexColors.borderLight,
                        ),
                      ),
                      child: Text(
                        caseItem.caseNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.accentGold
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    if (caseItem.caseType.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          caseItem.caseType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? LexColors.textSecondaryDark
                                : LexColors.slateLight,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: caseItem.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            caseItem.title,
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
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 14,
                color: isDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  caseItem.clientName ?? 'Client #${caseItem.client}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? LexColors.textSecondaryDark
                        : LexColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.gavel_outlined,
                size: 14,
                color: isDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  caseItem.courtName,
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
          if (caseItem.upcomingHearing != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? LexColors.surfaceDark
                    : const Color(0xFFFEF3C7).withAlpha(120),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: LexColors.accentBronze.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_outlined,
                    size: 14,
                    color: LexColors.accentBronze,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Next Hearing: ${caseItem.upcomingHearing!.date}${caseItem.upcomingHearing!.startTime != null ? " at ${caseItem.upcomingHearing!.startTime}" : ""}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: LexColors.accentBronze,
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
