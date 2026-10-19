import 'package:flutter/material.dart';

import '../theme/client_portal_theme.dart';

class ClientLoadingSkeleton extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ClientLoadingSkeleton({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = ClientPortalDimensions.cardRadius,
  });

  @override
  State<ClientLoadingSkeleton> createState() => _ClientLoadingSkeletonState();
}

class _ClientLoadingSkeletonState extends State<ClientLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.35,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final baseColor = isDark
            ? const Color(0xFF1E2D4A)
            : const Color(0xFFE2E8F0);

        return Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: isDark
                  ? ClientPortalColors.darkBorder
                  : ClientPortalColors.border,
            ),
          ),
        );
      },
    );
  }
}
