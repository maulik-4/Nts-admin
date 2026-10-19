import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../documents/data/repositories/document_sharing_repository.dart';

class InviteClientDialog extends ConsumerStatefulWidget {
  final String? initialEmail;
  final String? initialName;

  const InviteClientDialog({super.key, this.initialEmail, this.initialName});

  static Future<void> show(
    BuildContext context, {
    String? initialEmail,
    String? initialName,
  }) {
    return showDialog(
      context: context,
      builder: (context) => InviteClientDialog(
        initialEmail: initialEmail,
        initialName: initialName,
      ),
    );
  }

  @override
  ConsumerState<InviteClientDialog> createState() => _InviteClientDialogState();
}

class _InviteClientDialogState extends ConsumerState<InviteClientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSending = false;
  String? _errorMessage;
  Map<String, dynamic>? _inviteResult;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(documentSharingRepositoryProvider);
      final result = await repo.inviteClient(
        email: _emailController.text.trim(),
        clientName: _nameController.text.trim(),
        message: _messageController.text,
      );

      setState(() => _inviteResult = result);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to generate invitation link.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _inviteResult != null
              ? _buildSuccessView(context, isDark)
              : _buildFormView(context, isDark),
        ),
      ),
    );
  }

  Widget _buildFormView(BuildContext context, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Invite Client to Portal',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Generate a secure single-use access link enabling your client to view court schedules and case documents.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: LexColors.errorLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: LexColors.error.withAlpha(50)),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 12, color: LexColors.error),
              ),
            ),
            const SizedBox(height: 14),
          ],

          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Client Full Name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Client name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Client Email',
              hintText: 'client@example.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Email is required';
              if (!val.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Welcome Message (Optional)',
              hintText: 'Welcome to our client portal...',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          LexButton(
            label: _isSending ? 'Sending Invitation...' : 'Send Portal Invite',
            icon: Icons.send_rounded,
            onPressed: _isSending ? null : _sendInvite,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, bool isDark) {
    final inviteUrl = _inviteResult?['invite_url']?.toString() ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF10B981),
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Client Invitation Generated!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'An invitation email has been sent. You can also copy the activation link below:',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 20),

        if (inviteUrl.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    inviteUrl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: 'Copy Link',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: inviteUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invitation link copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        LexButton(label: 'Done', onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}
