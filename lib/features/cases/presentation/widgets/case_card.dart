import 'package:flutter/material.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/case_model.dart';

class CaseCard extends StatelessWidget {
  final Case caseItem;
  final VoidCallback onTap;

  const CaseCard({super.key, required this.caseItem, required this.onTap});

  Color _getStatusAccentColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'active':
        return const Color(0xFF10B981);
      case 'closed':
      case 'resolved':
      case 'archived':
        return const Color(0xFF94A3B8);
      case 'pending':
      case 'in_progress':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = _getStatusAccentColor(caseItem.status);

    return LexCard(
      onTap: onTap,
      leftAccentColor: accentColor,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Case Number Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  caseItem.caseNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: isDark
                        ? LexColors.accentGold
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Category Badge
              if (caseItem.caseType.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A2234)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E3A8A).withAlpha(100)
                          : const Color(0xFFDBEAFE),
                    ),
                  ),
                  child: Text(
                    caseItem.caseType.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),

              const Spacer(),
              StatusBadge(status: caseItem.status, showDot: true),
            ],
          ),
          const SizedBox(height: 10),

          // Title & Chevron
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  caseItem.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Client row
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 15,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  caseItem.clientName?.isNotEmpty == true
                      ? caseItem.clientName!
                      : 'Client #${caseItem.client}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Court row
          Row(
            children: [
              Icon(
                Icons.balance_rounded,
                size: 14,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  caseItem.courtName.isNotEmpty
                      ? caseItem.courtName
                      : 'Court unspecified',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          // Upcoming hearing pill if available
          if (caseItem.upcomingHearing != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2415)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF78350F)
                      : const Color(0xFFFDE68A),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_outlined,
                    size: 14,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Next Hearing: ${caseItem.upcomingHearing!.date}${caseItem.upcomingHearing!.startTime != null ? " at ${caseItem.upcomingHearing!.startTime}" : ""}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD97706),
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
