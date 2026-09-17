import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/branding_models.dart';
import '../../data/repositories/branding_repository.dart';

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
