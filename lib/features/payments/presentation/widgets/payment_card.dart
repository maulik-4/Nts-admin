import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/payment_model.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;

  const PaymentCard({super.key, required this.payment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = payment.paymentDate != null
        ? DateFormat('MMM d, yyyy').format(payment.paymentDate!.toLocal())
        : (payment.createdAt != null
              ? DateFormat('MMM d, yyyy').format(payment.createdAt!.toLocal())
              : '');

    final formattedAmount =
        '₹${double.tryParse(payment.amount)?.toStringAsFixed(2) ?? payment.amount}';

    final accentColor = payment.isPaid
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);

    return LexCard(
      onTap: onTap,
      borderRadius: 16,
      leftAccentColor: accentColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedAmount,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      payment.clientName?.isNotEmpty == true
                          ? payment.clientName!
                          : 'General Client Payment',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                status: payment.status.displayName,
                showDot: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Payment Method Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _methodIcon(payment.paymentMethod),
                      size: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      payment.paymentMethodDisplay ??
                          payment.paymentMethod.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Associated Case
              if (payment.caseTitle != null &&
                  payment.caseTitle!.isNotEmpty) ...[
                Icon(
                  Icons.folder_open_rounded,
                  size: 13,
                  color: isDark ? LexColors.accentGold : const Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    payment.caseTitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ] else
                const Spacer(),

              // Date
              if (dateStr.isNotEmpty)
                Flexible(
                  child: Text(
                    dateStr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _methodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi:
        return Icons.qr_code_2_rounded;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_outlined;
      case PaymentMethod.card:
        return Icons.credit_card_outlined;
      case PaymentMethod.cash:
        return Icons.payments_outlined;
    }
  }
}
