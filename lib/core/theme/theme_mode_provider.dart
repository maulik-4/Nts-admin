import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_token_storage.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final storage = ref.watch(secureTokenStorageProvider);
  return ThemeModeNotifier(storage);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SecureTokenStorage _storage;

  ThemeModeNotifier(this._storage) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final raw = await _storage.getThemeMode();
      if (raw == 'light') {
        state = ThemeMode.light;
      } else if (raw == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } catch (_) {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    String val;
    switch (mode) {
      case ThemeMode.light:
        val = 'light';
        break;
      case ThemeMode.dark:
        val = 'dark';
        break;
      case ThemeMode.system:
        val = 'system';
        break;
    }
    await _storage.saveThemeMode(val);
  }
}
