import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/cases_remote_data_source.dart';
import '../models/case_model.dart';

final casesRepositoryProvider = Provider<CasesRepository>((ref) {
  final remoteDataSource = ref.watch(casesRemoteDataSourceProvider);
  return CasesRepository(remoteDataSource);
});

class CasesRepository {
  final CasesRemoteDataSource _remoteDataSource;

  CasesRepository(this._remoteDataSource);

  Future<List<Case>> getCases() => _remoteDataSource.getCases();

  Future<Case> getCase(int id) => _remoteDataSource.getCase(id);

  Future<Case> createCase(CreateCaseRequest request) =>
      _remoteDataSource.createCase(request);

  Future<Case> updateCase(int id, UpdateCaseRequest request) =>
      _remoteDataSource.updateCase(id, request);

  Future<void> deleteCase(int id) => _remoteDataSource.deleteCase(id);
}
