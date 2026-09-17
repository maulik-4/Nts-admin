import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/client_model.dart';

final clientsRemoteDataSourceProvider = Provider<ClientsRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return ClientsRemoteDataSource(dio);
});

class ClientsRemoteDataSource {
  final Dio _dio;

  ClientsRemoteDataSource(this._dio);

  Future<List<Client>> getClients() async {
    try {
      final response = await _dio.get(ApiEndpoints.clients);
      final data = response.data;
      if (data is List) {
        return data
            .map((item) => Client.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['results'] is List) {
        return (data['results'] as List)
            .map((item) => Client.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Client> getClient(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.clients}$id/');
      if (response.data is Map<String, dynamic>) {
        return Client.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Invalid client response format.');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Client> createClient(CreateClientRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.clients,
        data: request.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return Client.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(
        message: 'Invalid response from client creation.',
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Client> updateClient(int id, UpdateClientRequest request) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.clients}$id/',
        data: request.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return Client.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Invalid response from client update.');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> deleteClient(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.clients}$id/');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }
}
