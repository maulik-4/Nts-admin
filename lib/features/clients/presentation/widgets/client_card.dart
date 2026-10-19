import 'package:flutter/material.dart';

import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/client_model.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;

  const ClientCard({super.key, required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = client.isActive
        ? const Color(0xFF10B981)
        : const Color(0xFF94A3B8);

    return LexCard(
      onTap: onTap,
      borderRadius: 16,
      leftAccentColor: accentColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFEFF6FF),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFDBEAFE),
                  ),
                ),
                child: Center(
                  child: Text(
                    client.name.isNotEmpty
                        ? client.name.substring(0, 1).toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    if (client.city != null && client.city!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              client.city!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                status: client.isActive ? 'Active' : 'Inactive',
                showDot: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 14,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  client.phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF334155),
                  ),
                ),
              ),
              if (client.email != null && client.email!.isNotEmpty) ...[
                const SizedBox(width: 14),
                Icon(
                  Icons.email_outlined,
                  size: 14,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    client.email!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
