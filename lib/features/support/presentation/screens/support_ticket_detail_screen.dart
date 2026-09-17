import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reply: $e'),
            backgroundColor: LexColors.error,
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket marked as resolved'),
            backgroundColor: LexColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: LexColors.error,
          ),
        );
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
      appBar: AppBar(
        title: Text('Ticket #${widget.ticketId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.invalidate(supportDetailProvider(widget.ticketId)),
          ),
        ],
      ),
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error loading ticket: $err'),
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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  ticket.ticketNumber,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? LexColors.accentGold
                                        : LexColors.accentBronze,
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
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    ticket.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: ticket.statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              ticket.subject,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ticket.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? LexColors.textSecondaryDark
                                    : LexColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              runSpacing: 6,
                              children: [
                                Text(
                                  'Category: ${ticket.category}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Priority: ${ticket.priority}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (ticket.createdAt != null)
                                  Text(
                                    'Opened: ${DateFormat.yMMMd().format(ticket.createdAt!)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Resolve action button
                      if (!ticket.isResolved)
                        OutlinedButton.icon(
                          onPressed: _isResolving ? null : _resolve,
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: LexColors.success,
                          ),
                          label: _isResolving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Mark Ticket as Resolved'),
                        ),

                      const SizedBox(height: 20),
                      const Text(
                        'Discussion & Replies',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),

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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? LexColors.surfaceDark
                        : LexColors.canvasLight,
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? LexColors.borderDark
                            : LexColors.borderLight,
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
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendReply(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
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
                              : const Icon(Icons.send),
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
      margin: const EdgeInsets.only(bottom: 10),
      child: LexCard(
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
            Text(reply.message, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
