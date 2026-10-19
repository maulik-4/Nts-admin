import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../data/models/support_ticket.dart';
import '../../data/repositories/support_repository.dart';
import '../providers/support_notifier.dart';

class SupportTicketDetailScreen extends ConsumerStatefulWidget {
  final int ticketId;

  const SupportTicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<SupportTicketDetailScreen> createState() =>
      _SupportTicketDetailScreenState();
}

class _SupportTicketDetailScreenState
    extends ConsumerState<SupportTicketDetailScreen> {
  final _replyCtrl = TextEditingController();
  bool _isReplying = false;
  bool _isResolving = false;

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isReplying = true);
    try {
      await ref
          .read(supportRepositoryProvider)
          .replyTicket(widget.ticketId, text);
      _replyCtrl.clear();
      ref.invalidate(supportDetailProvider(widget.ticketId));
      if (mounted) {
        AppAlerts.showSuccess(context, 'Reply posted successfully');
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Failed to post reply: $e');
      }
    } finally {
      if (mounted) setState(() => _isReplying = false);
    }
  }

  Future<void> _resolve() async {
    setState(() => _isResolving = true);
    try {
      await ref
          .read(supportNotifierProvider.notifier)
          .resolveTicket(widget.ticketId);
      ref.invalidate(supportDetailProvider(widget.ticketId));
      ref.invalidate(supportStatsProvider);
      if (mounted) {
        AppAlerts.showSuccess(context, 'Ticket marked as resolved');
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Failed to resolve ticket: $e');
      }
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(supportDetailProvider(widget.ticketId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? LexColors.canvasDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Ticket #${widget.ticketId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.invalidate(supportDetailProvider(widget.ticketId)),
          ),
        ],
      ),
      body: ticketAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ShimmerBox(
              width: double.infinity,
              height: 180,
              borderRadius: BorderRadius.circular(18),
            ),
            const SizedBox(height: 16),
            ShimmerBox(
              width: 140,
              height: 24,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 12),
            ShimmerBox(
              width: double.infinity,
              height: 80,
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: LexColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  'Error loading ticket: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(supportDetailProvider(widget.ticketId)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LexColors.slatePrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (ticket) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header card with badges
                      LexCard(
                        borderRadius: 18,
                        leftAccentColor: ticket.statusColor,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white10
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    ticket.ticketNumber,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white70
                                          : LexColors.slatePrimary,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ticket.statusColor.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: ticket.statusColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        ticket.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: ticket.statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ticket.priorityColor.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    ticket.priority.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: ticket.priorityColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              ticket.subject,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ticket.description,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: isDark
                                    ? LexColors.textSecondaryDark
                                    : LexColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Divider(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              runSpacing: 6,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.category_outlined,
                                      size: 13,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Category: ${ticket.category.toUpperCase()}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                if (ticket.createdAt != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 13,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Opened: ${DateFormat.yMMMd().format(ticket.createdAt!)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Resolve action button
                      if (!ticket.isResolved)
                        SizedBox(
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: _isResolving ? null : _resolve,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: LexColors.success),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.check_circle_outline_rounded,
                              color: LexColors.success,
                            ),
                            label: _isResolving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: LexColors.success,
                                    ),
                                  )
                                : const Text(
                                    'Mark Ticket as Resolved',
                                    style: TextStyle(
                                      color: LexColors.success,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: LexColors.slatePrimary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.forum_outlined,
                              size: 16,
                              color: LexColors.slatePrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Discussion & Replies',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (ticket.replies.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No replies yet. Our support team will respond shortly.',
                              style: TextStyle(
                                color: isDark
                                    ? LexColors.textSecondaryDark
                                    : LexColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        )
                      else
                        ...ticket.replies.map(
                          (reply) => _buildReplyCard(reply, isDark),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom Reply Box
              if (!ticket.isResolved)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? LexColors.surfaceDark : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: LexTextField(
                            controller: _replyCtrl,
                            hintText: 'Type your reply...',
                            prefixIcon: Icons.edit_note_rounded,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendReply(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: LexColors.slatePrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: _isReplying ? null : _sendReply,
                            icon: _isReplying
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReplyCard(TicketReply reply, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: LexCard(
        borderRadius: 16,
        leftAccentColor: reply.isStaffReply ? Colors.blue : null,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: reply.isStaffReply
                      ? Colors.blue
                      : LexColors.slatePrimary,
                  child: Text(
                    reply.authorName.isNotEmpty
                        ? reply.authorName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  reply.authorName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (reply.isStaffReply) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'STAFF',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (reply.createdAt != null)
                  Text(
                    DateFormat.MMMd().add_jm().format(reply.createdAt!),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reply.message,
              style: const TextStyle(fontSize: 14, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}
