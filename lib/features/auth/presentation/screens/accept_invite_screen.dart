import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../../data/models/accept_invite_request.dart';
import '../providers/auth_notifier.dart';

class AcceptInviteScreen extends ConsumerStatefulWidget {
  final String? initialToken;

  const AcceptInviteScreen({super.key, this.initialToken});

  @override
  ConsumerState<AcceptInviteScreen> createState() => _AcceptInviteScreenState();
}

class _AcceptInviteScreenState extends ConsumerState<AcceptInviteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tokenController;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.initialToken ?? '');
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onAcceptInvite() async {
    ref.read(authNotifierProvider.notifier).clearError();

    if (_formKey.currentState?.validate() ?? false) {
      final request = AcceptInviteRequest(
        token: _tokenController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      final success = await ref
          .read(authNotifierProvider.notifier)
          .acceptInvite(request);

      if (success && mounted) {
        AppAlerts.showSuccess(
          context,
          'Invitation accepted successfully! You may now sign in with your credentials.',
        );
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accept Law Firm Invite'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 460,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join Law Practice Workspace',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter the invite token sent to your email and set up your lawyer or staff credentials.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? LexColors.textSecondaryDark
                        : LexColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 24),

                // API Error Banner
                if (authState.hasError && authState.errorMessage != null) ...[
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

                LexCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LexTextField(
                        controller: _tokenController,
                        label: 'Invitation Token *',
                        hintText: 'Paste token from invitation email',
                        prefixIcon: Icons.vpn_key_outlined,
                        validator: Validators.inviteToken,
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 16),
                      LexTextField(
                        controller: _usernameController,
                        label: 'Choose Username *',
                        hintText: 'e.g. advocate.raj',
                        prefixIcon: Icons.person_outline,
                        validator: Validators.username,
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 16),
                      LexTextField(
                        controller: _passwordController,
                        label: 'Set Password *',
                        hintText: 'Minimum 6 characters',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: Validators.password,
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 16),
                      LexTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password *',
                        hintText: 'Re-enter chosen password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: (v) => Validators.confirmPassword(
                          v,
                          _passwordController.text,
                        ),
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 24),
                      LexButton(
                        label: 'Accept & Activate Account',
                        onPressed: _onAcceptInvite,
                        isLoading: authState.isLoading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Back to sign in',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? LexColors.accentGold
                            : LexColors.accentBronze,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
