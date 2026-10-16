import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_brand_logo.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../providers/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    // Clear any previous error before attempting
    ref.read(authNotifierProvider.notifier).clearError();

    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(authNotifierProvider.notifier)
          .login(_usernameController.text, _passwordController.text);
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            title: const Text('Reset Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your account email address. We will send a secure password reset link if the account exists.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final email = emailCtrl.text.trim();
                        if (email.isEmpty) return;
                        setDialogState(() => isSubmitting = true);
                        final success = await ref
                            .read(authNotifierProvider.notifier)
                            .forgotPassword(email);
                        if (dialogCtx.mounted) {
                          Navigator.of(dialogCtx).pop();
                          if (success) {
                            AppAlerts.showSuccess(
                              context,
                              'If that email exists in the system, password reset instructions have been sent.',
                            );
                          } else {
                            AppAlerts.showError(
                              context,
                              'Unable to submit reset request. Please check your network and try again.',
                            );
                          }
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Reset Link'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 440,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Branding Header
                Center(
                  child: AppBrandLogo(
                    size: 72,
                    borderRadius: BorderRadius.circular(18),
                    showBorder: true,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome to Vidhanta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to access your firm workspace',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? LexColors.textSecondaryDark
                        : LexColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 32),

                // Main Form Card
                LexCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // API Error Banner
                      if (authState.hasError &&
                          authState.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? LexColors.error.withValues(alpha: 0.15)
                                : LexColors.errorLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: LexColors.error.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: LexColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  authState.errorMessage!,
                                  style: const TextStyle(
                                    color: LexColors.error,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Username field
                      LexTextField(
                        controller: _usernameController,
                        label: 'Username',
                        hintText: 'Enter your legal account username',
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        validator: Validators.username,
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 18),

                      // Password field
                      LexTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Enter your account password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: Validators.password,
                        onSubmitted: (_) => _onLogin(),
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 12),

                      // Forgot password prompt
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => _showForgotPasswordDialog(context),
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? LexColors.accentGold
                                  : LexColors.accentBronze,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      LexButton(
                        label: 'Sign In',
                        onPressed: _onLogin,
                        isLoading: authState.isLoading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Navigation actions (New User inquiry & Accept Invite)
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 8,
                  children: [
                    Text(
                      'New User?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/new-user'),
                      child: Text(
                        'Get in Touch / Request Access',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? LexColors.accentGold
                              : LexColors.accentBronze,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Have an invitation code? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => context.push('/accept-invite'),
                      child: Text(
                        'Accept Invite',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? LexColors.accentGold
                              : LexColors.accentBronze,
                        ),
                      ),
                    ),
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
