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

class ClientAcceptInviteScreen extends ConsumerStatefulWidget {
  final String? initialToken;

  const ClientAcceptInviteScreen({super.key, this.initialToken});

  @override
  ConsumerState<ClientAcceptInviteScreen> createState() =>
      _ClientAcceptInviteScreenState();
}

class _ClientAcceptInviteScreenState
    extends ConsumerState<ClientAcceptInviteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isValidatingToken = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _tokenErrorMessage;
  String? _errorMessage;

  String? _firmName;
  String? _invitedEmail;

  @override
  void initState() {
    super.initState();
    if (widget.initialToken != null && widget.initialToken!.isNotEmpty) {
      _tokenController.text = widget.initialToken!;
      _validateToken(widget.initialToken!);
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _validateToken(String token) async {
    if (token.trim().isEmpty) return;

    setState(() {
      _isValidatingToken = true;
      _tokenErrorMessage = null;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(clientPortalRepositoryProvider);
      final info = await repo.validateInvite(token.trim());

      setState(() {
        _firmName = info['firm_name']?.toString();
        _invitedEmail = info['email']?.toString();
        if (_usernameController.text.isEmpty &&
            info['suggested_username'] != null) {
          _usernameController.text = info['suggested_username'].toString();
        }
      });
    } on ApiException catch (e) {
      setState(() => _tokenErrorMessage = e.message);
    } catch (e) {
      setState(
        () => _tokenErrorMessage = 'Invalid or expired invitation link.',
      );
    } finally {
      if (mounted) setState(() => _isValidatingToken = false);
    }
  }

  Future<void> _handleAcceptInvite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(clientPortalRepositoryProvider);
      final user = await repo.acceptInvite(
        token: _tokenController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      ref
          .read(authNotifierProvider.notifier)
          .setAuthenticated(UserProfile.fromUser(user));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully! Welcome to your client portal.',
          ),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/client/dashboard');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Failed to activate account. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accept Invitation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/client/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Welcome Banner if token validated
                    if (_firmName != null) ...[
                      LexCard(
                        borderRadius: 16,
                        leftAccentColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Invited by $_firmName',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            if (_invitedEmail != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Invitation verified for: $_invitedEmail',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (_tokenErrorMessage != null) ...[
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
                                _tokenErrorMessage!,
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
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Invitation Token Field
                          TextFormField(
                            controller: _tokenController,
                            decoration: InputDecoration(
                              labelText: 'Invitation Token',
                              hintText: 'Enter or paste UUID token',
                              prefixIcon: const Icon(Icons.vpn_key_outlined),
                              suffixIcon: _isValidatingToken
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                      ),
                                      tooltip: 'Verify Token',
                                      onPressed: () =>
                                          _validateToken(_tokenController.text),
                                    ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Invitation token is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // First and Last Name
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'First Name',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Username
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Choose Username',
                              prefixIcon: Icon(Icons.alternate_email_rounded),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please choose a username';
                              }
                              if (val.trim().length < 3) {
                                return 'Username must be at least 3 characters';
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
                              labelText: 'Set Password',
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
                                return 'Password is required';
                              }
                              if (val.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscurePassword,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: Icon(Icons.lock_clock_outlined),
                            ),
                            validator: (val) {
                              if (val != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          LexButton(
                            label: _isSubmitting
                                ? 'Creating Account...'
                                : 'Create Client Account',
                            icon: Icons.person_add_alt_1_rounded,
                            onPressed: _isSubmitting
                                ? null
                                : _handleAcceptInvite,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    TextButton(
                      child: const Text(
                        'Already have an active account? Sign In',
                      ),
                      onPressed: () => context.go('/client/login'),
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
