import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../team/presentation/providers/team_notifier.dart';
import '../../data/models/message_model.dart';
import '../providers/messages_notifier.dart';

class MessagesListScreen extends ConsumerWidget {
  const MessagesListScreen({super.key});

  void _showComposeDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _ComposeMessageSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firm Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(messagesNotifierProvider.notifier).loadMessages(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComposeDialog(context, ref),
        icon: const Icon(Icons.send_outlined),
        label: const Text('Send Message'),
      ),
      body: messagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: LexColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  'Error loading messages: $err',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(messagesNotifierProvider.notifier)
                      .loadMessages(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (messages) {
          if (messages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: isDark
                          ? LexColors.textSecondaryDark
                          : LexColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No firm messages yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Send internal notes, legal updates, or messages to your colleagues.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark
                            ? LexColors.textSecondaryDark
                            : LexColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final authState = ref.watch(authNotifierProvider);
          final currentUserId = authState.user?.id ?? 0;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) => _buildMessageBubble(
              context,
              messages[idx],
              currentUserId,
              isDark,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    MessageModel msg,
    int currentUserId,
    bool isDark,
  ) {
    final isMe = msg.senderId == currentUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: LexCard(
          backgroundColor: isMe
              ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF))
              : null,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMe ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isMe ? 'You' : 'Colleague #${msg.senderId}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (msg.createdAt != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      DateFormat.jm().format(msg.createdAt!),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(msg.content, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposeMessageSheet extends ConsumerStatefulWidget {
  const _ComposeMessageSheet();

  @override
  ConsumerState<_ComposeMessageSheet> createState() =>
      _ComposeMessageSheetState();
}

class _ComposeMessageSheetState extends ConsumerState<_ComposeMessageSheet> {
  final _contentCtrl = TextEditingController();
  int? _selectedRecipientId;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _contentCtrl.text.trim();
    if (text.isEmpty || _selectedRecipientId == null) return;

    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authNotifierProvider);
      final firmId = auth.user?.firmId ?? 15;
      final senderId = auth.user?.id ?? 10;

      await ref
          .read(messagesNotifierProvider.notifier)
          .sendMessage(
            content: text,
            firmId: firmId,
            senderId: senderId,
            receiverId: _selectedRecipientId!,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully!'),
            backgroundColor: LexColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamAsync = ref.watch(teamNotifierProvider);
    final auth = ref.watch(authNotifierProvider);
    final currentUserId = auth.user?.id ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? LexColors.surfaceDark : LexColors.canvasLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Send Firm Message',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            // Recipient dropdown
            teamAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading team: $e'),
              data: (members) {
                final potentialRecipients = members
                    .where((m) => m.id != currentUserId)
                    .toList();

                if (potentialRecipients.isEmpty) {
                  return const Text(
                    'No other team members available to message.',
                  );
                }

                _selectedRecipientId ??= potentialRecipients.first.id;

                return DropdownButtonFormField<int>(
                  initialValue: _selectedRecipientId,
                  decoration: const InputDecoration(
                    labelText: 'Select Recipient',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: potentialRecipients
                      .map(
                        (m) => DropdownMenuItem<int>(
                          value: m.id,
                          child: Text('${m.username} (${m.displayRole})'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedRecipientId = v);
                  },
                );
              },
            ),
            const SizedBox(height: 14),

            LexTextField(
              controller: _contentCtrl,
              label: 'Message Content *',
              hintText: 'Type your message...',
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isLoading ? null : _send,
              style: ElevatedButton.styleFrom(
                backgroundColor: LexColors.slatePrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}
