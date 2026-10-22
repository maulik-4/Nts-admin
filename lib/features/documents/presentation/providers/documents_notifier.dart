import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/document_model.dart';
import '../../data/repositories/documents_repository.dart';

final documentSearchQueryProvider = StateProvider<String>((ref) => '');
final documentCaseFilterProvider = StateProvider<int?>((ref) => null);

final documentsNotifierProvider =
    StateNotifierProvider<DocumentsNotifier, AsyncValue<List<Document>>>((ref) {
      final repository = ref.watch(documentsRepositoryProvider);
      return DocumentsNotifier(repository);
    });

final filteredDocumentsProvider = Provider<AsyncValue<List<Document>>>((ref) {
  final docsAsync = ref.watch(documentsNotifierProvider);
  final searchQuery = ref
      .watch(documentSearchQueryProvider)
      .toLowerCase()
      .trim();
  final caseFilter = ref.watch(documentCaseFilterProvider);

  return docsAsync.whenData((docs) {
    return docs.where((d) {
      if (caseFilter != null && d.caseId != caseFilter) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final matchesName = d.fileName.toLowerCase().contains(searchQuery);
        final matchesCase =
            d.caseTitle?.toLowerCase().contains(searchQuery) ?? false;
        final matchesExt = d.fileExtension.toLowerCase().contains(searchQuery);
        return matchesName || matchesCase || matchesExt;
      }
      return true;
    }).toList();
  });
});

final documentDetailProvider = FutureProvider.family<Document, int>((
  ref,
  id,
) async {
  final repository = ref.watch(documentsRepositoryProvider);
  return repository.getDocument(id);
});

class DocumentsNotifier extends StateNotifier<AsyncValue<List<Document>>> {
  final DocumentsRepository _repository;

  DocumentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    state = const AsyncValue.loading();
    final res = await AsyncValue.guard(() => _repository.getDocuments());
    if (mounted) {
      state = res;
    }
  }

  Future<Document> uploadDocument({
    required int caseId,
    required String filePath,
    required String fileName,
    ProgressCallback? onProgress,
  }) async {
    final newDoc = await _repository.uploadDocument(
      caseId: caseId,
      filePath: filePath,
      fileName: fileName,
      onProgress: onProgress,
    );
    state.whenData((list) {
      state = AsyncValue.data([newDoc, ...list]);
    });
    return newDoc;
  }

  Future<void> deleteDocument(int id) async {
    await _repository.deleteDocument(id);
    state.whenData((list) {
      state = AsyncValue.data(list.where((d) => d.id != id).toList());
    });
  }
}
