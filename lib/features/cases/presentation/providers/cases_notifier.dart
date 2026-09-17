import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/case_model.dart';
import '../../data/repositories/cases_repository.dart';

final caseSearchQueryProvider = StateProvider<String>((ref) => '');
final caseStatusFilterProvider = StateProvider<String?>((ref) => null);

final casesNotifierProvider =
    StateNotifierProvider<CasesNotifier, AsyncValue<List<Case>>>((ref) {
      final repository = ref.watch(casesRepositoryProvider);
      return CasesNotifier(repository);
    });

final filteredCasesProvider = Provider<AsyncValue<List<Case>>>((ref) {
  final casesAsync = ref.watch(casesNotifierProvider);
  final searchQuery = ref.watch(caseSearchQueryProvider).toLowerCase().trim();
  final statusFilter = ref.watch(caseStatusFilterProvider)?.toLowerCase();

  return casesAsync.whenData((cases) {
    return cases.where((c) {
      if (statusFilter != null && c.status.toLowerCase() != statusFilter) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final matchesTitle = c.title.toLowerCase().contains(searchQuery);
        final matchesNumber = c.caseNumber.toLowerCase().contains(searchQuery);
        final matchesCourt = c.courtName.toLowerCase().contains(searchQuery);
        final matchesClient =
            c.clientName?.toLowerCase().contains(searchQuery) ?? false;
        return matchesTitle || matchesNumber || matchesCourt || matchesClient;
      }
      return true;
    }).toList();
  });
});

class CasesNotifier extends StateNotifier<AsyncValue<List<Case>>> {
  final CasesRepository _repository;

  CasesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCases();
  }

  Future<void> loadCases() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getCases());
  }

  Future<Case> createCase(CreateCaseRequest request) async {
    final newCase = await _repository.createCase(request);
    state.whenData((list) {
      state = AsyncValue.data([newCase, ...list]);
    });
    return newCase;
  }

  Future<Case> updateCase(int id, UpdateCaseRequest request) async {
    final updated = await _repository.updateCase(id, request);
    state.whenData((list) {
      state = AsyncValue.data(
        list.map((c) => c.id == id ? updated : c).toList(),
      );
    });
    return updated;
  }

  Future<void> deleteCase(int id) async {
    await _repository.deleteCase(id);
    state.whenData((list) {
      state = AsyncValue.data(list.where((c) => c.id != id).toList());
    });
  }
}
