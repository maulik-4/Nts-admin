import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/firm_theme_provider.dart';
import 'core/theme/lex_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: NTSLegalProApp()));
}

class NTSLegalProApp extends ConsumerWidget {
  const NTSLegalProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final firmTheme = ref.watch(firmThemeProvider);

    return MaterialApp.router(
      title: firmTheme.firmName ?? 'NTS Legal Pro',
      debugShowCheckedModeBanner: false,
      theme: LexTheme.buildDynamicTheme(firmTheme: firmTheme, isDark: false),
      darkTheme: LexTheme.buildDynamicTheme(firmTheme: firmTheme, isDark: true),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
