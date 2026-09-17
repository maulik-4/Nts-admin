import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/app_brand_logo.dart';
import '../providers/auth_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize session check as soon as widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(authNotifierProvider.notifier).checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? LexColors.canvasDark : LexColors.canvasLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Vidhanta Brand Logo - completely covers container with BoxFit.cover
            AppBrandLogo(
              size: 84,
              borderRadius: BorderRadius.circular(22),
              showBorder: true,
            ),
            const SizedBox(height: 24),
            Text(
              'VIDHANTA',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 2.0),
            ),
            const SizedBox(height: 6),
            Text(
              'Legal Management System',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? LexColors.textSecondaryDark
                    : LexColors.textSecondaryLight,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? LexColors.accentGold : LexColors.accentBronze,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
