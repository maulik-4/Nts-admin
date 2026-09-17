import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/support_ticket.dart';
import '../../data/repositories/support_repository.dart';

final supportStatsProvider = FutureProvider<SupportStats>((ref) {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getStats();
});

final supportNotifierProvider =
    StateNotifierProvider<SupportNotifier, AsyncValue<List<SupportTicket>>>((
      ref,
    ) {
      final repository = ref.watch(supportRepositoryProvider);
      return SupportNotifier(repository);
    });

final supportDetailProvider = FutureProvider.family<SupportTicket, int>((
  ref,
  id,
) {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getTicketDetail(id);
});

class SupportNotifier extends StateNotifier<AsyncValue<List<SupportTicket>>> {
  final SupportRepository _repository;

  SupportNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTickets();
  }

  Future<void> loadTickets() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getTickets());
  }

  Future<SupportTicket> createTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    final ticket = await _repository.createTicket(
      subject: subject,
      description: description,
      category: category,
      priority: priority,
    );
    await loadTickets();
    return ticket;
  }

  Future<void> resolveTicket(int id) async {
    await _repository.resolveTicket(id);
    await loadTickets();
  }
}
