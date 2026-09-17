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
                        color: isDark
                            ? LexColors.textPrimaryDark
                            : LexColors.slatePrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (payment.clientName != null &&
                        payment.clientName!.isNotEmpty)
                      Text(
                        payment.clientName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? LexColors.textSecondaryDark
                              : LexColors.textPrimaryLight,
                        ),
                      )
                    else
                      Text(
                        'General Client Payment',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? LexColors.textSecondaryDark
                              : LexColors.textSecondaryLight,
                        ),
                      ),
                  ],
                ),
              ),
              StatusBadge(status: payment.status.displayName),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              // Payment Method Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _methodIcon(payment.paymentMethod),
                      size: 11,
                      color: isDark
                          ? LexColors.accentGold
                          : LexColors.slatePrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      payment.paymentMethodDisplay ??
                          payment.paymentMethod.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? LexColors.accentGold
                            : LexColors.slatePrimary,
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
                  Icons.folder_outlined,
                  size: 13,
                  color: isDark ? LexColors.accentGold : LexColors.slateLight,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    payment.caseTitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? LexColors.textSecondaryDark
                          : LexColors.textSecondaryLight,
                    ),
                  ),
                ),
              ] else
                const Spacer(),

              // Date
              if (dateStr.isNotEmpty)
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? LexColors.textSecondaryDark
                        : LexColors.textSecondaryLight,
                  ),
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
