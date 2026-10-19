import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../providers/auth_notifier.dart';

/// Available login modes on the Vidhanta authentication screen.
enum LoginType { firm, client }

/// Premium Vidhanta Legal Management System Login Screen.
///
/// Designed accurately to match [login.png] with [loginback.png] as the
/// decorative background.
///
/// Features:
/// - Courthouse background from [loginback.png] positioned at the top with
///   golden swooping curve transitioning into deep navy backdrop.
/// - Top welcome section: uppercase eyebrow, serif 'Welcome to Vidhanta' heading
///   (with gold Vidhanta), 3-line subtitle, and gold accent bar.
/// - Floating white logo badge at top-center of the card containing [icon.png].
/// - Pure white login card with rounded corners, subtle border, and soft shadow.
/// - Symmetrical segmented control: Firm Login and Client Login with icons.
/// - Username field with leading person icon and dynamic placeholder.
/// - Password field with leading lock icon and trailing eye toggle.
/// - Gold 'Forgot password?' link opening a secure reset dialog.
/// - Dark navy sign-in button with embedded circular arrow icon badge.
/// - Clean 'OR' divider with horizontal hairline rules.
/// - 'Have an invitation code? / Accept your invite to join' card with envelope icon.
/// - 'New User? Get in Touch / Request Access >' footer outside the card.
/// - Fully responsive across mobile (320px, 360px, 390px, 430px), tablets, and landscape.
class LoginScreen extends ConsumerStatefulWidget {
  final LoginType initialType;

  const LoginScreen({super.key, this.initialType = LoginType.firm});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late LoginType _loginType;
  bool _obscurePassword = true;

  // Vidhanta Palette extracted directly from login.png
  static const Color primaryNavy = Color(0xFF132B4F);
  static const Color deepNavyBg = Color(0xFF0C192E);
  static const Color buttonCircleNavy = Color(0xFF233E67);
  static const Color accentGold = Color(0xFFC5852C);
  static const Color primaryText = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color eyebrowText = Color(0xFF5A718C);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color segmentBg = Color(0xFFF1F5F9);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color errorRedBg = Color(0xFFFEF2F2);

  @override
  void initState() {
    super.initState();
    _loginType = widget.initialType;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    ref.read(authNotifierProvider.notifier).clearError();

    if (_formKey.currentState?.validate() ?? false) {
      final isClient = _loginType == LoginType.client;
      await ref
          .read(authNotifierProvider.notifier)
          .login(
            _usernameController.text.trim(),
            _passwordController.text,
            isClient: isClient,
          );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        final navigator = Navigator.of(dialogCtx);
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset_rounded, color: primaryNavy, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: primaryText,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your account email address. We will send a secure password reset link if the account exists.',
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => navigator.pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: secondaryText),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final email = emailController.text.trim();
                          if (email.isEmpty) return;
                          setDialogState(() => isSubmitting = true);
                          final success = await ref
                              .read(authNotifierProvider.notifier)
                              .forgotPassword(email);
                          if (!mounted) return;
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Password reset link sent to your email.'
                                    : 'Unable to process reset request. Please check the email.',
                              ),
                              backgroundColor: success ? primaryNavy : errorRed,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send Link'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final isNarrow = screenWidth < 360;
        final isShort = screenHeight < 700;

        // Background courthouse image height:
        // Positioned at top with alignment: Alignment.topRight so that:
        // 1. The clean white sky covers the left side where the welcome text sits.
        // 2. The courthouse columns and pediment are crisply framed on the right.
        // 3. The golden swooping curve starts right below the gold accent bar and sweeps behind the badge.
        // 4. Everything below the curve transitions seamlessly into the deep navy backdrop.
        final headerBgHeight = (screenHeight * 0.38).clamp(270.0, 340.0);

        return Scaffold(
          backgroundColor: deepNavyBg,
          body: Stack(
            children: [
              // 1. Rich deep navy gradient filling entire background
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF142B4E),
                        Color(0xFF0E2038),
                        Color(0xFF081426),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Decorative Courthouse Header Image (loginback.png)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: headerBgHeight,
                child: ClipRect(
                  child: Image.asset(
                    'loginback.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topRight,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),

              // 3. Single-Page Layout Layer
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isNarrow ? 16 : 20,
                      vertical: 6,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header Typography Section matching login.png
                          _buildHeaderSection(isNarrow, isShort),
                          SizedBox(height: isShort ? 10 : 12),

                          // Login Card with Overlapping Floating Badge
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              // The Card itself (half of 70px badge = 35px overhang)
                              Padding(
                                padding: const EdgeInsets.only(top: 35),
                                child: _buildLoginCard(
                                  authState,
                                  isNarrow,
                                  isShort,
                                ),
                              ),

                              // Floating White Logo Badge (icon.png)
                              Positioned(
                                top: 0,
                                child: _buildFloatingBadge(),
                              ),
                            ],
                          ),

                          SizedBox(height: isShort ? 12 : 14),

                          // Footer: New User? Get in Touch / Request Access >
                          _buildFooterSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Welcome typography section identical to login.png.
  Widget _buildHeaderSection(bool isNarrow, bool isShort) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Uppercase Eyebrow
        Text(
          'LEGAL MANAGEMENT SYSTEM',
          style: TextStyle(
            fontSize: isNarrow ? 9.5 : (isShort ? 10 : 11),
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: eyebrowText,
          ),
        ),
        SizedBox(height: isShort ? 4 : 6),

        // Welcome to Vidhanta heading
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: isNarrow ? 24 : (isShort ? 26 : 29),
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.15,
              fontFamily: 'serif',
            ),
            children: const [
              TextSpan(
                text: 'Welcome to\n',
                style: TextStyle(color: primaryNavy),
              ),
              TextSpan(
                text: 'Vidhanta',
                style: TextStyle(color: accentGold),
              ),
            ],
          ),
        ),
        SizedBox(height: isShort ? 4 : 6),

        // Subtitle
        Text(
          'Streamline your legal\nmatters with security\nand ease',
          style: TextStyle(
            fontSize: isNarrow ? 12 : (isShort ? 12.5 : 13.5),
            height: 1.35,
            fontWeight: FontWeight.w500,
            color: secondaryText,
          ),
        ),
        SizedBox(height: isShort ? 8 : 10),

        // Gold Accent Bar
        Container(
          width: 38,
          height: 3.5,
          decoration: BoxDecoration(
            color: accentGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  /// Floating white rounded square badge overlapping card top edge.
  Widget _buildFloatingBadge() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: deepNavyBg.withValues(alpha: 0.16),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        'icon.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.balance_rounded, size: 32, color: primaryNavy),
      ),
    );
  }

  /// White Login Card matching login.png.
  Widget _buildLoginCard(dynamic authState, bool isNarrow, bool isShort) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        isNarrow ? 16 : 20,
        40, // Space for the lower half of the 70px overlapping floating badge
        isNarrow ? 16 : 20,
        isShort ? 14 : 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Two-option Segmented Selector
            _buildSegmentedSelector(isNarrow),
            SizedBox(height: isShort ? 12 : 14),

            // Error banner if any
            if (authState.hasError && authState.errorMessage != null) ...[
              _buildErrorBanner(authState.errorMessage!),
              SizedBox(height: isShort ? 10 : 12),
            ],

            // 2. Username field
            _buildUsernameField(authState.isLoading, isNarrow, isShort),
            SizedBox(height: isShort ? 9 : 11),

            // 3. Password field
            _buildPasswordField(authState.isLoading, isNarrow, isShort),
            const SizedBox(height: 5),

            // 4. Forgot password?
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _showForgotPasswordDialog(context),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: accentGold,
                  ),
                ),
              ),
            ),
            SizedBox(height: isShort ? 14 : 18),

            // 5. Primary Sign-in Button with right circular arrow
            _buildSubmitButton(authState.isLoading, isNarrow, isShort),
          ],
        ),
      ),
    );
  }

  /// Segmented Control with Firm Login and Client Login.
  Widget _buildSegmentedSelector(bool isNarrow) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: segmentBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: inputBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentOption(
              type: LoginType.firm,
              label: 'Firm Login',
              icon: Icons.apartment_rounded,
              isNarrow: isNarrow,
            ),
          ),
          Expanded(
            child: _buildSegmentOption(
              type: LoginType.client,
              label: 'Client Login',
              icon: Icons.groups_rounded,
              isNarrow: isNarrow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentOption({
    required LoginType type,
    required String label,
    required IconData icon,
    required bool isNarrow,
  }) {
    final isSelected = _loginType == type;

    return GestureDetector(
      onTap: () {
        if (_loginType != type) {
          setState(() {
            _loginType = type;
          });
          ref.read(authNotifierProvider.notifier).clearError();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? primaryNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryNavy.withValues(alpha: 0.22),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isNarrow ? 15 : 17,
              color: isSelected ? Colors.white : primaryNavy,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isNarrow ? 12 : 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : primaryNavy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Username field.
  Widget _buildUsernameField(bool isLoading, bool isNarrow, bool isShort) {
    final hint = _loginType == LoginType.firm
        ? 'Enter your firm username'
        : 'Enter your client username';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Username',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _usernameController,
          enabled: !isLoading,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontSize: 14, color: primaryText),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: isNarrow ? 12.5 : 13.5,
              color: secondaryText.withValues(alpha: 0.65),
            ),
            prefixIcon: const Icon(
              Icons.person_outline_rounded,
              color: secondaryText,
              size: 20,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: isShort ? 10 : 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryNavy, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: errorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: errorRed, width: 1.5),
            ),
          ),
          validator: Validators.username,
        ),
      ],
    );
  }

  /// Password field.
  Widget _buildPasswordField(bool isLoading, bool isNarrow, bool isShort) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _passwordController,
          enabled: !isLoading,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _onLogin(),
          style: const TextStyle(fontSize: 14, color: primaryText),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Enter your password',
            hintStyle: TextStyle(
              fontSize: isNarrow ? 12.5 : 13.5,
              color: secondaryText.withValues(alpha: 0.65),
            ),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: secondaryText,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: secondaryText,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: isShort ? 10 : 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryNavy, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: errorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: errorRed, width: 1.5),
            ),
          ),
          validator: Validators.password,
        ),
      ],
    );
  }

  /// Primary Sign-in Button with circular forward arrow badge.
  Widget _buildSubmitButton(bool isLoading, bool isNarrow, bool isShort) {
    final buttonLabel = _loginType == LoginType.firm
        ? 'Sign In as Firm'
        : 'Sign In as Client';

    return SizedBox(
      height: isShort ? 46 : 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryNavy.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white70,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                children: [
                  const SizedBox(width: 32),
                  Expanded(
                    child: Center(
                      child: Text(
                        buttonLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isNarrow ? 14 : 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: buttonCircleNavy,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Footer outside the card on the dark navy backdrop.
  Widget _buildFooterSection() {
    return Center(
      child: GestureDetector(
        onTap: () => context.push('/new-user'),
        child: Text.rich(
          TextSpan(
            text: 'New User? ',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(
                text: 'Get in Touch / Request Access ',
                style: TextStyle(
                  color: Color(0xFFE5A84B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFE5A84B),
                  size: 15,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Floating alert banner when authentication returns an error.
  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: errorRedBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: errorRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: errorRed, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: errorRed,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
