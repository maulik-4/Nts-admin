import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../data/models/whatsapp_template_model.dart';
import '../../data/repositories/whatsapp_repository.dart';
import 'communication_preference_dialog.dart';

class WhatsAppComposerModal extends ConsumerStatefulWidget {
  final int clientId;
  final String recipientName;
  final String recipientNumber;
  final int? caseId;
  final String? caseTitle;
  final String? defaultTemplate;

  const WhatsAppComposerModal({
    super.key,
    required this.clientId,
    required this.recipientName,
    required this.recipientNumber,
    this.caseId,
    this.caseTitle,
    this.defaultTemplate,
  });

  static Future<void> show(
    BuildContext context, {
    required int clientId,
    required String recipientName,
    required String recipientNumber,
    int? caseId,
    String? caseTitle,
    String? defaultTemplate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WhatsAppComposerModal(
        clientId: clientId,
        recipientName: recipientName,
        recipientNumber: recipientNumber,
        caseId: caseId,
        caseTitle: caseTitle,
        defaultTemplate: defaultTemplate,
      ),
    );
  }

  @override
  ConsumerState<WhatsAppComposerModal> createState() =>
      _WhatsAppComposerModalState();
}

class _WhatsAppComposerModalState extends ConsumerState<WhatsAppComposerModal> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final Map<String, TextEditingController> _paramControllers = {};

  List<WhatsAppTemplate> _templates = [];
  String _selectedTemplate = 'hearing_reminder';
  bool _isLoadingTemplates = true;
  bool _isSending = false;
  String? _errorMessage;
  bool _showOptInPrompt = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.recipientNumber;
    _nameController.text = widget.recipientName;
    if (widget.defaultTemplate != null) {
      _selectedTemplate = widget.defaultTemplate!;
    }
    _fetchTemplates();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    for (var c in _paramControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchTemplates() async {
    try {
      final repo = ref.read(whatsappRepositoryProvider);
      final list = await repo.getTemplates();
      if (mounted) {
        setState(() {
          _templates = list;
          _isLoadingTemplates = false;
          _initParamControllers();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingTemplates = false;
          _initParamControllers();
        });
      }
    }
  }

  void _initParamControllers() {
    final currentTpl = _templates.firstWhere(
      (t) => t.name == _selectedTemplate,
      orElse: () => WhatsAppTemplate(
        name: _selectedTemplate,
        label: 'Message',
        params: [
          'client_name',
          'case_title',
          'hearing_date',
          'hearing_time',
          'court_name',
        ],
      ),
    );

    for (var param in currentTpl.params) {
      if (!_paramControllers.containsKey(param)) {
        String initialVal = '';
        if (param == 'client_name') initialVal = widget.recipientName;
        if (param == 'case_title' && widget.caseTitle != null) {
          initialVal = widget.caseTitle!;
        }
        _paramControllers[param] = TextEditingController(text: initialVal);
      }
    }
  }

  String _formatParamLabel(String param) {
    return param
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ');
  }

  String _buildLivePreview() {
    final name =
        _paramControllers['client_name']?.text.trim() ?? widget.recipientName;
    final caseTitle =
        _paramControllers['case_title']?.text.trim() ??
        (widget.caseTitle ?? 'Your Legal Case');

    switch (_selectedTemplate) {
      case 'hearing_reminder':
        final date =
            _paramControllers['hearing_date']?.text.trim() ?? '[Hearing Date]';
        final time =
            _paramControllers['hearing_time']?.text.trim() ?? '[Hearing Time]';
        final court =
            _paramControllers['court_name']?.text.trim() ?? '[Court Name]';
        return '📋 *Hearing Reminder*\n\nDear $name,\n\nThis is a reminder regarding your upcoming court hearing for *$caseTitle*.\n\n📅 Date: $date\n⏰ Time: $time\n🏛 Court: $court\n\nPlease ensure all documents are ready.';
      case 'document_shared':
        final doc =
            _paramControllers['document_title']?.text.trim() ??
            '[Document Title]';
        return '📄 *New Document Shared*\n\nDear $name,\n\nA new legal document (*$doc*) has been shared for *$caseTitle*.\n\nYou can review it securely in your Client Portal.';
      case 'case_update':
        final msg =
            _paramControllers['update_message']?.text.trim() ??
            '[Update Details]';
        return '⚖️ *Case Update*\n\nDear $name,\n\nRegarding *$caseTitle*:\n\n$msg\n\nContact counsel with questions.';
      case 'payment_reminder':
        final amt = _paramControllers['amount']?.text.trim() ?? '₹0.00';
        final due = _paramControllers['due_date']?.text.trim() ?? '[Due Date]';
        return '💳 *Payment Reminder*\n\nDear $name,\n\nInvoice for *$caseTitle* of *$amt* is due on *$due*.\n\nKindly process at your convenience.';
      default:
        final msg = _paramControllers['message']?.text.trim() ?? '';
        return '✉️ *Message from Counsel*\n\nDear $name,\n\n$msg';
    }
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
      _showOptInPrompt = false;
    });

    try {
      final repo = ref.read(whatsappRepositoryProvider);
      final params = <String, dynamic>{};
      for (var entry in _paramControllers.entries) {
        params[entry.key] = entry.value.text.trim();
      }

      final result = await repo.sendMessage(
        recipientNumber: _phoneController.text.trim(),
        recipientName: _nameController.text.trim(),
        template: _selectedTemplate,
        templateParams: params,
        clientId: widget.clientId,
        caseId: widget.caseId,
      );

      if (!mounted) return;

      if (result.chatUrl != null && result.chatUrl!.isNotEmpty) {
        // Fallback to click-to-chat
        final uri = Uri.parse(result.chatUrl!);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp launched with composed message'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp message dispatched via platform gateway'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 403) {
        setState(() {
          _errorMessage = e.message;
          _showOptInPrompt = true;
        });
      } else {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Failed to send WhatsApp message.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_rounded,
                        color: Color(0xFF25D366),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Send WhatsApp Reminder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Recipient: ${widget.recipientName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Body
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: LexColors.errorLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: LexColors.error.withAlpha(50),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: LexColors.error,
                                ),
                              ),
                              if (_showOptInPrompt) ...[
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.settings_outlined,
                                    size: 14,
                                  ),
                                  label: const Text(
                                    'Update Consent Preferences',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: LexColors.error,
                                    side: const BorderSide(
                                      color: LexColors.error,
                                    ),
                                  ),
                                  onPressed: () {
                                    CommunicationPreferenceDialog.show(
                                      context,
                                      clientId: widget.clientId,
                                      clientName: widget.recipientName,
                                      phoneNumber: widget.recipientNumber,
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Phone Number
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'WhatsApp Phone Number',
                          hintText: '+919876543210',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Template Picker
                      const Text(
                        'Message Template',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTemplate,
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          suffixIcon: _isLoadingTemplates
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'hearing_reminder',
                            child: Text('Hearing Reminder'),
                          ),
                          DropdownMenuItem(
                            value: 'document_shared',
                            child: Text('Document Shared Notice'),
                          ),
                          DropdownMenuItem(
                            value: 'case_update',
                            child: Text('Case Status Update'),
                          ),
                          DropdownMenuItem(
                            value: 'payment_reminder',
                            child: Text('Payment Due Reminder'),
                          ),
                          DropdownMenuItem(
                            value: 'general_message',
                            child: Text('General Notification'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedTemplate = val;
                              _initParamControllers();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 18),

                      // Dynamic Parameters
                      const Text(
                        'Template Variables',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),

                      ..._paramControllers.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              labelText: _formatParamLabel(entry.key),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      // Live Preview Box
                      Row(
                        children: [
                          const Icon(
                            Icons.remove_red_eye_outlined,
                            size: 16,
                            color: Color(0xFF25D366),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Live WhatsApp Preview',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFDCF8C6).withAlpha(60),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF25D366).withAlpha(60),
                          ),
                        ),
                        child: Text(
                          _buildLivePreview(),
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: isDark
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Send Button
                      LexButton(
                        label: _isSending
                            ? 'Sending WhatsApp...'
                            : 'Dispatch via WhatsApp',
                        icon: Icons.send_rounded,
                        onPressed: _isSending ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
