import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/errors/api_exception.dart';
import 'package:flutter_application_1/features/documents/data/datasources/documents_remote_data_source.dart';
import 'package:flutter_application_1/features/documents/data/models/document_model.dart';
import 'package:flutter_application_1/features/documents/data/repositories/documents_repository.dart';

class MockDocumentsRemoteDataSource implements DocumentsRemoteDataSource {
  final List<Document> _docs = [
    const Document(
      id: 4,
      caseId: 4,
      caseTitle: 'State vs Sharma',
      firm: 15,
      file: 'https://api.hphighcourt.site/files/sample_brief.pdf',
    ),
  ];

  bool shouldThrowError = false;

  @override
  Future<List<Document>> getDocuments() async {
    if (shouldThrowError) {
      throw const ApiException(message: 'Error fetching documents');
    }
    return _docs;
  }

  @override
  Future<Document> getDocument(int id) async {
    if (shouldThrowError) {
      throw const ApiException(message: 'Document not found');
    }
    return _docs.firstWhere((d) => d.id == id);
  }

  @override
  Future<Document> uploadDocument({
    required int caseId,
    required String filePath,
    required String fileName,
    ProgressCallback? onProgress,
  }) async {
    if (shouldThrowError) {
      throw const ApiException(message: 'File upload failed');
    }
    final doc = Document(
      id: _docs.length + 1,
      caseId: caseId,
      firm: 15,
      file: 'https://api.hphighcourt.site/files/$fileName',
    );
    _docs.add(doc);
    return doc;
  }

  @override
  Future<void> deleteDocument(int id) async {
    if (shouldThrowError) {
      throw const ApiException(message: 'File delete failed');
    }
    _docs.removeWhere((d) => d.id == id);
  }

  @override
  Future<String> downloadDocument({
    required int id,
    required String savePath,
    ProgressCallback? onProgress,
  }) async {
    if (shouldThrowError) {
      throw const ApiException(message: 'File download failed');
    }
    return savePath;
  }
}

void main() {
  group('DocumentsRepository Tests', () {
    late MockDocumentsRemoteDataSource mockDataSource;
    late DocumentsRepository repository;

    setUp(() {
      mockDataSource = MockDocumentsRemoteDataSource();
      repository = DocumentsRepository(mockDataSource);
    });

    test('getDocuments returns list of documents', () async {
      final docs = await repository.getDocuments();
      expect(docs.length, 1);
      expect(docs.first.fileName, 'sample_brief.pdf');
    });

    test('uploadDocument appends new document', () async {
      final newDoc = await repository.uploadDocument(
        caseId: 4,
        filePath: '/storage/petition.pdf',
        fileName: 'petition.pdf',
      );
      expect(newDoc.fileName, 'petition.pdf');

      final all = await repository.getDocuments();
      expect(all.length, 2);
    });

    test('deleteDocument removes document', () async {
      await repository.deleteDocument(4);
      final all = await repository.getDocuments();
      expect(all.isEmpty, true);
    });

    test('downloadDocument returns saved file path', () async {
      final path = await repository.downloadDocument(
        id: 4,
        savePath: '/local/docs/sample_brief.pdf',
      );
      expect(path, '/local/docs/sample_brief.pdf');
    });

    test('rethrows ApiException on remote failure', () async {
      mockDataSource.shouldThrowError = true;
      expect(() => repository.getDocuments(), throwsA(isA<ApiException>()));
    });
  });
}
