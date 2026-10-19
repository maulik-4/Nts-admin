import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class FirmSuspendedScreen extends ConsumerWidget {
  final String? message;
  final String? requestId;

  const FirmSuspendedScreen({super.key, this.message, this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayMessage =
        message ??
        'Access to this law firm workspace has been deactivated or suspended by platform administration.';

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
                    Color(0xFFFEF2F2),
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
                    // Warning Shield Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withAlpha(30),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFEF4444).withAlpha(80),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.gavel_rounded,
                        size: 40,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Firm Workspace Suspended',
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
                      displayMessage,
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

                    // Support Card
                    LexCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.support_agent_rounded,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Platform Support',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'If you believe this suspension was made in error or wish to reactivate your firm, please reach out to our legal compliance desk:',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.mail_outline,
                                    size: 16,
                                  ),
                                  label: const Text('Email Support'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final Uri emailLaunchUri = Uri(
                                      scheme: 'mailto',
                                      path: 'support@vidhanta.com',
                                      queryParameters: {
                                        'subject':
                                            'Inquiry: Firm Suspension [ID: ${requestId ?? 'N/A'}]',
                                      },
                                    );
                                    await launchUrl(emailLaunchUri);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

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

                    // Log out button
                    LexButton(
                      label: 'Return to Login',
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
