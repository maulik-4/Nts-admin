import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_update_provider.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../shared/widgets/force_update_dialog.dart';
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
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Preferences')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Theme & Appearance Section
                Text(
                  'Appearance & Theme',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Application Theme',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? LexColors.textSecondaryDark
                              : LexColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.system,
                              label: Text('System'),
                              icon: Icon(Icons.brightness_auto_outlined),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text('Light'),
                              icon: Icon(Icons.light_mode_outlined),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text('Dark'),
                              icon: Icon(Icons.dark_mode_outlined),
                            ),
                          ],
                          selected: {currentThemeMode},
                          onSelectionChanged: (set) {
                            if (set.isNotEmpty) {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .setThemeMode(set.first);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

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
                  'Application Information',
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
                      _buildInfoRow(context, 'Application Name', 'Vidhanta'),
                      const Divider(),
                      _buildInfoRow(
                        context,
                        'Build Version',
                        '1.0.1+2 (Production Release)',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        context,
                        'Legal Services',
                        'Role-based Legal Management System',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        context,
                        'Security Standard',
                        'Encrypted Credentials & Session Management',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        context,
                        'Support Desk',
                        'support@vidhanta.com',
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.system_update_alt,
                          color: LexColors.accentBronze,
                        ),
                        title: const Text(
                          'Check for Updates',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Ensure your app is up to date',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: OutlinedButton(
                          onPressed: () async {
                            final scaffold = ScaffoldMessenger.of(context);
                            final info = await ref
                                .read(appUpdateNotifierProvider.notifier)
                                .checkAppVersion();
                            if (!context.mounted) return;
                            if (info.isForceUpdate) {
                              ForceUpdateDialog.show(context, info);
                            } else {
                              scaffold.showSnackBar(
                                const SnackBar(
                                  content: Text('Vidhanta is currently up to date (v1.0.1).'),
                                  backgroundColor: LexColors.success,
                                ),
                              );
                            }
                          },
                          child: const Text('Check Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? LexColors.textSecondaryDark
                  : LexColors.textSecondaryLight,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark
                    ? LexColors.textPrimaryDark
                    : LexColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
