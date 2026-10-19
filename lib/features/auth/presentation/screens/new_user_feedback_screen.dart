import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_brand_logo.dart';
import '../../../../shared/widgets/lex_button.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../../data/models/user_feedback_request.dart';
import '../providers/user_feedback_notifier.dart';

class NewUserFeedbackScreen extends ConsumerStatefulWidget {
  const NewUserFeedbackScreen({super.key});

  @override
  ConsumerState<NewUserFeedbackScreen> createState() =>
      _NewUserFeedbackScreenState();
}

class _NewUserFeedbackScreenState extends ConsumerState<NewUserFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final request = UserFeedbackRequest(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      companyName: _companyController.text.trim(),
      message: _messageController.text.trim(),
    );

    final success = await ref
        .read(userFeedbackNotifierProvider.notifier)
        .submitFeedback(request);

    if (success && mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: LexColors.success, size: 26),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Inquiry Received',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'Thank you for reaching out! Your information has been submitted. Our team will review your inquiry and get in touch with you shortly.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LexColors.accentBronze,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedbackState = ref.watch(userFeedbackNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New User Inquiry'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: AppBrandLogo(
                      size: 64,
                      borderRadius: BorderRadius.circular(16),
                      showBorder: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Get Started with Vidhanta',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Provide your details to connect with us and set up your legal firm workspace.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? LexColors.textSecondaryDark
                          : LexColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error banner
                  if (feedbackState.errorMessage != null) ...[
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
                              feedbackState.errorMessage!,
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

                  // Form Card
                  LexCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Full Name
                        LexTextField(
                          controller: _nameController,
                          label: 'Full Name *',
                          hintText: 'e.g. Adv. Rajesh Sharma',
                          prefixIcon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          validator: (v) => Validators.required(v, 'Full name'),
                          enabled: !feedbackState.isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Official Email
                        LexTextField(
                          controller: _emailController,
                          label: 'Email Address *',
                          hintText: 'e.g. rajesh@legalchambers.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.email,
                          enabled: !feedbackState.isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Phone Number
                        LexTextField(
                          controller: _phoneController,
                          label: 'Phone Number *',
                          hintText: '+91 9876543210',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: Validators.phone,
                          enabled: !feedbackState.isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Company / Law Firm Name
                        LexTextField(
                          controller: _companyController,
                          label: 'Company / Firm Name *',
                          hintText: 'e.g. Sharma & Associates Law Chambers',
                          prefixIcon: Icons.business_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              Validators.required(v, 'Company or firm name'),
                          enabled: !feedbackState.isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Message / Inquiry
                        LexTextField(
                          controller: _messageController,
                          label: 'Message / Inquiry *',
                          hintText: 'Describe your legal practice, requirements, or questions...',
                          prefixIcon: Icons.chat_bubble_outline,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                          validator: (v) =>
                              Validators.required(v, 'Inquiry message'),
                          enabled: !feedbackState.isLoading,
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        LexButton(
                          label: 'Submit Inquiry',
                          onPressed: _onSubmit,
                          isLoading: feedbackState.isLoading,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Back to Login Prompt
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Already have an account? Sign in',
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
      ),
    );
  }
}
