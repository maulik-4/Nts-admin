import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/hearings_remote_data_source.dart';
import '../models/hearing_model.dart';

final hearingsRepositoryProvider = Provider<HearingsRepository>((ref) {
  final remoteDataSource = ref.watch(hearingsRemoteDataSourceProvider);
  return HearingsRepository(remoteDataSource);
});

class HearingsRepository {
  final HearingsRemoteDataSource _remoteDataSource;

  HearingsRepository(this._remoteDataSource);

  Future<List<Hearing>> getHearings() => _remoteDataSource.getHearings();

  Future<Hearing> getHearing(int id) => _remoteDataSource.getHearing(id);

  Future<Hearing> createHearing(CreateHearingRequest request) =>
      _remoteDataSource.createHearing(request);

  Future<Hearing> updateHearing(int id, UpdateHearingRequest request) =>
      _remoteDataSource.updateHearing(id, request);

  Future<List<Hearing>> getUpcomingHearings({int days = 7}) =>
      _remoteDataSource.getUpcomingHearings(days: days);

  Future<Map<String, dynamic>> notifyClient(int id) =>
      _remoteDataSource.notifyClient(id);

  Future<void> deleteHearing(int id) => _remoteDataSource.deleteHearing(id);
}
