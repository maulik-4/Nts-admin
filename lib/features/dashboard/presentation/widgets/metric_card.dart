import 'package:flutter/material.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final String? trendText;
  final Color? trendColor;
  final Color? trendBgColor;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    this.trendText = '+0%',
    this.trendColor,
    this.trendBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor =
        iconColor ??
        (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB));
    final bgColor = iconBgColor ?? primaryColor.withValues(alpha: 0.12);

    final effectiveTrendColor =
        trendColor ??
        (isDark ? const Color(0xFF34D399) : const Color(0xFF059669));
    final effectiveTrendBg =
        trendBgColor ??
        effectiveTrendColor.withValues(alpha: isDark ? 0.2 : 0.12);

    return LexCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Icon container + Title + right 3-dots
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: primaryColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.more_horiz_rounded,
                size: 18,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Value and Trend badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark
                          ? LexColors.textPrimaryDark
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
              if (trendText != null && trendText!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: effectiveTrendBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 10,
                        color: effectiveTrendColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trendText!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: effectiveTrendColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Subtitle and Mini Bar Chart Graphic
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle ?? '',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? LexColors.textMutedDark
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              _MiniBarChart(color: primaryColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  final Color color;
  const _MiniBarChart({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _bar(4),
        const SizedBox(width: 2),
        _bar(8),
        const SizedBox(width: 2),
        _bar(12),
        const SizedBox(width: 2),
        _bar(16),
      ],
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 2.8,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}
