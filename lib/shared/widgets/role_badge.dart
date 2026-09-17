import 'package:flutter/material.dart';

import '../../features/auth/domain/models/user_role.dart';

/// Reusable, subtle, and premium role badge based on centralized [RoleConfig].
class RoleBadge extends StatelessWidget {
  final UserRole role;
  final String? customLabel;
  final bool showDescription;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const RoleBadge({
    super.key,
    required this.role,
    this.customLabel,
    this.showDescription = false,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final color = role.badgeColor;
    final label =
        customLabel ?? (showDescription ? role.description : role.displayTitle);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: borderRadius ?? BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }
}
