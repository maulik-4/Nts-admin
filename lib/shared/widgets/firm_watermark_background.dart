import 'package:flutter/material.dart';

import '../../core/theme/firm_theme.dart';

/// Renders an authentic law firm watermark and visual brand identity
/// when explicitly displayed in branding previews or components.
/// Note: Removed from app shell so it is not shown on every page.
class FirmWatermarkBackground extends StatelessWidget {
  final FirmTheme firmTheme;
  final bool isDark;
  final bool isOverlay;

  const FirmWatermarkBackground({
    super.key,
    required this.firmTheme,
    this.isDark = false,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    // Opacity is calibrated to be subtle, elegant, and non-distracting:
    // Underlay: ~0.06 in light, ~0.08 in dark
    // Overlay: ~0.03 in light, ~0.04 in dark
    final double opacity = isOverlay
        ? (isDark ? 0.04 : 0.03)
        : (isDark ? 0.085 : 0.055);

    final firmColor = isDark ? firmTheme.accentColor : firmTheme.primaryColor;
    final firmName = firmTheme.firmName ?? 'NTS Legal Pro';
    final hasLogo =
        firmTheme.logoUrl != null && firmTheme.logoUrl!.trim().isNotEmpty;

    return IgnorePointer(
      child: Center(
        child: Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasLogo)
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: firmColor.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.network(
                      firmTheme.logoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildClassicalSeal(firmColor),
                    ),
                  )
                else
                  _buildClassicalSeal(firmColor),
                const SizedBox(height: 20),
                // Tracked Firm Name Monogram / Typography
                Text(
                  firmName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: firmTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4.0,
                    color: firmColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 1,
                      color: firmColor.withValues(alpha: 0.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'ADVOCATES & LEGAL COUNSEL',
                        style: TextStyle(
                          fontFamily: firmTheme.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.5,
                          color: firmColor,
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 1,
                      color: firmColor.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassicalSeal(Color firmColor) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: firmColor, width: 2.5),
      ),
      child: Center(
        child: Container(
          width: 196,
          height: 196,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: firmColor.withValues(alpha: 0.5),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.balance, size: 80, color: firmColor),
              const SizedBox(height: 6),
              Text(
                'LEX • JUSTITIA',
                style: TextStyle(
                  fontFamily: firmTheme.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.0,
                  color: firmColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
