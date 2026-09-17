import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/documents_remote_data_source.dart';
import '../models/document_model.dart';

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  final remoteDataSource = ref.watch(documentsRemoteDataSourceProvider);
  return DocumentsRepository(remoteDataSource);
});

class DocumentsRepository {
  final DocumentsRemoteDataSource _remoteDataSource;

  DocumentsRepository(this._remoteDataSource);

  Future<List<Document>> getDocuments() => _remoteDataSource.getDocuments();

  Future<Document> getDocument(int id) => _remoteDataSource.getDocument(id);

  Future<Document> uploadDocument({
    required int caseId,
    required String filePath,
    required String fileName,
    ProgressCallback? onProgress,
  }) => _remoteDataSource.uploadDocument(
    caseId: caseId,
    filePath: filePath,
    fileName: fileName,
    onProgress: onProgress,
  );

  Future<void> deleteDocument(int id) => _remoteDataSource.deleteDocument(id);

  Future<String> downloadDocument({
    required int id,
    required String savePath,
    ProgressCallback? onProgress,
  }) => _remoteDataSource.downloadDocument(
    id: id,
    savePath: savePath,
    onProgress: onProgress,
  );
}
