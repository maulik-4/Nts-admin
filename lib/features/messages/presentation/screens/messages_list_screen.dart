import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
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
      backgroundColor: isDark ? LexColors.canvasDark : const Color(0xFFF8FAFC),
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
        backgroundColor: LexColors.slatePrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        icon: const Icon(Icons.send_rounded, size: 20),
        label: const Text(
          'Send Message',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: messagesAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (ctx, idx) => Align(
            alignment: idx.isEven ? Alignment.centerRight : Alignment.centerLeft,
            child: ShimmerBox(
              width: MediaQuery.of(context).size.width * 0.72,
              height: 80,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
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
                  'Error loading messages: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(messagesNotifierProvider.notifier)
                      .loadMessages(),
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
        data: (messages) {
          if (messages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: (isDark ? LexColors.surfaceDark : Colors.white),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.forum_outlined,
                        size: 54,
                        color: isDark
                            ? LexColors.textSecondaryDark
                            : LexColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No firm messages yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Send internal notes, legal updates, or messages to your colleagues.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark
                            ? LexColors.textSecondaryDark
                            : LexColors.textSecondaryLight,
                        fontSize: 14,
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
          borderRadius: 18,
          leftAccentColor: isMe ? null : LexColors.accentGold,
          backgroundColor: isMe
              ? (isDark ? const Color(0xFF1E293B) : const Color(0xFF0F1F38))
              : (isDark ? LexColors.surfaceDark : Colors.white),
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
                    isMe ? Icons.arrow_outward_rounded : Icons.south_west_rounded,
                    size: 13,
                    color: isMe ? Colors.white70 : LexColors.accentGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isMe ? 'You' : 'Colleague #${msg.senderId}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isMe
                          ? Colors.white
                          : (isDark ? Colors.white : LexColors.slatePrimary),
                    ),
                  ),
                  if (msg.createdAt != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      DateFormat.jm().format(msg.createdAt!),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white60 : Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                msg.content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: isMe ? Colors.white : null,
                ),
              ),
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
    if (text.isEmpty) {
      AppAlerts.showError(context, 'Please enter a message.');
      return;
    }
    if (_selectedRecipientId == null) {
      AppAlerts.showError(context, 'Please select a recipient.');
      return;
    }

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
        AppAlerts.showSuccess(context, 'Message sent successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Failed to send: $e');
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
        color: isDark ? LexColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: LexColors.accentGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: LexColors.accentGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INTERNAL DISPATCH',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: LexColors.accentGold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Send Firm Message',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Recipient dropdown
            teamAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(
                'Error loading team: $e',
                style: const TextStyle(color: LexColors.error),
              ),
              data: (members) {
                final potentialRecipients = members
                    .where((m) => m.id != currentUserId)
                    .toList();

                if (potentialRecipients.isEmpty) {
                  return const Text(
                    'No other team members available to message.',
                    style: TextStyle(color: Colors.grey),
                  );
                }

                _selectedRecipientId ??= potentialRecipients.first.id;

                return DropdownButtonFormField<int>(
                  initialValue: _selectedRecipientId,
                  decoration: InputDecoration(
                    labelText: 'Select Recipient',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: isDark
                        ? LexColors.cardBackgroundDark
                        : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
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
              hintText: 'Type internal communication or notes...',
              maxLines: 4,
              prefixIcon: Icons.edit_note_rounded,
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LexColors.slatePrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
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
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Send Message',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
