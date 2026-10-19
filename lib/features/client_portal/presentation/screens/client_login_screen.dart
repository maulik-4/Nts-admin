import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../auth/data/models/user_profile.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/repositories/client_portal_repository.dart';

class ClientLoginScreen extends ConsumerStatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  ConsumerState<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends ConsumerState<ClientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(clientPortalRepositoryProvider);
      final user = await repo.clientLogin(
        usernameOrEmail: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      ref
          .read(authNotifierProvider.notifier)
          .setAuthenticated(UserProfile.fromUser(user));

      if (!mounted) return;
      context.go('/client/dashboard');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Login failed. Please check your credentials.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF0F172A),
                    Color(0xFF0A0F1D),
                    Color(0xFF020617),
                  ]
                : const [
                    Color(0xFFF1F5F9),
                    Color(0xFFFFFFFF),
                    Color(0xFFE2E8F0),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Badge
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary
                              .withAlpha(25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary
                                .withAlpha(60),
                          ),
                        ),
                        child: Icon(
                          Icons.balance_rounded,
                          size: 34,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Client Document Portal',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Secure access to your case hearings, advocate representations, and shared case files.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 28),

                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: LexColors.errorLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: LexColors.error.withAlpha(50),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 18,
                                color: LexColors.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: LexColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      LexCard(
                        borderRadius: 18,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Username or Email
                            TextFormField(
                              controller: _usernameController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email or Username',
                                hintText: 'client@example.com',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter your username or email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            LexButton(
                              label: _isLoading
                                  ? 'Signing In...'
                                  : 'Access Portal',
                              icon: Icons.login_rounded,
                              onPressed: _isLoading ? null : _handleLogin,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Alternate actions
                      TextButton.icon(
                        icon: const Icon(Icons.card_giftcard_rounded, size: 16),
                        label: const Text(
                          'Have an invite link? Activate account',
                        ),
                        onPressed: () => context.push('/client/accept-invite'),
                      ),
                      const SizedBox(height: 6),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 16,
                        ),
                        label: const Text('Law Firm & Counsel Login'),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        onPressed: () => context.go('/login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
