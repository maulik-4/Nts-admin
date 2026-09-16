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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onPressed != null && !isLoading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? border;

    switch (variant) {
      case LexButtonVariant.primary:
        backgroundColor = isDark ? Colors.white : LexColors.slatePrimary;
        foregroundColor = isDark ? LexColors.slateDark : Colors.white;
        border = null;
        break;
      case LexButtonVariant.secondary:
        backgroundColor = isDark
            ? LexColors.surfaceDark
            : LexColors.canvasLight;
        foregroundColor = isDark ? Colors.white : LexColors.slatePrimary;
        border = BorderSide(
          color: isDark ? LexColors.borderDark : LexColors.borderLight,
          width: 1,
        );
        break;
      case LexButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? Colors.white : LexColors.slatePrimary;
        border = BorderSide(
          color: isDark ? LexColors.borderDark : LexColors.borderLight,
          width: 1,
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
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      );
    } else {
      content = Text(
        label,
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
          child: Center(child: content),
        ),
      ),
    );
  }
}
