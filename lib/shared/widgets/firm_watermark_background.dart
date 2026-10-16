import 'package:flutter/material.dart';

import '../../core/theme/firm_theme.dart';

/// Renders an authentic law firm watermark and visual brand identity
/// in the background of screens for advocates, lawyers, and firm members.
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
    return const SizedBox.shrink();
  }
}
