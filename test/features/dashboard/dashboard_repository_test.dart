import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/cases/data/models/case_model.dart';
import 'package:flutter_application_1/features/cases/data/repositories/cases_repository.dart';
import 'package:flutter_application_1/features/clients/data/models/client_model.dart';
import 'package:flutter_application_1/features/clients/data/repositories/clients_repository.dart';
import 'package:flutter_application_1/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:flutter_application_1/features/dashboard/data/models/dashboard_models.dart';
import 'package:flutter_application_1/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:flutter_application_1/features/hearings/data/models/hearing_model.dart';
import 'package:flutter_application_1/features/hearings/data/repositories/hearings_repository.dart';

class MockDashboardRemoteDataSource implements DashboardRemoteDataSource {
  @override
  Future<ClientUsage?> getClientUsage() async {
    return const ClientUsage(
      used: 5,
      limit: 100,
      planName: 'Pro Tier',
      unlimited: false,
    );
  }

  @override
  Future<TaskStats?> getTaskStats() async {
    return const TaskStats(
      total: 12,
      pending: 4,
      inProgress: 3,
      completed: 5,
      overdue: 0,
    );
  }

  @override
  Future<SupportStats?> getSupportStats() async {
    return const SupportStats(total: 2, open: 1, inProgress: 1, resolved: 0);
  }

  @override
  Future<SubscriptionInfo> getActiveSubscription() async {
    return const SubscriptionInfo(
      id: 1,
      isActive: true,
      hasActivePlan: true,
      billingCycle: 'monthly',
    );
  }
}

class MockClientsRepo implements ClientsRepository {
  @override
  Future<List<Client>> getClients() async => [
    const Client(
      id: 1,
      name: 'Client A',
      phone: '123',
      address: 'Shimla',
      firm: 15,
    ),
  ];

  @override
  Future<Client> getClient(int id) => throw UnimplementedError();

  @override
  Future<Client> createClient(CreateClientRequest request) =>
      throw UnimplementedError();

  @override
  Future<Client> updateClient(int id, UpdateClientRequest request) =>
      throw UnimplementedError();

  @override
  Future<void> deleteClient(int id) => throw UnimplementedError();
}

class MockCasesRepo implements CasesRepository {
  @override
  Future<List<Case>> getCases() async => [
    const Case(
      id: 1,
      title: 'Case 1',
      caseNumber: 'C-01',
      caseType: 'Civil',
      courtName: 'High Court',
      status: 'open',
      client: 1,
      firm: 15,
    ),
    const Case(
      id: 2,
      title: 'Case 2',
      caseNumber: 'C-02',
      caseType: 'Criminal',
      courtName: 'High Court',
      status: 'closed',
      client: 1,
      firm: 15,
    ),
  ];

  @override
  Future<Case> getCase(int id) => throw UnimplementedError();

  @override
  Future<Case> createCase(CreateCaseRequest request) =>
      throw UnimplementedError();

  @override
  Future<Case> updateCase(int id, UpdateCaseRequest request) =>
      throw UnimplementedError();

  @override
  Future<void> deleteCase(int id) => throw UnimplementedError();
}

class MockHearingsRepo implements HearingsRepository {
  @override
  Future<List<Hearing>> getHearings() async => [
    const Hearing(
      id: 1,
      title: 'Upcoming Bail Hearing',
      date: '2026-12-01',
      courtName: 'Court 1',
      caseId: 1,
    ),
  ];

  @override
  Future<Hearing> getHearing(int id) => throw UnimplementedError();

  @override
  Future<Hearing> createHearing(CreateHearingRequest request) =>
      throw UnimplementedError();

  @override
  Future<Hearing> updateHearing(int id, UpdateHearingRequest request) =>
      throw UnimplementedError();

  @override
  Future<List<Hearing>> getUpcomingHearings({int days = 7}) async => getHearings();

  @override
  Future<Map<String, dynamic>> notifyClient(int id) async => {'message': 'Notified'};

  @override
  Future<void> deleteHearing(int id) => throw UnimplementedError();
}

void main() {
  group('Dashboard Models and Repository Tests', () {
    test('ClientUsage parses correctly', () {
      final json = {
        'used': 3,
        'limit': null,
        'plan_name': null,
        'unlimited': true,
      };

      final usage = ClientUsage.fromJson(json);

      expect(usage.used, 3);
      expect(usage.limit, isNull);
      expect(usage.unlimited, true);
    });

    test('TaskStats parses correctly', () {
      final json = {
        'total': 10,
        'pending': 2,
        'in_progress': 3,
        'completed': 5,
        'overdue': 0,
      };

      final stats = TaskStats.fromJson(json);

      expect(stats.total, 10);
      expect(stats.pending, 2);
      expect(stats.completed, 5);
    });

    test('SupportStats parses correctly', () {
      final json = {'total': 4, 'open': 1, 'in_progress': 2, 'resolved': 1};

      final stats = SupportStats.fromJson(json);

      expect(stats.total, 4);
      expect(stats.open, 1);
      expect(stats.resolved, 1);
    });

    test('SubscriptionInfo.none returns inactive subscription', () {
      final sub = SubscriptionInfo.none();
      expect(sub.hasActivePlan, false);
      expect(sub.isActive, false);
    });

    test('DashboardRepository aggregates metrics correctly', () async {
      final repo = DashboardRepository(
        MockDashboardRemoteDataSource(),
        MockClientsRepo(),
        MockCasesRepo(),
        MockHearingsRepo(),
      );

      final data = await repo.getDashboardData();

      expect(data.totalClients, 5);
      expect(data.totalCases, 2);
      expect(data.openCases, 1);
      expect(data.closedCases, 1);
      expect(data.upcomingHearingsCount, 1);
      expect(data.subscriptionInfo?.hasActivePlan, true);
      expect(data.taskStats?.total, 12);
      expect(data.supportStats?.total, 2);
    });
  });
}
