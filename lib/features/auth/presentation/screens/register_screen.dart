import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../../data/models/register_request.dart';
import '../providers/auth_notifier.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Firm controllers
  final _firmNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _panController = TextEditingController();
  final _gstController = TextEditingController();

  // Admin user controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firmNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _panController.dispose();
    _gstController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    ref.read(authNotifierProvider.notifier).clearError();

    if (_formKey.currentState?.validate() ?? false) {
      final request = RegisterRequest(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firmName: _firmNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        panNumber: _panController.text.trim(),
        gstNumber: _gstController.text.trim().isNotEmpty
            ? _gstController.text.trim()
            : null,
      );

      final success = await ref
          .read(authNotifierProvider.notifier)
          .register(request);

      if (success && mounted) {
        // Show success notification and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Law firm registration submitted successfully! Please sign in.',
            ),
            backgroundColor: LexColors.success,
          ),
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
        title: const Text('Register Law Firm'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 540,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Establish Your Firm Workspace',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Register your law firm and administrative manager credentials.',
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

                // Section 1: Firm Information
                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 18,
                            color: isDark
                                ? LexColors.accentGold
                                : LexColors.accentBronze,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Law Firm Information',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? LexColors.textPrimaryDark
                                  : LexColors.slatePrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LexTextField(
                        controller: _firmNameController,
                        label: 'Firm Name *',
                        hintText: 'e.g. Apex Chambers & Associates',
                        prefixIcon: Icons.account_balance_outlined,
                        validator: (v) => Validators.required(v, 'Firm name'),
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 14),
                      LexTextField(
                        controller: _addressController,
                        label: 'Office Address *',
                        hintText: 'Street address or suite number',
                        prefixIcon: Icons.location_on_outlined,
                        validator: (v) =>
                            Validators.required(v, 'Office address'),
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: LexTextField(
                              controller: _cityController,
                              label: 'City *',
                              hintText: 'City',
                              validator: (v) => Validators.required(v, 'City'),
                              enabled: !authState.isLoading,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: LexTextField(
                              controller: _stateController,
                              label: 'State *',
                              hintText: 'State',
                              validator: (v) => Validators.required(v, 'State'),
                              enabled: !authState.isLoading,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: LexTextField(
                              controller: _pincodeController,
                              label: 'Pincode *',
                              hintText: 'Postal code',
                              keyboardType: TextInputType.number,
                              validator: Validators.pincode,
                              enabled: !authState.isLoading,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: LexTextField(
                              controller: _panController,
                              label: 'PAN Number *',
                              hintText: '10-char PAN',
                              validator: Validators.panNumber,
                              enabled: !authState.isLoading,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      LexTextField(
                        controller: _gstController,
                        label: 'GST Number (Optional)',
                        hintText: 'Firm GSTIN if registered',
                        prefixIcon: Icons.receipt_long_outlined,
                        enabled: !authState.isLoading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section 2: Administrator Account
                LexCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings_outlined,
                            size: 18,
                            color: isDark
                                ? LexColors.accentGold
                                : LexColors.accentBronze,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Administrator Credentials',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? LexColors.textPrimaryDark
                                  : LexColors.slatePrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LexTextField(
                        controller: _usernameController,
                        label: 'Admin Username *',
                        hintText: 'e.g. advocate.sharma',
                        prefixIcon: Icons.person_outline,
                        validator: Validators.username,
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 14),
                      LexTextField(
                        controller: _emailController,
                        label: 'Official Email *',
                        hintText: 'firm@legalchambers.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 14),
                      LexTextField(
                        controller: _phoneController,
                        label: 'Contact Phone *',
                        hintText: '+91 9876543210',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 14),
                      LexTextField(
                        controller: _passwordController,
                        label: 'Password *',
                        hintText: 'Minimum 6 characters',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: Validators.password,
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 14),
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
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                LexButton(
                  label: 'Complete Registration',
                  onPressed: _onRegister,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Already registered? Sign in',
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
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
