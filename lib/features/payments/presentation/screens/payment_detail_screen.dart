import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../providers/payments_notifier.dart';

class PaymentDetailScreen extends ConsumerStatefulWidget {
  final int paymentId;

  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  ConsumerState<PaymentDetailScreen> createState() =>
      _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends ConsumerState<PaymentDetailScreen> {
  bool _isSendingEmail = false;
  bool _isSendingWhatsapp = false;

  Future<void> _handleEmailReceipt() async {
    setState(() => _isSendingEmail = true);
    try {
      final msg = await ref
          .read(paymentsNotifierProvider.notifier)
          .notifyEmail(widget.paymentId);
      if (mounted) {
        AppAlerts.showSuccess(context, msg);
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Failed to send email invoice: $e');
      }
    } finally {
      if (mounted) setState(() => _isSendingEmail = false);
    }
  }

  Future<void> _handleWhatsappReceipt() async {
    setState(() => _isSendingWhatsapp = true);
    try {
      final msg = await ref
          .read(paymentsNotifierProvider.notifier)
          .notifyWhatsapp(widget.paymentId);
      if (mounted) {
        AppAlerts.showSuccess(context, msg);
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Failed to send WhatsApp receipt: $e');
      }
    } finally {
      if (mounted) setState(() => _isSendingWhatsapp = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment Record?'),
        content: const Text(
          'Are you sure you want to delete this payment record? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ref
          .read(paymentsNotifierProvider.notifier)
          .deletePayment(widget.paymentId);
      if (mounted) {
        AppAlerts.showSuccess(context, 'Payment record deleted successfully.');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Failed to delete payment: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentAsync = ref.watch(paymentDetailProvider(widget.paymentId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Receipt',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
            tooltip: 'Delete Payment',
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: paymentAsync.when(
        data: (payment) {
          final dateFormat = DateFormat('MMMM d, yyyy, h:mm a');
          final formattedAmount =
              '₹${double.tryParse(payment.amount)?.toStringAsFixed(2) ?? payment.amount}';

          final accentColor = payment.isPaid
              ? const Color(0xFF10B981)
              : const Color(0xFFF59E0B);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main Receipt Hero Card
                LexCard(
                  borderRadius: 20,
                  leftAccentColor: accentColor,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: payment.isPaid
                              ? const Color(0xFF10B981).withAlpha(25)
                              : const Color(0xFFF59E0B).withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          payment.isPaid
                              ? Icons.check_circle_rounded
                              : Icons.hourglass_top_rounded,
                          color: payment.isPaid
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        formattedAmount,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      StatusBadge(
                        status: payment.status.displayName,
                        showDot: true,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Receipt Reference #${payment.id}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Transaction Information Card
                LexCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Transaction Details',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        'Client',
                        payment.clientName ?? 'General Client',
                        Icons.person_outline_rounded,
                      ),
                      if (payment.caseTitle != null &&
                          payment.caseTitle!.isNotEmpty) ...[
                        const Divider(height: 18),
                        _buildDetailRow(
                          context,
                          'Associated Case',
                          payment.caseTitle!,
                          Icons.folder_open_rounded,
                        ),
                      ],
                      const Divider(height: 18),
                      _buildDetailRow(
                        context,
                        'Payment Method',
                        payment.paymentMethodDisplay ??
                            payment.paymentMethod.displayName,
                        Icons.payment_rounded,
                      ),
                      const Divider(height: 18),
                      _buildDetailRow(
                        context,
                        'Payment Date',
                        payment.paymentDate != null
                            ? dateFormat.format(payment.paymentDate!.toLocal())
                            : (payment.createdAt != null
                                ? dateFormat.format(payment.createdAt!.toLocal())
                                : 'Not recorded'),
                        Icons.calendar_today_outlined,
                      ),
                      const Divider(height: 18),
                      _buildDetailRow(
                        context,
                        'Firm ID',
                        '#${payment.firm}',
                        Icons.business_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Receipt Dispatch Actions
                Text(
                  'CLIENT COMMUNICATIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    icon: _isSendingEmail
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.email_outlined, size: 18),
                    label: const Text(
                      'Email Receipt to Client',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: _isSendingEmail ? null : _handleEmailReceipt,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    icon: _isSendingWhatsapp
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const Text(
                      'Send Receipt via WhatsApp',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: _isSendingWhatsapp ? null : _handleWhatsappReceipt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F1F38),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SkeletonLoader(height: 180, borderRadius: 20),
              SizedBox(height: 16),
              SkeletonLoader(height: 160, borderRadius: 18),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: ErrorStateWidget(
            message: 'Unable to load payment details: $err',
            onRetry: () =>
                ref.invalidate(paymentDetailProvider(widget.paymentId)),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
