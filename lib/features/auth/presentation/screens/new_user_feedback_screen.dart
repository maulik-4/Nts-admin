import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_brand_logo.dart';
import '../../../../shared/widgets/lex_text_field.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF131D33) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: LexColors.success, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Inquiry Received',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Thank you for reaching out! Your information has been submitted. Our team will review your inquiry and get in touch with you shortly.',
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? const Color(0xFF1E3A8A)
                  : const Color(0xFF132B4F),
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
      backgroundColor:
          isDark ? const Color(0xFF0C1322) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'New User Inquiry',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Banner matching 2.png left screen
                    Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B192C).withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/bg.png',
                              fit: BoxFit.cover,
                              alignment: Alignment.centerRight,
                              errorBuilder: (context, error, stackTrace) => Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF071224), Color(0xFF1E3A8A)],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    const Color(0xFF081426).withValues(alpha: 0.95),
                                    const Color(0xFF0D2240).withValues(alpha: 0.75),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.65, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 20,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Get Started with',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const Text(
                                        'Vidhanta',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFFBBF24),
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Provide your details to connect with us\nand set up your legal firm workspace.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          height: 1.35,
                                          color: Colors.white.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 58,
                                  height: 58,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFFDE68A),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: AppBrandLogo(
                                      size: 44,
                                      showBorder: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                        borderRadius: BorderRadius.circular(10),
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
                    const SizedBox(height: 16),
                  ],

                  // Form Card matching 2.png
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131D33) : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF1E2D4A)
                            : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Your Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tell us about yourself and your firm.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Full Name
                        LexTextField(
                          controller: _nameController,
                          label: 'Full Name *',
                          hintText: 'e.g. Adv. Rajesh Sharma',
                          prefixIcon: Icons.person_outline_rounded,
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
                          hintText: '+91 98765 43210',
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
                          hintText: 'e.g. Sharma & Associates LLP',
                          prefixIcon: Icons.apartment_rounded,
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              Validators.required(v, 'Company or firm name'),
                          enabled: !feedbackState.isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Message / Inquiry with character counter
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _messageController,
                          builder: (context, value, _) {
                            final length = value.text.length;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                LexTextField(
                                  controller: _messageController,
                                  label: 'Message / Inquiry *',
                                  hintText:
                                      'Describe your legal practice, requirements, or questions...',
                                  prefixIcon: Icons.chat_bubble_outline_rounded,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 4,
                                  textInputAction: TextInputAction.newline,
                                  validator: (v) =>
                                      Validators.required(v, 'Inquiry message'),
                                  enabled: !feedbackState.isLoading,
                                ),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '$length/500',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Submit Button matching 2.png
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                feedbackState.isLoading ? null : _onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFF132B4F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            child: feedbackState.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Submit Inquiry',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded,
                                          size: 18),
                                    ],
                                  ),
                          ),
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
                              ? const Color(0xFF38BDF8)
                              : const Color(0xFF0284C7),
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
    ),
  );
}
}
