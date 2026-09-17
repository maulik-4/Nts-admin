import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/firm_theme_provider.dart';
import '../../data/models/branding_models.dart';
import '../../data/models/firm_profile.dart';
import '../../data/repositories/branding_repository.dart';

final firmProfileNotifierProvider =
    StateNotifierProvider<FirmProfileNotifier, AsyncValue<FirmProfile>>((ref) {
      final repository = ref.watch(brandingRepositoryProvider);
      return FirmProfileNotifier(repository, ref);
    });

class FirmProfileNotifier extends StateNotifier<AsyncValue<FirmProfile>> {
  final BrandingRepository _repository;
  final Ref _ref;

  FirmProfileNotifier(this._repository, this._ref)
    : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getFirmProfile());
  }

  Future<FirmProfile> saveBranding({
    required String themeColor,
    required String accentColor,
    required String fontFamily,
    required bool sidebarDark,
    String? logoFilePath,
    String? logoFileName,
    List<int>? logoBytes,
  }) async {
    final updatedProfile = await _repository.updateFirmBranding(
      themeColor: themeColor,
      accentColor: accentColor,
      fontFamily: fontFamily,
      sidebarDark: sidebarDark,
      logoFilePath: logoFilePath,
      logoFileName: logoFileName,
      logoBytes: logoBytes,
    );
    state = AsyncValue.data(updatedProfile);

    // Immediately update global firm theme across the application
    _ref.read(firmThemeProvider.notifier).updateFromProfile(updatedProfile);

    return updatedProfile;
  }
}

final brandingNotifierProvider =
    StateNotifierProvider<BrandingNotifier, AsyncValue<FirmWebsiteBranding>>((
      ref,
    ) {
      final repository = ref.watch(brandingRepositoryProvider);
      return BrandingNotifier(repository);
    });

class BrandingNotifier extends StateNotifier<AsyncValue<FirmWebsiteBranding>> {
  final BrandingRepository _repository;

  BrandingNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadBranding();
  }

  Future<void> loadBranding() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getWebsiteBranding());
  }

  Future<void> updateBranding(Map<String, dynamic> data) async {
    await _repository.updateWebsiteBranding(data);
    await loadBranding();
  }
}

final firmDetailsNotifierProvider =
    StateNotifierProvider<FirmDetailsNotifier, AsyncValue<FirmDetails>>((ref) {
      final repository = ref.watch(brandingRepositoryProvider);
      return FirmDetailsNotifier(repository);
    });

class FirmDetailsNotifier extends StateNotifier<AsyncValue<FirmDetails>> {
  final BrandingRepository _repository;

  FirmDetailsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDetails();
  }

  Future<void> loadDetails() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getFirmDetails());
  }

  Future<void> updateDetails(Map<String, dynamic> data) async {
    await _repository.updateFirmDetails(data);
    await loadDetails();
  }
}
