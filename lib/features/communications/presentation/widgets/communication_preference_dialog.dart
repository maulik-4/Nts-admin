import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../data/models/communication_preference_model.dart';
import '../../data/repositories/whatsapp_repository.dart';

class CommunicationPreferenceDialog extends ConsumerStatefulWidget {
  final int clientId;
  final String clientName;
  final String? phoneNumber;

  const CommunicationPreferenceDialog({
    super.key,
    required this.clientId,
    required this.clientName,
    this.phoneNumber,
  });

  static Future<void> show(
    BuildContext context, {
    required int clientId,
    required String clientName,
    String? phoneNumber,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CommunicationPreferenceDialog(
        clientId: clientId,
        clientName: clientName,
        phoneNumber: phoneNumber,
      ),
    );
  }

  @override
  ConsumerState<CommunicationPreferenceDialog> createState() =>
      _CommunicationPreferenceDialogState();
}

class _CommunicationPreferenceDialogState
    extends ConsumerState<CommunicationPreferenceDialog> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _whatsappConsent = false;
  String _preferredChannel = 'both';
  final _phoneController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber ?? '';
    _fetchPreferences();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchPreferences() async {
    try {
      final repo = ref.read(whatsappRepositoryProvider);
      final pref = await repo.getPreferences(widget.clientId);
      if (mounted) {
        setState(() {
          _whatsappConsent = pref.whatsappConsent;
          _preferredChannel = pref.preferredChannel;
          if (pref.whatsappNumber != null && pref.whatsappNumber!.isNotEmpty) {
            _phoneController.text = pref.whatsappNumber!;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(whatsappRepositoryProvider);
      await repo.updatePreferences(
        widget.clientId,
        CommunicationPreference(
          preferredChannel: _preferredChannel,
          whatsappConsent: _whatsappConsent,
          whatsappNumber: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client communication preferences updated'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Failed to update preferences.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isLoading
              ? const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.chat_outlined,
                          color: Color(0xFF25D366),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Preferences: ${widget.clientName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: LexColors.errorLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: LexColors.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // WhatsApp Consent Toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'WhatsApp Communication Consent',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Client has explicitly consented to receiving hearing notifications via WhatsApp.',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _whatsappConsent,
                      activeThumbColor: const Color(0xFF25D366),
                      onChanged: (val) =>
                          setState(() => _whatsappConsent = val),
                    ),
                    const SizedBox(height: 12),

                    // WhatsApp Dedicated Phone
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp Phone Number',
                        hintText: '+919876543210',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Channel Preference
                    const Text(
                      'Preferred Notification Channel',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _preferredChannel,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'both',
                          child: Text('Both Email and WhatsApp'),
                        ),
                        DropdownMenuItem(
                          value: 'whatsapp',
                          child: Text('WhatsApp Only'),
                        ),
                        DropdownMenuItem(
                          value: 'email',
                          child: Text('Email Only'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _preferredChannel = val);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    LexButton(
                      label: _isSaving ? 'Saving...' : 'Save Preferences',
                      onPressed: _isSaving ? null : _savePreferences,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
