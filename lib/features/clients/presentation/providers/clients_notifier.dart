import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/client_model.dart';
import '../../data/repositories/clients_repository.dart';

final clientSearchQueryProvider = StateProvider<String>((ref) => '');
final clientActiveFilterProvider = StateProvider<bool?>((ref) => null);

final clientsNotifierProvider =
    StateNotifierProvider<ClientsNotifier, AsyncValue<List<Client>>>((ref) {
      final repository = ref.watch(clientsRepositoryProvider);
      return ClientsNotifier(repository);
    });

final filteredClientsProvider = Provider<AsyncValue<List<Client>>>((ref) {
  final clientsAsync = ref.watch(clientsNotifierProvider);
  final searchQuery = ref.watch(clientSearchQueryProvider).toLowerCase().trim();
  final activeFilter = ref.watch(clientActiveFilterProvider);

  return clientsAsync.whenData((clients) {
    return clients.where((client) {
      if (activeFilter != null && client.isActive != activeFilter) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final matchesName = client.name.toLowerCase().contains(searchQuery);
        final matchesPhone = client.phone.toLowerCase().contains(searchQuery);
        final matchesEmail =
            client.email?.toLowerCase().contains(searchQuery) ?? false;
        final matchesCity =
            client.city?.toLowerCase().contains(searchQuery) ?? false;
        return matchesName || matchesPhone || matchesEmail || matchesCity;
      }
      return true;
    }).toList();
  });
});

class ClientsNotifier extends StateNotifier<AsyncValue<List<Client>>> {
  final ClientsRepository _repository;

  ClientsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadClients();
  }

  Future<void> loadClients() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getClients());
  }

  Future<Client> createClient(CreateClientRequest request) async {
    final newClient = await _repository.createClient(request);
    state.whenData((list) {
      state = AsyncValue.data([newClient, ...list]);
    });
    return newClient;
  }

  Future<Client> updateClient(int id, UpdateClientRequest request) async {
    final updated = await _repository.updateClient(id, request);
    state.whenData((list) {
      state = AsyncValue.data(
        list.map((c) => c.id == id ? updated : c).toList(),
      );
    });
    return updated;
  }

  Future<void> deleteClient(int id) async {
    await _repository.deleteClient(id);
    state.whenData((list) {
      state = AsyncValue.data(list.where((c) => c.id != id).toList());
    });
  }
}
