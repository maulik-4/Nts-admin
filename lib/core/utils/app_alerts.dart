import 'package:flutter/material.dart';

import '../theme/lex_colors.dart';

/// Centralized graceful error handling and alert presentation for the application.
class AppAlerts {
  AppAlerts._();

  /// Shows a graceful error alert dialog to the user.
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String message,
    String title = 'Attention Needed',
    VoidCallback? onRetry,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top alert icon
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: LexColors.errorLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: LexColors.error.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 30,
                    color: LexColors.error,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _cleanErrorMessage(message),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: isDark
                        ? LexColors.textSecondaryDark
                        : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF475569)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                        child: Text(
                          onRetry != null ? 'Cancel' : 'Dismiss',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? LexColors.textSecondaryDark
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                    if (onRetry != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            onRetry();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F1F38),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Try Again',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Displays a floating error notification banner.
  static void showError(
    BuildContext context,
    String message, {
    String? title,
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFF87171),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    _cleanErrorMessage(message),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE2E8F0),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                  onRetry();
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Color(0xFF60A5FA),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Displays a floating success notification banner.
  static void showSuccess(
    BuildContext context,
    String message, {
    String? title,
  }) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF10B981), width: 1.2),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF34D399),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE2E8F0),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _cleanErrorMessage(String message) {
    var clean = message.replaceFirst('Exception: ', '');
    clean = clean.replaceFirst('ApiException: ', '');
    return clean;
  }
}
