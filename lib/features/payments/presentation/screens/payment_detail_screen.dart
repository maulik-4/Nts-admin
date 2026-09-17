import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/lex_button.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: LexColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send email invoice: $e'),
            backgroundColor: LexColors.error,
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: LexColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send WhatsApp receipt: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingWhatsapp = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment Record'),
        content: const Text(
          'Are you sure you want to delete this payment record? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: LexColors.error),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment record deleted successfully.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete payment: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentAsync = ref.watch(paymentDetailProvider(widget.paymentId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: LexColors.error),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main Receipt Hero Card
                LexCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: payment.isPaid
                              ? LexColors.successLight
                              : LexColors.accentLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          payment.isPaid
                              ? Icons.check_circle_outline
                              : Icons.hourglass_top_outlined,
                          color: payment.isPaid
                              ? LexColors.success
                              : LexColors.warning,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        formattedAmount,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      StatusBadge(status: payment.status.displayName),
                      const SizedBox(height: 16),
                      Text(
                        'Receipt Reference #${payment.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? LexColors.textSecondaryDark
                              : LexColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Transaction Information Card
                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Details',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? LexColors.textPrimaryDark
                              : LexColors.slatePrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        'Client',
                        payment.clientName ?? 'General Client',
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      if (payment.caseTitle != null &&
                          payment.caseTitle!.isNotEmpty) ...[
                        _buildDetailRow(
                          context,
                          'Associated Case',
                          payment.caseTitle!,
                          Icons.folder_outlined,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _buildDetailRow(
                        context,
                        'Payment Method',
                        payment.paymentMethodDisplay ??
                            payment.paymentMethod.displayName,
                        Icons.payment_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Payment Date',
                        payment.paymentDate != null
                            ? dateFormat.format(payment.paymentDate!.toLocal())
                            : (payment.createdAt != null
                                  ? dateFormat.format(
                                      payment.createdAt!.toLocal(),
                                    )
                                  : 'Not recorded'),
                        Icons.calendar_today_outlined,
                      ),
                      const SizedBox(height: 12),
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
                  'Client Communications',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : LexColors.slatePrimary,
                  ),
                ),
                const SizedBox(height: 12),

                LexButton(
                  label: 'Email Receipt to Client',
                  icon: Icons.email_outlined,
                  variant: LexButtonVariant.outline,
                  isLoading: _isSendingEmail,
                  onPressed: _isSendingEmail ? null : _handleEmailReceipt,
                ),
                const SizedBox(height: 10),

                LexButton(
                  label: 'Send Receipt via WhatsApp',
                  icon: Icons.chat_outlined,
                  variant: LexButtonVariant.secondary,
                  isLoading: _isSendingWhatsapp,
                  onPressed: _isSendingWhatsapp ? null : _handleWhatsappReceipt,
                ),
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SkeletonLoader(height: 180),
              SizedBox(height: 16),
              SkeletonLoader(height: 160),
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
          color: isDark
              ? LexColors.textSecondaryDark
              : LexColors.textSecondaryLight,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? LexColors.textSecondaryDark
                : LexColors.textSecondaryLight,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? LexColors.textPrimaryDark
                  : LexColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }
}
