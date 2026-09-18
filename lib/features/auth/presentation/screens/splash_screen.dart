import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/lex_colors.dart';
import '../providers/auth_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final Duration minDuration;

  const SplashScreen({
    super.key,
    this.minDuration = const Duration(milliseconds: 1800),
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startInitialization();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startInitialization() async {
    final stopwatch = Stopwatch()..start();

    // Execute session restoration
    try {
      await ref.read(authNotifierProvider.notifier).checkSession();
    } catch (_) {}

    if (!mounted) return;

    // Guarantee minimum display duration so the splash artwork is perceived
    final elapsed = stopwatch.elapsedMilliseconds;
    final remaining = widget.minDuration.inMilliseconds - elapsed;
    if (remaining > 0) {
      _timer = Timer(Duration(milliseconds: remaining), () {
        if (!mounted) return;
        _navigateToNext();
      });
    } else {
      _navigateToNext();
    }
  }

  void _navigateToNext() {
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) {
      context.go('/app/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Main Splash Screen Artwork - preserves exact aspect ratio & scales gracefully
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 480,
                      maxHeight: 480,
                    ),
                    child: Image.asset(
                      'assets/image/splashScreen.png',
                      fit: BoxFit.contain,
                      semanticLabel: 'Vidhanta Law Firm Management System',
                    ),
                  ),
                ),
              ),

              // Subtle Loading Indicator at bottom during startup
              const Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        LexColors.accentBronze,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
