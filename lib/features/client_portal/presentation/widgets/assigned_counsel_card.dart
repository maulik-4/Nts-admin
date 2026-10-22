import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/client_portal_theme.dart';
import '../../data/models/client_dashboard_model.dart';

class AssignedCounselCard extends StatelessWidget {
  final LegalPersonnel counsel;
  final VoidCallback? onTap;

  const AssignedCounselCard({super.key, required this.counsel, this.onTap});

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'L';
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

  Future<void> _sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhone = counsel.phone != null && counsel.phone!.trim().isNotEmpty;
    final hasEmail = counsel.email.trim().isNotEmpty;

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
                .withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            ClientPortalDimensions.cardRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Avatar with colored background
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFF1E2D4A)
                        : const Color(0xFFEBF2FA),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFDBEAFE),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(counsel.name),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: ClientPortalColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Counsel Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        counsel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: isDark
                              ? ClientPortalColors.darkPrimaryText
                              : ClientPortalColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        counsel.role.isNotEmpty && counsel.role != 'staff'
                            ? counsel.role
                            : 'Lawyer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? ClientPortalColors.darkSecondaryText
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Firm Legal Counsel',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? ClientPortalColors.darkSecondaryText
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(
                            Icons.apartment_rounded,
                            size: 14,
                            color: ClientPortalColors.primaryBlue,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Firm Legal Counsel',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: ClientPortalColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Contact Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasEmail)
                      _IconButtonBox(
                        icon: Icons.mail_outline_rounded,
                        tooltip: 'Email ${counsel.name}',
                        onTap: () => _sendEmail(counsel.email),
                        isDark: isDark,
                      ),
                    if (hasPhone) ...[
                      const SizedBox(width: 8),
                      _IconButtonBox(
                        icon: Icons.phone_outlined,
                        tooltip: 'Call ${counsel.name}',
                        onTap: () => _makePhoneCall(counsel.phone!),
                        isDark: isDark,
                      ),
                    ],
                    if (onTap != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: isDark
                            ? ClientPortalColors.darkSecondaryText
                            : ClientPortalColors.secondaryText,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconButtonBox extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDark;

  const _IconButtonBox({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E2D4A).withValues(alpha: 0.6)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
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
      ),
    );
  }
}
