import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/clients_remote_data_source.dart';
import '../models/client_model.dart';

final clientsRepositoryProvider = Provider<ClientsRepository>((ref) {
  final remoteDataSource = ref.watch(clientsRemoteDataSourceProvider);
  return ClientsRepository(remoteDataSource);
});

class ClientsRepository {
  final ClientsRemoteDataSource _remoteDataSource;

  ClientsRepository(this._remoteDataSource);

  Future<List<Client>> getClients() => _remoteDataSource.getClients();

  Future<Client> getClient(int id) => _remoteDataSource.getClient(id);

  Future<Client> createClient(CreateClientRequest request) =>
      _remoteDataSource.createClient(request);

  Future<Client> updateClient(int id, UpdateClientRequest request) =>
      _remoteDataSource.updateClient(id, request);

  Future<void> deleteClient(int id) => _remoteDataSource.deleteClient(id);
}
