import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/client_dashboard_model.dart';
import '../../data/models/client_document_model.dart';
import '../../data/repositories/client_portal_repository.dart';

final clientDashboardProvider =
    FutureProvider.autoDispose<ClientPortalDashboardData>((ref) async {
      final repo = ref.watch(clientPortalRepositoryProvider);
      return repo.getHearings();
    });

final clientDocumentsSearchQueryProvider = StateProvider<String>((ref) => '');

final clientDocumentsProvider =
    FutureProvider.autoDispose<List<ClientDocumentItem>>((ref) async {
      final repo = ref.watch(clientPortalRepositoryProvider);
      final search = ref.watch(clientDocumentsSearchQueryProvider);
      return repo.getDocuments(search: search.isEmpty ? null : search);
    });

final clientDocumentBytesProvider = FutureProvider.autoDispose
    .family<Uint8List, int>((ref, docId) async {
      final repo = ref.watch(clientPortalRepositoryProvider);
      final link = await repo.getAccessLink(docId);
      return repo.downloadDocumentBytes(
        docId,
        link.token,
        disposition: 'inline',
      );
    });
