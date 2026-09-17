import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cases/data/models/case_model.dart';
import '../../../cases/data/repositories/cases_repository.dart';
import '../../../clients/data/models/client_model.dart';
import '../../../clients/data/repositories/clients_repository.dart';
import '../../../hearings/data/models/hearing_model.dart';
import '../../../hearings/data/repositories/hearings_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../models/dashboard_models.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final remoteDataSource = ref.watch(dashboardRemoteDataSourceProvider);
  final clientsRepo = ref.watch(clientsRepositoryProvider);
  final casesRepo = ref.watch(casesRepositoryProvider);
  final hearingsRepo = ref.watch(hearingsRepositoryProvider);

  return DashboardRepository(
    remoteDataSource,
    clientsRepo,
    casesRepo,
    hearingsRepo,
  );
});

class DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  final ClientsRepository _clientsRepository;
  final CasesRepository _casesRepository;
  final HearingsRepository _hearingsRepository;

  DashboardRepository(
    this._remoteDataSource,
    this._clientsRepository,
    this._casesRepository,
    this._hearingsRepository,
  );

  Future<DashboardData> getDashboardData() async {
    // Concurrently fetch all metrics and collections
    final results = await Future.wait([
      _remoteDataSource.getClientUsage(),
      _remoteDataSource.getTaskStats(),
      _remoteDataSource.getSupportStats(),
      _remoteDataSource.getActiveSubscription(),
      _clientsRepository.getClients().catchError((_) => <Client>[]),
      _casesRepository.getCases().catchError((_) => <Case>[]),
      _hearingsRepository.getHearings().catchError((_) => <Hearing>[]),
    ]);

    final clientUsage = results[0] as ClientUsage?;
    final taskStats = results[1] as TaskStats?;
    final supportStats = results[2] as SupportStats?;
    final subscriptionInfo = results[3] as SubscriptionInfo?;
    final clients = (results[4] as List).cast<dynamic>();
    final cases = (results[5] as List).cast<dynamic>();
    final hearings = (results[6] as List).cast<dynamic>();

    final totalClients = clientUsage?.used ?? clients.length;
    final totalCases = cases.length;
    final openCases = cases
        .where((c) => c.status.toString().toLowerCase() == 'open')
        .length;
    final closedCases = cases
        .where((c) => c.status.toString().toLowerCase() == 'closed')
        .length;

    // Filter upcoming hearings
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final upcomingHearings = hearings.where((h) {
      final pDate = h.parsedDate;
      if (pDate == null) return true;
      final pDateOnly = DateTime(pDate.year, pDate.month, pDate.day);
      return !pDateOnly.isBefore(todayDateOnly);
    }).toList();

    // Sort upcoming hearings chronologically
    upcomingHearings.sort((a, b) {
      final comp = (a.parsedDate ?? DateTime(2099)).compareTo(
        b.parsedDate ?? DateTime(2099),
      );
      if (comp != 0) return comp;
      return (a.startTime ?? '').compareTo(b.startTime ?? '');
    });

    // Recent cases: up to 4
    final recentCases = cases.take(4).toList();

    return DashboardData(
      clientUsage: clientUsage,
      taskStats: taskStats,
      supportStats: supportStats,
      subscriptionInfo: subscriptionInfo,
      totalClients: totalClients,
      totalCases: totalCases,
      openCases: openCases,
      closedCases: closedCases,
      upcomingHearingsCount: upcomingHearings.length,
      recentCases: List.from(recentCases),
      upcomingHearings: List.from(upcomingHearings.take(3)),
    );
  }
}
