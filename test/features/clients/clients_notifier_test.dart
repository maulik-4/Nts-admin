import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/features/clients/data/models/client_model.dart';
import 'package:flutter_application_1/features/clients/data/repositories/clients_repository.dart';
import 'package:flutter_application_1/features/clients/presentation/providers/clients_notifier.dart';

class MockClientsRepository implements ClientsRepository {
  List<Client> mockClients = [
    const Client(
      id: 1,
      name: 'Alpha Corp',
      phone: '9876543210',
      address: 'Shimla',
      city: 'Shimla',
      firm: 15,
      isActive: true,
    ),
    const Client(
      id: 2,
      name: 'Beta Ltd',
      phone: '9123456780',
      address: 'Solan',
      city: 'Solan',
      firm: 15,
      isActive: false,
    ),
  ];

  @override
  Future<List<Client>> getClients() async => List<Client>.from(mockClients);

  @override
  Future<Client> getClient(int id) async =>
      mockClients.firstWhere((c) => c.id == id);

  @override
  Future<Client> createClient(CreateClientRequest request) async {
    final newClient = Client(
      id: mockClients.length + 1,
      name: request.name,
      phone: request.phone,
      address: request.address,
      city: request.city,
      firm: request.firm,
    );
    mockClients.add(newClient);
    return newClient;
  }

  @override
  Future<Client> updateClient(int id, UpdateClientRequest request) async {
    final index = mockClients.indexWhere((c) => c.id == id);
    final existing = mockClients[index];
    final updated = existing.copyWith(
      name: request.name,
      city: request.city,
      isActive: request.isActive,
    );
    mockClients[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteClient(int id) async {
    mockClients.removeWhere((c) => c.id == id);
  }
}

void main() {
  group('ClientsNotifier Tests', () {
    late MockClientsRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockClientsRepository();
      container = ProviderContainer(
        overrides: [clientsRepositoryProvider.overrideWithValue(mockRepo)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state loads clients from repository', () async {
      final notifier = container.read(clientsNotifierProvider.notifier);
      await notifier.loadClients();

      final state = container.read(clientsNotifierProvider);
      expect(state.value, isNotNull);
      expect(state.value!.length, 2);
      expect(state.value!.first.name, 'Alpha Corp');
    });

    test('filteredClientsProvider filters by search query', () async {
      await container.read(clientsNotifierProvider.notifier).loadClients();

      container.read(clientSearchQueryProvider.notifier).state = 'Solan';

      final filtered = container.read(filteredClientsProvider);
      expect(filtered.value!.length, 1);
      expect(filtered.value!.first.name, 'Beta Ltd');
    });

    test('createClient adds new client to state', () async {
      await container.read(clientsNotifierProvider.notifier).loadClients();

      const req = CreateClientRequest(
        name: 'Gamma Enterprises',
        phone: '9988776655',
        address: 'Mandi',
        firm: 15,
      );

      final created = await container
          .read(clientsNotifierProvider.notifier)
          .createClient(req);

      expect(created.name, 'Gamma Enterprises');
      final list = container.read(clientsNotifierProvider).value!;
      expect(list.length, 3);
      expect(list.any((c) => c.name == 'Gamma Enterprises'), isTrue);
    });

    test('deleteClient removes client from state', () async {
      await container.read(clientsNotifierProvider.notifier).loadClients();

      await container.read(clientsNotifierProvider.notifier).deleteClient(1);

      final list = container.read(clientsNotifierProvider).value!;
      expect(list.length, 1);
      expect(list.first.id, 2);
    });
  });
}
