import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../../auth/domain/models/user.dart';
import '../models/access_link_model.dart';
import '../models/client_dashboard_model.dart';
import '../models/client_document_model.dart';

final clientPortalRepositoryProvider = Provider<ClientPortalRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(secureTokenStorageProvider);
  return ClientPortalRepository(dio, tokenStorage);
});

class ClientPortalRepository {
  final Dio _dio;
  final SecureTokenStorage _tokenStorage;

  ClientPortalRepository(this._dio, this._tokenStorage);

  /// Endpoint 1.1: Client Portal Login
  Future<User> clientLogin({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.clientLogin,
        data: {'username': usernameOrEmail.trim(), 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data);

      final accessToken =
          data['access']?.toString() ?? data['token']?.toString() ?? '';
      final refreshToken = data['refresh']?.toString() ?? '';

      if (accessToken.isNotEmpty) {
        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        await _tokenStorage.saveUser(user);
        await _tokenStorage.saveCredentials(
          username: usernameOrEmail.trim(),
          password: password,
        );
      }

      return user;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Endpoint 1.2: Validate Client Invite Token
  Future<Map<String, dynamic>> validateInvite(String token) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.clientAcceptInvite,
        queryParameters: {'token': token.trim()},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Endpoint 1.3: Accept Client Invite & Create Account
  Future<User> acceptInvite({
    required String token,
    required String username,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.clientAcceptInvite,
        data: {
          'token': token.trim(),
          'username': username.trim(),
          'password': password,
          if (firstName != null && firstName.trim().isNotEmpty)
            'first_name': firstName.trim(),
          if (lastName != null && lastName.trim().isNotEmpty)
            'last_name': lastName.trim(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data);

      final accessToken =
          data['access']?.toString() ?? data['token']?.toString() ?? '';
      final refreshToken = data['refresh']?.toString() ?? '';

      if (accessToken.isNotEmpty) {
        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        await _tokenStorage.saveUser(user);
        await _tokenStorage.saveCredentials(
          username: username.trim(),
          password: password,
        );
      }

      return user;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Endpoint 2.1: Client Dashboard Hearings & Counsel Info
  Future<ClientPortalDashboardData> getHearings() async {
    try {
      final response = await _dio.get(ApiEndpoints.clientHearings);
      return ClientPortalDashboardData.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Endpoint 2.2: Client Shared Documents List
  Future<List<ClientDocumentItem>> getDocuments({String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _dio.get(
        ApiEndpoints.clientDocuments,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['results'] is List) {
        return (data['results'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => ClientDocumentItem.fromJson(e))
            .toList();
      } else if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => ClientDocumentItem.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Endpoint 2.3: Generate Time-Limited Document Download Link
  Future<DocumentAccessLink> getAccessLink(int docId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.clientDocumentAccessLink(docId),
      );
      return DocumentAccessLink.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Endpoint 2.4: Signed Document Download & Preview Stream
  Future<Uint8List> downloadDocumentBytes(
    int docId,
    String token, {
    String disposition = 'inline',
  }) async {
    try {
      final path = ApiEndpoints.clientDocumentDownload(
        docId,
        token,
        disposition: disposition,
      );

      final response = await _dio.get<List<int>>(
        path,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': '*/*'},
        ),
      );

      return Uint8List.fromList(response.data ?? []);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }
}
