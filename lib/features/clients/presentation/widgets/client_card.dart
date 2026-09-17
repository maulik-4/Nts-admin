import 'package:flutter/material.dart';

import '../../../../core/theme/lex_colors.dart';
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

    return LexCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isDark
                    ? LexColors.surfaceDark
                    : const Color(0xFFEEF2F6),
                child: Text(
                  client.name.isNotEmpty
                      ? client.name.substring(0, 1).toUpperCase()
                      : 'C',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LexColors.accentGold
                        : LexColors.slatePrimary,
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? LexColors.textPrimaryDark
                            : LexColors.textPrimaryLight,
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
                                ? LexColors.textSecondaryDark
                                : LexColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            client.city!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? LexColors.textSecondaryDark
                                  : LexColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              StatusBadge(status: client.isActive ? 'Active' : 'Inactive'),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 14,
                color: isDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight,
              ),
              const SizedBox(width: 6),
              Text(
                client.phone,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? LexColors.textPrimaryDark
                      : LexColors.slatePrimary,
                ),
              ),
              if (client.email != null && client.email!.isNotEmpty) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.email_outlined,
                  size: 14,
                  color: isDark
                      ? LexColors.textSecondaryDark
                      : LexColors.textSecondaryLight,
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
                          ? LexColors.textSecondaryDark
                          : LexColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
