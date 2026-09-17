import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/models/user_profile.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/branding/data/models/firm_profile.dart';
import '../../features/branding/data/repositories/branding_repository.dart';
import 'firm_theme.dart';

/// Central state notifier managing the firm-scoped application theme.
class FirmThemeNotifier extends StateNotifier<FirmTheme> {
  final BrandingRepository _brandingRepository;
  int? _currentFirmId;

  FirmThemeNotifier(this._brandingRepository) : super(FirmTheme.defaultTheme());

  /// Loads and applies the appropriate theme for [user].
  ///
  /// - Platform Super Admin remains on the neutral platform theme.
  /// - Firm-scoped users (Firm Admin, Lawyers, Staff) receive their firm's branding.
  /// - Reads from local cache first for zero-latency startup, then refreshes from backend.
  Future<void> loadThemeForUser(UserProfile? user) async {
    if (user == null || user.isSuperAdmin) {
      _currentFirmId = null;
      state = FirmTheme.defaultTheme();
      return;
    }

    final int? firmId = user.firmId;
    if (firmId != null) {
      _currentFirmId = firmId;
      // 1. Fast local cache recovery
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedString = prefs.getString('firm_theme_$firmId');
        if (cachedString != null) {
          final Map<String, dynamic> jsonMap = jsonDecode(cachedString);
          if (_currentFirmId == firmId) {
            state = FirmTheme.fromJson(jsonMap);
          }
        }
      } catch (_) {
        // Graceful fallback to default/backend
      }
    }

    // 2. Fetch authoritative firm branding from backend
    try {
      final profile = await _brandingRepository.getFirmProfile();
      final effectiveFirmId = profile.id > 0 ? profile.id : firmId;
      _currentFirmId = effectiveFirmId;

      final freshTheme = FirmTheme.fromProfile(profile);
      state = freshTheme;

      // Persist to local cache for subsequent launches
      if (effectiveFirmId != null && effectiveFirmId > 0) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'firm_theme_$effectiveFirmId',
          jsonEncode(freshTheme.toJson()),
        );
      }
    } catch (_) {
      // Backend unavailable; retain cached or default theme
    }
  }

  /// Instantly updates the theme and local cache from a saved [FirmProfile].
  Future<void> updateFromProfile(FirmProfile profile) async {
    final updatedTheme = FirmTheme.fromProfile(profile);
    state = updatedTheme;

    if (profile.id > 0) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'firm_theme_${profile.id}',
          jsonEncode(updatedTheme.toJson()),
        );
      } catch (_) {}
    }
  }

  /// Resets to default baseline theme on logout.
  void resetToDefault() {
    _currentFirmId = null;
    state = FirmTheme.defaultTheme();
  }
}

/// Global provider for the active firm theme.
final firmThemeProvider = StateNotifierProvider<FirmThemeNotifier, FirmTheme>((
  ref,
) {
  final brandingRepo = ref.watch(brandingRepositoryProvider);
  final notifier = FirmThemeNotifier(brandingRepo);

  // React to auth state changes: login, session restore, logout
  ref.listen<AuthState>(authNotifierProvider, (previous, next) {
    if (next.status == AuthStatus.authenticated && next.user != null) {
      notifier.loadThemeForUser(next.user);
    } else if (next.status == AuthStatus.unauthenticated) {
      notifier.resetToDefault();
    }
  }, fireImmediately: true);

  return notifier;
});
