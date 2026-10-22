import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/tenant_firm.dart';
import '../../data/repositories/firms_repository.dart';

final firmsNotifierProvider =
    StateNotifierProvider<FirmsNotifier, AsyncValue<List<TenantFirm>>>((ref) {
      final repository = ref.watch(firmsRepositoryProvider);
      return FirmsNotifier(repository);
    });

class FirmsNotifier extends StateNotifier<AsyncValue<List<TenantFirm>>> {
  final FirmsRepository _repository;

  FirmsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFirms();
  }

  Future<void> loadFirms() async {
    state = const AsyncValue.loading();
    try {
      final firms = await _repository.getFirms();
      if (mounted) {
        state = AsyncValue.data(firms);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> createFirm(Map<String, dynamic> firmData) async {
    await _repository.createFirm(firmData);
    await loadFirms();
  }

  Future<void> updateFirm(int firmId, Map<String, dynamic> data) async {
    final updated = await _repository.updateFirm(firmId, data);
    final currentFirms = state.value ?? [];
    final updatedList = currentFirms
        .map((f) => f.id == firmId ? updated : f)
        .toList();
    state = AsyncValue.data(updatedList);
  }

  Future<void> deleteFirm(int firmId) async {
    await _repository.deleteFirm(firmId);
    final currentFirms = state.value ?? [];
    final updatedList = currentFirms.where((f) => f.id != firmId).toList();
    state = AsyncValue.data(updatedList);
  }

  Future<bool> toggleActive(int firmId) async {
    try {
      final newStatus = await _repository.toggleActive(firmId);
      final updatedFirms = state.value?.map((f) {
        if (f.id == firmId) {
          return f.copyWith(isActive: newStatus);
        }
        return f;
      }).toList();
      if (updatedFirms != null) {
        state = AsyncValue.data(updatedFirms);
      }
      return newStatus;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> toggleBlock(int firmId) async {
    try {
      final newStatus = await _repository.toggleBlock(firmId);
      final updatedFirms = state.value?.map((f) {
        if (f.id == firmId) {
          return f.copyWith(isBlocked: newStatus);
        }
        return f;
      }).toList();
      if (updatedFirms != null) {
        state = AsyncValue.data(updatedFirms);
      }
      return newStatus;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFirmStats(int firmId) async {
    return await _repository.getFirmStats(firmId);
  }

  Future<void> changeAdmin(int firmId, int userId) async {
    await _repository.changeAdmin(firmId, userId);
    await loadFirms();
  }
}
