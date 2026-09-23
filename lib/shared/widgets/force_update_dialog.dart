import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/app_update_info.dart';
import '../../core/providers/app_update_provider.dart';
import '../../core/theme/lex_colors.dart';
import 'lex_button.dart';

/// Non-dismissible modal alert for mandatory app updates.
/// Cannot be closed, cancelled, or popped until the user updates the application.
class ForceUpdateDialog extends ConsumerWidget {
  final AppUpdateInfo updateInfo;

  const ForceUpdateDialog({
    super.key,
    required this.updateInfo,
  });

  /// Static helper to display the non-dismissible update alert dialog.
  static Future<void> show(BuildContext context, AppUpdateInfo updateInfo) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => ForceUpdateDialog(updateInfo: updateInfo),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Strict blocking: app cannot be dismissed without updating
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 24,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Icon Indicator
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: LexColors.accentBronze.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: LexColors.accentBronze.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.system_update_rounded,
                        color: LexColors.accentBronze,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  updateInfo.title.isNotEmpty
                      ? updateInfo.title
                      : 'App Update Required',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(height: 8),

                // Version comparison badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? LexColors.slateDark
                          : LexColors.accentLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: LexColors.accentBronze.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      'v${updateInfo.currentVersion}  ➔  v${updateInfo.latestVersion}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? LexColors.accentGold
                            : LexColors.accentBronze,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  updateInfo.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? LexColors.textSecondaryDark
                            : LexColors.textSecondaryLight,
                        height: 1.4,
                      ),
                ),

                // Release notes list (if available)
                if (updateInfo.releaseNotes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : LexColors.canvasLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? LexColors.borderDark
                            : LexColors.borderLight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What's New:",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? LexColors.textPrimaryDark
                                : LexColors.slatePrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...updateInfo.releaseNotes.map(
                          (note) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: LexColors.accentBronze,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    note,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Non-dismissible Primary Action Button: "Update Now"
                LexButton(
                  label: 'Update Now',
                  icon: Icons.open_in_new_rounded,
                  onPressed: () async {
                    await ref
                        .read(appUpdateNotifierProvider.notifier)
                        .launchUpdateUrl();
                  },
                ),

                const SizedBox(height: 8),

                // Mandatory note reminder
                Center(
                  child: Text(
                    'This update is mandatory to continue using Vidhanta.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? LexColors.textMutedDark
                          : LexColors.textMutedLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
