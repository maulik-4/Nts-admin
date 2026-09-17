import 'package:flutter/material.dart';

import '../../core/theme/lex_colors.dart';

enum LexButtonVariant { primary, secondary, outline }

class LexButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LexButtonVariant variant;
  final IconData? icon;
  final double height;
  final double? width;

  const LexButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = LexButtonVariant.primary,
    this.icon,
    this.height = 48.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEnabled = onPressed != null && !isLoading;
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final accentColor = theme.colorScheme.secondary;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? border;

    switch (variant) {
      case LexButtonVariant.primary:
        backgroundColor = primaryColor;
        foregroundColor = onPrimaryColor;
        border = null;
        break;
      case LexButtonVariant.secondary:
        backgroundColor = isDark
            ? LexColors.surfaceDark
            : primaryColor.withValues(alpha: 0.08);
        foregroundColor = isDark ? accentColor : primaryColor;
        border = BorderSide(
          color: isDark
              ? LexColors.borderDark
              : primaryColor.withValues(alpha: 0.2),
          width: 1,
        );
        break;
      case LexButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? accentColor : primaryColor;
        border = BorderSide(
          color: isDark
              ? accentColor.withValues(alpha: 0.6)
              : primaryColor.withValues(alpha: 0.4),
          width: 1.5,
        );
        break;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    } else if (icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      );
    } else {
      content = Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: foregroundColor,
          letterSpacing: 0.2,
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: isEnabled
            ? backgroundColor
            : backgroundColor.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: border ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
