import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../providers/admin_gateway_notifier.dart';

class AdminTransactionsTab extends ConsumerWidget {
  const AdminTransactionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(adminTransactionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return txAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No Billing Transactions Recorded',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'All completed and pending firm subscription orders will be audited here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(adminTransactionsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final dateFormatted = tx.createdAt != null
                  ? DateFormat('MMM d, yyyy • h:mm a').format(tx.createdAt!)
                  : 'N/A';

              return LexCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tx.firmName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        StatusBadge(status: tx.status, showDot: true),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plan: ${tx.planName}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              '₹${tx.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              dateFormatted,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order ID: ${tx.orderId}${tx.paymentId != null ? ' • Payment: ${tx.paymentId}' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => ErrorStateWidget(
        message: err.toString(),
        onRetry: () => ref.refresh(adminTransactionsProvider),
      ),
    );
  }
}
