import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/hearing_model.dart';
import '../../data/repositories/hearings_repository.dart';

final hearingSearchQueryProvider = StateProvider<String>((ref) => '');
// 'upcoming', 'past', 'all'
final hearingTimeFilterProvider = StateProvider<String>((ref) => 'upcoming');

final hearingsNotifierProvider =
    StateNotifierProvider<HearingsNotifier, AsyncValue<List<Hearing>>>((ref) {
      final repository = ref.watch(hearingsRepositoryProvider);
      return HearingsNotifier(repository);
    });

final filteredHearingsProvider = Provider<AsyncValue<List<Hearing>>>((ref) {
  final hearingsAsync = ref.watch(hearingsNotifierProvider);
  final searchQuery = ref
      .watch(hearingSearchQueryProvider)
      .toLowerCase()
      .trim();
  final timeFilter = ref.watch(hearingTimeFilterProvider);
  final today = DateTime.now();
  final todayDateOnly = DateTime(today.year, today.month, today.day);

  return hearingsAsync.whenData((hearings) {
    final list = hearings.where((h) {
      final hDate = h.parsedDate;
      if (hDate != null) {
        final hDateOnly = DateTime(hDate.year, hDate.month, hDate.day);
        if (timeFilter == 'upcoming' && hDateOnly.isBefore(todayDateOnly)) {
          return false;
        }
        if (timeFilter == 'past' && !hDateOnly.isBefore(todayDateOnly)) {
          return false;
        }
      }

      if (searchQuery.isNotEmpty) {
        final matchesTitle = h.title.toLowerCase().contains(searchQuery);
        final matchesCourt = h.courtName.toLowerCase().contains(searchQuery);
        final matchesJudge =
            h.judgeName?.toLowerCase().contains(searchQuery) ?? false;
        return matchesTitle || matchesCourt || matchesJudge;
      }
      return true;
    }).toList();

    // Sort chronologically
    list.sort((a, b) {
      final dateComp = (a.parsedDate ?? DateTime(2099)).compareTo(
        b.parsedDate ?? DateTime(2099),
      );
      if (dateComp != 0) return dateComp;
      return (a.startTime ?? '').compareTo(b.startTime ?? '');
    });

    return list;
  });
});

class HearingsNotifier extends StateNotifier<AsyncValue<List<Hearing>>> {
  final HearingsRepository _repository;

  HearingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadHearings();
  }

  Future<void> loadHearings() async {
    state = const AsyncValue.loading();
    final res = await AsyncValue.guard(() => _repository.getHearings());
    if (mounted) state = res;
  }

  Future<Hearing> createHearing(CreateHearingRequest request) async {
    final newHearing = await _repository.createHearing(request);
    state.whenData((list) {
      state = AsyncValue.data([newHearing, ...list]);
    });
    return newHearing;
  }

  Future<Hearing> updateHearing(int id, UpdateHearingRequest request) async {
    final updated = await _repository.updateHearing(id, request);
    state.whenData((list) {
      state = AsyncValue.data(
        list.map((h) => h.id == id ? updated : h).toList(),
      );
    });
    return updated;
  }

  Future<void> deleteHearing(int id) async {
    await _repository.deleteHearing(id);
    state.whenData((list) {
      state = AsyncValue.data(list.where((h) => h.id != id).toList());
    });
  }
}
