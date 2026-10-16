import 'package:flutter/material.dart';

class LexCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? leftAccentColor;
  final double leftAccentWidth;
  final bool showShadow;
  final Border? border;

  const LexCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 18,
    this.onTap,
    this.backgroundColor,
    this.leftAccentColor,
    this.leftAccentWidth = 4.0,
    this.showShadow = true,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBorder = Border.all(
      color: isDark
          ? const Color(0xFF334155).withValues(alpha: 0.6)
          : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
      width: 1.0,
    );

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? defaultBorder,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : const Color(0xFF1E293B).withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );

    Widget effectiveCard = cardContent;

    if (leftAccentColor != null) {
      effectiveCard = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            effectiveCard,
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: leftAccentWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: leftAccentColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    bottomLeft: Radius.circular(borderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: effectiveCard,
        ),
      );
    }

    return effectiveCard;
  }
}
