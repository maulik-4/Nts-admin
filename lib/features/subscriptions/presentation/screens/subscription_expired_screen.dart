import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class SubscriptionExpiredScreen extends ConsumerWidget {
  final String? message;
  final String? requestId;

  const SubscriptionExpiredScreen({super.key, this.message, this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFirmAdmin = userRole.isAdmin || userRole.isFirmAdmin;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF0F172A),
                    Color(0xFF090E1A),
                    Color(0xFF020617),
                  ]
                : const [
                    Color(0xFFFFFBEB),
                    Color(0xFFF8FAFC),
                    Color(0xFFF1F5F9),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hourglass / Expired Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withAlpha(30),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withAlpha(80),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.hourglass_empty_rounded,
                        size: 40,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Subscription Plan Expired',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      message ??
                          (isFirmAdmin
                              ? 'Your firm\'s active billing cycle has completed. Upgrade or renew your subscription plan to restore workspace litigation tools and team member access.'
                              : 'Your law firm\'s subscription has lapsed. Please notify your Firm Administrator to renew the subscription plan.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (isFirmAdmin) ...[
                      // Admin Renewal Callout
                      LexCard(
                        borderRadius: 16,
                        leftAccentColor: const Color(0xFFF59E0B),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Renew Firm Subscription',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Choose between monthly or annual billing to instantly restore all case files, client representations, and lawyer assignments.',
                              style: TextStyle(fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: LexButton(
                                label: 'View Subscription Plans',
                                icon: Icons.credit_card_rounded,
                                onPressed: () {
                                  context.push('/app/more/subscriptions');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Staff / Lawyer guidance card
                      LexCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Notice for Counsel & Staff',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Only designated Firm Administrators possess authorization to manage subscription billing and checkout. Please reach out to your managing partner or administrator.',
                              style: TextStyle(fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (requestId != null && requestId!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: requestId!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Request ID copied to clipboard'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Request Reference: $requestId',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.copy_rounded, size: 12),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    LexButton(
                      label: 'Log Out',
                      icon: Icons.logout_rounded,
                      variant: LexButtonVariant.outline,
                      onPressed: () async {
                        await ref.read(authNotifierProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
