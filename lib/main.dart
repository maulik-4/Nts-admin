import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/firm_theme_provider.dart';
import 'core/theme/lex_theme.dart';

import 'core/theme/theme_mode_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const ProviderScope(child: NTSLegalProApp()));
}

class NTSLegalProApp extends ConsumerWidget {
  const NTSLegalProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final firmTheme = ref.watch(firmThemeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: firmTheme.firmName ?? 'Vidhanta',
      debugShowCheckedModeBanner: false,
      theme: LexTheme.buildDynamicTheme(firmTheme: firmTheme, isDark: false),
      darkTheme: LexTheme.buildDynamicTheme(firmTheme: firmTheme, isDark: true),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
