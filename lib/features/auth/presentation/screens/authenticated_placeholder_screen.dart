import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../providers/auth_notifier.dart';

class AuthenticatedPlaceholderScreen extends ConsumerWidget {
  const AuthenticatedPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NTS Legal Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Banner
              LexCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark
                                ? LexColors.surfaceDark
                                : LexColors.slatePrimary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? LexColors.accentGold
                                  : LexColors.borderLight,
                            ),
                          ),
                          child: Icon(
                            Icons.verified_user_outlined,
                            color: isDark ? LexColors.accentGold : Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Authentication Active',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? LexColors.textPrimaryDark
                                      : LexColors.slatePrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Session successfully authenticated and verified.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? LexColors.textSecondaryDark
                                      : LexColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),

                    // User Details
                    _buildDetailRow(
                      context,
                      'Username',
                      user?.username ?? 'Not provided',
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      'Role',
                      user?.role?.toUpperCase() ?? 'STAFF',
                      Icons.shield_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      'Email',
                      user?.email.isNotEmpty == true
                          ? user!.email
                          : 'Linked to Firm Account',
                      Icons.email_outlined,
                    ),
                    if (user?.firmName != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Law Firm',
                        user!.firmName!,
                        Icons.business_outlined,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Placeholder info note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? LexColors.surfaceDark : LexColors.canvasLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? LexColors.borderDark
                        : LexColors.borderLight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: isDark
                          ? LexColors.accentGold
                          : LexColors.accentBronze,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Phase 2 Authentication Foundation Complete. '
                        'Dashboard, Cases, Clients, and other feature modules will be connected in subsequent phases.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark
                              ? LexColors.textSecondaryDark
                              : LexColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              LexButton(
                label: 'Sign Out Session',
                variant: LexButtonVariant.outline,
                icon: Icons.logout,
                isLoading: authState.isLoading,
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? LexColors.textMutedDark : LexColors.textMutedLight,
        ),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? LexColors.textMutedDark : LexColors.textMutedLight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? LexColors.textPrimaryDark
                  : LexColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }
}
