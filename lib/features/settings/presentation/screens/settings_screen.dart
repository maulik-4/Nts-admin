import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../notifications/data/repositories/notifications_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = true;
  bool _taskAssignedEmail = true;
  bool _hearingReminderEmail = true;
  bool _paymentReceiptEmail = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      final prefs = await repo.getPreferences();
      setState(() {
        _taskAssignedEmail = prefs.emailPreferences['task_assigned'] ?? true;
        _hearingReminderEmail =
            prefs.emailPreferences['hearing_reminder'] ?? true;
        _paymentReceiptEmail =
            prefs.emailPreferences['payment_receipt'] ?? true;
      });
    } catch (_) {
      // Keep defaults
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePref(String key, bool value) async {
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      await repo.updatePreferences({
        'email': {key: value},
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update setting: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Preferences')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Email & Alert Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : LexColors.slatePrimary,
                  ),
                ),
                const SizedBox(height: 12),

                LexCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Task Assignment Alerts'),
                        subtitle: const Text(
                          'Notify when a legal task is assigned to you',
                        ),
                        value: _taskAssignedEmail,
                        onChanged: (v) {
                          setState(() => _taskAssignedEmail = v);
                          _updatePref('task_assigned', v);
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Court Hearing Reminders'),
                        subtitle: const Text(
                          'Receive advance alert for scheduled hearings',
                        ),
                        value: _hearingReminderEmail,
                        onChanged: (v) {
                          setState(() => _hearingReminderEmail = v);
                          _updatePref('hearing_reminder', v);
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Payment Receipts & Invoices'),
                        subtitle: const Text(
                          'Get email copy for recorded fee payments',
                        ),
                        value: _paymentReceiptEmail,
                        onChanged: (v) {
                          setState(() => _paymentReceiptEmail = v);
                          _updatePref('payment_receipt', v);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Application & Security',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : LexColors.slatePrimary,
                  ),
                ),
                const SizedBox(height: 12),

                LexCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow('Application Name', 'NTS Legal Pro'),
                      const Divider(),
                      _buildInfoRow(
                        'Build Version',
                        '1.0.0+1 (Production Release)',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        'Cloud API',
                        'api.hphighcourt.site (TLS Secure)',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        'Session Security',
                        'Encrypted JWT with Keystore/Keychain',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        'Data Isolation',
                        'Strict Multi-Tenant Separation',
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
