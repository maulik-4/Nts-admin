import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/client_portal_theme.dart';
import '../../data/models/client_dashboard_model.dart';

class WelcomeCard extends StatelessWidget {
  final ClientPortalDashboardData data;

  const WelcomeCard({super.key, required this.data});

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'C';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firm = data.firm;
    final contactPhone = firm?.phone.isNotEmpty == true
        ? firm!.phone
        : (firm?.whatsapp.isNotEmpty == true ? firm!.whatsapp : null);
    final location = firm?.address.isNotEmpty == true
        ? firm!.address
        : (firm?.name.isNotEmpty == true ? firm!.name : null);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? ClientPortalColors.darkCardBackground
            : ClientPortalColors.cardBackground,
        borderRadius: BorderRadius.circular(ClientPortalDimensions.cardRadius),
        border: Border.all(
          color: isDark
              ? ClientPortalColors.darkBorder
              : ClientPortalColors.border,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A)
                .withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ClientPortalDimensions.cardRadius),
        child: Stack(
          children: [
            // Background Illustration: asset with fallback custom painter
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.25 : 0.85,
                child: Image.asset(
                  'assets/images/client_back.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder: (context, error, stackTrace) =>
                      const CustomPaint(painter: _CourthousePainter()),
                ),
              ),
            ),
            // Gradient overlay to guarantee high-contrast readability on the left
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.0, 0.55, 1.0],
                    colors: isDark
                        ? [
                            ClientPortalColors.darkCardBackground.withValues(
                              alpha: 0.95,
                            ),
                            ClientPortalColors.darkCardBackground.withValues(
                              alpha: 0.80,
                            ),
                            ClientPortalColors.darkCardBackground.withValues(
                              alpha: 0.30,
                            ),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.95),
                            Colors.white.withValues(alpha: 0.80),
                            Colors.white.withValues(alpha: 0.20),
                          ],
                  ),
                ),
              ),
            ),
            // Card Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                            color: isDark
                                ? ClientPortalColors.darkSecondaryText
                                : ClientPortalColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.clientName.isNotEmpty
                              ? data.clientName
                              : 'Client',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark
                                ? ClientPortalColors.darkPrimaryText
                                : ClientPortalColors.primaryText,
                          ),
                        ),
                        if (firm?.name != null && firm!.name.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            firm.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ClientPortalColors.primaryBlue,
                            ),
                          ),
                        ],
                        if (location != null && location.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: isDark
                                    ? ClientPortalColors.darkSecondaryText
                                    : ClientPortalColors.secondaryText,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? ClientPortalColors.darkSecondaryText
                                        : ClientPortalColors.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Avatar and Contact Actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Avatar with Client Initials
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: ClientPortalColors.primaryBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ClientPortalColors.primaryBlue.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(data.clientName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (contactPhone != null && contactPhone.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ActionButton(
                              icon: Icons.phone_outlined,
                              tooltip: 'Call Firm',
                              onTap: () => _makePhoneCall(contactPhone),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _ActionButton(
                              icon: Icons.chat_bubble_outline_rounded,
                              tooltip: 'Message Firm',
                              onTap: () => _openWhatsApp(contactPhone),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E2D4A).withValues(alpha: 0.8)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDark
                ? ClientPortalColors.darkPrimaryText
                : ClientPortalColors.primaryNavy,
          ),
        ),
      ),
    );
  }
}

/// Fallback custom-drawn courthouse illustration if raster asset is unavailable
class _CourthousePainter extends CustomPainter {
  const _CourthousePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2F6FED).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final right = size.width;
    final bottom = size.height;
    final w = size.width * 0.45;
    final h = size.height * 0.75;
    final x = right - w - 10;
    final y = bottom - h;

    // Pediment triangle
    final path = Path()
      ..moveTo(x + w / 2, y)
      ..lineTo(x, y + h * 0.25)
      ..lineTo(x + w, y + h * 0.25)
      ..close();
    canvas.drawPath(path, paint);

    // Entablature
    canvas.drawRect(
      Rect.fromLTWH(x + 5, y + h * 0.25, w - 10, h * 0.08),
      paint,
    );

    // 4 Columns
    final colWidth = (w - 20) / 7;
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x + 10 + i * (colWidth * 2),
            y + h * 0.33,
            colWidth,
            h * 0.55,
          ),
          const Radius.circular(3),
        ),
        paint,
      );
    }

    // Base podium
    canvas.drawRect(Rect.fromLTWH(x, y + h * 0.88, w, h * 0.12), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
