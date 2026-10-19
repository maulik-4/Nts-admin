import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/client_document_access_model.dart';

final documentSharingRepositoryProvider = Provider<DocumentSharingRepository>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return DocumentSharingRepository(dio);
});

class DocumentSharingRepository {
  final Dio _dio;

  DocumentSharingRepository(this._dio);

  /// Endpoint 3.1: Share Document with Client
  Future<Map<String, dynamic>> shareDocumentWithClient(
    int clientId,
    int docId, {
    int expiresInDays = 30,
    String? message,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.clientShareDocument(clientId, docId),
        data: {
          'expires_in_days': expiresInDays,
          if (message != null && message.trim().isNotEmpty)
            'message': message.trim(),
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Endpoint 3.2: Revoke Document Sharing
  Future<void> revokeDocumentSharing(int clientId, int docId) async {
    try {
      await _dio.delete(ApiEndpoints.clientShareDocument(clientId, docId));
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Endpoint 3.3: List Documents Shared with Specific Client
  Future<List<ClientDocumentAccessItem>> listSharedDocuments(
    int clientId,
  ) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.clientSharedDocuments(clientId),
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['results'] is List) {
        return (data['results'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => ClientDocumentAccessItem.fromJson(e))
            .toList();
      } else if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => ClientDocumentAccessItem.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  /// Endpoint 1.4: Send Client Invite
  Future<Map<String, dynamic>> inviteClient({
    required String email,
    required String clientName,
    String? message,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.clientInvite,
        data: {
          'email': email.trim(),
          'client_name': clientName.trim(),
          if (message != null && message.trim().isNotEmpty)
            'message': message.trim(),
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }
}
