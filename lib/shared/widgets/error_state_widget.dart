import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/lex_colors.dart';
import 'lex_button.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String? requestId;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.requestId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: LexColors.errorLight,
                shape: BoxShape.circle,
                border: Border.all(color: LexColors.error.withAlpha(60)),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 32,
                color: LexColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Complete Request',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? LexColors.textPrimaryDark
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark
                      ? LexColors.textSecondaryDark
                      : LexColors.textSecondaryLight,
                ),
              ),
            ),
            if (requestId != null && requestId!.isNotEmpty) ...[
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: requestId!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Request ID copied to clipboard'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ID: $requestId',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              LexButton(
                label: 'Try Again',
                variant: LexButtonVariant.outline,
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
