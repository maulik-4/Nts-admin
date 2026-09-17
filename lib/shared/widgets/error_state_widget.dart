import 'package:flutter/material.dart';

import '../../core/theme/lex_colors.dart';
import 'lex_button.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
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
                    : LexColors.slatePrimary,
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
