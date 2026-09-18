import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/document_model.dart';

final documentsRemoteDataSourceProvider = Provider<DocumentsRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return DocumentsRemoteDataSource(dio);
});

class DocumentsRemoteDataSource {
  final Dio _dio;

  DocumentsRemoteDataSource(this._dio);

  Future<List<Document>> getDocuments() async {
    try {
      final response = await _dio.get(ApiEndpoints.documents);
      final data = response.data;
      if (data is List) {
        return data
            .map((item) => Document.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['results'] is List) {
        return (data['results'] as List)
            .map((item) => Document.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Document> getDocument(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.documents}$id/');
      if (response.data is Map<String, dynamic>) {
        return Document.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Invalid document response format.');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Document> uploadDocument({
    required int caseId,
    required String filePath,
    required String fileName,
    ProgressCallback? onProgress,
  }) async {
    try {
      final multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      );

      final formData = FormData.fromMap({
        'case': caseId,
        'file': multipartFile,
      });

      final response = await _dio.post(
        ApiEndpoints.documents,
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.data is Map<String, dynamic>) {
        return Document.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(
        message: 'Invalid response from document upload.',
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> deleteDocument(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.documents}$id/');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<String> downloadDocument({
    required int id,
    required String savePath,
    ProgressCallback? onProgress,
  }) async {
    try {
      await _dio.download(
        '${ApiEndpoints.documents}$id/download/',
        savePath,
        onReceiveProgress: onProgress,
      );
      return savePath;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Uint8List> getDocumentBytes({
    required int id,
    String? fileUrl,
    ProgressCallback? onProgress,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        '${ApiEndpoints.documents}$id/download/',
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: onProgress,
      );
      if (response.data != null) {
        return Uint8List.fromList(response.data!);
      }
    } on DioException catch (e) {
      if (fileUrl != null && fileUrl.isNotEmpty) {
        try {
          final fallbackResponse = await _dio.get<List<int>>(
            fileUrl,
            options: Options(responseType: ResponseType.bytes),
            onReceiveProgress: onProgress,
          );
          if (fallbackResponse.data != null) {
            return Uint8List.fromList(fallbackResponse.data!);
          }
        } on DioException catch (fallbackErr) {
          if (fallbackErr.error is ApiException) {
            throw fallbackErr.error as ApiException;
          }
          throw ApiException.fromResponse(
            fallbackErr.response?.statusCode,
            fallbackErr.response?.data,
          );
        }
      }

      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }

    throw const ApiException(
      message: 'Empty response while fetching document.',
    );
  }
}
